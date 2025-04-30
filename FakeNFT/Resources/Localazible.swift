import Foundation

enum Localizable {
    enum RemoveFromCart {
        static let labelText = NSLocalizedString("RemoveFromCart.labelText", comment: "")
        static let removeBtnText = NSLocalizedString("RemoveFromCart.removeBtnText", comment: "")
        static let returnBtnText = NSLocalizedString("RemoveFromCart.returnBtnText", comment: "")
    }
    
    enum CartView {
        static let costString = NSLocalizedString("Cart.price", comment: "")
        static let payButtonString = NSLocalizedString("Cart.toPayment", comment: "")
        static let emptyCartLabelString = NSLocalizedString("Cart.cartIsEmpty", comment: "")
    }
    
    enum Sorting {
        static let price = NSLocalizedString("Sorting.price", comment: "")
        static let name = NSLocalizedString("Sorting.name", comment: "")
        static let rating = NSLocalizedString("Sorting.rating", comment: "")
        static let cancelButtonTitle = NSLocalizedString("Sorting.cancelButtonTitle", comment: "")
        static let alertTitle = NSLocalizedString("Sorting.alertTitle", comment: "")
    }
}
