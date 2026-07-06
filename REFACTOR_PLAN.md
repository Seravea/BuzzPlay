# REFACTOR_PLAN.md

Plan de refactor des Views de **BuzzPlay**. Compagnon de `ARCHITECTURE.md`.

> **Important.** Le classement chiffré réel (nombre de sous-vues inline > seuil, lignes par vue) doit être produit par l'agent en **lisant le code** (règle REFACTOR-2 de `ARCHITECTURE.md`). Ce document fournit : (1) le **cadre du tableau** à remplir, (2) un **pré-diagnostic par zone** (hypothèse à confirmer), (3) les **points critiques à tester**.

---

## 1. Tableau de priorisation (à remplir par l'agent — NE PAS modifier de code à cette étape)

Pour chaque View, l'agent renseigne :

| View / fichier | Feature | Sous-vues inline > seuil | ~Lignes `body` | Complexité d'état* | Dépendances sensibles** | Priorité |
|---|---|---|---|---|---|---|
| _(à remplir)_ | | | | | | |

\* **Complexité d'état** : nombre de `@State` / `@Binding` / `@ObservedObject` / `@StateObject` / `@EnvironmentObject` en jeu. Plus c'est élevé, plus l'extraction est risquée (voir §3).

\*\* **Dépendances sensibles** : la vue touche-t-elle à MultipeerConnectivity, MusicKit, un Timer, ou un composant partagé (`CountdownOverlay`) ? Si oui → test renforcé.

### Calcul de priorité (score simple)
`Priorité = (sous-vues inline > seuil) + (1 si body > 2 écrans) + (1 si dépendance sensible)`
Trier **décroissant** : on commence par le score le plus haut.

> Règle de bon sens : à score égal, commencer par la vue **sans dépendance sensible** (rodage à faible risque avant d'attaquer les vues temps réel / audio).

---

## 2. Pré-diagnostic par zone (HYPOTHÈSE — à confirmer par l'inventaire réel)

Basé uniquement sur l'arborescence connue, pas sur le contenu. À valider/corriger avec les vrais chiffres.

| Zone | Vues probables | Risque de refactor présumé | Pourquoi |
|---|---|---|---|
| **MasterFeatures / PlayerGameView** | écrans de jeu principaux | **Élevé** | probablement les vues les plus grosses (layout dense) ET les plus riches en état → double risque taille + propagation |
| **Buzzer** (`BuzzerButtonView`, `BuzzerPlayerView`) | jeu temps réel | **Élevé (test)** | MultipeerConnectivity + interaction temps réel → l'extraction peut casser le flux d'état réseau silencieusement |
| **CountdownOverlay** (Shared) | overlay partagé | **Moyen-élevé** | partagé + basé sur un Timer → toute modif se répercute sur **toutes** les features qui l'utilisent |
| **PostRoundLeaderboardView** | affichage scores | **Moyen** | affichage de données calculées → vérifier que les scores restent corrects après extraction |
| **PlayerChooseGameView / PlayerGameView** | navigation + jeu | **Moyen** | état passé entre écrans → risque sur la navigation/passage d'état |
| **CreateTeamView** | formulaire | **Faible** | déjà partiellement propre (dossier `Subviews/` en place, `TextFieldCustom` extrait) → bon candidat de rodage |
| **HomeView** | menu | **Faible** | probablement simple, peu d'état → idéal pour la 1re passe |

> **Ordre de rodage suggéré** : commencer par **HomeView** puis **CreateTeamView** (faible risque, on valide la méthode), garder **Buzzer / PlayerGameView / MasterFeatures** (haut risque) pour quand la boucle est bien huilée. On ne commence PAS par la vue la plus dangereuse.

---

## 3. Points critiques à tester (par catégorie de risque)

Un refactor ne doit **rien changer au comportement**. Ces tests se font **en interaction réelle** après chaque page (règle ÉTAT-3), pas juste « ça compile ». Classés par ce qui casse le plus souvent lors d'une extraction de sous-vues.

### 3.1 — Propagation d'état SwiftUI (risque n°1, silencieux)
L'extraction casse l'état sans erreur de compilation. Après chaque vue refactorée, vérifier :
- [ ] Une valeur modifiée dans la sous-vue extraite **se répercute** bien sur le parent (le `@State` devenu `@Binding` fonctionne).
- [ ] La sous-vue **se met à jour** quand le ViewModel change (pas de `@StateObject` recréé à tort à la place d'un `@ObservedObject`).
- [ ] Aucun état ne **se réinitialise** de façon inattendue (symptôme d'un `@StateObject` dupliqué ou d'un objet recréé).
- [ ] Les `@EnvironmentObject` sont **toujours injectés** dans la sous-vue extraite (sinon crash à l'exécution).
- [ ] **Fonction déplacée vers le ViewModel (FONC-1/FONC-4)** : vérifier qu'elle ne lisait pas un `@State` **local à la View** qui n'existe pas côté ViewModel. Si c'était le cas, la donnée doit lui être passée en paramètre. Tester que l'action produit le même résultat qu'avant.

### 3.2 — MultipeerConnectivity (vues Buzzer / jeu multijoueur)
Le plus risqué car l'état réseau est souvent porté par ces vues.
- [ ] Le **buzz fonctionne toujours** (envoi/réception entre appareils).
- [ ] Un joueur qui **rejoint** en cours est bien pris en compte.
- [ ] Un joueur qui **quitte / se déconnecte** est bien géré (pas de crash, l'UI se met à jour).
- [ ] La **session survit** à une extraction (l'objet de session n'a pas été recréé/dupliqué par l'extraction).

### 3.3 — MusicKit (blind test)
- [ ] La **preview** joue toujours (non-abonné).
- [ ] Le **full track** joue pour l'hôte abonné.
- [ ] **Pas de double lecture** (deux extraits qui se superposent) après refactor.
- [ ] L'audio **s'arrête proprement** en fin de manche, à l'abandon, et au passage en arrière-plan.
- [ ] Le **modal d'abonnement** s'ouvre toujours.

### 3.4 — Timers & CountdownOverlay (partagé)
Attention : c'est partagé → tester dans **chaque** feature qui l'utilise, pas une seule.
- [ ] Le compte à rebours **ne se dérègle pas** (bonne durée).
- [ ] Il ne se **duplique pas** (deux timers qui tournent).
- [ ] Il **s'arrête** bien quand la manche/partie se termine.
- [ ] Comportement correct au **retour d'arrière-plan** (cohérent avec la logique de pause/reprise du plan analytics).

### 3.5 — Scoring (PostRoundLeaderboardView, ScorePlayer)
- [ ] Les **scores affichés restent exacts** après extraction (aucune valeur figée/perdue).
- [ ] Le classement s'**ordonne** toujours correctement.

### 3.6 — Navigation & passage d'état entre écrans
- [ ] La navigation entre écrans **conserve l'état** (ex. équipe créée → écran de jeu).
- [ ] Aucun écran ne **repart de zéro** après un aller-retour.

---

## 4. Rappel de procédure (voir `ARCHITECTURE.md` §6)

1. Inventaire d'abord (remplir §1), **sans modifier**.
2. Une page à la fois, de la plus prioritaire à la moins (mais rodage sur faible risque, §2).
3. Après chaque page : diff présenté → validation humaine → **tests §3 en interaction réelle** → **commit**.
4. Checklist de suivi cochée au fur et à mesure (REFACTOR-3).
