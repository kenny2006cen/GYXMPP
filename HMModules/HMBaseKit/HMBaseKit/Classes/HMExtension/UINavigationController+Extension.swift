//
//  UINavigationController+Extension.swift
//  HMBaseKit
//
//  Created by Ko Lee on 2019/9/20.
//

import UIKit

public extension UINavigationController {
    
    ///设置导航栏标题的字体颜色和大小
    func hm_navigationTitle(_ color:UIColor, _ font: UIFont)  {
         self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font]
    }
    
    ///设置导航栏透明
    func hm_navigationClear()  {
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    ///设置还原导航默认
    func hm_navigationDefault()  {
        self.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationBar.shadowImage = nil
    }
}
