import SwiftUI

struct AlbumCardView: View {
    let album: Album
    let service = NavidromeService()
    
    var body: some View {
        VStack(alignment: .leading) {
            if let coverId = album.coverArt, let url = service.getCoverArtURL(coverId: coverId) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { Color.gray.opacity(0.3) }
                    .frame(width: 160, height: 160).cornerRadius(8).clipped()
            }
            Text(album.name).font(.headline).lineLimit(1)
            Text(album.artist).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
        }.frame(width: 160)
    }
}
