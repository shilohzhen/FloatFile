import AppKit
import SwiftUI

class FloatingPanel: NSPanel {
    private let visualEffectView = NSVisualEffectView()
    private let backgroundLayerView = BackgroundImageLayerView()

    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 520),
            styleMask: [.titled, .resizable, .closable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.title = "FloatFile"
        self.titlebarAppearsTransparent = false
        self.isFloatingPanel = true
        self.level = .floating
        self.hidesOnDeactivate = false
        self.isMovableByWindowBackground = false
        self.isRestorable = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isOpaque = false
        self.hasShadow = true
        self.animationBehavior = .utilityWindow

        self.minSize = NSSize(width: 280, height: 300)
        self.maxSize = NSSize(width: 600, height: 800)

        setFrameAutosaveName("FloatFilePanel")

        setupBackgroundLayers(contentView: contentView)
        applySettings()
    }

    private func setupBackgroundLayers(contentView: NSView) {
        guard let existingContentView = self.contentView else { return }

        // Visual effect (blur)
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.frame = existingContentView.bounds
        visualEffectView.autoresizingMask = [.width, .height]
        existingContentView.addSubview(visualEffectView, positioned: .below, relativeTo: nil)

        // Background image layer (aspect fill)
        backgroundLayerView.frame = existingContentView.bounds
        backgroundLayerView.autoresizingMask = [.width, .height]
        existingContentView.addSubview(backgroundLayerView, positioned: .below, relativeTo: nil)

        // Content on top
        existingContentView.addSubview(contentView)
        contentView.frame = existingContentView.bounds
        contentView.autoresizingMask = [.width, .height]
    }

    func applySettings() {
        let settings = AppSettings.shared
        let opacity = max(0.1, min(1.0, settings.panelOpacity))

        // Reset all
        visualEffectView.isHidden = true
        backgroundLayerView.isHidden = true
        self.backgroundColor = .clear

        switch settings.backgroundStyle {
        case .system:
            visualEffectView.isHidden = false
            visualEffectView.alphaValue = CGFloat(opacity)

        case .solid:
            let nsBg = NSColor(settings.bgColor)
            self.backgroundColor = nsBg.withAlphaComponent(CGFloat(opacity))

        case .image:
            if let img = settings.bgImage {
                backgroundLayerView.setImage(img)
                backgroundLayerView.isHidden = false
                backgroundLayerView.alphaValue = CGFloat(opacity)
            } else {
                visualEffectView.isHidden = false
                visualEffectView.alphaValue = CGFloat(opacity)
            }

        case .transparent:
            break
        }
    }
}

// MARK: - Background Image Layer View (aspectFill)
class BackgroundImageLayerView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.contentsGravity = .resizeAspectFill
        layer?.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setImage(_ image: NSImage) {
        layer?.contents = image
    }
}
