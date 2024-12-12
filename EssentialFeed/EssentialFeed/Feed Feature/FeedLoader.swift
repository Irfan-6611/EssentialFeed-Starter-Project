//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public enum LoadFeedResult {
	case success([FeedItem])
	case failiur(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
