//
//  CropView .swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 13.04.2023.
//

import Foundation
import UIKit

class CropView: UIView {
    override func draw(_ rect: CGRect) {
        let lineWidth: CGFloat = 1.0
        let numberOfLines: CGFloat = 4.0
        let path = UIBezierPath()
        let xStep = rect.width / numberOfLines
        for index in 1..<Int(numberOfLines) {
            let xPoint = CGFloat(index) * xStep
            path.move(to: CGPoint(x: xPoint, y: 0))
            path.addLine(to: CGPoint(x: xPoint, y: rect.height))
        }

        let yStep = rect.height / numberOfLines
        for index in 1..<Int(numberOfLines) {
            let yPoint = CGFloat(index) * yStep
            path.move(to: CGPoint(x: 0, y: yPoint))
            path.addLine(to: CGPoint(x: rect.width, y: yPoint))
        }

        UIColor.white.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }

}
