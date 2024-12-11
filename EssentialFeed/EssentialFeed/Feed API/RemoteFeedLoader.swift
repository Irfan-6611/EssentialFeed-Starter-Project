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

private struct FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static func map(_ data: Data, _ response: HTTPURLResponse ) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidDate
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}
