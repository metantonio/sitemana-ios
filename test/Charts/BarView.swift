//
//  BarView.swift
//  Sitemana API
//
//  Created by antonio_martinez88@hotmail.com on 12/5/24.
//
import SwiftUI

struct BarView: View {
    var value: CGFloat
    var label: String

    var body: some View {
        VStack {
            // Mostrar el valor en la parte superior de la barra
            Text("\(Int(value))")
                .font(.system(size: value < 20 ? 10 : 14))
                .rotationEffect(.degrees(0))
                .offset(y: value < 1 ? 0 : -20)
            
            // La barra en sí
            Rectangle()
                .fill(Color.blue)
                .frame(height: value)

            // Etiqueta en la parte inferior de la barra
            Text(label.suffix(5))
                //.font(.caption)
                .font(.system(size: value < 20 ? 10 : 14))
                .lineLimit(1)  // Limitar a una sola línea
                .truncationMode(.tail)  // Añadir '...' si no cabe
                .rotationEffect(.degrees(-90))
                .frame(width: value < 1 ? 0 : nil) // Evitar texto en barras pequeñas
                .offset(y: value < 1 ? 0 : 80)
        }
        .frame(maxWidth: .infinity)  // Asegurar que el contenido ocupe todo el espacio disponible
    }
}
