import Foundation

struct SharedRecentTrack: Codable, Equatable {
    var title: String
    var artist: String
    var albumID: String
}

struct SharedState: Codable, Equatable {
    var trackID: String?
    var title: String?
    var artist: String?
    var albumTitle: String?
    var albumID: String?
    var isPlaying: Bool
    var progress: Double
    var likedCount: Int
    var recents: [SharedRecentTrack]

    static let empty = SharedState(
        trackID: nil,
        title: nil,
        artist: nil,
        albumTitle: nil,
        albumID: nil,
        isPlaying: false,
        progress: 0,
        likedCount: 0,
        recents: []
    )
}

enum SharedStore {
    static let suiteName = "group.me.arafatarzu.arzxsh"
    private static let stateKey = "arzxsh.sharedState.v1"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static func read() -> SharedState {
        guard let data = defaults.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(SharedState.self, from: data) else {
            return .empty
        }
        return state
    }

    static func write(_ state: SharedState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: stateKey)
    }
}

enum PlaybackSignal {
    static let toggleName = "me.arafatarzu.arzxsh.togglePlayback"

    static func postToggle() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(rawValue: toggleName),
            nil,
            nil,
            true
        )
    }
}

final class PlaybackSignalObserver {
    private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            center,
            observer,
            { _, rawObserver, _, _, _ in
                guard let rawObserver else { return }
                let instance = Unmanaged<PlaybackSignalObserver>.fromOpaque(rawObserver).takeUnretainedValue()
                instance.handler()
            },
            PlaybackSignal.toggleName as CFString,
            nil,
            .deliverImmediately
        )
    }

    deinit {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterRemoveObserver(center, observer, CFNotificationName(rawValue: PlaybackSignal.toggleName), nil)
    }
}
