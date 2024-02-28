//
//  DescriptableTests.swift
//  RaceSyncAPITests
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-12.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import XCTest
import RaceSyncAPI

class DescriptableTests: XCTestCase {

    override func setUp() { }

    override func tearDown() { }

    func testAttributesDescription() {
        let object = TestObject(text: "This is text", number: 604, flag: true)
        let description = """
        {
            - text = This is text
            - number = 604
            - flag = true
        }
        """

        XCTAssertEqual(object.attributesDescription, description as NSString)

        print("\(object.attributesDescription)")
    }

}

struct TestObject: Descriptable {
    let text: String
    let number: Int
    let flag: Bool
}
