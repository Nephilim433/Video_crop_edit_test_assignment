//
//  RatioCollectionViewCell.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 10.04.2023.
//

import UIKit

class RatioCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "RatioCollectionViewCell"
    
    private let label = UILabel()
    private let imageView = UIImageView()
    
    var ratioText: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .gray
        
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        
        contentView.backgroundColor = .gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageMargin: CGFloat = 10
        let labelMargin: CGFloat = 2
        imageView.frame = CGRect(x: imageMargin, y: imageMargin, width: contentView.frame.width-2*imageMargin, height: contentView.frame.width-2*imageMargin)
        label.frame = CGRect(x: labelMargin, y: imageView.frame.maxY+labelMargin, width: contentView.frame.width-2*labelMargin, height: contentView.frame.height-contentView.frame.width-2*labelMargin)
    }
    
    override var isSelected: Bool {
        didSet {
            label.backgroundColor = isSelected ? .white : .clear
        }
    }
    
}
