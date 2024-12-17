//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Irfan Ahmed on 17/12/2024.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCacheFeedCallCount = 0
    
    func deleteCachedFeed() {
        deleteCacheFeedCallCount += 1
    }
}

class LocalFeedLoader {
    private let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()

        sut.save([anyFeedItem(), anyFeedItem()])
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                    line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
    }
    
    private func anyFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "Any Desc", location: "Any Location", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any.url.com")!
    }
    
}
