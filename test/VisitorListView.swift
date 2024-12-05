//
//  VisitorListView.swift
//  test
//
//  Created by antonio_martinez88@hotmail.com on 11/29/24.
//

import Charts
import SwiftUI

struct VisitorListView: View {
    var records: [[String: Any]]  // Recibe los registros desde ContentView

    // Procesar los registros para contar correos únicos por día
    private var emailsPerDay: [EmailData] {
        var result: [EmailData] = []
        var emailSetPerDay: [String: Set<String>] = [:]
        var flagBool: Bool = true
        // Iterar a través de los diccionarios en records
        for record in records {
            print("Processing record: \(record)")

            // Acceder directamente a las claves del diccionario
            if let createdAt = record["createdAt"] as? String,
                let date = formattedDate(from: createdAt)
            {

                // Verificar si el campo "emailscount" está presente
                if let count = record["emailscount"] as? Int {
                    flagBool = false
                    // Si "emailscount" existe, agregarlo directamente al resultado
                    result.append(EmailData(date: date, count: count))
                } else {
                    flagBool = true
                    // Si "emailscount" no está presente, contar los emails únicos
                    
                    if let email = record["email"] as? String {
                        if emailSetPerDay[date] == nil {
                            emailSetPerDay[date] = Set<String>()
                        }
                        emailSetPerDay[date]?.insert(email)
                    }

                    // Añadir al resultado el conteo de emails únicos
                    //result.append(EmailData(date: date, count: email.count ?? 0))
                }
            }
        }

        if flagBool==true {
            //var result: [EmailData] = []
            for (date, emails) in emailSetPerDay {
                // Verificar las fechas y los correos acumulados
                //print("Date: \(date), Emails: \(emails)")

                result.append(EmailData(date: date, count: emails.count))
            }
        }

        // Verificar los datos finales antes de devolver
        // print("result to pass to bar chart: \(result)")

        return result.sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack {
            Text("Unique Email Count")
                .font(.headline)

            // Gráfico de barras con los datos procesados
            BarChartEmail(data: emailsPerDay)
                .frame(height: 200)
                .padding()

            Section(header: Text("Response")) {
                List(records, id: \.uniqueId) { record in
                    VStack(alignment: .leading) {
                        ForEach(record.keys.sorted(), id: \.self) { key in
                            HStack {
                                Text(key)
                                    .fontWeight(.bold)
                                Text(
                                    ": \(String(describing: record[key] ?? "N/A"))"
                                )
                                .foregroundColor(.gray)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
        }
    }

    // Función para formatear la fecha
    func formattedDate(from dateString: String) -> String? {
        // Usamos un formateador para convertir la fecha
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"  // El formato de fecha en la API
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")  // Asegúrate de manejar correctamente las zonas horarias
        if let date = dateFormatter.date(from: dateString) {
            // Ahora formateamos la fecha a solo año, mes y día
            dateFormatter.dateFormat = "yyyy-MM-dd"  // Solo queremos la fecha sin la hora
            return dateFormatter.string(from: date)
        }
        return nil
    }
}

// Extensión para crear una clave única para cada diccionario
extension Dictionary where Key == String {
    var uniqueId: String {
        return self.keys.sorted().map { key in
            "\(key): \(String(describing: self[key]))"
        }.joined(separator: "; ")
    }
}
