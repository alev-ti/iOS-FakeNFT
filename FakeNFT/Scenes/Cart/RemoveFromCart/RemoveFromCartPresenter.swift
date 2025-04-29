import Foundation

protocol RemoveFromCartPresenterProtocol {}

final class RemoveFromCartPresenter: RemoveFromCartPresenterProtocol {
    weak var view: RemoveFromCartViewProtocol?
}
