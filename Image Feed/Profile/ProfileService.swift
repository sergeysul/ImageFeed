import UIKit

struct ProfileResult: Codable{
    let userName: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile{
    let userName: String
    let name: String
    let loginName: String
    let bio: String
    
    init(result: ProfileResult){
        self.userName = result.userName
        self.name = ("\(result.firstName) \(result.lastName ?? "")")
        self.loginName = ("@\(result.userName)")
        self.bio = result.bio ?? ""
    }
}

enum ProfileServiceError: Error{
    case invalidRequest
}


final class ProfileService{
    
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: Profile?
    
    private init(){
        
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeBaseRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.profile = Profile(result: result)
                guard let profileData = self.profile else {
                    print("Error of profileData")
                    return
                }
                completion(.success(profileData))
                self.task = nil
                
            case .failure(let error):
                print("Error: Failed to get profileData: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
    
    
    private func makeBaseRequest(token: String) -> URLRequest? {
        
        let baseURL = URL(string: "/me", relativeTo: Constants.defaultBaseURL)

        guard let url = baseURL else {
            print("Failed to create URL")
            return nil
         }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
     }
}
