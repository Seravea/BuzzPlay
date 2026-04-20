# Session 2026-04-20 — UX Audit + Redesign BlindTest

## Contexte
Projet BuzzPlay — jeu de soirée iOS (MPC), rôles Master/Team, BlindTest + Quiz.  
Point de départ : branche `main` au commit `c1c5ae2` (redesign Quiz Master UI).

---

## 1. Audit UX complet

Analyse de 83 fichiers Swift. Problèmes classés P0 → P3.

### P0 — Bloquants
| Fichier | Problème |
|---|---|
| `HomeView.swift:54` | String debug `"Pas de team Gros Bug sa reum"` visible utilisateurs |
| `BuzzerPlayerView.swift:29` | String debug `"Pas de buzzer BUG DE OUF"` visible utilisateurs |
| `BuzzerButtonView.swift:33` | `onTapGesture` au lieu de `Button` → inaccessible VoiceOver (conservé intentionnellement pour l'animation physique du buzzer) |

### P1 — Expérience cassée (corrigés)
- `PrivateMasterBlindTestView` : `isFetching` jamais affiché → spinner ajouté
- Bouton "Lecture" non désactivé pendant `isFetching` → corrigé
- Erreurs Apple Music silencieuses → alertes utilisateur ajoutées
- Rôles alerte `CreateTeamView` inversés → corrigés (Annuler=cancel, Continuer=default)
- `ConnectionLostOverlay` sans animation → `.easeInOut(0.3)` + `.transition(.opacity)`
- `LobbyMasterView` : `ProgressView` trompeur → empty state (icône + texte)

### P2 — Qualité (corrigés)
- **Zéro haptique** → `.heavy` sur buzz, `.success`/`.warning` sur valider/refuser (BlindTest + Quiz)

### P3 — Cohérence (non traités dans cette session)
- Opacités disabled incohérentes (0.3 / 0.7 / 0.8)
- Titres navigation sans pattern uniforme
- `CoinsViewModel.errorMessage` jamais affiché
- `TimerCardView.isCorrectAnswer` paramètre inutilisé

---

## 2. Fixes Apple Music

### Pastille abonnement
- Badge `"Gratuit · ~15 sec"` dans la toolbar (icône note orange, capsule ultraThinMaterial)
- Tappable → sheet native `MusicSubscriptionOffer` d'Apple
- Si abonnement → pastille disparaît automatiquement

### Alerte abonnement une seule fois
- `hasShownSubscriptionInfo` stocké dans `UserDefaults` (`buzzplay.subscriptionInfoShown`)
- Affiché une seule fois sur l'appareil, jamais répété

### Timer en fin de preview
- Observer `AVPlayerItemDidPlayToEndTime` ajouté dans `playRandomPreview()`
- Quand la preview (15–30s) se termine → `handlePreviewEnd()` stoppe le timer

### Mise à jour abonnement en temps réel
- `MusicSubscription.subscriptionUpdates` — décidé de ne pas l'utiliser au `onAppear` (causait un hang XPC de 8s)
- Rafraîchissement via `.onChange(of: showSubscriptionOffer)` quand la sheet se ferme

---

## 3. Fix latence TextField (AVAudioSession sur main thread)

**Cause** : `setupAudioSession()` + `updateCatalogPlaybackCapability()` déclenchaient chacun une connexion XPC vers `itunescloudd` — 20 retries simultanés → hang 8s.

**Fixes** :
- `observeSubscriptionUpdates()` retiré du `onAppear` (double connexion XPC)
- `configureAudioSession()` déplacé dans `startRound()` (1 seul appel par manche, hors MainActor)
- `setupAudioSession()` en `onAppear` supprimé (redondant avec `configureAudioSession()` dans `playRandomPreview`)
- `AmbiantSoundViewModel` : `ObservableObject` retiré (incompatible avec `@Observable`, causait double re-render)

---

## 4. Legal Apple Music

**Question** : utilisation des previews 30s dans une app commerciale — légal ?

**Réponse** : Oui, viable pour l'App Store.
- Les previews sont fournies intentionnellement par Apple via MusicKit
- Apple gère les royalties, pas le développeur
- Apps similaires : SongPop, Musixmatch
- À respecter : pas de téléchargement, pas de boucle forcée, attribution titre/artiste, entitlement `com.apple.developer.musickit`
- Ajouter dans la description App Store : *"Le Blind Test utilise les extraits musicaux fournis par Apple Music (~15–30 sec)."*

---

## 5. Redesign BlindTest Master UI (style Quiz)

### Flow 3 états avec transition glissante (spring 0.45s)

**Screen 1 — Recherche**
- Header "Blind Test" + sous-titre
- Search bar stylée + bouton "Chercher" gradient orange
- Playlists en liste verticale (cards avec icône, nom, curateur, nb titres)
- Empty state avant toute recherche + spinner pendant `isFetching`

**Screen 2 — Liste des titres** ← *retour ici après chaque validation*
- Titres numérotés avec artiste + année
- Chansons jouées grisées (✓ vert) via `playedSongs: [BlindTestSong]`
- Chanson sélectionnée mise en avant (bordure mustard)
- Barre de progression `X/total ✓`
- Bouton "Lancer la manche" conditionnel (visible seulement si titre sélectionné)
- Indicateur de chargement dans le bouton pendant `isFetching`

**Screen 3 — Manche active**
- Timer hero `darkestPurple` + badge EN COURS / PAUSÉ / TERMINÉ
- Carte chanson : artwork `AsyncImage`, animation `waveform` SF Symbol pendant lecture
- Classement en direct avec barres de progression par équipe (`QuizScoreRow`)
- `RadarPulseView` en attente de buzz
- **Bottom sheet buzz** : carte équipe + temps de réaction + `+10` / `+20` / `+30` / Refuser

**Toolbar**
- En jeu : bouton `‹` pour annuler la manche (`cancelRound()`) → retour Screen 2
- Hors jeu : pastille Apple Music "Gratuit · ~15 sec" si pas abonné

### Nouvelles méthodes VM
```swift
var playedSongs: [BlindTestSong] = []        // titres déjà joués
func cancelRound()                            // annuler sans valider → Screen 2
func handlePreviewEnd()                       // appelé par observer AVPlayer fin preview
func observeSubscriptionUpdates()             // non utilisé au onAppear (XPC flood)
```

---

## Commits de la session

| Hash | Description |
|---|---|
| `b8ffe05` | feat: améliorations UX — spinners, haptiques, animations, empty states |
| `2d7cbee` | fix: alerte abonnement une seule fois + timer s'arrête en fin de preview |
| `5932f53` | feat: pastille Apple Music tappable → sheet abonnement natif |
| `7d76c71` | feat: pastille Apple Music tappable → sheet abonnement natif (chevron) |
| `16a0eb7` | feat: mise à jour abonnement Apple Music en temps réel |
| `80d1cd1` | fix: suppression du double appel XPC Apple Music au onAppear |
| `8371280` | fix: latence TextField — AVAudioSession hors du main thread |
| `f049699` | refactor: supprimer setupAudioSession() redondant du onAppear |
| `cd432e3` | refactor: configureAudioSession() appelé une seule fois par manche |
| `7016a82` | feat: redesign BlindTest Master UI — flow 3 états style Quiz |

---

## Fichiers modifiés

```
BuzzPlay/Features/MasterFeatures/BlindTest/View/BlindTestMasterView.swift
BuzzPlay/Features/MasterFeatures/BlindTest/View/PrivateMasterBlindTestView.swift   ← réécriture complète
BuzzPlay/Features/MasterFeatures/BlindTest/ViewModel/BlindTestMasterViewModel.swift
BuzzPlay/Features/MasterFeatures/MasterLobby/Views/LobbyMasterView.swift
BuzzPlay/Features/MasterFeatures/MasterQuiz/ViewModel/QuizMasterViewModel.swift
BuzzPlay/Features/MasterFeatures/MasterQuiz/View/QuizMasterQuestionView.swift
BuzzPlay/Features/TeamFeatures/Buzzer/Button/Views/BuzzerButtonView.swift
BuzzPlay/Features/TeamFeatures/Buzzer/Button/Views/BuzzerPlayerView.swift
BuzzPlay/Features/TeamFeatures/CreateTeamView/Views/CreateTeamView.swift
BuzzPlay/Core/SharedViewModel/AmbiantSoundViewModel.swift
BuzzPlay/Core/Services/AppleMusic/AppleMusicService.swift
```

---

## Points en attente (prochaine session)

- [ ] P0 strings de debug (`HomeView`, `BuzzerPlayerView`) — à remplacer par des vues d'erreur propres
- [ ] P3 cohérence opacités disabled → token unique
- [ ] P3 titres navigation → pattern uniforme
- [ ] `CoinsViewModel.errorMessage` → affichage dans l'UI
- [ ] `TimerCardView.isCorrectAnswer` → utiliser ou supprimer le paramètre
- [ ] Apple Intelligence feature (mentionnée dans le contexte projet)
