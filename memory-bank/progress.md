# Progress — Urban Terror Optimized

## État global du projet

**Phase actuelle** : POST-PHASE-1A — Phase 1A terminée et mergée. Repo propre. Prochaine phase à décider.

---

## ✅ Terminé

### Analyse & Planification (2026-06-14)
- [x] Analyse des 66 commits de `omg-urt/urbanterror-slim` vs notre projet
- [x] Identification de 11 fonctionnalités manquantes, 5 partielles, 13 déjà présentes
- [x] Génération de `ANALYSIS_REPORT.md`
- [x] Création de `ROADMAP.md` (6 phases détaillées)
- [x] Configuration du Memory Bank + `.clinerules` + `.instructions.md` + `.agents/`

### Phase 1A — Fixes sécurité & branding (2026-06-14)
- [x] Branding : Q3_VERSION, CLIENT_WINDOW_TITLE, BASEGAME → `q3ut4`, DEFAULT_GAME → `q3ut4`
- [x] Build config : CNAME → `urbanterror-optimized`, RENDERER_DEFAULT → `vulkan` (Makefile)
- [x] Sécurité : Désactivation de `FS_CheckIdPaks()` (Urban Terror utilise ses propres paks)
- [x] Sécurité : `FS_GamePak` check pour empêcher le téléchargement de paks UrT depuis serveurs moddés
- [x] Sécurité : `CL_FirstDownload` pour filtrer les téléchargements sur serveurs moddés
- [x] Feature : Master server + cvars `modversion` / `sv_modversion`
- [x] Feature : Système de window margins CSS-like (`r_windowMarginTop/Bottom/Left/Right`)
- [x] Build test : ✅ Succès

### Setup repo (2026-06-14)
- [x] CLAUDE.md créé (guidance pour Claude Code)
- [x] Git remotes reconfigurés : `origin` → `miccarrer/Quake3e`, `upstream` → `ec-/Quake3e`
- [x] Feature branch mergée en FF dans `main`, worktree supprimé, branches nettoyées
- [x] `main` pushé sur `origin`

---

## ⚠️ À vérifier

### JIT NaN fix (`56f03bca` depuis urbanterror-slim)
- Ce fix est dans le ROADMAP en `[ ]` mais une session précédente l'avait marqué ✅ "vérification complète"
- Aucun commit correspondant dans notre historique
- **Action requise** : Vérifier si Quake3e upstream couvre déjà ce cas (commit `cdb374ec` désactive les optimisations FP non-sûres dans le Makefile) ou si le fix de `vm_x86.c` de slim est nécessaire

---

## 📋 À faire (voir `ROADMAP.md` pour le détail complet)

### Phase 1 — Intégration du code
- [x] **1A** — Fixes sécurité + branding + window margins + modversion
- [ ] **1B** — Features UrT : Console à onglets (`2c70fdc0`), Tellme (`d4f12aa7`+), Demo UrT (`9579fc7e`)
- [ ] **1C** — Cvars serveur : sv_sayprefix (`dd52e95f`), sv_nofalldamage (`be301ebf`), sv_infiniteStamina (`bbb587d4`), referee fix (`b834398f`)
- [ ] **1D** — (Optionnel) dmaHD audio engine (`213e0e5d`) — 1524 lignes, décision en attente

### Phase 2 — Branding complet
- [ ] CMakeLists.txt : `CNAME "quake3e"` → `"urbanterror-optimized"`
- [ ] CI : Renommer artifacts, nettoyer jobs désactivés
- [ ] README.md, BUILD.md : Réécrire pour UrT
- [ ] Supprimer docs Q3A legacy (`docs/quake3e-*`, `docs/README.*`)
- [ ] Renommer repo GitHub `Quake3e` → `urbanterror-optimized`
- [ ] Créer `LICENSE` (alias de `COPYING.txt` pour GitHub)
- [ ] Tags Git : Supprimer tags Quake3e, créer `v1.0.0`

### Phase 3 — Documentation
- [ ] Réorganiser `docs/` (legal/, analysis/)
- [ ] Créer CHANGELOG.md, CONTRIBUTING.md, SECURITY.md
- [ ] Créer CREDITS.md, CVARS.md, urt-features.md

### Phase 4 — Conventions dev
- [ ] `.editorconfig`, `.clang-format`, `.gitattributes`

### Phase 5 — CI/CD
- [ ] Séparer `ci.yml` / `release.yml`
- [ ] Lint clang-format, caching, release notes auto

### Phase 6 — Nettoyage final
- [ ] Build test Linux complet
- [ ] Tags Git, remote GitHub
- [ ] Vérification finale

---

## 📊 Métriques

| Indicateur | Valeur |
|------------|--------|
| Commits urbanterror-slim analysés | 66 |
| Fonctionnalités déjà intégrées | 13 |
| Fonctionnalités intégrées en Phase 1A | 4 (sécurité + modversion + window margins) |
| Fonctionnalités manquantes restantes | ~7 |
| Phases roadmap totales | 6 |
| Phases terminées | 1 (Phase 1A) |
