//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Irfan Ahmed on 12/01/2025.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var viewAppeared = false
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refresh()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if !viewAppeared {
            refresh()
            viewAppeared = true
        }
    }
    
    @objc private func refresh() {
        refreshControl?.beginRefreshing()
        load()
    }
    
    private func load() {
        loader?.load { [unowned self] _ in
            self.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadFeeds() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadFeeds() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.refreshControl?.simulatePullToResfresh()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.refreshControl?.simulatePullToResfresh()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
        
        sut.refreshControl?.endRefreshing()
        sut.refreshControl?.simulatePullToResfresh()
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
        
        sut.refreshControl?.endRefreshing()
        sut.simulateAppearance()
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    //MARK: - Helper
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()

        var loadCallCount: Int {
            return completions.count
        }
            
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int = 0) {
            completions[0](.success([]))
        }
    }
}

private extension FeedViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded() // ViewDidLoad
            replaceRefreshControlWithFakeForiOS17Support()
        }
        
        beginAppearanceTransition(true, animated: false) // viewWillAppear
        endAppearanceTransition()// isViewAppearing+ViewDidAppear
    }
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshController()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }

        refreshControl = fake
    }
}

private extension UIRefreshControl {
    func simulatePullToResfresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private class FakeRefreshController: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { return _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
