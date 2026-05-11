import Foundation

/// Abstraction du coordinateur Player exposée aux Game ViewModels côté Team.
/// Prépare le terrain pour les mocks de test (PHASE 3).
@MainActor
protocol TeamGameHost: AnyObject {
    var mpcService: MPCService? { get }
    var player: Player? { get }

    func sendBuzz(playerID: UUID)
}
