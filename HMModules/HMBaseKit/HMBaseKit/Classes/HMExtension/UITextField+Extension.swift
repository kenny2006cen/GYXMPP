//
//  UITextField+Extension.swift
//  HMBaseKit
//
//  Created by Ko Lee on 2019/8/21.
//

import UIKit

public extension UITextField {
    
    ///初始化TextField  字体大小、字体颜色、提示文字、边框样式 、背景色
    class func hm_textField(_ textColor: UIColor, _ backgroundColor: UIColor, _ font: UIFont, _ placeholder: String, _ borderStyle: UITextField.BorderStyle) -> Self {
        return hm_basekit_textField(textColor, backgroundColor, font, placeholder, borderStyle)
    }
    
    ///初始化TextField 字体大小、字体颜色、提示文字、边框样式
    class func hm_textField(_ textColor: UIColor, _ font: UIFont, _ placeholder: String, _ borderStyle: UITextField.BorderStyle) -> Self {
        return hm_basekit_textField(textColor, font, placeholder, borderStyle)
    }
    
    ///初始化TextField 字体大小、字体颜色、提示文字
    class func hm_textField(_ textColor: UIColor, _ font: UIFont, _ placeholder: String) -> Self {
        return hm_basekit_textField(textColor, font, placeholder)
    }
    
    ///初始化TextField 字体大小、字体颜色
    class func hm_textField(_ textColor: UIColor, _ font: UIFont) -> Self {
        return hm_basekit_textField(textColor, font)
    }
    
    ///设置TextField 字体大小、字体颜色、提示文字、边框样式、背景色
    func hm_textField(_ textColor: UIColor, _ backgroundColor: UIColor, _ font: UIFont, _ placeholder: String, _ borderStyle: UITextField.BorderStyle) {
        hm_basekit_textField(textColor, backgroundColor, font, placeholder, borderStyle)
    }
    
    ///设置TextField 字体大小、字体颜色、提示文字、背景色
    func hm_textField(_ textColor: UIColor, _ backgroundColor: UIColor, _ font: UIFont, _ placeholder: String) {
        hm_basekit_textField(textColor, backgroundColor, font, placeholder)
    }
    
    ///设置TextField 字体大小、字体颜色、背景色
    func hm_textField(_ textColor: UIColor, _ backgroundColor: UIColor, _ font: UIFont) {
        hm_basekit_textField(textColor, backgroundColor, font)
    }
    
    ///设置TextField 字体大小、字体颜色、提示文字、边框样式
    func hm_textField(_ textColor: UIColor, _ font: UIFont, _ placeholder: String, _ borderStyle: UITextField.BorderStyle) {
        hm_basekit_textField(textColor, font, placeholder, borderStyle)
    }
    
    ///设置TextField 字体大小、字体颜色、提示文字
    func hm_textField(_ textColor: UIColor, _ font: UIFont, _ placeholder: String) {
        hm_basekit_textField(textColor, font, placeholder)
    }
    
    ///设置TextField 字体大小、字体颜色
    func hm_textField(_ textColor: UIColor, _ font: UIFont) {
        hm_basekit_textField(textColor, font)
    }
    
    ///设置Placeholder的字体大小和颜色
    func hm_textFieldPlaceholder(_ color: UIColor, _ font: UIFont) {
        hm_basekit_textFieldPlaceholder(color, font)
    }
    
    ///设置LeftView
    func hm_textFieldSetLeftView(_ leftView: UIView?) {
        hm_basekit_textFieldSetLeftView(leftView)
    }
    
    ///设置左边距
    func hm_textFieldSetLeftPadding(_ padding: CGFloat) {
        hm_basekit_textFieldSetLeftPadding(padding)
    }
    
    ///设置RightView
    func hm_textFieldSetRightView(_ rightView: UIView?) {
        hm_basekit_textFieldSetRightView(rightView)
    }
    
    ///修改clear按钮的图片
    func hm_textFieldChangeClearButton(_ imageName: String) {
        hm_basekit_textFieldChangeClearButton(imageName)
    }
    
    ///切圆角
    func hm_textFieldCornerRadius(_ cornerRadius: CGFloat) {
        hm_basekit_textFieldCornerRadius(cornerRadius)
    }
}



fileprivate extension UITextField {
    
    class func hm_basekit_textField(_ textColor: UIColor, _ backgroundColor: UIColor, _ font: UIFont, _ placeholder: String, _ borderStyle: UITextField.BorderStyle) -> Self {
        let textField = self.init()
        textField.textColor = textColor
        textField.font = font
        textField.placeholder = placeholder
        textField.borderStyle = borderStyle
        textField.backgroundColor = backgroundColor
        return textField
    }
    
    class func hm_basekit_textField(_ textColor: UIColor, _ font: UIFont, _ placeholder: String, _ borderStyle: UITextField.BorderStyle) -> Self {
        return hm_basekit_textField(textColor, .clear, font, placeholder, borderStyle)
    }
    
    class func hm_basekit_textField(_ textColor: UIColor, _ font: UIFont, _ placeholder: String) -> Self {
        return hm_basekit_textField(textColor, font, placeholder, .none)
    }
    
    class func hm_basekit_textField(_ textColor: UIColor, _ font: UIFont) -> Self {
        return hm_basekit_textField(textColor, font, "", .none)
    }
    
    //MRK: ----- 实例方法
    
    func hm_basekit_textField(_ textColor: UIColor, _ backgroundColor: UIColor, _ font: UIFont, _ placeholder: String, _ borderStyle: UITextField.BorderStyle) {
        self.textColor = textColor
        self.font = font
        self.placeholder = placeholder
        self.borderStyle = borderStyle
        self.backgroundColor = backgroundColor
    }
    
    func hm_basekit_textField(_ textColor: UIColor, _ font: UIFont, _ placeholder: String, _ borderStyle: UITextField.BorderStyle) {
        hm_basekit_textField(textColor, .clear, font, placeholder, borderStyle)
    }
    
    func hm_basekit_textField(_ textColor: UIColor, _ font: UIFont, _ placeholder: String) {
        self.textColor = textColor
        self.font = font
        self.placeholder = placeholder
    }
    
    func hm_basekit_textField(_ textColor: UIColor, _ backgroundColor: UIColor, _ font: UIFont, _ placeholder: String) {
        self.textColor = textColor
        self.font = font
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
    }
    
    func hm_basekit_textField(_ textColor: UIColor, _ font: UIFont) {
        self.textColor = textColor
        self.font = font
    }
    
    func hm_basekit_textField(_ textColor: UIColor, _ backgroundColor: UIColor, _ font: UIFont) {
        self.textColor = textColor
        self.font = font
        self.backgroundColor = backgroundColor
    }
    
    func hm_basekit_textFieldPlaceholder(_ color: UIColor, _ font: UIFont) {
        if #available(iOS 13.0, *) {
           let arrStr = NSMutableAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: font])
           self.attributedPlaceholder = arrStr
        } else {
           self.setValue(color, forKeyPath: "_placeholderLabel.textColor")
           self.setValue(font, forKeyPath:"_placeholderLabel.font")
        }
    }
    
    func hm_basekit_textFieldSetLeftView(_ leftView: UIView?) {
        if leftView != nil  {
            self.leftView = leftView
            self.leftViewMode = .always
        }
    }
    
    func hm_basekit_textFieldSetLeftPadding(_ padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func hm_basekit_textFieldSetRightView(_ rightView: UIView?) {
        if rightView != nil  {
            self.rightView = rightView
            self.rightViewMode = .always
        }
    }
    
    func hm_basekit_textFieldCornerRadius(_ cornerRadius: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
    
    func hm_basekit_textFieldChangeClearButton(_ imageName: String) {
        if let image = UIImage(named: imageName) {
            let cleaButton:UIButton =  self.value(forKey: "_clearButton") as! UIButton
            cleaButton.setImage(image, for: .normal)
            self.clearButtonMode = .whileEditing
        }
    }
}

