import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}


final class OAuth2Service{
    
    static let shared = OAuth2Service()
    private var urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    private (set) var authToken: String {
        get {
            return OAuth2TokenStorage().token ?? ""
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var baseURL = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Invalid URL")
            return nil
        }
        
        baseURL.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = baseURL.url else {
            print("Error: couldn't get the URL from the components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    
    func fetchAuthToken(
        _ code: String,
        completion: @escaping (Result<String,Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))
                    self.task = nil
                    self.lastCode = nil
                case .failure(let error):
                    print("Failed to get accessToken")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}
