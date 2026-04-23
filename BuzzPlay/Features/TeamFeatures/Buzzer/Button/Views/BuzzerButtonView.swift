//
//  BuzzerButtonView.swift
//  BuzzPlay
//

import SwiftUI
import UIKit

struct BuzzerButtonView: View {
    @State private var isTapped: Bool = false
    @Bindable var buzzerVM: BuzzerViewModel

    private var ourTeamBuzzed: Bool { buzzerVM.teamNameHasBuzz == buzzerVM.team.name }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Glow when enabled
                if buzzerVM.isEnabled {
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 260, height: 260)
                        .blur(radius: 40)
                }

                Image(.buttonFloor)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 320, maxHeight: 230)
                    .opacity(buzzerVM.isEnabled ? 1 : 0.4)

                Image(.buttonTap)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 240)
                    .padding(.bottom, isTapped ? 10 : 100)
                    .opacity(buzzerVM.isEnabled ? 1 : (ourTeamBuzzed ? 0.55 : 0.3))
            }
            .onTapGesture {
                if buzzerVM.isEnabled {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    buzzerVM.buzz()
                    isTapped.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isTapped.toggle()
                    }
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
            .animation(.easeInOut(duration: 0.1), value: isTapped)

            stateLabel
        }
        .appDefaultTextStyle(Typography.body)
    }

    @ViewBuilder
    private var stateLabel: some View {
        if let teamName = buzzerVM.teamNameHasBuzz {
            if teamName == buzzerVM.team.name {
                Label("Tu as buzzé !", systemImage: "bolt.fill")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(Color(hex: "#F6339A"))
            } else {
                Text("\(teamName) a buzzé")
                    .font(.nohemi(.subheadline, weight: .regular))
                    .foregroundStyle(.white.opacity(0.4))
            }
        } else if buzzerVM.isEnabled {
            Text("Appuie pour buzzer !")
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white.opacity(0.75))
        } else {
            Text("En attente d'une question…")
                .font(.nohemi(.subheadline, weight: .regular))
                .foregroundStyle(.white.opacity(0.3))
        }
    }
}

#Preview {
    BuzzerButtonView(
        buzzerVM: BuzzerViewModel(
            team: Team(name: "L'équipe 1", teamColor: .blueGame),
            mode: .blindTest
        )
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(BackgroundAppView())
}
