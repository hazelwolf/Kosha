import SwiftUI

@main
struct KoshaApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.dark)
        }
        #if os(macOS)
        .defaultSize(width: 1440, height: 860)
        .windowStyle(.hiddenTitleBar)
        #endif
    }
}
