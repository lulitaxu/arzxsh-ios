import AVFoundation
import Foundation

enum RepeatMode {
    case off
    case all
    case one
}

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
    @Published var history: [Track] = []
    @Published var shuffleEnabled: Bool = false
    @Published var repeatMode: RepeatMode = .off
    @Published var sleepTimerMinutes: Int? = nil
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

    var likedTracks: [Track] {
        Catalog.tracks.filter { likedIDs.contains($0.id) }
    }

    private let player = AVPlayer()
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var preShuffleQueue: [Track]?
    private var sleepTask: Task<Void, Never>?
    private let likedKey = "arzxsh.likedTrackIDs"

    init() {
        likedIDs = Set(UserDefaults.standard.stringArray(forKey: likedKey) ?? [])
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
        shuffleEnabled = false
        preShuffleQueue = nil
        loadCurrent(autoplay: true)
    }

    func playAlbum(_ album: Album, startAt index: Int = 0) {
        playQueue(album.tracks, startAt: index)
    }

    func playMix(_ mix: Mix) {
        playQueue(mix.tracks, startAt: 0)
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
        if hasNext {
            currentIndex += 1
            loadCurrent(autoplay: true)
        } else if repeatMode == .all, !queue.isEmpty {
            currentIndex = 0
            loadCurrent(autoplay: true)
        }
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

    func playNext(_ track: Track) {
        playNext([track])
    }

    func playNext(_ tracks: [Track]) {
        guard !tracks.isEmpty else { return }
        guard currentTrack != nil else {
            playQueue(tracks, startAt: 0)
            return
        }
        queue.insert(contentsOf: tracks, at: currentIndex + 1)
        if shuffleEnabled {
            preShuffleQueue?.insert(contentsOf: tracks, at: min(currentIndex + 1, preShuffleQueue?.count ?? 0))
        }
    }

    func addToQueue(_ track: Track) {
        addToQueue([track])
    }

    func addToQueue(_ tracks: [Track]) {
        guard !tracks.isEmpty else { return }
        queue.append(contentsOf: tracks)
        if shuffleEnabled {
            preShuffleQueue?.append(contentsOf: tracks)
        }
    }

    func toggleShuffle() {
        shuffleEnabled.toggle()
        if shuffleEnabled {
            preShuffleQueue = queue
            guard queue.count > 2, currentIndex >= 0, currentIndex < queue.count - 1 else { return }
            let head = Array(queue[...currentIndex])
            var tail = Array(queue[(currentIndex + 1)...])
            tail.shuffle()
            queue = head + tail
        } else if let backup = preShuffleQueue {
            var counts: [String: Int] = [:]
            for track in backup { counts[track.id, default: 0] += 1 }
            var extras: [Track] = []
            for track in queue {
                if let count = counts[track.id], count > 0 {
                    counts[track.id] = count - 1
                } else {
                    extras.append(track)
                }
            }
            var restored = backup
            restored.append(contentsOf: extras)
            let current = currentTrack
            queue = restored
            if let current, let index = restored.firstIndex(of: current) {
                currentIndex = index
            }
            preShuffleQueue = nil
        }
    }

    func cycleRepeat() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    func setSleepTimer(_ minutes: Int?) {
        sleepTask?.cancel()
        sleepTask = nil
        sleepTimerMinutes = minutes
        guard let minutes else { return }
        sleepTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(minutes) * 60_000_000_000)
            guard !Task.isCancelled else { return }
            guard let self else { return }
            if self.isPlaying {
                self.player.pause()
                self.isPlaying = false
            }
            self.sleepTimerMinutes = nil
            self.sleepTask = nil
        }
    }

    func toggleLike(_ track: Track) {
        if likedIDs.contains(track.id) {
            likedIDs.remove(track.id)
        } else {
            likedIDs.insert(track.id)
        }
        UserDefaults.standard.set(Array(likedIDs), forKey: likedKey)
    }

    func isLiked(_ track: Track) -> Bool {
        likedIDs.contains(track.id)
    }

    private func recordHistory(_ track: Track) {
        history.removeAll { $0.id == track.id }
        history.insert(track, at: 0)
        if history.count > 24 {
            history = Array(history.prefix(24))
        }
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
        recordHistory(track)
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.repeatMode == .one {
                    self.seek(to: 0)
                    self.player.play()
                    self.isPlaying = true
                } else if self.hasNext {
                    self.playNext()
                } else if self.repeatMode == .all, !self.queue.isEmpty {
                    self.currentIndex = 0
                    self.loadCurrent(autoplay: true)
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
