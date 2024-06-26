//
//  Cell.swift
//  PolyLabel
//
//  Created by Nicolas Marchal on 25/06/2024.
//

import Foundation

class Cell: Comparable {
    var x: Double
    var y: Double
    var half: Double
    var distance: Double
    var max: Double

    init(x: Double, y: Double, half: Double, polygon: [[[Double]]]) {
        self.x = x
        self.y = y
        self.half = half
        self.distance = Cell.pointToPolygonDist(x: x, y: y, polygon: polygon)
        self.max = self.distance + self.half * sqrt(2.0)
    }

    // signed distance from point to polygon outline (negative if point is outside)
    private static func pointToPolygonDist(x: Double, y: Double, polygon: [[[Double]]]) -> Double {
        var inside = false
        var minDistSq = Double.greatestFiniteMagnitude

        for ring in polygon {
            for i in 0..<ring.count {
                let current = ring[(i + 1) % ring.count]
                let prev = ring[i]

                if (current[1] > y) != (prev[1] > y),
                   x < (prev[0] - current[0]) * (y - current[1]) / (prev[1] - current[1]) + current[0] {
                    inside.toggle()
                }

                let distSq = Cell.getSegDistSq(px: x, py: y, a: current, b: prev)
                if distSq < minDistSq {
                    minDistSq = distSq
                }
            }
        }

        return minDistSq == 0 ? 0 : (inside ? 1 : -1) * sqrt(minDistSq)
    }

    // get squared distance from a point to a segment
    private static func getSegDistSq(px: Double, py: Double, a: [Double], b: [Double]) -> Double {
        var x = a[0]
        var y = a[1]
        let dx = b[0] - x
        let dy = b[1] - y

        if dx != 0 || dy != 0 {
            let t = ((px - x) * dx + (py - y) * dy) / (dx * dx + dy * dy)
            if t > 1 {
                x = b[0]
                y = b[1]
            } else if t > 0 {
                x += dx * t
                y += dy * t
            }
        }

        let dx1 = px - x
        let dy1 = py - y

        return dx1 * dx1 + dy1 * dy1
    }

    static func < (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.max < rhs.max
    }

    static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
