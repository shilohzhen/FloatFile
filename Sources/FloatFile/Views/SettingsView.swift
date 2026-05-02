import SwiftUI
import Carbon.HIToolbox

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    @State private var isRecordingHotkey = false
    @State private var eventMonitor: Any?
    @State private var recordedModifiers: NSEvent.ModifierFlags?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.headline)

            Divider()

            // Default folder
            VStack(alignment: .leading, spacing: 4) {
                Text("Default Folder")
                    .font(.system(size: 12))

                HStack(spacing: 4) {
                    Text(displayPath)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button("Choose...") {
                        pickDefaultFolder()
                    }
                    .font(.system(size: 10))
                    .buttonStyle(.bordered)

                    Button("Reset") {
                        settings.defaultFolderPath = ""
                    }
                    .font(.system(size: 10))
                    .buttonStyle(.bordered)
                }
            }

            Divider()

            // Opacity
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Opacity")
                        .font(.system(size: 12))
                    Spacer()
                    Text("\(Int(settings.panelOpacity * 100))%")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }

                Slider(value: $settings.panelOpacity, in: 0.1...1.0, step: 0.05) {
                    Text("Opacity")
                }
                .onChange(of: settings.panelOpacity) { _ in
                    PanelManager.shared.updateAppearance()
                }
            }

            Divider()

            // Background style
            VStack(alignment: .leading, spacing: 6) {
                Text("Background")
                    .font(.system(size: 12))

                // Style selector
                HStack(spacing: 0) {
                    bgStyleButton("Blur", .system)
                    bgStyleButton("Color", .solid)
                    bgStyleButton("Image", .image)
                    bgStyleButton("Clear", .transparent)
                }
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(5)

                // Color picker (when solid)
                if settings.backgroundStyle == .solid {
                    ColorPicker("Panel Color", selection: $settings.bgColor)
                        .font(.system(size: 11))
                        .onChange(of: settings.bgColor) { _ in
                            PanelManager.shared.updateAppearance()
                        }
                }

                // Image picker (when image)
                if settings.backgroundStyle == .image {
                    HStack(spacing: 4) {
                        Text(settings.bgImageDisplayName)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        Button("Choose...") {
                            pickBackgroundImage()
                        }
                        .font(.system(size: 10))
                        .buttonStyle(.bordered)

                        if !settings.bgImagePath.isEmpty {
                            Button("Remove") {
                                settings.bgImagePath = ""
                                PanelManager.shared.updateAppearance()
                            }
                            .font(.system(size: 10))
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }

            Divider()

            // Display mode
            VStack(alignment: .leading, spacing: 4) {
                Text("Display Mode")
                    .font(.system(size: 12))

                Picker("", selection: $settings.displayMode) {
                    Label("List", systemImage: "list.bullet").tag(DisplayMode.list)
                    Label("Icons", systemImage: "square.grid.2x2").tag(DisplayMode.icons)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Divider()

            // Hotkey
            VStack(alignment: .leading, spacing: 4) {
                Text("Global Shortcut")
                    .font(.system(size: 12))

                HStack {
                    Text(hotkeyDisplayString)
                        .font(.system(size: 13, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(isRecordingHotkey ? Color.red.opacity(0.15) : Color.clear)
                        .background(.quaternary)
                        .cornerRadius(4)

                    Button(isRecordingHotkey ? "Recording..." : "Record") {
                        toggleRecording()
                    }
                    .font(.system(size: 11))
                    .buttonStyle(.bordered)
                    .tint(isRecordingHotkey ? .red : .accentColor)
                }

                if isRecordingHotkey {
                    Text("Press a key combination (e.g. ⌘⇧F)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            HStack {
                Spacer()
                Button("Done") {
                    NotificationCenter.default.post(name: .closeSettings, object: nil)
                }
                .buttonStyle(.borderedProminent)
                .font(.system(size: 12))
            }
        }
        .padding(14)
        .frame(width: 280)
        .onDisappear {
            stopRecording()
        }
    }

    // MARK: - Background Style Button
    private func bgStyleButton(_ label: String, _ style: BackgroundStyle) -> some View {
        Button {
            settings.backgroundStyle = style
            PanelManager.shared.updateAppearance()
        } label: {
            Text(label)
                .font(.system(size: 10))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(settings.backgroundStyle == style ? Color.accentColor : Color.clear)
                .foregroundColor(settings.backgroundStyle == style ? .white : .primary)
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pickers
    private var displayPath: String {
        if settings.defaultFolderPath.isEmpty {
            return "~/ (Home)"
        }
        return settings.defaultFolderPath.replacingOccurrences(
            of: FileManager.default.homeDirectoryForCurrentUser.path,
            with: "~"
        )
    }

    private func pickDefaultFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose default folder to open"

        if panel.runModal() == .OK, let url = panel.url {
            settings.defaultFolderPath = url.path
        }
    }

    private func pickBackgroundImage() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.image]
        panel.message = "Choose background image"

        if panel.runModal() == .OK, let url = panel.url {
            settings.bgImagePath = url.path
            PanelManager.shared.updateAppearance()
        }
    }

    // MARK: - Hotkey
    private var hotkeyDisplayString: String {
        if isRecordingHotkey {
            if let mods = recordedModifiers, !mods.isEmpty {
                return modString(mods) + "..."
            }
            return "Press keys..."
        }
        return settings.modifierDisplay + settings.keyDisplay
    }

    private func modString(_ flags: NSEvent.ModifierFlags) -> String {
        var parts: [String] = []
        if flags.contains(.command) { parts.append("⌘") }
        if flags.contains(.option) { parts.append("⌥") }
        if flags.contains(.control) { parts.append("⌃") }
        if flags.contains(.shift) { parts.append("⇧") }
        return parts.joined()
    }

    private func toggleRecording() {
        if isRecordingHotkey {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecordingHotkey = true
        recordedModifiers = nil

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            if event.type == .flagsChanged {
                if !flags.isEmpty {
                    recordedModifiers = flags
                }
                return nil
            }

            if event.type == .keyDown {
                let keyCode = Int(event.keyCode)
                let modifierKeyCodes: Set<Int> = [54, 55, 56, 57, 58, 59, 62, 63]
                if modifierKeyCodes.contains(keyCode) {
                    return nil
                }

                if !flags.isEmpty {
                    AppSettings.shared.hotkeyKeyCode = keyCode
                    AppSettings.shared.hotkeyModifiers = Int(flags.rawValue)
                    HotKeyManager.shared.register()
                    stopRecording()
                }
                return nil
            }

            return event
        }
    }

    private func stopRecording() {
        isRecordingHotkey = false
        recordedModifiers = nil
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
}

extension Notification.Name {
    static let closeSettings = Notification.Name("closeSettings")
}
