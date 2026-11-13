import SwiftUI

struct TrackMenuContent: View {
    @EnvironmentObject var engine: PlayerEngine
    let track: Track
    var onGoToAlbum: (() -> Void)? = nil

    var body: some View {
        Button {
            engine.playNext(track)
        } label: {
            Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
        }
        Button {
            engine.addToQueue(track)
        } label: {
            Label("Add to Queue", systemImage: "text.badge.plus")
        }
        Button {
            engine.toggleLike(track)
        } label: {
            Label(engine.isLiked(track) ? "Unlike" : "Like", systemImage: engine.isLiked(track) ? "heart.fill" : "heart")
        }
        if let onGoToAlbum {
            Button {
                onGoToAlbum()
            } label: {
                Label("Go to Album", systemImage: "square.stack")
            }
        }
    }
}

struct AlbumMenuContent: View {
    @EnvironmentObject var engine: PlayerEngine
    let album: Album
    var onGoToAlbum: (() -> Void)? = nil

    var body: some View {
        Button {
            engine.playAlbum(album, startAt: 0)
        } label: {
            Label("Play", systemImage: "play.fill")
        }
        Button {
            engine.playNext(album.tracks)
        } label: {
            Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
        }
        Button {
            engine.addToQueue(album.tracks)
        } label: {
            Label("Add to Queue", systemImage: "text.badge.plus")
        }
        if let onGoToAlbum {
            Button {
                onGoToAlbum()
            } label: {
                Label("Go to Album", systemImage: "square.stack")
            }
        }
    }
}
