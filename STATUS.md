# Estat del Projecte: SocDel73 Player

## 📅 Última actualització: 02/05/2026 (Punt de restauració post-crisis)

## 🎯 Objectiu actual
- Finalitzar la Fase 1: Consolidar la connexió amb l'API Subsonic de Nebraska (Navidrome).
- Llistar els àlbums de la biblioteca per verificar la comunicació.

## ✅ Què funciona (Versió Estable 65c17d5)
- **Connexió:** L'app es connecta a `https://music.socdel73.com` via HTTPS.
- **Seguretat:** Les credencials es llegeixen des de l'arxiu `Secrets.swift` (no pujat a GitHub).
- **Arquitectura:** MVVM funcional.
- **Motor de so:** AVFoundation configurat per a una reproducció base (preparat per a millores de fidelitat).
- **Interfície:** Graella d'àlbums funcional.

## 🛠 Arxius clau al projecte
- `SubsonicAPI.swift`: Gestor de les crides al servidor.
- `LibraryViewModel.swift`: Lògica que demana i processa els àlbums.
- `AlbumGridView.swift`: Vista principal de la biblioteca.
- `PlayerEngine.swift`: El cor de la reproducció.
- `Secrets.swift`: (Local) Conté la URL, usuari i contrasenya.

## 🚧 Propers passos (Prioritat Alta)
1. Verificar que la càrrega d'imatges (portades) no satura la memòria.
2. Començar la **Fase 2**: Investigar la reproducció Bit-Perfect i millores al motor de so per a FLAC.
3. **Important:** No fer canvis estructurals grans sense validar la connexió actual.

## ⚠️ Línies Vermelles
- No tocar la gestió d'usuaris (Login UI) fins a la Fase 4.
- No implementar sistemes de pujada de fitxers (rsync) dins de l'app.
