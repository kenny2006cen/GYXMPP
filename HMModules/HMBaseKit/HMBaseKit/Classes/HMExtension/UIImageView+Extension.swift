//
//  UIImageView+Extension.swift
//  HMBaseKit
//
//  Created by Ko Lee on 2019/8/21.
//

import UIKit

public extension UIImageView {
    
    ///设置图片初始化
    class func hm_imagView(_ imageName:String) -> Self {
        return hm_basekit_imagView(imageName)
    }
    
    ///设置图片和圆角初始化
    class func hm_imagView(_ imageName:String, _ cornerRadius:CGFloat) -> Self {
        return hm_basekit_imagView(imageName, cornerRadius)
    }
    
    ///设置图片和圆角、背景色初始化
    class func hm_imagView(_ imageName:String, _ backgroundColor: UIColor, _ cornerRadius:CGFloat) -> Self {
        return hm_basekit_imagView(imageName, backgroundColor, cornerRadius)
    }
    
    
    
    ///设置图片
    func hm_imagView(_ imageName:String)  {
        hm_basekit_imagView(imageName)
    }
    
    ///设置图片和圆角
    func hm_imagView(_ imageName:String, _ cornerRadius:CGFloat)  {
        hm_basekit_imagView(imageName, cornerRadius)
    }
    
    ///设置图片和圆角、背景色
    func hm_imagView(_ imageName:String, _ backgroundColor: UIColor,  _ cornerRadius:CGFloat)  {
        hm_basekit_imagView(imageName, backgroundColor, cornerRadius)
    }
    
}

fileprivate extension UIImageView {
    
    class func hm_basekit_imagView(_ imageName:String) -> Self {
        let imageView = self.init()
        if let image = UIImage(named: imageName) {
            imageView.image = image
        }
        return imageView
    }
    
    class func hm_basekit_imagView(_ imageName:String, _ cornerRadius:CGFloat) -> Self {
        let imageView = hm_basekit_imagView(imageName)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        return imageView
    }
    
    class func hm_basekit_imagView(_ imageName:String, _ backgroundColor: UIColor, _ cornerRadius:CGFloat) -> Self {
        let imageView = hm_basekit_imagView(imageName, cornerRadius)
        imageView.backgroundColor = backgroundColor
        return imageView
    }
    
    /// --- 实例方法
    
    func hm_basekit_imagView(_ imageName:String)  {
        if let image = UIImage(named: imageName) {
            self.image = image
        }
    }
    
    func hm_basekit_imagView(_ imageName:String, _ cornerRadius:CGFloat)  {
        hm_basekit_imagView(imageName)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
    
    func hm_basekit_imagView(_ imageName:String, _ backgroundColor: UIColor,  _ cornerRadius:CGFloat)  {
        hm_basekit_imagView(imageName, cornerRadius)
        self.backgroundColor = backgroundColor
    }
}


