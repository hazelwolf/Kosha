import Foundation
import NoteKit
import NoteKitUI
import SwiftUI

enum KoshaNotes {
    static let store = MarkdownNoteStore(
        directory: URL.applicationSupportDirectory.appending(path: "Kosha/Notes"))
}

/// A book taken off the shelf, with the reader's own notes for this topic.
struct OpenBookView: View {
    let topic: Topic
    let askLibrarian: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text(topic.shelf.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .tracking(1.4)
                    .foregroundStyle(Theme.walnutLight)
                Spacer()
                Button("Back to the shelf") { dismiss() }
                    .tint(Theme.walnut)
                    .keyboardShortcut(.cancelAction)
            }

            Text(topic.title)
                .font(.system(size: 42, weight: .medium, design: .serif))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle().fill(Theme.walnutLight.opacity(0.4)).frame(height: 1)

            Text(topic.state.label)
                .font(.system(size: 19, design: .serif))
                .foregroundStyle(Theme.ink.opacity(0.82))

            NotesPanel(
                store: KoshaNotes.store,
                anchor: "topic:\(topic.id)",
                style: NotesPanelStyle(
                    text: Theme.ink,
                    secondaryText: Theme.walnutLight,
                    fieldBackground: .white.opacity(0.45),
                    accent: Theme.walnut,
                    fontDesign: .serif))

            HStack(spacing: 12) {
                Button(action: askLibrarian) {
                    Label("Ask the librarian", systemImage: "cup.and.saucer.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.walnut)

                if let url = topic.notionURL {
                    Link(destination: url) {
                        Label("Open notes in Notion", systemImage: "arrow.up.right")
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.walnut)
                }
            }
            .controlSize(.large)
        }
        .padding(32)
        .frame(minWidth: 620, idealWidth: 760, minHeight: 640, idealHeight: 760)
        .background(Theme.paper)
        .environment(\.colorScheme, .light)
    }
}
