import SwiftUI

struct LyriBeacon: Identifiable {
    let time: Double
    let text: String
    var id: Double { time }
}

struct Track: Identifiable, Hashable {
    let id: String
    let title: String
    let artist: String
    let albumID: String
    let duration: Double
    let audioFile: String
    let lyrics: [LyriBeacon]

    static func == (lhs: Track, rhs: Track) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Album: Identifiable, Hashable {
    let id: String
    let title: String
    let artist: String
    let year: String
    let genre: String
    let colors: [Color]
    let tint: Color
    let symbol: String

    var tracks: [Track] { Catalog.tracks.filter { $0.albumID == id } }

    static func == (lhs: Album, rhs: Album) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum AppTheme {
    static let accent = Color(red: 0.98, green: 0.24, blue: 0.30)
}
