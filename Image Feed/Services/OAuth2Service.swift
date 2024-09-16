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
        let baseURL = URL(string: "https://unsplash.com")
        let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        )!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchAuthToken(
        _ code: String,
        complition: @escaping (Result<String,Error>) -> Void
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
                    complition(.success(authToken))
                case .failure(let error):
                    complition(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func object(
        for request: URLRequest,
        complition: @escaping (Result<OAuthTokenResponseBody,Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        return urlSession.data(for: request ) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result {
                    try decoder.decode(OAuthTokenResponseBody.self, from: data)
                }
            }
            complition(response)
        }
    }
}
