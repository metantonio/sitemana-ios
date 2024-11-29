//
//  VisitorListView.swift
//  test
//
//  Created by antonio_martinez88@hotmail.com on 11/29/24.
//

import SwiftUI

struct VisitorListView: View {
    var records: [[String: Any]] // Recibe los registros desde ContentView
    
    var body: some View {
        Section(header: Text("Visitor List")) {
            List(records, id: \.uniqueId) { record in
                VStack(alignment: .leading) {
                    ForEach(record.keys.sorted(), id: \.self) { key in
                        HStack {
                            Text(key)
                                .fontWeight(.bold)
                            Text(": \(String(describing: record[key] ?? "N/A"))")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }
}

extension Dictionary where Key == String {
    var uniqueId: String {
        // Crear una clave única concatenando las claves y valores del diccionario
        return self.keys.sorted().map { key in
            "\(key): \(String(describing: self[key]))"
        }.joined(separator: "; ")
    }
}

