//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Irfan Ahmed on 09/12/2024.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failiur(Error)
}

public protocol HTTPClient {
    func get(from url: URL, complition: @escaping((HTTPClientResult) -> Void))
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidDate
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(complition: @escaping(Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                complition(.invalidDate)
            case .failiur:
                complition(.connectivity)
            }
        }
    }
    
}
