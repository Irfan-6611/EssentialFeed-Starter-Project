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
    
    struct UnexpectedValuesRepresentation: Error {}
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failiur(error))
            } else {
                completion(.failiur(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    
//    func test_getFromURL_performGETRequestWithURL() {
//        let url = anyURL()
//        
//        let exp = expectation(description: "wait for request")
//        
//        URLProtocolStub.observeRequests { request in
//            XCTAssertEqual(request.httpMethod, "GET")
//            XCTAssertEqual(request.url, url)
//            exp.fulfill()
//        }
//        
//        makeSUT().get(from: url) { _ in }
//        
//        wait(for: [exp], timeout: 1.0)
//    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let exp = expectation(description: "wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failiur(receivedError as NSError):
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected failiur with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_get_From_URL_failsOnAllNilValues() {
        
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let exp = expectation(description: "wait for completion")
        
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .failiur:
                break
            default:
                XCTFail("Expected failiur, got \(result) instead")
            }
            
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}

// MARK: - Helpers

private class URLProtocolStub: URLProtocol {
    
    private static var stub: Stub?
    
    private static var requestObserver: ((URLRequest) -> Void)?
    
    private struct Stub {
        var data: Data?
        var response: URLResponse?
        var error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }
    
    static func startInterceptingRequest() {
        URLProtocol.registerClass(self)
    }
    
    static func stopInterceptingRequest() {
        URLProtocol.unregisterClass(self)
        stub = nil
        requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() { }
}
