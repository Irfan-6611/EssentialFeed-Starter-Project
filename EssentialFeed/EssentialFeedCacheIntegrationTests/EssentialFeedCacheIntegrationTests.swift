//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Irfan Ahmed on 25/12/2024.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
        
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed  = uniqueImageFeed().models
        
        save(feed, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
        
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models

        save(firstFeed, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformLastSave)

        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let coreDataPath = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: coreDataPath, currentDate: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let loadExp = expectation(description: "wait for load completion")
        sut.load { loadResult in
            switch loadResult {
            case let .success(feedImage):
                XCTAssertEqual(feedImage, expectedFeed, file: file, line: line)
                
            case let .failiur(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(feed) { saveError in
            XCTAssertNil(saveError, "Expected to save feed successfully", file: file, line: line)
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL()-> URL {
        return cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
