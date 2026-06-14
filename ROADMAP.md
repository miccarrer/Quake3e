# 🗺️ Roadmap : Urban Terror Optimized

**Objectif** : Transformer ce fork de Quake3e en un projet Urban Terror autonome, propre, et respectant les conventions modernes de développement.

---

## Phase 1 — Intégration du code (features + fixes depuis urbanterror-slim)

### 1A. Fixes & sécurité prioritaires
*Petits changements, gros impact — à faire en premier*

- [ ] **x86 JIT NaN fix** (`56f03bca`) — Correction VM pour gérer les opérandes NaN dans `code/qcommon/vm_x86.c`
- [ ] **Sécurité downloads** (`0504f377`, `32499141`) — Filtre anti-download des paks UrT + fix noms de maps dans `code/qcommon/files.c` et `code/client/cl_main.c`
- [ ] **Master Server + modversion** (`4bd6632f`) — Ajout de `modversion`/`sv_modversion` dans `code/qcommon/common.c`, `qcommon.h`, `code/server/sv_main.c`

### 1B. Fonctionnalités UrT
*Plus gros changements, valeur élevée pour les joueurs*

- [ ] **Console à onglets multiples** (`2c70fdc0`, `03b932d1`) — Refonte de `code/client/cl_console.c` avec système `NUM_CONSOLES`
- [ ] **Tellme** (`d4f12aa7`, `7716e57a`, `002d179d`, `588c4cb1`) — Commande tellme + bouton dans `code/client/cl_console.c`, `cl_keys.c`
- [ ] **UrT Demo Support** (`9579fc7e`, `ec15c2c6`) — `USE_URTDEMO` dans Makefile/CMake + `cl_main.c`, `client.h`, `common.c`, `q_shared.h`, `qcommon.h`

### 1C. Fonctionnalités serveur optionnelles
*Cvars utiles pour serveurs moddés/d'entraînement*

- [ ] **sv_sayprefix / sv_tellprefix** (`dd52e95f`) — `code/server/server.h`, `sv_ccmds.c`, `sv_init.c`, `sv_main.c`
- [ ] **sv_nofalldamage** (`be301ebf`) — `code/server/server.h`, `sv_game.c`, `sv_init.c`, `sv_main.c`
- [ ] **sv_infiniteStamina** (`bbb587d4`) — `code/server/server.h`, `sv_client.c`, `sv_init.c`, `sv_main.c`
- [ ] **Referee fix** (`b834398f`) — `code/client/cl_keys.c`

### 1D. Optionnel — dmaHD
- [ ] **Moteur audio dmaHD** (`213e0e5d`) — 1524 lignes, `code/client/snd_dmahd.c` (nouveau) + modifications `snd_dma.c`, `snd_local.h`, `snd_mem.c`, `snd_mix.c`

---

## Phase 2 — Identité & Branding (Quake3e → Urban Terror Optimized)

*Le projet est encore un fork de Quake3e en apparence.*

- [ ] `CMakeLists.txt` — Changer `CNAME "quake3e"` → `CNAME "urbanterror-optimized"`
- [ ] `.github/workflows/build.yml` — Renommer artifacts et jobs vers UrT, supprimer jobs inutiles (ARM commentés, msys32 redondant)
- [ ] `README.md` — Réécrire entièrement pour UrT (features, build, liens)
- [ ] `BUILD.md` — Adapter les références Q3A vers UrT
- [ ] Supprimer `docs/quake3e-changes.txt`, `quake3e-FAQ.txt`, `quake3e.htm`, `quake3e.md`
- [ ] Supprimer `docs/README.Linux`, `docs/README.Q3Test`
- [ ] Supprimer `docs/LinuxSupport/`, `docs/firewall/`
- [ ] Déplacer `id-readme.txt` vers `docs/legal/`
- [ ] Créer `LICENSE` (synonyme de `COPYING.txt` pour GitHub)
- [ ] Nettoyer tags Git Quake3e, créer tag `v1.0.0`
- [ ] Changer `origin` remote vers le nouveau repo UrT

---

## Phase 3 — Réorganisation documentation

### Structure cible `docs/` :
```
docs/
├── BUILD.md              (déplacé depuis racine)
├── CHANGELOG.md          (nouveau)
├── CREDITS.md            (nouveau — crédits Quake3e, ioq3, omg-urt)
├── CVARS.md              (nouveau — documentation cvars UrT)
├── urt-features.md       (nouveau — console tabs, tellme, demo, etc.)
├── legal/
│   ├── GPL.txt           (depuis COPYING.txt)
│   ├── id-readme.txt     (depuis racine)
│   └── third-party.txt   (nouveau — libs tierces)
└── analysis/
    └── slim-comparison.md (depuis ANALYSIS_REPORT.md)
```

- [ ] Créer la structure `docs/legal/`, `docs/analysis/`
- [ ] Déplacer `COPYING.txt` → `docs/legal/GPL.txt` (garder copie racine)
- [ ] Déplacer `id-readme.txt` → `docs/legal/`
- [ ] Déplacer `ANALYSIS_REPORT.md` → `docs/analysis/slim-comparison.md`
- [ ] Déplacer `BUILD.md` → `docs/BUILD.md` (garder lien dans README)
- [ ] Créer `docs/CREDITS.md`
- [ ] Créer `docs/CVARS.md`
- [ ] Créer `docs/urt-features.md`
- [ ] Créer `docs/legal/third-party.txt`

### Nouveaux fichiers racine :
- [ ] `CHANGELOG.md` — Historique des versions
- [ ] `CONTRIBUTING.md` — Guide de contribution
- [ ] `SECURITY.md` — Politique de sécurité

---

## Phase 4 — Conventions de développement modernes

- [ ] `.editorconfig` — Indentation cohérente (tabs pour C, 2-space pour YAML, etc.)
- [ ] `.clang-format` — Formatage automatique du code C (style projet)
- [ ] `.gitignore` — Nettoyage et complétion
- [ ] `.gitattributes` — Normalisation fins de ligne (`* text=auto`)
- [ ] `CONTRIBUTING.md` — Workflow git, conventions de commit, processus PR

---

## Phase 5 — CI/CD modernisation

*Le workflow actuel (`build.yml`, 17KB) est hérité de Quake3e et complexe.*

- [ ] Nettoyer les jobs désactivés/commentés (ARM, msys32)
- [ ] Renommer tous les artifacts vers `urbanterror-optimized-*`
- [ ] Séparer en workflows distincts :
  - `.github/workflows/ci.yml` — Build + test sur PR (Release only)
  - `.github/workflows/release.yml` — Build + upload sur tag
- [ ] Ajouter job de lint (clang-format check)
- [ ] Ajouter caching des dépendances
- [ ] Release notes auto-générées depuis CHANGELOG.md

---

## Phase 6 — Nettoyage final & validation

- [ ] Build test : Vérifier que `make` compile sur Linux après tous les changements
- [ ] Git tags : Supprimer les tags Quake3e, créer `v1.0.0`
- [ ] Remote : Configurer le remote vers le nouveau repo GitHub
- [ ] Nettoyage : Supprimer fichiers temporaires, `ANALYSIS_REPORT.md` racine (déplacé)
- [ ] Vérification finale : `git status` propre, README à jour, build OK

---

## 📋 Ordre d'exécution proposé

| # | Phase | Durée estimée | Risque |
|---|-------|---------------|--------|
| 1 | Phase 1A — Fixes sécurité | Court | Faible |
| 2 | Phase 2 — Branding Makefile/CMake | Court | Faible |
| 3 | Phase 4 — Conventions (.editorconfig etc.) | Court | Très faible |
| 4 | Phase 1B — Features UrT (console, tellme, demo) | Moyen | Moyen |
| 5 | Phase 1C — Cvars serveur optionnelles | Court | Faible |
| 6 | Phase 3 — Réorganisation docs | Moyen | Faible |
| 7 | Phase 5 — CI/CD | Moyen | Moyen |
| 8 | Phase 6 — Nettoyage final | Court | Faible |

---

## 📊 Référence : Fonctionnalités déjà présentes (13)

Ces fonctionnalités de urbanterror-slim sont **déjà intégrées** dans notre projet :

1. ✅ MAX_RELIABLE_COMMANDS = 128
2. ✅ qkey fix
3. ✅ MAX_LOCATIONS
4. ✅ condump actif
5. ✅ con_autoclear
6. ✅ r_ext_compressed_textures
7. ✅ .mtrx shader loading
8. ✅ CalcSpecular epsilon fix
9. ✅ r_parallaxMapOffset
10. ✅ teleport command
11. ✅ spoof/forcecvar/sendclientcommand
12. ✅ kicknum/kickall/kickbots
13. ✅ Authorize server disabled