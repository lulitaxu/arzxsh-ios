# arzxsh for iOS

A native SwiftUI music player for iOS 18, built to an Apple Music design standard: large collapsing titles, artwork-tinted screens, a blurred-artwork Now Playing view with a swelling scrubber, synced lyrics that follow the song, and a persistent mini player above the tab bar.

This is milestone 1: the full app shell and a working local player. It ships with a small bundled sample catalog (4 albums, 12 short tracks) so playback, seeking, the queue, and lyric sync all run for real. No source branding appears anywhere in the UI; the library reads as the app's own.

## Design language

- Dark, artwork-led. Every album has a two-color gradient identity drawn in code with typographic artwork (SF symbol plus title and artist set on the gradient). No image files, no downloads.
- Accent: Apple Music-style red. Type: system SF throughout.
- Motion: spring on the mini player appearing, artwork that settles smaller when paused, a scrubber whose thumb swells while dragging, lyrics that ease the active line to center.

## Layout

- `App/` — app entry, root tab container, mini player overlay, deep-link launch handling.
- `Models/` — `Track`, `Album`, lyric line models, and the bundled `Catalog` with timestamped synced lyrics for every track.
- `Player/` — `PlayerEngine`, an `AVPlayer`-backed observable engine: queue, play/pause/next/previous, seek, volume, likes, and 0.3s position publishing.
- `Views/` — Home, Library, Search, Album detail, Now Playing, Lyrics, Queue, Mini Player, shared artwork and rows.
- `Resources/Audio/` — the bundled sample tracks (short generated loops, AAC).
- `UITests/` — XCUITest screenshot tests that walk the app and capture every main screen.

## How CI proves it

There is no Mac in the dev setup, so GitHub Actions (macos-15) is the compiler:

1. `brew install xcodegen && xcodegen generate` builds the Xcode project from `project.yml`.
2. `xcodebuild test` builds for an iPhone 16 simulator and runs the UI tests.
3. Screenshots are extracted from the `.xcresult` with `xcresulttool export attachments` and uploaded as the `screenshots` artifact (with a `simctl` deep-link fallback if attachment export yields nothing). The xcresult and build log are uploaded too.

## Milestone 2

A YouTube Music resolution engine for iOS that replaces the bundled sample catalog with real search and streaming, keeping this UI and playback layer unchanged.
