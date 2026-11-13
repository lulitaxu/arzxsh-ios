import SwiftUI

private func L(_ time: Double, _ text: String) -> LyriBeacon {
    LyriBeacon(time: time, text: text)
}

enum Catalog {
    static let albums: [Album] = [
        Album(
            id: "midnight-dhaka",
            title: "Midnight in Dhaka",
            artist: "Nadia Rahman",
            year: "2024",
            genre: "Indie",
            colors: [Color(red: 0.05, green: 0.07, blue: 0.28), Color(red: 0.16, green: 0.16, blue: 0.52), Color(red: 0.38, green: 0.22, blue: 0.66)],
            glow: Color(red: 0.96, green: 0.91, blue: 0.78),
            tint: Color(red: 0.55, green: 0.65, blue: 1.0),
            coverStyle: .skyline,
            titleLayout: .bottomLeft
        ),
        Album(
            id: "neon-monsoon",
            title: "Neon Monsoon",
            artist: "The Cartographers",
            year: "2025",
            genre: "Electronic",
            colors: [Color(red: 0.01, green: 0.20, blue: 0.30), Color(red: 0.02, green: 0.42, blue: 0.48), Color(red: 0.10, green: 0.66, blue: 0.52)],
            glow: Color(red: 0.45, green: 0.95, blue: 1.0),
            tint: Color(red: 0.35, green: 0.95, blue: 0.75),
            coverStyle: .rain,
            titleLayout: .topLeft
        ),
        Album(
            id: "golden-hour-static",
            title: "Golden Hour Static",
            artist: "Arif Chowdhury",
            year: "2023",
            genre: "Folk Pop",
            colors: [Color(red: 0.52, green: 0.15, blue: 0.04), Color(red: 0.85, green: 0.38, blue: 0.08), Color(red: 0.98, green: 0.66, blue: 0.20)],
            glow: Color(red: 1.0, green: 0.86, blue: 0.48),
            tint: Color(red: 1.0, green: 0.78, blue: 0.38),
            coverStyle: .sunDisc,
            titleLayout: .centered
        ),
        Album(
            id: "paper-boats",
            title: "Paper Boats",
            artist: "Mira Sen",
            year: "2025",
            genre: "Dream Pop",
            colors: [Color(red: 0.42, green: 0.10, blue: 0.38), Color(red: 0.72, green: 0.22, blue: 0.48), Color(red: 0.94, green: 0.45, blue: 0.55)],
            glow: Color(red: 1.0, green: 0.76, blue: 0.80),
            tint: Color(red: 1.0, green: 0.58, blue: 0.76),
            coverStyle: .paperFold,
            titleLayout: .verticalRight
        )
    ]

    static let tracks: [Track] = [
        Track(id: "t01", title: "Rickshaw Bells at 2 AM", artist: "Nadia Rahman", albumID: "midnight-dhaka", duration: 48, audioFile: "track01", lyrics: [
            L(2, "Streetlights hum on an empty road"),
            L(6, "Your laughter echoes off the shuttered shops"),
            L(10, "A rickshaw bell rings somewhere far"),
            L(14, "And the city forgets to sleep"),
            L(18, "We were chasing ghosts in the old town lanes"),
            L(22, "With pocket change and borrowed time"),
            L(26, "Every crossing felt like a promise"),
            L(30, "Every shadow knew our names"),
            L(34, "Ring the bell, we are almost home"),
            L(38, "Through the smoke and the winter haze"),
            L(42, "If the morning takes it all away"),
            L(46, "Tonight was ours anyway")
        ]),
        Track(id: "t02", title: "Buriganga Blue", artist: "Nadia Rahman", albumID: "midnight-dhaka", duration: 48, audioFile: "track02", lyrics: [
            L(2, "Brown water carrying a silver moon"),
            L(6, "Boats are rocking like they dream"),
            L(10, "You said the river remembers everything"),
            L(14, "Even the words we never mean"),
            L(18, "Buriganga blue, carry me slow"),
            L(22, "Past the brickfields and the glow"),
            L(26, "If I lose my way in the current"),
            L(30, "Let the tide decide where I go"),
            L(34, "Lanterns fading on the far shore"),
            L(38, "Engines humming low and deep"),
            L(42, "The river keeps what the city drops"),
            L(46, "And sings the drowned to sleep")
        ]),
        Track(id: "t03", title: "Last Train to Kamalapur", artist: "Nadia Rahman", albumID: "midnight-dhaka", duration: 48, audioFile: "track03", lyrics: [
            L(2, "Platform nine and a whistle cry"),
            L(6, "Your suitcase held together with string"),
            L(10, "You waved like it was just another day"),
            L(14, "Like leaving was a small thing"),
            L(18, "Last train rolling out of Kamalapur"),
            L(22, "Windows lit like a string of stars"),
            L(26, "I kept your ticket in my pocket"),
            L(30, "Like a map of where you are"),
            L(34, "Miles of fields in the window glass"),
            L(38, "Sleeping villages drifting by"),
            L(42, "If you look back at the city lights"),
            L(46, "One of them is mine tonight")
        ]),
        Track(id: "t04", title: "Umbrella City", artist: "The Cartographers", albumID: "neon-monsoon", duration: 48, audioFile: "track04", lyrics: [
            L(2, "Rain writes letters on the window"),
            L(6, "Neon bleeding into the street"),
            L(10, "A hundred umbrellas bloom at once"),
            L(14, "And strangers share the heat"),
            L(18, "Umbrella city, hold me dry"),
            L(22, "Under your electric sky"),
            L(26, "Every puddle holds a universe"),
            L(30, "Every corner says goodbye"),
            L(34, "Thunder talking over rooftops"),
            L(38, "Lightning taking photographs"),
            L(42, "We were soaked and laughing anyway"),
            L(46, "Monsoon writes the epitaphs")
        ]),
        Track(id: "t05", title: "Puddle Lights", artist: "The Cartographers", albumID: "neon-monsoon", duration: 48, audioFile: "track05", lyrics: [
            L(2, "Headlights doubled in the water"),
            L(6, "The whole street turned to glass"),
            L(10, "You skipped over every puddle"),
            L(14, "Like the rain would never last"),
            L(18, "Puddle lights, shine for me"),
            L(22, "Show me where the dry ground is"),
            L(26, "Love is just a reflection"),
            L(30, "That the weather likes to kiss"),
            L(34, "When the clouds finally empty"),
            L(38, "And the drains run clear and slow"),
            L(42, "The city in the puddle vanishes"),
            L(46, "But I still see its glow")
        ]),
        Track(id: "t06", title: "Sixth Floor Thunder", artist: "The Cartographers", albumID: "neon-monsoon", duration: 48, audioFile: "track06", lyrics: [
            L(2, "Counting seconds after lightning"),
            L(6, "From your window on the sixth floor"),
            L(10, "The storm was closer than the last one"),
            L(14, "Shaking every locked door"),
            L(18, "Sixth floor thunder, roll on by"),
            L(22, "Shake the dust from the summer sky"),
            L(26, "We are small and the night is huge"),
            L(30, "But your hand is warm in mine"),
            L(34, "Antennas dancing on the rooftop"),
            L(38, "Water tanks and tangled wire"),
            L(42, "If the power cuts at midnight"),
            L(46, "We will talk by candle fire")
        ]),
        Track(id: "t07", title: "Tea Stall Confessions", artist: "Arif Chowdhury", albumID: "golden-hour-static", duration: 48, audioFile: "track07", lyrics: [
            L(2, "Two cups sweating on a plastic table"),
            L(6, "You told me everything at last"),
            L(10, "The stall keeper pretended not to listen"),
            L(14, "Polishing a foggy glass"),
            L(18, "Tea stall confessions, steam and sugar"),
            L(22, "Truth comes cheap at half past nine"),
            L(26, "Every secret tastes a little sweeter"),
            L(30, "When the tea is strong as wine"),
            L(34, "Biscuits softening in the saucer"),
            L(38, "Rain deciding not to fall"),
            L(42, "You said some things you can only say"),
            L(46, "To a stranger, after all")
        ]),
        Track(id: "t08", title: "Rooftop Kites", artist: "Arif Chowdhury", albumID: "golden-hour-static", duration: 48, audioFile: "track08", lyrics: [
            L(2, "Paper diamonds over the rooftops"),
            L(6, "String cutting through the blue"),
            L(10, "Every kid on every building"),
            L(14, "Was flying something true"),
            L(18, "Rooftop kites, climb for me"),
            L(22, "Higher than the water tanks"),
            L(26, "Freedom is a length of string"),
            L(30, "And a wind that gives no thanks"),
            L(34, "When the string finally breaks"),
            L(38, "Nobody calls it a fall"),
            L(42, "Somewhere over the next para"),
            L(46, "It belongs to no one at all")
        ]),
        Track(id: "t09", title: "August Postcard", artist: "Arif Chowdhury", albumID: "golden-hour-static", duration: 48, audioFile: "track09", lyrics: [
            L(2, "I bought a postcard I will never send"),
            L(6, "Of a river in the rain"),
            L(10, "August makes the whole world softer"),
            L(14, "And heavier with grain"),
            L(18, "August postcard, unsigned"),
            L(22, "Sitting in a drawer somewhere"),
            L(26, "Some words only work unsent"),
            L(30, "Some love only lives in air"),
            L(34, "The stamp is from another decade"),
            L(38, "The ink has learned to fade"),
            L(42, "If you ever find it, read it slow"),
            L(46, "It says more than I ever said")
        ]),
        Track(id: "t10", title: "Origami Hearts", artist: "Mira Sen", albumID: "paper-boats", duration: 48, audioFile: "track10", lyrics: [
            L(2, "You folded every napkin in the cafe"),
            L(6, "Into something with wings"),
            L(10, "A hundred paper hearts on the table"),
            L(14, "And other fragile things"),
            L(18, "Origami hearts, hold the fold"),
            L(22, "Crease by crease, line by line"),
            L(26, "Love is just a patient paper"),
            L(30, "Waiting for a sign"),
            L(34, "One of them is in my notebook"),
            L(38, "Pressed between the pages still"),
            L(42, "Unfold it and the words are yours"),
            L(46, "Fold it back, they always will")
        ]),
        Track(id: "t11", title: "Slow River", artist: "Mira Sen", albumID: "paper-boats", duration: 48, audioFile: "track11", lyrics: [
            L(2, "The boatman rows like time is water"),
            L(6, "And we have all afternoon"),
            L(10, "Reeds are whispering on both banks"),
            L(14, "Under a lazy moon"),
            L(18, "Slow river, take your time"),
            L(22, "We are in no hurry now"),
            L(26, "Every bend is a new beginning"),
            L(30, "Every ripple shows us how"),
            L(34, "Dragonflies over the shallows"),
            L(38, "A heron standing still"),
            L(42, "The world can keep its deadlines"),
            L(46, "We have a moon to kill")
        ]),
        Track(id: "t12", title: "Lantern Season", artist: "Mira Sen", albumID: "paper-boats", duration: 48, audioFile: "track12", lyrics: [
            L(2, "Paper lanterns in the market lane"),
            L(6, "Turning dusk to gold"),
            L(10, "You picked the one with the crooked seam"),
            L(14, "Said perfect is too cold"),
            L(18, "Lantern season, light the way"),
            L(22, "Through the last weeks of the year"),
            L(26, "Every flame is a small rebellion"),
            L(30, "Against the dark out here"),
            L(34, "When the wind comes off the river"),
            L(38, "Hold your lantern low"),
            L(42, "Some lights only survive"),
            L(46, "Because somebody shields the glow")
        ])
    ]

    static let mixes: [Mix] = [
        Mix(
            id: "dhaka-nights-mix",
            title: "Dhaka Nights Mix",
            subtitle: "Late-night city songs",
            trackIDs: ["t01", "t02", "t03", "t11", "t12"],
            heroAlbumID: "midnight-dhaka",
            colors: [Color(red: 0.08, green: 0.05, blue: 0.30), Color(red: 0.30, green: 0.12, blue: 0.52), Color(red: 0.55, green: 0.20, blue: 0.62)]
        ),
        Mix(
            id: "monsoon-focus-mix",
            title: "Monsoon Focus Mix",
            subtitle: "Rainy-day concentration",
            trackIDs: ["t04", "t05", "t06", "t09", "t08"],
            heroAlbumID: "neon-monsoon",
            colors: [Color(red: 0.02, green: 0.14, blue: 0.30), Color(red: 0.03, green: 0.32, blue: 0.45), Color(red: 0.06, green: 0.52, blue: 0.55)]
        )
    ]

    static func album(id: String) -> Album {
        albums.first { $0.id == id } ?? albums[0]
    }

    static func album(for track: Track) -> Album {
        album(id: track.albumID)
    }
}
