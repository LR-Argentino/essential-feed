//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Luca Argentino on 13.06.24.
//

import Foundation

protocol FeedLoader {
    typealias Result = Swift.Result<[FeedItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
