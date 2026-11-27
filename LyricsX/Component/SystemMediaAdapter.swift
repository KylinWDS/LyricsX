//
//  SystemMediaAdapter.swift
//  LyricsX
//
//  macOS 15.4+ 兼容层：系统对 MediaRemote 私有框架施加了 bundle id
//  前缀（com.apple.*）门禁，MusicPlayer 包的 MusicPlayers.SystemMedia
//  在新版系统上无法再读取 Now Playing 数据。
//
//  本适配器通过 MediaRemoteAdapter（vendored 于
//  Vendor/Dependencies/MediaRemoteAdapter）桥接系统 /usr/bin/perl
//  （持有 com.apple.perl 身份，仍具备 MediaRemote 访问权限），
//  以 JSON 流的方式读取正在播放信息，并实现 MusicPlayerProtocol，
//  对上层（AppController / SelectedPlayer / Touch Bar 等）完全透明。
//

import Foundation
import MusicPlayer
import MediaRemoteAdapter
import CXShim

extension MusicPlayers {

    final class SystemMediaAdapter: ObservableObject {

        @Published private(set) var currentTrack: MusicTrack?
        @Published private(set) var playbackState: PlaybackState = .stopped

        private let mediaController = MediaController()

        /// 最近一次收到的播放信息，用于 playbackTime / updatePlayerState 计算
        private var lastPayload: TrackInfo.Payload?

        init?() {
            guard FileManager.default.isExecutableFile(atPath: "/usr/bin/perl") else {
                NSLog("[LyricsX] SystemMediaAdapter unavailable: /usr/bin/perl not found")
                return nil
            }

            mediaController.onTrackInfoReceived = { [weak self] trackInfo in
                self?.handleTrackInfo(trackInfo)
            }
            mediaController.onListenerTerminated = { [weak self] in
                NSLog("[LyricsX] MediaRemoteAdapter listener terminated")
                // 自动重启监听进程，保证长期运行稳定
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.mediaController.startListening()
                }
            }
            mediaController.startListening()

            // 启动后立即拉取一次当前状态
            mediaController.getTrackInfo { [weak self] trackInfo in
                self?.handleTrackInfo(trackInfo)
            }
            NSLog("[LyricsX] SystemMediaAdapter started")
        }

        deinit {
            mediaController.stopListening()
        }

        private func handleTrackInfo(_ trackInfo: TrackInfo?) {
            guard let payload = trackInfo?.payload else {
                lastPayload = nil
                if currentTrack != nil {
                    currentTrack = nil
                }
                if playbackState != .stopped {
                    playbackState = .stopped
                }
                return
            }

            lastPayload = payload

            let duration = payload.durationMicros.map { $0 / 1_000_000 }
            let track = MusicTrack(
                id: payload.bundleIdentifier.map { "\($0)-\(payload.uniqueIdentifier)" }
                    ?? payload.uniqueIdentifier,
                title: payload.title,
                album: payload.album,
                artist: payload.artist,
                duration: duration,
                fileURL: nil,
                artwork: payload.artwork)
            if track.id != currentTrack?.id {
                currentTrack = track
            }

            let newState = computePlaybackState(from: payload)
            if newState != playbackState {
                playbackState = newState
            }
        }

        private func computePlaybackState(from payload: TrackInfo.Payload) -> PlaybackState {
            guard payload.isPlaying == true else {
                if let elapsed = payload.elapsedTimeMicros {
                    return .paused(time: elapsed / 1_000_000)
                }
                return .stopped
            }
            // 播放中：由时间戳 + 已播放时长推导起始时间，保证逐字动画平滑推进
            if let elapsed = payload.elapsedTimeMicros {
                let start: Date
                if let ts = payload.timestampEpochMicros {
                    start = Date(timeIntervalSince1970: ts / 1_000_000 - elapsed / 1_000_000)
                } else {
                    start = Date(timeIntervalSinceNow: -elapsed / 1_000_000)
                }
                return .playing(start: start)
            }
            return .stopped
        }
    }
}

extension MusicPlayers.SystemMediaAdapter: MusicPlayerProtocol {

    public var currentTrackWillChange: AnyPublisher<MusicTrack?, Never> {
        return $currentTrack.eraseToAnyPublisher()
    }

    public var playbackStateWillChange: AnyPublisher<PlaybackState, Never> {
        return $playbackState.eraseToAnyPublisher()
    }

    var name: MusicPlayerName? {
        return nil
    }

    var playbackTime: TimeInterval {
        get {
            if let payload = lastPayload, let elapsed = payload.currentElapsedTime {
                return elapsed
            }
            return playbackState.time
        }
        set {
            lastPayload = nil
            // PlaybackState.withTime 在 MusicPlayer 包内是 internal，这里用公开 API 等价实现
            switch playbackState {
            case .playing:
                playbackState = .playing(time: newValue)
            case .paused:
                playbackState = .paused(time: newValue)
            default:
                break
            }
            mediaController.setTime(seconds: newValue)
        }
    }

    public func resume() {
        mediaController.play()
    }

    public func pause() {
        mediaController.pause()
    }

    public func playPause() {
        mediaController.togglePlayPause()
    }

    public func skipToNextItem() {
        mediaController.nextTrack()
    }

    public func skipToPreviousItem() {
        mediaController.previousTrack()
    }

    public func updatePlayerState() {
        // MediaController 通过监听进程持续推送，无需主动轮询；
        // 这里基于最近一次 payload 刷新时间，保证每秒轮询拿到新进度。
        if let payload = lastPayload {
            let newState = computePlaybackState(from: payload)
            if newState != playbackState {
                playbackState = newState
            }
        }
    }
}
