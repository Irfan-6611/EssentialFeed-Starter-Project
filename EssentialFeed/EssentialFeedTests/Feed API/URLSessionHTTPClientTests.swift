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
    
    init(session: URLSession = .shared) {
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
        
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        
        let url = URL(string: "https://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        
        URLProtocolStub.stub(url, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failiur(receivedError as NSError):
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("XPected")
            }
            
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        
        URLProtocolStub.stopInterceptingRequest()
        
    }
    
}

// MARK: - Helpers

private class URLProtocolStub: URLProtocol {
    
    private static var stubs = [URL: Stub]()
    
    private struct Stub {
        var error: Error?
    }
    
    static func stub(_ url: URL, error: Error? = nil) {
        stubs[url] = Stub(error: error)
    }
    
    static func startInterceptingRequest() {
        URLProtocol.registerClass(self)
    }
    
    static func stopInterceptingRequest() {
        URLProtocol.unregisterClass(self)
        stubs = [:]
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        
        return URLProtocolStub.stubs[url] != nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}
