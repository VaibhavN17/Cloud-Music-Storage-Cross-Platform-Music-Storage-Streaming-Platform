# Implementation Plan
## Cloud Music Storage

---

## Table of Contents
1. Phase 1 — Planning
2. Phase 2 — UI
3. Phase 3 — Backend
4. Phase 4 — Upload
5. Phase 5 — Streaming
6. Phase 6 — Public Music
7. Phase 7 — Admin
8. Phase 8 — Testing
9. Phase 9 — Deployment
10. Timeline Summary

---

## Phase 1 — Planning (Week 1–2)

**Objectives**: Lock scope, architecture, and design foundations before writing product code.

**Tasks**
- Finalize PRD/TRD sign-off with stakeholders.
- Set up repos (backend, Flutter app), branch strategy, CI skeleton.
- Provision PostgreSQL, Redis, Cloudflare R2 buckets (dev/staging).
- Define Prisma schema v1 and run initial migration.

**Deliverables**: Approved PRD/TRD, initialized repos, provisioned dev infra, Prisma schema v1.
**Dependencies**: None.
**Estimated Time**: 2 weeks.
**Risks**: Scope creep from stakeholders — mitigate with a frozen MVP feature list (see PRD §10).

## Phase 2 — UI (Week 3–6)

**Objectives**: Build the design system and static screens before wiring real data.

**Tasks**
- Implement design tokens, theme (dark/light), typography, component library in Flutter.
- Build screens: Splash, Onboarding, Login, Signup, Forgot Password, OTP, Home, Library, Player (mini + full), Search, Profile, Settings — with mock data.
- Set up GoRouter navigation graph and Riverpod state scaffolding.

**Deliverables**: Navigable, styled Flutter app shell with mock data across MVP screens.
**Dependencies**: Phase 1 design tokens finalized.
**Estimated Time**: 4 weeks.
**Risks**: Design/dev drift — mitigate with weekly design QA pass.

## Phase 3 — Backend (Week 5–9, overlaps Phase 2)

**Objectives**: Stand up core API — auth, users, folders, playlists, favorites.

**Tasks**
- Implement Express + TypeScript project structure (controllers/services/repositories/middlewares).
- Auth: email/password, Google/Apple OAuth, email verification, forgot password, JWT + refresh flow.
- CRUD APIs for Folder, Playlist, Favorite, Follow, Comment.
- Rate limiting, validation middleware, error-handling middleware.

**Deliverables**: Deployed staging API covering auth + library CRUD, Postman/OpenAPI collection.
**Dependencies**: Phase 1 schema, infra.
**Estimated Time**: 5 weeks.
**Risks**: OAuth provider setup delays (Apple especially) — start provider registration in Phase 1.

## Phase 4 — Upload (Week 9–11)

**Objectives**: Full upload pipeline from client to R2 with metadata extraction.

**Tasks**
- Presigned upload URL endpoint + chunked/resumable upload support.
- Worker service: metadata extraction (ID3/Vorbis/MP4), artwork extraction, file validation/AV scan hook.
- Flutter: drag-and-drop (desktop/web), file picker (mobile), background upload with progress + retry.
- Trash/Restore soft-delete implementation.

**Deliverables**: End-to-end working upload from all target platforms into a real library.
**Dependencies**: Phase 3 API, R2 buckets from Phase 1.
**Estimated Time**: 3 weeks.
**Risks**: Cross-platform file-picker/drag-drop inconsistencies — allocate platform-specific QA time.

## Phase 5 — Streaming (Week 11–13)

**Objectives**: Reliable playback across devices with signed URLs and background audio.

**Tasks**
- Signed streaming URL endpoint with TTL + range-request support via CDN.
- Flutter audio engine integration (`just_audio` + `audio_service`): mini player, full player, queue, shuffle/repeat.
- Playback heartbeat + cross-device resume.
- Offline download implementation with encrypted local cache and quota display.

**Deliverables**: Gapless streaming + offline playback working on all platforms.
**Dependencies**: Phase 4 upload pipeline (need real audio files to stream).
**Estimated Time**: 3 weeks.
**Risks**: iOS background-audio and Android battery-optimization edge cases — dedicate a hardening sub-sprint.

## Phase 6 — Public Music (Week 13–16)

**Objectives**: Opt-in public publishing layer with social features.

**Tasks**
- Publish flow with ownership attestation + ToS acceptance capture.
- Artist profile, followers, likes, comments, public playlists, shareable links.
- Report abuse + DMCA report submission flow (user-facing).

**Deliverables**: Users can publish tracks publicly and be discovered/followed; reporting flow live.
**Dependencies**: Phase 3/4/5 complete.
**Estimated Time**: 3 weeks.
**Risks**: Legal/compliance review needed on attestation + DMCA wording before launch — involve legal early in this phase, not after.

## Phase 7 — Admin (Week 16–18)

**Objectives**: Operational tooling for trust & safety and platform health.

**Tasks**
- Admin dashboard: stats overview, user management (search/suspend/reinstate).
- Reports queue: review, evidence view, approve/reject with audit logging.
- Storage analytics and system log viewer.

**Deliverables**: Functional admin panel deployed to a restricted internal route/app.
**Dependencies**: Phase 6 reports data model.
**Estimated Time**: 2–3 weeks.
**Risks**: Admin panel security — enforce RBAC + IP allow-list/2FA-required for admin roles.

## Phase 8 — Testing (Week 18–20, continuous throughout)

**Objectives**: Verify correctness, performance, and security before launch.

**Tasks**
- Unit tests (backend services, Flutter notifiers/repositories).
- Integration + API tests (Postman/Newman or supertest suite).
- Flutter widget/integration tests for critical flows (auth, upload, playback).
- Manual QA pass per platform.
- Load testing streaming + upload endpoints; security testing (OWASP checklist, dependency audit).

**Deliverables**: Test reports, coverage thresholds met (e.g., ≥70% backend service coverage), signed-off security checklist.
**Dependencies**: Feature-complete build from Phases 3–7.
**Estimated Time**: 2 weeks dedicated + ongoing.
**Risks**: Testing squeezed by schedule pressure — protect this phase explicitly in planning, don't let it silently shrink.

## Phase 9 — Deployment (Week 20–21)

**Objectives**: Ship to production across all platforms.

**Tasks**
- Finalize CI/CD pipelines (build, test, deploy) for backend and Flutter (app store/play store/web/desktop packaging).
- Production infra cutover: PostgreSQL, Redis, R2 production buckets, monitoring/alerting wired.
- App store / Play Store submission; web deployment; desktop installer builds.
- Rollback plan validated (DB migration rollback + previous container image ready).

**Deliverables**: Live production app across Android, iOS, Web, and initial desktop builds; monitoring dashboards active.
**Dependencies**: Phase 8 sign-off.
**Estimated Time**: 1–2 weeks.
**Risks**: App store review delays — submit builds 1–2 weeks ahead of target launch date to buffer review time.

## 10. Timeline Summary

| Phase | Duration | Weeks |
|---|---|---|
| 1. Planning | 2 weeks | 1–2 |
| 2. UI | 4 weeks | 3–6 |
| 3. Backend | 5 weeks | 5–9 |
| 4. Upload | 3 weeks | 9–11 |
| 5. Streaming | 3 weeks | 11–13 |
| 6. Public Music | 3 weeks | 13–16 |
| 7. Admin | 2–3 weeks | 16–18 |
| 8. Testing | 2 weeks + continuous | 18–20 |
| 9. Deployment | 1–2 weeks | 20–21 |

**Total MVP timeline: ~21 weeks (~5 months)** with two workstreams (Flutter + Backend) running in parallel from Phase 2/3 onward.
