//
//  KVObserverTests.swift
//  PMKVObserverTests
//
//  Created by Kevin Ballard on 11/18/15.
//  Copyright © 2015 Kevin Ballard. All rights reserved.
//

import XCTest
@testable import PMKVObserver

class KVObserverTests: XCTestCase {
    var helper: KVOHelper!
    
    override func setUp() {
        super.setUp()
        helper = KVOHelper()
    }
    
    override func tearDown() {
        helper = nil
        super.tearDown()
    }
    
    func testKVO() {
        var fired = false
        var token: KVObserver!
        token = KVObserver(object: helper, keyPath: "str") { [weak helper] object, change, kvo in
            fired = true
            XCTAssert(object === helper)
            XCTAssertEqual(change.kind, .Setting)
            XCTAssert(kvo === token)
            XCTAssertEqual(object.str, "foo")
        }
        helper.str = "foo"
        XCTAssertTrue(fired)
        fired = false
        token.cancel()
        helper.str = "bar"
        XCTAssertFalse(fired)
        fired = false
        
        let foo = NSObject()
        token = KVObserver(observer: foo, object: helper, keyPath: "str") { [weak foo] observer, object, _, _ in
            fired = true
            XCTAssert(observer === foo)
            XCTAssertEqual(object.str, "foo")
        }
        XCTAssertFalse(fired)
        fired = false
        helper.str = "foo"
        XCTAssertTrue(fired)
        fired = false
        token.cancel()
        helper.str = "bar"
        XCTAssertFalse(fired)
    }
    
    func testInitialCancel() {
        var fired = false
        weak var weakToken: KVObserver!
        helper.str = "foo"
        autoreleasepool {
            let token = KVObserver(object: helper, keyPath: "str", options: .Initial) { object, _, kvo in
                fired = true
                XCTAssertEqual(object.str, "foo")
                kvo.cancel()
            }
            weakToken = token
            XCTAssertTrue(fired)
            fired = false
            helper.str = "bar"
            XCTAssertFalse(fired)
            fired = false
        }
        XCTAssertNil(weakToken)
        
        autoreleasepool {
            let token = KVObserver(observer: self, object: helper, keyPath: "str", options: .Initial) { _, object, _, kvo in
                fired = true
                XCTAssertEqual(object.str, "bar")
                kvo.cancel()
            }
            weakToken = token
            XCTAssertTrue(fired)
            fired = false
            helper.str = "baz"
            XCTAssertFalse(fired)
            fired = false
        }
        XCTAssertNil(weakToken)
    }
    
    func testSameObserverObject() {
        var fired = false
        let token = KVObserver(observer: helper, object: helper, keyPath: "str") { [weak helper] observer, object, _, _ in
            fired = true
            XCTAssert(observer === helper)
            XCTAssert(object === helper)
            XCTAssertEqual(object.str, "foo")
        }
        helper.str = "foo"
        XCTAssertTrue(fired)
        token.cancel()
    }
}
