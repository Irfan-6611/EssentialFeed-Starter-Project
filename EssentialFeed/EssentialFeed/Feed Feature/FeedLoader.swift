//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public enum LoadFeedResult {
	case success([FeedImage])
	case failiur(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
