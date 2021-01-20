//
//  AdminTabController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 20/01/2021.
//

import UIKit

class AdminTabController:UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let profileTab = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "UserProfileView")
        profileTab.tabBarItem = UITabBarItem(title: "profile", image: UIImage(named: "profile-icon"), tag: 2)
        self.viewControllers?.append(profileTab)
    }
}
