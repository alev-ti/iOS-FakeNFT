import Foundation

protocol SelectCurrencyPresenterProtocol {
    var currencies: [Currency] { get }
    func viewDidLoad()
    func currencyDidSelect(at indexPath: IndexPath)
    func payOrder(with nfts: [String])
}

final class SelectCurrencyPresenter: SelectCurrencyPresenterProtocol {
    weak var view: SelectCurrencyViewProtocol?
    private let currencyService: CurrencyServiceProtocol
    
    var currencies: [Currency] = []
    private var selectedCurrency: IndexPath? {
        didSet {
            view?.updatePayButtonState(selectedCurrency != nil)
        }
    }
    
    init(currencyService: CurrencyServiceProtocol) {
        self.currencyService = currencyService
    }
    
    func viewDidLoad() {
        view?.showLoading()
        
        currencyService.requestCurrencies { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let currencies):
                self.currencies = currencies
                self.view?.updateCollectionView()
            case .failure(let error):
                print("Currency loading error: \(error)")
            }
            
            self.view?.hideLoading()
        }
    }
    
    func currencyDidSelect(at indexPath: IndexPath) {
        guard let view = view else { return }
        
        selectedCurrency = indexPath
        view.toggleSelectAtCell(at: indexPath, isSelected: true)
        view.showLoading()
        
        currencyService.setCurrencyIDBeforePayment(String(indexPath.row)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("Currency set success: \(response.success), ID: \(response.id)")
            case .failure(let error):
                view.toggleSelectAtCell(at: indexPath, isSelected: false)
                print("Currency set error: \(error)")
            }
            
            view.hideLoading()
        }
    }
    
    func payOrder(with nfts: [String]) {
        view?.showLoading()
        
        currencyService.putOrderAndPayRequest(nfts: nfts) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.handlePaymentSuccess()
            case .failure:
                self.handlePaymentFailure()
            }
            
            self.view?.hideLoading()
        }
    }
    
    private func handlePaymentSuccess() {
        print("Payment succeeded")
        CartStore.cartItemIDs.removeAll()
        
        let assembly = SuccessPurchaseAssembly()
        guard let successVC = assembly.assemble() as? SuccessPurchaseViewProtocol else { return }
        
        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve
        
        view?.navigationController?.pushViewController(successVC, animated: true)
    }
    
    private func handlePaymentFailure() {
        print("Payment failed")
        
        let action = AlertModel.Action(
            title: "Повторить",
            style: .default) { [weak self] in
                guard let self = self else { return }
                self.payOrder(with: Array(CartStore.cartItemIDs))
            }
        
        let alert = AlertModel(
            title: "Не удалось произвести оплату",
            message: "",
            actions: [action]
        )
        
        view?.showAlert(alert)
    }
}
