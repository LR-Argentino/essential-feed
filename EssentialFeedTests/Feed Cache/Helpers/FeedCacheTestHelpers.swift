//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Luca Argentino on 17.09.2024.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> FeedImage {
    return FeedImage(id: UUID(), description: "any description", location: "any location", url: URL(string: "www.any-image.com")!)
}

func uniqueImageFeeds() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImageFeed(), uniqueImageFeed()]
    let local = models.map{
        LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    
    return (models, local)
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -7)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
