//
//  PlayerView+PanGesture.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 13.04.2023.
//


import UIKit
extension PlayerView {
    struct ResizeRect{
        var topTouch = false
        var leftTouch = false
        var rightTouch = false
        var bottomTouch = false
        var middleTouch = false
    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let cropView = sender.view else { return }
        guard let playerLayer = self.playerLayer else { return }
        
        let cropViewHalfWidth = cropView.frame.size.width / 2
        let cropViewHalfHeight = cropView.frame.size.height / 2

        let translation = sender.translation(in: self)
        if sender.state == .began {
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
            }else if xRange ~= touchStart.x {
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
        
        if sender.state == .changed {

            let cropViewCenterX = cropView.center.x + translation.x
            let cropViewCenterY = cropView.center.y + translation.y
            // Restrict the cropView to the playerLayer frame
            let playerLayerFrame = playerLayer.frame
            let cropViewMaxX = playerLayerFrame.maxX - cropViewHalfWidth
            let cropViewMinX = playerLayerFrame.minX + cropViewHalfWidth
            let cropViewMaxY = playerLayerFrame.maxY - cropViewHalfHeight
            let cropViewMinY = playerLayerFrame.minY + cropViewHalfHeight

            if resizeRect.topTouch {
                freeSizeCallBack()
                cropViewTopAnchor.constant += translation.y
                if cropViewTopAnchor.constant < playerLayerFrame.minY {
                    cropViewTopAnchor.constant = playerLayerFrame.minY
                }
            }
            
            if resizeRect.rightTouch {
                freeSizeCallBack()
                cropViewRightAnchor.constant += translation.x
                if cropViewRightAnchor.constant > -(self.frame.maxX-playerLayerFrame.maxX) {
                    cropViewRightAnchor.constant = -(self.frame.maxX-playerLayerFrame.maxX)
                }

            }
            if resizeRect.bottomTouch {
                freeSizeCallBack()
                let halfSize = self.frame.size.height / 2
                let halfLayer = (self.playerLayer?.frame.size.height ?? 0) / 2
                let guess = -1 * (halfSize - halfLayer)
                cropViewBottomAnchor.constant += translation.y
                if cropViewBottomAnchor.constant > guess {
                    cropViewBottomAnchor.constant = guess
                }

            }
            if resizeRect.leftTouch {
                freeSizeCallBack()
                cropViewLeftAnchor.constant += translation.x
                if cropViewLeftAnchor.constant < playerLayerFrame.minX {
                        cropViewLeftAnchor.constant = playerLayerFrame.minX
                    }

            }
            
            if resizeRect.middleTouch {
                cropViewWidthAnchor.constant = cropView.frame.width
                cropViewHeightAnchor.constant = cropView.frame.height
                cropViewWidthAnchor.isActive = true
                cropViewHeightAnchor.isActive = true
                NSLayoutConstraint.deactivate(topBottomLeftRightConstraints)
                cropViewCenterXConstraint.constant = min(max(cropViewCenterX, cropViewMinX), cropViewMaxX) - (self.frame.width/2)
                cropViewCenterYConstraint.constant = min(max(cropViewCenterY, cropViewMinY), cropViewMaxY) - (self.frame.height/2)
                cropViewCenterXConstraint.isActive = true
                cropViewCenterYConstraint.isActive = true
            }
            sender.setTranslation(CGPoint.zero, in: self)
        }
        if sender.state == .ended {
            NSLayoutConstraint.activate(topBottomLeftRightConstraints)
            NSLayoutConstraint.deactivate(widthHeightXYConstraints)
            cropViewTopAnchor.constant = self.cropView.frame.minY
            cropViewRightAnchor.constant = -(self.frame.maxX-self.cropView.frame.maxX)
            cropViewBottomAnchor.constant = -(self.frame.height - self.cropView.frame.maxY)
            cropViewLeftAnchor.constant = self.cropView.frame.minX
        }
    }
}
