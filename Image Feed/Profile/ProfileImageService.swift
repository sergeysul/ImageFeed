import UIKit

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}


final class ProfileImageService {

    static let shared = ProfileImageService()
    private let urlSession = URLSession.shared
    private init() { }
    private var task: URLSessionTask?
    private (set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")


    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let request = makeImageRequest(for: username) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }

            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage.medium

                guard let avatarURL = self.avatarURL else {
                    print("Failed to get avatarURL")
                    return
                }

                completion(.success(avatarURL))
                self.task = nil

                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
            case .failure(let error):
                print("failed to get avatarURL: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()


    }

    private func makeImageRequest(for username: String) -> URLRequest? {
        let baseURL = URL(string: "users/\(username)", relativeTo: Constants.defaultBaseURL)

        guard let url = baseURL else {
            print("Failed to get URL")
            return nil
        }

        guard let authToken = OAuth2TokenStorage().token else {
            assertionFailure("Failed to get authToken")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}
