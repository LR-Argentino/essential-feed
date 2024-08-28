//
//  RemoteFeedImage.swift
//  EssentialFeed
//
//  Created by Luca Argentino on 28.08.2024.
//

import Foundation

internal struct RemoteFeedImage: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
