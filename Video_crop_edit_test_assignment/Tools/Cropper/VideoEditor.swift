//
//  VideoEditor.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 06.04.2023.
//


import AVFoundation
import UIKit
protocol VideoEditorCommandProtocol: NSObjectProtocol {
    func execute()
}


class VideoEditor {
    var videoData: VideoEditorData
    var commands: [Any]
    var exportSession: AVAssetExportSession?
    var start: CMTime?
    var end: CMTime?
    var exportProgressBarTimer: Timer?
    
    init(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        self.videoData = VideoEditorData(asset: asset)
        self.commands = []
        
    }
    
    func export(progressCallback: @escaping ((Float) -> Void), completion: @escaping (AVAssetExportSession)->Void) {
        
        export(presetName: AVAssetExportPresetHighestQuality, optimizeForNetworkUse: false, outputFileType: AVFileType.mov,progressCallback: progressCallback, completion: completion)
    }
    
    func setTrimming(start: CMTime, end: CMTime) {
        self.start = start
        self.end = end
    }
    
    func resetVideoData(videoURL: URL) {
        let asset = AVURLAsset(url: videoURL)
        self.videoData = VideoEditorData(asset: asset)
    }

    func crop(cropFrame: CGRect, outputSize: CGSize) {
        let command = CropCommand(videoData: videoData, cropFrame: cropFrame, outputSize: outputSize)
        commands.append(command)
    }
    // MARK: Private
    private func applyCommands() {
        for item in commands {
            if let command = item as? VideoEditorCommandProtocol {
                command.execute()
            }
        }
    }
    
    private func export(presetName: String, optimizeForNetworkUse: Bool, outputFileType: AVFileType, progressCallback: @escaping ((Float) -> Void), completion: @escaping (AVAssetExportSession)->Void) {
        applyCommands()
        if let videoDataComposition = videoData.composition?.copy() as? AVAsset {
            exportSession = AVAssetExportSession(asset: videoDataComposition, presetName: presetName)
        }
        if let videoComposition = videoData.videoComposition {
            exportSession?.videoComposition = videoComposition
        }
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("cropped-video.mp4")
        
        if FileManager.default.isDeletableFile(atPath: exportURL.path) {
            do {
                try FileManager.default.removeItem(atPath: exportURL.path)
            } catch {
                print("error removing file at path")
            }
        }
        
        exportSession?.outputFileType = outputFileType
        exportSession?.outputURL = exportURL
        exportSession?.timeRange = CMTimeRange(start: start ?? CMTime.zero, end: end ?? videoData.asset.duration)
        
        
        exportProgressBarTimer = Timer()
        exportProgressBarTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _  in
            guard let strongSelf = self else { return }
            if strongSelf.exportSession!.progress < 0.99 {
                let progress = Float((strongSelf.exportSession?.progress)!)
                progressCallback(progress)
            } else {
                strongSelf.exportProgressBarTimer?.invalidate()
            }
        }
        
        exportSession?.shouldOptimizeForNetworkUse = optimizeForNetworkUse
        exportSession?.exportAsynchronously {
            DispatchQueue.main.async {
                self.commands = []
                if let exportSession = self.exportSession {
                    completion(exportSession)
                }
            }
        }
        
    }
}

