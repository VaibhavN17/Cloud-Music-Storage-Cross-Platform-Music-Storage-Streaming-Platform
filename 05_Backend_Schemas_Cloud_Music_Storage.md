# Backend Schemas Document
## Cloud Music Storage — Database & API Design

---

## Table of Contents
1. Entity Overview
2. Prisma Schema
3. Indexing Strategy
4. REST API Surface
5. Request/Response Examples
6. Error Codes
7. JWT & Refresh Token Flow
8. RBAC & Permissions
9. Rate Limiting

---

## 1. Entity Overview

Core entities: `User`, `Track`, `Folder`, `Playlist`, `PlaylistTrack`, `Favorite`, `Follow`, `Comment`, `Report`, `RefreshToken`, `AuditLog`.

Relationships:
- User 1—N Track, Folder, Playlist, Favorite, Report, RefreshToken
- Playlist N—N Track (via PlaylistTrack join)
- User N—N User (via Follow: follower/following)
- Track 1—N Comment (on public tracks only)

## 2. Prisma Schema

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum Role {
  USER
  MODERATOR
  ADMIN
}

enum Visibility {
  PRIVATE
  PUBLIC
}

enum ReportType {
  ABUSE
  DMCA
}

enum ReportStatus {
  OPEN
  UNDER_REVIEW
  RESOLVED
  REJECTED
}

model User {
  id                String    @id @default(cuid())
  email             String    @unique
  passwordHash      String?
  displayName       String
  avatarUrl         String?
  bio               String?
  role              Role      @default(USER)
  emailVerified     Boolean   @default(false)
  twoFactorEnabled  Boolean   @default(false)
  twoFactorSecret   String?
  storageUsedBytes  BigInt    @default(0)
  storageQuotaBytes BigInt    @default(5368709120) // 5GB default
  suspended         Boolean   @default(false)
  createdAt         DateTime  @default(now())
  updatedAt         DateTime  @updatedAt
  deletedAt         DateTime?

  tracks            Track[]
  folders           Folder[]
  playlists         Playlist[]
  favorites         Favorite[]
  comments          Comment[]
  reportsFiled      Report[]        @relation("ReportsFiled")
  reportsReceived   Report[]        @relation("ReportsReceived")
  refreshTokens     RefreshToken[]
  followers         Follow[]        @relation("Following")
  following         Follow[]        @relation("Follower")

  @@index([email])
}

model Track {
  id             String     @id @default(cuid())
  ownerId        String
  owner          User       @relation(fields: [ownerId], references: [id])
  folderId       String?
  folder         Folder?    @relation(fields: [folderId], references: [id])

  title          String
  artist         String?
  album          String?
  genre          String?
  durationMs     Int?
  fileKey        String     // R2 object key
  artworkKey     String?
  fileSizeBytes  BigInt
  format         String     // mp3, flac, m4a, wav
  visibility     Visibility @default(PRIVATE)
  ownershipAttestedAt DateTime?

  playCount      Int        @default(0)
  likeCount      Int        @default(0)

  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  deletedAt      DateTime?  // soft delete / trash

  playlistTracks PlaylistTrack[]
  favorites      Favorite[]
  comments       Comment[]
  reports        Report[]

  @@index([ownerId])
  @@index([visibility])
  @@index([title])
  @@index([artist])
  @@index([deletedAt])
}

model Folder {
  id        String   @id @default(cuid())
  ownerId   String
  owner     User     @relation(fields: [ownerId], references: [id])
  parentId  String?
  parent    Folder?  @relation("FolderTree", fields: [parentId], references: [id])
  children  Folder[] @relation("FolderTree")
  name      String
  tracks    Track[]
  createdAt DateTime @default(now())

  @@index([ownerId])
}

model Playlist {
  id          String          @id @default(cuid())
  ownerId     String
  owner       User            @relation(fields: [ownerId], references: [id])
  name        String
  coverUrl    String?
  visibility  Visibility      @default(PRIVATE)
  createdAt   DateTime        @default(now())
  updatedAt   DateTime        @updatedAt

  tracks      PlaylistTrack[]

  @@index([ownerId])
}

model PlaylistTrack {
  id          String   @id @default(cuid())
  playlistId  String
  playlist    Playlist @relation(fields: [playlistId], references: [id])
  trackId     String
  track       Track    @relation(fields: [trackId], references: [id])
  position    Int
  addedAt     DateTime @default(now())

  @@unique([playlistId, trackId])
  @@index([playlistId])
}

model Favorite {
  id        String   @id @default(cuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  trackId   String
  track     Track    @relation(fields: [trackId], references: [id])
  createdAt DateTime @default(now())

  @@unique([userId, trackId])
}

model Follow {
  id           String   @id @default(cuid())
  followerId   String
  follower     User     @relation("Follower", fields: [followerId], references: [id])
  followingId  String
  following    User     @relation("Following", fields: [followingId], references: [id])
  createdAt    DateTime @default(now())

  @@unique([followerId, followingId])
}

model Comment {
  id        String   @id @default(cuid())
  trackId   String
  track     Track    @relation(fields: [trackId], references: [id])
  authorId  String
  author    User     @relation(fields: [authorId], references: [id])
  body      String
  createdAt DateTime @default(now())
  deletedAt DateTime?

  @@index([trackId])
}

model Report {
  id           String       @id @default(cuid())
  type         ReportType
  status       ReportStatus @default(OPEN)
  trackId      String?
  track        Track?       @relation(fields: [trackId], references: [id])
  reporterId   String
  reporter     User         @relation("ReportsFiled", fields: [reporterId], references: [id])
  reportedUserId String?
  reportedUser User?        @relation("ReportsReceived", fields: [reportedUserId], references: [id])
  reason       String
  evidenceUrl  String?
  resolvedById String?
  resolutionNote String?
  createdAt    DateTime     @default(now())
  resolvedAt   DateTime?

  @@index([status])
  @@index([type])
}

model RefreshToken {
  id         String   @id @default(cuid())
  userId     String
  user       User     @relation(fields: [userId], references: [id])
  tokenHash  String   @unique
  revoked    Boolean  @default(false)
  expiresAt  DateTime
  createdAt  DateTime @default(now())

  @@index([userId])
}

model AuditLog {
  id         String   @id @default(cuid())
  actorId    String
  action     String
  targetType String
  targetId   String
  metadata   Json?
  createdAt  DateTime @default(now())

  @@index([actorId])
  @@index([targetType, targetId])
}
```

## 3. Indexing Strategy

- B-tree indexes on all foreign keys (`ownerId`, `folderId`, `playlistId`, `trackId`) for join performance.
- Composite index on `Track(visibility, deletedAt)` to speed up public-catalog browse queries excluding trashed items.
- `tsvector` GIN index on `Track(title, artist, album)` for full-text search (added via raw SQL migration alongside Prisma schema).
- Unique constraints prevent duplicate favorites/follows/playlist entries at the DB level, not just app level.

## 4. REST API Surface (selected)

```
POST   /auth/signup
POST   /auth/login
POST   /auth/oauth/google
POST   /auth/oauth/apple
POST   /auth/refresh
POST   /auth/logout
POST   /auth/forgot-password
POST   /auth/reset-password
POST   /auth/verify-email
POST   /auth/2fa/enable
POST   /auth/2fa/verify

GET    /me
PATCH  /me
GET    /me/storage

POST   /tracks/upload-url          # get presigned R2 PUT URL
POST   /tracks                     # confirm upload, create Track record
GET    /tracks
GET    /tracks/:id
PATCH  /tracks/:id
DELETE /tracks/:id                 # soft delete (trash)
POST   /tracks/:id/restore
POST   /tracks/:id/publish         # toggle PUBLIC + ownership attestation
GET    /tracks/:id/stream-url      # signed streaming URL

GET    /folders
POST   /folders
PATCH  /folders/:id
DELETE /folders/:id

GET    /playlists
POST   /playlists
PATCH  /playlists/:id
DELETE /playlists/:id
POST   /playlists/:id/tracks
DELETE /playlists/:id/tracks/:trackId

POST   /favorites/:trackId
DELETE /favorites/:trackId

GET    /search?q=&type=&genre=&sort=

GET    /artists/:userId
POST   /artists/:userId/follow
DELETE /artists/:userId/follow
POST   /tracks/:id/comments
GET    /tracks/:id/comments

POST   /reports
GET    /admin/reports
PATCH  /admin/reports/:id
GET    /admin/users
PATCH  /admin/users/:id/suspend
GET    /admin/stats
GET    /admin/logs
```

## 5. Request/Response Examples

**Upload confirm**
```json
POST /tracks
{
  "fileKey": "u_123/trk_abc/original.mp3",
  "title": "Midnight Drive",
  "artist": "Rahul",
  "album": "Demos",
  "durationMs": 214000,
  "fileSizeBytes": 5242880,
  "format": "mp3",
  "artworkKey": "u_123/trk_abc/artwork.jpg"
}
```
Response `201`:
```json
{
  "id": "trk_abc",
  "title": "Midnight Drive",
  "visibility": "PRIVATE",
  "createdAt": "2026-08-01T10:00:00Z"
}
```

**Stream URL**
```json
GET /tracks/trk_abc/stream-url
```
Response `200`:
```json
{ "url": "https://cdn.cloudmusic.app/signed/...", "expiresAt": "2026-08-01T10:15:00Z" }
```

## 6. Error Codes

| Code | Meaning |
|---|---|
| `AUTH_INVALID_CREDENTIALS` | Login failed |
| `AUTH_TOKEN_EXPIRED` | Access token expired, refresh required |
| `AUTH_REFRESH_INVALID` | Refresh token invalid/revoked |
| `VALIDATION_ERROR` | Request payload failed schema validation |
| `QUOTA_EXCEEDED` | User storage quota exceeded |
| `NOT_FOUND` | Resource does not exist or not owned by user |
| `FORBIDDEN` | Authenticated but not authorized for this action |
| `RATE_LIMITED` | Too many requests |
| `UPLOAD_FAILED` | R2 upload confirmation mismatch |
| `INTERNAL_ERROR` | Unexpected server error |

## 7. JWT & Refresh Token Flow

1. Login/OAuth success → issue access token (15 min, JWT, signed HS256/RS256) + refresh token (opaque, hashed + stored in `RefreshToken` table, 30-day TTL).
2. Client stores both in secure storage; access token attached as `Authorization: Bearer` on every request.
3. On `401 AUTH_TOKEN_EXPIRED`, client calls `/auth/refresh` with the refresh token.
4. Server validates hash against `RefreshToken` table, checks not revoked/expired, issues new access + rotates refresh token (old one marked revoked).
5. Logout revokes the current refresh token; "logout all devices" revokes all tokens for the user.

## 8. RBAC & Permissions

| Role | Capabilities |
|---|---|
| USER | Full CRUD on own tracks/folders/playlists, publish/unpublish own tracks, follow/comment/favorite, file reports |
| MODERATOR | All USER capabilities + view/action reports queue, unpublish public tracks pending review |
| ADMIN | All MODERATOR capabilities + user management (suspend/reinstate), storage analytics, system logs, role assignment |

Enforcement: route-level middleware checks `role`; ownership checks (`resource.ownerId === req.user.id`) enforced per-service for all mutating operations regardless of role, except MODERATOR/ADMIN acting through explicit admin endpoints.

## 9. Rate Limiting

- Redis token-bucket per user (authenticated) and per IP (unauthenticated endpoints like login/signup).
- Defaults: 100 req/min general API, 10 req/min for auth endpoints (login/signup/forgot-password), 20 uploads/hour on free tier.
- `429 RATE_LIMITED` response includes `Retry-After` header.
