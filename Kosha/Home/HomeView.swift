import SwiftUI

enum Theme {
    static let paper = Color(red: 0.96, green: 0.90, blue: 0.78)
    static let brass = Color(red: 0.88, green: 0.70, blue: 0.40)
    static let ink = Color(red: 0.11, green: 0.07, blue: 0.05)
    static let walnut = Color(red: 0.22, green: 0.12, blue: 0.07)
    static let walnutLight = Color(red: 0.40, green: 0.23, blue: 0.12)
}

struct HomeView: View {
    @State private var wing = KnowledgeLibrary.wings[0]
    @State private var liftedID: Topic.ID?
    @State private var openBook: Topic?
    @State private var showLibrarian = false
    @State private var tilt = CGSize.zero
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 900
            ZStack(alignment: .bottom) {
                scene(in: proxy.size)
                LinearGradient(colors: [.black.opacity(0.55), .clear, .clear, .black.opacity(0.72)],
                               startPoint: .top, endPoint: .bottom)
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    header(compact: compact)
                    Spacer(minLength: 8)
                    wingPicker
                    bookshelf
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                guard !reduceMotion else { return }
                if case .active(let point) = phase {
                    withAnimation(.easeOut(duration: 0.5)) {
                        tilt = CGSize(width: point.x / proxy.size.width - 0.5,
                                      height: point.y / proxy.size.height - 0.5)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .background(Theme.ink)
        .sheet(item: $openBook) { topic in
            OpenBookView(topic: topic) {
                openBook = nil
                showLibrarian = true
            }
        }
        .sheet(isPresented: $showLibrarian) {
            LibrarianView()
        }
        #if DEBUG
        .onAppear(perform: openDebugDestination)
        #endif
    }

    #if DEBUG
    /// Lets automated checks open a screen: KOSHA_DEBUG_OPEN=librarian, or a topic title.
    private func openDebugDestination() {
        guard let target = ProcessInfo.processInfo.environment["KOSHA_DEBUG_OPEN"] else { return }
        if target == "librarian" {
            showLibrarian = true
        } else {
            openBook = KnowledgeLibrary.wings.flatMap(\.topics).first { $0.title == target }
        }
    }
    #endif

    /// Aspect-fills the painting with a small overscan, so pointer parallax never shows an edge.
    private func scene(in size: CGSize) -> some View {
        let art = CGSize(width: 2048, height: 1152)
        let scale = max(size.width / art.width, size.height / art.height) * 1.04
        let fitted = CGSize(width: art.width * scale, height: art.height * scale)
        return ZStack {
            Image("CafeScene")
                .resizable()
                .frame(width: fitted.width, height: fitted.height)
                .accessibilityLabel("A warm library café on a rainy evening")
            CafeAtmosphere(size: fitted)
        }
        .offset(x: -tilt.width * size.width * 0.03, y: -tilt.height * size.height * 0.02)
        .frame(width: size.width, height: size.height)
    }

    private func header(compact: Bool) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Kosha")
                    .font(.system(size: compact ? 34 : 46, weight: .medium, design: .serif))
                    .foregroundStyle(Theme.paper)
                Text("कोश  ·  Vidyopārjita, knowledge acquired by learning")
                    .font(.system(size: compact ? 14 : 16, design: .serif))
                    .foregroundStyle(Theme.brass)
            }
            .shadow(color: .black.opacity(0.75), radius: 10, y: 2)

            Spacer()

            Button {
                showLibrarian = true
            } label: {
                Label("Ask the librarian", systemImage: "cup.and.saucer.fill")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 44)
                    .background(Theme.brass, in: Capsule())
                    .shadow(color: .black.opacity(0.45), radius: 8, y: 3)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("l", modifiers: .command)
        }
        .padding(.horizontal, 32)
        .padding(.top, 34)
    }

    private var wingPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(KnowledgeLibrary.wings) { item in
                    let selected = item.id == wing.id
                    Button {
                        withAnimation(.snappy(duration: 0.3)) {
                            wing = item
                            liftedID = nil
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: item.symbol)
                            Text(item.name)
                            Text("\(item.topics.count)")
                                .monospacedDigit()
                                .opacity(0.7)
                        }
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(selected ? Theme.ink : Theme.paper)
                        .padding(.horizontal, 15)
                        .frame(minHeight: 44)
                        .background(selected ? AnyShapeStyle(Theme.paper) : AnyShapeStyle(Theme.ink.opacity(0.74)),
                                    in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 12)
    }

    private var bookshelf: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .bottom, spacing: 3) {
                    ForEach(wing.shelves) { shelf in
                        ShelfMarker(name: shelf.name, tint: wing.tint)
                        ForEach(shelf.topics) { topic in
                            BookSpine(topic: topic, isLifted: liftedID == topic.id) { hovering in
                                if hovering {
                                    liftedID = topic.id
                                } else if liftedID == topic.id {
                                    liftedID = nil
                                }
                            } onActivate: {
                                activate(topic)
                            }
                        }
                        Color.clear.frame(width: 18, height: 1)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 50)
            }
            .frame(height: 276)
            .id(wing.id)

            ledge
        }
    }

    /// Hover already lifted the book on a Mac, so one click opens it. On touch, the first tap lifts it.
    private func activate(_ topic: Topic) {
        #if os(macOS)
        openBook = topic
        #else
        if liftedID == topic.id {
            openBook = topic
        } else {
            liftedID = topic.id
        }
        #endif
    }

    private var ledge: some View {
        LinearGradient(colors: [Theme.walnutLight, Theme.walnut, Theme.ink],
                       startPoint: .top, endPoint: .bottom)
            .frame(height: 34)
            .overlay(alignment: .top) {
                Rectangle().fill(Theme.brass.opacity(0.55)).frame(height: 1)
            }
            .shadow(color: .black.opacity(0.6), radius: 12, y: -4)
    }
}

/// A small brass label standing between groups of books.
private struct ShelfMarker: View {
    let name: String
    let tint: Color

    var body: some View {
        Text(name.uppercased())
            .font(.system(size: 12, weight: .bold, design: .serif))
            .tracking(1.2)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(Theme.brass, in: RoundedRectangle(cornerRadius: 3))
            .fixedSize()
            .rotationEffect(.degrees(-90))
            .frame(width: 30, height: 190)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    HomeView()
}
