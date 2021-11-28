//
//  SettingsConfig.swift
//  MarcosApostolo
//
//  Created by Marcos Apóstolo on 18/11/21.
//

import Foundation

class SettingsConfig {
    static let shared: SettingsConfig = {
        return SettingsConfig()
    }()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        
    }
    
    func configureSettingsBundle() {
        guard let settingsBundle = Bundle.main.url(forResource: "Settings", withExtension:"bundle") else {
            return;
        }
        
        guard let settings = NSDictionary(contentsOf: settingsBundle.appendingPathComponent("Root.plist")) else {
            return
        }
        
        guard let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [[String: AnyObject]] else {
            return
        }
        
        var defaultsToRegister = [String: AnyObject]()
        
        for pref in preferences {
            if let key = pref["Key"] as? String, let val = pref["DefaultValue"] {
                print("\(key)==> \(val)")
                defaultsToRegister[key] = val
            }
        }
        
        userDefaults.register(defaults: defaultsToRegister)
        userDefaults.synchronize()
    }
}
