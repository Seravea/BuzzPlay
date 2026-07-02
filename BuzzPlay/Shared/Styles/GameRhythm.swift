//
//  GameRhythm.swift
//  BuzzPlay
//
//  ⏱️ TOUS les délais qui font le rythme du jeu, centralisés pour le tuning.
//  Les valeurs sont celles d'origine (aucun changement de comportement) —
//  ajuster ICI après un test device, jamais en dur dans les vues/VMs.
//

import Foundation

enum GameRhythm {

    // MARK: - Feedback de réponse (côté Player)

    /// Durée de l'overlay "BONNE/MAUVAISE RÉPONSE" avant auto-dismiss.
    /// Pendant ce temps le joueur ne voit pas la suite → raccourcir = rythme plus arcade.
    static let answerOverlay: Duration = .seconds(1.5)

    /// Durée du toast "pouvoir" (blocage posé / parade par bouclier) sur le buzzer (S2).
    static let powerFeedback: Duration = .seconds(2.5)

    /// Délai entre la révélation de la réponse et la montée de la sheet de classement
    /// inter-manche (calé pour démarrer après la fin de l'overlay ci-dessus).
    static let leaderboardDelay: Duration = .seconds(2.7)

    /// #chantier6 — verrou du bouton « Musique suivante » (Blind Test) après une bonne réponse.
    /// Le titre est révélé IMMÉDIATEMENT ; ce verrou garantit juste que la sheet de classement
    /// inter-manche a le temps de MONTER (leaderboardDelay) et d'être vue (+1s) avant que le
    /// Maître enchaîne (sinon un nouveau countdown l'annule). Pas la peine d'attendre toute
    /// l'animation interne → ~3,7s (5,6s jugé trop long au test).
    static let blindTestNextHold: Duration = leaderboardDelay + .seconds(1)

    /// #chantier6 — durée de révélation de la MusicCard quand le Maître PASSE un morceau que
    /// personne n'a trouvé (pas de classement à ce moment) : les joueurs voient le titre ~2,5s
    /// puis on enchaîne tout seul. Plus court que blindTestNextHold (rien à attendre côté sheet).
    static let blindTestSkipReveal: Duration = .seconds(2.5)

    // MARK: - Fenêtre de réponse après un buzz (#answer-window)

    /// Durée (s) de la barre qui se vide après un buzz : passé ce délai, le Master est
    /// incité (sans être forcé) à refuser — anti buzz-réflexe. Source de vérité unique.
    static let answerWindow: TimeInterval = 5

    // MARK: - Countdown 3-2-1-GO

    /// Durée de chaque chiffre du décompte (3… 2… 1…).
    static let countdownTick: Duration = .seconds(1)

    /// Durée d'affichage du "GO!" avant de rendre la main au buzzer.
    static let goFlash: Duration = .milliseconds(800)

    /// Quiz : temps mort après un refus de réponse (laisse l'overlay "Raté" se voir)
    /// avant de lancer le décompte de reprise.
    static let rejectResumeDelay: Duration = .milliseconds(1500)

    // MARK: - Transitions inter-jeux (côté Player)

    /// Durée de l'overlay "Nouvelle partie !" avant redirection (#B6).
    static let newGameNotif: Duration = .seconds(2)

    /// Durée d'affichage du toast "+X Notes reçues".
    static let notesToast: TimeInterval = 2.5

    /// Respiration entre la fermeture d'une sheet et l'ouverture de la suivante
    /// (classement inter-jeu → annonce du jeu, podium…).
    static let sheetTransition: TimeInterval = 0.35

    // MARK: - Infrastructure (toucher avec précaution)

    /// Debounce des déconnexions MPC : absorbe les micro-coupures avant d'acter la déco.
    static let disconnectDebounce: Duration = .milliseconds(300)

    /// "Quitter" Master : délai pour laisser partir le message masterLeftParty
    /// avant de couper la session (#quit-teardown).
    static let quitTeardown: Duration = .milliseconds(400)

    /// Reconnexion : délai avant de renvoyer playerReady (laisse la session se stabiliser).
    static let playerReadyReco: Duration = .milliseconds(500)

    /// 1er arrivé sur le buzzer : délai avant playerReady (laisse la transition
    /// de navigation se terminer, #A5).
    static let playerReadyFirst: Duration = .milliseconds(600)

    /// Relance du masterLaunchedGame vers les joueurs qui ne l'ont pas reçu.
    static let inviteRetry: Duration = .seconds(2)
}
