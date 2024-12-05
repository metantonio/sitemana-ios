//
//  BarChart.swift
//  Sitemana API
//
//  Created by antonio_martinez88@hotmail.com on 12/5/24.
//

import SwiftUI

struct BarChartEmail: View {
    var data: [EmailData]

    var body: some View {

        GeometryReader { geometry in
            VStack {
                // El gráfico de barras
                if data.isEmpty {
                    Text("No data available")
                        .foregroundColor(.gray)
                } else {
                    // ScrollView horizontal para permitir el desplazamiento
                    ScrollView([.horizontal, .vertical], showsIndicators: true) {
                        HStack(alignment: .bottom, spacing: 1) {
                            ForEach(data) { item in
                                let barWidth = max(
                                    geometry.size.width / CGFloat(data.count),
                                    50)  // Minimiza el ancho
                                let validBarWidth = max(barWidth, 1)
                                BarView(
                                    value: CGFloat(item.count), label: item.date
                                )
                                .frame(width: validBarWidth)
                            }
                        }
                        //.padding(.horizontal, 0)  // Puedes ajustar el padding según sea necesario
                    }
                    //.frame(height: 200)  // Ajusta la altura del gráfico según sea necesario
                    .frame(height: geometry.size.height) //toda la altura posible
                }

                // Leyenda con fechas y valores
                //                HStack {
                //                    ForEach(data) { item in
                //                        VStack {
                //                            Text(item.date)
                //                                .font(.caption)
                //                                .padding(.top, 5)
                //                            Text("\(item.count)")
                //                                .font(.caption)
                //                        }
                //                        .frame(maxWidth: .infinity)
                //                    }
                //                }
                //                .padding(.top, 10)
            }
        }
        .frame(height: UIScreen.main.bounds.height)
    }
}
