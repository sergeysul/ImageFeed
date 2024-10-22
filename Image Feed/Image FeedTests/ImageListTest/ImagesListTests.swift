@testable import Image_Feed
import XCTest

final class ImagesListTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view


        XCTAssertTrue(presenter.isViewDidLoadCall)
    }

    func testGetCellHeightIsCalledCorrect() {
  
        let vc = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        vc.presenter = presenter
        presenter.view = vc
        let thumbImageURL = URL(string: "https://unsplash.com/photos/thumb")!
        let fullImageURL = URL(string: "https://unsplash.com/photos/full")!
        
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: Date(), welcomeDescription: "test", thumbImageURL: thumbImageURL, fullImageURL: fullImageURL, isLiked: false)
            presenter.photos = [photo]
        presenter.photos = [photo]
        let indexPath = IndexPath(row: 0, section: 0)
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

        let cellHeight = presenter.getCellHeight(indexPath: indexPath, tableView: tableView)
        XCTAssertEqual(cellHeight, 0)
    }
}
