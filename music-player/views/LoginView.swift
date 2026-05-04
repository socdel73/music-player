import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager
    
    @State private var serverURL = "https://music.socdel73.com"
    @State private var username = ""
    @State private var password = ""
    @State private var isConnecting = false
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "waveform.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
            
            Text("SocDel73 Player")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("Servidor (URL)", text: $serverURL)
                    .textFieldStyle(.roundedBorder)
#if os(iOS)
                    .textInputAutocapitalization(.never)
#endif
                    .autocorrectionDisabled(true)
                
                TextField("Usuari", text: $username)
                    .textContentType(.username)
                    .textFieldStyle(.roundedBorder)
#if os(iOS)
                    .textInputAutocapitalization(.never)
#endif
                    .autocorrectionDisabled(true)
                
                SecureField("Contrasenya", text: $password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            Button(action: {
                isConnecting = true
                // Fem servir Task per gestionar l'asincronia correctament
                Task {
                    // Simulem un segon de cortesia per a la UI
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    auth.saveCredentials(url: serverURL, user: username, pass: password)
                    isConnecting = false
                }
            }) {
                if isConnecting {
                    ProgressView()
                } else {
                    Text("Connectar a Nebraska")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .disabled(username.isEmpty || password.isEmpty)
            
            Text("Les teves credencials s'emmagatzemen de forma xifrada al Keychain del dispositiu.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top)
        }
        .padding()
#if os(macOS)
        .frame(width: 400, height: 500)
#endif
    }
}
