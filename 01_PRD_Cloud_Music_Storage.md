# Product Requirement Document (PRD)
## Cloud Music Storage — Cross-Platform Music Storage & Streaming Platform

---

## Table of Contents
1. Vision
2. Problem Statement
3. Goals & Objectives
4. Success Metrics
5. Personas
6. User Stories
7. Functional Requirements
8. Non-Functional Requirements
9. Business Rules
10. Feature List (MVP vs Future Scope)
11. Acceptance Criteria
12. Risk Analysis
13. Competitor Analysis

---

## 1. Vision

Cloud Music Storage is a cross-platform application that lets any user upload, organize, and stream their personal music collection from any device — the same way Google Drive stores files and Spotify streams catalog music, but centered on **the user's own library**. Users get unlimited-feeling personal cloud storage purpose-built for audio, with metadata intelligence, offline playback, and an optional public-publishing layer for artists who own or are licensed to distribute their work.

The long-term vision is to become the default "bring your own music" cloud player for people who own personal collections (ripped CDs, purchased tracks, independent releases, demos, DJ sets) that mainstream streaming services don't host, while offering a legitimate, opt-in publishing path for original creators.

## 2. Problem Statement

- Users who own personal or independently produced music (not on Spotify/Apple Music catalogs) have no clean cross-device way to store, organize, and stream it.
- Local storage fragments across phones, laptops, and desktops with no sync.
- Existing generic cloud storage (Drive, Dropbox) offers file storage but no music-grade experience — no metadata extraction, no proper player, no playlists, no streaming optimization, no offline caching tuned for audio.
- Independent artists lack a low-friction way to share original tracks publicly without going through label/distributor gatekeeping, while still needing abuse/DMCA protections.
- Copyright liability is a real platform risk if uploads aren't gated and attributed correctly.

## 3. Goals & Objectives

**Goals**
- Deliver a reliable, fast, cross-platform (mobile, desktop, web) personal music cloud with streaming-grade playback.
- Provide clear separation between **Private** (owner-only) and **Public** (opt-in, ownership-attested) content.
- Build a moderation and DMCA pipeline from day one, not as an afterthought.
- Support offline-first playback and multi-device sync of library state (playlists, likes, playback position).

**Objectives (first 12 months)**
- Ship MVP across Android, iOS, and Web within Phase 1–5 (see Implementation Plan).
- Support gapless streaming with adaptive bitrate from Cloudflare R2 + CDN.
- Achieve sub-300ms perceived time-to-first-audio-byte on broadband.
- Reach a content moderation SLA of <24h for abuse/DMCA reports.

## 4. Success Metrics

| Metric | Target (Year 1) |
|---|---|
| Monthly Active Users (MAU) | 100,000 |
| Avg. library size per user | 250+ tracks |
| Streaming start success rate | >99.5% |
| Playback stall rate | <0.5% of sessions |
| Upload success rate | >99% |
| DMCA/abuse resolution time | <24 hours (P1), <72h (P2) |
| Crash-free session rate (mobile) | >99.5% |
| D30 retention | >25% |
| Public track publish opt-in rate | 10–15% of active uploaders |

## 5. Personas

**1. Priya — The Archivist (Primary)**
Ripped her CD collection years ago; has 3,000+ MP3/FLAC files scattered across an old laptop and a phone. Wants one place to store everything, organized automatically, playable anywhere, including offline on commutes.

**2. Rahul — The Independent Artist**
Produces original beats and tracks. Wants to store working files privately, but also publish finished tracks publicly to build a following, with basic artist profile, likes, and comments — without dealing with a full distributor.

**3. Meera — The DJ / Curator**
Maintains large sets and mixes for gigs. Needs folder structure, fast search/filter/sort, playlists, and reliable offline download for venues with poor connectivity.

**4. Admin/Trust & Safety Operator**
Anthropic — err, platform operator — reviews reports, DMCA takedowns, and storage abuse from a dashboard; needs audit logs and bulk moderation tools.

## 6. User Stories

- As a user, I want to drag-and-drop upload songs so I can quickly move my library to the cloud.
- As a user, I want metadata (artist, album, cover art) auto-extracted so I don't have to tag everything manually.
- As a user, I want to organize tracks into folders and playlists so my library stays navigable at scale.
- As a user, I want to stream my music on any device without re-downloading, and download tracks for offline listening when I choose.
- As a user, I want to mark a track Public and confirm ownership so I can share original work with listeners.
- As a listener, I want to follow artists, like public tracks, and browse public playlists.
- As a user, I want to report abusive or infringing public content.
- As a rights holder, I want a DMCA reporting flow that results in timely takedown.
- As an admin, I want a dashboard showing storage usage, reports, and system health so I can operate the platform.
- As a user, I want two-factor authentication and Google/Apple login for secure, low-friction access.

## 7. Functional Requirements

- FR1: Auth — email/password, Google OAuth, Apple Sign-In, email verification, forgot-password reset, optional TOTP-based 2FA.
- FR2: Upload — single & batch upload, drag-and-drop (web/desktop), background upload (mobile), resumable/chunked upload for large files.
- FR3: Metadata — auto-extract ID3/Vorbis/MP4 tags and embedded artwork; allow manual edit and re-fetch.
- FR4: Organization — folders, playlists, favorites/liked songs, tags.
- FR5: Search/Filter/Sort — by title, artist, album, genre, duration, date added, folder.
- FR6: Streaming playback — background playback, mini player, full-screen player, queue, shuffle, repeat, playback speed, sleep timer, equalizer, optional synced lyrics.
- FR7: Offline — explicit download-for-offline with local encrypted cache and storage quota display.
- FR8: Sync — cross-device sync of library metadata, playback position, likes, playlists via REST + Redis-backed session state (Socket.IO optional for live sync).
- FR9: Trash/Restore — soft-delete with 30-day retention before hard delete.
- FR10: Public publishing — explicit opt-in per track, ownership attestation checkbox + terms acceptance, artist profile, followers, likes, comments, public playlists, shareable links.
- FR11: Moderation — report abuse, DMCA takedown request form, admin review queue, content takedown/reinstate workflow.
- FR12: Admin panel — user management, storage analytics, system logs, statistics dashboard, content moderation tools.

## 8. Non-Functional Requirements

- **Performance**: stream start <300ms P50 on broadband; API P95 <200ms for metadata endpoints.
- **Scalability**: stateless API layer horizontally scalable; storage on Cloudflare R2 with CDN edge caching; Redis for session/cache/rate-limit state.
- **Availability**: 99.9% uptime target for API and streaming edge.
- **Security**: JWT + refresh token rotation, encrypted storage credentials, signed time-limited URLs for all audio access, OWASP Top 10 mitigations.
- **Portability**: single Flutter codebase across Android, iOS, Windows, macOS, Linux, Web.
- **Compliance**: DMCA safe-harbor style takedown process; GDPR-style data export/delete for user accounts.
- **Observability**: structured logging, centralized error tracking, uptime/latency monitoring, audit trail for admin actions.

## 9. Business Rules

- Only the uploader is responsible for the legality of uploaded content; platform is a hosting intermediary.
- Public uploads require an explicit ownership/licensing attestation at time of publish; this attestation is stored and timestamped.
- Private content is never scanned for public discovery, only for abuse/DMCA response when specifically reported (with logged justification).
- A track flagged via valid DMCA notice is taken down within a defined SLA regardless of private/public status if it is public; private storage is not proactively policed absent a valid legal request tied to that specific user/content.
- Storage quotas are enforced per plan tier (free/paid); uploads beyond quota are blocked with a clear upgrade prompt.
- Deleted items remain recoverable in Trash for 30 days, then are purged permanently from R2.

## 10. Feature List — MVP vs Future Scope

**MVP**
Auth (email + Google + Apple, verification, forgot password), upload (single + batch), metadata extraction, folders, playlists, favorites, search/filter/sort, streaming playback (mini + full player, queue, shuffle, repeat), offline download, trash/restore, private/public toggle with ownership attestation, basic artist profile, report abuse, basic admin dashboard (users, reports, storage).

**Future Scope**
Two-factor authentication, equalizer, sleep timer, playback speed, synced lyrics, public playlists & comments, followers, DMCA formal workflow automation, advanced admin analytics, Socket.IO live cross-device sync, collaborative playlists, desktop-native builds (Windows/macOS/Linux polish pass), recommendation/discovery engine.

## 11. Acceptance Criteria (samples)

- **Upload**: Given a valid audio file ≤500MB, when a user uploads it, then it appears in their library within 30s with correct extracted metadata and a playable state.
- **Public Publish**: Given a private track, when a user toggles Public and confirms the ownership checkbox, then the track becomes visible on their public artist profile and searchable by other users within 5 minutes.
- **Streaming**: Given a track in a user's library, when they press play on any authenticated device, then audio begins streaming via a signed URL and playback position syncs across devices on next open.
- **DMCA**: Given a valid DMCA report submitted against a public track, when an admin approves the takedown, then the track is unpublished within 1 hour and the uploader is notified.

## 12. Risk Analysis

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Copyright infringement liability from public uploads | High | Medium | Ownership attestation, DMCA pipeline, rapid takedown SLA, ToS indemnification |
| Storage cost overrun at scale | Medium | Medium | Tiered quotas, R2 lifecycle policies, cold storage for rarely-played tracks |
| Streaming latency/CDN cost | Medium | Medium | Cloudflare CDN edge caching, adaptive bitrate, signed URL TTL tuning |
| Cross-platform Flutter audio inconsistency (background playback on iOS/Android) | Medium | High | Use proven audio_service/just_audio stack, platform-specific QA pass each release |
| Account takeover / credential stuffing | High | Low-Medium | 2FA, rate limiting, breached-password checks, refresh token rotation |
| Moderation backlog abuse | Medium | Medium | Admin tooling, report triage priority, automated hash-matching for repeat-offender uploads |

## 13. Competitor Analysis

| Product | Strength | Gap Cloud Music Storage Fills |
|---|---|---|
| Spotify / Apple Music | Massive licensed catalog, polished player | No personal/independent library hosting |
| Google Drive / Dropbox | Reliable generic cloud storage | No music-native UX: no metadata, player, streaming optimization |
| Apple Music Cloud Library (iTunes Match) | Matches personal library to catalog | Apple-only, weak for non-catalog independent music, no public artist layer |
| SoundCloud | Public artist publishing, community | Weak private personal-library/storage use case, storage limits, less cross-device "my whole collection" framing |

Cloud Music Storage's differentiator: **personal-first cloud storage with music-grade UX, plus an opt-in, ownership-gated public layer** — combining the private utility of Drive/Dropbox with the playback experience of Spotify.
