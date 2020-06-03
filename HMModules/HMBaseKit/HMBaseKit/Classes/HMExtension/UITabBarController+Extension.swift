//
//  UITabBarController+Extension.swift
//  HMBaseKit
//
//  Created by Ko Lee on 2019/9/20.
//

import UIKit

public extension UITabBarController {
    
    ///设置tabBar颜色
    func hm_tabBar(color: UIColor) {
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = color
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
    }
    
    ///设置tabBar阴影
    func hm_tabBarShadow(_ bgColor: UIColor, _ shadowColor: UIColor, _ shadowOffset: CGSize, _ shadowRadius:CGFloat, _ shadowOpacity: Float = 1.0)  {
        hm_tabBar(color: bgColor)
        self.tabBar.layer.shadowColor = shadowColor.cgColor
        self.tabBar.layer.shadowOffset = shadowOffset
        self.tabBar.layer.shadowOpacity = shadowOpacity
        self.tabBar.layer.shadowRadius = shadowRadius
    }
}
