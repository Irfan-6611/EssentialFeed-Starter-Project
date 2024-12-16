//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Irfan Ahmed on 08/12/2024.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in }
        sut.load {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failiur(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
                
        let sample = [199, 201, 300, 400, 500]
        sample.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: failiur(.invalidDate)) {
                let data = makeItemsJSON([])
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }

    func test_load_deliverErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
                
        expect(sut, toCompleteWith: failiur(.invalidDate)) {
            let inValidJson = Data("Hello world".utf8)
            client.complete(withStatusCode: 200, data: inValidJson)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
                
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        
        let item1 = makeItems(id: UUID(), imageURL: URL(string: "https//:a-url.com")!)
        
        let item2 = makeItems(id: UUID(), description: "a description", location: "Location", imageURL: URL(string: "https//:a-given-url.com")!)
                
        let items = [item1.model, item2.model]
        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemsJSON([item1.jsonItem, item2.jsonItem])
            client.complete(withStatusCode: 200, data: json)
        }
        
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDeallocated() {
        let url = URL(string: "https//:a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResult = [RemoteFeedLoader.Result]()
        sut?.load { capturedResult.append($0)}
        
        sut = nil
        
        let json = makeItemsJSON([])
        client.complete(withStatusCode: 200, data: json)
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
// MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
        
    private func makeItems(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, jsonItem: [String: Any]){
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues { $0 }

        
       return (item, json)
        
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = [ "items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failiur(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failiur(error)
    }
    
    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let(.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let(.failiur(receivedError as RemoteFeedLoader.Error), .failiur(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
            
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, complition: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, complition: @escaping(HTTPClientResult) -> Void) {
            messages.append((url, complition))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].complition(.failiur(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].complition(.success(data, response))
        }

    }
    
}
