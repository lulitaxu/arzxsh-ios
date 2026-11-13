import AVFoundation
import Foundation

@MainActor
final class PlayerEngine: ObservableObject {
    @Published var queue: [Track] = []
    @Published var currentIndex: Int = -1
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var volume: Float = 0.8 {
        didSet { player.volume = volume }
    }
    @Published var likedIDs: Set<String> = []
    @Published var showNowPlaying: Bool = false
    @Published var showLyrics: Bool = false
    @Published var showQueue: Bool = false
    @Published var failedToLoad: Bool = false

    var currentTrack: Track? {
        guard queue.indices.contains(currentIndex) else { return nil }
        return queue[currentIndex]
    }

    var hasNext: Bool { queue.indices.contains(currentIndex + 1) }
    var hasPrevious: Bool { queue.indices.contains(currentIndex - 1) }

    private let player = AVPlayer()
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?

    init() {
        player.volume = volume
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.3, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }
            if time.seconds.isFinite {
                self.currentTime = time.seconds
            }
            if let itemSeconds = self.player.currentItem?.duration.seconds, itemSeconds.isFinite, itemSeconds > 0 {
                self.duration = itemSeconds
            }
        }
    }

    deinit {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
    }

    func playQueue(_ tracks: [Track], startAt index: Int) {
        guard !tracks.isEmpty, tracks.indices.contains(index) else { return }
        queue = tracks
        currentIndex = index
        loadCurrent(autoplay: true)
    }

    func playAlbum(_ album: Album, startAt index: Int = 0) {
        playQueue(album.tracks, startAt: index)
    }

    func togglePlayPause() {
        guard currentTrack != nil else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func playNext() {
        guard hasNext else { return }
        currentIndex += 1
        loadCurrent(autoplay: true)
    }

    func playPrevious() {
        if currentTime > 3 {
            seek(to: 0)
            return
        }
        guard hasPrevious else {
            seek(to: 0)
            return
        }
        currentIndex -= 1
        loadCurrent(autoplay: true)
    }

    func jumpTo(index: Int) {
        guard queue.indices.contains(index) else { return }
        if index == currentIndex {
            seek(to: 0)
            return
        }
        currentIndex = index
        loadCurrent(autoplay: true)
    }

    func seek(to seconds: Double) {
        let target = max(0, min(seconds, duration > 0 ? duration : seconds))
        let time = CMTime(seconds: target, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = target
            }
        }
    }

    func retry() {
        loadCurrent(autoplay: true)
    }

    func toggleLike(_ track: Track) {
        if likedIDs.contains(track.id) {
            likedIDs.remove(track.id)
        } else {
            likedIDs.insert(track.id)
        }
    }

    func isLiked(_ track: Track) -> Bool {
        likedIDs.contains(track.id)
    }

    private func loadCurrent(autoplay: Bool) {
        guard let track = currentTrack else { return }
        guard let url = Bundle.main.url(forResource: track.audioFile, withExtension: "m4a") else {
            failedToLoad = true
            isPlaying = false
            return
        }
        failedToLoad = false
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        currentTime = 0
        duration = track.duration
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.hasNext {
                    self.playNext()
                } else {
                    self.isPlaying = false
                    self.currentTime = self.duration
                }
            }
        }
        if autoplay {
            player.play()
            isPlaying = true
        } else {
            isPlaying = false
        }
    }
}
