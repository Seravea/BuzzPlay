//
//  CreateTeamView.swift
//  BuzzPlay
//

import SwiftUI

struct CreateTeamView: View {
    @Bindable var createTeamVM: CreateTeamViewModel
    @EnvironmentObject private var router: Router
    @FocusState private var pseudoFocused: Bool

    private var initial: String {
        String(createTeamVM.pseudo.prefix(1).uppercased())
    }

    private var teamGradient: LinearGradient {
        createTeamVM.playerColor.gradient
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 28) {
                    avatarSection
                    pseudoSection
                    colorSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 22)
                .padding(.top, BuzzSpacing.lg)
            }

            ctaSection
        }
        .background(BackgroundAppView())
        .foregroundStyle(.white)
        .appDefaultTextStyle(Typography.body)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
        .onAppear { pseudoFocused = createTeamVM.pseudo.isEmpty }
    }

    // MARK: - Toolbar back

    private var backButton: some View {
        Button { router.path.removeLast() } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .textStyle(Typography.label)
                Text("Retour")
                    .font(.nohemi(.subheadline, weight: .semiBold))
            }
            .foregroundStyle(.white)
        }
    }

    // MARK: - Avatar preview

    private var avatarSection: some View {
        VStack(spacing: BuzzSpacing.sm) {
            Text("CHOISIS TON PERSO")
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.textMuted)

            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(teamGradient)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(initial.isEmpty ? "?" : initial)
                            .font(.custom("Nohemi-Black", size: 52))
                            .foregroundStyle(.white.opacity(initial.isEmpty ? 0.30 : 1))
                    )
                    .shadow(color: createTeamVM.playerColor.color.opacity(0.40), radius: 20, y: 8)
            }

            Text("Visible par tout le monde dans le lobby.")
                .font(.nohemi(.caption))
                .foregroundStyle(.textTertiary)
        }
        .padding(.top, BuzzSpacing.sm)
    }

    // MARK: - Pseudo field

    private var pseudoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TON PSEUDO")
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.textMuted)

            HStack(spacing: 10) {
                TextField(
                    "",
                    text: $createTeamVM.pseudo,
                    prompt: Text("Ton pseudo").foregroundStyle(.white.opacity(0.30))
                )
                .font(.nohemi(.title3, weight: .bold))
                .foregroundStyle(.white)
                .focused($pseudoFocused)
                .submitLabel(.done)

                if !createTeamVM.pseudo.isEmpty {
                    Text("\(createTeamVM.pseudo.count)/20")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(.textDim)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
            .padding(.vertical, 14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    .strokeBorder(
                        pseudoFocused
                            ? createTeamVM.playerColor.color.opacity(0.70)
                            : .white.opacity(0.12),
                        lineWidth: 1.5
                    )
                    .animation(.easeInOut(duration: 0.2), value: pseudoFocused)
            )
        }
    }

    // MARK: - Color picker

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            Text("COULEUR")
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.textMuted)

            HStack(spacing: 14) {
                ForEach(GameColor.allCases, id: \.self) { color in
                    let isSelected = createTeamVM.playerColor == color
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            createTeamVM.playerColor = color
                        }
                    } label: {
                        Circle()
                            .fill(color.gradient)
                            .frame(width: 46, height: 46)
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
    }

    // MARK: - CTA

    private var ctaSection: some View {
        Button {
            pseudoFocused = false
            createTeamVM.validate()
            router.push(.playerChooseGameView)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.right.circle.fill")
                    .textStyle(Typography.cardTitle)
                Text("Entrer dans le lobby")
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
                in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
            )
            .shadow(color: Color.greenButtonLeading.opacity(0.32), radius: 12, y: 4)
            .opacity(createTeamVM.isPseudoValid ? 1 : 0.40)
        }
        .buttonStyle(.plain)
        .disabled(!createTeamVM.isPseudoValid)
        .padding(.horizontal, 22)
        .padding(.bottom, BuzzSpacing.xxxl)
        .padding(.top, BuzzSpacing.md)
    }
}

#Preview {
    NavigationStack {
        CreateTeamView(createTeamVM: CreateTeamViewModel())
            .environmentObject(Router())
    }
}
