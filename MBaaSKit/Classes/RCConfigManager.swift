//
//  RCConfigManager.swift
//  Pods
//
//  Created by Timothy Barnard on 19/02/2017.
//
//
import Foundation
import UIKit

public class RCConfigManager {
    
    private func checkAndGetVersion(_ key: String, version: String) {
        
        UserDefaults.standard.set(key, forKey: version)
    }
    
    class func getColor( name: String, defaultColor: UIColor = .black ) -> UIColor {
        
        guard let returnColor = RCFileManager.readJSONColor(keyVal: name) else {
            return defaultColor
        }
        
        return returnColor
    }
    
    class func getTranslation( name: String, defaultName: String = "") -> String {
        
        guard let returnTranslation = RCFileManager.readJSONTranslation(keyName: name) else {
            return defaultName
        }
        
        return returnTranslation
    }
    
    class func getLangugeList() -> [String] {
        
        let returnVal = [String]()
        
        guard let returnTranslation = RCFileManager.readJSONLanuageList() else {
            return returnVal
        }
        
        return returnTranslation
    }
    
    class func getMainSetting(name: String, defaultName: String = "") -> String {
        
        guard let returnSetting = RCFileManager.readJSONMainSettings(keyName: name ) else {
            return defaultName
        }
        
        return returnSetting
    }
    
    class func getObjectProperties( className: String, objectName: String  ) -> [String:AnyObject] {
        
        return RCFileManager.getJSONDict(parseKey: className, keyVal: objectName)
    }
    
    class func checkIfFilesExist() -> Bool {
        
        if RCFileManager.checkFilesExists(fileName: RCFile.readConfigJSON.rawValue)
            && RCFileManager.checkFilesExists(fileName: RCFile.readLangJSON.rawValue) {
            return true
        } else {
            return false
        }
        
    }
    
    class func getConfigVersion() {
        
        self.getConfigVersion { (completed, data) in
            DispatchQueue.main.async {
                
            }
        }
    }
    
    
    class func updateConfigFiles() {
        //RCFileManager.changeJSONFileName(oldName: RCFile.saveConfigJSON.rawValue, newName: RCFile.readConfigJSON.rawValue)
        //RCFileManager.changeJSONFileName(oldName: RCFile.saveLangJSON.rawValue, newName: RCFile.readLangJSON.rawValue)
        
        guard let doAnalytics = RCFileManager.readConfigVersion("doAnalytics") else {
            return
        }
        UserDefaults.standard.set(doAnalytics, forKey: "doAnalytics")
        //self.checkAndGetVersion("doAnalytics", version: doAnalytics)
        
        guard let version = RCFileManager.readConfigVersion("version") else {
            return
        }
        UserDefaults.standard.set(version, forKey: "version")
        //self.checkAndGetVersion("version", version: version)
    }

    
    /**
     getConfigVersion
     - parameters
     - getCompleted: return value of success state
     - data: return array of objects
     */
    class func getConfigVersion(getCompleted : @escaping (_ succeeded: Bool, _ message: String ) -> ()) {
        
        var version: String = ""
        
        if let buildVersion: AnyObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject? {
            version = buildVersion as! String
        }
        
        var url: String = ""
        url = url.readPlistString(value: "URL", "http://0.0.0.0:8181")
        
        var key: String = ""
        key = key.readPlistString(value: "APPKEY", "")
        
        let apiEndpoint = "/api/"+key+"/remote/" + version
        
        let networkURL = url + apiEndpoint
        
        guard let endpoint = URL(string: networkURL) else {
            print("Error creating endpoint")
            return
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        //if let token = _currentUser?.currentToken {
        //    request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        // }
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if ((error) != nil) {
                getCompleted(false, "error")
            }
            
            guard let data = data else {
                return
            }
            
            RCFileManager.writeJSONFile(jsonData: data as NSData, fileType: .config)
            
            getCompleted(true, "success")
            
            }.resume()
    }
    
}
