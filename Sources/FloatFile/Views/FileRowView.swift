import SwiftUI

struct FileRowView: View {
    let item: FileItem
    let isSelected: Bool
    let onSelect: (FileItem) -> Void
    let onNavigate: (FileItem) -> Void

    var body: some View {
        HStack(spacing: 4) {
            Image(nsImage: item.thumbnail(size: 20))
                .resizable()
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.name)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .truncationMode(.middle)

                HStack(spacing: 6) {
                    if !item.isDirectory {
                        Text(item.formattedSize)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    Text(item.formattedDate)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if item.isDirectory {
                Image(systemName: "chevron.right")
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(3)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(item)
        }
        .onTapGesture(count: 2) {
            onNavigate(item)
        }
        .onDrag {
            NSItemProvider(object: item.path as NSURL)
        }
    }
}

// MARK: - Icon Grid View
struct FileIconView: View {
    let item: FileItem
    let isSelected: Bool
    let onSelect: (FileItem) -> Void
    let onNavigate: (FileItem) -> Void

    var body: some View {
        VStack(spacing: 4) {
            Image(nsImage: item.thumbnail(size: 48))
                .resizable()
                .frame(width: 48, height: 48)

            Text(item.name)
                .font(.system(size: 10))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .truncationMode(.middle)
                .frame(width: 70)
        }
        .padding(6)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(4)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(item)
        }
        .onTapGesture(count: 2) {
            onNavigate(item)
        }
        .onDrag {
            NSItemProvider(object: item.path as NSURL)
        }
    }
}
