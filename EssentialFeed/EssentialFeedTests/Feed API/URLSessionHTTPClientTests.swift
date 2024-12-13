//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Irfan Ahmed on 13/12/2024.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failiur(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumeDataTaskWithURL() {
        
        let url = URL(string: "https//:a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url, task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount , 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https//:a-url.com")!
        let error = NSError(domain: "Domain Error", code: 1)
        let session = URLSessionSpy()
        session.stub(url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for execution")
        sut.get(from: url) { result in
            
            switch result {
            case let .failiur(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
                
            default:
                XCTFail("XPected")
            }
            
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        
    }
    
}

// MARK: - Helpers

private class URLSessionSpy: URLSession {
    
    private var stubs = [URL: Stub]()
    
    private struct Stub {
        var task: URLSessionDataTask
        var error: Error?
    }
    
    func stub(_ url: URL, _ task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
        stubs[url] = Stub(task: task, error: error)
    }
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        
        guard let stub = stubs[url] else {
            fatalError("")
        }
        completionHandler(nil, nil, stub.error)
        return stub.task
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
