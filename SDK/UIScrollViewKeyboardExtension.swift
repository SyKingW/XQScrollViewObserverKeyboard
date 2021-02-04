//
//  UIScrollViewKeyboardExtension.swift
//  VensiMqttDemo
//
//  Created by WXQ on 2021/2/3.
//

import UIKit

public extension UIScrollView {
    
    /// 监听键盘，改变滚动大小
    @objc func xq_addObserverKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(notification_keyboarWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notification_keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 移除键盘的监听
    /// 一般来说不用去调用这个
    @objc func xq_removeObserverKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    private struct AssociatedKeys {
        static var lastContentSizeNameKey = "xq_lastContentSize"
    }
    
    private var xq_lastContentSize: CGSize? {
        set {
            if let size = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.lastContentSizeNameKey, NSValue.init(cgSize: size), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }else {
                objc_setAssociatedObject(self, &AssociatedKeys.lastContentSizeNameKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.lastContentSizeNameKey) as? NSValue {
                return value.cgSizeValue
            }
            return nil
        }
    }
    
    // MARK: - notification
    
    @objc private func notification_keyboarWillShow(_ notification: Notification) {
//        print(notification)
        
        if let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyBoardRect = endFrame.cgRectValue
            let scrollViewToWindowRect = self.convert(self.frame, to: UIApplication.shared.windows.first)
            
//            print("wxq: ", keyBoardRect, scrollViewToWindowRect)
            
            // 已经完全被遮挡，不需要进行什么判断了
            if scrollViewToWindowRect.minY > keyBoardRect.minY {
                return
            }
            
            if keyBoardRect.minY > scrollViewToWindowRect.maxY {
                // 视图不被遮挡
                return
            }
            
            if keyBoardRect.minY > scrollViewToWindowRect.minY + self.contentSize.height {
                // 滚动内容不被遮挡
                return
            }
            
            // 需要增加滚动范围
            
            // 记录当前大小
            self.xq_lastContentSize = self.contentSize
            
            
            // 获取子视图最大的y
            var subViewMaxY: CGFloat = 0
            for item in self.subviews {
                // 一般系统的私有类，才有下划线
                if NSStringFromClass(item.classForCoder).hasPrefix("_") {
                    continue
                }
                // 隐藏的视图忽略
                if item.isHidden || item.alpha == 0 {
                    continue
                }
                
                if item.frame.maxY > subViewMaxY {
                    subViewMaxY = item.frame.maxY
                }
            }
            
            let differHeight = scrollViewToWindowRect.maxY - keyBoardRect.minY
            if subViewMaxY > self.bounds.height {
                // 超过滚动视图本身了
                self.contentSize.height += (differHeight)
            }else {
                self.contentSize.height = (subViewMaxY + differHeight)
            }
            
            // 其实这里还可以做一个检测是哪个输入框是焦点
            // 然后滚动到焦点的输入框
            
        }
        
    }
    
    @objc private func notification_keyboardWillHide(_ notification: Notification) {
//        print(notification)
        if let size = self.xq_lastContentSize {
            self.contentSize = size
        }
    }
    
    
    
}
