import SwiftUI
import WidgetKit

struct ArzxshProvider: TimelineProvider {
    func placeholder(in context: Context) -> ArzxshWidgetEntry {
        ArzxshWidgetEntry(date: Date(), state: SharedStore.read())
    }

    func getSnapshot(in context: Context, completion: @escaping (ArzxshWidgetEntry) -> Void) {
        completion(ArzxshWidgetEntry(date: Date(), state: SharedStore.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ArzxshWidgetEntry>) -> Void) {
        let entry = ArzxshWidgetEntry(date: Date(), state: SharedStore.read())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct LockScreenWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ArzxshLockWidgets", provider: ArzxshProvider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Now Playing")
        .description("Your current track on the Lock Screen.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct LockScreenWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ArzxshWidgetEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            LockCircularWidgetView(state: entry.state)
        case .accessoryInline:
            LockInlineWidgetView(state: entry.state)
        default:
            LockRectangularWidgetView(state: entry.state)
        }
    }
}

struct HomeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ArzxshHomeWidgets", provider: ArzxshProvider()) { entry in
            HomeWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.05, green: 0.05, blue: 0.09)
                }
        }
        .configurationDisplayName("arzxsh")
        .description("Now playing and recently played, one tap away.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HomeWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ArzxshWidgetEntry

    var body: some View {
        switch family {
        case .systemMedium:
            HomeMediumWidgetView(state: entry.state)
        default:
            HomeSmallWidgetView(state: entry.state)
        }
    }
}

@main
struct ArzxshWidgets: WidgetBundle {
    var body: some Widget {
        LockScreenWidget()
        HomeWidget()
    }
}
