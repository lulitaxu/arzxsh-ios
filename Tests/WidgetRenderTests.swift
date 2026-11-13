import SwiftUI
import XCTest
@testable import arzxsh

@MainActor
final class WidgetRenderTests: XCTestCase {
    private func sampleState() -> SharedState {
        let album = Catalog.albums[0]
        let track = album.tracks[0]
        return SharedState(
            trackID: track.id,
            title: track.title,
            artist: track.artist,
            albumTitle: album.title,
            albumID: album.id,
            isPlaying: true,
            progress: 0.44,
            likedCount: 3,
            recents: [Catalog.tracks[0], Catalog.tracks[3], Catalog.tracks[6]].map {
                SharedRecentTrack(title: $0.title, artist: $0.artist, albumID: $0.albumID)
            }
        )
    }

    private func attach<V: View>(_ view: V, size: CGSize, name: String) {
        let content = view
            .frame(width: size.width, height: size.height)
            .environment(\.colorScheme, .dark)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        guard let image = renderer.uiImage, let data = image.pngData() else {
            XCTFail("ImageRenderer produced no PNG for \(name)")
            return
        }
        XCTAssertGreaterThan(data.count, 1500, "Render for \(name) looks blank (\(data.count) bytes)")
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testWidgetRenders() {
        let state = sampleState()
        attach(LockRectangularWidgetView(state: state), size: CGSize(width: 164, height: 72), name: "LockRect")
        attach(LockCircularWidgetView(state: state), size: CGSize(width: 72, height: 72), name: "LockCircular")
        attach(
            ZStack {
                Color.black
                LockInlineWidgetView(state: state)
                    .foregroundStyle(.white)
            },
            size: CGSize(width: 216, height: 24),
            name: "LockInline"
        )
        attach(HomeSmallWidgetView(state: state), size: CGSize(width: 158, height: 158), name: "HomeSmall")
        attach(HomeMediumWidgetView(state: state), size: CGSize(width: 338, height: 158), name: "HomeMedium")
    }

    func testSharedStoreRoundTripAndIntentFlip() async throws {
        let state = sampleState()
        SharedStore.write(state)
        XCTAssertEqual(SharedStore.read(), state)
        _ = try await TogglePlaybackIntent().perform()
        XCTAssertEqual(SharedStore.read().isPlaying, !state.isPlaying)
        XCTAssertEqual(SharedStore.read().trackID, state.trackID)
    }
}
