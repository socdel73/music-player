# Estat del Projecte: SocDel73 Player

📅 Sessió: 07/05/2026 - Consolidació Motor Audiòfil i Gapless
✅ ESTAT ACTUAL: FASE 2 COMPLETADA (Motor de So)
Motor d'Àudio: Consolidat l'ús d'AVAudioEngine amb configuració de sortida a 32-bit.

Telemetria Real: Implementat sistema de diagnòstic que llegeix el format real del buffer (confirmat streaming a 48.0kHz des de Nebraska).

Gapless Playback: Sistema de Pre-fetching operatiu. L'app descarrega la següent pista de la cua mentre sona l'actual per eliminar el silenci entre tracks.

Sincronització de Cues: Corregit el "bug dels fantasmes" mitjançant la cancel·lació de tasques (downloadTask.cancel()) al canviar d'àlbum.

UI Informativa: Mini-player actualitzat amb títol, àlbum i etiqueta de qualitat dinàmica (Blau per CD, Taronja per Hi-Res).

🛠️ ARXIUS DE REFERÈNCIA ACTUALITZATS
viewmodels/AudioPlayerManager.swift: Motor principal amb lògica de cues i resets.

viewmodels/AudioPlayerManager+Telemetry.swift: Extensió de diagnòstic tècnic.

views/AlbumDetailView.swift: Interfície de reproducció dinàmica.

🚧 PROPERS PASSOS: FASE 3 (BIBLIOTECA & PERSISTÈNCIA)
Persistència de Cua: Que l'app recordi què sonava si la tanquem.

Refactor de la Biblioteca: Millorar la navegació entre carpetes de Nebraska (Bruce vs David vs CDs).

Millora de l'Streaming: Investigar el canvi de downloadTask a dataTask per fer streaming progressiu real (començar a sonar abans de baixar tot el fitxer).


📝 ACTA DE SESSIÓ: 06/05/2026
Estat del Projecte: Finalització de la Fase 4 i Obertura de la Fase 2 (Motor de So).

✅ ASSOLIMENTS D'AVUI (Fase 4 & 2)
Sincronització de Seguretat: S'ha unificat el sistema de credencials MD5 Salted Token. El Keychain ja és funcional i persistent en ambdues plataformes.

Resolució de Bloquejos de Xarxa: S'han corregit els permisos del Sandbox de macOS (Outgoing Connections), permetent que el Mac llisti els àlbums igual que l'iPad.

Model de Dades Robus: S'ha implementat el model genèric SubsonicResponse<T> que permet llegir errors del servidor i dades de forma flexible.

Primer So (Alpha Stage): L'app ja "sona" a l'iPad. Hem confirmat que les metadades (cançons i àlbums) arriben i es reprodueixen.

🛠️ ARXIUS CLAU EN L'ÚLTIM PUSH
Models/Credentials.swift: Estructura única de sessió.

Utilities/String+MD5.swift: Extensió de criptografia centralitzada.

ViewModels/AuthManager.swift: Gestió del Singleton shared i inicialització de sessió.

Networking/NavidromeService.swift: Crides asíncrones amb gestió d'errors i paràmetres de stream optimitzats.

ViewModels/AudioPlayerManager.swift: Primera versió del motor de reproducció basat en AVFoundation.

🚀 PROPERS PASSOS: FASE 2 (L'EXPERIÈNCIA AUDIÒFILA)
A la propera sessió, deixarem de banda la infraestructura i ens tancarem a la Sala d'Escoltes. L'objectiu és que "SocDel73 Player" no soni com una app qualsevol, sinó com un component d'alta fidelitat.

Bit-Perfect Audit:

Verificarem que Navidrome no transcodifica (forçar FLAC original).

Configurarem el buffer de AVPlayer per evitar micro-talls i optimitzar la latència.

Gapless Playback (Fase Inicial):

Començarem a dissenyar el sistema de pre-fetching de la següent cançó. Crucial per als directes de Bruce Springsteen on el so no s'ha d'aturar entre cançons.

UI de Reproducció (Mini-Player):

Crearem una barra de control persistent que mostri la qualitat del fitxer (Sample Rate, Bit Depth).

Gestió de Cues (Queue Management):

Poder afegir un àlbum sencer a la cua de reproducció sense que l'app oblidi l'ordre dels tracks.

Sessió: 04/05/2026 - Tancament de la Fase 4

✅ ESTAT ACTUAL: FASE 4 FINALITZADA
Autenticació: LoginView implementada i funcional en macOS/iOS.

Seguretat: KeychainHelper i AuthManager gestionant credencials encriptades.

Networking: SubsonicAPI i NavidromeService adaptats per a connexions dinàmiques i segures.

🛠️ ARXIUS DE REFERÈNCIA ACTUALITZATS
Utilities/KeychainHelper.swift

ViewModels/AuthManager.swift

Views/LoginView.swift

Networking/SubsonicAPI.swift (Ara dinàmic)

Networking/NavidromeService.swift (Adaptat)

🚧 PROPERS PASSOS: FASE 5 (LLIBRERIA ASYNC I PERSISTÈNCIA)
Ara que la porta és segura, hem d'optimitzar com l'usuari es mou per l'interior de la biblioteca. La sessió de demà ens portarà a:

Logout segur: Implementar la capacitat de sortir i esborrar el Keychain des de la UI.

Càrrega Asíncrona Avançada: Evitar que l'app "es congeli" mentre descarrega la llista d'àlbums de Bruce Springsteen o els CD importats.

Gestió d'Errors Audiòfila: Si el servidor Nebraska no respon, donarem missatges clars i elegants en lloc de crashejar.

# STATUS - SocDel73 Player (V1.0)

## 📅 Sessió: 03/05/2026 - Tancament de la Fase 3

### ✅ ESTAT ACTUAL: FASE 3 COMPLETADA

- **Motor d'Àudio**: Implementat `AVAudioEngine` amb càrrega asíncrona i telemetria Bit-Perfect (kHz reals).
- **Arquitectura**: MVVM estricte. Els ViewModels utilitzen `@MainActor` per garantir l'estabilitat de la UI.
- **Multiplataforma**: Codi blindat amb directives `#if os(iOS)` per a compatibilitat total entre macOS, iPad i iPhone.
- **Biblioteca**: Lògica de carpetes físiques (Nebraska) operativa.

### 🛠️ ARXIUS DE REFERÈNCIA

- `viewmodels/AudioPlayerManager.swift`: Cor de l'app (Audiòfil).
- `viewmodels/LibraryViewModel.swift`: Gestor de la col·lecció de Nebraska.
- `views/AlbumDetailView.swift`: Interfície de reproducció i llistat de cançons.

### 🚧 PROPERS PASSOS: FASE 4 (AUTENTICACIÓ)

- Creació de la `LoginView`.
- Implementació de **Keychain** per guardar URL, usuari i password de forma encriptada.
- Eliminació del fitxer `Secrets.swift`.

notes (

Checklist de Tancament de Sessió:
Codi Sincronitzat: Has corregit el crash de AVAudioEngine, la navegació de l'iPad i els conflictes de fils.

Commit fet: La branca main de GitHub ja té la versió estable de la Fase 3.

STATUS.md actualitzat: El diari de bord de "Nebraska" reflecteix que la biblioteca ja llista i reprodueix amb telemetria real.

🚧 Full de ruta per a demà: Fase 4 (Autenticació)
Demà deixarem de banda els arxius de configuració manuals i atacarem la seguretat professional:

Keychain: Guardarem les teves credencials de music.socdel73.com de forma encriptada al xip de seguretat del dispositiu.

LoginView: Una interfície neta per introduir URL, usuari i password.

Eliminació de Secrets: Esborrarem definitivament qualsevol rastre de contrasenyes en el codi font.
)

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
- **Seek Absolut:** Sistema matemàtic de càlcul de _frames_ per avançar/retrocedir 15 segons sense perdre la qualitat de la mostra ni generar "agulles fantasmes".
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
