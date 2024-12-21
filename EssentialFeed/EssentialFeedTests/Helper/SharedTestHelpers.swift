//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Irfan Ahmed on 22/12/2024.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}
