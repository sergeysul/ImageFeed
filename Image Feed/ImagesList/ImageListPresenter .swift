import UIKit

public protocol ImageListPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func getCellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat
    func updateTableViewAnimated()
}

final class ImageListPresenter: ImageListPresenterProtocol {

    weak var view: ImageListViewControllerProtocol?
    var imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?

    var photos: [Photo] = []

    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else {return}
            self.updateTableViewAnimated()
        }
        imagesListService.fetchPhotoNextPage()
    }

    func getCellHeight(indexPath: IndexPath, tableView: UITableView) -> CGFloat {
        let image = photos[indexPath.row]

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom

        return cellHeight
    }

    func like(_ cell: ImagesListCell, tableView: UITableView) {

    }

    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
            }
            view?.updateTableViewAnimated(indexPaths)
        }
    }


}
