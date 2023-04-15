import UIKit
// ratio buttons
extension PlayerView {
    func fullscreenSize() {
        guard let playerLayer = playerLayer else { return }
        let playerLayerFrame = playerLayer.frame
        NSLayoutConstraint.deactivate(topBottomLeftRightConstraints)
        NSLayoutConstraint.activate(widthHeightXYConstraints)
        UIView.animate(withDuration: 0.3) {
            self.cropViewWidthAnchor.constant = playerLayerFrame.width
            self.cropViewHeightAnchor.constant = playerLayerFrame.height
            self.cropViewCenterXConstraint.constant = 0
            self.cropViewCenterYConstraint.constant = 0
            self.cropViewWidthAnchor.isActive = true
            self.layoutIfNeeded()
        }
    }
    func cropViewFreeSize() {
        NSLayoutConstraint.activate(topBottomLeftRightConstraints)
        NSLayoutConstraint.deactivate(widthHeightXYConstraints)
        cropViewTopAnchor.constant = self.cropView.frame.minY
        cropViewRightAnchor.constant = -(self.frame.maxX-self.cropView.frame.maxX)
        cropViewBottomAnchor.constant = -(self.frame.height - self.cropView.frame.maxY)
        cropViewLeftAnchor.constant = self.cropView.frame.minX
        cropView.updateConstraints()
            self.layoutIfNeeded()
    }
    func instagram() {
        guard let playerLayer = playerLayer else { return }
        let size: CGFloat = min(playerLayer.frame.width, playerLayer.frame.height)
                    NSLayoutConstraint.deactivate(topBottomLeftRightConstraints)
                    NSLayoutConstraint.activate(widthHeightXYConstraints)
        UIView.animate(withDuration: 0.3) {
            self.cropViewCenterXConstraint.constant = 0
            self.cropViewCenterYConstraint.constant = 0
            self.cropViewWidthAnchor.constant = size
            self.cropViewHeightAnchor.constant = size
            self.layoutIfNeeded()
        }
    }
    func sixteenByNine() {
        guard let playerLayer = playerLayer else { return }
        let size = CGSize(width: (playerLayer.frame.width), height: (playerLayer.frame.width*9)/16)
        NSLayoutConstraint.deactivate(topBottomLeftRightConstraints)
        NSLayoutConstraint.activate(widthHeightXYConstraints)
        UIView.animate(withDuration: 0.3) {
            self.cropViewCenterXConstraint.constant = 0
            self.cropViewCenterYConstraint.constant = 0
            self.cropViewWidthAnchor.constant = size.width
            self.cropViewHeightAnchor.constant = size.height
            self.layoutIfNeeded()
        }
    }
    func fiveByFour() {
        guard let playerLayer = playerLayer else { return }
        let cropRatio = CGSize(width: 4, height: 5)
        let playerRatio = playerLayer.frame.size
        // Calculate size of cropView based on the larger dimension
        var cropSize = CGSize(width: 0, height: 0)
        if cropRatio.width/cropRatio.height > playerRatio.width/playerRatio.height {
            cropSize.width = playerRatio.width
            cropSize.height = cropSize.width * cropRatio.height / cropRatio.width
        } else {
            cropSize.height = playerRatio.height
            cropSize.width = cropSize.height * cropRatio.width / cropRatio.height
        }
        // Set the frame of the cropView and center it within the playerLayer
        NSLayoutConstraint.deactivate(topBottomLeftRightConstraints)
        NSLayoutConstraint.activate(widthHeightXYConstraints)
        UIView.animate(withDuration: 0.3) {
            self.cropViewCenterXConstraint.constant = 0
            self.cropViewCenterYConstraint.constant = 0
            self.cropViewWidthAnchor.constant = cropSize.width
            self.cropViewHeightAnchor.constant = cropSize.height

            if self.cropView.frame.size.width > playerLayer.frame.size.width {
                self.cropViewWidthAnchor.constant = playerLayer.frame.size.width
                self.cropViewHeightAnchor.constant = self.cropView.frame.size.width * cropRatio.height / cropRatio.width
            } else if self.cropView.frame.size.height > playerLayer.frame.size.height {
                self.cropViewHeightAnchor.constant = playerLayer.frame.size.height
                self.cropViewWidthAnchor.constant = self.cropView.frame.size.height * cropRatio.width / cropRatio.height
        }
            self.layoutIfNeeded()
        }
    }

    func fourByFive() {
        guard let playerLayer = playerLayer else { return }
        let cropRatio = CGSize(width: 5, height: 4)
        let playerRatio = playerLayer.frame.size

        // Calculate size of cropView based on the larger dimension
        var cropSize = CGSize(width: 0, height: 0)
        if cropRatio.width/cropRatio.height > playerRatio.width/playerRatio.height {
            cropSize.width = playerRatio.width
            cropSize.height = cropSize.width * cropRatio.height / cropRatio.width
        } else {
            cropSize.height = playerRatio.height
            cropSize.width = cropSize.height * cropRatio.width / cropRatio.height
        }
        // Set the frame of the cropView and center it within the playerLayer
        NSLayoutConstraint.deactivate(topBottomLeftRightConstraints)
        NSLayoutConstraint.activate(widthHeightXYConstraints)
        UIView.animate(withDuration: 0.3) {
            self.cropViewCenterXConstraint.constant = 0
            self.cropViewCenterYConstraint.constant = 0
            self.cropViewWidthAnchor.constant = cropSize.width
            self.cropViewHeightAnchor.constant = cropSize.height
        // Make sure the cropView is not larger than the playerLayer
            if self.cropView.frame.size.width > playerLayer.frame.size.width {
                self.cropViewWidthAnchor.constant = playerLayer.frame.size.width
                self.cropViewHeightAnchor.constant = self.cropView.frame.size.width * cropRatio.height / cropRatio.width
            } else if self.cropView.frame.size.height > playerLayer.frame.size.height {
                self.cropViewHeightAnchor.constant = playerLayer.frame.size.height
            }
            self.layoutIfNeeded()
        }
    }
}
