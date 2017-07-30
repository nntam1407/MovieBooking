//
//  RootTabbarViewController.swift
//  MovieBooking
//
//  Created by Tam Nguyen on 7/29/17.
//  Copyright © 2017 Tam Nguyen. All rights reserved.
//

import UIKit

enum TabbarIndexEnum: Int {
    case movies = 0
    case favorited = 1
    case more = 2
}

class RootTabbarViewController: BaseTabbarViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK:
    // MARK: UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if self.selectedIndex == TabbarIndexEnum.more.rawValue {
            self.tabBar.barStyle = .default
        } else {
            self.tabBar.barStyle = .black
        }
    }

}
