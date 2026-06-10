# ShowComm — Claude Context

## What this project is

ShowComm is a Flutter (Dart) mobile app for iOS and Android used in live
production environments (theatre, live events). It listens for SMPTE timecode
from an ETC Response SMPTE Gateway over local WiFi (UDP port 5004), displays a
cue list with live countdowns, and supports multi-device collaboration with a
permission hierarchy.

**Key design principle:** fully peer-to-peer on LAN — no cloud, no accounts.

## Current state (as of first session)

The full UI scaffold is complete and compiles. No real networking or timecode
parsing is wired in yet — those are stubbed and will be added when hardware is
available on Mac.

### What's built

- `lib/theme/app_theme.dart` — Material 3 dark theme, black/purple palette
- `lib/models/` — `Cue`, `UserModel` (with `Permission` enum), `SessionModel`
- `lib/core/timecode/timecode.dart` — frame ↔ string conversion utilities (stub, no UDP yet)
- `lib/state/providers.dart` — Riverpod providers: `appStateProvider`, `timecodeProvider`, `currentSessionProvider`, `discoveredSessionsProvider` (mock data)
- `lib/ui/screens/` — all six screens (see below)
- `lib/ui/widgets/` — five reusable widgets
- `ios/Runner/Info.plist` — `NSLocalNetworkUsageDescription` + `NSBonjourServices` for `_showcomm._tcp`

### Screens

| File | Screen | Notes |
|---|---|---|
| `onboarding_screen.dart` | First launch | Name + role, role quick-picks, saves to SharedPreferences |
| `session_list_screen.dart` | Session browser | Mock mDNS sessions, "Host New Session" dialog |
| `cue_list_screen.dart` | Main working screen | Timecode display, next-cue preview, cue list, FAB |
| `cue_editor_screen.dart` | Add/edit cue | Bottom sheet, 4-field HH:MM:SS:FF with auto-advance |
| `user_management_screen.dart` | User list + permissions | Master-only permission sheet |
| `settings_screen.dart` | App settings | Profile editing, network/timecode info |

### Widgets

| File | Widget | Notes |
|---|---|---|
| `timecode_display.dart` | `TimecodeDisplay` | Space Mono, animated purple glow when running |
| `cue_tile.dart` | `CueTile` | Highlights next cue, strikethrough past cues |
| `countdown_chip.dart` | `CountdownChip` | Red <30s, amber <5min, grey otherwise, green tick when past |
| `role_badge.dart` | `RoleBadge` | MASTER / EDITOR / PROPOSE / VIEWER badges |
| `session_card.dart` | `SessionCard` | Session discovery card with Join button |

## Packages

```yaml
flutter_riverpod: ^2.5.1   # state management
shared_preferences: ^2.3.2  # user profile persistence
google_fonts: ^6.2.1        # Space Mono for timecode displays
uuid: ^4.4.0                # UUID generation (ready for device IDs)
```

## Colours

| Name | Hex | Usage |
|---|---|---|
| `background` | `#09090F` | Scaffold background |
| `surface` | `#0F0F1A` | App bar, banners |
| `surfaceElevated` | `#161624` | Cards, tiles |
| `surfaceHighlight` | `#1E1E38` | Selected/next cue |
| `primary` | `#7C3AED` | Buttons, borders, glows |
| `primaryLight` | `#A78BFA` | Text accents, countdown |
| `primaryDark` | `#5B21B6` | Gradients |

## What to build next (suggested order from project brief)

### 1. Timecode engine (do on Mac with hardware)
- `lib/core/timecode/udp_listener.dart` — `dart:io` RawDatagramSocket on port 5004
- `lib/core/timecode/mtc_parser.dart` — reassemble 8 quarter-frame MTC messages into HH:MM:SS:FF
- Wire into `TimecodeNotifier` in `providers.dart` via `update(frames, isRunning: true)`
- Android: add `INTERNET` + `CHANGE_WIFI_MULTICAST_STATE` permissions, acquire `MulticastLock`

### 2. Session hosting & mDNS
- Replace mock `discoveredSessionsProvider` with real mDNS using `nsd` package
- `lib/core/session/mdns_service.dart` — advertise `_showcomm._tcp` when hosting
- `lib/core/session/http_server.dart` — serve cue JSON via `shelf` + `shelf_io`

### 3. WebSocket sync
- `lib/core/session/websocket_server.dart` — shelf WebSocket server (host)
- `lib/core/session/websocket_client.dart` — `dart:io` WebSocket client (joiners)
- Message types: `cue_update`, `join_request`, `join_approved`, `propose_change`, `approve_change`, `reject_change`

### 4. User hierarchy & approval flow
- Proposal diff UI (review added/changed/removed cues before approving)
- Join request banner in `UserManagementScreen`
- Master handoff flow

## Cue file format (JSON served over HTTP)

```json
{
  "session": "Show A - Tuesday Night",
  "created": "2026-06-10T19:00:00",
  "framerate": 25,
  "version": 1,
  "master_device_id": "uuid-of-master-device",
  "users": [
    { "name": "Sarah", "role": "Stage Manager", "permission": "direct_edit" },
    { "name": "James", "role": "Lighting Op", "permission": "propose" },
    { "name": "Tom", "role": "Director", "permission": "view" }
  ],
  "cues": [
    { "id": 1, "label": "Fly Cue 1", "timecode": "00:12:34:00" }
  ]
}
```

Permission values: `direct_edit` | `propose` | `view`

## Getting started on Mac

```bash
# 1. Generate native iOS/Android layer (one-time, won't overwrite Dart files)
flutter create . --org com.showcomm --project-name showcomm

# 2. Install packages
flutter pub get

# 3. Run on iOS Simulator
open -a Simulator
flutter run

# 4. Or quick web preview (no Xcode needed)
flutter run -d chrome
```
