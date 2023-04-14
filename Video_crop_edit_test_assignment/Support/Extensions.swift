//
//  Extensions.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 07.04.2023.
//

import AVFoundation
import UIKit

extension AVPlayer {
  var isPlaying: Bool {
    rate != 0 && error == nil
  }
}

extension UIImage.SymbolConfiguration {
    static var playPauseConfig: UIImage.SymbolConfiguration {
        return UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
    }
}

