import SwiftUI

struct ContentView: View {
    @EnvironmentObject var engine: PlayerEngine
    @State private var selectedTab = 0
    @State private var homePath = NavigationPath()
    @State private var didHandleLaunchArgs = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HomeView(path: $homePath)
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(0)
                    LibraryView()
                        .tabItem { Label("Library", systemImage: "books.vertical.fill") }
                        .tag(1)
                    SearchView()
                        .tabItem { Label("Search", systemImage: "magnifyingglass") }
                        .tag(2)
                }
                .tint(AppTheme.accent)

                if engine.currentTrack != nil {
                    MiniPlayerView()
                        .padding(.horizontal, 8)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 53)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: engine.currentTrack?.id)
        .fullScreenCover(isPresented: $engine.showNowPlaying) {
            NowPlayingView()
        }
        .onAppear {
            guard !didHandleLaunchArgs else { return }
            didHandleLaunchArgs = true
            handleLaunchArguments()
        }
    }

    private func handleLaunchArguments() {
        let args = ProcessInfo.processInfo.arguments
        func value(after flag: String) -> String? {
            guard let idx = args.firstIndex(of: flag), idx + 1 < args.count else { return nil }
            return args[idx + 1]
        }
        guard let screen = value(after: "-screen") else { return }
        switch screen {
        case "library":
            selectedTab = 1
        case "search":
            selectedTab = 2
        case "album":
            if let album = Catalog.albums.first {
                homePath.append(album)
            }
        case "nowplaying", "lyrics", "queue":
            engine.playQueue(Catalog.tracks, startAt: 0)
            engine.showNowPlaying = true
            if screen == "lyrics" { engine.showLyrics = true }
            if screen == "queue" { engine.showQueue = true }
            Task {
                try? await Task.sleep(nanoseconds: 900_000_000)
                engine.seek(to: 14)
            }
        default:
            break
        }
    }
}
