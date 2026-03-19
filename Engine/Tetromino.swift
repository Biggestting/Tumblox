import Foundation

// MARK: - Shape

enum TetrominoShape: String, CaseIterable, Codable {
    case i, o, t, s, z, j, l

    var color: TileColor {
        switch self {
        case .i: return .cyan
        case .o: return .yellow
        case .t: return .purple
        case .s: return .green
        case .z: return .red
        case .j: return .blue
        case .l: return .orange
        }
    }

    /// All rotation states (4 rotations, each is an array of (col, row) offsets from origin)
    var rotationStates: [[(Int, Int)]] {
        switch self {
        case .i:
            return [
                [(0,1),(1,1),(2,1),(3,1)],
                [(2,0),(2,1),(2,2),(2,3)],
                [(0,2),(1,2),(2,2),(3,2)],
                [(1,0),(1,1),(1,2),(1,3)],
            ]
        case .o:
            return [
                [(1,0),(2,0),(1,1),(2,1)],
                [(1,0),(2,0),(1,1),(2,1)],
                [(1,0),(2,0),(1,1),(2,1)],
                [(1,0),(2,0),(1,1),(2,1)],
            ]
        case .t:
            return [
                [(0,1),(1,1),(2,1),(1,0)],
                [(1,0),(1,1),(1,2),(2,1)],
                [(0,1),(1,1),(2,1),(1,2)],
                [(1,0),(1,1),(1,2),(0,1)],
            ]
        case .s:
            return [
                [(1,0),(2,0),(0,1),(1,1)],
                [(1,0),(1,1),(2,1),(2,2)],
                [(1,1),(2,1),(0,2),(1,2)],
                [(0,0),(0,1),(1,1),(1,2)],
            ]
        case .z:
            return [
                [(0,0),(1,0),(1,1),(2,1)],
                [(2,0),(1,1),(2,1),(1,2)],
                [(0,1),(1,1),(1,2),(2,2)],
                [(1,0),(0,1),(1,1),(0,2)],
            ]
        case .j:
            return [
                [(0,0),(0,1),(1,1),(2,1)],
                [(1,0),(2,0),(1,1),(1,2)],
                [(0,1),(1,1),(2,1),(2,2)],
                [(1,0),(1,1),(0,2),(1,2)],
            ]
        case .l:
            return [
                [(2,0),(0,1),(1,1),(2,1)],
                [(1,0),(1,1),(1,2),(2,2)],
                [(0,1),(1,1),(2,1),(0,2)],
                [(0,0),(1,0),(1,1),(1,2)],
            ]
        }
    }
}

// MARK: - Tile Color

enum TileColor: String, Codable {
    case cyan, yellow, purple, green, red, blue, orange
}

// MARK: - Tetromino

struct Tetromino {
    var shape: TetrominoShape
    var rotation: Int = 0       // 0–3
    var col: Int                // left-most column of bounding box
    var row: Int                // top-most row of bounding box

    init(shape: TetrominoShape, col: Int = 3, row: Int = 0) {
        self.shape = shape
        self.col = col
        self.row = row
    }

    var cells: [(col: Int, row: Int)] {
        shape.rotationStates[rotation].map { (col + $0.0, row + $0.1) }
    }

    mutating func rotate(clockwise: Bool) {
        let count = shape.rotationStates.count
        rotation = clockwise
            ? (rotation + 1) % count
            : (rotation + count - 1) % count
    }

    static func random() -> Tetromino {
        Tetromino(shape: TetrominoShape.allCases.randomElement()!)
    }
}
