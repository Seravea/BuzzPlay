//
//  ConnectionLostOverlay.swift
//  BuzzPlay
//

import SwiftUI

struct ConnectionLostOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                Text("Connexion perdue")
                    .font(.poppins(.title2, weight: .bold))
                    .font(.nohemi(.title2, weight: .bold))
                    .foregroundStyle(.white)

                Text("Reconnexion en cours…")
                    .font(.poppins(.body, weight: .regular))
                    .font(.nohemi(.body, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    ConnectionLostOverlay()
}
