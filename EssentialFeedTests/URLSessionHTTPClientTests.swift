//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Luca Argentino on 01.08.2024.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init (session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInteceptingRequest()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let url = URL(string: "http://wrong-url.com")!
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from: url) {_ in}
        wait(for: [exp], timeout: 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "www.apple.com")!
        let error = NSError(domain: "any", code: 0, userInfo: nil)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(recievedError as NSError):
                XCTAssertNotNil(recievedError)
            default:
                XCTFail("Expected failure but got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(ile: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: #file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
    
        
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInteceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func stub(data: Data?, response:  HTTPURLResponse? ,error: Error?) {
            stub = Stub(data: data, response: response, error: error)
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
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        
    }
}
