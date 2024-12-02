//
//  ContentView.swift
//  test
//
//  Created by antonio_martinez88@hotmail.com on 11/29/24.
//

import SwiftUI

struct ContentView: View {
    @State private var domainId: String = "www.qlx.com"
    @State private var email: String = ""
    @State private var host: String = ""
    @State private var csvUrl: String = ""
    @State private var records: [[String: Any]] = []  // Lista de diccionarios dinámicos
    @State private var message: String = ""
    @State private var isNavigating: Bool = false  // Estado para navegar cuando se reciben los resultados
    @State private var isLoading: Bool = false  // Estado para controlar la animación de carga
    

    let knownDomainIds = [
        "www.qlx.com": "672ce0eec9c8622bbea4e655"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {  // Usar ScrollView para permitir desplazamiento
                VStack(spacing: 20) {
                    // Formulario de entrada
                    VStack(alignment: .leading) {
                        Section(header: Text("Domain ID")) {
                            TextField(
                                "Enter or select domain ID", text: $domainId
                            )
                            .padding()
                            Picker("Select Domain", selection: $domainId) {
                                ForEach(
                                    knownDomainIds.keys.sorted(), id: \.self
                                ) { key in
                                    Text(key).tag(key)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                        }

                        Section(header: Text("Email")) {
                            TextField("Enter email", text: $email)
                                .padding()
                        }

                        Section(header: Text("Host")) {
                            TextField("Enter host", text: $host)
                                .padding()
                        }

                        Section(header: Text("CSV URL")) {
                            TextField("Enter CSV URL", text: $csvUrl)
                                .padding()
                        }
                    }
                    .padding(.horizontal)

                    // Botones de acción
                    VStack {
                        if isLoading {
                            ProgressView("Loading...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }
                        
                        Button(action: {
                            getLast100Visitors()
                        }) {
                            Text("Get Last 100 Visitors")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        Button(action: {
                            getDailyReport()
                        }) {
                            Text("Get Daily Report")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        Button(action: {
                            suppressAccountLevel()
                        }) {
                            Text("Suppress Account Level")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()

                        Button(action: {
                            suppressDomainLevel()
                        }) {
                            Text("Suppress Domain Level")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()

                        Button(action: {
                            suppressContactCSV()
                        }) {
                            Text("Suppress Contact CSV")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        // Puedes agregar más botones aquí
                        // Ejemplo:
                        // Button(action: {
                        //     // Acción para otro botón
                        // }) {
                        //     Text("Another Action")
                        // }
                    }
                    
                    // Agregar indicador de carga
                    if isLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }

                    // Mostrar mensaje de estado
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            .navigationTitle("Sitemana API App")

            // Navegar cuando los resultados se reciban
            .navigationDestination(isPresented: $isNavigating) {
                VisitorListView(records: records)
            }
        }
    }

    func getDomainId() -> String {
        return knownDomainIds[domainId] ?? ""
    }

    func getLast100Visitors() {
        let domainId = getDomainId()
        let urlString =
            "https://api.sitemana.com/v1/visitors?apikey=602540f74e99dc5183bf563fca795c70&domainId=\(domainId)"
        makeApiRequest(urlString: urlString)
    }

    func getDailyReport() {
        let domainId = getDomainId()
        let urlString =
            "https://api.sitemana.com/v1/dailyreports?apikey=602540f74e99dc5183bf563fca795c70&domainId=\(domainId)"
        makeApiRequest(urlString: urlString)
    }

    func makeApiRequest(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.main.async {
                    self.isLoading = true  // Mostrar animación de carga
                }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                            self.isLoading = false  // Ocultar animación de carga
                        }
            
            if let error = error {
                DispatchQueue.main.async {
                    message = "Error: \(error.localizedDescription)"
                }
                return
            }

            if let data = data {
                if let json = try? JSONSerialization.jsonObject(
                    with: data, options: []) as? [String: Any],
                    let results = json["results"] as? [[String: Any]]
                {
                    DispatchQueue.main.async {
                        self.records = results
                        self.message = "Data loaded successfully!"
                        self.isNavigating = true  // Activar la navegación cuando los resultados estén listos
                    }
                } else {
                    DispatchQueue.main.async {
                        message = "Failed to parse data."
                    }
                }
            }
        }.resume()
    }

    func suppressAccountLevel() {
        guard !email.isEmpty else {
            message = "Please enter an email"
            return
        }
        let urlString =
            "https://api.sitemana.com/v1/suppressContact?apikey=602540f74e99dc5183bf563fca795c70&email=\(email)"
        makeApiRequest(urlString: urlString)
    }

    func suppressDomainLevel() {
        guard !email.isEmpty && !host.isEmpty else {
            message = "Please enter both email and host"
            return
        }
        let urlString =
            "https://api.sitemana.com/v1/suppressContact?apikey=602540f74e99dc5183bf563fca795c70&email=\(email)&host=\(host)"
        makeApiRequest(urlString: urlString)
    }

    func suppressContactCSV() {
        guard !csvUrl.isEmpty && !host.isEmpty else {
            message = "Please enter both CSV URL and host"
            return
        }
        let urlString =
            "https://api.sitemana.com/v1/suppressContactCSV?apikey=602540f74e99dc5183bf563fca795c70"
        let parameters = [
            "host": host,
            "csv": csvUrl,
        ]
        makePostRequest(urlString: urlString, parameters: parameters)
    }

    func makePostRequest(urlString: String, parameters: [String: String]) {
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(
            withJSONObject: parameters)

        DispatchQueue.main.async {
                    self.isLoading = true  // Mostrar animación de carga
                }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                        self.isLoading = false  // Ocultar animación de carga
                    }
            if let error = error {
                DispatchQueue.main.async {
                    message = "Error: \(error.localizedDescription)"
                }
                return
            }

            if let data = data {
                if let json = try? JSONSerialization.jsonObject(
                    with: data, options: [])
                {
                    DispatchQueue.main.async {
                        message = "\(json)"
                    }
                }
            }
        }.resume()
    }
}
