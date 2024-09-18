import UIKit


final class OAuth2Service{
    static let shared = OAuth2Service()
    
    private var urlSession = URLSession.shared
    
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
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error is creating the OAuth token request")
            return
        }
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody,Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        return urlSession.data(for: request ) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result {
                    try decoder.decode(OAuthTokenResponseBody.self, from: data)
                }
            }
            completion(response)
        }
    }
}
