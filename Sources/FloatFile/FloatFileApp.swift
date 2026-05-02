import SwiftUI

@main
struct FloatFileApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
        } label: {
            Image(systemName: "folder.fill")
        }
        .menuBarExtraStyle(.menu)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        HotKeyManager.shared.register()
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregister()
    }
}

struct MenuBarView: View {
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        Button("Show FloatFile (\(settings.modifierDisplay)\(settings.keyDisplay))") {
            PanelManager.shared.togglePanel()
        }

        Divider()

        Button("Quit") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
