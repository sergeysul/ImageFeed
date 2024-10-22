@testable import Image_Feed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerDidTapLogOut() {

        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.logout()
        
        XCTAssertTrue(presenter.isButtonTapped)
    }

    func testViewControllerCallsViewDidLoad() {
        
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view

        XCTAssertTrue(presenter.isViewDidLoad)
    }
}
