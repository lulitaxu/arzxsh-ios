import AppIntents
import Foundation
import WidgetKit

struct TogglePlaybackIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Playback"
    static var description = IntentDescription("Plays or pauses arzxsh.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        var state = SharedStore.read()
        guard state.trackID != nil else {
            return .result()
        }
        state.isPlaying.toggle()
        SharedStore.write(state)
        PlaybackSignal.postToggle()
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
