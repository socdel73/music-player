import SwiftUI

struct AlbumCardView: View {
    let album: Album
    // Eliminem 'let service = NavidromeService()' d'aquí per seguir MVVM pur.
    // La vista no hauria de crear serveis, però de moment ho arreglarem així:
    private let service = NavidromeService()
    
    var body: some View {
        VStack(alignment: .leading) {
            // Verificació de seguretat per a la caràtula
            if let coverId = album.coverArt,
                let url = service.getCoverArtURL(coverId: coverId) {
                
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(Image(systemName: "music.note"))
                }
                .frame(width: 160, height: 160)
                .cornerRadius(8)
                .clipped()
            } else {
                // Placeholder si no hi ha ID de caràtula
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .cornerRadius(8)
                    .overlay(Image(systemName: "music.note"))
            }
            
            Text(album.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(album.artist ?? "Artista desconegut")                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 160)
    }
}
