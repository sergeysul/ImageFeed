import UIKit
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    let key = "Bearer Token"
    private let keychain = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychain.string(forKey: key)
        }
        set {
            if let newValue {
                keychain.set(newValue, forKey: key)
            } else {
                print("Error: Invalid token", #fileID, #function, #line)
            }
        }
    }
    
    func removeToken(){
        keychain.removeObject(forKey: key)
    }
}
