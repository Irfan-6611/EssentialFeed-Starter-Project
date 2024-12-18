//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Irfan Ahmed on 09/12/2024.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public typealias Result = LoadFeedResult
  
    public enum Error: Swift.Error {
        case connectivity
        case invalidDate
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping(LoadFeedResult) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, from: response))
            case .failiur:
                completion(.failiur(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModel())
        } catch {
            return .failiur(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModel() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}
