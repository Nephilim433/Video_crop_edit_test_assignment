//
//  PlayerView.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 07.04.2023.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var freeSizeCallBack: (() -> Void) = {}
    let cropView = CropView()
    var touchStart = CGPoint.zero
    var proxyFactor = CGFloat(30)
    var resizeRect = ResizeRect()
    var cropViewCenterXConstraint: NSLayoutConstraint!
    var cropViewCenterYConstraint: NSLayoutConstraint!
    var cropViewHeightAnchor: NSLayoutConstraint!
    var cropViewWidthAnchor: NSLayoutConstraint!
    var cropViewTopAnchor: NSLayoutConstraint!
    var cropViewBottomAnchor: NSLayoutConstraint!
    var cropViewLeftAnchor: NSLayoutConstraint!
    var cropViewRightAnchor: NSLayoutConstraint!
    var topBottomLeftRightConstraints: [NSLayoutConstraint]!
    var widthHeightXYConstraints: [NSLayoutConstraint]!
    let panGestureRecognizer = UIPanGestureRecognizer()
    private var initialSet = false

    // MARK: Lifecycle

    init(url: URL) {
        super.init(frame: .zero)
        let playerBackgroundColor = UIColor(red: 16/255, green: 16/255, blue: 16/255, alpha: 1.0)
        backgroundColor = playerBackgroundColor
        setPlayer(url)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        print("PlayerView deinit")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let player = self.player else {
              return
          }
        guard let playerLayer = self.playerLayer else {
            return
        }

        guard let videoSize = player.currentItem?.asset.tracks(withMediaType: .video).first?.naturalSize else {
            return
        }

        playerLayer.frame = AVMakeRect(aspectRatio: videoSize, insideRect: self.bounds)
        if !initialSet {
            setupCropView()
        }
    }

    private func setPlayer(_ url: URL) {
        let player = AVPlayer(url: url)
        self.player = player
        playerLayer = AVPlayerLayer()
        guard let playerLayer = self.playerLayer else { return }
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        layer.addSublayer(playerLayer)
    }

    private func setupCropView() {
        initialSet = true
        cropView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        cropView.layer.borderColor = UIColor.white.cgColor
        cropView.layer.borderWidth = 2.0
        addSubview(cropView)
        cropView.translatesAutoresizingMaskIntoConstraints = false
        cropViewCenterXConstraint = cropView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        cropViewCenterYConstraint = cropView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        cropViewHeightAnchor = cropView.heightAnchor.constraint(equalToConstant: 200)
        cropViewWidthAnchor = cropView.widthAnchor.constraint(equalToConstant: 200)

        cropViewTopAnchor = cropView.topAnchor.constraint(equalTo: self.topAnchor)
        cropViewBottomAnchor = cropView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        cropViewLeftAnchor = cropView.leftAnchor.constraint(equalTo: self.leftAnchor)
        cropViewRightAnchor = cropView.rightAnchor.constraint(equalTo: self.rightAnchor)

        cropViewTopAnchor.constant = (frame.height/2)-100
        cropViewBottomAnchor.constant = -(frame.height/2)+100
        cropViewLeftAnchor.constant = (frame.width/2)-100
        cropViewRightAnchor.constant = -(frame.width/2)+100

        cropViewTopAnchor.isActive = true
        cropViewBottomAnchor.isActive = true
        cropViewLeftAnchor.isActive = true
        cropViewRightAnchor.isActive = true

        widthHeightXYConstraints = [cropViewWidthAnchor,
                                    cropViewHeightAnchor,
                                    cropViewCenterXConstraint,
                                    cropViewCenterYConstraint]
        topBottomLeftRightConstraints = [cropViewTopAnchor,
                                         cropViewBottomAnchor,
                                         cropViewLeftAnchor,
                                         cropViewRightAnchor]

        cropViewTopAnchor.priority = .defaultLow
        cropViewBottomAnchor.priority = .defaultLow
        cropViewLeftAnchor.priority = .defaultLow
        cropViewRightAnchor.priority = .defaultLow

        // Set up gesture recognizers for the cropView
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        cropView.addGestureRecognizer(panGestureRecognizer)
    }
}
