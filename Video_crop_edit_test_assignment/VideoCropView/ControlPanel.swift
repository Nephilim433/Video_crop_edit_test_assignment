//
//  ControlPanel.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 14.04.2023.
//

import UIKit

class ControlPanel: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    private let videoCropVC: VideoCropViewController
    
    private lazy var colletionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 100)
        let colletionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colletionView.backgroundColor = .gray
        colletionView.register(RatioCollectionViewCell.self, forCellWithReuseIdentifier: RatioCollectionViewCell.identifier)
        colletionView.showsHorizontalScrollIndicator = false
        colletionView.dataSource = self
        colletionView.delegate = self
        return colletionView
    }()
    
    private var ratioCellItems : [RatioCellItem] = RatioCellItem.allCases.map { $0 }
    
    init(videoCropVC: VideoCropViewController) {
        self.videoCropVC = videoCropVC
        super.init()
        
        videoCropVC.view.addSubview(colletionView)
        colletionView.translatesAutoresizingMaskIntoConstraints = false
        colletionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        NSLayoutConstraint.activate([
            colletionView.bottomAnchor.constraint(equalTo: videoCropVC.view.safeAreaLayoutGuide.bottomAnchor),
            colletionView.leftAnchor.constraint(equalTo: videoCropVC.view.leftAnchor),
            colletionView.rightAnchor.constraint(equalTo: videoCropVC.view.rightAnchor),
            colletionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func freesizeSelected() {
        colletionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ratioCellItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RatioCollectionViewCell.identifier, for: indexPath) as? RatioCollectionViewCell else { return UICollectionViewCell() }
        cell.image = UIImage(named: ratioCellItems[indexPath.item].imageName)
        cell.ratioText = ratioCellItems[indexPath.item].rawValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section }).forEach({ collectionView.deselectItem(at: $0, animated: true) })
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RatioCollectionViewCell.identifier, for: indexPath) as? RatioCollectionViewCell else { return }
        cell.isSelected = true
        videoCropVC.handleAspectRatioButtonTapped(ratioCellItems[indexPath.item])
    }
}
