import Foundation
import Basic

public enum HTTPMethod: String {
  case post = "POST"
}

public protocol APIRequest: Encodable {
  associatedtype Response: Decodable

  var url: URL { get }
  var method: HTTPMethod { get }
  var body: Data { get }
}

public protocol APIResponse: Decodable {}
public struct EmptyResponse: APIResponse {}

@available(OSX 10.13, *)
public class NetworkService {
  let session: URLSession = URLSession.shared

  public func send<T: APIRequest>(_ apiRequest: T, completion: @escaping (Result<T.Response, XcodeServerHelpersError>) -> Void) -> Progress {
    var urlRequest = URLRequest(url: apiRequest.url)
    urlRequest.httpMethod = apiRequest.method.rawValue

    switch apiRequest.method {
    case .post:
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      urlRequest.httpBody = apiRequest.body
    }

    let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
      if let error = error {
        completion(.failure(XcodeServerHelpersError.failedToCommunicateWithSlack(error: error.localizedDescription)))
        return
      }
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(XcodeServerHelpersError.unknownError))
        return
      }
      var response: T.Response? = nil
      if let mimeType = httpResponse.mimeType, mimeType == "application/json" {
        let data = data ?? (try! JSONEncoder().encode("")) // always provide some data, so we can rebuild empty responses
        response = try! JSONDecoder().decode(T.Response.self, from: data)
      } else if T.Response.self == String.self, let data = data {
        response = (String(data: data, encoding: .utf8) as! T.Response)
      } else {
        print("Can't decode response")
      }
      guard (200...299).contains(httpResponse.statusCode) else {
        completion(.failure(XcodeServerHelpersError.failedToCommunicateWithSlack(error: "Response: \(String(describing: response))")))
        return
      }
      if let response = response {
        completion(.success(response))
      } else {
        completion(.failure(XcodeServerHelpersError.failedToCommunicateWithSlack(error: "Could not decode response")))
      }
    }
    task.resume()
    return task.progress
  }

  public init() {}
}
