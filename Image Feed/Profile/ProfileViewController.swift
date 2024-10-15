import UIKit
import Kingfisher
import SwiftKeychainWrapper
import WebKit

final class ProfileViewController: UIViewController {
    
    private var profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    var avatarImageView: UIImageView = {
        let avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.image = UIImage(named: "avatar")
        avatar.heightAnchor.constraint(equalToConstant: 70).isActive = true
        avatar.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatar.contentMode = .scaleAspectFit
        
        return avatar
    }()
    
    var namelabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 23)
        return label
    }()
    
    var loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    var logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        addSubviews()
        addConstrains()
        
        guard let profile = profileService.profile else {
            print("Error profile data")
            return
        }
        updateProfileDetails(profile: profile)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    func updateAvatar(){
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            print("Error:", #fileID, #function)
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35, backgroundColor: UIColor(named: "YP Black"))
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "Placeholder"), options: [.processor(processor)])
    }
    
    private func updateProfileDetails(profile: Profile){
        namelabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func addSubviews() {
        view.addSubview(avatarImageView)
        view.addSubview(namelabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func addConstrains() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            namelabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            namelabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            loginNameLabel.topAnchor.constraint(equalTo: namelabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Вы вышли из профиля", message: .none, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "ОК", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func logout() {
        
        cleanCookies()
        KeychainWrapper.standard.removeObject(forKey: "Bearer Token")

        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }

    func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func showAlertLogout() {
        let alert = UIAlertController(title: "Пока, Пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.logout()
        }
        let noButton = UIAlertAction(title: "Нет", style: .default, handler: nil)
        alert.addAction(yesButton)
        alert.addAction(noButton)
        present(alert, animated: true)
    }

    @objc
    private func didTapLogoutButton() {
        showAlertLogout()
    }
}
