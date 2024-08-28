//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Luca Argentino on 27.08.2024.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        
        sut.save(items) { _ in}
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItems(), uniqueItems()]
        let deletionError = anyError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItems(), uniqueItems()]
        let localFeedItems = items.map{
            LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)
        }
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(localFeedItems, timestamp: timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyError()
        
        expect(sut, toCompleteWithError: deletionError as NSError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyError()
        
        expect(sut, toCompleteWithError: insertionError as NSError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_succeedsOnSuccessfullCacheInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }
    
    func test_save_doesNotDelieverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recievedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItems()]) { recievedResults.append($0)}
        
        sut = nil
        store.completeDeletion(with: anyError())
        XCTAssertTrue(recievedResults.isEmpty)
    }
    
    func test_save_doesNotDelieverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var recievedResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItems()]) { recievedResults.append($0)}
        
        store.completeDeletionSuccessfully()
        sut = nil
        
        store.completeInsertion(with: anyError())
        XCTAssertTrue(recievedResults.isEmpty)
    }
    
    // MARK: - Helpers
    private func uniqueItems() -> FeedItem {
        return FeedItem(id: UUID(), description: "any description", location: "any location", imageURL: URL(string: "www.any-image.com")!)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        
        return (sut, store)
    }
    
    private class FeedStoreSpy: FeedStore {
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void
        
        enum RecievedMessage: Equatable {
            case deleteCachedFeed
            case insert([LocalFeedItem], timestamp: Date)
        }
        
        private(set) var recievedMessages = [RecievedMessage]()
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
        
        
        
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            recievedMessages.append(.deleteCachedFeed)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            recievedMessages.append(.insert(items, timestamp: timestamp))
            insertionCompletions.append(completion)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }

    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        var recievedError: Error?
        
        sut.save([uniqueItems()]) { error in
            recievedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(recievedError as NSError?, expectedError, file: file, line: line)
    }
    
    private func anyError() -> Error {
        let error = NSError(domain: "any", code: 0, userInfo: nil)
        return error
    }
}
