import Foundation
import UIKit

enum SortingMethod: String {
    case price
    case name
    case rating
    
    var displayName: String {
        switch self {
            case .price: return Localizable.Sorting.price
            case .name: return Localizable.Sorting.name
            case .rating: return Localizable.Sorting.rating
        }
    }
}

protocol SortingDelegate: AnyObject {
    func didSelectSortingMethod(_ method: SortingMethod)
}

final class SortingManager {
    private enum Constants {
        static let cancelButtonTitle = Localizable.Sorting.cancelButtonTitle
        static let alertTitle = Localizable.Sorting.alertTitle
        static let userDefaultsKey = "selectedSortingMethod"
    }
    
    static var currentSortingMethod: SortingMethod {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: Constants.userDefaultsKey),
                  let method = SortingMethod(rawValue: rawValue) else {
                return .name
            }
            return method
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Constants.userDefaultsKey)
        }
    }
    
    static func makeSortingAlert(for delegate: SortingDelegate) -> AlertModel {
        let methods: [SortingMethod] = [.price, .name, .rating]
        
        let sortingActions = methods.map { method in
            AlertModel.Action(
                title: method.displayName,
                style: .default
            ) {
                currentSortingMethod = method
                delegate.didSelectSortingMethod(method)
            }
        }
        
        let cancelAction = AlertModel.Action(
            title: Constants.cancelButtonTitle,
            style: .cancel,
            completion: nil
        )
        
        return AlertModel(
            title: Constants.alertTitle,
            message: nil,
            actions: sortingActions + [cancelAction],
            preferredStyle: .actionSheet
        )
    }
}
