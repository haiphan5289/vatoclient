import FwiCore
import UIKit

extension UIViewController {
    /// Present action sheet.
    ///
    /// - parameters:
    ///   - title: {String} (an action sheet's title)
    ///   - message: {String} (an instruction message)
    ///   - actions: {[UIAlertAction]} (a list of actions without cancel action)
    ///   - cancelAction: {UIAlertAction} (a cancel action)
    func presentActionSheet(withTitle t: String?, message m: String?, actions a: [UIAlertAction], cancelAction cancel: UIAlertAction = UIAlertAction(title: Text.cancel.text, style: .cancel, handler: nil), from view: UIView? = nil, direction d: UIPopoverArrowDirection = .any) {
        let alert = UIAlertController(title: t, message: m, preferredStyle: .actionSheet)
        defer {
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true, completion: nil)
            }
        }

        a.forEach {
            alert.addAction($0)
        }
        alert.addAction(cancel)

        if UIApplication.isPad {
            alert.modalPresentationStyle = .popover

            let presenter = alert.popoverPresentationController
            if let view = view {
                presenter?.sourceView = view
                presenter?.permittedArrowDirections = d
            } else {
                presenter?.sourceView = self.view
                presenter?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)

                let frame = UIScreen.main.bounds
                presenter?.sourceRect = CGRect(x: frame.midX, y: frame.midY, width: 0.0, height: 0.0)
            }
        }
    }

    /// Present alert view.
    ///
    /// - parameters:
    ///   - title: {String} (an alert view's title)
    ///   - message: {String} (an instruction message)
    ///   - actions: {[UIAlertAction]} (a list of actions)
    ///   - cancelAction: {UIAlertAction} (a cancel action)
    func presentAlert(withTitle t: String?, message m: String?, actions a: [UIAlertAction] = [], cancelAction cancel: UIAlertAction = UIAlertAction(title: Text.dismiss.text, style: .cancel, handler: nil)) {
        let alert = UIAlertController(title: t, message: m, preferredStyle: .alert)
        defer {
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true, completion: nil)
            }
        }

        a.forEach {
            alert.addAction($0)
        }
        alert.addAction(cancel)
    }
}
