import Foundation

/// Abstraction du coordinateur Master exposée aux Game ViewModels.
/// Remplace les références concrètes à MasterFlowViewModel dans BlindTest et Quiz.
@MainActor
protocol MasterGameHost: AnyObject {
    // Transport
    var mpcService: MPCService { get }

    // Joueurs
    var players: [Player] { get }
    var connectedPlayersCount: Int { get }
    var totalPlayersCount: Int { get }
    var currentBuzzPlayer: Player? { get }

    // Actions score
    func addPointToPlayer(_ player: Player, points: Int)

    // Actions buzz
    func unlockBuzz()

    // Actions broadcast
    func broadcastPublicStateFromCurrentGame()
    func sendPublicState(_ state: PublicState)
    func broadcastGameLaunch(_ game: GameType)

    // Mutations atomiques évitant l'accès direct aux propriétés
    func setBuzzPlayer(_ player: Player)
    func resetBuzzState()
}
