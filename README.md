# LyricsX

[![Crowdin](https://badges.crowdin.net/lyricsx/localized.svg)](https://crowdin.com/project/lyricsx)
[![Telegram](https://img.shields.io/badge/chat-Telegram-blue.svg)](https://telegram.me/LyricsXApp)
[![codebeat badge](https://codebeat.co/badges/d4ea2fbf-89a0-4490-875f-857a1568ec16)](https://codebeat.co/projects/github-com-ddddxxx-lyricsx-master)

<img src="docs/img/icon.png" width="128px">

Ultimate lyrics app for macOS.

[LyricsX for iOS](https://github.com/ddddxxx/LyricsX-iOS) and [lyricsx-cli for Linux](https://github.com/ddddxxx/lyricsx-cli) is in early development.

## Installation

### Homebrew

```
$ brew install --cask lyricsx
```

### Mac App Store

[![download on the Mac App Store](docs/img/MAS_badge.svg)](https://itunes.apple.com/us/app/lyricsx/id1254743014?mt=12)

### Manual

Download from [releases](https://github.com/ddddxxx/LyricsX/releases).

### Requirements

- macOS 10.11+

## 关于 `adapt/xcode27-20261127` 分支（macOS 27.2 适配）

> 上游 [ddddxxx/LyricsX](https://github.com/ddddxxx/LyricsX) 已停止维护。本分支是针对 **macOS 27.2.1 / Xcode 27.2** 的个人适配版，仅用于作者及固定小范围机器，不做上架、公证与自动更新。项目业务逻辑保持原样，只做兼容适配。

### 关键改动

- **播放数据源修复（重要）**：macOS 15.4 起系统将 MediaRemote 私有框架限制为 `com.apple.*` 身份的进程，原 `SystemMedia` 通道在 15.4+ 上完全读不到 Now Playing。本分支内置 [mediaremote-adapter](https://github.com/ungive/mediaremote-adapter)（利用系统 `/usr/bin/perl` 持有的 `com.apple.perl` 身份桥接），可识别任意正在播放的音乐 App（网易云音乐、Spotify 等）。
- **依赖全部可复现化**：移除 Carthage 与所有 Git submodule 依赖；LyricsKit、TouchBarHelper、mediaremote-adapter vendor 进仓库（`Vendor/`）作为本地 SPM 包；Sparkle / AppCenter / OpenCC 以本地 API 兼容 stub 保留调用点（自动更新、崩溃上报、简繁转换当前为空实现）。
- **签名与打包**：ad-hoc 签名（无需付费开发者账号），关闭沙盒 / hardened runtime / App Group 强依赖。
- **Touch Bar**：加载后自动呈现歌词；DFRPrivate 私有 API 增加运行时探测；歌词颜色跟随桌面歌词颜色偏好，字体可通过偏好键 `TouchBarLyricsFontName` / `TouchBarLyricsFontSize` 调整。

### 构建

```bash
git clone -b adapt/xcode27-20261127 https://github.com/KylinWDS/LyricsX.git
cd LyricsX
./Scripts/package.sh
```

产物位于 `.build/package/output/LyricsX.app` 与 `.build/package/LyricsX.zip`（arm64，Apple Silicon）。

### 目标机器安装

可直接从本仓库 [Releases](https://github.com/KylinWDS/LyricsX/releases) 下载打包好的 `LyricsX.zip`，解压后拖入「应用程序」即可。首次运行如被 Gatekeeper 拦截：

```bash
xattr -dr com.apple.quarantine /Applications/LyricsX.app
```

### 已知限制

- 仅 arm64（Apple Silicon）。
- 自动更新、崩溃上报、简繁转换暂为兼容 stub。
- 逐字卡拉OK填色动画仅对带逐字时间标签的歌词生效（QQ 音乐源），逐行歌词只有整行切换。

## Features

- Work perfectly with your favorite music players. [List of supported players](https://github.com/ddddxxx/MusicPlayer#supported-players)
- Automatically search & download live lyrics from various lyrics sources. [List of supported sources](https://github.com/ddddxxx/LyricsKit#supported-sources)
- Display lyrics on desktop and menubar. you can customize font, color and position.
- Adjust lyrics offset on status menu.
- Navigate the song with lyrics - Double click a line to jump to specific position.
- Drag & Drop to import/export lyrics file.
- Auto launch & quit with music player.
- Automatic conversion between Traditional Chinese and Simplified Chinese.

### Lyrics Editor

LyricsX use custom lyrics file format "LRCX" which support word time tag, multi-language translation and more. Currently there's no official LRCX editor. You can use [Lrcx_Creator](https://github.com/Doublefire-Chen/Lrcx_Creator) for now (see [#544](https://github.com/ddddxxx/LyricsX/issues/544), thanks to [@Doublefire-Chen](https://github.com/Doublefire-Chen)). Or use normal LRC editor, as LRCX is compatible with LRC.

## Screenshot

<img src="docs/img/desktop_lyrics.gif" width="480px">

<img src="docs/img/preview_1.jpg" width="1280px">

<img src="docs/img/preview_2.jpg" width="1280px">

<img src="docs/img/preview_3.jpg" width="1280px">

## Credit

#### 上游项目

本项目基于 [ddddxxx/LyricsX](https://github.com/ddddxxx/LyricsX) 适配而来，全部核心设计与功能均来自原作者 [@ddddxxx](https://github.com/ddddxxx)。感谢其多年维护这款优秀的 macOS 歌词应用，以及 LyricsKit、MusicPlayer、TouchBarHelper 等配套开源库。因上游已停止维护，本分支仅针对新版本 macOS 做兼容性适配，未改变原有设计与功能。

#### Components

- [LyricsKit](https://github.com/ddddxxx/LyricsKit)
- [MusicPlayer](https://github.com/ddddxxx/MusicPlayer)

#### Open Source Libraries

- [SwiftyOpenCC](https://github.com/ddddxxx/SwiftyOpenCC)
- [GenericID](https://github.com/ddddxxx/GenericID)
- [SwiftCF](https://github.com/ddddxxx/SwiftCF)
- [Regex](https://github.com/ddddxxx/Regex)
- [Semver](https://github.com/ddddxxx/Semver)
- [TouchBarHelper](https://github.com/ddddxxx/TouchBarHelper)
- [CombineX](https://github.com/cx-org/CombineX)
- [SnapKit](https://github.com/SnapKit/SnapKit)
- [MASShortcut](https://github.com/shpakovski/MASShortcut)
- [Sparkle](https://github.com/sparkle-project/Sparkle)
- [Then](https://github.com/devxoul/Then)

#### Special Thanks

- [Lyrics Project](https://github.com/MichaelRow/Lyrics)


## ⚠️ Disclaimer

All lyrics are property and copyright of their owners.
