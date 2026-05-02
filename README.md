# FloatFile

A floating file manager for macOS that stays on top of all windows — perfect for dragging files to AI apps (Claude, Gemini, etc.) when using Stage Manager.

![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## The Problem

macOS Stage Manager groups windows into "stages." When you need to drag a file from Finder to an AI app like Claude or Gemini, both windows must be in the same stage — which means extra clicks every time.

## The Solution

FloatFile is a lightweight panel that floats above all windows, across all stages. Open it with a hotkey, browse your files, and drag them to any app instantly.

## Features

- **Always on top** — stays visible across all Stage Manager stages
- **Global hotkey** — default `⌘⇧F`, fully customizable
- **Drag & drop** — drag files directly to any application
- **Image previews** — see actual thumbnails for image files
- **List & icon views** — switch between compact list and grid layout
- **Customizable background** — blur, solid color, or your own image
- **Adjustable opacity** — from 10% to 100%
- **Default folder** — set any directory as your start location
- **Position memory** — remembers where you left the panel
- **Menu bar app** — no Dock icon, just a small menu bar icon

## Requirements

- macOS 13.0 Ventura or later (Stage Manager introduced in Ventura)

## Installation

### Download DMG

Download `FloatFile.dmg` from [Releases](../../releases), open it, and drag FloatFile to Applications.

> **First launch**: Right-click the app and select "Open" (unsigned app workaround).

### Build from Source

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/FloatFile.git
cd FloatFile

# Generate Xcode project (requires xcodegen)
brew install xcodegen
xcodegen generate

# Build
xcodebuild -scheme FloatFile -configuration Release build

# Or use the build script to create a DMG
bash build.sh
```

## Usage

1. Click the folder icon in the menu bar, or press `⌘⇧F`
2. Browse files using the sidebar quick access or navigate folders
3. Drag any file icon to another app
4. Single-click to select, double-click to open folders

## Customization

Open **Settings** from the sidebar:

| Setting | Description |
|---------|-------------|
| Default Folder | Choose which directory opens by default |
| Opacity | Adjust panel transparency (10%–100%) |
| Background | Blur / Solid Color / Image / Clear |
| Display Mode | List view or icon grid |
| Global Shortcut | Record any key combination |

## Tech Stack

- **SwiftUI** — declarative UI
- **AppKit** — floating panel (`NSPanel` with `.floating` window level)
- **Carbon HIToolbox** — global hotkey registration
- **NSItemProvider** — native drag & drop

## Project Structure

```
FloatFile/
├── Sources/FloatFile/
│   ├── FloatFileApp.swift           # App entry point
│   ├── Panel/
│   │   ├── FloatingPanel.swift      # NSPanel subclass
│   │   ├── PanelManager.swift       # Panel lifecycle
│   │   └── HotKeyManager.swift      # Global hotkey
│   ├── Models/
│   │   ├── FileItem.swift           # File data model
│   │   └── AppSettings.swift        # User preferences
│   ├── ViewModels/
│   │   └── FileBrowserViewModel.swift
│   ├── Views/
│   │   ├── FileBrowserView.swift    # Main view
│   │   ├── FileRowView.swift        # File rows & icon grid
│   │   ├── SidebarView.swift        # Quick access sidebar
│   │   ├── BreadcrumbView.swift     # Path navigation
│   │   └── SettingsView.swift       # Settings panel
│   └── DragDrop/
│       └── FileDragProvider.swift    # Drag support
├── project.yml                      # xcodegen config
├── build.sh                         # Build & package script
└── generate_icon.swift              # App icon generator
```

## License

MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

---

Built with Swift and a lot of dragging files around.
