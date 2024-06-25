//
//  PolyLabel.swift
//  PolyLabel
//
//  Created by Nicolas Marchal on 25/06/2024.
//

import Foundation

public class PolyLabel {

    let x: Double
    let y: Double
    let distance: Double

    init(x: Double, y: Double, distance: Double) {
        self.x = x
        self.y = y
        self.distance = distance
    }

    static func polyLabel(_ polygon: [[[Double]]], precision: Double = 1.0, debug: Bool = false) -> PolyLabel {
        // find the bounding box of the outer ring
        var minX = polygon[0][0][0]
        var maxX = minX
        var minY = polygon[0][0][1]
        var maxY = minY

        for i in 1..<polygon[0].count {
            let x = polygon[0][i][0]
            let y = polygon[0][i][1]
            if x < minX { minX = x }
            if x > maxX { maxX = x }
            if y < minY { minY = y }
            if y > maxY { maxY = y }
        }

        let width = maxX - minX
        let height = maxY - minY
        let cellSize = min(width, height)
        var half = cellSize / 2

        if cellSize == 0 {
            return PolyLabel(x: minX, y: minY, distance: 0)
        }

        // a priority queue of cells in order of their "potential" (max distance to polygon)
        var cellQueue = PriorityQueue<Cell>(sort: { $0.max > $1.max })

        for x in stride(from: minX, to: maxX, by: cellSize) {
            for y in stride(from: minY, to: maxY, by: cellSize) {
                cellQueue.enqueue(Cell(x: x + half, y: y + half, half: half, polygon: polygon))
            }
        }

        // take centroid as the first best guess
        var bestCell = getCentroidCell(polygon: polygon)

        // special case for rectangular polygons
        let bboxCell = Cell(x: minX + width / 2, y: minY + height / 2, half: 0, polygon: polygon)
        if bboxCell.distance > bestCell.distance {
            bestCell = bboxCell
        }

        var numProbes = cellQueue.count

        while let cell = cellQueue.dequeue() {
            // update the best cell if we found a better one
            if cell.distance > bestCell.distance {
                bestCell = cell
                if debug {
                    print("Found best \(String(format: "%.2f", cell.distance)) after \(numProbes) probes")
                }
            }

            // do not drill down further if there's no chance of a better solution
            if cell.max - bestCell.distance <= precision {
                continue
            }

            // split the cell into four cells
            half = cell.half / 2
            cellQueue.enqueue(Cell(x: cell.x - half, y: cell.y - half, half: half, polygon: polygon))
            cellQueue.enqueue(Cell(x: cell.x + half, y: cell.y - half, half: half, polygon: polygon))
            cellQueue.enqueue(Cell(x: cell.x - half, y: cell.y + half, half: half, polygon: polygon))
            cellQueue.enqueue(Cell(x: cell.x + half, y: cell.y + half, half: half, polygon: polygon))
            numProbes += 4
        }

        if debug {
            print("Num probes: \(numProbes)")
            print("Best distance: \(bestCell.distance)")
        }

        return PolyLabel(x: bestCell.x, y: bestCell.y, distance: bestCell.distance)
    }

    // get polygon centroid
    private static func getCentroidCell(polygon: [[[Double]]]) -> Cell {
        var area = 0.0
        var x = 0.0
        var y = 0.0
        let points = polygon[0]

        for i in 0..<points.count {
            let j = (i + points.count - 1) % points.count
            let a0 = points[i][0]
            let a1 = points[i][1]
            let b0 = points[j][0]
            let b1 = points[j][1]
            let diff = a0 * b1 - b0 * a1
            x += (a0 + b0) * diff
            y += (a1 + b1) * diff
            area += diff * 3
        }

        if area == 0 {
            return Cell(x: points[0][0], y: points[0][1], half: 0, polygon: polygon)
        }

        return Cell(x: x / area, y: y / area, half: 0, polygon: polygon)
    }

    func getCoordinates() -> [Double] {
        return [x, y]
    }
}
