//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Luca Argentino on 18.06.24.
//

import XCTest

class RemoteFeedLoader {
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
