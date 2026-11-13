import SwiftUI

func formatTime(_ seconds: Double) -> String {
    guard seconds.isFinite, seconds >= 0 else { return "0:00" }
    let total = Int(seconds.rounded())
    return String(format: "%d:%02d", total / 60, total % 60)
}

struct ArtworkView: View {
    let spec: CoverSpec
    var width: CGFloat
    var height: CGFloat
    var animated: Bool = false
    var showsTitle: Bool = true

    init(album: Album, size: CGFloat, animated: Bool = false, showsTitle: Bool = true) {
        self.spec = album.coverSpec
        self.width = size
        self.height = size
        self.animated = animated
        self.showsTitle = showsTitle
    }

    init(spec: CoverSpec, size: CGFloat, animated: Bool = false, showsTitle: Bool = true) {
        self.spec = spec
        self.width = size
        self.height = size
        self.animated = animated
        self.showsTitle = showsTitle
    }

    init(spec: CoverSpec, width: CGFloat, height: CGFloat, animated: Bool = false, showsTitle: Bool = true) {
        self.spec = spec
        self.width = width
        self.height = height
        self.animated = animated
        self.showsTitle = showsTitle
    }

    private var cornerRadius: CGFloat { max(4, min(width, height) * 0.07) }

    var body: some View {
        CoverArt(spec: spec, size: CGSize(width: width, height: height), animated: animated, showsTitle: showsTitle)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct AlbumCard: View {
    let album: Album
    var width: CGFloat = 160

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArtworkView(album: album, size: width)
                .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(album.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(width: width, alignment: .leading)
        }
    }
}

struct TrackRow: View {
    let track: Track
    @EnvironmentObject var engine: PlayerEngine

    private var isCurrent: Bool { engine.currentTrack?.id == track.id }

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(album: Catalog.album(for: track), size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.body.weight(isCurrent ? .semibold : .regular))
                    .foregroundStyle(isCurrent ? AppTheme.accent : Color.primary)
                    .lineLimit(1)
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if isCurrent {
                Image(systemName: engine.isPlaying ? "waveform" : "waveform.slash")
                    .foregroundStyle(AppTheme.accent)
                    .symbolEffect(.variableColor.iterative, isActive: engine.isPlaying)
            } else {
                Text(formatTime(track.duration))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
