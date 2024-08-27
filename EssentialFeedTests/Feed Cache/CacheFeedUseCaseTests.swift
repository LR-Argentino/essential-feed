//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Luca Argentino on 27.08.2024.
//

import XCTest

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
}

class LocalFeedLoader {
    init (store: FeedStore) {
        
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
