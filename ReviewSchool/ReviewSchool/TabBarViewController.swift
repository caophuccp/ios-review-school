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
        
        let tabOne = UIViewController()
        tabOne.view.backgroundColor = .systemRed
        let tabOneBarItem = UITabBarItem(title: "Tab1", image: nil, tag: 0)
        
        tabOne.tabBarItem = tabOneBarItem
        
        
        // Create Tab two
        let tabTwo = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatTabView")
        let tabTwoBarItem2 = UITabBarItem(title: "", image: UIImage(named: "chat-icon"), tag: 1)
        
        tabTwo.tabBarItem = tabTwoBarItem2
        
        let tab3 = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "UserProfileView")
        let tabTwoBarItem3 = UITabBarItem(title: "tab3", image: UIImage(named: "chat-icon"), tag: 1)
        tab3.tabBarItem = tabTwoBarItem3
        
        self.tabBar.backgroundColor = #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1)
        self.viewControllers = [tabTwo, tabOne, tab3]
    }
}
