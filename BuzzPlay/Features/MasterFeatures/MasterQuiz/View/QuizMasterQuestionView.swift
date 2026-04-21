//
//  QuizMasterQuestionView.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Screen 2: Active Question

struct QuizActiveQuestionScreen: View {
    @Bindable var quizMasterVM: QuizMasterViewModel
    let onValidate: (Int) -> Void
    let onReject: () -> Void

    var buzzedTeam: Team? { quizMasterVM.teamHasBuzz }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 14) {
                timerHero
                questionCard
                answersSection
                scoresSection
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)

            // Dimmed overlay quand une équipe a buzzé
            if buzzedTeam != nil {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { } // bloque le tap en dessous
                    .transition(.opacity)
            }

            // Bottom sheet buzz
            if let team = buzzedTeam {
                QuizBuzzSheet(
                    team: team,
                    reactionTime: quizMasterVM.formattedTime,
                    onValidate: onValidate,
                    onReject: onReject
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.05), value: buzzedTeam != nil)
    }

    // MARK: Timer

    private var timerHero: some View {
        HStack {
            Text(quizMasterVM.formattedTime)
                .font(.nohemi(.largeTitle, weight: .extraBold))
                .foregroundStyle(buzzedTeam != nil ? Color(hex: "#F6339A") : Color.mustardYellow)
                .tracking(3)
            Spacer()
            Text(buzzedTeam != nil ? "PAUSÉ" : "EN COURS")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.white.opacity(0.08), in: Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.darkestPurple, in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Question Card

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("QUESTION")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)
            if let question = quizMasterVM.currentQuestion {
                Text(question.title)
                    .font(.nohemi(.title3, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.1), lineWidth: 1))
    }

    // MARK: Answers

    private var answersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RÉPONSES")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.8)
                .padding(.leading, 2)

            if let answers = quizMasterVM.currentQuestion?.answers, !answers.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(answers, id: \.self) { answer in
                        Text(answer)
                            .font(.nohemi(.subheadline, weight: .semiBold))
                            .foregroundStyle(Color(hex: "#7DFFA0"))
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#00C950").opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "#00C950").opacity(0.25), lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: Scores + Waiting Radar

    private var scoresSection: some View {
        let teams = quizMasterVM.gameVM.teams.sorted { $0.score > $1.score }
        let maxScore = max(teams.map(\.score).max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 8) {
            Text("CLASSEMENT EN DIRECT")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(0.8)
                .padding(.leading, 2)

            ForEach(teams) { team in
                QuizScoreRow(team: team, maxScore: maxScore)
            }

            // Radar — attente buzz
            HStack(spacing: 10) {
                RadarPulseView()
                Text("En attente d'un buzz…")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 4)
        }
    }
}

// MARK: - Score Row

struct QuizScoreRow: View {
    let team: Team
    let maxScore: Int

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(team.teamColor.color)
                .frame(width: 8, height: 8)

            Text(team.name)
                .font(.nohemi(.subheadline, weight: .semiBold))
                .foregroundStyle(.white)

            Spacer()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1)).frame(height: 4)
                    let w = maxScore > 0 ? CGFloat(team.score) / CGFloat(maxScore) * geo.size.width : 0
                    Capsule()
                        .fill(team.teamColor.gradient)
                        .frame(width: w, height: 4)
                        .animation(.spring(), value: team.score)
                }
            }
            .frame(width: 80, height: 4)

            Text("\(team.score) pts")
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .frame(minWidth: 50, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.07), lineWidth: 1))
    }
}

// MARK: - Buzz Bottom Sheet

struct QuizBuzzSheet: View {
    let team: Team
    let reactionTime: String
    let onValidate: (Int) -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            // Handle
            RoundedRectangle(cornerRadius: 99)
                .fill(.white.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.bottom, 2)

            Text("A BUZZÉ !")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(0.5)

            // Team card
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(team.teamColor.gradient)
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(team.name.prefix(1)))
                            .font(.nohemi(.title3, weight: .bold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.nohemi(.body, weight: .bold))
                        .foregroundStyle(.white)
                    Text(team.players.map(\.name).joined(separator: " · "))
                        .font(.nohemi(.caption2, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(1)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("RÉACTION")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(0.5)
                    Text(reactionTime)
                        .font(.nohemi(.body, weight: .extraBold))
                        .foregroundStyle(Color.mustardYellow)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.mustardYellow.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.mustardYellow.opacity(0.25), lineWidth: 1))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(team.teamColor.gradient)
                    .frame(width: 4)
                    .padding(.leading, 0)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }

            // Validation buttons — différenciés par taille
            HStack(spacing: 8) {
                validationButton(points: 10, scale: 0.88)
                validationButton(points: 20, scale: 0.94)
                validationButton(points: 30, scale: 1.0, highlighted: true)
            }

            // Reject button
            Button(action: onReject) {
                Text("Refuser la réponse ✕")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(Color(hex: "#FF6B70"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color(hex: "#FB2C36").opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color(hex: "#FB2C36").opacity(0.35), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 40)
        .background(Color(hex: "#1A0535"), in: RoundedRectangle(cornerRadius: 28))
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func validationButton(points: Int, scale: CGFloat, highlighted: Bool = false) -> some View {
        let responses = points / 10
        Button { onValidate(points) } label: {
            VStack(spacing: 2) {
                Text("+\(points)")
                    .font(.nohemi(.title3, weight: .extraBold))
                Text("\(responses) réponse\(responses > 1 ? "s" : "")")
                    .font(.nohemi(.caption2, weight: .semiBold))
                    .opacity(0.7)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                LinearGradient(colors: [Color.greenButtonLeading, Color.greenButtonTrailing],
                               startPoint: .leading, endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .opacity(highlighted ? 1 : (scale < 0.9 ? 0.65 : 0.82))
            .shadow(color: highlighted ? Color.greenButtonLeading.opacity(0.35) : .clear, radius: 8)
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Radar Pulse Animation

struct RadarPulseView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .strokeBorder(.white.opacity(0.5), lineWidth: 1.5)
                    .frame(width: animate ? 36 : 8, height: animate ? 36 : 8)
                    .opacity(animate ? 0 : 0.8)
                    .animation(
                        .easeOut(duration: 2).repeatForever(autoreverses: false).delay(Double(i) * 0.6),
                        value: animate
                    )
            }
            Circle()
                .fill(.white.opacity(0.5))
                .frame(width: 6, height: 6)
        }
        .frame(width: 36, height: 36)
        .onAppear { animate = true }
    }
}

// MARK: - GameColor helpers

extension GameColor {
    var color: Color {
        switch self {
        case .redGame:    return Color(hex: "#FB2C36")
        case .greenGame:  return Color(hex: "#00C950")
        case .blueGame:   return Color(hex: "#2B7FFF")
        case .yellowGame: return Color(hex: "#FEC260")
        case .purpleGame: return Color(hex: "#AD46FF")
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .redGame:    return LinearGradient(colors: [Color(hex: "#FB2C36"), Color(hex: "#F6339A")], startPoint: .leading, endPoint: .trailing)
        case .greenGame:  return LinearGradient(colors: [Color(hex: "#00C950"), Color(hex: "#009966")], startPoint: .leading, endPoint: .trailing)
        case .blueGame:   return LinearGradient(colors: [Color(hex: "#2B7FFF"), Color(hex: "#00B8DB")], startPoint: .leading, endPoint: .trailing)
        case .yellowGame: return LinearGradient(colors: [Color(hex: "#F0B100"), Color(hex: "#FF6900")], startPoint: .leading, endPoint: .trailing)
        case .purpleGame: return LinearGradient(colors: [Color(hex: "#AD46FF"), Color(hex: "#F6339A")], startPoint: .leading, endPoint: .trailing)
        }
    }
}
