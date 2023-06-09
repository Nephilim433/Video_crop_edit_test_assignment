//
//  HandlerView.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 13.04.2023.
//

import Foundation
import UIKit

class HandlerView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitFrame = bounds.insetBy(dx: -20, dy: -20)
        return hitFrame.contains(point) ? self : nil
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitFrame = bounds.insetBy(dx: -20, dy: -20)
        return hitFrame.contains(point)
    }
}
