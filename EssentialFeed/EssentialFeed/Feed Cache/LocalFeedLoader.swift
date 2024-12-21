//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Irfan Ahmed on 18/12/2024.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult

    public init(store: FeedStore, currentDate: @escaping () -> Date ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toModel(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { error in
            if let retrievalError = error {
                completion(.failiur(retrievalError))
            } else {
                completion(.success([]))
            }
        }
    }
}

private extension Array where Element == FeedImage {
    func toModel() -> [LocalFeedImage] {
        return map({LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)})
    }
}
