import SwiftUI

struct ScrubberView: View {
    @EnvironmentObject var engine: PlayerEngine
    @State private var dragging = false
    @State private var dragValue: Double = 0

    private var shownValue: Double { dragging ? dragValue : engine.currentTime }
    private var fraction: Double {
        guard engine.duration > 0 else { return 0 }
        return max(0, min(1, shownValue / engine.duration))
    }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.24))
                        .frame(height: dragging ? 10 : 5)
                    Capsule()
                        .fill(Color.white.opacity(0.92))
                        .frame(width: max(0, geo.size.width * fraction), height: dragging ? 10 : 5)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 13, height: 13)
                        .scaleEffect(dragging ? 1.6 : 0.01)
                        .opacity(dragging ? 1 : 0)
                        .offset(x: max(0, min(geo.size.width - 13, geo.size.width * fraction - 6.5)))
                        .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 1)
                }
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            dragging = true
                            let f = max(0, min(1, gesture.location.x / geo.size.width))
                            dragValue = f * engine.duration
                        }
                        .onEnded { _ in
                            engine.seek(to: dragValue)
                            dragging = false
                        }
                )
            }
            .frame(height: 26)
            .animation(.easeOut(duration: 0.15), value: dragging)

            HStack {
                Text(formatTime(shownValue))
                Spacer()
                Text("-" + formatTime(max(0, engine.duration - shownValue)))
            }
            .font(.caption.weight(.medium).monospacedDigit())
            .foregroundStyle(Color.white.opacity(0.55))
        }
    }
}

struct NowPlayingView: View {
    @EnvironmentObject var engine: PlayerEngine

    var body: some View {
        Group {
            if let track = engine.currentTrack {
                content(track: track)
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background)
        .sheet(isPresented: $engine.showQueue) {
            QueueView()
        }
    }

    private var background: some View {
        ZStack {
            if let track = engine.currentTrack {
                ArtworkView(album: Catalog.album(for: track), size: 700, animated: true)
                    .blur(radius: 60)
                    .saturation(1.45)
                    .scaleEffect(1.25)
            }
            Color.black.opacity(0.38)
        }
        .ignoresSafeArea()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Nothing is playing right now.")
                .font(.headline)
            Text("Pick a song from your library and it will show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Close") {
                engine.showNowPlaying = false
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
        }
        .padding(32)
    }

    private var grabberHeader: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 38, height: 5)
            HStack {
                Button {
                    engine.showNowPlaying = false
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .frame(width: 32, height: 32)
                }
                .accessibilityIdentifier("closeNowPlayingButton")
                Spacer()
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
    }

    private func content(track: Track) -> some View {
        let album = Catalog.album(for: track)
        return VStack(spacing: 0) {
            grabberHeader

            if engine.showLyrics {
                LyricsView(track: track)
                    .padding(.top, 4)
            } else {
                Spacer()
                ArtworkView(album: album, size: 318, animated: true)
                    .shadow(color: Color.black.opacity(0.55), radius: 30, x: 0, y: 16)
                    .scaleEffect(engine.isPlaying ? 1.0 : 0.86)
                    .animation(.spring(response: 0.55, dampingFraction: 0.82), value: engine.isPlaying)
                Spacer()
            }

            if engine.failedToLoad {
                VStack(spacing: 10) {
                    Text("This track could not be played.")
                        .font(.headline)
                    Button("Retry") {
                        engine.retry()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)
                }
                .padding(.vertical, 12)
            } else {
                controls(track: track)
            }
        }
    }

    private func controls(track: Track) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.title3.bold())
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.title3)
                        .foregroundStyle(Color.white.opacity(0.6))
                        .lineLimit(1)
                }
                Spacer()
                Button {
                    engine.toggleLike(track)
                } label: {
                    Image(systemName: engine.isLiked(track) ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundStyle(engine.isLiked(track) ? AppTheme.accent : Color.white.opacity(0.85))
                }
                .accessibilityIdentifier("likeButton")
            }

            ScrubberView()

            HStack {
                Button {
                    engine.toggleShuffle()
                } label: {
                    Image(systemName: "shuffle")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(engine.shuffleEnabled ? AppTheme.accent : Color.white.opacity(0.55))
                        .frame(width: 40, height: 44)
                }
                .accessibilityIdentifier("shuffleButton")
                Spacer()
                Button {
                    engine.playPrevious()
                } label: {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(engine.hasPrevious || engine.currentTime > 3 ? .white : Color.white.opacity(0.35))
                }
                Spacer()
                Button {
                    engine.togglePlayPause()
                } label: {
                    Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }
                .accessibilityIdentifier("playPauseButton")
                Spacer()
                Button {
                    engine.playNext()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(engine.hasNext || engine.repeatMode == .all ? .white : Color.white.opacity(0.35))
                }
                .accessibilityIdentifier("nextButton")
                Spacer()
                Button {
                    engine.cycleRepeat()
                } label: {
                    Image(systemName: engine.repeatMode == .one ? "repeat.1" : "repeat")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(engine.repeatMode == .off ? Color.white.opacity(0.55) : AppTheme.accent)
                        .frame(width: 40, height: 44)
                }
                .accessibilityIdentifier("repeatButton")
            }
            .padding(.vertical, 4)

            HStack(spacing: 6) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.55))
                Slider(value: $engine.volume, in: 0...1)
                    .tint(Color.white.opacity(0.85))
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.55))
            }

            HStack {
                Button {
                    engine.showLyrics.toggle()
                } label: {
                    Image(systemName: "quote.bubble")
                        .font(.system(size: 20))
                        .foregroundStyle(engine.showLyrics ? AppTheme.accent : Color.white.opacity(0.8))
                        .frame(width: 44, height: 36)
                }
                .accessibilityIdentifier("lyricsButton")
                Spacer()
                Menu {
                    Button {
                        engine.setSleepTimer(nil)
                    } label: {
                        if engine.sleepTimerMinutes == nil {
                            Label("Off", systemImage: "checkmark")
                        } else {
                            Text("Off")
                        }
                    }
                    ForEach([15, 30, 45], id: \.self) { minutes in
                        Button {
                            engine.setSleepTimer(minutes)
                        } label: {
                            if engine.sleepTimerMinutes == minutes {
                                Label("\(minutes) minutes", systemImage: "checkmark")
                            } else {
                                Text("\(minutes) minutes")
                            }
                        }
                    }
                } label: {
                    Image(systemName: engine.sleepTimerMinutes == nil ? "moon.zzz" : "moon.zzz.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(engine.sleepTimerMinutes == nil ? Color.white.opacity(0.8) : AppTheme.accent)
                        .frame(width: 44, height: 36)
                }
                .accessibilityIdentifier("sleepTimerButton")
                Spacer()
                Button {
                    engine.showQueue = true
                } label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.white.opacity(0.8))
                        .frame(width: 44, height: 36)
                }
                .accessibilityIdentifier("queueButton")
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 26)
    }
}
