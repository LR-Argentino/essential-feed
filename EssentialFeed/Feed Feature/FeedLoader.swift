//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Luca Argentino on 13.06.24.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
