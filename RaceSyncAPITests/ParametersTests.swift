//
//  ParamsTests.swift
//  RaceSyncAPITests
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-15.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import XCTest
import RaceSyncAPI
import Alamofire

class ParamsTests: XCTestCase {

    override func setUpWithError() throws { }

    override func tearDownWithError() throws { }

    func testEqualStringParams() throws {

        let before: Params = ["foo": "bar"]
        let after: Params = ["foo": "bar"]
        let result: Params = Params.diff(between: before, and: after)

        XCTAssertEqual(result, [:])
    }

    func testDifferentStringParams() throws {

        let before: Params = ["foo": "bar"]
        let after: Params = ["foo": "bar2"]
        let result: Params = Params.diff(between: before, and: after)

        XCTAssertEqual(result, after)
        XCTAssertNotEqual(result, before)
    }

    func testMissingStringParams() throws {

        let before: Params = ["foo": "bar"]
        let after: Params = [:]
        let result: Params = Params.diff(between: before, and: after)

        XCTAssertEqual(result, after)
        XCTAssertNotEqual(result, before)
    }

    func testDifferentBoolParams() throws {

        let before: Params = ["foo": false]
        let after: Params = ["foo": true]
        let result: Params = Params.diff(between: before, and: after)

        XCTAssertEqual(result, ["foo": 1])
    }

    func testDifferentIntParams() throws {

        let before: Params = ["foo": 25]
        let after: Params = ["foo": 450]
        let result: Params = Params.diff(between: before, and: after)

        XCTAssertEqual(result, after)
    }

    func testDiffParams() throws {

        let before: Params = ["foo1": 25, "foo2": true]
        let after: Params = ["foo1": 25, "foo2": false, "foo3": "hello world"]
        let result: Params = Params.diff(between: before, and: after)

        XCTAssertEqual(result, ["foo2": 0, "foo3": "hello world"])
    }
}

