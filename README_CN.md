# FloatFile

一款适用于 macOS 的浮动文件管理器，始终置于所有窗口之上——特别适合在使用“台前调度”（Stage Manager）功能时，将文件拖拽至各类 AI 应用（如 Claude、Gemini 等）中。

![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 痛点

macOS 的“台前调度”（Stage Manager）功能会将窗口归类到不同的“舞台”（Stages）中。当你需要从 Finder 拖拽文件至 Claude 或 Gemini 等 AI 应用时，这两个窗口必须处于同一个“舞台”下——这意味着每次操作都需要进行额外的点击切换。

## 解决方案

FloatFile 是一个轻量级的面板，它始终浮动在所有窗口之上，且跨越所有“舞台”可见。只需按下快捷键即可将其唤出，浏览你的文件，并即刻将其拖拽至任何应用程序中。

## 功能特性

- **始终置顶** — 在“台前调度”的各个“舞台”之间保持可见
- **全局快捷键** — 默认为 `⌘⇧F`，且完全支持自定义设置
- **拖放操作** — 可将文件直接拖拽至任何应用程序中
- **图像预览** — 可直接显示图像文件的缩略图预览
- **列表与图标视图** — 可在紧凑的列表视图与网格布局之间切换
- **自定义背景** — 支持模糊效果、纯色填充或使用自定义图片作为背景
- **透明度调节** — 支持 10% 至 100% 之间的透明度调节
- **默认文件夹** — 可将任意目录设置为应用的起始位置
- **位置记忆** — 自动记住面板上次关闭时的位置
- **菜单栏应用** — 不在 Dock 栏显示图标，仅在菜单栏显示一个小图标

## 系统要求

- macOS 13.0 Ventura 或更高版本（“台前调度”功能始于 Ventura 版本）

## 安装方法

### 下载 DMG 文件

请前往 [Releases](../../releases) 页面下载 `FloatFile.dmg` 文件，打开该文件，并将 FloatFile 拖拽至“应用程序”（Applications）文件夹中。

> **首次启动提示**：请右键点击应用图标，然后选择“打开”（此为针对未签名应用的通用启动方法）。 ### 从源代码构建

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/FloatFile.git
cd FloatFile

# 生成 Xcode 项目（需安装 xcodegen）
brew install xcodegen
xcodegen generate

# 构建
xcodebuild -scheme FloatFile -configuration Release build

# 或者使用构建脚本来生成 DMG 镜像
bash build.sh
```

## 使用方法

1. 点击菜单栏中的文件夹图标，或按下 `⌘⇧F` 快捷键
2. 利用侧边栏的快速访问功能浏览文件，或手动导航至指定文件夹
3. 将任意文件图标拖拽至其他应用程序中
4. 单击以选中文件，双击以打开文件夹

## 自定义设置

从侧边栏打开 **设置** (Settings)：

| 设置项 | 描述 |
|---------|-------------|
| 默认文件夹 | 选择默认打开的目录 |
| 不透明度 | 调整面板的透明度（10%–100%） |
| 背景样式 | 模糊 / 纯色 / 图片 / 透明 |
| 显示模式 | 列表视图或图标网格视图 |
| 全局快捷键 | 录制任意按键组合作为快捷键 | ## 技术栈

- **SwiftUI** — 声明式 UI
- **AppKit** — 浮动面板（使用 `.floating` 窗口层级的 `NSPanel`）
- **Carbon HIToolbox** — 全局快捷键注册
- **NSItemProvider** — 原生拖放功能

## 项目结构

```
FloatFile/
├── Sources/FloatFile/
│   ├── FloatFileApp.swift           # App 入口点
│   ├── Panel/
│   │   ├── FloatingPanel.swift      # NSPanel 子类
│   │   ├── PanelManager.swift       # 面板生命周期管理
│   │   └── HotKeyManager.swift      # 全局快捷键管理
│   ├── Models/
│   │   ├── FileItem.swift           # 文件数据模型
│   │   └── AppSettings.swift        # 用户偏好设置
│   ├── ViewModels/
│   │   └── FileBrowserViewModel.swift
│   ├── Views/
│   │   ├── FileBrowserView.swift    # 主视图
│   │   ├── FileRowView.swift        # 文件行视图与图标网格视图
│   │   ├── SidebarView.swift        # 快速访问侧边栏
│   │   ├── BreadcrumbView.swift     # 路径导航视图
│   │   └── SettingsView.swift       # 设置面板视图
│   └── DragDrop/
│       └── FileDragProvider.swift    # 拖拽支持
├── project.yml                      # xcodegen 配置文件
├── build.sh                         # 构建与打包脚本
└── generate_icon.swift              # App 图标生成脚本
```

## 许可证

MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

## 贡献

欢迎贡献代码！欢迎随时提交 Issue 或 Pull Request。

---

使用 Swift 语言开发，并在大量拖拽文件的实践中不断完善。
