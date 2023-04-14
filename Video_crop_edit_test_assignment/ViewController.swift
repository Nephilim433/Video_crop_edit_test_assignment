//
//  ViewController.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 06.04.2023.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    private let urlTextField = UITextField()

    lazy var bundleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Preloaded video", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapBundleButton), for: .touchUpInside)
        return button
    }()
    
    lazy var webButton: UIButton = {
        let button = UIButton()
        button.setTitle("By hardcoded URL", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapWebButton), for: .touchUpInside)
        return button
    }()

    lazy var spinner: UIActivityIndicatorView = {
      let spinner = UIActivityIndicatorView(style: .large)
        spinner.isHidden = true
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        // Set up the text field
        configureUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        spinner.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        spinner.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        urlTextField.frame = CGRect(x: 0, y: 100, width: self.view.frame.maxX-50, height: 40)
        urlTextField.center.x = view.center.x
        bundleButton.frame = CGRect(x: 100, y: 300, width: self.view.frame.maxX-100, height: 50)
        bundleButton.center.x = view.center.x
        webButton.frame = CGRect(x: 100, y: 400, width: self.view.frame.maxX-100, height: 50)
        webButton.center.x = view.center.x
        spinner.center = view.center
    }
    
    // MARK: - UI
    private func configureUI() {
        urlTextField.placeholder = "Paste video URL here"
        urlTextField.borderStyle = .roundedRect
        view.addSubview(urlTextField)
        urlTextField.delegate = self
        urlTextField.autocorrectionType = .no
        view.addSubview(bundleButton)
        view.addSubview(webButton)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
    }
    
    //MARK: - Actions
    @objc
    func didTapBundleButton() {
        spinner.isHidden = false
        spinner.startAnimating()
        self.view.isUserInteractionEnabled = false
        let bundleURL = Bundle.main.url(forResource: "video4", withExtension: "mp4")!
        let vc = VideoCropViewController(videoURL: bundleURL)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func didTapWebButton() {
        spinner.isHidden = false
        spinner.startAnimating()
        self.view.isUserInteractionEnabled = false
        let webUrl = URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4")!
        let vc = VideoCropViewController(videoURL: webUrl)
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
}

extension ViewController {
    //check if video is playable 
    private func checkVideo(url: URL, complition: @escaping (Bool) -> Void) {
        let asset = AVURLAsset(url: url)
        let keys = ["playable"]
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError?
            let status = asset.statusOfValue(forKey: "playable", error: &error)

            switch status {
            case .loaded:
                // URL points to a playable video
                complition(true)
            case .failed, .cancelled:
                // URL does not point to a playable video
                complition(false)
                print("Error loading asset: \(error?.localizedDescription ?? "unknown error")")
            default:
                break
            }
        }
    }
    private func showNotValidAlert() {
        let alert = UIAlertController(title: "Invalid URL", message: "Please enter a valid URL.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard
        textField.resignFirstResponder()
        
        // Handle the video URL
        guard let text = textField.text else { return true }
        if let url = URL(string: text), url.isFileURL || url.scheme == "http" || url.scheme == "https" {
            // The text is a valid URL
            print("valid")
            spinner.isHidden = false
            spinner.startAnimating()
            checkVideo(url: url) { isVideo in
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.spinner.isHidden = true
                    self.view.isUserInteractionEnabled = true
                    if isVideo {
                        let vc = VideoCropViewController(videoURL: url)
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        self.showNotValidAlert()
                    }
                }
            }

        } else {
            print("not valid")
            showNotValidAlert()
        }
        
        return true
    }
    
}


