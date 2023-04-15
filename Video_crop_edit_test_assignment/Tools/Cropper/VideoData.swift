//
//  VideoData.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 13.04.2023.
//

import AVFoundation

class VideoEditorData: NSObject {
    var asset: AVAsset
    var composition: AVMutableComposition?
    var assetVideoTrack: AVAssetTrack?
    var assetAudioTrack: AVAssetTrack?
    var videoComposition: AVMutableVideoComposition?
    var videoCompositionTrack: AVMutableCompositionTrack?
    var audioCompositionTrack: AVMutableCompositionTrack?
    var videoSize: CGSize = .zero
    var videoDuration: CGFloat = .zero

    init(asset: AVAsset) {
        self.asset = asset
        super.init()
        self.loadAsset(asset: asset)

    }

    func loadAsset(asset: AVAsset) {
        if asset.tracks(withMediaType: .video).count != 0 {
            assetVideoTrack = asset.tracks(withMediaType: .video).first
        }
        if asset.tracks(withMediaType: .audio).count != 0 {
            assetAudioTrack = asset.tracks(withMediaType: .audio).first
        }
        if let videoTrack = assetVideoTrack {
            videoSize = videoTrack.naturalSize

        }

        let duration: CMTime = asset.duration
        let totalSeconds = CMTimeGetSeconds(duration)
        videoDuration = CGFloat(totalSeconds)

        composition = AVMutableComposition()
        videoComposition = AVMutableVideoComposition()
        videoComposition?.frameDuration = CMTime(value: 1, timescale: 1000)
        videoComposition?.renderSize = videoSize
        let insertionPoint: CMTime = CMTime.zero
        if let assetVideoTrack = assetVideoTrack {
            videoCompositionTrack = composition?.addMutableTrack(withMediaType: .video,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: asset.duration),
                                                           of: assetVideoTrack, at: insertionPoint)
            } catch {
            }
        }
        if let assetAudioTrack = assetAudioTrack {
            audioCompositionTrack = composition?.addMutableTrack(withMediaType: .audio,
                                                                 preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try audioCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: asset.duration),
                                                           of: assetAudioTrack, at: insertionPoint)
            } catch {
            }
        }

    }
}
