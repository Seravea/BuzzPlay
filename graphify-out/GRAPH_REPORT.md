# Graph Report - .  (2026-06-08)

## Corpus Check
- 134 files · ~63,046 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1218 nodes · 1768 edges · 100 communities (86 shown, 14 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 44 edges (avg confidence: 0.81)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_MPC Transport Layer|MPC Transport Layer]]
- [[_COMMUNITY_Quiz Master Flow|Quiz Master Flow]]
- [[_COMMUNITY_Player Buzzer UI|Player Buzzer UI]]
- [[_COMMUNITY_BlindTest Engine|BlindTest Engine]]
- [[_COMMUNITY_Notes Economy|Notes Economy]]
- [[_COMMUNITY_Navigation & Routing|Navigation & Routing]]
- [[_COMMUNITY_Design System|Design System]]
- [[_COMMUNITY_Score & Leaderboard|Score & Leaderboard]]
- [[_COMMUNITY_Game Config & Lobby|Game Config & Lobby]]
- [[_COMMUNITY_AI Quiz Generator|AI Quiz Generator]]
- [[_COMMUNITY_Module 10|Module 10]]
- [[_COMMUNITY_Module 11|Module 11]]
- [[_COMMUNITY_Module 12|Module 12]]
- [[_COMMUNITY_Module 13|Module 13]]
- [[_COMMUNITY_Module 14|Module 14]]
- [[_COMMUNITY_Module 15|Module 15]]
- [[_COMMUNITY_Module 16|Module 16]]
- [[_COMMUNITY_Module 17|Module 17]]
- [[_COMMUNITY_Module 18|Module 18]]
- [[_COMMUNITY_Module 19|Module 19]]
- [[_COMMUNITY_Module 20|Module 20]]
- [[_COMMUNITY_Module 21|Module 21]]
- [[_COMMUNITY_Module 22|Module 22]]
- [[_COMMUNITY_Module 23|Module 23]]
- [[_COMMUNITY_Module 24|Module 24]]
- [[_COMMUNITY_Module 25|Module 25]]
- [[_COMMUNITY_Module 26|Module 26]]
- [[_COMMUNITY_Module 27|Module 27]]
- [[_COMMUNITY_Module 28|Module 28]]
- [[_COMMUNITY_Module 29|Module 29]]
- [[_COMMUNITY_Module 30|Module 30]]
- [[_COMMUNITY_Module 31|Module 31]]
- [[_COMMUNITY_Module 32|Module 32]]
- [[_COMMUNITY_Module 33|Module 33]]
- [[_COMMUNITY_Module 34|Module 34]]
- [[_COMMUNITY_Module 35|Module 35]]
- [[_COMMUNITY_Module 36|Module 36]]
- [[_COMMUNITY_Module 37|Module 37]]
- [[_COMMUNITY_Module 38|Module 38]]
- [[_COMMUNITY_Module 39|Module 39]]
- [[_COMMUNITY_Module 40|Module 40]]
- [[_COMMUNITY_Module 41|Module 41]]
- [[_COMMUNITY_Module 42|Module 42]]
- [[_COMMUNITY_Module 43|Module 43]]
- [[_COMMUNITY_Module 44|Module 44]]
- [[_COMMUNITY_Module 45|Module 45]]
- [[_COMMUNITY_Module 46|Module 46]]
- [[_COMMUNITY_Module 47|Module 47]]
- [[_COMMUNITY_Module 48|Module 48]]
- [[_COMMUNITY_Module 49|Module 49]]
- [[_COMMUNITY_Module 50|Module 50]]
- [[_COMMUNITY_Module 51|Module 51]]
- [[_COMMUNITY_Module 52|Module 52]]
- [[_COMMUNITY_Module 53|Module 53]]
- [[_COMMUNITY_Module 54|Module 54]]
- [[_COMMUNITY_Module 55|Module 55]]
- [[_COMMUNITY_Module 56|Module 56]]
- [[_COMMUNITY_Module 57|Module 57]]
- [[_COMMUNITY_Module 58|Module 58]]
- [[_COMMUNITY_Module 59|Module 59]]
- [[_COMMUNITY_Module 60|Module 60]]
- [[_COMMUNITY_Module 61|Module 61]]
- [[_COMMUNITY_Module 62|Module 62]]
- [[_COMMUNITY_Module 63|Module 63]]
- [[_COMMUNITY_Module 64|Module 64]]
- [[_COMMUNITY_Module 65|Module 65]]
- [[_COMMUNITY_Module 66|Module 66]]
- [[_COMMUNITY_Module 67|Module 67]]
- [[_COMMUNITY_Module 68|Module 68]]
- [[_COMMUNITY_Module 69|Module 69]]
- [[_COMMUNITY_Module 70|Module 70]]
- [[_COMMUNITY_Module 71|Module 71]]
- [[_COMMUNITY_Module 72|Module 72]]
- [[_COMMUNITY_Module 73|Module 73]]
- [[_COMMUNITY_Module 74|Module 74]]
- [[_COMMUNITY_Module 75|Module 75]]
- [[_COMMUNITY_Module 76|Module 76]]
- [[_COMMUNITY_Module 77|Module 77]]
- [[_COMMUNITY_Module 78|Module 78]]
- [[_COMMUNITY_Module 79|Module 79]]
- [[_COMMUNITY_Module 80|Module 80]]
- [[_COMMUNITY_Module 81|Module 81]]
- [[_COMMUNITY_Module 82|Module 82]]
- [[_COMMUNITY_Module 83|Module 83]]
- [[_COMMUNITY_Module 84|Module 84]]
- [[_COMMUNITY_Module 85|Module 85]]
- [[_COMMUNITY_Module 86|Module 86]]
- [[_COMMUNITY_Module 87|Module 87]]
- [[_COMMUNITY_Module 88|Module 88]]
- [[_COMMUNITY_Module 89|Module 89]]
- [[_COMMUNITY_Module 90|Module 90]]
- [[_COMMUNITY_Module 91|Module 91]]
- [[_COMMUNITY_Module 92|Module 92]]
- [[_COMMUNITY_Module 93|Module 93]]
- [[_COMMUNITY_Module 94|Module 94]]
- [[_COMMUNITY_Module 95|Module 95]]

## God Nodes (most connected - your core abstractions)
1. `BlindTestMasterViewModel` - 45 edges
2. `MasterFlowViewModel` - 43 edges
3. `QuizMasterViewModel` - 29 edges
4. `PlayerGameViewModel` - 29 edges
5. `MPCService` - 26 edges
6. `QuizQuestionType` - 24 edges
7. `BuzzerViewModel` - 23 edges
8. `MPCMessage` - 19 edges
9. `Text` - 19 edges
10. `BlindTestSong` - 18 edges

## Surprising Connections (you probably didn't know these)
- `AIQuizGenerator` --references--> `QuizQuestionType`  [EXTRACTED]
  BuzzPlay/AI/AIQuizGenerator.swift → BuzzPlay/Core/Models/QuizQuestion.swift
- `QuizSource` --case_of--> `AIGeneratedQuiz`  [EXTRACTED]
  BuzzPlay/Core/Models/QuizQuestion.swift → BuzzPlay/AI/AIQuizModels.swift
- `QuizQuestionType` --references--> `Bool`  [EXTRACTED]
  BuzzPlay/Core/Models/QuizQuestion.swift → BuzzPlay/Features/MasterFeatures/MasterQuiz/View/QuizMasterListView.swift
- `QuizQuestionType` --references--> `Color`  [EXTRACTED]
  BuzzPlay/Core/Models/QuizQuestion.swift → BuzzPlay/Features/MasterFeatures/MasterQuiz/View/QuizMasterListView.swift
- `QuizQuestionType` --references--> `Int`  [EXTRACTED]
  BuzzPlay/Core/Models/QuizQuestion.swift → BuzzPlay/Features/MasterFeatures/MasterQuiz/View/QuizMasterListView.swift

## Import Cycles
- None detected.

## Communities (100 total, 14 thin omitted)

### Community 0 - "MPC Transport Layer"
Cohesion: 0.06
Nodes (37): AnyShapeStyle, Bool, Color, GameColor, GameType, Int, LinearGradient, Player (+29 more)

### Community 1 - "Quiz Master Flow"
Cohesion: 0.06
Nodes (26): BuzzPayload, BlindTestMasterViewModel, Bool, BuzzDrivenGame, GameType, Int, MasterChooseGameViewModel, MasterLobbyViewModel (+18 more)

### Community 2 - "Player Buzzer UI"
Cohesion: 0.06
Nodes (35): songNotFound, QuizQuestion, QuizTheme, String, UUID, MusicItemID, Song, String (+27 more)

### Community 3 - "BlindTest Engine"
Cohesion: 0.08
Nodes (21): AVPlayer, Int, MainActor, BlindTestPlaylist, BlindTestSong, Bool, CoinsViewModel, Int (+13 more)

### Community 4 - "Notes Economy"
Cohesion: 0.04
Nodes (47): Ce qu'il ne faut PAS faire, CLAUDE.md — BuzzPlay iOS App, Contexte produit, Conventions de code à respecter, Couleurs, Design System (respecter absolument), Fichiers existants à modifier, Modèle économique (contexte pour les features à coder) (+39 more)

### Community 5 - "Navigation & Routing"
Cohesion: 0.05
Nodes (36): Bool, Int, Player, RoundCountdownPhase, String, Bool, Player, QuizQuestion (+28 more)

### Community 6 - "Design System"
Cohesion: 0.07
Nodes (32): BlindTestMasterViewModel, Bool, Content, CGFloat, Content, LinearGradient, EnvironmentKey, AppFontKey (+24 more)

### Community 7 - "Score & Leaderboard"
Cohesion: 0.09
Nodes (30): AIQuizGenerator, contextOverflow, generationFailed, noFreshQuestion, notAvailable, buildQuizPrompt(), QuizTheme, Bool (+22 more)

### Community 8 - "Game Config & Lobby"
Cohesion: 0.09
Nodes (23): Bool, Error, MCPeerID, MPCMessage, Player, String, URL, Void (+15 more)

### Community 9 - "AI Quiz Generator"
Cohesion: 0.06
Nodes (31): Int, Player, Void, BlindTestMasterViewModel, Router, CGFloat, Color, Player (+23 more)

### Community 10 - "Module 10"
Cohesion: 0.11
Nodes (15): AVAudioPlayer, Bool, Player, RoundCountdownPhase, String, Timer, Void, AnswerResult (+7 more)

### Community 11 - "Module 11"
Cohesion: 0.15
Nodes (15): Bool, BuzzerViewModel, GameType, Int, MPCMessage, MPCService, Never, Player (+7 more)

### Community 12 - "Module 12"
Cohesion: 0.09
Nodes (16): String, Bool, String, CoinsViewModel, CoinsViewModel, BlindTestPlaylist, Bool, String (+8 more)

### Community 13 - "Module 13"
Cohesion: 0.14
Nodes (17): Bool, Int, MasterFlowViewModel, MPCService, Player, PlayerGameViewModel, String, CoinsViewModel (+9 more)

### Community 14 - "Module 14"
Cohesion: 0.10
Nodes (19): AnyObject, BuzzDrivenGame, CoinsViewModel, Decoder, Player, Bool, CodingKey, Encoder (+11 more)

### Community 15 - "Module 15"
Cohesion: 0.10
Nodes (20): 1. Audit UX complet, 2. Fixes Apple Music, 3. Fix latence TextField (AVAudioSession sur main thread), 4. Legal Apple Music, 5. Redesign BlindTest Master UI (style Quiz), Alerte abonnement une seule fois, Commits de la session, Contexte (+12 more)

### Community 16 - "Module 16"
Cohesion: 0.14
Nodes (14): Bool, CoinsViewModel, Double, MasterFlowViewModel, Never, Player, QuizQuestion, QuizSet (+6 more)

### Community 17 - "Module 17"
Cohesion: 0.17
Nodes (16): String, UUID, AVAudioPlayer, Bool, CoinsViewModel, Color, Int, Player (+8 more)

### Community 18 - "Module 18"
Cohesion: 0.16
Nodes (13): GameType, PlayerGameViewModel, BuzzerViewModel, CoinsViewModel, Color, GameType, Int, PlayerGameViewModel (+5 more)

### Community 19 - "Module 19"
Cohesion: 0.19
Nodes (14): DifficultyPillAI, ThemeCardAI, AIQuizGenerator, Bool, Int, Never, QuizDifficulty, QuizSet (+6 more)

### Community 20 - "Module 20"
Cohesion: 0.12
Nodes (17): MPCMessage, buyGiftRequest, buyGiftResult, buzz, buzzLock, buzzUnlock, hintRevealedToPlayer, masterGameComplete (+9 more)

### Community 21 - "Module 21"
Cohesion: 0.21
Nodes (8): BuzzerGameMode, Bool, BuzzerViewModel, CreateTeamViewModel, MPCService, Player, PlayerGameViewModel, PlayerFlowViewModel

### Community 22 - "Module 22"
Cohesion: 0.24
Nodes (11): Bool, Color, QuizSet, QuizTheme, QuizThemeSelectionViewModel, Router, String, Void (+3 more)

### Community 23 - "Module 23"
Cohesion: 0.22
Nodes (10): Color, String, UUID, QuizSet, QuizTheme, QuizSamples, QuizTheme, QuizThemeCategory (+2 more)

### Community 24 - "Module 24"
Cohesion: 0.22
Nodes (8): Bool, CoinsViewModel, GameType, Int, MasterFlowViewModel, NotesStore, Player, MasterChooseGameViewModel

### Community 25 - "Module 25"
Cohesion: 0.24
Nodes (7): Int, MasterFlowViewModel, QuizQuestion, QuizSet, QuizTheme, String, QuizThemeSelectionViewModel

### Community 26 - "Module 26"
Cohesion: 0.23
Nodes (11): Bool, CGFloat, Int, Player, QuizMasterViewModel, String, Void, QuizActiveQuestionScreen (+3 more)

### Community 27 - "Module 27"
Cohesion: 0.24
Nodes (11): String, Bool, Color, QuizQuestion, Void, QuizBundleJSON, Decodable, rebus (+3 more)

### Community 28 - "Module 28"
Cohesion: 0.24
Nodes (6): Bool, GameColor, Player, String, Void, CreateTeamViewModel

### Community 29 - "Module 29"
Cohesion: 0.24
Nodes (10): AIQuizReviewView, QuestionCardAI, AIQuizGenerator, Bool, Int, Never, QuizQuestion, QuizSet (+2 more)

### Community 30 - "Module 30"
Cohesion: 0.20
Nodes (9): String, UUID, UUID, String, UUID, Codable, BuzzLockPayload, BuzzPayload (+1 more)

### Community 31 - "Module 31"
Cohesion: 0.20
Nodes (10): Bool, Color, LinearGradient, Router, String, Void, HomeRoleCard, HomeSecondaryCard (+2 more)

### Community 32 - "Module 32"
Cohesion: 0.18
Nodes (8): Bool, GameMode, MasterLobbyViewModel, Player, Router, String, LobbyMasterView, LobbyTeamRow

### Community 33 - "Module 33"
Cohesion: 0.22
Nodes (9): Color, String, QuizDifficulty, difficile, expert, facile, moyen, bundled (+1 more)

### Community 34 - "Module 34"
Cohesion: 0.20
Nodes (9): Route, CaseIterable, GameType, quiz, score, GameDuration, longue, normale (+1 more)

### Community 35 - "Module 35"
Cohesion: 0.24
Nodes (8): CGFloat, Int, QuizMasterViewModel, Router, String, QuizMasterListView, QuizQuestionListScreen, QuizValidationOverlay

### Community 36 - "Module 36"
Cohesion: 0.22
Nodes (9): Bool, Int, NotesStore, Void, NotesPack, PurchaseState, NotesShopView, PackCard (+1 more)

### Community 37 - "Module 37"
Cohesion: 0.25
Nodes (8): AppIcon source photo — tropical coastal scene with flowers and islands, Animations & Glow Effects ✨, Haptic Feedback 🔊, Nouveau fichier, BlindTestBuzzSheet.swift — extracted from PrivateMasterBlindTestView, Haptic Feedback (buzz=heavy, validate=medium, score=light), Sprint 1 — Gameplay Feel (Haptic + Animations), Rationale: transform BuzzPlay from standard quiz app to arcade party game feel

### Community 38 - "Module 38"
Cohesion: 0.22
Nodes (8): ButtonStyleE, Style, LinearGradient, ButtonStyleE, destructive, neutral, positive, secondary

### Community 39 - "Module 39"
Cohesion: 0.22
Nodes (8): Color, LinearGradient, GameColor, blueGame, greenGame, purpleGame, redGame, yellowGame

### Community 40 - "Module 40"
Cohesion: 0.22
Nodes (7): Bool, Decoder, GameColor, Int, String, Hashable, Player

### Community 41 - "Module 41"
Cohesion: 0.25
Nodes (6): GameMode, Int, MasterFlowViewModel, Player, GameDuration, MasterLobbyViewModel

### Community 42 - "Module 42"
Cohesion: 0.22
Nodes (8): CGFloat, Color, Font, String, Style, Typography, Void, PrimaryButtonView

### Community 43 - "Module 43"
Cohesion: 0.22
Nodes (4): Bool, Route, Router, ObservableObject

### Community 44 - "Module 44"
Cohesion: 0.32
Nodes (6): AmbiantSoundViewModel, AVAudioPlayer, Bool, String, BlindTestMasterViewModel, GridItem

### Community 45 - "Module 45"
Cohesion: 0.29
Nodes (6): Bool, CGFloat, Int, Player, String, Void

### Community 46 - "Module 46"
Cohesion: 0.32
Nodes (7): Color: Blue #2B7FFF on Purple (~3.8:1 contrast — FAIL), Color: Green #00C950 on Purple (~4.2:1 contrast — borderline), Color: Mustard Yellow #FEC260 on Purple (~4.8:1 contrast), Color: White #FFF on Purple #2A0944 (~9.5:1 contrast), Contrast Ratio Requirements (≥4.5:1 for text), WCAG 2.1 AA Compliance, Rationale: Blue #2B7FFF fails WCAG AA — use as accent only, never for main text

### Community 47 - "Module 47"
Cohesion: 0.25
Nodes (7): 1. Skill UI/UX créé, 2. Serveur de preview HTML configuré, 3. Redesign Quiz Master — Maquette HTML, 5. Design System — Règles confirmées, 6. Fichiers mockup HTML, Ce qu'on a fait, Session — Quiz Master Redesign

### Community 48 - "Module 48"
Cohesion: 0.29
Nodes (6): AnswerResult, Bool, Int, String, TimeInterval, TimerStartPayload

### Community 49 - "Module 49"
Cohesion: 0.29
Nodes (6): colors, info, author, version, properties, localizable

### Community 50 - "Module 50"
Cohesion: 0.38
Nodes (3): MainActor, PublicState, Task

### Community 51 - "Module 51"
Cohesion: 0.33
Nodes (6): Bool, BuzzerViewModel, Color, Double, BuzzerButtonView, PulseRingView

### Community 52 - "Module 52"
Cohesion: 0.29
Nodes (6): LinearGradient, Route, String, RoleButtonUI, master, teams

### Community 53 - "Module 53"
Cohesion: 0.29
Nodes (7): Après, Avant, BuzzPlay UI/UX Sprints 1-3 Summary, 📊 Impact Résumé, 🎯 Metrics, 🎯 Objectif, 🚀 Prochaines étapes recommandées

### Community 54 - "Module 54"
Cohesion: 0.33
Nodes (5): Bool, CreateTeamViewModel, LinearGradient, Router, String

### Community 55 - "Module 55"
Cohesion: 0.33
Nodes (5): Player, PlayerFlowViewModel, PlayerGameViewModel, Router, PulsingPill

### Community 56 - "Module 56"
Cohesion: 0.33
Nodes (6): Code Quality, Micro-Interactions 🎨, EmptyStateView — empty state with icon + CTA, LoadingCardView — reusable loading state with pulsing circle, Sprint 3 — Polish (Micro-Interactions + Accessibility), Rationale: secondary text opacity raised from 0.7 to 0.85 for WCAG compliance

### Community 57 - "Module 57"
Cohesion: 0.33
Nodes (6): Visual Enhancements, Écran Public Blind Test, Écran Public Quiz, PublicBlindTestView — spectator screen (44px timer, 56px song title), PublicQuizDisplayView — spectator screen (44px timer, 48px question), Sprint 2 — Spectator Experience (Public Display)

### Community 58 - "Module 58"
Cohesion: 0.33
Nodes (6): ✅ CONFORMES (Ratio ≥ 4.5:1), 📝 Fixes appliquées, Rapport d'audit des contrastes de BuzzPlay, 📱 Test sur device, WCAG 2.1 AA Contrast Audit, ⚠️ À AMÉLIORER

### Community 59 - "Module 59"
Cohesion: 0.40
Nodes (4): colors, info, author, version

### Community 60 - "Module 60"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 61 - "Module 61"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 62 - "Module 62"
Cohesion: 0.40
Nodes (4): images, info, author, version

### Community 63 - "Module 63"
Cohesion: 0.70
Nodes (3): QuizSet, QuizTheme, QuizJSONLoader

### Community 64 - "Module 64"
Cohesion: 0.40
Nodes (4): Double, RoundCountdownPhase, String, CountdownOverlay

### Community 65 - "Module 65"
Cohesion: 0.40
Nodes (4): CGFloat, Font, String, TextFieldCustom

### Community 66 - "Module 66"
Cohesion: 0.70
Nodes (3): String, Void, EmptyStateView

### Community 67 - "Module 67"
Cohesion: 0.40
Nodes (4): Bool, Player, String, TeamCardView

### Community 68 - "Module 68"
Cohesion: 0.40
Nodes (4): CGFloat, Double, Int, DotsIndicator

### Community 69 - "Module 69"
Cohesion: 0.40
Nodes (4): colors, info, author, version

### Community 70 - "Module 70"
Cohesion: 0.40
Nodes (4): colors, info, author, version

### Community 71 - "Module 71"
Cohesion: 0.40
Nodes (4): colors, info, author, version

### Community 72 - "Module 72"
Cohesion: 0.40
Nodes (4): colors, info, author, version

### Community 73 - "Module 73"
Cohesion: 0.67
Nodes (3): AIGeneratedQuiz, AIQuizQuestion, String

### Community 75 - "Module 75"
Cohesion: 0.50
Nodes (3): info, author, version

### Community 77 - "Module 77"
Cohesion: 0.50
Nodes (3): Bool, String, Void

### Community 79 - "Module 79"
Cohesion: 0.50
Nodes (3): BlindTestSong, Bool, SongCard

### Community 80 - "Module 80"
Cohesion: 0.50
Nodes (3): CGFloat, Int, String

### Community 81 - "Module 81"
Cohesion: 0.50
Nodes (3): Font, String, Void

### Community 84 - "Module 84"
Cohesion: 0.50
Nodes (4): Créés, 📁 Fichiers modifiés, Modifiés (Sprint 1), 4. Implémentation SwiftUI

### Community 85 - "Module 85"
Cohesion: 0.50
Nodes (3): info, author, version

### Community 86 - "Module 86"
Cohesion: 0.67
Nodes (3): buttonFloor — light grey ellipse buzzer floor/shadow graphic, ButtonTap — red ellipse buzzer tap surface graphic, Buzzer button — composed of red tap surface + grey floor shadow (3D effect)

## Knowledge Gaps
- **524 isolated node(s):** `TimeInterval`, `Error`, `notAvailable`, `generationFailed`, `noFreshQuestion` (+519 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `QuizQuestionType` connect `Module 27` to `Module 33`, `Module 34`, `Module 35`, `Player Buzzer UI`, `Score & Leaderboard`, `Module 40`, `Module 12`, `Module 30`?**
  _High betweenness centrality (0.166) - this node is a cross-community bridge._
- **Why does `BuzzLockPayload` connect `Module 30` to `Game Config & Lobby`, `Quiz Master Flow`?**
  _High betweenness centrality (0.075) - this node is a cross-community bridge._
- **Why does `BlindTestMasterViewModel` connect `BlindTest Engine` to `AI Quiz Generator`, `Module 14`, `Quiz Master Flow`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **What connects `TimeInterval`, `Error`, `notAvailable` to the rest of the system?**
  _525 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `MPC Transport Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.06140350877192982 - nodes in this community are weakly interconnected._
- **Should `Quiz Master Flow` be split into smaller, more focused modules?**
  _Cohesion score 0.05858585858585859 - nodes in this community are weakly interconnected._
- **Should `Player Buzzer UI` be split into smaller, more focused modules?**
  _Cohesion score 0.05568627450980392 - nodes in this community are weakly interconnected._