import SwiftUI

struct AlbumCardView: View {
    let album: Album
    let service = NavidromeService() // Necessitem el servei per la URL de la caràtula
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Imatge de l'àlbum
            if let coverArtId = album.coverArt,
                let url = service.getCoverArtURL(coverId: coverArtId) {
                
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Image(systemName: "music.note.list") // Si falla la càrrega
                            .foregroundColor(.secondary)
                    case .empty:
                        ProgressView() // Mentre descarrega
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 160, height: 160) // Mida estàndard de la graella
                .cornerRadius(8)
                .clipped()
                
            } else {
                // Placeholder si no hi ha caràtula
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .overlay(Image(systemName: "music.note"))
            }
            
            Text(album.name)
                .font(.headline)
                .lineLimit(1)
            
            Text(album.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 160)
    }
}
