import UIKit
import Foundation
import Image_Feed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol{

    var presenter: ProfilePresenterProtocol?
    var exidButton = true

    func updateAvatar() { }
    func logout() { }
    func showAlert(alert: UIAlertController) { }
    func addSubviews() { }
    func addConstrains() { }
    func configure(_ presenter: any Image_Feed.ProfilePresenterProtocol) { }

}
