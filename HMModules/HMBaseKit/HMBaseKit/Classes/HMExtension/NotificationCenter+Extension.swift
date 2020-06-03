//
//  NotificationCenter+Extension.swift
//  HMBaseKit
//
//  Created by Ko Lee on 2019/9/20.
//

import UIKit

public extension NotificationCenter {
    
    static func hm_addObserver(name: String, object: Any?, queue: OperationQueue?, using: @escaping (Notification) -> Void)  {
        self.default.addObserver(forName: NSNotification.Name.init(rawValue: name), object: object, queue: queue, using: using)
    }
    
    static func hm_addObserver(_ observer: Any, _ selector: Selector, _ name: String, object anObject: Any?) {
        self.default.addObserver(observer, selector: selector, name: NSNotification.Name.init(rawValue: name), object: anObject)
    }
    
    static func hm_post(_ notification: Notification) {
        self.default.post(notification)
    }
    
    static func hm_post(_ name: String, _ object: Any?) {
        self.default.post(name: NSNotification.Name.init(rawValue: name), object: object)
    }
    
    static func hm_post(_ name: String, _ object: Any?, _ userInfo: [AnyHashable : Any]? = nil) {
        self.default.post(name: NSNotification.Name.init(rawValue: name), object: object, userInfo: userInfo)
    }
    
    static func hm_removeObserver(_ observer: Any) {
        self.default.removeObserver(observer)
    }
    
    static func hm_removeObserver(_ observer: Any, name: String, object: Any?) {
        self.default.removeObserver(observer, name: NSNotification.Name.init(rawValue: name), object: object)
    }
}
