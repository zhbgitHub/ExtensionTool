//
//  UITextView+Ext.swift
//  ExtensionTool
//
//  Created by 张崇超 on 2018/7/10.
//  Copyright © 2018年 ZCC. All rights reserved.
//

import UIKit

var k_TextViewPlaceholderKey: Int = 0
var k_TextViewPlaceholderColorKey: Int = 1

extension UITextView {
    
    /// xib
    @IBInspectable var placeholder: String? {
        set {
            self.k_placeholder = newValue
        }
        get { return nil }
    }
    /// xib
    @IBInspectable var placeholderColor: UIColor? {
        set {
            self.k_placeholderColor = newValue
        }
        get { return nil }
    }
    
    /// 占位文字颜色
    var k_placeholderColor: UIColor? {
        
        set {
            
            objc_setAssociatedObject(self, &k_TextViewPlaceholderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            // 占位颜色
            if let placeholder = self.viewWithTag(101) as? UITextView {
                
                placeholder.textColor = newValue
                
            } else {
                
                self.layoutSubviews()
            }
        }
        get {
            
            return objc_getAssociatedObject(self, &k_TextViewPlaceholderColorKey) as? UIColor
        }
    }
    
    /// 占位文字
    var k_placeholder: String? {
        
        set {
            
            if newValue == nil {
                
                // 删除
                self.viewWithTag(101)?.isHidden = true
                return
            }
            objc_setAssociatedObject(self, &k_TextViewPlaceholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let placeholder = self.viewWithTag(101) as? UITextView {
                
                placeholder.isHidden = !(self.text ?? "").isEmpty
            }
            // 接收通知
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextViewTextDidChange, object: nil, queue: OperationQueue.main) { (note) in
                
                if let length = self.k_limitTextLength { self.k_limitTextLength = length }
                
                if let placeholder = self.viewWithTag(101) as? UITextView {
                    
                    placeholder.isHidden = !(self.text.count == 0)
                    
                } else {
                    
                    self.layoutSubviews()
                }
            }
        }
        get {
            
            return objc_getAssociatedObject(self, &k_TextViewPlaceholderKey) as? String
        }
    }
    
    /// 最大文字长度
    var k_limitTextLength: Int? {
        
        set {
            
            if let _ = self.k_placeholder {
                
                if self.text.count >= newValue! { self.text = self.text.k_subText(to: newValue! - 1) }

            } else {
                
                NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextViewTextDidChange, object: nil, queue: OperationQueue.main) { (note) in
                    
                    if self.text.count >= newValue! { self.text = self.text.k_subText(to: newValue! - 1) }
                }
            }
        }
        get { return nil }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let placeholder = self.k_placeholder {
            
            var maskView = self.viewWithTag(101) as? UITextView
            if maskView == nil {
                
                maskView = UITextView.init(frame: self.bounds)
                maskView?.tag = 101
                maskView?.isUserInteractionEnabled = false
                maskView?.text = placeholder
                maskView?.textColor = self.k_placeholderColor ?? UIColor.lightGray
                maskView?.font = self.font ?? UIFont.systemFont(ofSize: 14.0)
                maskView?.backgroundColor = self.backgroundColor

                self.insertSubview(maskView!, at: 0)
            }
            if self != maskView! { maskView?.isHidden = !(self.text.isEmpty) }
        }
    }
}

extension UITextField {
    
    /// xib
    @IBInspectable var placeholderColor: UIColor? {
        set {
            self.k_placeholderColor = newValue
        }
        get { return nil }
    }
    /// 占位文字颜色
    var k_placeholderColor: UIColor? {
        
        set {

            self.setValue(newValue, forKeyPath: "_placeholderLabel.textColor")
        }
        get { return nil }
    }
    
    /// 最大文字长度
    var k_limitTextLength: Int? {
        
        set {
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nil, queue: OperationQueue.main) { (note) in
                
                if let text = self.text {
                    
                    if text.count >= newValue! { self.text = text.k_subText(to: newValue! - 1) }
                }
            }
        }
        get { return nil }
    }
}
