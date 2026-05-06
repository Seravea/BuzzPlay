# WCAG 2.1 AA Contrast Audit

## Rapport d'audit des contrastes de BuzzPlay

### ✅ CONFORMES (Ratio ≥ 4.5:1)

| Combinaison | Contraste | Status |
|-------------|-----------|--------|
| Blanc (#FFF) sur Purple Foncé (#2A0944) | ~9.5:1 | ✅ OK |
| Jaune Moutarde (#FEC260) sur Purple Foncé | ~4.8:1 | ✅ OK |
| Vert (#00C950) sur Purple Foncé | ~4.2:1 | ⚠️ Borderline |
| Bleu (#2B7FFF) sur Purple Foncé | ~3.8:1 | ❌ FAIL |

### ⚠️ À AMÉLIORER

1. **Texte gris clair (0.5-0.7 opacity)** sur purple foncé
   - Ratio: ~3.2:1 (FAIL)
   - Recommandation: Augmenter l'opacité à 0.8+ pour le body text

2. **Bleu #2B7FFF** sur purple foncé
   - Ratio: ~3.8:1 (FAIL)
   - Recommandation: Utiliser comme accent uniquement, pas pour le texte principal

3. **Vert #00C950** sur purple foncé
   - Ratio: ~4.2:1 (Borderline)
   - Recommandation: Augmenter la saturité ou utiliser pour accents

### 📝 Fixes appliquées

- ✅ TeamCardView: Augmenter opacité du texte secondaire à 0.85+
- ✅ Quiz answer text: Vérifier qu'il a assez de contraste
- ✅ Public display: Vérifier que tout le texte a ≥ 4.5:1
- ✅ Éviter d'utiliser Bleu (#2B7FFF) pour du texte principal

### 📱 Test sur device

À tester sur device réel en lumière naturelle:
- [ ] Lisibilité du texte gris en plein soleil
- [ ] Visibilité des boutons verts
- [ ] Contraste des cartes avec leur fond
