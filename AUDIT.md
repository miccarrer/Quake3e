# 🔎 Audit des fondations & plan de modernisation

> Audit réalisé le **2026-06-15** (état branche `main` @ `2b872b31`).
> Objectif : vérifier la solidité des fondations et lister ce qui peut être modernisé
> (CI, game dev, docs, outillage) pour viser un projet « le plus moderne possible ».
> Suivi de l'exécution : milestone **M7** du [`ROADMAP.md`](ROADMAP.md).

## Verdict

Les fondations **M0–M4 sont solides** : pour un moteur C legacy (lignée Quake3), le projet
est au-dessus de la moyenne des forks. Ce qui suit comble les lacunes restantes.

### ✅ Acquis (vérifié)

| Domaine | État |
|---|---|
| **CI** | `ci.yml` : clang-format (lignes modifiées), cppcheck, ASan/UBSan, matrice Linux/macOS/Windows-MinGW, ccache, concurrency |
| **Release** | `release.yml` : 5 plateformes, Vulkan+OpenGL, publication GitHub Release, actions récentes |
| **Qualité code** | `.clang-format`, `.clang-tidy`, `.editorconfig`, `.gitattributes`, `.gitignore`, hook clang-format à l'édition |
| **Gouvernance** | CODEOWNERS, templates issue/PR, SECURITY, CONTRIBUTING, CHANGELOG (Keep a Changelog) |
| **Docs** | README, `docs/BUILD.md` (multiplateforme), CVARS/CREDITS/urt-features/legal, memory-bank à jour |
| **Build** | Makefile branché (CNAME, Vulkan défaut), `compile_commands.json` via bear, MSVC 2017 |

### ⚠️ Lacunes → traitées en M7

| # | Lacune | Axe | Impact |
|---|---|---|---|
| 1 | **Aucun test unitaire** (~60K SLOC), **aucun fuzzing** | Tests | 🔴 Élevé |
| 2 | Pas de **CodeQL**, pas de **dependabot**, actions épinglées sur tags (pas SHA) | Sécurité CI | 🟠 Moyen |
| 3 | Pas de **build provenance / attestation**, pas de job **MSVC** en CI | Sécurité CI | 🟠 Moyen |
| 4 | Pas de **`-std=` explicite**, versioning statique (pas de `git describe`) | Build | 🟠 Moyen |
| 5 | Pas de **durcissement** (PIE/RELRO/stack-protector/FORTIFY) | Build | 🟠 Moyen |
| 6 | MSVC encore nommé `quake3e.sln`, pas de coverage | Build | 🟢 Faible |
| 7 | Pas d'**env reproductible** (Dockerfile/devcontainer/Nix) | Env | 🟡 Selon besoin |
| 8 | Pas de **CODE_OF_CONDUCT**, badges/captures README, ARCHITECTURE.md racine | Polish | 🟢 Faible |

---

## Plan M7 — suivi d'exécution

Livré par **phases indépendantes** (chacune compilable/mergeable seule), impact décroissant.
Contrainte : `code/` reste aligné `ec-/Quake3e` → tests/fuzzing hors-arbre dans `tests/`,
modifs `code/` minimisées.

### Phase 1 — Tests & fuzzing 🔴
- [ ] `tests/unit/` : harness **Unity** (vendored) + `tests/Makefile` séparé (ASan/UBSan par défaut)
- [ ] Tests : `q_math.c`, `q_shared.c` (parse/Info_*), `cvar.c` (+ stubs), `md4.c`/`md5.c`
- [ ] `tests/fuzz/` : cibles **libFuzzer** sur `COM_Parse`, `Info_*`, `msg.c` (+ corpus seed)
- [ ] CI : jobs `unit` et `fuzz-smoke` dans `ci.yml`

### Phase 2 — Durcissement CI / sécurité 🟠
- [ ] `.github/workflows/codeql.yml` (langage c-cpp, PR + hebdo)
- [ ] `.github/dependabot.yml` (écosystème github-actions)
- [ ] Épingler les actions sur **SHA** (`ci.yml` + `release.yml`)
- [ ] `actions/attest-build-provenance` sur les artefacts de `release.yml`
- [ ] Job **MSVC** dans la matrice `build` de `ci.yml`
- [ ] *(optionnel, après Phase 1)* coverage codecov

### Phase 3 — Build & versioning 🟠
- [ ] Versioning dynamique : `git describe --match 'v[0-9]*'` → `-DSVN_VERSION` (Makefile ;
      hook déjà présent `code/qcommon/q_shared.h:30-32`, **0 modif code**)
- [ ] `-std=gnu99` explicite (3 blocs plateforme du Makefile) — **valider build**
- [ ] Durcissement Linux/release : `-fstack-protector-strong`, `-D_FORTIFY_SOURCE=2`,
      `-Wl,-z,relro,-z,now`, `-fPIE -pie` — **vérifier JIT VM sous PIE**
- [ ] *(optionnel)* rebranding `quake3e.sln` → `urbanterror-optimized.*`

### Phase 4 — Env reproductible & polish 🟡/🟢
- [ ] `.devcontainer/devcontainer.json` + `Dockerfile` (toolchain one-command)
- [ ] `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1)
- [ ] README : badges (CI/release/licence/plateformes) + capture/GIF
- [ ] `ARCHITECTURE.md` (promotion de `memory-bank/systemPatterns.md`)
- [ ] *(optionnel)* `.github/FUNDING.yml`

---

## Notes techniques

- **`git describe`** : le tag legacy `latest` (purgé en remote, restant en local) court-circuite
  `v0.1.0`. Utiliser `--match 'v[0-9]*'` → `v0.1.0-22-gXXXXXXX` (non-destructif, pas besoin de
  supprimer le tag).
- **`-std`** : `gnu99` et non `c99` — le code utilise des extensions GNU (`__attribute__`, asm
  inline). Verrouille le comportement face aux compilateurs dont le défaut migre vers C23.
- **Tests hors-arbre** : `tests/` n'est pas suivi par upstream → zéro impact sur le cherry-pick.
- **Unity** plutôt que Criterion : header-only, C89, zéro dépendance — adapté au C legacy.
