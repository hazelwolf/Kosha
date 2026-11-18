import SwiftUI

/// Stable, per-topic book proportions and cloth colour, derived from the Notion id.
struct BookLook {
    let width: CGFloat
    let height: CGFloat
    let cloth: Color
    let foil: Color

    private static let cloths: [Color] = [
        Color(red: 0.40, green: 0.14, blue: 0.11), Color(red: 0.15, green: 0.27, blue: 0.20),
        Color(red: 0.13, green: 0.21, blue: 0.33), Color(red: 0.46, green: 0.27, blue: 0.11),
        Color(red: 0.27, green: 0.16, blue: 0.24), Color(red: 0.51, green: 0.36, blue: 0.20),
        Color(red: 0.20, green: 0.31, blue: 0.31), Color(red: 0.31, green: 0.11, blue: 0.09),
    ]

    init(topic: Topic) {
        let hash = topic.id.utf8.reduce(UInt32(2166136261)) { ($0 ^ UInt32($1)) &* 16777619 }
        width = 46 + CGFloat(hash % 5) * 5
        height = 188 + CGFloat((hash >> 5) % 6) * 7
        cloth = topic.state == .blank
            ? Color(red: 0.70, green: 0.63, blue: 0.50)
            : Self.cloths[Int((hash >> 9) % UInt32(Self.cloths.count))]
        foil = topic.state == .blank
            ? Color(red: 0.25, green: 0.18, blue: 0.12)
            : Color(red: 0.93, green: 0.78, blue: 0.48)
    }
}

/// One topic as a book. Hover or the first tap lifts it; a click or second tap opens it.
struct BookSpine: View {
    let topic: Topic
    let isLifted: Bool
    let onHover: (Bool) -> Void
    let onActivate: () -> Void

    private var look: BookLook { BookLook(topic: topic) }

    var body: some View {
        Button(action: onActivate) {
            spine
        }
        .buttonStyle(.plain)
        .frame(width: look.width, height: look.height)
        .rotation3DEffect(.degrees(isLifted ? -14 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
        .offset(y: isLifted ? -34 : 0)
        .scaleEffect(isLifted ? 1.05 : 1, anchor: .bottom)
        .shadow(color: .black.opacity(isLifted ? 0.65 : 0.35), radius: isLifted ? 16 : 3, x: 3, y: isLifted ? 12 : 1)
        .zIndex(isLifted ? 2 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.68), value: isLifted)
        .onHover(perform: onHover)
        .accessibilityLabel("\(topic.title), \(topic.shelf). \(topic.state.label).")
        .accessibilityHint("Opens this book")
    }

    private var spine: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(look.cloth)
            .overlay {
                LinearGradient(stops: [
                    .init(color: .black.opacity(0.42), location: 0),
                    .init(color: .white.opacity(0.16), location: 0.3),
                    .init(color: .clear, location: 0.58),
                    .init(color: .black.opacity(0.48), location: 1),
                ], startPoint: .leading, endPoint: .trailing)
            }
            .overlay {
                VStack {
                    band
                    Spacer()
                    band
                }
                .padding(.vertical, 12)
            }
            .overlay {
                Text(topic.title)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(look.foil)
                    .lineLimit(2)
                    .minimumScaleFactor(0.62)
                    .multilineTextAlignment(.center)
                    .frame(width: look.height - 54, height: look.width - 8)
                    .fixedSize()
                    .rotationEffect(.degrees(-90))
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .frame(width: look.width, height: look.height)
    }

    private var band: some View {
        VStack(spacing: 2) {
            Rectangle().frame(height: 1.5)
            Rectangle().frame(height: 0.75)
        }
        .foregroundStyle(look.foil.opacity(0.8))
    }
}
