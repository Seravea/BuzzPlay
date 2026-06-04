//
//  GiftShopView.swift
//  BuzzPlay
//

import SwiftUI
import AVFoundation

// MARK: - Bottom Bar (toujours visible en bas du buzzer)

struct GiftBottomBar: View {
    @Bindable var coinsVM: CoinsViewModel
    @Binding var isSheetOpen: Bool
    var isWaiting: Bool = false

    @State private var glowPulse = false

    private var balance: Int { coinsVM.playerGameViewModel?.player.accountAmount ?? 0 }

    var body: some View {
        VStack(spacing: 8) {
            if isWaiting && balance > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .bold))
                    Text("C'est le moment d'utiliser tes Notes !")
                        .font(.nohemi(.caption2, weight: .bold))
                }
                .foregroundStyle(Color.mustardYellow)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.mustardYellow.opacity(0.12), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.35), lineWidth: 1))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button { isSheetOpen = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.mustardYellow)

                    Text("Cadeaux")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    HStack(spacing: 5) {
                        Text("\(balance)")
                            .font(.nohemi(.callout, weight: .extraBold))
                            .monospacedDigit()
                            .foregroundStyle(Color.mustardYellow)
                        Image(systemName: "dollarsign.bank.building.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.mustardYellow)
                    }

                    Image(systemName: "chevron.up")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(
                    isWaiting ? Color.mustardYellow.opacity(0.10) : .white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            isWaiting ? Color.mustardYellow.opacity(0.55) : .white.opacity(0.12),
                            lineWidth: isWaiting ? 1.5 : 1
                        )
                )
                .shadow(
                    color: isWaiting ? Color.mustardYellow.opacity(glowPulse ? 0.40 : 0.12) : .clear,
                    radius: glowPulse ? 16 : 6
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isWaiting)
        .onChange(of: isWaiting) { _, waiting in
            if waiting {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            } else {
                glowPulse = false
            }
        }
        .onAppear {
            if isWaiting {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }
}

// MARK: - Gift Shop Sheet

struct GiftShopSheet: View {
    @Bindable var coinsVM: CoinsViewModel
    @Binding var isPresented: Bool

    @State private var showSoundPicker = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    private var balance: Int { coinsVM.playerGameViewModel?.player.accountAmount ?? 0 }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(.white.opacity(0.25))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 24)

            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Boutique")
                        .font(.nohemi(.title2, weight: .extraBold))
                        .foregroundStyle(.white)
                    Text("Active un cadeau pour changer le jeu")
                        .font(.nohemi(.caption, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 5) {
                        Text("\(balance)")
                            .font(.nohemi(.title3, weight: .extraBold))
                            .monospacedDigit()
                            .foregroundStyle(Color.mustardYellow)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Image(systemName: "dollarsign.bank.building.fill")
                            .foregroundStyle(Color.mustardYellow)
                            .layoutPriority(1)
                    }
                    Text("Notes disponibles")
                        .font(.nohemi(.caption2, weight: .regular))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)

            // Erreur
            if let error = coinsVM.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.nohemi(.caption, weight: .regular))
                        .foregroundStyle(.red.opacity(0.9))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            }

            // Grille de cadeaux
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(CoinsViewModel.Gift.allCases, id: \.self) { gift in
                    GiftCardView(
                        gift: gift,
                        balance: balance,
                        isPending: coinsVM.isPendingPurchase,
                        otherPlayers: coinsVM.otherPlayers,
                        onBuy: { target in
                            if gift == .changeBuzzSound {
                                showSoundPicker = true
                            } else {
                                coinsVM.buyGift(gift, targeting: target)
                                if coinsVM.errorMessage == nil { isPresented = false }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $showSoundPicker) {
            SoundPickerSheet(coinsVM: coinsVM, isShopPresented: $isPresented)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "1A0535"), location: 0),
                    .init(color: Color(hex: "2A0944"), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Gift Card

private struct GiftCardView: View {
    let gift: CoinsViewModel.Gift
    let balance: Int
    let isPending: Bool
    let otherPlayers: [Player]
    let onBuy: (Player?) -> Void

    private var canAfford: Bool { balance >= gift.price }
    private var notEnoughPlayers: Bool { otherPlayers.count < gift.minimumOtherPlayers }
    private var isActive: Bool { canAfford && !notEnoughPlayers && !isPending }

    var body: some View {
        Group {
            if gift.requiresTargetPlayer && !notEnoughPlayers {
                Menu {
                    ForEach(otherPlayers) { enemy in
                        Button(enemy.name) { onBuy(enemy) }
                    }
                } label: { cardBody }
                .disabled(!canAfford)
                .buttonStyle(.plain)
            } else {
                Button { onBuy(nil) } label: { cardBody }
                .buttonStyle(.plain)
                .disabled(!isActive)
            }
        }
    }

    private var cardBody: some View {
        VStack(spacing: 10) {
            Image(systemName: gift.iconName)
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(isActive ? gift.accentColor : .white.opacity(0.22))
                .frame(width: 54, height: 54)
                .background(
                    isActive ? gift.accentColor.opacity(0.18) : .white.opacity(0.05),
                    in: RoundedRectangle(cornerRadius: 14)
                )

            Text(gift.shortTitle)
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(isActive ? .white : .white.opacity(0.28))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 3) {
                Text("\(gift.price)")
                    .font(.nohemi(.caption2, weight: .extraBold))
                Image(systemName: "dollarsign.bank.building.fill")
                    .font(.system(size: 10))
            }
            .foregroundStyle(isActive ? Color.mustardYellow : .white.opacity(0.22))
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(
                isActive ? Color.mustardYellow.opacity(0.12) : .white.opacity(0.05),
                in: Capsule()
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 6)
        .background(
            isActive ? gift.accentColor.opacity(0.07) : .white.opacity(0.03),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    isActive ? gift.accentColor.opacity(0.28) : .white.opacity(0.05),
                    lineWidth: 1
                )
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
    }
}

// MARK: - Propriétés visuelles des Gifts (SwiftUI)

extension CoinsViewModel.Gift {
    var iconName: String {
        switch self {
        case .scoreDoubled:         return "2.circle.fill"
        case .enemyCanNotBuzz:      return "hand.raised.slash.fill"
        case .allEnemiesCanNotBuzz: return "person.2.slash.fill"
        case .showIndicies:         return "lightbulb.fill"
        case .changeBuzzColor:      return "paintbrush.fill"
        case .changeBuzzSound:      return "waveform"
        case .shieldSingle:         return "shield.fill"
        case .shieldAll:            return "shield.lefthalf.filled"
        }
    }

    var shortTitle: String {
        switch self {
        case .scoreDoubled:         return "Score ×2"
        case .enemyCanNotBuzz:      return "Bloquer\nun ennemi"
        case .allEnemiesCanNotBuzz: return "Bloquer\ntout le monde"
        case .showIndicies:         return "Voir\nun indice"
        case .changeBuzzColor:      return "Changer\nla couleur"
        case .changeBuzzSound:      return "Changer\nle son"
        case .shieldSingle:         return "Bouclier\n1 ennemi"
        case .shieldAll:            return "Bouclier\ntout le monde"
        }
    }

    var accentColor: Color {
        switch self {
        case .scoreDoubled:         return Color(hex: "00C875")
        case .enemyCanNotBuzz:      return Color(hex: "FF4D4D")
        case .allEnemiesCanNotBuzz: return Color(hex: "FF8C42")
        case .showIndicies:         return Color(hex: "FFD600")
        case .changeBuzzColor:      return Color(hex: "B06BFF")
        case .changeBuzzSound:      return Color(hex: "4DAAFF")
        case .shieldSingle:         return Color(hex: "2B7FFF")
        case .shieldAll:            return Color(hex: "00B8DB")
        }
    }
}

// MARK: - Sound Picker Sheet

struct SoundPickerSheet: View {
    @Bindable var coinsVM: CoinsViewModel
    @Binding var isShopPresented: Bool
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSound: String? = nil
    @State private var previewPlayer: AVAudioPlayer? = nil

    private let sounds = ["BeginQuestion", "Blblbl", "GoodAnswer", "HeavenlyChoir",
                          "Mosquito", "PositiveAnswer", "Tired", "WrongAnswer"]
    private let soundLabels = ["Début de question", "Blblbl", "Bonne réponse", "Chœur céleste",
                               "Moustique", "Réponse positive", "Fatigué", "Mauvaise réponse"]

    var body: some View {
        VStack(spacing: 0) {
            Text("Choisis ton son de buzzer")
                .font(.nohemi(.headline, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 24)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(zip(sounds, soundLabels)), id: \.0) { sound, label in
                        Button {
                            selectedSound = sound
                            playPreview(sound)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: selectedSound == sound ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(selectedSound == sound ? Color(hex: "4DAAFF") : .white.opacity(0.3))

                                Text(label)
                                    .font(.nohemi(.body, weight: .medium))
                                    .foregroundStyle(.white)

                                Spacer()

                                Image(systemName: "play.circle")
                                    .font(.system(size: 18))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                selectedSound == sound ? Color(hex: "4DAAFF").opacity(0.12) : .white.opacity(0.04),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        selectedSound == sound ? Color(hex: "4DAAFF").opacity(0.4) : .clear,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 16)
            }

            // CTA
            Button {
                coinsVM.buyGift(.changeBuzzSound, selectedSound: selectedSound)
                if coinsVM.errorMessage == nil {
                    dismiss()
                    isShopPresented = false
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "waveform")
                    Text(selectedSound == nil ? "Choisir un son d'abord" : "Confirmer — 20 🎵")
                        .font(.nohemi(.body, weight: .bold))
                }
                .foregroundStyle(selectedSound == nil ? .white.opacity(0.4) : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    selectedSound == nil
                        ? AnyShapeStyle(Color.white.opacity(0.08))
                        : AnyShapeStyle(LinearGradient(colors: [Color(hex: "2B7FFF"), Color(hex: "00B8DB")], startPoint: .leading, endPoint: .trailing)),
                    in: RoundedRectangle(cornerRadius: 14)
                )
            }
            .buttonStyle(.plain)
            .disabled(selectedSound == nil)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "1A0535"), location: 0),
                    .init(color: Color(hex: "2A0944"), location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private func playPreview(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        previewPlayer?.stop()
        previewPlayer = try? AVAudioPlayer(contentsOf: url)
        previewPlayer?.play()
    }
}
