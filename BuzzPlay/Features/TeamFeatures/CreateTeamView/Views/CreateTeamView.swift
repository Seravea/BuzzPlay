//
//  CreateTeamView.swift
//  BuzzPlay
//

import SwiftUI

struct CreateTeamView: View {
    @Bindable var createTeamVM: CreateTeamViewModel
    @EnvironmentObject private var router: Router
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var teamColor: Color { Color(createTeamVM.team.teamColor.rawValue) }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 16) {
                    if createTeamVM.hasSavedTeamDraft {
                        savedDraftCard
                    }
                    colorPickerSection
                    teamNameSection
                    playersSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, sizeClass == .regular ? 0 : 20)
                .padding(.top, 16)
                .frame(maxWidth: sizeClass == .regular ? 560 : .infinity)
                .frame(maxWidth: .infinity)
            }

            validateCTA
        }
        .background(BackgroundAppView())
        .foregroundStyle(.white)
        .appDefaultTextStyle(Typography.body)
        .alert("Es-tu sûr des prénoms de tes joueurs ?", isPresented: $createTeamVM.isAlertOn) {
            Button("Annuler", role: .cancel) { createTeamVM.isAlertOn = false }
            Button("Continuer") {
                createTeamVM.validate()
                router.push(.playerChooseGameView)
            }
        }
    }

    // MARK: - Saved Draft

    private var savedDraftCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(teamColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Équipe sauvegardée")
                        .font(.nohemi(.subheadline, weight: .bold))
                    Text("\"\(createTeamVM.savedTeamDraft?.name ?? "")\" · \(createTeamVM.savedTeamDraft?.players.filter { !$0.name.isEmpty }.count ?? 0) joueur(s)")
                        .font(.nohemi(.caption, weight: .regular))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
            }
            HStack(spacing: 8) {
                Button {
                    createTeamVM.useSavedTeamDraft()
                    createTeamVM.didLoadSavedTeam = true
                } label: {
                    Text("Utiliser")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(teamColor.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(teamColor.opacity(0.45), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button {
                    createTeamVM.resetForm()
                    createTeamVM.didLoadSavedTeam = true
                } label: {
                    Text("Nouveau")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white.opacity(0.65))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.white.opacity(0.1), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button {
                    createTeamVM.deleteSavedTeamDraft()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "#FF6B70"))
                        .frame(width: 42, height: 42)
                        .background(Color(hex: "#FB2C36").opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color(hex: "#FB2C36").opacity(0.25), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.1), lineWidth: 1))
    }

    // MARK: - Color Picker

    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("COULEUR DE L'ÉQUIPE")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)
            HStack(spacing: 14) {
                ForEach(GameColor.allCases, id: \.self) { color in
                    let isSelected = createTeamVM.team.teamColor == color
                    Button { createTeamVM.team.teamColor = color } label: {
                        Circle()
                            .fill(Color(color.rawValue))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: 2.5)
                                    .opacity(isSelected ? 1 : 0)
                            )
                            .scaleEffect(isSelected ? 1.18 : 1)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(teamColor.opacity(0.35), lineWidth: 1)
                .animation(.easeInOut(duration: 0.3), value: createTeamVM.team.teamColor)
        )
    }

    // MARK: - Team Name

    private var teamNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NOM DE L'ÉQUIPE")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)
            TextField(
                "",
                text: $createTeamVM.team.name,
                prompt: Text("Ex : Les champions").foregroundStyle(.white.opacity(0.3))
            )
            .font(.nohemi(.title3, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        teamColor.opacity(createTeamVM.team.name.isEmpty ? 0.2 : 0.6),
                        lineWidth: 1.5
                    )
                    .animation(.easeInOut(duration: 0.2), value: createTeamVM.team.name.isEmpty)
            )
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Players

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("JOUEURS")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(0.8)
                Text("\(createTeamVM.nbofPlayers)/6")
                    .font(.nohemi(.caption2, weight: .semiBold))
                    .foregroundStyle(teamColor)
                Spacer()
                if createTeamVM.nbofPlayers < 6 {
                    Button {
                        withAnimation { createTeamVM.team.players.append(Player(name: "")) }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("Ajouter")
                                .font(.nohemi(.subheadline, weight: .bold))
                        }
                        .foregroundStyle(teamColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(teamColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(teamColor.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            if createTeamVM.team.players.isEmpty {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Ajoute au moins un joueur")
                        .font(.nohemi(.subheadline, weight: .regular))
                }
                .foregroundStyle(.white.opacity(0.25))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            }

            ForEach($createTeamVM.team.players) { $player in
                playerRow($player)
            }
        }
        .padding(16)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }

    @ViewBuilder
    private func playerRow(_ player: Binding<Player>) -> some View {
        let initial = String(player.wrappedValue.name.prefix(1).uppercased())
        HStack(spacing: 12) {
            Text(initial.isEmpty ? "?" : initial)
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(initial.isEmpty ? .white.opacity(0.25) : teamColor)
                .frame(width: 36, height: 36)
                .background(
                    teamColor.opacity(initial.isEmpty ? 0.05 : 0.15),
                    in: Circle()
                )

            TextField(
                "",
                text: player.name,
                prompt: Text("Nom du joueur").foregroundStyle(.white.opacity(0.3))
            )
            .font(.nohemi(.body, weight: .medium))
            .foregroundStyle(.white)

            Button { createTeamVM.removePlayer(player: player.wrappedValue) } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.07), lineWidth: 1))
    }

    // MARK: - CTA

    private var validateCTA: some View {
        Button { createTeamVM.isAlertOn.toggle() } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 17, weight: .semibold))
                Text("Valider l'équipe")
                    .font(.nohemi(.body, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                    startPoint: .leading, endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: Color.greenButtonLeading.opacity(0.3), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, sizeClass == .regular ? 200 : 20)
        .padding(.bottom, 28)
        .padding(.top, 12)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    CreateTeamView(createTeamVM: CreateTeamViewModel())
        .environmentObject(Router())
}
