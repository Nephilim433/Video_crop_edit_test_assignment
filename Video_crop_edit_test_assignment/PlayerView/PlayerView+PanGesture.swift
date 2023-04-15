//
//  PlayerView+PanGesture.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 13.04.2023.
//

import UIKit
extension PlayerView {
    struct ResizeRect {
        var topTouch = false
        var leftTouch = false
        var rightTouch = false
        var bottomTouch = false
        var middleTouch = false
    }
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let cropView = sender.view else { return }
        guard let playerLayer = self.playerLayer else { return }
        let translation = sender.translation(in: self)
        switch sender.state {
        case .began:
            handlePanGestureBegan(sender, cropView: cropView)
        case .changed:
            handlePanGestureChanged(sender, cropView: cropView, playerLayer: playerLayer, translation: translation)
        case .ended:
            handlePanGestureEnded(sender, cropView: cropView)
        default:
            break
        }
        sender.setTranslation(CGPoint.zero, in: self)
    }
    private func handlePanGestureBegan(_ sender: UIPanGestureRecognizer, cropView: UIView) {
        touchStart = sender.location(in: cropView)
        resizeRect = ResizeRect()
        let xRange = -proxyFactor...proxyFactor
        let yRange = -proxyFactor...proxyFactor
        let xRange2 = (cropView.frame.width-proxyFactor)...(cropView.frame.width+proxyFactor)
        let yRange2 = (cropView.frame.height-proxyFactor)...(cropView.frame.height+proxyFactor)
        if xRange ~= touchStart.x && yRange ~= touchStart.y {
            resizeRect.topTouch = true
            resizeRect.leftTouch = true
        } else if xRange2 ~= touchStart.x && yRange ~= touchStart.y {
            resizeRect.topTouch = true
            resizeRect.rightTouch = true
        } else if xRange ~= touchStart.x && yRange2 ~= touchStart.y {
            resizeRect.bottomTouch = true
            resizeRect.leftTouch = true
        } else if xRange2 ~= touchStart.x && yRange2 ~= touchStart.y {
            resizeRect.bottomTouch = true
            resizeRect.rightTouch = true
        } else if xRange ~= touchStart.x {
            resizeRect.leftTouch = true
        } else if yRange ~= touchStart.y {
            resizeRect.topTouch = true
        } else if xRange2 ~= touchStart.x {
            resizeRect.rightTouch = true
        } else if yRange2 ~= touchStart.y {
            resizeRect.bottomTouch = true
        } else {
            resizeRect.middleTouch = true
        }
    }

    private func handlePanGestureChanged(_ sender: UIPanGestureRecognizer,
                                         cropView: UIView,
                                         playerLayer: CALayer,
                                         translation: CGPoint) {
        let cropViewHalfWidth = cropView.frame.size.width / 2
        let cropViewHalfHeight = cropView.frame.size.height / 2
        let cropViewCenterX = cropView.center.x + translation.x
        let cropViewCenterY = cropView.center.y + translation.y
        let playerLayerFrame = playerLayer.frame
        let cropViewMaxX = playerLayerFrame.maxX - cropViewHalfWidth
        let cropViewMinX = playerLayerFrame.minX + cropViewHalfWidth
        let cropViewMaxY = playerLayerFrame.maxY - cropViewHalfHeight
        let cropViewMinY = playerLayerFrame.minY + cropViewHalfHeight
        if resizeRect.topTouch {
            handleTopTouch(translation: translation, playerLayerFrameMinY: playerLayerFrame.minY)
        }
        if resizeRect.rightTouch {
            handleRightTouch(translation: translation, playerLayerFrameMaxX: -(self.frame.maxX-playerLayerFrame.maxX))
        }
        if resizeRect.bottomTouch {
            handleBottomTouch(translation: translation)
        }
        if resizeRect.leftTouch {
            handleLeftTouch(translation: translation, playerLayerFrameMinX: playerLayerFrame.minX)
        }
        if resizeRect.middleTouch {
            handleMiddleTouch(newCenterX: min(max(cropViewCenterX, cropViewMinX), cropViewMaxX) - (self.frame.width/2),
                              newCenterY: min(max(cropViewCenterY, cropViewMinY), cropViewMaxY) - (self.frame.height/2))
        }
    }
    private func handlePanGestureEnded(_ sender: UIPanGestureRecognizer, cropView: UIView) {
        NSLayoutConstraint.activate(topBottomLeftRightConstraints)
        NSLayoutConstraint.deactivate(widthHeightXYConstraints)
        cropViewTopAnchor.constant = cropView.frame.minY
        cropViewRightAnchor.constant = -(frame.maxX-cropView.frame.maxX)
        cropViewBottomAnchor.constant = -(frame.height - cropView.frame.maxY)
        cropViewLeftAnchor.constant = cropView.frame.minX
    }
    private func handleTopTouch(translation: CGPoint, playerLayerFrameMinY: CGFloat) {
        freeSizeCallBack()
        cropViewTopAnchor.constant += translation.y
        if cropViewTopAnchor.constant < playerLayerFrameMinY {
            cropViewTopAnchor.constant = playerLayerFrameMinY
        }
    }
    private func handleRightTouch(translation: CGPoint, playerLayerFrameMaxX: CGFloat) {
        freeSizeCallBack()
        cropViewRightAnchor.constant += translation.x
        if cropViewRightAnchor.constant > playerLayerFrameMaxX {
            cropViewRightAnchor.constant = playerLayerFrameMaxX
        }
    }
    private func handleBottomTouch(translation: CGPoint) {
        freeSizeCallBack()
        let halfSize = self.frame.size.height / 2
        let halfLayer = (self.playerLayer?.frame.size.height ?? 0) / 2
        let guess = -1 * (halfSize - halfLayer)
        cropViewBottomAnchor.constant += translation.y
        if cropViewBottomAnchor.constant > guess {
            cropViewBottomAnchor.constant = guess
        }
    }
    private func handleLeftTouch(translation: CGPoint, playerLayerFrameMinX: CGFloat) {
        freeSizeCallBack()
        cropViewLeftAnchor.constant += translation.x
        if cropViewLeftAnchor.constant < playerLayerFrameMinX {
            cropViewLeftAnchor.constant = playerLayerFrameMinX
        }
    }
    private func handleMiddleTouch(newCenterX: CGFloat, newCenterY: CGFloat) {
        cropViewWidthAnchor.constant = cropView.frame.width
        cropViewHeightAnchor.constant = cropView.frame.height
        cropViewWidthAnchor.isActive = true
        cropViewHeightAnchor.isActive = true
        NSLayoutConstraint.deactivate(topBottomLeftRightConstraints)
        cropViewCenterXConstraint.constant = newCenterX
        cropViewCenterYConstraint.constant = newCenterY
        cropViewCenterXConstraint.isActive = true
        cropViewCenterYConstraint.isActive = true
    }
}
