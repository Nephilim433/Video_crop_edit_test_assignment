//
//  SceneDelegate.swift
//  Video_crop_edit_test_assignment
//
//  Created by Yaroslav Vedmedenko on 06.04.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()

    }

}
