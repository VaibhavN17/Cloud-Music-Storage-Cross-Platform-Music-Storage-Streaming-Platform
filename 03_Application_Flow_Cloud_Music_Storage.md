# Application Flow Document
## Cloud Music Storage

---

## Table of Contents
1. Authentication Flow
2. Upload Flow
3. Streaming Flow
4. Playback Flow
5. Playlist Flow
6. Search Flow
7. Profile Flow
8. Settings Flow
9. Admin Flow
10. Error Flow
11. Offline Flow
12. Synchronization Flow

---

## 1. Authentication Flow

```
[Splash] → [Check stored token]
   ├─ Valid token → [Home]
   └─ No/expired token → [Login]
        ├─ Email/Password → validate → 2FA? → [Home]
        ├─ Google Sign-In → OAuth → map/create user → [Home]
        ├─ Apple Sign-In → OAuth → map/create user → [Home]
        └─ New user → [Signup] → [Email Verification] → [Home]
   [Forgot Password] → [Enter email] → [OTP/reset link] → [Reset Password] → [Login]
```
- Access token stored in secure storage; refresh token rotated on each use.
- Failed login after N attempts triggers temporary rate-limit lockout.

## 2. Upload Flow

```
[Library] → [Upload] → select file(s) / drag-drop
   → client validates type/size
   → request presigned upload URL(s) from API
   → direct PUT to Cloudflare R2
   → API notified upload complete
   → Worker: extract metadata (ID3/Vorbis/MP4) + artwork
   → Track record created (status: private, ready)
   → [Library] updated in real time
```
- Batch uploads processed in parallel with individual progress indicators.
- Failed uploads retry with exponential backoff; permanently failed items surfaced with a retry button.

## 3. Streaming Flow

```
[User presses Play] → API: request signed streaming URL for trackId
   → API validates ownership/access (private) or public status
   → API returns short-lived signed R2/CDN URL
   → Client audio engine opens URL with HTTP range support
   → Playback begins; heartbeat POSTs position every ~15s
```
- On signed URL expiry mid-session, client silently re-requests a fresh URL without interrupting playback.

## 4. Playback Flow

```
[Mini Player] ⇄ [Full Screen Player]
   → Queue management (add/remove/reorder)
   → Controls: play/pause, next/prev, seek, shuffle, repeat (off/one/all)
   → Playback speed, equalizer, sleep timer accessible from full player
   → Background playback continues via platform audio service (lock screen controls)
```

## 5. Playlist Flow

```
[Library] → [Create Playlist] → name/cover
   → [Add tracks] from library/search/public catalog
   → Reorder via drag handle
   → [Playlist Detail] → play all / shuffle / edit / delete
   → Optional: [Make Public] → shareable link generated
```

## 6. Search Flow

```
[Search bar] → debounce input (300ms)
   → API: full-text query across title/artist/album (+ public catalog if toggled)
   → Results grouped: Tracks / Albums / Artists / Playlists
   → [Filter] genre, duration, date added
   → [Sort] relevance, title, date, duration
```

## 7. Profile Flow

```
[Profile] → view avatar, display name, bio, stats (tracks, playlists, followers)
   → [Edit Profile] → update fields → save
   → [Artist Mode] (auto-enabled on first public publish) → public track list, followers, comments moderation
```

## 8. Settings Flow

```
[Settings] → Account (email, password, 2FA) 
           → Storage (quota usage, upgrade)
           → Playback (default quality, download settings)
           → Notifications
           → Privacy (data export/delete)
           → About/Legal (ToS, DMCA policy)
```

## 9. Admin Flow

```
[Admin Login] → [Dashboard: stats overview]
   → [User Management] search/suspend/reinstate users
   → [Reports Queue] abuse + DMCA reports → review evidence → approve/reject → action logged
   → [Storage Analytics] usage by user/bucket, cost trends
   → [System Logs] filterable audit + error log viewer
```

## 10. Error Flow

```
[Any API call] → on failure:
   → Network error → show retry banner, queue action if safe (e.g., like/favorite)
   → 401 → attempt refresh-token flow → success: retry original call | failure: force logout → [Login]
   → 403 → show permission-denied state, no retry
   → 404 → show "not found" empty state
   → 5xx → show generic error state with retry + report option
```

## 11. Offline Flow

```
[Track/Playlist] → [Download for offline]
   → check storage quota → download audio to encrypted local cache
   → track marked "Available Offline" with local badge
   → Playback: if online, stream; if offline, prefer local cached copy automatically
   → [Downloads] screen manages/removes offline content
```

## 12. Synchronization Flow

```
[App foreground / reconnect] → sync pass:
   → pull: playlists, likes, folder changes, playback position since lastSyncTimestamp
   → push: any offline-queued actions (likes, playlist edits made while offline)
   → conflict resolution: last-write-wins on metadata; server-authoritative for storage/quota state
   → (optional) Socket.IO pushes live "now playing"/library-change events to other active sessions
```
