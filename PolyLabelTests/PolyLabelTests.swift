//
//  PolyLabelTests.swift
//  PolyLabelTests
//
//  Created by Nicolas Marchal on 25/06/2024.
//

import XCTest
@testable import PolyLabel

class PolyLabelTests: XCTestCase {
    static var water1: [[[Double]]] = []
        static var water2: [[[Double]]] = []
    
    static func loadPolygon(from filename: String) -> [[[Double]]] {
        let path = Bundle(for: self).path(forResource: filename, ofType: nil)!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [[[Double]]]
        return json
    }
    
    override func setUpWithError() throws {
        PolyLabelTests.water1 = PolyLabelTests.loadPolygon(from: "water1.json")
        PolyLabelTests.water2 = PolyLabelTests.loadPolygon(from: "water2.json")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWater1() {
            let result = PolyLabel.polyLabel(Self.water1, precision: 1)
            XCTAssertEqual(result.getCoordinates(), [3865.85009765625, 2124.87841796875])
            XCTAssertEqual(result.distance, 288.8493574779127)
        }

        func testWater1Precision50() {
            let result = PolyLabel.polyLabel(Self.water1, precision: 50)
            XCTAssertEqual(result.getCoordinates(), [3854.296875, 2123.828125])
            XCTAssertEqual(result.distance, 278.5795872381558)
        }

        func testWater2() {
            let result = PolyLabel.polyLabel(Self.water2)
            XCTAssertEqual(result.getCoordinates(), [3263.5, 3263.5])
            XCTAssertEqual(result.distance, 960.5)
        }

        func testDegeneratePolygons() {
            let result1 = PolyLabel.polyLabel([[[0, 0], [1, 0], [2, 0], [0, 0]]])
            XCTAssertEqual(result1.getCoordinates(), [0, 0])
            XCTAssertEqual(result1.distance, 0)

            let result2 = PolyLabel.polyLabel([[[0, 0], [1, 0], [1, 1], [1, 0], [0, 0]]])
            XCTAssertEqual(result2.getCoordinates(), [0, 0])
            XCTAssertEqual(result2.distance, 0)
        }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
