import SwiftUI

/// Small preview box showing the next piece to fall.
struct NextPieceView: View {
    let piece: Tetromino
    @Environment(\.colorScheme) var colorScheme

    private let previewSize: CGFloat = 56
    private let tileSize: CGFloat = 10
    private let borderRadius: CGFloat = 2

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(TumbloxColors.card(colorScheme))

            Canvas { ctx, size in
                let cells = piece.shape.rotationStates[0]  // always draw rotation 0 for preview

                // Compute bounding box to center the piece
                let minCol = cells.map { $0.0 }.min() ?? 0
                let maxCol = cells.map { $0.0 }.max() ?? 0
                let minRow = cells.map { $0.1 }.min() ?? 0
                let maxRow = cells.map { $0.1 }.max() ?? 0
                let pieceW = CGFloat(maxCol - minCol + 1) * tileSize
                let pieceH = CGFloat(maxRow - minRow + 1) * tileSize
                let originX = (size.width - pieceW) / 2
                let originY = (size.height - pieceH) / 2

                for (col, row) in cells {
                    let x = originX + CGFloat(col - minCol) * tileSize
                    let y = originY + CGFloat(row - minRow) * tileSize
                    let rect = CGRect(x: x + 1, y: y + 1, width: tileSize - 2, height: tileSize - 2)
                    let path = Path(roundedRect: rect, cornerRadius: borderRadius)
                    ctx.fill(path, with: .color(swiftColor(for: piece.shape.color)))
                }
            }
        }
        .frame(width: previewSize, height: previewSize)
    }

    private func swiftColor(for tileColor: TileColor) -> Color {
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
