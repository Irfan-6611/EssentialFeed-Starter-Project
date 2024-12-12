//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Irfan Ahmed on 13/12/2024.
//

import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "https//:a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.requestedURLs, [url])
    }
    
}

// MARK: - Helpers

private class URLSessionSpy: URLSession {
    var requestedURLs = [URL]()
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        requestedURLs.append(url)
        return FakeURLSessionDataTask()
    }
}

private class FakeURLSessionDataTask: URLSessionDataTask {
    
}
