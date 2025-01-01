//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Irfan Ahmed on 13/12/2024.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    public func get(from url: URL, complition: @escaping((HTTPClient.Result) -> Void)) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                complition(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                complition(.success((data, response)))
            }else {
                complition(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
