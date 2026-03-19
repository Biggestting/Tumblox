import SwiftUI

struct GameCanvas: View {
    let grid: [[GridCell]]
    let activePiece: Tetromino?
    let ghostCells: Set<String>      // "col,row" keys for ghost tiles
    let hintCells: Set<String>       // "col,row" keys for hint highlight
    let nextPiece: Tetromino?
    let showNextPiece: Bool

    @Environment(\.colorScheme) var colorScheme

    // Tile rendering
    private let borderRadius: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            // Fit the board within available space, preserving 10:20 aspect ratio
            let tileFromWidth  = geo.size.width  / CGFloat(GameEngine.columns)
            let tileFromHeight = geo.size.height / CGFloat(GameEngine.rows)
            let tileSize       = min(tileFromWidth, tileFromHeight)
            let boardWidth     = tileSize * CGFloat(GameEngine.columns)
            let boardHeight    = tileSize * CGFloat(GameEngine.rows)
            let offsetX        = (geo.size.width  - boardWidth)  / 2
            let offsetY        = (geo.size.height - boardHeight) / 2

            ZStack(alignment: .topLeading) {
                // Background grid lines
                gridLines(tileSize: tileSize, totalHeight: boardHeight)

                // Locked tiles
                lockedTiles(tileSize: tileSize)

                // Ghost piece
                ghostTiles(tileSize: tileSize)

                // Hint overlay
                hintTiles(tileSize: tileSize)

                // Active piece
                activeTiles(tileSize: tileSize)
            }
            .frame(width: boardWidth, height: boardHeight)
            .background(colorScheme == .dark ? Color(hex: "#080808") : .boardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color(hex: "#2DD4BF").opacity(0.12)
                            : Color(hex: "#000000").opacity(0.06),
                        lineWidth: 1
                    )
            )
            .offset(x: offsetX, y: max(0, offsetY))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Game board")
            .accessibilityHint("Swipe left or right to move. Swipe down to drop. Tap to rotate.")
        }
    }

    // MARK: - Sublayers

    private func gridLines(tileSize: CGFloat, totalHeight: CGFloat) -> some View {
        Canvas { ctx, size in
            let lineColor = colorScheme == .dark
                ? Color(white: 1, opacity: 0.05)
                : Color(white: 0, opacity: 0.05)
            // Vertical
            for col in 0...GameEngine.columns {
                let x = CGFloat(col) * tileSize
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: totalHeight))
                ctx.stroke(path, with: .color(lineColor), lineWidth: 0.5)
            }
            // Horizontal
            for row in 0...GameEngine.rows {
                let y = CGFloat(row) * tileSize
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(path, with: .color(lineColor), lineWidth: 0.5)
            }
        }
    }

    private func lockedTiles(tileSize: CGFloat) -> some View {
        ForEach(0..<GameEngine.rows, id: \.self) { row in
            ForEach(0..<GameEngine.columns, id: \.self) { col in
                if case .filled(let tileColor) = grid[row][col] {
                    tile(tileColor: tileColor, col: col, row: row, tileSize: tileSize, opacity: 1)
                }
            }
        }
    }

    private func ghostTiles(tileSize: CGFloat) -> some View {
        ForEach(Array(ghostCells), id: \.self) { key in
            let parts = key.split(separator: ",").compactMap { Int($0) }
            if parts.count == 2 {
                ghostTile(col: parts[0], row: parts[1], tileSize: tileSize)
            }
        }
    }

    private func hintTiles(tileSize: CGFloat) -> some View {
        ForEach(Array(hintCells), id: \.self) { key in
            let parts = key.split(separator: ",").compactMap { Int($0) }
            if parts.count == 2 {
                hintTile(col: parts[0], row: parts[1], tileSize: tileSize)
            }
        }
    }

    private func hintTile(col: Int, row: Int, tileSize: CGFloat) -> some View {
        let inset: CGFloat = 1.5
        return RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
            .fill(Color.primaryGradientMid.opacity(0.20))
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
                    .strokeBorder(Color.primaryGradientMid.opacity(0.55), lineWidth: 1.5)
            )
            .frame(width: tileSize - inset * 2, height: tileSize - inset * 2)
            .position(
                x: CGFloat(col) * tileSize + tileSize / 2,
                y: CGFloat(row) * tileSize + tileSize / 2
            )
    }

    private func activeTiles(tileSize: CGFloat) -> some View {
        Group {
            if let piece = activePiece {
                ForEach(0..<piece.cells.count, id: \.self) { i in
                    let cell = piece.cells[i]
                    if cell.row >= 0 {
                        tile(tileColor: piece.shape.color, col: cell.col, row: cell.row, tileSize: tileSize, opacity: 1)
                    }
                }
            }
        }
    }

    // MARK: - Single tile

    private func tile(tileColor: TileColor, col: Int, row: Int, tileSize: CGFloat, opacity: Double) -> some View {
        let inset: CGFloat = 1.5
        return RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
            .fill(color(for: tileColor).opacity(opacity))
            .frame(width: tileSize - inset * 2, height: tileSize - inset * 2)
            .position(
                x: CGFloat(col) * tileSize + tileSize / 2,
                y: CGFloat(row) * tileSize + tileSize / 2
            )
    }

    private func ghostTile(col: Int, row: Int, tileSize: CGFloat) -> some View {
        let inset: CGFloat = 1.5
        return RoundedRectangle(cornerRadius: borderRadius, style: .continuous)
            .strokeBorder(
                (activePiece.map { color(for: $0.shape.color) } ?? TumbloxColors.textMuted(colorScheme)).opacity(0.35),
                lineWidth: 1.5
            )
            .frame(width: tileSize - inset * 2, height: tileSize - inset * 2)
            .position(
                x: CGFloat(col) * tileSize + tileSize / 2,
                y: CGFloat(row) * tileSize + tileSize / 2
            )
    }

    private func color(for tileColor: TileColor) -> Color {
        switch tileColor {
        case .cyan:   return Color(hex: "#00C8FF")
        case .yellow: return Color(hex: "#FFD600")
        case .purple: return Color(hex: "#A855F7")
        case .green:  return Color(hex: "#22C55E")
        case .red:    return Color(hex: "#EF4444")
        case .blue:   return Color(hex: "#3B82F6")
        case .orange: return Color(hex: "#F97316")
        }
    }
}
