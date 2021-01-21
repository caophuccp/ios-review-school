//
//  TabBarViewController.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import UIKit

class TabBarViewController:UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tabOne = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
        tabOne.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "chat-icon"), tag: 1)
        
        let chatTab = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatTabView")
        chatTab.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "chat-icon"), tag: 2)
        let scanTab = UIStoryboard(name: "Scan", bundle: nil).instantiateViewController(withIdentifier: "ScanViewController")
        scanTab.tabBarItem = UITabBarItem(title: "Scan", image: UIImage(named: "scan-icon"), tag: 3)
        
        let profileTab = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "UserProfileView")
        profileTab.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile-icon"), tag: 4)
        
        self.tabBar.backgroundColor = #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1)
        self.viewControllers = [tabOne, scanTab, chatTab, profileTab]
    }
}
