//
//  RatioCellItem.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 13.04.2023.
//

import Foundation

enum RatioCellItem: String, CaseIterable {
    case freeSize = "Free Size"
    case instagram = "Instagram"
    case fourToFive = "4:5"
    case fiveToFour = "5:4"
    case sixteenToNine = "16:9"
    case fullscreen = "FullScreen"

    var imageName: String {
           switch self {
           case .freeSize:
               return "freeSize"
           case .instagram:
               return "instagram"
           case .fourToFive:
               return "fourToFive"
           case .fiveToFour:
               return "fiveToFour"
           case .sixteenToNine:
               return "sixteenToNine"
           case .fullscreen:
               return "fullscreen"
           }
       }
}
