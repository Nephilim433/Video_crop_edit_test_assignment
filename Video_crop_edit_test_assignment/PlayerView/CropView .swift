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
        for i in 1..<Int(numberOfLines) {
            let x = CGFloat(i) * xStep
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        let yStep = rect.height / numberOfLines
        for i in 1..<Int(numberOfLines) {
            let y = CGFloat(i) * yStep
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        UIColor.white.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }

}
