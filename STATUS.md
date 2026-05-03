# Estat del Projecte: SocDel73 Player

# STATUS - SocDel73 Player (V1.0)
## 📅 Sessió: 03/05/2026 - Tancament Fase 3

### ✅ ESTAT ACTUAL: FASE 3 COMPLETADA
- **Arquitectura**: MVVM consolidada amb ViewModels protegits per `@MainActor`.
- **Motor de So**: `AVAudioEngine` estable amb telemetria Bit-Perfect (kHz reals).
- **Interfície**: Llista d'àlbums i detall de cançons funcional en iOS i iPadOS.
- **Navegació**: Corregit el bug de la pantalla en blanc a l'iPad.

### 🛠️ ARXIUS MODIFICATS
1. `AudioPlayerManager.swift`: Motor blindat contra crashes d'inicialització.
2. `AlbumDetailView.swift`: UI sincronitzada amb el motor i llista de cançons.
3. `AlbumDetailViewModel.swift`: Gestió asíncrona de cançons amb protecció de fils.
4. `ContentView.swift`: Forçat estil de navegació per a compatibilitat total.

### 🚧 PROPERS PASSOS (FASE 4)
- Disseny de la pantalla de **Login**.
- Implementació de **Keychain** per a la persistència segura de credencials.
- Eliminació definitiva de l'arxiu `Secrets.swift`.


## 📅 Última actualització: 03/05/2026 (Tancament Fase 3)

## 🎯 Objectiu actual
- **Fase 3 COMPLETADA**: Biblioteca organitzada per carpetes físiques de Nebraska i arquitectura MVVM consolidada.
- **Iniciant Fase 4**: Implementació de seguretat, Keychain i pantalla de Login.

## ✅ Què funciona (Assoliments de la sessió)
- **Arquitectura MVVM**: Separació total de responsabilitats. `ContentView` ara és una vista "tonta" que només observa el `LibraryViewModel`.
- **Motor de So (Fase 2 avançada)**: Implementada la telemetria Bit-Perfect. L'app ja llegeix i mostra la freqüència de mostreig real (ex: 44.1kHz, 96kHz) directament des del buffer d'àudio.
- **Interfície Dinàmica**: Selector de biblioteques (Picker) funcional que filtra els àlbums de Nebraska segons la carpeta física (Nugs, Bruce, CD).
- **Càrrega Asíncrona**: Implementació d'art d'àlbum via `AsyncImage` i gestió de xarxa amb `async/await` a la capa de carpetes.
- **Git Flow**: Historial netejat i sincronitzat amb el repositori remot.

## 🛠 Arxius clau actuals
- `models/MusicFolder.swift`: Estructura de dades de les biblioteques físiques.
- `viewmodels/LibraryViewModel.swift`: El nou "cervell" de la biblioteca. Gestiona estats de càrrega i filtres.
- `viewmodels/AudioPlayerManager.swift`: Motor de so basat en `AVAudioEngine` amb telemetria Bit-Perfect.
- `views/ContentView.swift`: Interfície principal neta i reactiva.
- `views/components/AlbumCardView.swift`: Component reutilitzable per a la graella d'àlbums.

## 🚧 Propers passos (Objectiu Pròxima Sessió)
1. **Atacar la Fase 4**: Crear la `LoginView.swift`.
2. Implementar el gestor de credencials amb **Keychain** per eliminar el fitxer `Secrets.swift`.
3. Migrar la funció `fetchRecentAlbums` de closures a `async/await`.

## ⚠️ Línies Vermelles
- **No tocar el disseny visual**: Seguim amb el layout base per centrar-nos en la seguretat.
- **Mantenir Bit-Perfect**: Qualsevol canvi no pot degradar la qualitat de la mostra.


## 📅 Última actualització: 03/05/2026 (Tancament Fase 2)

## 🎯 Objectiu actual
- **Fase 2 COMPLETADA**: Motor de so d'alta fidelitat (Bit-Perfect) consolidat.
- **Iniciant Fase 3**: Disseny de la "Biblioteca Real" a la UI (separació de Music Folders de Navidrome).

## ✅ Què funciona (Assoliments de la sessió)
- **Motor Audiòfil:** `AVQueuePlayer` substituït per `AVAudioEngine`. L'app llegeix la freqüència matemàtica real de l'arxiu (ex: 44.1kHz, 96kHz) abans de reproduir.
- **Puresa FLAC:** Connexió a "Nebraska" blindada amb `format=raw` i `maxBitRate=0`. El servidor ja no fa transcodificació d'amagat.
- **Seek Absolut:** Sistema matemàtic de càlcul de *frames* per avançar/retrocedir 15 segons sense perdre la qualitat de la mostra ni generar "agulles fantasmes".
- **Telemetria:** Barra de progrés en temps real afegida a la UI connectada al motor de fons.
- **Git:** Conflictes de divergència solucionats i historial estabilitzat amb la branca remota.

## 🛠 Arxius clau tocats / creats
- `viewmodels/AudioPlayerManager.swift`: (REFACTORITZACIÓ TOTAL) Implementació de l'arquitectura de nodes d'Apple i descàrrega en memòria cau.
- `viewmodels/AlbumDetailViewModel.swift`: (NOU) Creat per consolidar el patró MVVM i treure la lògica de xarxa de la vista.
- `views/AlbumDetailView.swift`: Actualitzat per llegir la telemetria (ProgressView) i netejat de crides a APIs.
- `networking/NavidromeService.swift`: Actualitzat l'endpoint de streaming. Identificada l'estructura `fetchMusicFolders` per a la Fase 3.
- `networking/SubsonicAPI.swift`: Optimització del consum de memòria limitant la mida de descàrrega de les caràtules (`size=600`).

## 🚧 Propers passos (Objectiu Pròxima Sessió)
1. **Atacar la Fase 3:** Analitzar el `ContentView.swift` o `LibraryView`.
2. Connectar la funció `fetchMusicFolders` per llegir les carpetes físiques del servidor ("Bruce Springsteen" vs "david").
3. Crear un Selector (Picker/Tabs) a la pantalla principal perquè l'usuari pugui navegar entre els Directes Nugs i els CDs rippejats sense barrejar-los.

## ⚠️ Línies Vermelles
- **Color verd i disseny final:** Congelat temporalment. No polirem l'estètica fins que les dades de les carpetes de "Nebraska" es mostrin correctament a la pantalla.
- No tocar la gestió d'usuaris (Login UI) fins a la Fase 4.



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



