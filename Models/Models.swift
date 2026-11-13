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

enum CoverStyle {
    case skyline
    case rain
    case sunDisc
    case paperFold
}

enum CoverTitleLayout {
    case bottomLeft
    case topLeft
    case centered
    case verticalRight
}

struct Album: Identifiable, Hashable {
    let id: String
    let title: String
    let artist: String
    let year: String
    let genre: String
    let colors: [Color]
    let glow: Color
    let tint: Color
    let coverStyle: CoverStyle
    let titleLayout: CoverTitleLayout

    var tracks: [Track] { Catalog.tracks.filter { $0.albumID == id } }

    static func == (lhs: Album, rhs: Album) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Mix: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let trackIDs: [String]
    let heroAlbumID: String
    let colors: [Color]

    var tracks: [Track] {
        trackIDs.compactMap { id in Catalog.tracks.first { $0.id == id } }
    }

    var hero: Album { Catalog.album(id: heroAlbumID) }

    static func == (lhs: Mix, rhs: Mix) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum AppTheme {
    static let accent = Color(red: 0.98, green: 0.24, blue: 0.30)
}
