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

    func testSimpleDescription() {
        let object = TestObject(name: "Ignacio", age: 34)
        let description = """
        {
            - name = Ignacio
            - age = 34
        }
        """

        XCTAssertEqual(object.attributesDescription, description as NSString)

        print("\(object.attributesDescription)")
    }

}

struct TestObject: Descriptable {
    let name: String
    let age: Int
}
