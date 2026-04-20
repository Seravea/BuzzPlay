# Session — Quiz Master Redesign
**Date :** 20 avril 2026

---

## Ce qu'on a fait

### 1. Skill UI/UX créé
Création d'un skill Claude Code dédié à BuzzPlay :
- **Expert iOS senior SwiftUI** — design review, refacto, architecture MVVM
- Connait le design system complet (Nohemi, couleurs, composants)
- Diagnostic en 5 axes : UI, UX, SwiftUI, Architecture, Pro Max
- Chemin : `~/Library/Application Support/Claude/.../skills/buzzplay-design-review/SKILL.md`

---

### 2. Serveur de preview HTML configuré
- Node.js server dans `mockups/server.js` (port 3456)
- Config : `.claude/launch.json` → `preview_start("mockups")`
- Permet d'itérer visuellement sur les maquettes avant de coder en Swift

---

### 3. Redesign Quiz Master — Maquette HTML

**Flow retenu : 3 écrans distincts (iPhone-first)**

| État | Description |
|------|-------------|
| ① Liste | Toutes les questions avec statuts |
| ② En jeu | Timer + question + réponses + classement |
| ③ Buzz ! | Bottom sheet avec team + validation |

**Décisions de design prises :**

- Réponses **toujours visibles** (seul le Master voit l'écran)
- **Classement en direct** dans l'espace vide de l'écran ② à la place de "en attente de buzz"
- Boutons +10/+20/+30 **différenciés par taille** (scale 0.88 / 0.94 / 1.0)
- Confirmation après validation : overlay centré `+XX pts` qui **surpasse les 3 états** pendant la transition de retour (pas un flash, pas un écran séparé)
- Difficulté des questions : **couleur sur le numéro** (vert/orange/rouge), pas de dots (confusion avec bouton action)
- Questions validées : numéro **neutre gris** (cohérence — vert = facile, pas "fait")
- **Point clignotant du timer supprimé** — une seule animation sur l'écran
- **Radar sonar** en remplacement des barres son pour "en attente de buzz"
- Police **Nohemi** chargée via `@font-face` dans le HTML
- Timer : `letter-spacing: 3px` pour aérer les chiffres
- Durée overlay validation : **650ms** (assez pour lire, pas trop long)

---

### 4. Implémentation SwiftUI

#### Fichiers modifiés/créés

**`BuzzPlay/Features/MasterFeatures/MasterQuiz/View/QuizMasterListView.swift`** *(remplacé)*
- Container principal avec transition slide entre liste ↔ question
- Pilotée par `quizMasterVM.isPlaying`
- `handleValidate()` : overlay → retour liste → fade out
- `QuizQuestionListScreen` : header avec progress bar, liste de questions
- `QuizQuestionRow` : badge numéro coloré par difficulté, statuts done/active/disabled
- `QuizValidationOverlay` : overlay centré avec animation spring

**`BuzzPlay/Features/MasterFeatures/MasterQuiz/View/QuizMasterQuestionView.swift`** *(nouveau)*
- `QuizActiveQuestionScreen` : timer hero, question card, answers grid, scores, radar
- `QuizBuzzSheet` : bottom sheet native avec team card + validation différenciée
- `RadarPulseView` : animation sonar (3 anneaux + dot central)
- Extension `GameColor` : `.color` et `.gradient` pour les couleurs équipes
- `QuizScoreRow` : barre de progression par équipe

**`BuzzPlay/Features/MasterFeatures/MasterQuiz/ThemeSelection/View/QuizThemeSelectionView.swift`** *(remplacé)*
- Header custom Nohemi (remplace navigationTitle générique)
- `ThemeSection` : badge emoji + compteur quiz
- `QuizSetCard` : stripe colorée à gauche, difficulté calculée depuis les questions

---

### 5. Design System — Règles confirmées

| Règle | Détail |
|-------|--------|
| Police | `.font(.nohemi(...))` uniquement — jamais d'autre |
| Couleurs gradients | Portent du sens : vert = positif, rouge = danger, violet = neutre |
| Difficulté (1/2/3) | Vert / Orange / Rouge sur le badge numéro |
| Questions validées | Badge numéro gris neutre (pas vert) |
| Animations | Une seule animation dominante par écran |
| Timer | `letter-spacing` pour aérer les chiffres tabular |
| Validation | Overlay centré surpasse tous les états |

---

### 6. Fichiers mockup HTML
```
mockups/
├── index.html          — mockup interactif iPhone (3 états)
├── server.js           — serveur Node.js port 3456
└── fonts/              — Nohemi (Regular, Medium, SemiBold, Bold, ExtraBold, Black)
```
