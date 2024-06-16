//
//  Logo.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 6/7/24.
//

import SwiftUI

struct Logo: View {
    var body: some View {
        Image("athlinklogo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 50, height: 50)
            .cornerRadius(25)
    }
}

#Preview {
    Logo()
}
