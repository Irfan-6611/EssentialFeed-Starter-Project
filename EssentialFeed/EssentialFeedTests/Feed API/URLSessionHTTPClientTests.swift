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
        session.dataTask(with: url) { _, _, _ in }.resume()
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
    
    func test_getFromURL_resumeDataTaskWithURL() {
        
        let url = URL(string: "https//:a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url, task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount , 1)
    }
    
}

// MARK: - Helpers

private class URLSessionSpy: URLSession {
    var requestedURLs = [URL]()
    
    private var stubs = [URL: URLSessionDataTask]()
    func stub(_ url: URL, _ task: URLSessionDataTask) {
        stubs[url] = task
    }
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        requestedURLs.append(url)
        return stubs[url] ?? FakeURLSessionDataTask()
    }
}

private class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() {
        
    }
}
private class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeCallCount = 0
    
    override func resume() {
        resumeCallCount += 1
    }
}
