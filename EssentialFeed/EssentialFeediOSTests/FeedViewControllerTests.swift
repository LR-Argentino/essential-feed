//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Luca Argentino on 02.03.2025.
//  Copyright © 2025 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import UIKit

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector (load), for: .valueChanged)
 
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            
            self?.refreshControl?.endRefreshing()
        }
    }
    
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request before view is loaded")

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
   
        sut.replaceRefreshControlWithFakeForiOS17Support()
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a third loading request once user initiates another load")
    }
    
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        sut.replaceRefreshControlWithFakeForiOS17Support()
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

        loader.completeLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
    }
    
    // MARK: - Helpers

    class LoaderSpy: FeedLoader{
        private(set) var completions: [(FeedLoader.Result) -> Void] = []
        
        var loadCallCount: Int {
            return completions.count
        }
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeLoading(at index: Int) {
            completions[index](.success([]))
        }
        
    }
    
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
}

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
}


extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension FeedViewController {
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        // Kopiere alle Targets und Aktionen vom alten RefreshControl
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        // Stelle sicher, dass der Fake auch `load()` auslöst
        fake.addTarget(self, action: #selector(load), for: .valueChanged) // Sicherstellen, dass `load()` weiter getriggert wird
        
        refreshControl = fake
    }
}

 private class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing: Bool = false
    
    override var isRefreshing: Bool {
        return _isRefreshing
    }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
