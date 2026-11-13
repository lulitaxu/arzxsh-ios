import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var engine: PlayerEngine
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    NavigationLink {
                        LibraryListView(kind: "playlists", path: $path)
                    } label: {
                        Label("Playlists", systemImage: "music.note.list")
                    }
                    NavigationLink {
                        LibraryListView(kind: "albums", path: $path)
                    } label: {
                        Label("Albums", systemImage: "square.stack.fill")
                    }
                    NavigationLink {
                        LibraryListView(kind: "artists", path: $path)
                    } label: {
                        Label("Artists", systemImage: "music.mic")
                    }
                    NavigationLink {
                        LibraryListView(kind: "downloaded", path: $path)
                    } label: {
                        Label("Downloaded", systemImage: "arrow.down.circle.fill")
                    }
                    NavigationLink {
                        LibraryListView(kind: "liked", path: $path)
                    } label: {
                        HStack {
                            Label("Liked Songs", systemImage: "heart.fill")
                            Spacer()
                            Text("\(engine.likedTracks.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityIdentifier("likedSongsRow")
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
    @Binding var path: NavigationPath
    @EnvironmentObject var engine: PlayerEngine

    private var title: String {
        switch kind {
        case "playlists": return "Playlists"
        case "albums": return "Albums"
        case "artists": return "Artists"
        case "liked": return "Liked Songs"
        default: return "Downloaded"
        }
    }

    var body: some View {
        List {
            if kind == "artists" {
                ForEach(Array(Set(Catalog.albums.map { $0.artist })).sorted(), id: \.self) { artist in
                    let album = Catalog.albums.first { $0.artist == artist } ?? Catalog.albums[0]
                    Button {
                        engine.playQueue(Catalog.tracks.filter { $0.artist == artist }, startAt: 0)
                    } label: {
                        HStack(spacing: 12) {
                            ArtworkView(album: album, size: 44, showsTitle: false)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(artist)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text("\(Catalog.tracks.filter { $0.artist == artist }.count) songs")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } else if kind == "playlists" {
                ForEach(Catalog.mixes) { mix in
                    Button {
                        engine.playMix(mix)
                    } label: {
                        HStack(spacing: 12) {
                            ArtworkView(spec: mix.coverSpec, size: 52)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mix.title)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text("\(mix.tracks.count) songs")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } else if kind == "liked" {
                if engine.likedTracks.isEmpty {
                    Text("No liked songs yet. Tap the heart while a song plays and it will live here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(engine.likedTracks.enumerated()), id: \.element.id) { index, track in
                        Button {
                            engine.playQueue(engine.likedTracks, startAt: index)
                        } label: {
                            TrackRow(track: track)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            TrackMenuContent(track: track, onGoToAlbum: { path.append(Catalog.album(for: track)) })
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
                    .contextMenu {
                        TrackMenuContent(track: track, onGoToAlbum: { path.append(Catalog.album(for: track)) })
                    }
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
