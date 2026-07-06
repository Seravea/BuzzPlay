//
//  QuizThemeSelectionView.swift
//  BuzzPlay
//

import SwiftUI

#if os(iOS) && swift(>=5.9)
import FoundationModels
#endif

struct QuizThemeSelectionView: View {
    @Bindable var viewModel: QuizThemeSelectionViewModel
    @EnvironmentObject private var router: Router

    @State private var showAIGeneratorSheet = false
    @State private var showAIReviewSheet = false
    @State private var aiGeneratedSet: QuizSet?
    @State private var aiGenerator = AIQuizGenerator()

    // #v1-packs — pack premium sélectionné pour achat (sheet mock → StoreKit 2 plus tard)
    @State private var packToBuy: RemoteQuizPack?

    // Alertes affichées quand l'appareil est éligible mais Apple Intelligence indisponible.
    @State private var showEnableAIAlert = false
    @State private var showModelNotReadyAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.bottom, BuzzSpacing.xxl)

                ForEach(viewModel.groupedThemes, id: \.label) { group in
                    groupSection(label: group.label, themes: group.themes)
                        .padding(.bottom, 28)
                }
            }
            .padding(.top, BuzzSpacing.lg)     // #header-air — ne pas coller à la nav bar
            .padding(.bottom, BuzzSpacing.xxxl)
        }
        .foregroundStyle(.white)
        .background(BackgroundAppView())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Quiz")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .masterDarkNavBar()  // #8
        // #v1-packs — achat d'un pack premium (mock V1, StoreKit 2 branché ensuite)
        .sheet(item: $packToBuy) { pack in
            PackPurchaseSheet(pack: pack)
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.sheetBg)
        }
        .sheet(isPresented: $showAIGeneratorSheet) {
            if #available(iOS 26.0, *) {
                #if os(iOS) && swift(>=5.9)
                AIQuizSetupView(
                    generator: aiGenerator,
                    quizRoundsTotal: viewModel.quizRoundsTotal,
                    onComplete: { set in
                        aiGeneratedSet = set
                        showAIGeneratorSheet = false
                        showAIReviewSheet = true
                    },
                    onDismiss: { showAIGeneratorSheet = false }
                )
                .presentationBackground(Color.sheetBg)
                #else
                EmptyView()
                #endif
            } else {
                EmptyView()
            }
        }
        .sheet(isPresented: $showAIReviewSheet) {
            if #available(iOS 26.0, *) {
                #if os(iOS) && swift(>=5.9)
                AIQuizReviewView(
                    generator: aiGenerator,
                    quizSet: aiGeneratedSet ?? QuizSet(id: UUID(), title: "", theme: QuizThemes.annees2000, questions: []),
                    targetCount: viewModel.quizRoundsTotal,
                    onLaunch: { set in
                        showAIReviewSheet = false
                        viewModel.selectSet(set)
                        router.push(.quizMaster)
                    },
                    onBack: { showAIReviewSheet = false }
                )
                .presentationBackground(Color.sheetBg)
                #else
                EmptyView()
                #endif
            } else {
                EmptyView()
            }
        }
        .alert("Activer Apple Intelligence", isPresented: $showEnableAIAlert) {
            Button("Ouvrir les Réglages") { openAppSettings() }
            Button("Plus tard", role: .cancel) {}
        } message: {
            Text("La génération de quiz par IA nécessite Apple Intelligence. Active-le dans Réglages › Apple Intelligence et Siri, puis reviens ici.")
        }
        .alert("Apple Intelligence se prépare", isPresented: $showModelNotReadyAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Le modèle d'Apple Intelligence est en cours de téléchargement. Réessaie dans quelques minutes.")
        }
    }

    /// Ouvre la page Réglages de l'app (point d'entrée le plus direct vers Apple Intelligence).
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: BuzzSpacing.md) {
            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                Text("Choisir un quiz")
                    .font(.nohemi(.title, weight: .extraBold)).titleTracking()
                    .foregroundStyle(.white)
                Text("Sélectionne le thème et la playlist")
                    .font(.nohemi(.subheadline, weight: .regular))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            aiGenerateButton
        }
    }

    /// Bouton « Générer » selon l'état réel d'Apple Intelligence :
    /// - disponible → actif, ouvre le générateur
    /// - activé mais modèle pas prêt → grisé, message de patience
    /// - Apple Intelligence désactivé → grisé, invite à l'activer dans les Réglages
    /// - appareil non éligible (ou iOS < 26) → rien
    @ViewBuilder
    private var aiGenerateButton: some View {
        if #available(iOS 26.0, *) {
            #if os(iOS) && swift(>=5.9)
            switch SystemLanguageModel.default.availability {
            case .available:
                generateButtonLabel(enabled: true) { showAIGeneratorSheet = true }
            case .unavailable(.appleIntelligenceNotEnabled):
                generateButtonLabel(enabled: false) { showEnableAIAlert = true }
            case .unavailable(.modelNotReady):
                generateButtonLabel(enabled: false) { showModelNotReadyAlert = true }
            case .unavailable:
                EmptyView()
            }
            #endif
        }
    }

    @ViewBuilder
    private func generateButtonLabel(enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .textStyle(Typography.footnoteEM)
                Text("Générer")
                    .font(.nohemi(.caption, weight: .bold))
            }
            .foregroundStyle(enabled ? .white : Color.textMuted)
            .padding(.horizontal, BuzzSpacing.md)
            .padding(.vertical, BuzzSpacing.sm)
            .background(Color.purpleLeading.opacity(enabled ? 0.2 : 0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.sm2)
                    .strokeBorder(Color.purpleLeading.opacity(enabled ? 0.3 : 0.12), lineWidth: 1)
            )
        }
    }

    // MARK: - Group Section

    @ViewBuilder
    private func groupSection(label: String, themes: [QuizTheme]) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.lg) {
            // Eyebrow label
            Text(label.uppercased())
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Color.textMuted)
                .padding(.horizontal, BuzzSpacing.xl)

            VStack(spacing: 28) {
                ForEach(themes) { theme in
                    // #v1-packs — pack premium verrouillé : card cadenas → sheet d'achat
                    if viewModel.isLocked(theme), let pack = viewModel.remotePack(for: theme) {
                        ThemeLockedPackCard(theme: theme, pack: pack, onTap: { packToBuy = pack })
                            .padding(.horizontal, BuzzSpacing.lg)
                    } else {
                        // #v1-packs — IA = bouton dédié (header), plus de « thème vide → IA ».
                        // Un thème non premium sans contenu ne s'affiche simplement pas.
                        let sets = viewModel.sets(for: theme)
                        if !sets.isEmpty {
                            ThemeSection(theme: theme, sets: sets) { set in
                                viewModel.selectSet(set)
                                router.push(.quizMaster)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuizThemeSelectionView(viewModel: QuizThemeSelectionViewModel(gameVM: MasterFlowViewModel()))
            .environmentObject(Router())
    }
}
