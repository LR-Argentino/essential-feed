//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Luca Argentino on 02.03.2025.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
