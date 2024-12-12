//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Irfan Ahmed on 09/12/2024.
//

import Foundation

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failiur(Error)
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidDate
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(complition: @escaping(Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let items = try FeedItemsMapper.map(data, response)
                    complition(.success(items))
                } catch {
                    complition(.failiur(.invalidDate))
                }
            case .failiur:
                complition(.failiur(.connectivity))
            }
        }
    }
}
