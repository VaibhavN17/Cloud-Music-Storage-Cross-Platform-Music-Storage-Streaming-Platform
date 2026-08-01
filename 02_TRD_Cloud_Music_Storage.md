# Technical Requirement Document (TRD)
## Cloud Music Storage

---

## Table of Contents
1. Architecture Overview
2. Frontend Architecture
3. Backend Architecture
4. Database
5. Storage
6. Streaming
7. Caching
8. Authentication & Authorization
9. Security
10. Logging & Monitoring
11. Deployment & Scalability
12. Performance Targets
13. Folder Structure
14. Coding Standards
15. Environment Variables

---

## 1. Architecture Overview

```
                         ┌────────────────────┐
                         │   Cloudflare CDN    │
                         └─────────┬───────────┘
                                   │
      ┌────────────────────────────────────────────────────┐
      │                    Load Balancer                     │
      └─────────┬────────────────────────────┬───────────────┘
                 │                            │
     ┌───────────▼───────────┐   ┌────────────▼────────────┐
     │  Express.js API (N)    │   │  Express.js API (N)      │
     │  TypeScript, stateless │   │  stateless, autoscaled   │
     └───────────┬───────────┘   └────────────┬─────────────┘
                 │                             │
        ┌────────┴─────────────────────────────┴────────┐
        │                                                 │
 ┌──────▼──────┐   ┌──────────────┐   ┌─────────────┐   ┌▼────────────┐
 │  PostgreSQL  │   │    Redis      │   │ Cloudflare  │   │  Socket.IO   │
 │ (Prisma ORM) │   │ cache/session │   │  R2 Storage │   │  (optional)  │
 └──────────────┘   │  rate-limit   │   │  audio/art  │   └──────────────┘
                     └──────────────┘   └─────────────┘
```

Clients (Flutter apps on Android/iOS/Windows/macOS/Linux/Web) talk to the Express REST API over HTTPS. Audio bytes are never proxied through the API for playback — clients stream directly from Cloudflare R2/CDN using short-lived signed URLs issued by the API.

## 2. Frontend Architecture (Flutter)

- **Pattern**: Clean Architecture, Feature-First module layout.
- **State management**: Riverpod (StateNotifier/AsyncNotifier per feature).
- **Routing**: GoRouter with auth-guarded route redirection.
- **Networking**: Dio with interceptors for JWT attach, refresh-token retry, and structured error mapping.
- **Local storage**: Hive/Isar for offline cache of library metadata; platform file system for downloaded audio blobs (encrypted at rest where platform supports it).
- **Audio engine**: `just_audio` + `audio_service` for background playback, lock-screen controls, and queue management across platforms.
- **Dependency Injection**: Riverpod providers act as the DI graph; no separate service locator needed.

## 3. Backend Architecture (Express.js + TypeScript)

- Layered architecture: **Routes → Controllers → Services → Repositories → Prisma**.
- DTOs validated at the controller boundary using Zod (or class-validator) before hitting services.
- Business logic lives exclusively in Services; Repositories are the only layer touching Prisma.
- Background/async work (metadata extraction, artwork processing, transcoding) handled by a **Worker** process pool consuming a Redis-backed queue (BullMQ).
- Socket.IO (optional) used only for live cross-device sync events (e.g., "now playing" push), not for core data mutations.

## 4. Database — PostgreSQL via Prisma

- Primary relational store for users, tracks, playlists, folders, follows, likes, comments, reports, admin/audit logs.
- Read-heavy metadata queries (library browse, search) backed by composite indexes; full-text search via PostgreSQL `tsvector` on title/artist/album.
- Soft-delete pattern (`deletedAt` timestamp) for Trash/Restore feature; hard purge job runs nightly for records >30 days soft-deleted.

## 5. Storage — Cloudflare R2

- Buckets segmented by purpose: `audio-private/`, `audio-public/`, `artwork/`, `waveforms/` (future).
- Object key convention: `{userId}/{trackId}/original.{ext}` and `{userId}/{trackId}/artwork.jpg`.
- Uploads go through a **presigned PUT URL** issued by the API; large files use multipart/chunked upload.
- All read access — private or public — is via short-lived **signed GET URLs** (TTL 5–15 min), never public bucket ACLs, even for "Public" tracks (public tracks get longer-TTL signed URLs served through CDN edge cache).

## 6. Streaming

- Audio served via Cloudflare CDN edge cache in front of R2, using HTTP range requests for seek support.
- Adaptive delivery: original file served with range-request support; optional future transcoding to lower-bitrate variants for constrained networks.
- Playback session tracked server-side (track id, position, device) for cross-device resume, written asynchronously (not blocking playback) via a lightweight `POST /playback/heartbeat`.

## 7. Caching

- **Redis** used for: JWT refresh-token allow-list, rate-limiting counters (per-IP and per-user), hot library-metadata cache (recently accessed folders/playlists), signed-URL issuance throttling, Socket.IO pub/sub adapter (if multi-instance).
- Cache invalidation on writes: metadata edit/delete invalidates the relevant user's library cache key.

## 8. Authentication & Authorization

- JWT access tokens (short-lived, 15 min) + rotating refresh tokens (7–30 days, stored hashed, revocable via Redis allow-list).
- OAuth: Google Sign-In and Apple Sign-In via standard OAuth2/OIDC flows, mapped to internal user records by verified email.
- Optional TOTP-based 2FA (RFC 6238) at login.
- Authorization via RBAC: roles `user`, `artist` (implicit once a track is published), `moderator`, `admin`. Middleware enforces route-level role checks; resource-level checks (e.g., "is owner") enforced in Services.

## 9. Security

- All traffic over TLS 1.2+; HSTS enabled.
- Input validation at API boundary (Zod schemas) rejects malformed payloads before reaching services.
- Parameterized queries via Prisma eliminate raw SQL injection surface; any raw queries reviewed and parameterized explicitly.
- XSS mitigated via output encoding on any user-generated text (comments, bios) and strict CSP headers on web client.
- CSRF not applicable to token-based API (no cookies for auth), but CSRF protection applied to any cookie-based admin session if used.
- File upload validation: MIME-type sniffing + extension allow-list + max file size + malware/AV scan hook before marking upload "ready."
- Secrets managed via environment variables / secret manager, never committed; R2 credentials scoped to least privilege per bucket.

## 10. Logging & Monitoring

- Structured JSON logging (pino) with request IDs correlated across services and workers.
- Centralized log aggregation (e.g., ELK/Datadog-class tool) — pluggable, environment-specific.
- Error tracking via Sentry-class tool for both backend and Flutter clients.
- Uptime/latency monitoring on API and CDN edge; alerting thresholds on P95 latency, 5xx rate, and queue backlog depth.
- Admin audit log: every moderation/admin action recorded with actor, timestamp, before/after state.

## 11. Deployment & Scalability

- Containerized (Docker) Express API and Worker processes, deployed behind a load balancer, horizontally autoscaled on CPU/queue-depth.
- PostgreSQL managed instance with read replica(s) as read traffic grows; connection pooling via PgBouncer.
- Redis managed cluster with persistence for allow-list durability.
- Cloudflare R2 + CDN scales natively; no origin bottleneck for audio delivery.
- Blue/green or rolling deployment strategy; migrations run via Prisma Migrate in a pre-deploy step with backward-compatible schema changes preferred.

## 12. Performance Targets

| Metric | Target |
|---|---|
| API P95 latency (metadata endpoints) | <200ms |
| Stream time-to-first-byte | <300ms P50, <800ms P95 |
| Upload throughput per connection | Network-bound, chunked/resumable |
| Search query response | <150ms P95 |
| Concurrent streaming sessions per API node | 5,000+ (stateless, scales horizontally) |

## 13. Folder Structure (high-level pointer)

See dedicated Backend and Flutter folder-structure documents for full detail; TRD-level summary:
- Backend: `src/{routes,controllers,services,repositories,middlewares,dto,validators,workers,utils,config}`
- Flutter: `lib/{core,features,shared}` with each feature owning `data/domain/presentation`.

## 14. Coding Standards

- TypeScript strict mode; ESLint + Prettier enforced pre-commit (Husky).
- Dart: effective_dart lint set, `flutter analyze` clean on CI.
- Naming: `camelCase` for variables/functions, `PascalCase` for classes/types, `SCREAMING_SNAKE_CASE` for constants/env keys.
- No business logic in controllers or widgets — controllers/widgets orchestrate only.
- Every public function/service documented with a short doc comment describing intent, params, and error cases.

## 15. Environment Variables (sample)

```
# API
NODE_ENV=production
PORT=4000
JWT_ACCESS_SECRET=
JWT_REFRESH_SECRET=
JWT_ACCESS_TTL=15m
JWT_REFRESH_TTL=30d

# Database
DATABASE_URL=postgresql://user:pass@host:5432/cloudmusic

# Redis
REDIS_URL=redis://host:6379

# Cloudflare R2
R2_ACCOUNT_ID=
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_BUCKET_AUDIO_PRIVATE=
R2_BUCKET_AUDIO_PUBLIC=
R2_BUCKET_ARTWORK=
R2_SIGNED_URL_TTL_SECONDS=600

# OAuth
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
APPLE_CLIENT_ID=
APPLE_TEAM_ID=
APPLE_KEY_ID=
APPLE_PRIVATE_KEY=

# Misc
SENTRY_DSN=
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX=100
```
