import SwiftUI

struct QueueView: View {
    @EnvironmentObject var engine: PlayerEngine

    var body: some View {
        NavigationStack {
            List {
                if let current = engine.currentTrack {
                    Section("Now Playing") {
                        HStack(spacing: 12) {
                            ArtworkView(album: Catalog.album(for: current), size: 44)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(current.title)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AppTheme.accent)
                                    .lineLimit(1)
                                Text(current.artist)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: engine.isPlaying ? "waveform" : "waveform.slash")
                                .foregroundStyle(AppTheme.accent)
                        }
                    }
                }
                Section("Up Next") {
                    ForEach(Array(engine.queue.enumerated()), id: \.element.id) { index, track in
                        if index != engine.currentIndex {
                            Button {
                                engine.jumpTo(index: index)
                                engine.showQueue = false
                            } label: {
                                TrackRow(track: track)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Up Next")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        engine.showQueue = false
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
