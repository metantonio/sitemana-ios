//
//  Lo.swift
//  Sitemana API
//
//  Created by antonio_martinez88@hotmail.com on 12/3/24.
//

import SwiftUI

struct LoadingAppView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
            Text("Powered by QLX")
                .padding()
        }
    }
}
