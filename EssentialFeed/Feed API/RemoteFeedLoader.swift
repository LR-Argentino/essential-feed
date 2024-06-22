//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Luca Argentino on 22.06.24.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
