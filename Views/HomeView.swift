import SwiftUI

struct HomeView: View {
    @EnvironmentObject var engine: PlayerEngine
    @Binding var path: NavigationPath

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning, arz"
        case 12..<17: return "Good afternoon, arz"
        case 17..<22: return "Good evening, arz"
        default: return "Up late, arz"
        }
    }

    private var quickPicks: [Track] {
        [Catalog.tracks[0], Catalog.tracks[3], Catalog.tracks[6], Catalog.tracks[9], Catalog.tracks[1], Catalog.tracks[10]]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Jump back in")
                            .font(.title2.bold())
                        Text("Your recent rotation, one tap away.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(quickPicks) { track in
                            Button {
                                engine.playAlbum(Catalog.album(for: track), startAt: Catalog.album(for: track).tracks.firstIndex(of: track) ?? 0)
                            } label: {
                                HStack(spacing: 10) {
                                    ArtworkView(album: Catalog.album(for: track), size: 48)
                                    Text(track.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 0)
                                }
                                .padding(6)
                                .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)

                    shelf(title: "Recently Played", albums: Catalog.albums)
                    shelf(title: "Made for arz", albums: Array(Catalog.albums.reversed()))
                }
                .padding(.top, 8)
                .padding(.bottom, 110)
            }
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Album.self) { album in
                AlbumDetailView(album: album)
            }
        }
    }

    private func shelf(title: String, albums: [Album]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(albums) { album in
                        Button {
                            path.append(album)
                        } label: {
                            AlbumCard(album: album)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("album_\(album.id)")
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
