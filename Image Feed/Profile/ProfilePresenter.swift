import UIKit

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
    func getProfile() -> Profile?
    func getAvatarUrl() -> URL?
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    func viewDidLoad() {
        view?.addSubviews()
        view?.addConstrains()
    }

    func logout() {
        let alert = UIAlertController(title: "Пока, Пока!",
                                      message: "Уверены что хотите выйти?",
                                      preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Да", style: .default) { _ in
            self.view?.logout()
        }
        let noButton = UIAlertAction(title: "Нет", style: .default)
        
        yesButton.accessibilityIdentifier = "Да"
        alert.addAction(yesButton)
        alert.addAction(noButton)
        alert.preferredAction = noButton
        view?.showAlert(alert: alert)
    }


    func getProfile() -> Profile? {
        guard let profile = ProfileService.shared.profile else {
            return nil
        }

        return profile
    }

    func getAvatarUrl() -> URL? {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return nil
        }

        return url
    }

}
