import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T,Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        return data(for: request ) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<T, Error> in
                Result {
                    do {
                        return try decoder.decode(T.self, from: data)
                    } catch {
                        print("Error: Failed data decoding")
                        throw error
                    }
                }
            }
            completion(response)
        }
    }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                    print("Success Status: \(statusCode)")
                } else {
                    print("Error: \(NetworkError.httpStatusCode(statusCode))")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("Error: \(NetworkError.urlRequestError(error))")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("Error: \(NetworkError.urlSessionError)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}

