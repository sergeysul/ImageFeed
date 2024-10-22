import XCTest
import Image_Feed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: Image_Feed.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}

