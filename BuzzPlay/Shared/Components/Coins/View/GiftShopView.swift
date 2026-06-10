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

    private var balance: Int { PlayerNotesWallet.shared.balance }  // #v1-economy — solde local

    var body: some View {
        VStack(spacing: BuzzSpacing.sm) {
            if isWaiting && balance > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .textStyle(Typography.caption2Bold)
                    Text("C'est le moment d'utiliser tes Notes !")
                        .font(.nohemi(.caption2, weight: .bold))
                }
                .foregroundStyle(Color.mustardYellow)
                .padding(.horizontal, BuzzSpacing.md)
                .padding(.vertical, 5)
                .background(Color.mustardYellow.opacity(0.12), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.35), lineWidth: 1))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button { isSheetOpen = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "gift.fill")
                        .textStyle(Typography.labelSM)
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
                            .textStyle(Typography.footnote)
                            .foregroundStyle(Color.mustardYellow)
                    }

                    Image(systemName: "chevron.up")
                        .textStyle(Typography.caption2Bold)
                        .foregroundStyle(Color.textMuted)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 13)
                .background(
                    isWaiting ? Color.mustardYellow.opacity(0.10) : .white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BuzzRadius.lg2)
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
        .padding(.horizontal, BuzzSpacing.lg)
        .animation(.buzzSmooth, value: isWaiting)
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

    private let columns = [GridItem(.flexible(), spacing: BuzzSpacing.md), GridItem(.flexible(), spacing: BuzzSpacing.md)]
    private var balance: Int { PlayerNotesWallet.shared.balance }  // #v1-economy — solde local

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.textFaint)
                .frame(width: 36, height: 4)
                .padding(.top, BuzzSpacing.md)
                .padding(.bottom, BuzzSpacing.xxl)

            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Boutique")
                        .font(.nohemi(.title2, weight: .extraBold)).titleTracking()
                        .foregroundStyle(.white)
                    Text("Active un cadeau pour changer le jeu")
                        .font(.nohemi(.caption, weight: .regular))
                        .foregroundStyle(Color.textTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 5) {
                        Text("\(balance)")
                            .font(.nohemi(.title3, weight: .extraBold)).titleTracking()
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
                        .foregroundStyle(Color.textMuted)
                }
            }
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.bottom, BuzzSpacing.xl)

            // Erreur
            if let error = coinsVM.errorMessage {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    Text(error)
                        .font(.nohemi(.caption, weight: .regular))
                        .foregroundStyle(.red.opacity(0.9))
                    Spacer()
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.bottom, 14)
            }

            // Grille de cadeaux
            LazyVGrid(columns: columns, spacing: BuzzSpacing.md) {
                ForEach(CoinsViewModel.Gift.allCases, id: \.self) { gift in
                    GiftCardView(
                        gift: gift,
                        balance: balance,
                        isPending: coinsVM.isPendingPurchase,
                        otherPlayers: coinsVM.otherPlayers,
                        player: coinsVM.playerGameViewModel?.player,
                        onBuy: { target in
                            if gift == .changeBuzzSound {
                                // Vérifie le solde avant d'ouvrir le picker ; sinon buyGift
                                // affiche l'alerte "pas assez de Notes" (#alerte-solde-bas).
                                if balance >= gift.price {
                                    showSoundPicker = true
                                } else {
                                    coinsVM.buyGift(gift, targeting: target)
                                }
                            } else {
                                coinsVM.buyGift(gift, targeting: target)
                                if coinsVM.errorMessage == nil { isPresented = false }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
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
                    .init(color: Color.sheetBg, location: 0),
                    .init(color: Color.darkestPurple, location: 1),
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
    let player: Player?
    let onBuy: (Player?) -> Void

    private var canAfford: Bool { balance >= gift.price }
    private var notEnoughPlayers: Bool { otherPlayers.count < gift.minimumOtherPlayers }
    private var isOwned: Bool { gift.isActiveOnPlayer(player) }
    /// Blocages structurels rendant la card non-interactive. Le solde insuffisant
    /// n'en fait PAS partie : la card reste tappable pour afficher l'alerte
    /// "pas assez de Notes" (#alerte-solde-bas).
    private var isBlocked: Bool { notEnoughPlayers || isPending || isOwned }
    /// Abordable ET jouable — pilote le rendu (card grisée si false).
    private var isActive: Bool { canAfford && !isBlocked }

    var body: some View {
        Group {
            // Cadeau abordable nécessitant une cible → menu de sélection.
            if gift.requiresTargetPlayer && !notEnoughPlayers && canAfford {
                Menu {
                    ForEach(otherPlayers) { enemy in
                        Button(enemy.name) { onBuy(enemy) }
                    }
                } label: { cardBody }
                .disabled(isPending || isOwned)
                .buttonStyle(.plain)
            } else {
                // Bouton simple : tappable même si solde insuffisant (buyGift affiche
                // alors l'alerte), désactivé seulement pour un blocage structurel.
                Button { onBuy(nil) } label: { cardBody }
                .buttonStyle(.plain)
                .disabled(isBlocked)
            }
        }
    }

    private var cardBody: some View {
        VStack(spacing: 10) {
            Image(systemName: gift.iconName)
                .textStyle(Typography.screenTitleSoft)
                .foregroundStyle(isActive ? gift.accentColor : .white.opacity(0.22))
                .frame(width: 54, height: 54)
                .background(
                    isActive ? gift.accentColor.opacity(0.18) : .white.opacity(0.05),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                )
                .overlay(alignment: .topTrailing) {
                    if isOwned {
                        Text("Actif")
                            .font(.nohemi(.caption2, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.greenButtonLeading, in: Capsule())
                            .offset(x: 6, y: -6)
                    }
                }

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
                    .textStyle(Typography.caption2)
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
        .padding(.vertical, BuzzSpacing.lg)
        .padding(.horizontal, 6)
        .background(
            isActive ? gift.accentColor.opacity(0.07) : .white.opacity(0.03),
            in: RoundedRectangle(cornerRadius: BuzzRadius.lg2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                .strokeBorder(
                    isActive ? gift.accentColor.opacity(0.28) : .white.opacity(0.05),
                    lineWidth: 1
                )
        )
        .animation(.buzzDefault, value: isActive)
    }
}

// MARK: - État actif sur le Player

extension CoinsViewModel.Gift {
    func isActiveOnPlayer(_ player: Player?) -> Bool {
        guard let player else { return false }
        switch self {
        case .scoreDoubled:         return player.hasScoreDoubled
        case .shieldSingle:         return player.hasShieldSingle
        case .shieldAll:            return player.hasShieldAll
        case .changeBuzzColor:      return player.customBuzzColor != nil
        case .changeBuzzSound:      return player.customBuzzSound != nil
        case .enemyCanNotBuzz, .allEnemiesCanNotBuzz, .showIndicies:
            return false  // effets ponctuels, pas de state persistant côté acheteur
        }
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
        case .scoreDoubled:         return Color.greenButtonLeading
        case .enemyCanNotBuzz:      return Color.redSoft
        case .allEnemiesCanNotBuzz: return Color.peach
        case .showIndicies:         return Color.yellowLeading
        case .changeBuzzColor:      return Color.purpleLeading
        case .changeBuzzSound:      return Color.skyBlue
        case .shieldSingle:         return Color.blueLeading
        case .shieldAll:            return Color.blueTrailing
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

    private let sounds = buzzSoundNames
    private var soundLabels: [String] { buzzSoundNames.map(buzzSoundLabel(for:)) }

    var body: some View {
        VStack(spacing: 0) {
            Text("Choisis ton son de buzzer")
                .font(.nohemi(.headline, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, BuzzSpacing.xxl)
                .padding(.bottom, BuzzSpacing.lg)

            ScrollView {
                VStack(spacing: BuzzSpacing.sm) {
                    ForEach(Array(zip(sounds, soundLabels)), id: \.0) { sound, label in
                        Button {
                            selectedSound = sound
                            playPreview(sound)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: selectedSound == sound ? "checkmark.circle.fill" : "circle")
                                    .textStyle(Typography.title3)
                                    .foregroundStyle(selectedSound == sound ? Color.skyBlue : .white.opacity(0.3))

                                Text(label)
                                    .font(.nohemi(.body, weight: .medium))
                                    .foregroundStyle(.white)

                                Spacer()

                                Image(systemName: "play.circle")
                                    .textStyle(Typography.cardTitle)
                                    .foregroundStyle(Color.textMuted)
                            }
                            .padding(.horizontal, BuzzSpacing.xl)
                            .padding(.vertical, BuzzSpacing.md)
                            .background(
                                selectedSound == sound ? Color.skyBlue.opacity(0.12) : .white.opacity(0.04),
                                in: RoundedRectangle(cornerRadius: BuzzRadius.sm)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: BuzzRadius.sm)
                                    .strokeBorder(
                                        selectedSound == sound ? Color.skyBlue.opacity(0.4) : .clear,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, BuzzSpacing.lg)
                    }
                }
                .padding(.bottom, BuzzSpacing.lg)
            }

            // CTA
            Button {
                coinsVM.buyGift(.changeBuzzSound, selectedSound: selectedSound)
                if coinsVM.errorMessage == nil {
                    dismiss()
                    isShopPresented = false
                }
            } label: {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "waveform")
                    Text(selectedSound == nil ? "Choisir un son d'abord" : "Confirmer — 20 🎵")
                        .font(.nohemi(.body, weight: .bold))
                }
                .foregroundStyle(selectedSound == nil ? Color.textMuted : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    selectedSound == nil
                        ? AnyShapeStyle(Color.white.opacity(0.08))
                        : AnyShapeStyle(LinearGradient(colors: [Color.blueLeading, Color.blueTrailing], startPoint: .leading, endPoint: .trailing)),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                )
            }
            .buttonStyle(.plain)
            .disabled(selectedSound == nil)
            .padding(.horizontal, BuzzSpacing.xl)
            .padding(.bottom, BuzzSpacing.xxxl)
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color.sheetBg, location: 0),
                    .init(color: Color.darkestPurple, location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
        // Hygiène : stoppe le préview audio si la sheet est fermée en pleine lecture
        // (sinon l'AVAudioPlayer continue de jouer en arrière-plan).
        .onDisappear {
            previewPlayer?.stop()
            previewPlayer = nil
        }
    }

    private func playPreview(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        previewPlayer?.stop()
        previewPlayer = try? AVAudioPlayer(contentsOf: url)
        previewPlayer?.play()
    }
}
