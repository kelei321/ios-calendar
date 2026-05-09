import SwiftUI

extension EventColor {
    var swiftUIColor: Color {
        switch self {
        case .blue: .blue
        case .green: .green
        case .orange: .orange
        case .red: .red
        case .purple: .purple
        case .gray: .gray
        }
    }
}
