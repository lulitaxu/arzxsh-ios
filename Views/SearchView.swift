import SwiftUI

struct SearchView: View {
    @EnvironmentObject var engine: PlayerEngine
    @State private var query = ""

    private let categories: [(String, [Color])] = [
        ("Indie", [Color(red: 0.10, green: 0.13, blue: 0.42), Color(red: 0.38, green: 0.20, blue: 0.68)]),
        ("Electronic", [Color(red: 0.02, green: 0.32, blue: 0.38), Color(red: 0.04, green: 0.62, blue: 0.44)]),
        ("Folk Pop", [Color(red: 0.82, green: 0.40, blue: 0.08), Color(red: 0.95, green: 0.68, blue: 0.18)]),
        ("Dream Pop", [Color(red: 0.82, green: 0.28, blue: 0.44), Color(red: 0.52, green: 0.24, blue: 0.70)]),
        ("Dhaka Nights", [Color(red: 0.16, green: 0.10, blue: 0.34), Color(red: 0.55, green: 0.18, blue: 0.30)]),
        ("Rainy Day", [Color(red: 0.10, green: 0.22, blue: 0.34), Color(red: 0.20, green: 0.45, blue: 0.55)])
    ]

    private var filteredTracks: [Track] {
        guard !query.isEmpty else { return [] }
        return Catalog.tracks.filter {
            $0.title.localizedCaseInsensitiveContains(query) || $0.artist.localizedCaseInsensitiveContains(query)
        }
    }

    private var filteredAlbums: [Album] {
        guard !query.isEmpty else { return [] }
        return Catalog.albums.filter {
            $0.title.localizedCaseInsensitiveContains(query) || $0.artist.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if query.isEmpty {
                    browse
                } else {
                    results
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $query, prompt: "Artists, Songs, Albums")
            .navigationDestination(for: Album.self) { album in
                AlbumDetailView(album: album)
            }
        }
    }

    private var browse: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Browse Categories")
                    .font(.title3.bold())
                    .padding(.horizontal, 16)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(categories, id: \.0) { category in
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(colors: category.1, startPoint: .topLeading, endPoint: .bottomTrailing)
                            Circle()
                                .fill(Color.white.opacity(0.13))
                                .frame(width: 90, height: 90)
                                .offset(x: 55, y: -28)
                            Text(category.0)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(12)
                        }
                        .frame(height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
            .padding(.bottom, 110)
        }
    }

    private var results: some View {
        List {
            if !filteredAlbums.isEmpty {
                Section("Albums") {
                    ForEach(filteredAlbums) { album in
                        NavigationLink(value: album) {
                            HStack(spacing: 12) {
                                ArtworkView(album: album, size: 48)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(album.title)
                                        .font(.body.weight(.medium))
                                        .lineLimit(1)
                                    Text(album.artist)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            if !filteredTracks.isEmpty {
                Section("Songs") {
                    ForEach(filteredTracks) { track in
                        Button {
                            engine.playAlbum(Catalog.album(for: track), startAt: Catalog.album(for: track).tracks.firstIndex(of: track) ?? 0)
                        } label: {
                            TrackRow(track: track)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            if filteredAlbums.isEmpty && filteredTracks.isEmpty {
                Text("No results for \u{201C}\(query)\u{201D}. Try another title or artist.")
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
    }
}
