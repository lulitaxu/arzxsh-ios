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
        [Catalog.tracks[0], Catalog.tracks[3], Catalog.tracks[6], Catalog.tracks[9], Catalog.tracks[4], Catalog.tracks[7]]
    }

    private var recentlyPlayedAlbums: [Album] {
        var seen: Set<String> = []
        var result: [Album] = []
        for track in engine.history {
            if seen.insert(track.albumID).inserted {
                result.append(Catalog.album(id: track.albumID))
            }
        }
        return result
    }

    private var heavyRotationAlbums: [Album] {
        var counts: [String: Int] = [:]
        var recency: [String: Int] = [:]
        for (index, track) in engine.history.enumerated() {
            counts[track.albumID, default: 0] += 1
            if recency[track.albumID] == nil {
                recency[track.albumID] = index
            }
        }
        return Catalog.albums
            .filter { counts[$0.id] != nil }
            .sorted { a, b in
                let ca = counts[a.id] ?? 0
                let cb = counts[b.id] ?? 0
                if ca != cb { return ca > cb }
                return (recency[a.id] ?? 0) < (recency[b.id] ?? 0)
            }
    }

    private var newReleases: [Album] {
        Catalog.albums.sorted { $0.year > $1.year }
    }

    private var recentlyAdded: [Album] {
        Array(Catalog.albums.reversed())
    }

    private var moreLikeArtist: String {
        engine.history.first?.artist ?? Catalog.albums[0].artist
    }

    private var moreLikeAlbums: [Album] {
        let seed = Catalog.albums.first { $0.artist == moreLikeArtist } ?? Catalog.albums[0]
        let rest = Catalog.albums
            .filter { $0.id != seed.id }
            .sorted { a, b in
                let aMatch = a.genre == seed.genre
                let bMatch = b.genre == seed.genre
                return aMatch && !bMatch
            }
        return [seed] + rest
    }

    private var artistEntries: [(name: String, album: Album)] {
        var seen: Set<String> = []
        var result: [(name: String, album: Album)] = []
        for album in Catalog.albums {
            if seen.insert(album.artist).inserted {
                result.append((name: album.artist, album: album))
            }
        }
        return result
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    jumpBackIn

                    if !recentlyPlayedAlbums.isEmpty {
                        shelf(title: "Recently Played", albums: recentlyPlayedAlbums)
                    }

                    topPicks

                    shelf(title: "New Releases", albums: newReleases)

                    if !heavyRotationAlbums.isEmpty {
                        shelf(title: "Heavy Rotation", albums: heavyRotationAlbums)
                    }

                    mixesShelf

                    shelf(title: "More Like \(moreLikeArtist)", albums: moreLikeAlbums)

                    artistsSpotlight

                    shelf(title: "Recently Added", albums: recentlyAdded)
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

    private var jumpBackIn: some View {
        VStack(alignment: .leading, spacing: 14) {
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
                    let album = Catalog.album(for: track)
                    Button {
                        engine.playAlbum(album, startAt: album.tracks.firstIndex(of: track) ?? 0)
                    } label: {
                        HStack(spacing: 10) {
                            ArtworkView(album: album, size: 48)
                            Text(track.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .contextMenu {
                            TrackMenuContent(track: track, onGoToAlbum: { path.append(album) })
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("quickpick_\(track.id)")
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var topPicks: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Picks for You")
                .font(.title2.bold())
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    if let mix = Catalog.mixes.first {
                        Button {
                            engine.playMix(mix)
                        } label: {
                            ArtworkView(spec: mix.coverSpec, width: 320, height: 190)
                                .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("toppick_\(mix.id)")
                    }
                    ForEach([Catalog.albums[1], Catalog.albums[2]]) { album in
                        Button {
                            path.append(album)
                        } label: {
                            ArtworkView(spec: album.coverSpec, width: 320, height: 190)
                                .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("toppick_\(album.id)")
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var mixesShelf: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Made for arz")
                .font(.title2.bold())
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(Catalog.mixes) { mix in
                        Button {
                            engine.playMix(mix)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                ArtworkView(spec: mix.coverSpec, size: 160)
                                    .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(mix.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    Text(mix.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .frame(width: 160, alignment: .leading)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("mix_\(mix.id)")
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var artistsSpotlight: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Artists")
                .font(.title2.bold())
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 18) {
                    ForEach(artistEntries, id: \.name) { entry in
                        Button {
                            engine.playQueue(Catalog.tracks.filter { $0.artist == entry.name }, startAt: 0)
                        } label: {
                            VStack(spacing: 8) {
                                ArtworkView(album: entry.album, size: 92, showsTitle: false)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                                Text(entry.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .frame(width: 96)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
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
                        .contextMenu {
                            AlbumMenuContent(album: album, onGoToAlbum: { path.append(album) })
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
