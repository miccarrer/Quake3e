# Tech Context — Urban Terror Optimized

## Stack technique

### Langage principal
- **C** (C89/C99 selon les fichiers, style Quake3/ioq3)

### Dépendances externes
| Dépendance | Rôle | Embarquée ? |
|------------|------|:---:|
| SDL2 | Video, audio, input (optionnel) | Non (système) sauf Windows |
| OpenGL | Renderer classique | Non (système) |
| Vulkan | Renderer moderne | Non (système) |
| libcurl | Téléchargements HTTP | Oui (`code/libcurl/`) |
| libjpeg | Compression JPEG (screenshots) | Oui (`code/libjpeg/`) |
| libogg + libvorbis | Décodeur audio Ogg Vorbis | Oui (`code/libogg/`, `code/libvorbis/`) |

### Build systems
- **Makefile** (principal) — Support Linux, macOS, MinGW, Raspberry Pi, PowerPC
- **CMakeLists.txt** (alternatif) — Maintenu mais `CNAME` encore à `quake3e`
- **MSVC** (`code/win32/msvc2017/quake3e.sln`) — Windows natif

### CI/CD
- **GitHub Actions** (`.github/workflows/build.yml`)
- Plateformes : Windows (MSYS2, MSVC), Ubuntu (x86/x86_64/ARM64), macOS (x86_64/ARM64)

## Environnement de développement

### Outils requis (Linux)
```bash
sudo apt install make gcc libcurl4-openssl-dev mesa-common-dev \
  libxxf86dga-dev libxrandr-dev libxxf86vm-dev libasound-dev libsdl2-dev
```

### Build minimal (Linux)
```bash
make                    # Build dans build/
make install DESTDIR=bin  # Sortie dans bin/
```

### Build avec Vulkan statique
```bash
make BUILD_SERVER=0 USE_RENDERER_DLOPEN=0 RENDERER_DEFAULT=vulkan
```

### Test rapide du build
```bash
make clean && make -j$(nproc) 2>&1 | tail -5
```

## Plateformes cibles

| Plateforme | Architecture | Statut build |
|------------|-------------|:---:|
| Linux | x86_64 | ✅ Principal |
| Linux | x86 (i386) | ✅ CI |
| Linux | ARM64 | ✅ CI |
| Windows | x86_64 (MSYS2/MinGW) | ✅ CI |
| Windows | x86 (MSYS2/MinGW) | ✅ CI |
| Windows | x64/x86/ARM64 (MSVC) | ✅ CI |
| macOS | x86_64 (Intel) | ✅ CI |
| macOS | aarch64 (Apple Silicon) | ✅ CI |

## Environnement Shell

**L'utilisateur utilise `fish` comme shell par défaut.**
- fish n'est PAS POSIX-compliant : pas de `$()`, `&&` fonctionne différemment, les globs (`*`) sont différents
- **Préfixer les commandes complexes par `bash -c '...'`** pour garantir la compatibilité
- Éviter les pipes complexes ou les sous-shells sans `bash -c`
- Si une commande bloque, c'est probablement un problème de syntaxe fish
- Préférer des commandes simples, une à la fois

## Versionning
- Git avec remote `origin` sur `ec-/Quake3e.git` (à changer)
- Tags actuels : dates Quake3e (`2021-03-28`, etc.) — à remplacer par semver
- Branche : `main`
- Convention de commit prévue : Conventional Commits (`feat:`, `fix:`, etc.)

## Outils de qualité (planifiés, Phase 4)
- `.editorconfig` — Indentation cohérente
- `.clang-format` — Formatage C automatique
- `.gitattributes` — Normalisation fins de ligne