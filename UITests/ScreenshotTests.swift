import XCTest

final class ScreenshotTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    private func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testLikedSongs() throws {
        app.launchArguments = ["-screen", "nowplaying"]
        app.launch()
        XCTAssertTrue(app.buttons["playPauseButton"].waitForExistence(timeout: 15))
        Thread.sleep(forTimeInterval: 1.5)
        app.buttons["likeButton"].tap()
        Thread.sleep(forTimeInterval: 0.6)
        app.buttons["closeNowPlayingButton"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10))
        app.tabBars.buttons["Library"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        var row = app.buttons["likedSongsRow"]
        if !row.waitForExistence(timeout: 5) {
            row = app.cells["likedSongsRow"]
            XCTAssertTrue(row.waitForExistence(timeout: 5))
        }
        row.tap()
        Thread.sleep(forTimeInterval: 1.2)
        shot("LikedSongs")
    }

    func testLyrics() throws {
        app.launchArguments = ["-screen", "lyrics"]
        app.launch()
        Thread.sleep(forTimeInterval: 3.5)
        shot("Lyrics")
    }

    func testMainScreens() throws {
        app.launch()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 15))
        Thread.sleep(forTimeInterval: 1.0)

        let firstPick = app.buttons["quickpick_t01"]
        XCTAssertTrue(firstPick.waitForExistence(timeout: 10))
        firstPick.tap()
        Thread.sleep(forTimeInterval: 1.2)
        let secondPick = app.buttons["quickpick_t04"]
        XCTAssertTrue(secondPick.waitForExistence(timeout: 10))
        secondPick.tap()
        Thread.sleep(forTimeInterval: 1.5)
        shot("Home")

        app.tabBars.buttons["Library"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        shot("Library")

        app.tabBars.buttons["Search"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        shot("Search")

        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 5) {
            searchField.tap()
            searchField.typeText("Monsoon")
            Thread.sleep(forTimeInterval: 1.2)
            shot("SearchResults")
            app.buttons["Cancel"].tap()
        }

        app.tabBars.buttons["Home"].tap()
        Thread.sleep(forTimeInterval: 0.8)
        app.scrollViews.firstMatch.swipeUp()
        Thread.sleep(forTimeInterval: 0.6)
        let card = app.buttons.matching(identifier: "album_midnight-dhaka").firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 10))
        card.tap()
        Thread.sleep(forTimeInterval: 1.2)
        shot("Album")
    }

    func testNowPlaying() throws {
        app.launchArguments = ["-screen", "nowplaying"]
        app.launch()
        XCTAssertTrue(app.buttons["playPauseButton"].waitForExistence(timeout: 15))
        Thread.sleep(forTimeInterval: 3.0)
        shot("NowPlaying")
        Thread.sleep(forTimeInterval: 5.0)
        shot("NowPlayingLive2")
        app.buttons["shuffleButton"].tap()
        let repeatButton = app.buttons["repeatButton"]
        repeatButton.tap()
        repeatButton.tap()
        Thread.sleep(forTimeInterval: 0.6)
        shot("NowPlayingControls")
    }

    func testQueue() throws {
        app.launchArguments = ["-screen", "queue"]
        app.launch()
        Thread.sleep(forTimeInterval: 3.0)
        shot("Queue")
    }
}
