import SwiftUI

@main
struct ArzxshApp: App {
    @StateObject private var engine = PlayerEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(engine)
        }
    }
}
