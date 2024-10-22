import UIKit
import Foundation
import Image_Feed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var view: ProfileViewControllerProtocol?
    var isButtonTapped = false
    var isViewDidLoad = false

    func viewDidLoad() { isViewDidLoad = true }
    func logout() { isButtonTapped = true }
    func getProfile() -> Image_Feed.Profile? { return nil }
    func getAvatarUrl() -> URL? { return nil }
}
