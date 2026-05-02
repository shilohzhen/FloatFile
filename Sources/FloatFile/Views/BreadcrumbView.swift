import SwiftUI

struct BreadcrumbView: View {
    @ObservedObject var viewModel: FileBrowserViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(Array(viewModel.pathComponents.enumerated()), id: \.offset) { index, component in
                    if index > 0 {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        viewModel.navigate(to: component.path)
                    } label: {
                        Text(component.name)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(index == viewModel.pathComponents.count - 1 ? .primary : .secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .background(Color.white.opacity(0.03))
    }
}
