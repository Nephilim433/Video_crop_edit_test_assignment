//
//  YiCropCommand.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 06.04.2023.
//

import Foundation
import AVFoundation
import UIKit

class CropCommand: NSObject, VideoEditorCommandProtocol {
    weak var videoData: VideoEditorData?
    var cropFrame: CGRect
    var outputSize: CGSize
    init(videoData: VideoEditorData, cropFrame: CGRect, outputSize: CGSize) {
        self.videoData = videoData
        self.cropFrame = cropFrame
        self.outputSize = outputSize
        super.init()
    }

    func execute() {
        let inputSize = videoData?.videoSize

        let widthScaleFactor = outputSize.width / inputSize!.width
        let heightScaleFactor = outputSize.height / inputSize!.height
        let scaleFactor = min(widthScaleFactor, heightScaleFactor)

        cropFrame = CGRect(x: cropFrame.origin.x / scaleFactor,
                           y: cropFrame.origin.y / scaleFactor,
                           width: cropFrame.size.width / scaleFactor,
                           height: cropFrame.size.height / scaleFactor)

        var instruction: AVMutableVideoCompositionInstruction?
        var layerInstruction: AVMutableVideoCompositionLayerInstruction?
        let duration = videoData?.composition?.duration
        if videoData?.videoComposition?.instructions.count == 0 {
            instruction = AVMutableVideoCompositionInstruction()
            instruction?.timeRange = CMTimeRange(start: CMTime.zero, duration: duration ?? CMTime.zero)
            if let videoCompositionTrack = videoData?.videoCompositionTrack {
                layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
                layerInstruction?.setCropRectangle(cropFrame, at: CMTime.zero)
                let transform1 = CGAffineTransform(translationX: -1 * cropFrame.origin.x, y: -1 * cropFrame.origin.y)
                layerInstruction?.setTransform(transform1, at: CMTime.zero)
            }
        } else {
            instruction = videoData?.videoComposition?.instructions.last as? AVMutableVideoCompositionInstruction
            layerInstruction = instruction?.layerInstructions.last as? AVMutableVideoCompositionLayerInstruction
            if let duration = duration {
                var start = CGAffineTransform()
                let success = layerInstruction?.getTransformRamp(for: duration,
                                                                 start: &start,
                                                                 end: nil,
                                                                 timeRange: nil) ?? false
                if !success {
                    layerInstruction?.setCropRectangle(cropFrame, at: CMTime.zero)
                    let transform1 = CGAffineTransform(translationX: -1 * cropFrame.origin.x,
                                               y: -1 * cropFrame.origin.y)
                    layerInstruction?.setTransform(transform1, at: CMTime.zero)
                } else {
                    let transform1 = CGAffineTransform(translationX: -1 * cropFrame.origin.x,
                                               y: -1 * cropFrame.origin.y)
                    let newTransform = start.concatenating(transform1)
                    layerInstruction?.setTransform(newTransform, at: CMTime.zero)
                }
            }
        }
        videoData?.videoComposition?.renderSize = cropFrame.size
        videoData?.videoSize = cropFrame.size
        if let layerInstruction = layerInstruction {
            instruction?.layerInstructions = [layerInstruction]
        }
        if let instruction = instruction {
            videoData?.videoComposition?.instructions = [instruction]
        }

    }

}
