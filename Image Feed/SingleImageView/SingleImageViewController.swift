import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController{
    var image: UIImage?{
        didSet{
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var imageURL: Photo?
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    
        guard let imageURL else { return }
        openImage(photo: imageURL)
        
    }
    
    private func openImage(photo: Photo) {
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: photo.fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else {return}
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                print("[SingleImageViewController]:[setImage]: Error getting single image")
            }
        }
        imageView.frame.size = photo.size
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}


    
