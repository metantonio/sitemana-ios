import AVFoundation
//
//  AddDomainView.swift
//  test
//
//  Created by Antonio_martinez88@hotmail.com on 12/2/24.
//
import SwiftUI

struct AddDomainView: View {
    @Binding var knownDomainIds: [String: String]
    @State private var newDomainId: String = ""
    @State private var newWebsite: String = ""
    @State private var isScanning: Bool = false  // Estado para controlar la vista de escaneo
    @State private var scannerResult: String? = nil  // Resultado del escaneo QR
    @Environment(\.dismiss) var dismiss  // Para poder cerrar la vista
    var onSave: (() -> Void)? //función on closure para actualizar data cuando se pise el boton save

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Add New Domain ID")) {
                    TextField("Domain ID", text: $newDomainId)
                        .disableAutocorrection(true)
                        .cornerRadius(10)
                    TextField("Website", text: $newWebsite)
                        .disableAutocorrection(true)
                        .cornerRadius(10)
                }

                // Botón para escanear código QR
                Button("Scan QR Code") {
                    isScanning = true

                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("AccentColor"))
                .foregroundColor(.white)
                .cornerRadius(8)

                // Botón para guardar
                Button("Save") {
                    if !newDomainId.isEmpty && !newWebsite.isEmpty {
                        knownDomainIds[newWebsite] = newDomainId
                        saveKnownDomainIds()  // Guarda los datos en UserDefaults
                        onSave?()
                        dismiss()  // Cierra la vista
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("AccentColor"))
                .foregroundColor(.white)
                .cornerRadius(8)

                // Botón para cancelar
                Button("Cancel") {
                    dismiss()  // Cerrar la vista sin hacer cambios
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Add Domain ID")
            .sheet(isPresented: $isScanning) {
                QRScannerView(result: $scannerResult) { scannedData in
                    // Suponiendo que el formato del QR es un diccionario JSON con "domainId" y "website"
                    if let data = parseQRCodeData(scannedData) {
                        print("data: \(data)")
                        // Asignar los valores escaneados a las variables de estado
                        newDomainId = data["domainId"] ?? ""
                        newWebsite = data["website"] ?? ""
                        print("Domain ID: \(newDomainId), Website: \(newWebsite)")
                    }
                    isScanning = false  // Detener el escaneo
                }
            }
        }

    }
    // Función para parsear los datos del QR, asumiendo un formato tipo JSON en el QR
    func parseQRCodeData(_ qrString: String) -> [String: String]? {
        if let data = qrString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data)
                as? [String: String]
        {
            return json
        }
        return nil
    }
    func saveKnownDomainIds() {
        // Convertir el diccionario en datos JSON
        if let encodedData = try? JSONEncoder().encode(knownDomainIds) {
            UserDefaults.standard.set(encodedData, forKey: "knownDomainIds")
        }
    }

    // Recuperar los datos desde UserDefaults
    func loadKnownDomainIds() {
        if let savedData = UserDefaults.standard.data(forKey: "knownDomainIds"),
            let decodedDomainIds = try? JSONDecoder().decode(
                [String: String].self, from: savedData)
        {
            knownDomainIds = decodedDomainIds
        }
    }
}


