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
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data)else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }

}
