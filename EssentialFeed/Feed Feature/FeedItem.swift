//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Luca Argentino on 13.06.24.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
