import SwiftUI

struct LyricsView: View {
    let track: Track
    @EnvironmentObject var engine: PlayerEngine

    private var activeIndex: Int {
        var index = 0
        for (i, line) in track.lyrics.enumerated() {
            if engine.currentTime >= line.time {
                index = i
            } else {
                break
            }
        }
        return index
    }

    private func style(for index: Int) -> (font: Font, color: Color) {
        let tint = Catalog.album(for: track).tint
        let distance = abs(index - activeIndex)
        switch distance {
        case 0:
            return (.system(size: 27, weight: .bold), tint)
        case 1:
            return (.system(size: 24, weight: .semibold), Color.white.opacity(0.78))
        case 2:
            return (.system(size: 24, weight: .semibold), Color.white.opacity(0.52))
        default:
            return (.system(size: 24, weight: .semibold), Color.white.opacity(0.30))
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ArtworkView(album: Catalog.album(for: track), size: 46)
                .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 3)
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if track.lyrics.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)
                    Text("No lyrics for this one yet.")
                        .font(.headline)
                    Text("Enjoy the instrumental break.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                lyricsList
            }
        }
    }

    private var lyricsList: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(track.lyrics.enumerated()), id: \.element.id) { index, line in
                        let s = style(for: index)
                        Text(line.text)
                            .font(s.font)
                            .foregroundStyle(s.color)
                            .fixedSize(horizontal: false, vertical: true)
                            .id(line.id)
                            .onTapGesture {
                                engine.seek(to: line.time + 0.05)
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.top, 36)
                .padding(.bottom, 120)
            }
            .mask(
                LinearGradient(
                    colors: [Color.clear, Color.black, Color.black, Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onChange(of: activeIndex) { _, newIndex in
                guard track.lyrics.indices.contains(newIndex) else { return }
                withAnimation(.easeInOut(duration: 0.45)) {
                    proxy.scrollTo(track.lyrics[newIndex].id, anchor: .center)
                }
            }
            .onAppear {
                guard track.lyrics.indices.contains(activeIndex) else { return }
                proxy.scrollTo(track.lyrics[activeIndex].id, anchor: .center)
            }
        }
    }
}
