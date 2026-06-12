# CLAUDE.md — BuzzPlay iOS App

> Ce fichier est le point d'entrée pour Claude Code.
> Lis-le intégralement avant de toucher au code.
> L'app est **quasi-terminée** — ton rôle est de corriger, compléter et ajouter des features précises. Ne refactorise pas ce qui fonctionne.

---

## Contexte produit

**BuzzPlay** est une app iOS de jeu de soirée multijoueur en local (sans internet).
Un **Master** anime la partie depuis son iPhone. Les **Players** buzzent depuis leurs propres iPhones.
Connexion via **MultipeerConnectivity** (Wi-Fi local, pas d'internet requis).

Deux modes de jeu : **Quiz** (questions/réponses avec buzzer) et **Blind Test** (deviner un titre depuis Apple Music via MusicKit).

### Stack technique
- Swift / SwiftUI, iOS 17+
- MultipeerConnectivity (MPC)
- MusicKit + AVFoundation
- Architecture MVVM avec `@Observable`
- Pas de CoreData, persistance légère via UserDefaults

### Rôles
- **Master** : 1 seul par session, advertiser MPC, anime et contrôle tout
- **Player** : N joueurs, browsers MPC, buzzent et utilisent des pouvoirs

### Navigation
- **Master** : `HomeView` → `LobbyMasterView` → `MasterChooseGameView` (NavigationStack hub) → Quiz / BlindTest / Score
- **BlindTest Master** : ZStack avec slide animation entre 3 états (Search → SongList → Active) — architecture intentionnelle, ne pas refactoriser
- **Player** : `HomeView` → `CreateTeamView` → `PlayerChooseGameView` → `BuzzerPlayerView`

### État partagé
`PublicState` diffusé par le Master à tous les Players en temps réel via MPC.

---

## Modèle économique (contexte pour les features à coder)

### Monnaie in-app : les Notes (🎵)
- Monnaie consommable achetée par le **Master** via IAP
- Le Master les **distribue aux Players** avant/pendant la partie
- Les Players les **dépensent** dans le Shop Cadeaux pour acheter des pouvoirs
- Les Notes **ne périment jamais** (règle Apple StoreKit obligatoire)
- Persistance locale : `UserDefaults` pour le solde Master + solde de chaque Player (transmis via MPC)

### Packs IAP (consommables StoreKit 2)
| ID produit | Notes | Prix |
|---|---|---|
| `buzzplay.notes.intro` | 100 Notes | 0,99€ |
| `buzzplay.notes.soiree` | 400 Notes | 2,99€ |
| `buzzplay.notes.weekend` | 1 000 Notes | 5,99€ |
| `buzzplay.notes.saison` | 2 500 Notes | 9,99€ |

### Unlock V2 (non-consommable, à préparer mais pas activer en V1)
| ID produit | Description | Prix |
|---|---|---|
| `buzzplay.master.online` | Mode en ligne permanent | 9,99€ |

### Pouvoirs (Shop Cadeaux — côté Player)
| Enum case | Coût | Effet |
|---|---|---|
| `scoreDoubled` | 30 🎵 | ×2 points prochaine bonne réponse |
| `enemyCanNotBuzz` | 50 🎵 | Bloque le buzzer d'un joueur choisi |
| `allEnemiesCanNotBuzz` | 100 🎵 | Bloque tous les adversaires |
| `showIndicies` | 50 🎵 | Indice sur la question/musique |
| `changeBuzzColor` | 20 🎵 | Couleur buzzer aléatoire |
| `changeBuzzSound` | 20 🎵 | Son buzzer aléatoire |
| `shieldSingle` | 30 🎵 | **NOUVEAU** Protège contre le prochain blocage d'un joueur |
| `shieldAll` | 60 🎵 | **NOUVEAU** Protège contre "Bloquer tout le monde" |

---

## Design System (respecter absolument)

> ⚠️ **RÈGLES D'ENFORCEMENT — À lire avant chaque vue créée ou modifiée**
> Ces règles sont vérifiées par des warnings Xcode. Toute violation est un warning visible dans le build.

### ❌ Ce qu'il ne faut JAMAIS faire dans une vue

```swift
// ❌ INTERDIT — Color(hex:) est @available(*, deprecated)
Color(hex: "#AD46FF")

// ❌ INTERDIT — taille fixe arbitraire
.font(.system(size: 24, weight: .bold))
.font(.system(size: 13))

// ❌ INTERDIT — valeurs de padding/spacing en dur
.padding(16)
.padding(.horizontal, 24)
.cornerRadius(12)

// ❌ INTERDIT — gradient inline
LinearGradient(colors: [Color(hex: "#AD46FF"), Color(hex: "#F6339A")], ...)
```

### ✅ Ce qu'il faut utiliser à la place

```swift
// ✅ Couleurs — tokens depuis Colors.swift (extension Color)
Color.purpleLeading    // #AD46FF — accent violet principal
Color.sheetBg          // #1A0535 — fond de sheet
Color.greenButtonLeading
Color.redLeading
// → Voir Shared/Styles/Colors.swift pour la liste complète

// ✅ Typographie — tokens depuis Typography.swift
.textStyle(Typography.screenTitle)    // titre principal vue
.textStyle(Typography.sectionTitle)   // titre de section
.textStyle(Typography.label)          // label, bouton
.textStyle(Typography.score)          // chiffre de score (large + black)
.textStyle(Typography.tag)            // badge, pill
// → Voir Shared/Extensions/TextExtensions.swift + Shared/Styles/Typography.swift

// ✅ Spacing — constantes depuis BuzzLayout.swift
.padding(BuzzSpacing.md)             // 16pt
.padding(.horizontal, BuzzSpacing.lg) // 24pt
.cornerRadius(BuzzRadius.md)          // 12pt
// → Voir Shared/Styles/BuzzLayout.swift

// ✅ Gradients — tokens depuis Colors.swift
LinearGradient.buzzPrimary    // purple → pink
LinearGradient.buzzSuccess    // green CTA
LinearGradient.buzzDanger     // red → pink
LinearGradient.buzzAmber      // yellow → orange
LinearGradient.buzzMaster     // blue Master
// → Voir Shared/Styles/Colors.swift

// ✅ Animations — tokens depuis BuzzLayout.swift
.animation(.buzzSnappy, value: isActive)
.animation(.buzzBouncy, value: isBuzzed)

// ✅ ViewModifiers composites — depuis Theme.swift
.buzzerScoreStyle()    // chiffre géant score buzzer
.cardStyle()           // card semi-transparente standard
.overlayLabelStyle()   // texte blanc sur fond sombre
```

### Couleurs disponibles (Colors.swift)
```swift
// ⚠️ Noms RÉELS depuis Colors.swift — cette liste DOIT y correspondre.
//    En cas de doute, ouvrir Shared/Styles/Colors.swift — ne PAS inventer de token.

// Fond global — dégradé diagonal via BackgroundAppView
// darkestPurple (#2A0944) → darkPurple (#3B185F) → darkPink (#A12568)

// Accents principaux
Color.purpleLeading     // #AD46FF — accent violet principal   (⚠️ PAS "buzzPurple")
Color.purpleTrailing    // #F6339A — accent secondaire (rose)
Color.buzzHotPink       // #FF2D78
Color.mustardYellow     // #FEC260 — Notes / jaune chaud
Color.greenGlow         // #7DFFA0 — glow positif               (⚠️ PAS "successGlow")
Color.sheetBg           // #1A0535 — fond de sheet              (⚠️ PAS "buzzDark")

// Jaune/orange & bleu : voir les paires leading/trailing ci-dessous (yellowLeading
// #F0B100, yellowTrailing #FF6900, blueTrailing #00B8DB) — il n'existe PAS de
// buzzAmber / buzzOrange / buzzCyan en tant que Color.

// Gradients (déjà dans Colors.swift)
Color.greenButtonLeading / greenButtonTrailing   // CTA principal
Color.redLeading / redTrailing                   // Destructif
Color.purpleLeading / purpleTrailing             // Buzzer / Player
Color.yellowLeading / yellowTrailing             // Notes / cadeaux
Color.blueLeading / blueTrailing                 // Master
```

### Typographie
```swift
// Police exclusive : Nohemi (custom font, déjà intégrée)
// Toujours passer par .textStyle(Typography.xxx) ou .font(.nohemi(...))
// JAMAIS .font(.system(size:))
// Graisses disponibles : thin, extraLight, light, regular, medium, semiBold, bold, extraBold, black
```

### Règles visuelles
- Boutons : `RoundedRectangle(cornerRadius: BuzzRadius.md)` + gradient linéaire horizontal
- Cards : `.background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))` + border `.white.opacity(0.10)`
- Textes secondaires : `.white.opacity(0.45)`
- Icônes : SF Symbols, `.white` ou `.white.opacity(0.25)`
- Dark mode permanent — aucun fond clair
- Padding horizontal contenu : `BuzzSpacing.md` (20pt) / listes : `BuzzSpacing.sm` (16pt)
- Langue : **français partout**

---

## TODO LIST — Priorisée

### 🔴 PRIORITÉ 1 — Correctifs bloquants (faire en premier)

#### T1 — Synchronisation MPC des états de jeu
- [ ] Vérifier que `PublicState` se synchronise correctement sur tous les Players quand le Master change d'état (ex: passer de SongList à ActiveScreen en BlindTest)
- [ ] S'assurer que la déconnexion d'un Player en cours de partie ne crash pas le Master
- [ ] Ajouter un mécanisme de reconnexion automatique si un Player perd la connexion temporairement (timeout 10s, puis alerte)
- [ ] Tester avec 6 appareils simultanés (stress test MPC)

#### T2 — Timer BlindTest
- [ ] Le chrono `SS:CS` (secondes:centièmes) doit être synchronisé entre Master et Players — actuellement chaque device a son propre timer local, ce qui crée des désynchronisations
- [ ] Solution recommandée : le Master est la source de vérité du timer, diffuse le temps restant via MPC toutes les 500ms
- [ ] Le timer doit se mettre en pause quand quelqu'un buzzz et reprendre si le Master invalide la réponse

#### T3 — Countdown 3-2-1-GO avant BlindTest
- [ ] L'overlay countdown doit être diffusé aux Players via MPC pour qu'ils voient aussi le compte à rebours
- [ ] S'assurer que la musique ne démarre qu'après le GO! et uniquement côté Master (AVFoundation)

#### T4 — Validation réponse Quiz
- [ ] Quand le Master valide une réponse, les points doivent être crédités immédiatement dans `PublicState` et propagés à tous
- [ ] L'overlay bonne/mauvaise réponse côté Player doit s'auto-dismiss après exactement 3.5s
- [ ] Vérifier que le buzzer se re-déverrouille pour tous après validation/refus

---

### 🟠 PRIORITÉ 2 — Features manquantes (cœur du produit)

#### T5 — Système de Notes complet (IAP + distribution + dépense)

##### T5a — StoreKit 2 (côté Master)
- [ ] Créer `NotesStore.swift` — `@Observable` class gérant StoreKit 2
- [ ] Implémenter `loadProducts()` pour les 4 packs (`buzzplay.notes.*`)
- [ ] Implémenter `purchase(product:)` avec gestion des états : `.purchasing`, `.success`, `.failure`, `.pending`
- [ ] Implémenter `restorePurchases()` (obligatoire Apple)
- [ ] Persister le solde Notes Master dans `UserDefaults` avec clé `"buzzplay.master.notesBalance"`
- [ ] Ajouter `Transaction.updates` listener pour gérer les achats complétés hors-app
- [ ] Préparer (sans activer) le produit non-consommable `buzzplay.master.online` dans le modèle

##### T5b — Interface d'achat (côté Master)
- [ ] Créer `NotesShopView.swift` — bottom sheet `.large` accessible depuis `MasterChooseGameView`
- [ ] Afficher solde actuel en haut (grand, avec icône 🎵)
- [ ] 4 cards de packs avec : nom, quantité Notes, prix, badge "Meilleure valeur" sur le pack 400
- [ ] Loading state pendant l'achat (ProgressView sur la card)
- [ ] Message de confirmation post-achat avec animation (+400 🎵 ajoutés)
- [ ] Gérer l'état "achats indisponibles" (mode avion, contrôle parental)

##### T5c — Distribution des Notes aux Players (côté Master)
- [ ] Dans `MasterChooseGameView`, section "Notes" existante : ajouter deux modes
  - Mode **Équitable** : bouton "Distribuer équitablement (X 🎵 chacun)" — divise le solde par nombre de joueurs
  - Mode **Personnalisé** : stepper +10/-10 par joueur, total restant affiché en temps réel
- [ ] Transmettre les soldes via MPC (`PublicState` ou message dédié `NotesCreditedMessage`)
- [ ] Le solde Player est local à son iPhone (UserDefaults côté Player, clé `"buzzplay.player.notesBalance"`)
- [ ] Afficher le solde Player dans le header de `BuzzerPlayerView` : `160 🎵`

##### T5d — Envoi de Notes en live pendant une manche
- [ ] Ajouter un bouton discret "🎵 +" dans la toolbar Master pendant `BlindTestActiveScreen` et Quiz actif
- [ ] Bottom sheet rapide : liste des joueurs + sélecteur 20 / 50 / 100 Notes
- [ ] Envoi instantané via MPC → Player reçoit une notification badge sur son buzzer ("Le Master t'envoie 50 🎵 !")
- [ ] Animation slide-up du badge, auto-dismiss 3s

##### T5e — Starter Pack (offre unique post-première soirée)
- [ ] Détecter la fin de la première partie complète du Master (flag `UserDefaults` `"buzzplay.master.hasPlayedFirstGame"`)
- [ ] Afficher une sheet unique (jamais re-montrée) : "Pack Découverte — 300 Notes à 1,99€"
- [ ] Ce pack est un IAP séparé : `buzzplay.notes.starter` — 300 Notes, 1,99€, marqué "Offre unique"
- [ ] Flag `"buzzplay.master.starterPackShown"` pour ne jamais re-proposer

#### T6 — Shop Cadeaux complet (côté Player)

##### T6a — Deux nouveaux pouvoirs (Boucliers)
- [ ] Ajouter `shieldSingle` (30 🎵) et `shieldAll` (60 🎵) à l'enum `GiftType` (ou équivalent)
- [ ] `shieldSingle` : quand un adversaire active `enemyCanNotBuzz` contre ce Player, le bouclier s'active automatiquement et consomme 0 Notes supplémentaires (déjà payé)
- [ ] `shieldAll` : même logique contre `allEnemiesCanNotBuzz`
- [ ] Le bouclier actif est visible sur le buzzer du Player (badge bleu "🛡️ Bouclier actif")
- [ ] Transmettre l'état bouclier dans `PublicState`

##### T6b — Logique d'achat côté Player
- [ ] `GiftShopSheet` existante : griser les cards si solde insuffisant (déjà implémenté selon le brief — vérifier)
- [ ] Après achat d'un pouvoir : déduire les Notes, diffuser via MPC l'action à appliquer
- [ ] Le Master reçoit le message et applique l'effet (il est la source de vérité du jeu)
- [ ] Confirmation visuelle côté Player : animation sur la card achetée

##### T6c — Pouvoir `enemyCanNotBuzz` — sélection de cible
- [ ] Quand un Player achète "Bloquer 1 joueur", afficher une sheet de sélection avec la liste des autres Players
- [ ] Après sélection, envoyer le message MPC avec `targetPeerID`
- [ ] Le Master bloque le buzzer du joueur ciblé dans `PublicState`
- [ ] Vérifier le bouclier du joueur ciblé avant d'appliquer le blocage

#### T7 — Écran de score amélioré

- [ ] `ScoreMasterView` : ajouter un bouton "Nouvelle partie" qui remet les scores à zéro et retourne à `MasterChooseGameView` sans déconnecter les Players
- [ ] `ScorePlayerView` : afficher le rang du joueur (#1, #2...) en plus du score
- [ ] Podium animé pour le Top 3 à la fin de partie (optionnel V1, priorité V1.5)

---

### 🟡 PRIORITÉ 3 — Améliorations UX (après P1 et P2)

#### T8 — Thèmes Quiz (architecture extensible)

- [ ] Ajouter `isPremium: Bool` dans le modèle `QuizPack` (ou équivalent)
- [ ] En V1, tous les packs ont `isPremium = false` — aucun paywall visible
- [ ] Prévoir un `QuizPackStore.swift` vide avec la structure StoreKit pour les thèmes payants (V1.5)
- [ ] IDs futurs à préparer : `buzzplay.quiz.cinema`, `buzzplay.quiz.sport`, `buzzplay.quiz.annees90`, `buzzplay.quiz.noel`

#### T9 — Partage App Store post-soirée

- [ ] À la fin de chaque partie (retour à `MasterChooseGameView`), afficher une fois sur 3 une bannière discrète en bas : "Tu as aimé BuzzPlay ? Partage-le 🎵"
- [ ] Tap → `ShareLink` natif iOS avec texte pré-rempli : "Je joue à BuzzPlay, le jeu de soirée sur iPhone ! 🎵 [lien App Store]"
- [ ] Bouton "Noter l'app" → `SKStoreReviewController.requestReview()` — déclencher après la 3ème partie jouée

#### T10 — Onboarding Master (première utilisation)

- [ ] Lors du premier lancement en mode Master, afficher un overlay tutoriel 3 étapes (SwiftUI TabView avec PageTabViewStyle) :
  1. "Connecte tes amis" — illustration MPC
  2. "Lance le jeu" — illustration buzzer
  3. "Achète des Notes pour plus de fun" — illustration Shop avec CTA "Voir les packs"
- [ ] Flag `UserDefaults` `"buzzplay.master.onboardingShown"`

#### T11 — Accessibilité et robustesse

- [ ] Ajouter `.accessibilityLabel` sur tous les boutons sans texte (icônes seules)
- [ ] Vérifier le comportement quand l'app passe en background pendant une partie (MPC se suspend — afficher une alerte au retour)
- [ ] Gérer le cas où le Master ferme l'app : les Players doivent voir "Le Master a quitté la partie" et retourner à `HomeView`

---

### 🔵 PRIORITÉ 4 — V2 Online (à préparer, pas implémenter)

> Ne pas coder ces features en V1. Créer uniquement les stubs et la structure.

#### T12 — Stubs V2 (architecture à préparer)

- [ ] Créer un protocole `GameTransport` abstraisant MPC :
  ```swift
  protocol GameTransport {
      func send(_ message: GameMessage, to peers: [PeerID]) async throws
      func broadcast(_ message: GameMessage) async throws
      var receivedMessages: AsyncStream<(PeerID, GameMessage)> { get }
  }
  ```
- [ ] `MPCTransport: GameTransport` — implémentation actuelle refactorisée derrière ce protocole
- [ ] `WebSocketTransport: GameTransport` — stub vide, marqué `// TODO: V2`
- [ ] Cette abstraction permet de switcher MPC → WebSocket en V2 sans toucher à la logique de jeu

- [ ] Créer `OnlineUnlockManager.swift` — stub vérifiant `buzzplay.master.online` dans StoreKit (retourne toujours `false` en V1)
- [ ] Dans `MasterChooseGameView`, ajouter un bouton "Mode en ligne" grisé avec badge "Bientôt" (visible mais non-interactif)

---

## Plan de code — Fichiers à créer / modifier

### Nouveaux fichiers à créer

```
BuzzPlay/
├── Store/
│   ├── NotesStore.swift          # StoreKit 2 — IAP Notes (T5a)
│   ├── QuizPackStore.swift       # Stub thèmes payants (T8)
│   └── OnlineUnlockManager.swift # Stub unlock V2 (T12)
├── Views/
│   ├── Master/
│   │   ├── NotesShopView.swift         # Shop IAP Master (T5b)
│   │   ├── NotesDistributionSheet.swift # Distribution Players (T5c)
│   │   ├── LiveNotesSheet.swift         # Envoi Notes en live (T5d)
│   │   └── StarterPackSheet.swift       # Offre unique (T5e)
│   ├── Player/
│   │   └── (GiftShopSheet.swift existe — modifier pour T6)
│   └── Shared/
│       └── OnboardingOverlayView.swift  # Tutoriel Master (T10)
├── Models/
│   └── GameTransport.swift       # Protocole abstraction réseau (T12)
└── Extensions/
    └── UserDefaults+BuzzPlay.swift # Clés UserDefaults centralisées
```

### Fichiers existants à modifier

```
PublicState.swift (ou équivalent)
  → Ajouter : playerNotesBalances: [PeerID: Int]
  → Ajouter : activeShields: [PeerID: ShieldType]
  → Ajouter : timerValue: Double (source de vérité Master)

GiftType.swift (ou enum équivalent des pouvoirs)
  → Ajouter : shieldSingle, shieldAll
  → Ajouter : cost: Int computed property
  → Ajouter : isShield: Bool computed property

MasterChooseGameView.swift
  → Modifier section Coins/Notes → modes Équitable/Personnalisé
  → Ajouter bouton "Mode en ligne" stub (T12)
  → Ajouter logique partage App Store (T9)

BuzzerPlayerView.swift
  → Ajouter affichage solde Notes dans header
  → Ajouter badge "Notes reçues" animé (T5d)
  → Ajouter badge "🛡️ Bouclier actif" (T6a)

BlindTestActiveScreen.swift
  → Ajouter bouton "🎵 +" toolbar Master (T5d)
  → Corriger synchronisation timer MPC (T2)

ScoreMasterView.swift
  → Ajouter bouton "Nouvelle partie" (T7)

ScorePlayerView.swift
  → Ajouter rang joueur (T7)
```

---

## Conventions de code à respecter

```swift
// 1. Architecture @Observable (pas ObservableObject)
@Observable
class NotesStore {
    var balance: Int = 0
    // ...
}

// 2. Async/await pour StoreKit 2 (pas de callbacks)
func purchase(_ product: Product) async throws -> Transaction {
    let result = try await product.purchase()
    // ...
}

// 3. Messages MPC — toujours Codable
struct NotesCreditedMessage: Codable {
    let amount: Int
    let fromMaster: Bool
    let timestamp: Date
}

// 4. UserDefaults — utiliser l'extension centralisée
extension UserDefaults {
    var masterNotesBalance: Int {
        get { integer(forKey: "buzzplay.master.notesBalance") }
        set { set(newValue, forKey: "buzzplay.master.notesBalance") }
    }
    // etc.
}

// 5. Gradients — toujours via les constantes du Design System
// Ne pas hardcoder les couleurs hex dans les vues
```

---

## Ce qu'il ne faut PAS faire

- ❌ Ne pas refactoriser le ZStack BlindTest (architecture intentionnelle)
- ❌ Ne pas changer la navigation NavigationStack existante
- ❌ Ne pas ajouter de framework tiers (pas de Alamofire, Kingfisher, etc.)
- ❌ Ne pas implémenter la V2 WebSocket (stubs uniquement)
- ❌ Ne pas modifier le Design System (couleurs, typo, cornerRadius)
- ❌ Ne pas utiliser `ObservableObject` / `@Published` — utiliser `@Observable`
- ❌ Ne pas faire expirer les Notes (règle Apple StoreKit obligatoire)
- ❌ Ne pas afficher le prix de l'unlock V2 (feature cachée en V1)

---

## Ordre d'exécution recommandé pour Claude Code

```
1. Lire ce fichier en entier ✓
2. Explorer la structure du projet (ls -R, chercher les fichiers clés)
3. Comprendre PublicState et le système MPC existant
4. Exécuter T1 (correctifs MPC) — ne rien ajouter avant que la base soit stable
5. Exécuter T2 + T3 (timer et countdown)
6. Exécuter T5a (NotesStore StoreKit) + T5b (interface)
7. Exécuter T5c + T5d (distribution + live)
8. Exécuter T6 (Shop Cadeaux complet avec boucliers)
9. Exécuter T4 (validation Quiz)
10. Exécuter T7 (score)
11. Exécuter T8 + T12 (stubs architecture)
12. Exécuter T9 + T10 + T11 (polish)
```

---

## Questions à poser avant de coder (si non-trouvé dans le projet)

- Quel est le nom exact de la struct/class `PublicState` dans le projet ?
- Comment sont encodés les messages MPC ? (JSON, Codable, autre ?)
- Quel est le nom du fichier contenant l'enum des pouvoirs (`GiftType` ou autre) ?
- Y a-t-il déjà un `UserDefaults` wrapper ou tout est en accès direct ?
- Les IDs App Store Connect sont-ils déjà configurés dans le projet ?

---

*Généré le 2026-05-21 — BuzzPlay v1.0 pre-launch*
*Source : sessions de design produit + brief technique BuzzPlay_DesignBrief.md*
