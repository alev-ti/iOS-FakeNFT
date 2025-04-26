import Foundation
import UIKit

protocol RemoveFromCartPresenterProtocol {}

final class RemoveFromCartPresenter: RemoveFromCartPresenterProtocol {
    weak var view: RemoveFromCartViewProtocol?
}
