//
//  VideoCropViewController.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 06.04.2023.
//
import UIKit
import AVFoundation
import AVKit

class VideoCropViewController: UIViewController {

    //MARK: - Properties
    private let videoURL: URL
    private var videoEditor: VideoEditor!
    private var playerView : PlayerView!
    private var trimmerView : TrimmerView!
    private var controlPanel: ControlPanel!
    private var progressView = UIProgressView()
    private var spinner = UIActivityIndicatorView(style: .large)
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration.playPauseConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    init(videoURL: URL) {
        self.videoURL = videoURL
        self.videoEditor = VideoEditor(videoURL: videoURL)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .white
        // Set up the navigation bar button
        let button = UIBarButtonItem(title: "Crop", style: .done, target: self, action: #selector(crop))
        navigationItem.rightBarButtonItem = button
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let asset = AVAsset(url: videoURL)
        self.trimmerView.asset = asset
        videoEditor.resetVideoData(videoURL: videoURL)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerAction(.pause)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: building UI
    
    func setupUI() {
        // Set up the control panel
        controlPanel = ControlPanel(videoCropVC: self)
        // Set up the trimmer view
        setupSlider()
        // Set up the video player layer
        setupPlayer()
        // Set up the spinner
        setupSpinner()
        // Set up the progress view
        setupProgressView()
    }
    
    
    //MARK: Player
    func setupPlayer() {
        self.playerView = PlayerView(url: videoURL)
            guard let playerView = self.playerView else { return }
            self.view.addSubview(playerView)
            playerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([

                playerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                playerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                playerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                playerView.bottomAnchor.constraint(equalTo: self.playPauseButton.topAnchor)
            ])
        
        playerView.freeSizeCallBack = { [weak self] in
            self?.controlPanel.freesizeSelected()

        }
    }
    //MARK: Spinner
    func setupSpinner() {
        spinner.isHidden = true
        spinner.hidesWhenStopped = true
        spinner.color = .white
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    //MARK: ProgressView
    func setupProgressView() {
        progressView.progress = 0
        progressView.progressTintColor = .white
        
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        progressView.leftAnchor.constraint(equalTo: view.leftAnchor),
        progressView.rightAnchor.constraint(equalTo: view.rightAnchor),
        progressView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
        progressView.isHidden = true
        
        
        
    }
    //MARK: Slider
    private func setupSlider() {
        trimmerView = TrimmerView()
        trimmerView.isHidden = false
        trimmerView.delegate = self
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.darkGray
        view.addSubview(playPauseButton)
        view.addSubview(trimmerView)
        if let duration = videoEditor?.videoData.videoDuration {
            trimmerView.maxDuration = duration
        }
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        trimmerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playPauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            playPauseButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            
            trimmerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            trimmerView.leftAnchor.constraint(equalTo: playPauseButton.rightAnchor),
            trimmerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            trimmerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        loopVideo()
    }

    private func loopVideo() {
        guard let videoPlayer = playerView?.player else { return }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] notification in
            if let startTime = self?.trimmerView.startTime {
                videoPlayer.seek(to: startTime)
                videoPlayer.play()
            }
        }
    }
    // MARK: Timers
    private var playbackTimeCheckerTimer: Timer?
    private var trimmerPositionChangedTimer: Timer?
    
    func startPlaybackTimeChecker() {
      stopPlaybackTimeChecker()
      playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                      selector: #selector(self.onPlaybackTimeChecker),
                                                      userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
      playbackTimeCheckerTimer?.invalidate()
      playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = self.playerView?.player else {
        return
      }

      let playBackTime = player.currentTime()
      trimmerView.seek(to: playBackTime)
      
      if playBackTime >= endTime {
          player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        trimmerView.seek(to: startTime)
      }
    }
    
    //MARK: Actions
    private enum Action {
        case pause
        case play
    }
    
    @objc private func handleActionButton() {
        guard let player = playerView?.player else { return }
        if player.isPlaying {
            playerAction(.pause)
        } else {
            playerAction(.play)
        }
    }

    private func playerAction(_ action:Action) {
        guard let player = self.playerView?.player else { return }
        switch action {
        case .play:
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration.playPauseConfig), for: .normal)
            startPlaybackTimeChecker()
        case .pause:
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration.playPauseConfig), for: .normal)
            stopPlaybackTimeChecker()
        }
    }
    
    @objc func crop() {
        guard let playerView = playerView, let playerLayerFrame = playerView.playerLayer?.frame else { return }
        
        // Convert the crop view's bounds to the player view's coordinate space and calculate the mask rect
        let playerLayerFrameInParent = playerView.convert(playerLayerFrame, to: playerView)
        let maskRect = playerView.cropView.convert(playerView.cropView.bounds, to: playerView)
            .intersection(playerLayerFrameInParent)
            .applying(CGAffineTransform(translationX: -playerLayerFrameInParent.origin.x, y: -playerLayerFrameInParent.origin.y))
        
        guard let videoEditor = self.videoEditor, let startTime = trimmerView.startTime, let endTime = trimmerView.endTime else { return }
        videoEditor.setTrimming(start: startTime, end: endTime)
        videoEditor.crop(cropFrame: maskRect, outputSize: (playerView.playerLayer?.frame.size)!)

        spinner.isHidden = false
        spinner.startAnimating()
        progressView.isHidden = false
        view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false

        videoEditor.export() { [weak self] progress in
            self?.progressView.progress = progress
        } completion: { [weak self] session in
            guard let strongSelf = self else { return }
            if session.status == .completed {
                strongSelf.navigationItem.rightBarButtonItem?.isEnabled = true
                strongSelf.progressView.isHidden = true
                strongSelf.progressView.progress = 0
                strongSelf.view.isUserInteractionEnabled = true
                strongSelf.spinner.stopAnimating()

                guard let exportUrl = session.outputURL else { return }
                let player = AVPlayer(url: exportUrl)
                let vc = AVPlayerViewController()
                vc.player = player
                vc.player?.play()
                
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}
    // MARK: Aspect Ratio Button Tapped
extension VideoCropViewController {
    func handleAspectRatioButtonTapped(_ button: RatioCellItem) {
        guard let playerView = self.playerView else { return }
        switch button {
        case .freeSize:
            playerView.cropViewFreeSize()
        case .instagram:
            playerView.instagram()
        case .fourToFive:
            playerView.fourByFive()
        case .fiveToFour:
            playerView.fiveByFour()
        case .sixteenToNine:
            playerView.sixteenByNine()
        case .fullscreen:
            playerView.fullscreenSize()
        }
    }
}


    //MARK: TrimmerViewDelegate
extension VideoCropViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        guard let player = playerView?.player else { return }
        player.seek(to:playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        guard let player = playerView?.player else { return }
        stopPlaybackTimeChecker()
        playerAction(.pause)
        player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}
