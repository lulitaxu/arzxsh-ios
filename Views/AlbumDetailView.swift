import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @EnvironmentObject var engine: PlayerEngine

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    ArtworkView(album: album, size: 232)
                        .shadow(color: Color.black.opacity(0.5), radius: 24, x: 0, y: 12)
                    VStack(spacing: 4) {
                        Text(album.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(album.artist)
                            .font(.headline)
                            .foregroundStyle(AppTheme.accent)
                        Text("\(album.genre) · \(album.year)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 12) {
                        Button {
                            engine.playAlbum(album, startAt: 0)
                        } label: {
                            Label("Play", systemImage: "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accent)

                        Button {
                            let tracks = album.tracks.shuffled()
                            engine.playQueue(tracks, startAt: 0)
                        } label: {
                            Label("Shuffle", systemImage: "shuffle")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.accent)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 18)

                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(Array(album.tracks.enumerated()), id: \.element.id) { index, track in
                        Button {
                            engine.playAlbum(album, startAt: index)
                        } label: {
                            HStack(spacing: 12) {
                                if engine.currentTrack?.id == track.id {
                                    Image(systemName: engine.isPlaying ? "waveform" : "waveform.slash")
                                        .foregroundStyle(AppTheme.accent)
                                        .frame(width: 22)
                                } else {
                                    Text("\(index + 1)")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 22)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(track.title)
                                        .font(.body.weight(engine.currentTrack?.id == track.id ? .semibold : .regular))
                                        .foregroundStyle(engine.currentTrack?.id == track.id ? AppTheme.accent : Color.primary)
                                        .lineLimit(1)
                                    Text(track.artist)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Text(formatTime(track.duration))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("track_\(track.id)")
                        if index < album.tracks.count - 1 {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
                .padding(.bottom, 110)
            }
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [album.colors[0].opacity(0.55), album.colors[1].opacity(0.18), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}
