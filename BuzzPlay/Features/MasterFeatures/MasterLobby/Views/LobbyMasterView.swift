//
//  LobbyMasterView.swift
//  BuzzPlay
//

import SwiftUI

struct LobbyMasterView: View {
    @EnvironmentObject var router: Router
    @Bindable var masterGameVM: MasterLobbyViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("MAÎTRE DU JEU")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.40))
                Text("Salle d'attente")
                    .font(.nohemi(.title, weight: .extraBold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 12)

            if masterGameVM.players.isEmpty {
                emptyState
            } else {
                teamList
            }
        }
        .background(BackgroundAppView())
        .foregroundStyle(.white)
        .appDefaultTextStyle(Typography.body)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ConnectionStatusBadge(
                    connected: masterGameVM.connectedPlayersCount,
                    total: masterGameVM.totalPlayersCount
                )
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.06))
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.3")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.white.opacity(0.40))
                }
                VStack(spacing: 6) {
                    Text("En attente des joueurs…")
                        .font(.nohemi(.title3, weight: .semiBold))
                    Text("Demande aux joueurs de rejoindre la partie")
                        .font(.nohemi(.subheadline))
                        .foregroundStyle(.white.opacity(0.50))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }

    // MARK: - Player list + start button

    private var teamList: some View {
        VStack(spacing: 0) {
            // Section label
            HStack {
                Text("JOUEURS CONNECTÉS")
                    .font(.nohemi(.caption2, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.40))
                Text("· \(masterGameVM.players.count)")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(.white.opacity(0.40))
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 12)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(masterGameVM.players) { player in
                        LobbyTeamRow(player: player)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 100)
            }

            // Start CTA
            Button {
                router.push(.masterChooseGameView)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Démarrer la partie")
                        .font(.nohemi(.body, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .shadow(color: Color.greenButtonLeading.opacity(0.32), radius: 12, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.bottom, 32)
            .padding(.top, 12)
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Team row

private struct LobbyTeamRow: View {
    let player: Player

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(player.teamColor.gradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.body, weight: .extraBold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.nohemi(.body, weight: .bold))
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.greenGlow)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}

#Preview {
    LobbyMasterView(masterGameVM: MasterLobbyViewModel(gameVM: MasterFlowViewModel()))
        .environmentObject(Router())
}
