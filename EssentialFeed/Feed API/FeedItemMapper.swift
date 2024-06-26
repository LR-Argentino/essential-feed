//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Luca Argentino on 26.06.24.
//

import Foundation

class FeedItemMapper {
    private static var OK_200: Int { 200 }
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feed: [FeedItem] {
            return items.map { $0.item }
        }
    }

    // Represent the FeedItem in API Module
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        return root.items.map { $0.item }
    }
}
