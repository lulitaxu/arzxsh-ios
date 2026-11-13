import MediaPlayer
import XCTest
@testable import arzxsh

@MainActor
final class NowPlayingTests: XCTestCase {
    func testNowPlayingInfoPublishedAndUpdatesOnPause() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        let engine = PlayerEngine()
        let album = Catalog.albums[0]
        let track = album.tracks[0]
        engine.playAlbum(album, startAt: 0)

        let info = MPNowPlayingInfoCenter.default().nowPlayingInfo
        XCTAssertEqual(info?[MPMediaItemPropertyTitle] as? String, track.title)
        XCTAssertEqual(info?[MPMediaItemPropertyArtist] as? String, track.artist)
        XCTAssertEqual(info?[MPMediaItemPropertyAlbumTitle] as? String, album.title)
        XCTAssertEqual((info?[MPMediaItemPropertyPlaybackDuration] as? NSNumber)?.doubleValue, track.duration)
        XCTAssertEqual((info?[MPNowPlayingInfoPropertyPlaybackRate] as? NSNumber)?.doubleValue, 1.0)
        XCTAssertNotNil(info?[MPMediaItemPropertyArtwork])
        XCTAssertNotNil(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime])

        engine.togglePlayPause()
        let paused = MPNowPlayingInfoCenter.default().nowPlayingInfo
        XCTAssertEqual(paused?[MPMediaItemPropertyTitle] as? String, track.title)
        XCTAssertEqual((paused?[MPNowPlayingInfoPropertyPlaybackRate] as? NSNumber)?.doubleValue, 0.0)
    }

    func testNowPlayingElapsedUpdatesOnSeek() async {
        let engine = PlayerEngine()
        engine.playAlbum(Catalog.albums[0], startAt: 0)
        engine.seek(to: 12)
        var elapsed: Double = -1
        for _ in 0..<30 {
            elapsed = (MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? NSNumber)?.doubleValue ?? -1
            if elapsed == 12 { break }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        XCTAssertEqual(elapsed, 12)
    }

    func testSharedStateWrittenOnPlayAndLike() {
        let engine = PlayerEngine()
        let album = Catalog.albums[0]
        let track = album.tracks[0]
        engine.playAlbum(album, startAt: 0)

        var state = SharedStore.read()
        XCTAssertEqual(state.trackID, track.id)
        XCTAssertEqual(state.title, track.title)
        XCTAssertEqual(state.artist, track.artist)
        XCTAssertEqual(state.albumID, album.id)
        XCTAssertEqual(state.isPlaying, true)
        XCTAssertEqual(state.recents.first?.title, track.title)

        let likedBefore = state.likedCount
        engine.toggleLike(track)
        state = SharedStore.read()
        XCTAssertEqual(state.likedCount, likedBefore + 1)
        engine.toggleLike(track)
        state = SharedStore.read()
        XCTAssertEqual(state.likedCount, likedBefore)
    }
}
