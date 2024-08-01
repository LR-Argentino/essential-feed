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
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "htttps://www.give-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load  { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURL() {
        let url = URL(string: "htttps://www.give-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_delieversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_delieversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 400, 404, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_delieversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_delieversNoItemsOn200HTTPResponseEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyJSONList = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSONList)
        })
    }
    
    func test_load_delieversItemsOn200HTTPResponseWithJsonItems() {
        let (sut, client) = makeSUT()
        
        let (item1, item1JSON) = makeItems(id: UUID(), url: URL(string: "www.imageblur.com")!)
        
        let (item2, item2JSON) = makeItems(id: UUID(), description: "a descritpion", location: "location 133", url: URL(string: "https://www.gps.com")!)
                
        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            let json = makeItemsJSON([item1JSON, item2JSON])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDelieverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        var capturedResults = [FeedLoader.Result]()
        
        sut?.load { capturedResults.append($0) }
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
 
    // HELPERS Functions
    
    private func makeSUT(url: URL = URL(string: "htttps://www.give-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func makeItems(id: UUID, description: String? = nil, location: String? = nil, url: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: url)
        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues { $0 }
     
        return (item, itemJSON)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = ["items": items]
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for load completion")

            sut.load { receivedResult in
                switch (receivedResult, expectedResult) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

                case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)

                default:
                    XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
                }

                exp.fulfill()
            }

            action()

            wait(for: [exp], timeout: 1.0)
        }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
            return .failure(error)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map {$0.url}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
}
