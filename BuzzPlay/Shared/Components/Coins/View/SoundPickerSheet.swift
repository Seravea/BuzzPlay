//
//  SoundPickerSheet.swift
//  BuzzPlay
//

import SwiftUI
import AVFoundation

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
                    Text(selectedSound == nil ? "Choisir un son d'abord" : "Confirmer — 20 \(Image(systemName: BuzzIcon.music))")
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
