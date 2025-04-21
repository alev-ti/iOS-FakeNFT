import UIKit

struct AlertModel {
    let title: String?
    let message: String?
    let actions: [Action]

    struct Action {
        let title: String
        let style: UIAlertAction.Style
        let completion: (() -> Void)?

        fileprivate func toUIAlertAction() -> UIAlertAction {
            UIAlertAction(title: title, style: style) { _ in
                completion?()
            }
        }
    }

    func makeAlertController() -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        actions.forEach {
            alertController.addAction($0.toUIAlertAction())
        }

        return alertController
    }
}
