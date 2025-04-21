import Foundation
import UIKit

final class CartStore {
    private enum Constants {
        static let cartItemsKey = "NFTsInCart"
        static let cartChangedNotificationName = "CartStoreCartChanged"
    }
    
    static let cartChangedNotification = Notification.Name(Constants.cartChangedNotificationName)
    static var NFTLargeImageURL: URL?
    
    static var cartItemIDs: Set<String> {
        get {
            guard let data = UserDefaults.standard.data(forKey: Constants.cartItemsKey),
                  let NFTIDs = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return Set(NFTIDs)
        }
        set {
            let array = Array(newValue)
            if let data = try? JSONEncoder().encode(array) {
                UserDefaults.standard.set(data, forKey: Constants.cartItemsKey)
            }
            
            NotificationCenter.default.post(name: cartChangedNotification, object: nil)
        }
    }
}
