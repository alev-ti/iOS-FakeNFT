import UIKit

struct AlertModel {
    let title: String?
    let message: String?
    let actions: [Action]
    let preferredStyle: UIAlertController.Style

    init(
        title: String?,
        message: String?,
        actions: [Action],
        preferredStyle: UIAlertController.Style = .alert
    ) {
        self.title = title
        self.message = message
        self.actions = actions
        self.preferredStyle = preferredStyle
    }

    struct Action {
        let title: String
        let style: UIAlertAction.Style
        let completion: (() -> Void)?
        
        fileprivate func toUIAlertAction() -> UIAlertAction {
            UIAlertAction(title: title, style: style) { _ in
                self.completion?()
            }
        }
    }

    func makeAlertController() -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle
        )
        
        actions.forEach {
            alertController.addAction($0.toUIAlertAction())
        }
        
        return alertController
    }
}
