import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var engine: PlayerEngine

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        LibraryListView(kind: "playlists")
                    } label: {
                        Label("Playlists", systemImage: "music.note.list")
                    }
                    NavigationLink {
                        LibraryListView(kind: "albums")
                    } label: {
                        Label("Albums", systemImage: "square.stack.fill")
                    }
                    NavigationLink {
                        LibraryListView(kind: "artists")
                    } label: {
                        Label("Artists", systemImage: "music.mic")
                    }
                    NavigationLink {
                        LibraryListView(kind: "downloaded")
                    } label: {
                        Label("Downloaded", systemImage: "arrow.down.circle.fill")
                    }
                }

                Section("Recently Added") {
                    ForEach(Catalog.albums) { album in
                        NavigationLink(value: album) {
                            HStack(spacing: 12) {
                                ArtworkView(album: album, size: 52)
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

                if !engine.likedIDs.isEmpty {
                    Section("Liked Songs") {
                        ForEach(Catalog.tracks.filter { engine.likedIDs.contains($0.id) }) { track in
                            Button {
                                engine.playQueue(Catalog.tracks, startAt: Catalog.tracks.firstIndex(of: track) ?? 0)
                            } label: {
                                TrackRow(track: track)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Album.self) { album in
                AlbumDetailView(album: album)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: engine.currentTrack == nil ? 0 : 76)
            }
        }
    }
}

struct LibraryListView: View {
    let kind: String
    @EnvironmentObject var engine: PlayerEngine

    private var title: String {
        switch kind {
        case "playlists": return "Playlists"
        case "albums": return "Albums"
        case "artists": return "Artists"
        default: return "Downloaded"
        }
    }

    var body: some View {
        List {
            if kind == "artists" {
                ForEach(Array(Set(Catalog.albums.map { $0.artist })).sorted(), id: \.self) { artist in
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(artist)
                                .font(.body.weight(.medium))
                            Text("\(Catalog.tracks.filter { $0.artist == artist }.count) songs")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else if kind == "playlists" {
                ForEach(Catalog.albums) { album in
                    NavigationLink(value: album) {
                        HStack(spacing: 12) {
                            ArtworkView(album: album, size: 52)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(album.title) Mix")
                                    .font(.body.weight(.medium))
                                    .lineLimit(1)
                                Text("\(album.tracks.count) songs")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else if kind == "downloaded" {
                ForEach(Catalog.tracks) { track in
                    Button {
                        engine.playQueue(Catalog.tracks, startAt: Catalog.tracks.firstIndex(of: track) ?? 0)
                    } label: {
                        TrackRow(track: track)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                ForEach(Catalog.albums) { album in
                    NavigationLink(value: album) {
                        HStack(spacing: 12) {
                            ArtworkView(album: album, size: 52)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(album.title)
                                    .font(.body.weight(.medium))
                                    .lineLimit(1)
                                Text("\(album.artist) · \(album.year)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .navigationDestination(for: Album.self) { album in
            AlbumDetailView(album: album)
        }
    }
}
