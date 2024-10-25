//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Luca Argentino on 17.09.2024.
//

import Foundation

func anyNSError() -> NSError {
    let error = NSError(domain: "any", code: 0, userInfo: nil)
    return error
}
