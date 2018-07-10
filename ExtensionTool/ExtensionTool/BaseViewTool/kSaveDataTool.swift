//
//  kSaveDataTool.swift
//  ExtensionTool
//
//  Created by 张崇超 on 2018/7/10.
//  Copyright © 2018年 ZCC. All rights reserved.
//

import UIKit

class kSaveDataTool: NSObject {

    //MARK: 保存值到偏好设置
    /// 保存值到偏好设置
    ///
    /// - Parameters:
    ///   - key: 键
    ///   - value: 值/nil
    @discardableResult
    static func k_addValueToUserdefault(key: String, value: String) -> Bool {
        
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        
        return self.k_checkValueFromUserdefault(key: key) != nil
    }
    
    //MARK: 删除偏好设置保存的值
    /// 删除偏好设置保存的值
    ///
    /// - Parameter key: 键
    /// - Returns: 结果
    @discardableResult
    static func k_deleteValueFromUserdefault(key: String) -> Bool {
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
        
        return self.k_checkValueFromUserdefault(key: key) == nil
    }
    
    //MARK: 更新偏好设置保存的值
    /// 更新偏好设置保存的值
    ///
    /// - Parameters:
    ///   - key: 键
    ///   - value: 值
    /// - Returns: 结果
    @discardableResult
    static func k_updateValueFromUserdefault(key: String, value: String) -> Bool {
        
        return self.k_addValueToUserdefault(key: value, value: key)
    }
    
    //MARK: 获取偏好设置保存的值
    /// 获取偏好设置保存的值
    ///
    /// - Parameter key: 键
    /// - Returns: 值/nil
    static func k_checkValueFromUserdefault(key: String) -> String? {
        
        return UserDefaults.standard.value(forKey: key) as? String
    }
    
    //MARK: 保存密码到钥匙串
    /// 保存/更新密码到钥匙串
    ///
    /// - Parameters:
    ///   - account: 账号
    ///   - password: 密码
    /// - Returns: 结果
    @discardableResult
    static func k_saveOrUpdatePassword(account: String, password: String) -> Bool {
        
        let dic = self.getQueryDic(account: account)
        let psdData: Data = password.data(using: .utf8)!
        
        // 是否已存在
        var result: CFTypeRef? = nil
        var state: OSStatus = SecItemCopyMatching(dic, &result)
        if state == errSecItemNotFound {
            
            // 不存在
            dic.setObject(psdData, forKey: kSecValueData as! NSCopying)
            state = SecItemAdd(dic, nil)
            
        } else if state == errSecSuccess {
            
            // 已存在
            self.k_deletePassword(account: account)
            self.k_saveOrUpdatePassword(account: account, password: password)
        }
        return state == errSecSuccess
    }
    
    //MARK: 删除钥匙串保存的密码
    /// 删除钥匙串保存的密码
    ///
    /// - Parameter key: 键
    /// - Returns: 结果
    @discardableResult
    static func k_deletePassword(account: String) -> Bool {
        
        let dic = self.getQueryDic(account: account)
        dic.setObject(kCFBooleanTrue, forKey: kSecReturnData as! NSCopying)
        
        return SecItemDelete(dic) == errSecSuccess
    }
    
    //MARK: 获取钥匙串保存的密码
    /// 获取钥匙串保存的密码
    ///
    /// - Parameter key: 键
    /// - Returns: 值/nil
    static func k_getPassword(account: String) -> String? {
        
        let dic = self.getQueryDic(account: account)
        dic.setObject(kCFBooleanTrue, forKey: kSecReturnData as! NSCopying)
        
        var result: CFTypeRef? = nil
        let state: OSStatus = SecItemCopyMatching(dic, &result)
        if state != errSecSuccess { return nil }
        
        return String(data: result as! Data, encoding: .utf8)
    }
    
    /// 根据账号 创建查询字典
    ///
    /// - Parameter account: 账号
    /// - Returns: 字典
    private static func getQueryDic(account: String) -> NSMutableDictionary {
        
        let dic = NSMutableDictionary.init()
        // 唯一标记符
        dic.setObject("com.zcc.keyChainTool", forKey: kSecAttrService as! NSCopying)
        // 保存账号
        dic.setObject(account, forKey: kSecAttrAccount as! NSCopying)
        // 保存密码
        dic.setObject(kSecClassGenericPassword, forKey: kSecClass as! NSCopying)
        
        return dic
    }
    
}
