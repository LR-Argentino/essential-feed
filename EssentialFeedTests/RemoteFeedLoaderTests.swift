//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luca Argentino on 18.06.24.
//

import XCTest
import EssentialFeed


final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "htttps://www.give-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
         
        XCTAssertEqual(client.requestedURL, url)
    }
    
    func test_loadTwice_requestDataFromURL() {
        let url = URL(string: "htttps://www.give-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
         
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    private func makeSUT(url: URL = URL(string: "htttps://www.give-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        return (sut, client)
    }
    
   private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
        var requestedURLs = [URL]()

        func get(from url: URL) {
            requestedURL = url
            requestedURLs.append(url)
        }
    }
}
