import SwiftUI

func formatTime(_ seconds: Double) -> String {
    guard seconds.isFinite, seconds >= 0 else { return "0:00" }
    let total = Int(seconds.rounded())
    return String(format: "%d:%02d", total / 60, total % 60)
}

struct ArtworkView: View {
    let album: Album
    var size: CGFloat = 160

    private var cornerRadius: CGFloat { max(4, size * 0.07) }

    var body: some View {
        ZStack {
            LinearGradient(colors: album.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            Circle()
                .fill(Color.white.opacity(0.14))
                .frame(width: size * 0.95, height: size * 0.95)
                .offset(x: size * 0.42, y: -size * 0.38)
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: size * 0.6, height: size * 0.6)
                .offset(x: -size * 0.45, y: size * 0.45)
            VStack(spacing: size * 0.05) {
                Image(systemName: album.symbol)
                    .font(.system(size: size * 0.26, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.92))
                if size >= 110 {
                    Text(album.title)
                        .font(.system(size: size * 0.105, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, size * 0.1)
                    Text(album.artist)
                        .font(.system(size: size * 0.075, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .lineLimit(1)
                }
            }
        }
        .frame(width: size, height: size)
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
