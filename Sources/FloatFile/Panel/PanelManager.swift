import AppKit
import SwiftUI

class PanelManager {
    static let shared = PanelManager()

    private var panel: FloatingPanel?
    private var isPanelVisible: Bool { panel?.isVisible ?? false }
    private let autosaveName = "FloatFilePanel"

    private init() {}

    func togglePanel() {
        if isPanelVisible {
            closePanel()
        } else {
            showPanel()
        }
    }

    func showPanel() {
        if let panel = panel {
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let viewModel = FileBrowserViewModel()
        let rootView = FileBrowserView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 380, height: 520)

        let newPanel = FloatingPanel(contentView: hostingView)

        // Restore saved frame, or center if first launch
        let savedFrame = UserDefaults.standard.string(forKey: "NSWindow Frame \(autosaveName)")
        if savedFrame != nil {
            // setFrameAutosaveName already restored the frame
        } else {
            newPanel.center()
        }

        newPanel.makeKeyAndOrderFront(nil)
        panel = newPanel
    }

    func closePanel() {
        panel?.close()
        panel = nil
    }

    func updateAppearance() {
        panel?.applySettings()
    }
}
