import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var engine: PlayerEngine

    var body: some View {
        HStack(spacing: 10) {
            if let track = engine.currentTrack {
                Button {
                    engine.showNowPlaying = true
                } label: {
                    HStack(spacing: 10) {
                        ArtworkView(album: Catalog.album(for: track), size: 42)
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(track.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Text(track.artist)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    engine.togglePlayPause()
                } label: {
                    Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                }
                .accessibilityIdentifier("miniPlayPauseButton")

                Button {
                    engine.playNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(engine.hasNext ? Color.primary : Color.secondary)
                        .frame(width: 40, height: 40)
                }
                .accessibilityIdentifier("miniNextButton")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 4)
        .accessibilityIdentifier("miniPlayer")
    }
}
