//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Luca Argentino on 22.06.24.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}
