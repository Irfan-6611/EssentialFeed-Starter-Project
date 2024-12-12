//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Irfan Ahmed on 12/12/2024.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failiur(Error)
}

public protocol HTTPClient {
    func get(from url: URL, complition: @escaping((HTTPClientResult) -> Void))
}
