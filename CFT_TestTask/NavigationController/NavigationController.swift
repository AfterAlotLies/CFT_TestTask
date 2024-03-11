//
//  NavigationController.swift
//  CFT_TestTask
//
//  Created by Vyacheslav on 11.03.2024.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        let mainViewController = NoteListViewController(nibName: "NoteListViewController", bundle: nil)
        self.viewControllers = [mainViewController]
    }

}
