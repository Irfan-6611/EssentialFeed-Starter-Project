//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Irfan Ahmed on 17/12/2024.
//

import XCTest


class FeedStore {
    var deleteCacheFeedCallCount = 0
}

class LocalFeedLoader {
    init(store: FeedStore) {
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
}
