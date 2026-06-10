# Packs de quiz distants — format & hébergement

L'app fetch **silencieusement** ce catalogue au lancement (`RemoteQuizPackCatalog.syncSilently()`),
le met en cache localement (`Application Support/quiz_packs_remote.json`) → les packs restent
disponibles **hors-ligne** pendant la partie. Offline/404/JSON cassé = no-op (l'app vit sur le cache).

## Hébergement

1. Créer un repo GitHub **public** (ex : `Seravea/buzzplay-packs`).
2. Y déposer `quiz_packs.json` (ce dossier contient un exemple prêt à copier).
3. Vérifier l'URL raw : `https://raw.githubusercontent.com/Seravea/buzzplay-packs/main/quiz_packs.json`
4. ⚠️ Si le nom du repo/fichier diffère, mettre à jour `catalogURL` dans
   [RemoteQuizPackCatalog.swift](../../BuzzPlay/Data/RemoteQuizPackCatalog.swift).

## Format

```jsonc
{
  "packs": [
    {
      "id": "pack-cinema-2026",          // unique, stable (sert d'identité au thème)
      "title": "Spécial Cinéma",          // affiché dans la sélection de thème
      "iconName": "film.fill",            // SF Symbol (vérifier qu'il existe !)
      "category": "special",              // "era" | "genre" | "special" → couleur du thème
      "productID": "buzzplay.quiz.cinema",// ABSENT ou null = pack GRATUIT
      "priceDisplay": "0,99 €",           // affichage V1 mock ; remplacé par le prix StoreKit en réel
      "sets": [
        {
          "id": "cinema-cultes",          // unique, stable
          "title": "Répliques cultes",
          "questions": [
            {
              "question": "…",
              "answers": ["…"],           // réponses acceptées (la 1re est affichée)
              "difficulty": "facile",     // facile | moyen | difficile | expert
              "funFact": "…"              // optionnel (null ok)
            }
          ]
        }
      ]
    }
  ]
}
```

## Premium (Non-Consumable)

- Un pack **avec `productID`** apparaît verrouillé (cadenas + prix) tant qu'il n'est pas acheté.
- V1 : achat **mocké** dans [QuizPackStore.swift](../../BuzzPlay/Data/QuizPackStore.swift)
  (unlock persisté `UserDefaults["buzzplay.quiz.unlockedPacks"]`).
- StoreKit 2 réel : remplacer uniquement `performPurchase` + brancher `restorePurchases`
  sur `Transaction.currentEntitlements`. Créer les produits **Non-Consumable** dans
  App Store Connect avec les mêmes `productID`.
- IDs réservés (CLAUDE.md) : `buzzplay.quiz.cinema`, `buzzplay.quiz.sport`,
  `buzzplay.quiz.annees90`, `buzzplay.quiz.noel`.
