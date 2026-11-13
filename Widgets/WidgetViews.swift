import SwiftUI
import WidgetKit

struct ArzxshWidgetEntry: TimelineEntry {
    let date: Date
    let state: SharedState
}

struct WidgetDisplay {
    let album: Album
    let title: String
    let artist: String
    let hasTrack: Bool

    init(state: SharedState) {
        let fallback = Catalog.albums[0]
        let resolved = state.albumID.flatMap { id in Catalog.albums.first { $0.id == id } } ?? fallback
        album = resolved
        hasTrack = state.trackID != nil
        if let title = state.title, let artist = state.artist {
            self.title = title
            self.artist = artist
        } else if let first = resolved.tracks.first {
            title = first.title
            artist = first.artist
        } else {
            title = resolved.title
            artist = resolved.artist
        }
    }
}

struct LockRectangularWidgetView: View {
    let state: SharedState

    private var display: WidgetDisplay { WidgetDisplay(state: state) }

    var body: some View {
        let d = display
        return ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.88))
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(d.album.tint.opacity(0.30))
            HStack(spacing: 8) {
                CoverArt(spec: d.album.coverSpec, size: CGSize(width: 40, height: 40), showsTitle: false)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(d.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(d.artist)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.white.opacity(0.72))
                        .lineLimit(1)
                    Text(state.albumTitle ?? d.album.title)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if d.hasTrack {
                    Button(intent: TogglePlaybackIntent()) {
                        Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(AppTheme.accent))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
    }
}

struct LockCircularWidgetView: View {
    let state: SharedState

    private var display: WidgetDisplay { WidgetDisplay(state: state) }

    var body: some View {
        let d = display
        return ZStack {
            Circle()
                .fill(Color(white: 0.13))
            Circle()
                .stroke(Color.white.opacity(0.22), lineWidth: 4.5)
                .padding(2.5)
            Circle()
                .trim(from: 0, to: max(0.02, min(1, state.progress)))
                .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(2.5)
            CoverArt(spec: d.album.coverSpec, size: CGSize(width: 50, height: 50), showsTitle: false)
                .clipShape(Circle())
                .padding(8)
            if !d.hasTrack {
                Image(systemName: "music.note")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: Color.black.opacity(0.6), radius: 3)
            }
        }
    }
}

struct LockInlineWidgetView: View {
    let state: SharedState

    private var display: WidgetDisplay { WidgetDisplay(state: state) }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: state.isPlaying ? "waveform" : "music.note")
            Text(display.title)
                .lineLimit(1)
        }
    }
}

struct HomeSmallWidgetView: View {
    let state: SharedState

    private var display: WidgetDisplay { WidgetDisplay(state: state) }

    var body: some View {
        let d = display
        return GeometryReader { geo in
            ZStack {
                CoverArt(spec: d.album.coverSpec, size: geo.size, showsTitle: false)
                LinearGradient(
                colors: [Color.black.opacity(0), Color.black.opacity(0.28), Color.black.opacity(0.78)],
                startPoint: .top,
                endPoint: .bottom
            )
            VStack {
                HStack {
                    Spacer()
                    if d.hasTrack {
                        Button(intent: TogglePlaybackIntent()) {
                            Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(Color.black.opacity(0.45)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(d.hasTrack ? d.title : d.album.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(d.hasTrack ? d.artist : "Open arzxsh to play")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.78))
                        .lineLimit(1)
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(12)
            }
        }
    }
}

struct HomeMediumWidgetView: View {
    let state: SharedState

    private var display: WidgetDisplay { WidgetDisplay(state: state) }

    private var recents: [SharedRecentTrack] {
        if !state.recents.isEmpty {
            return Array(state.recents.prefix(3))
        }
        return Catalog.albums[0].tracks.map {
            SharedRecentTrack(title: $0.title, artist: $0.artist, albumID: $0.albumID)
        }
    }

    var body: some View {
        let d = display
        return ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.09)
            LinearGradient(
                colors: [d.album.tint.opacity(0.34), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 7) {
                    CoverArt(spec: d.album.coverSpec, size: CGSize(width: 92, height: 92), showsTitle: false)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Text(d.hasTrack ? d.title : d.album.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(d.hasTrack ? d.artist : "arzxsh")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .lineLimit(1)
                }
                .frame(width: 118, alignment: .leading)
                Rectangle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 1)
                    .padding(.vertical, 6)
                VStack(alignment: .leading, spacing: 9) {
                    Text("Recently Played")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.accent)
                        .textCase(.uppercase)
                    ForEach(Array(recents.enumerated()), id: \.offset) { _, recent in
                        HStack(spacing: 8) {
                            CoverArt(
                                spec: (Catalog.albums.first { $0.id == recent.albumID } ?? Catalog.albums[0]).coverSpec,
                                size: CGSize(width: 30, height: 30),
                                showsTitle: false
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(recent.title)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text(recent.artist)
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.white.opacity(0.65))
                                    .lineLimit(1)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
        }
    }
}
