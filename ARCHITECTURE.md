# ARCHITECTURE.md

Référence d'architecture pour **BuzzPlay** (iOS, SwiftUI, MVVM, multijoueur local MultipeerConnectivity).

Ce document est **la source de vérité** de l'architecture. Il sert à deux choses :
1. Cadrer le refactor des Views (référence contre laquelle on refactore).
2. Servir de garde-fou pour l'assistance IA (agent de code) — les règles sont **nommées et vérifiables** pour qu'un agent puisse les suivre au lieu de les réinterpréter.

> **Principe directeur.** Une convention *implicite* n'est pas suivie par un agent ; une convention *nommée et vérifiable d'un coup d'œil* l'est. Toute règle ci-dessous doit pouvoir se vérifier par oui/non, sans jugement esthétique.

---

## 1. Pattern d'architecture : MVVM

Séparation stricte des responsabilités.

- **Model** — données et logique métier pure. Aucune dépendance à SwiftUI. Structs/enums de préférence (valeur), classes seulement si identité/référence nécessaire.
- **ViewModel** — état présenté à la vue + logique de présentation. `final class` conforme à `ObservableObject`. Expose des propriétés `@Published`. Ne contient **aucun** type SwiftUI de rendu (`View`, `Color`, etc. côté layout).
- **View** — rendu uniquement. Déclarative. **Aucune logique métier.** Lit l'état du ViewModel, remonte les intentions utilisateur au ViewModel via des méthodes.

**Règle MVVM-1.** Une View ne contient pas de logique métier ni de calcul non trivial. Si un calcul dépasse une transformation d'affichage simple → il va dans le ViewModel.

**Règle MVVM-2.** Un ViewModel n'importe pas SwiftUI pour du layout et ne référence jamais une View concrète.

---

## 2. Organisation des fichiers et dossiers

Organisation **par feature** (convention standard en entreprise), pas par type technique.

```
BuzzPlay/
├── AI/
├── Core/                        // logique transverse, services de base
├── Data/                        // données (JSON quiz, persistance)
├── Features/
│   ├── HomeView/
│   ├── DisplayPublic/
│   ├── GameProtocols/
│   ├── MasterFeatures/
│   ├── Shared/
│   │   └── Views/               // sous-vues RÉUTILISÉES par ≥ 2 features (ex. CountdownOverlay)
│   └── TeamFeatures/
│       ├── Buzzer/
│       │   └── Button/
│       │       ├── ViewModel/
│       │       └── Views/
│       │           ├── Subviews/            // ← sous-vues mono-parent (À CRÉER ici)
│       │           ├── BuzzerButtonView.swift
│       │           ├── BuzzerPlayerView.swift
│       │           └── PostRoundLeaderboardView.swift
│       ├── CreateTeamView/
│       │   ├── ViewModel/
│       │   └── Views/
│       │       ├── Subviews/                // ex. TextFieldCustom (pattern déjà en place ✓)
│       │       └── CreateTeamView.swift
│       ├── PlayerChooseGameView/
│       ├── PlayerGameView/
│       ├── ScorePlayer/
│       └── TeamViewModel/
└── Ressources/
    ├── Fonts/
    └── Sounds/
```

**Conventions de dossiers de ce projet (à respecter et généraliser) :**
- Chaque feature regroupe un dossier **`ViewModel/`** (singulier) et un dossier **`Views/`**.
- Dans `Views/` : la/les View(s) principale(s) au premier niveau **+ un dossier `Subviews/`** pour les sous-vues **mono-parent** de cette feature.
- Le **vraiment partagé** (réutilisé par ≥ 2 features) va dans **`Features/Shared/Views/`**.

**Règle DOSSIER-1.** Un type = un fichier. Le nom du fichier = le nom du type (`BuzzerButtonView.swift` contient `BuzzerButtonView`).

**Règle DOSSIER-2 — Généraliser le dossier `Subviews/`.** Chaque `Views/` de feature doit avoir un dossier **`Subviews/`** pour ses sous-vues mono-parent extraites. Le pattern existe déjà dans `CreateTeamView/Views/Subviews/` → l'appliquer partout où il manque (ex. `Buzzer/Button/Views/` n'en a pas encore et doit en avoir un).

**Règle DOSSIER-3.** Un service externe (MultipeerConnectivity, MusicKit, Analytics, StoreKit) vit dans `Core/` (ou un `Services/` si tu en crées un), jamais dans une View ni un ViewModel.

> **Note de cohérence (optionnel).** Certains dossiers de feature portent le suffixe `View` (`HomeView`, `CreateTeamView`, `PlayerGameView`) alors que ce sont des features, pas des vues. Ce n'est pas bloquant, mais si tu veux uniformiser un jour, un dossier de feature = un nom de feature (`Home`, `CreateTeam`), et le fichier View garde le suffixe (`HomeView.swift`). À ne PAS traiter pendant le refactor de Views — chantier séparé pour éviter de tout casser d'un coup.

---

## 3. Conventions de nommage (Swift API Design Guidelines)

- **Types** (struct/class/enum/protocol) : `PascalCase`.
- **Propriétés, méthodes, variables** : `camelCase`.
- **Views** : suffixe `View` → `BlindTestView`, `ScoreCardView`.
- **ViewModels** : suffixe `ViewModel` → `BlindTestViewModel`.
- **Sous-vues locales** : nom descriptif + `View`, préfixé par le contexte si utile → `BlindTestRoundView`, `PlayerRowView`.
- **Protocols** : nom capacité (`-able`, `-ing`) ou rôle → `Playable`, `AudioProviding`.
- **Booléens** : forme assertive → `isPlaying`, `hasSubscription`, `canSkip`.
- Nommage en **anglais** pour tout le code (identifiants, types, fichiers). Commentaires libres.

---

## 4. Découpage des Views (cœur du refactor)

C'est ici que se joue la propreté. Trois règles, toutes binaires.

**Règle VIEW-1 — Une View par fichier.** Pas de deux `struct ... : View` de premier niveau dans le même fichier. (Exception tolérée : une sous-vue `private` très courte, < ~15 lignes, dans le fichier de son parent — au-delà, on extrait.)

**Règle VIEW-2 — Seuil d'extraction.** Toute sous-vue inline (ex. un bloc dans un `VStack`) dépassant **~40-50 lignes** doit être extraite dans son propre type. Une page dont le `body` dépasse ~2 écrans de lecture est un signal d'extraction.

**Règle VIEW-3 — Une page ne fait que composer.** Un écran de haut niveau (`BlindTestView`, `QuizView`) assemble des sous-vues **déjà extraites**. Son `body` doit se lire comme un sommaire, pas contenir de gros blocs de layout inline.

### 4.1 — Deux raisons d'extraire, deux destinations (point clé)

Distinction que l'agent ne fait PAS spontanément — à expliciter :

| Raison d'extraire | Critère | Destination |
|---|---|---|
| **Réutilisation** | utilisé par **≥ 2** features | `Features/Shared/Views/` |
| **Lisibilité** | utilisé par **1 seule** feature mais **> seuil VIEW-2** | **même dossier que son écran parent** (voir VIEW-5) |
| (rien) | utilisé 1 fois **et** court | peut rester inline |

**Règle VIEW-4 — Arbre de décision d'extraction.**
1. Utilisé par plus d'une feature ? → **oui** : `Features/Shared/Views/`. **non** : étape 2.
2. Dépasse le seuil VIEW-2 ? → **oui** : extraite et rangée **avec son écran parent** (VIEW-5). **non** : peut rester inline.

**Règle VIEW-5 — Un dossier par écran (parent + ses sous-vues ensemble).** Quand une feature contient plusieurs écrans, chaque écran a **son propre dossier** contenant l'écran ET ses sous-vues mono-parent, pour qu'on retrouve toujours la vue parente à côté de ses enfants. On ne crée **PAS** de dossier `Subviews/` global à plat qui noierait les écrans parents (retour Romain 2026-07-06). Les vues de navigation/conteneur (ZStack racine, `…MasterView`, `Private…`/`Public…`) restent à la racine du `View/` de la feature. Modèle appliqué à `BlindTest/View/` : `Search/`, `SongList/`, `SolarSystem/`, `Active/`, `BuzzSheet/`, `AmbiantSounds/` (chacun = écran + ses sous-vues) ; `BlindTestMasterView`/`Private…`/`Public…` à la racine. Une feature mono-écran peut garder l'écran + ses sous-vues directement dans `View/` sans sous-dossier.

> Erreur connue à corriger dans ce projet : les composants **réutilisés** ont bien été extraits vers `Features/Shared/Views/` (ex. `CountdownOverlay`), mais les sous-vues **mono-parent volumineuses** sont restées inline dans leur page. La règle VIEW-4+VIEW-5 consiste à les extraire **et à les ranger dans le dossier de leur écran parent**.

---

## 4bis. Fonctions & logique dans les Views

Le découpage en sous-vues traite le **layout**. Cette section traite les **fonctions** — axe distinct, tout aussi important. La question n'est pas « fonction = mal », mais « **où va la fonction selon ce qu'elle fait** ».

**Règle FONC-1 — Aucune logique métier/décision dans une View.** Toute fonction qui calcule, décide, transforme des données, appelle un service (MPC, MusicKit, StoreKit, données), ou gère l'état de jeu vit dans le **ViewModel**. La View se contente de l'appeler (`viewModel.validerReponse()`).
Signal de détection : une fonction dans une View qui contient un `if`/`switch` sur des règles métier, une boucle de calcul, un accès à un service, ou qui mute autre chose que de l'état d'affichage local → **mal placée**, quelle que soit sa taille.

**Règle FONC-2 — Un handler d'action ne contient qu'un appel.** Le corps d'un `onTap` / `onSubmit` / `Button(action:)` ne contient **pas** de logique inline — seulement un appel au ViewModel. Un `Button(action:)` avec plusieurs lignes de logique = logique métier déguisée → déplacer au ViewModel.

**Règle FONC-3 — Helper de rendu : la bonne forme SwiftUI.** Pour un fragment purement visuel :
- fragment court **sans paramètre** → **computed property** `private var header: some View { ... }` (idiome préféré).
- fragment court **avec paramètre** → **fonction** `@ViewBuilder private func row(for item: Item) -> some View { ... }`.
- fragment **> seuil VIEW-2**, réutilisable, ou **portant son propre état** → **sous-vue extraite** (`struct`), rangée selon VIEW-4.

**Règle FONC-4 — Scinder les fonctions hybrides.** Une fonction de rendu qui a accumulé de la logique (moitié layout, moitié métier) doit être **scindée** au refactor : la partie logique part au ViewModel, la partie rendu devient computed property / `@ViewBuilder` / sous-vue selon FONC-3. C'est le cas le plus pernicieux car il échappe aux deux radars (ni sous-vue claire, ni méthode de ViewModel).

---

## 5. Propriété de l'état SwiftUI (critique pour un refactor sûr)

L'extraction de sous-vues casse souvent la propagation d'état **sans erreur de compilation** (l'app compile mais une vue ne se met plus à jour, un état se réinitialise). Ces règles sont non négociables lors du refactor.

- **`@State private var`** — état local, éphémère, **possédé** par cette vue (ex. toggle UI, champ de saisie). Toujours `private`.
- **`@Binding var`** — état **possédé par le parent**, muté par l'enfant. Utilisé quand une sous-vue extraite doit modifier une valeur du parent.
- **`@StateObject`** — la vue qui **crée et possède** un `ObservableObject` (typiquement le ViewModel racine d'un écran). Créé **une seule fois** ici.
- **`@ObservedObject`** — un `ObservableObject` **reçu** du parent (déjà créé ailleurs). Ne jamais l'utiliser pour créer l'objet.
- **`@EnvironmentObject`** — dépendance **injectée** dans l'arbre (ex. session partagée). Vérifier qu'elle reste injectée après extraction.

**Règle ÉTAT-1 — Préserver le flux lors de l'extraction.** Extraire une sous-vue ne doit PAS changer le comportement. Si un `@State` du parent est muté par le bloc extrait → il devient `@Binding` dans l'enfant. Si le bloc lit le ViewModel → passer le ViewModel en `@ObservedObject` (jamais le recréer en `@StateObject` dans l'enfant).

**Règle ÉTAT-2 — Un `ObservableObject` a un seul propriétaire.** `@StateObject` au point de création (l'écran), `@ObservedObject` / `@EnvironmentObject` partout ailleurs. Deux `@StateObject` du même objet = bug d'état dupliqué.

**Règle ÉTAT-3 — Validation fonctionnelle obligatoire.** « Ça compile » ne suffit PAS pour un refactor d'état. Chaque page refactorée est testée **en interaction réelle** (lancer, cliquer, vérifier que l'état se propage et se met à jour comme avant).

---

## 6. Procédure de refactor assisté (à suivre par l'agent)

Refactor = le comportement ne change pas, seule la structure change. Procédure stricte :

1. **Ne jamais refactorer plusieurs pages en un seul lot.** Une page à la fois.
2. **Ordre** : de la page la plus dégradée (plus de sous-vues inline > seuil) à la plus propre.
3. Pour chaque page : appliquer VIEW-1 à VIEW-4 et ÉTAT-1 à ÉTAT-2, **sans modifier le comportement**.
4. **Ne toucher qu'à la page en cours.** Aucune modification collatérale d'autres fichiers non listés.
5. S'arrêter après chaque page et **présenter le diff** pour validation humaine.
6. Après validation humaine + test fonctionnel (ÉTAT-3) → **commit** avant la page suivante.

**Règle REFACTOR-1 — Un commit par page.** Chaque page validée est committée avant de passer à la suivante (point de restauration). Jamais de refactor multi-pages non committé.

**Règle REFACTOR-2 — Inventaire avant modification.** Avant tout refactor, produire (sans rien modifier) la liste ordonnée des pages à traiter, avec pour chacune le nombre de sous-vues inline dépassant le seuil. Cette liste pilote la boucle.

**Règle REFACTOR-3 — Suivi.** Tenir une checklist markdown (pages faites / à faire), cochée au fur et à mesure, pour reprendre proprement entre sessions.

---

## 7. Checklist de validation par page (avant commit)

- [ ] Une seule View de premier niveau par fichier (VIEW-1)
- [ ] Aucune sous-vue inline > seuil restante (VIEW-2)
- [ ] Le `body` de la page ne fait que composer des sous-vues extraites (VIEW-3)
- [ ] Extraction rangée selon l'arbre de décision : partagé → `Features/Shared/Views/`, mono-parent → `Subviews/` de la feature (VIEW-4)
- [ ] Aucune logique métier/service dans la View — tout est au ViewModel (FONC-1)
- [ ] Handlers d'action = simple appel au ViewModel, pas de logique inline (FONC-2)
- [ ] Helpers de rendu en bonne forme (computed property / `@ViewBuilder` / sous-vue) (FONC-3)
- [ ] Fonctions hybrides scindées (logique → ViewModel, rendu → vue) (FONC-4)
- [ ] Propriété d'état correcte : `@Binding` pour mutation parent, `@ObservedObject` pour ViewModel reçu (ÉTAT-1, ÉTAT-2)
- [ ] **Testé en interaction réelle** — comportement identique à avant (ÉTAT-3)
- [ ] Nommage conforme (§3)
- [ ] Compile sans warning nouveau
- [ ] Commit effectué (REFACTOR-1)

---

## 8. Anti-patterns interdits

- ❌ Logique métier dans une View (calcul, décision, accès service) — au ViewModel (FONC-1).
- ❌ Handler d'action (`Button`, `onTap`) contenant de la logique inline au lieu d'un appel au ViewModel (FONC-2).
- ❌ Fonction de rendu hybride (moitié layout, moitié métier) laissée telle quelle au lieu d'être scindée (FONC-4).
- ❌ Bloc de layout inline > seuil dans une page (au lieu d'une sous-vue extraite).
- ❌ Recréer un ViewModel en `@StateObject` dans une sous-vue enfant (doit être `@ObservedObject`).
- ❌ Deux `struct: View` de premier niveau dans un même fichier.
- ❌ Extraire vers `Features/Shared/Views/` quelque chose utilisé par une seule feature (ça doit aller dans le `Subviews/` de la feature), ou laisser inline une grosse sous-vue mono-parent (dégrade la page).
- ❌ Refactor multi-pages en un lot / sans commit intermédiaire.
- ❌ Valider un refactor sur le seul critère « ça compile ».
- ❌ Appel à un service externe (MPC, MusicKit, StoreKit, Analytics) directement depuis une View.
