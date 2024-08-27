//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Luca Argentino on 27.08.2024.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init (store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
    

}

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        let deletionError = anyError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    // MARK: - Helpers
    private func uniqueItems() -> FeedItem {
        return FeedItem(id: UUID(), description: "any description", location: "any location", imageURL: URL(string: "www.any-image.com")!)
    }
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (sut, store)
    }
    
    private func anyError() -> Error {
        let error = NSError(domain: "any", code: 0, userInfo: nil)
        return error
    }
}
