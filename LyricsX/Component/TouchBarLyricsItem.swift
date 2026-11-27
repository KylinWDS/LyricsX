//
//  TouchBarLyricsItem.swift
//  LyricsX - https://github.com/ddddxxx/LyricsX
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AppKit
import CXShim
import LyricsCore
import OpenCC

@available(OSX 10.12.2, *)
class TouchBarLyricsItem: NSCustomTouchBarItem {
    
    private var lyricsTextField = KaraokeLabel(labelWithString: "")
    
    @objc dynamic var progressColor = #colorLiteral(red: 0, green: 1, blue: 0.8333333333, alpha: 1)
    
    private var cancelBag = Set<AnyCancellable>()
    
    override init(identifier: NSTouchBarItem.Identifier) {
        super.init(identifier: identifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        view = lyricsTextField
        customizationLabel = "Lyrics"
        AppController.shared.$currentLyrics
            .combineLatest(AppController.shared.$currentLineIndex)
            .receive(on: DispatchQueue.lyricsDisplay.cx)
            .invoke(TouchBarLyricsItem.handleLyricsDisplay, weaklyOn: self)
            .store(in: &cancelBag)
        // 与桌面歌词相同的绑定模式：
        // 文字颜色复用桌面歌词颜色偏好（黑底白字，显示页颜色选择器直接生效）
        // 注：必须绑定在 lyricsTextField 上——textColor 属性在 KaraokeLabel，
        // 绑到 item 自身会因 KVC 找不到 key 而在启动时崩溃
        lyricsTextField.bind(NSBindingName("textColor"), to: .standard, withDefaultName: .desktopLyricsColor)
        // 字体使用 Touch Bar 独立偏好（桌面歌词字体 24pt 对 Touch Bar 过大）
        observeDefaults(keys: [.touchBarLyricsFontName, .touchBarLyricsFontSize], options: [.initial]) { [unowned self] in
            self.lyricsTextField.font = defaults.touchBarLyricsFont
        }
    }
    
    private func handleLyricsDisplay(event: (lyrics: Lyrics?, index: Int?)) {
        guard let lyrics = event.lyrics,
            let index = event.index else {
                DispatchQueue.main.async {
                    self.lyricsTextField.stringValue = ""
                    self.lyricsTextField.removeProgressAnimation()
                }
                return
        }
        let line = lyrics.lines[index]
        var lyricsContent = line.content
        if let converter = ChineseConverter.shared,
            lyrics.metadata.language?.hasPrefix("zh") == true {
            lyricsContent = converter.convert(lyricsContent)
        }
        DispatchQueue.main.async {
            self.lyricsTextField.stringValue = lyricsContent
            if let timetag = line.attachments.timetag {
                let position = selectedPlayer.playbackTime
                let timeDelay = line.lyrics?.adjustedTimeDelay ?? 0
                let progress = timetag.tags.map { ($0.time + line.position - timeDelay - position, $0.index) }
                self.lyricsTextField.setProgressAnimation(color: self.progressColor, progress: progress)
            }
        }
    }
}
