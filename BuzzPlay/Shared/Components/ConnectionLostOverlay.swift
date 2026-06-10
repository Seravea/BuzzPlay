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

            VStack(spacing: BuzzSpacing.xl) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)

                Text("Connexion perdue")
                    .font(.nohemi(.title2, weight: .bold)).titleTracking()
                    .foregroundStyle(.white)

                Text("Reconnexion en cours…")
                    .font(.nohemi(.body, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
            }
            .padding(BuzzSpacing.xxxl)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        }
    }
}

#Preview {
    ConnectionLostOverlay()
}
