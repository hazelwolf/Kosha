import SwiftUI
#if os(macOS)
import LocalModelJobs
import LocalModelMLX
#endif

struct ChatLine: Identifiable {
    enum Speaker { case reader, librarian }
    let id = UUID()
    let speaker: Speaker
    var text: String
}

@MainActor
@Observable
final class LibrarianModel {
    var lines: [ChatLine] = []
    var status = ""
    var isWorking = false
    var errorMessage: String?

    #if os(macOS)
    private static let instructions = """
    You are the librarian-barista of Kosha, a warm personal library café. Help the reader \
    understand what they are studying. Answer clearly and briefly, in plain language, with one concrete \
    example when it helps. If you are unsure of something, say so.
    """

    /// Shared so the model stays loaded when the librarian sheet is closed and reopened.
    private static let queue = ModelJobQueue(
        backend: MLXTextBackend(location: .huggingFaceCache(repo: "mlx-community/Qwen3-8B-4bit")))

    private let conversationID = UUID().uuidString
    private var currentJob: UUID?

    func ask(_ question: String) {
        lines.append(ChatLine(speaker: .reader, text: question))
        let reply = ChatLine(speaker: .librarian, text: "")
        lines.append(reply)
        errorMessage = nil
        isWorking = true
        status = "Warming up the librarian…"
        Task {
            let job = await Self.queue.submit(
                TextRequest(prompt: question, instructions: Self.instructions, conversationID: conversationID))
            currentJob = job.id
            for await event in job.events {
                switch event {
                case .text(let text):
                    status = "Writing…"
                    if let index = lines.firstIndex(where: { $0.id == reply.id }) { lines[index].text += text }
                case .failed(let message):
                    errorMessage = message
                default:
                    break
                }
            }
            lines.removeAll { $0.id == reply.id && $0.text.isEmpty }
            currentJob = nil
            isWorking = false
            status = ""
        }
    }

    func stop() {
        guard let currentJob else { return }
        Task { await Self.queue.cancel(currentJob) }
    }
    #endif
}

struct LibrarianView: View {
    @State private var model = LibrarianModel()
    @State private var draft = ""
    @FocusState private var inputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("The Librarian")
                        .font(.system(size: 28, weight: .medium, design: .serif))
                    Text(subtitle)
                        .font(.system(size: 14, design: .serif))
                        .foregroundStyle(Theme.walnutLight)
                }
                Spacer()
                Button("Close") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
            .padding(24)

            Rectangle().fill(Theme.walnutLight.opacity(0.35)).frame(height: 1)

            #if os(macOS)
            conversation
            composer
            #else
            ContentUnavailableView("The librarian works on your Mac",
                                   systemImage: "macbook",
                                   description: Text("Open Kosha on your Mac to ask questions with its local AI."))
                .frame(maxHeight: .infinity)
            #endif
        }
        .foregroundStyle(Theme.ink)
        .frame(minWidth: 620, idealWidth: 720, minHeight: 560, idealHeight: 680)
        .background(Theme.paper)
        .environment(\.colorScheme, .light)
    }

    private var subtitle: String {
        #if os(macOS)
        "Runs privately on this Mac with MLX"
        #else
        "Available on your Mac"
        #endif
    }

    #if os(macOS)
    private var conversation: some View {
        ScrollViewReader { reader in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if model.lines.isEmpty {
                        Text("What are you curious about this evening?")
                            .font(.system(size: 22, design: .serif))
                            .foregroundStyle(Theme.ink.opacity(0.7))
                            .padding(.top, 24)
                    }
                    ForEach(model.lines) { line in
                        Text(line.text)
                            .font(.system(size: 17, design: .serif))
                            .lineSpacing(4)
                            .textSelection(.enabled)
                            .padding(line.speaker == .reader ? 12 : 0)
                            .background(line.speaker == .reader ? Theme.brass.opacity(0.28) : .clear,
                                        in: RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity,
                                   alignment: line.speaker == .reader ? .trailing : .leading)
                            .id(line.id)
                    }
                    if let error = model.errorMessage {
                        Text(error)
                            .font(.system(size: 15, design: .serif))
                            .foregroundStyle(Color(red: 0.55, green: 0.13, blue: 0.09))
                    }
                }
                .padding(24)
            }
            .onChange(of: model.lines.last?.text) {
                if let id = model.lines.last?.id { reader.scrollTo(id, anchor: .bottom) }
            }
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !model.status.isEmpty {
                Text(model.status)
                    .font(.system(size: 13, design: .serif))
                    .foregroundStyle(Theme.walnutLight)
            }
            HStack(spacing: 10) {
                TextField("Ask about anything on the shelves", text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16, design: .serif))
                    .lineLimit(1...4)
                    .focused($inputFocused)
                    .onSubmit(send)
                if model.isWorking {
                    Button("Stop", action: model.stop)
                } else {
                    Button("Ask", action: send)
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.walnut)
                        .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .controlSize(.large)
        }
        .padding(20)
        .onAppear {
            inputFocused = true
            #if DEBUG
            if let question = ProcessInfo.processInfo.environment["KOSHA_AUTOASK"] { model.ask(question) }
            #endif
        }
    }

    private func send() {
        let question = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !model.isWorking else { return }
        draft = ""
        model.ask(question)
    }
    #endif
}
