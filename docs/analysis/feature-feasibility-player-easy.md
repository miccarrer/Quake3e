# Analyse de faisabilité — Features joueurs faciles à implémenter

> **Contexte** : Urban Terror utilise une architecture Engine + QVM (cgame.qvm pour le rendu HUD/gameplay côté client, qagame.qvm côté serveur). Le projet **urbanterror-optimized** est l'**engine**.
>
> **Conséquence majeure** : les features HUD (crosshair, hitmarker, damage indicator, scoreboard, minimap, etc.) sont normalement dans le **cgame QVM du mod** (code fermé/binary). Pour les implémenter au niveau engine, il faut soit :
> 1. Ajouter un **layer de rendu engine-side** (interception des events + overlay 2D)
> 2. Ou **modifier le cgame QVM** (nécessite le code source du mod UrT)
>
> Les features marquées **✅ Engine** peuvent être implémentées directement dans l'engine. Les features marquées **⚠️ CGame** nécessitent une approche engine-side alternative (overlay) ou des changements au mod.

---

## Tableau récapitulatif

| # | Feature | Difficulté | Existe déjà ? | Niveau | Faisabilité engine |
|---|---------|-----------|---------------|--------|-------------------|
| 1 | Profils de config | Très facile | ❌ | Engine | ✅ Très haute |
| 6 | Auto-demo intelligent | Facile | ✅ Partiel (`cl_autoRecordDemo`) | Engine | ✅ Très haute |
| 7 | Netgraph overlay | Très facile | ❌ (mais `cl_shownet` existe) | Engine | ✅ Très haute |
| 8 | Screenshot manager étendu | Facile | ✅ Partiel (JPEG/BMP) | Engine | ✅ Très haute |
| 9 | Favoris serveurs / auto-reconnect | Facile | ✅ Partiel (`reconnect`) | Engine | ✅ Haute |
| 10 | Coloration syntaxique console | Facile | ❌ | Engine | ✅ Haute |
| 11 | Hitmarker visuel/sonore | Très facile | ❌ | ⚠️ CGame | 🔶 Moyenne (overlay engine) |
| 12 | Floating ammo HUD | Facile | ❌ | ⚠️ CGame | 🔶 Moyenne (overlay engine) |
| 13 | Killstreak tracker | Facile | ❌ | ⚠️ CGame | 🔶 Moyenne (overlay engine) |
| 54 | FPS limiter | Facile | ✅ Partiel (`com_maxFPS`) | Engine | ✅ Très haute |
| 102 | Presets graphiques | Très facile | ❌ | Engine | ✅ Très haute |
| 111 | FOV scaling ultrawide | Facile | ❌ | ⚠️ CGame | 🔶 Moyenne |
| 113 | Strafe jumping helper | Facile | ❌ | ⚠️ CGame | 🔶 Moyenne |
| 115 | Keybind conflict detection | Très facile | ❌ | Engine | ✅ Très haute |
| 119 | Crosshair import/export | Très facile | ❌ | ⚠️ CGame | ✅ Haute (sérialisation cvars) |

---

## Analyses détaillées

### 1. Profils de config (keybind profiles) — ✅ Engine, Très facile

**Existe déjà ?** Non. Le système de config se limite à `writeconfig <file>` et `exec <file>`.

**Faisabilité** : Très haute. Le système de commandes console et de fichiers (`FS_Write`) existe déjà.

**Implémentation** :
- `saveprofile <name>` : exécute `writeconfig profiles/<name>.cfg`
- `loadprofile <name>` : exécute `exec profiles/<name>.cfg`
- `listprofiles` : liste les fichiers dans `profiles/` via `FS_GetFileList`
- Cvar `cl_profile` pour mémoriser le profil actif

**Fichiers à modifier** : `code/client/cl_main.c` (nouvelles commandes)

**Estimation** : ~50 lignes de code.

---

### 6. Auto-demo intelligent — ✅ Engine, Facile

**Existe déjà ?** Oui, partiellement.
- `cl_autoRecordDemo` (on/off) existe déjà dans `cl_main.c` ligne ~auto-record au connect
- `cl_drawRecording` existe pour l'affichage HUD
- **Manque** : pruning (garde infinie), filtre par taille min, naming custom

**Faisabilité** : Très haute. Le code d'auto-record est dans `CL_MapLoading` / `CL_Init`.

**Implémentation** :
- `cl_autoDemoKeep` (int, nombre de démos à conserver) → au démarrage d'un nouvel enregistrement, supprimer les plus anciennes au-delà de N
- `cl_autoDemoMinSize` (int, KB) → au démarrage, supprimer les démos plus petites que N KB (probablement vides/corrompues)
- Utiliser `FS_GetFileList("demos/", ".dm_*", ...)` + `FS_Remove`

**Fichiers à modifier** : `code/client/cl_main.c` (fonction `CL_AutoRecordDemo` à créer)

**Estimation** : ~80 lignes de code.

---

### 7. Netgraph overlay — ✅ Engine, Très facile

**Existe déjà ?** Partiellement.
- `cl_shownet` (0-3) affiche des infos réseau en texte
- `cl_showTimeDelta` existe
- **Manque** : graphe visuel temps réel du ping et packet loss

**Faisabilité** : Très haute. Les données de ping sont dans `cl.snap.ping` et l'historique dans `cl.snapshots[i].ping`.

**Données disponibles** :
```c
// code/client/cl_cgame.c — déjà calculé !
for ( i = 0; i < PACKET_BACKUP; i++ ) {
    if ( cl.snapshots[i].ping > 0 && cl.snapshots[i].ping < 999 ) {
        ping[count] = cl.snapshots[i].ping;
        count++;
    }
}
```

**Implémentation** :
- Nouvelle cvar `cg_netgraph` (0=off, 1=texte, 2=graphe, 3=both)
- Cvar `cg_netgraphTime` (fenêtre en secondes, défaut 30)
- Ring buffer de `ping` et `packetLoss` échantillonné chaque frame
- Rendu 2D via `SCR_DrawStringExt` ou polygones dans `cl_scrn.c`

**Fichiers à modifier** : `code/client/cl_scrn.c` (nouvelle fonction `SCR_DrawNetgraph`)

**Estimation** : ~100 lignes de code.

---

### 8. Screenshot manager étendu — ✅ Engine, Facile

**Existe déjà ?** Oui, partiellement.
- `screenshot` (TGA), `screenshotJPEG` (avec `r_screenshotJpegQuality`), `screenshotBMP` existent
- Print Screen key est hardcoded dans `cl_keys.c` (BMP screenshot)
- **Manque** : PNG, mode "clean" (sans HUD), burst mode, organisation par date/map

**Faisabilité** : Haute. Le système de capture existe, il faut étendre les formats et ajouter le mode clean.

**Implémentation** :
- `cl_screenshotFormat` (0=TGA, 1=JPEG, 2=BMP, 3=PNG) → unifier les commandes en une seule `screenshot` qui respecte la cvar
- `cl_screenshotClean` (on/off) → pendant la capture, setter temporairement `cg_draw2D 0` + `cg_drawGun 0` via `Cvar_Set`, capturer, restaurer
- PNG : utiliser libpng (à ajouter aux libs vendored) ou un encodeur PNG minimal (zlib déjà présent)
- Burst mode : `screenshot_burst <count> <interval_ms>`

**Fichiers à modifier** : `code/client/cl_main.c` (commandes screenshot), `code/client/cl_keys.c`, éventuellement nouveau `code/client/cl_png.c`

**Estimation** : ~150 lignes (sans libpng), ~300 lignes (avec encodeur PNG minimal).

---

### 9. Favoris serveurs / auto-reconnect — ✅ Engine, Facile

**Existe déjà ?** Partiellement.
- `reconnect` existe (`CL_Reconnect_f` dans `cl_main.c`)
- `cl_reconnectArgs` stocke les derniers args de connexion
- Le browser de serveurs utilise déjà `getstatus`/`getinfo`
- **Manque** : favoris persistants, tags, auto-reconnect avec backoff

**Faisabilité** : Haute. L'infrastructure réseau et de fichiers existe.

**Implémentation** :
- `favorite <add|remove|list>` → gestion d'un fichier `favorites.txt`
- `cl_autoReconnect` (on/off) → après déconnexion involontaire, reconnecter avec backoff exponentiel (1s, 2s, 4s, 8s, max 60s)
- `cl_autoReconnectMaxRetries` (int)
- Timer dans `CL_Frame` qui déclenche `CL_Reconnect_f` après le délai

**Fichiers à modifier** : `code/client/cl_main.c`

**Estimation** : ~120 lignes de code.

---

### 10. Coloration syntaxique console — ✅ Engine, Facile

**Existe déjà ?** Non. La console a des onglets (`con_tabs`) et supporte les couleurs `^1`-`^7`, mais pas de coloration automatique.

**Faisabilité** : Haute. Le système de rendu de la console existe dans `cl_console.c`, avec support couleur.

**Implémentation** :
- `con_colorize` (on/off) → active la coloration
- Dans `Con_DrawUpdate` / `Con_PageUp` ou au moment du print (`Con_Print`), ajouter des codes couleur automatiquement :
  - Lignes commençant par une cvar connue → couleur A
  - Commandes → couleur B
  - Timestamps (format `HH:MM`) → gris
  - "error:" / "warning:" → rouge/jaune
- Recherche/filtrage : `Ctrl+F` dans la console, cvar `con_searchHighlight`

**Fichiers à modifier** : `code/client/cl_console.c`

**Estimation** : ~100 lignes de code (coloration) + ~60 lignes (recherche).

---

### 11. Hitmarker visuel et sonore — ⚠️ CGame, Très facile (si engine overlay)

**Existe déjà ?** Non dans l'engine. Le cgame QVM du mod peut l'avoir, mais ce n'est pas accessible.

**Le défi** : Le hit feedback (toucher un ennemi) est détecté côté cgame QVM via les events réseau (`EV_RAILTRAIL`, `EV_BULLET_HIT_FLESH`, etc.). L'engine ne voit pas directement ces events de manière structurée — ils sont passés au cgame via `CG_GetSnapshot`.

**Approche engine-side** :
1. **Intercepter les events dans le snapshot** : dans `CL_ParseEntities` (`cl_parse.c`), scanner les `entityState_t` pour les events de hit. **Problème** : les events UrT spécifiques ne sont pas documentés dans l'engine (le mod définit ses propres `EV_*`).
2. **Hook sonore** : intercepter `CG_S_STARTSOUND` dans le cgame syscall dispatch (`cl_cgame.c`) — quand le cgame demande un son de hit, l'engine peut l'utiliser comme trigger pour un hitmarker visuel.

**Faisabilité** : Moyenne. L'approche #2 (hook syscall) est la plus fiable — quand le cgame joue un son de hit (identifiable par le nom du sound file), l'engine peut déclencher un hitmarker.

**Implémentation** :
- Dans `CL_CgameSystemCalls` (`cl_cgame.c`), intercepter `CG_S_STARTSOUND` et `CG_S_STARTLOCALSOUND`
- Matcher le nom du son contre une liste configurable (`cg_hitSoundName`)
- Déclencher un timer pour afficher un hitmarker overlay dans `cl_scrn.c`

**Fichiers à modifier** : `code/client/cl_cgame.c` (hook), `code/client/cl_scrn.c` (rendu overlay)

**Estimation** : ~80 lignes. **Mais** : fragile (dépend des noms de sons du mod).

---

### 12. Floating ammo HUD — ⚠️ CGame, Facile (si engine overlay)

**Existe déjà ?** Non dans l'engine.

**Le défi** : Le compteur de munitions est dans `ps->ammo[weapon]` et `ps->clip[weapon]` — **accessibles depuis l'engine** car `playerState_t` est dans le snapshot !

**Faisabilité** : Haute. Contrairement au hitmarker, les munitions sont dans `cl.snap.ps` qui est accessible côté engine.

**Implémentation** :
- Cvar `cg_floatingAmmo` (on/off), `cg_floatingAmmoPosition` (offset X/Y depuis crosshair)
- Dans `SCR_DrawScreenField` (`cl_scrn.c`), après le rendu cgame, dessiner le compteur de munitions
- Accès : `cl.snap.ps.ammo[cl.snap.ps.weapon]` et `cl.snap.ps.clips[cl.snap.ps.weapon]` (noms de champs UrT-spécifiques à vérifier)

**Fichiers à modifier** : `code/client/cl_scrn.c`

**Estimation** : ~40 lignes. **Risque** : les noms exacts des champs UrT dans `playerState_t` (le mod peut utiliser des champs custom dans les champs de stats réservés).

---

### 13. Killstreak tracker — ⚠️ CGame, Facile (si engine overlay)

**Existe déjà ?** Non dans l'engine.

**Le défi** : Les frags sont détectés via les events réseau (`EV_OBITUARY` en Q3 standard). L'engine les voit passer dans le snapshot.

**Faisabilité** : Moyenne-Haute. L'engine peut scanner les events du snapshot.

**Implémentation** :
- Dans `CL_ParseEntities` ou après `CL_GetSnapshot`, scanner les `entityState_t` pour l'event `EV_OBITUARY` (valeur spécifique au mod — à découvrir empiriquement)
- Tracker les frags du joueur local (`cl.snap.ps.clientNum` == attaquant)
- Timer pour la fenêtre de streak (ex: 5 secondes entre frags pour maintenir le streak)
- Notification overlay dans `cl_scrn.c`

**Fichiers à modifier** : `code/client/cl_parse.c` (détection), `code/client/cl_scrn.c` (rendu)

**Estimation** : ~100 lignes. **Risque** : l'event d'obituary UrT peut différer de Q3, les champs `eventParm` peuvent coder l'arme/le headshot différemment.

---

### 54. FPS limiter intelligent — ✅ Engine, Facile

**Existe déjà ?** Oui, partiellement.
- `com_maxFPS` existe et limite déjà les FPS
- `r_swapInterval` (V-Sync) existe
- **Manque** : mode "sleep" (économie CPU/GPU) vs "busy wait" (minimum latency), FPS cap adaptatif

**Faisabilité** : Très haute.

**Implémentation** :
- `r_maxFPSMode` (0=basy wait existant, 1=sleep avec `Sys_Sleep`, 2=adaptatif)
- En mode sleep : après le rendu, calculer le temps restant et appeler `Sys_Sleep(remaining_ms)` au lieu de busy-wait
- En mode adaptatif : réduire le FPS cap si la température GPU/CPU est élevée (nécessite des capteurs — complexe)

**Fichiers à modifier** : `code/qcommon/common.c` (boucle `Com_Frame`)

**Estimation** : ~30 lignes (mode sleep simple).

---

### 102. Presets graphiques — ✅ Engine, Très facile

**Existe déjà ?** Non.

**Faisabilité** : Très haute. C'est juste un wrapper qui set plusieurs cvars d'un coup.

**Implémentation** :
- Commande `gfx_preset <name>` qui exécute un lot de `Cvar_Set` :
  - `competitive` : `r_picmip 5`, `r_fullbright 0`, `r_vertexLight 1`, `r_dynamiclight 0`, `r_fbo 0`, `cg_draw3dIcons 0`, `r_lodbias 2`, etc.
  - `balanced` : valeurs par défaut
  - `cinematic` : `r_fbo 1`, `r_hdr 1`, `r_bloom 1`, `r_ext_multisample 4`, etc.
- Presets stockés dans `scripts/gfx_presets/` ou hardcoded
- `r_lastPreset` pour mémoriser et `gfx_preset toggle` pour basculer

**Fichiers à modifier** : `code/client/cl_main.c` (nouvelle commande)

**Estimation** : ~100 lignes (presets hardcoded + parsing).

---

### 111. FOV scaling ultrawide — ⚠️ CGame/Engine, Facile

**Existe déjà ?** Non de manière automatique. `cg_fov` existe dans le mod (cgame QVM).

**Le défi** : Le FOV est normalement géré côté cgame QVM. Mais l'engine a accès au ratio d'aspect via `glconfig_t` (`cls.glconfig.vidWidth/vidHeight`).

**Faisabilité** : Moyenne. L'engine peut ajuster `ps->fov` dans le snapshot **avant** de le passer au cgame — mais cela peut entrer en conflit avec le mod qui set aussi le FOV.

**Approche alternative (engine-side)** : ajuster la matrice de projection du renderer au lieu du FOV gameplay — élargir le frustum horizontal sans changer le FOV logique. Plus propre mais ne change pas le gameplay (vision périphérique).

**Implémentation (approche projection)** :
- Cvar `cg_autoFOV` (on/off)
- Dans le renderer, si le ratio d'aspect > 16:9, ajuster le frustum horizontal
- Ou : setter `cg_fov` via `Cvar_Set` quand le ratio change (mais le mod peut override)

**Fichiers à modifier** : `code/renderer/tr_view.c` (matrice projection) ou `code/client/cl_main.c` (set `cg_fov`)

**Estimation** : ~30 lignes (projection) ou ~40 lignes (cvar set). **Risque** : conflit avec le mod.

---

### 113. Strafe jumping helper — ⚠️ CGame/Engine, Facile

**Existe déjà ?** Non.

**Faisabilité** : Haute. Les données de vélocité sont dans `cl.snap.ps.velocity` (accessible engine-side). La prédiction de mouvement existe côté engine (`CL_PredictMovement` dans les anciens Q3, ou dans le cgame).

**Implémentation engine-side** :
- Cvar `cg_strafeHelper` (0=off, 1=vecteur vélocité, 2=angle optimal, 3=texte)
- Dans `cl_scrn.c` après le rendu cgame :
  - Lire `cl.snap.ps.velocity` et `cl.snap.ps.viewangles`
  - Calculer l'angle entre vélocité et view direction
  - Afficher un indicateur visuel (ligne, arc, texte "OPTIMAL!" / "TOO WIDE!" / "TOO NARROW!")
- L'angle optimal de strafe (~25-30° entre viewangle et vélocité horizontale) est un calcul trigonométrique simple

**Fichiers à modifier** : `code/client/cl_scrn.c`

**Estimation** : ~80 lignes. **Note** : purement visuel, n'affecte pas le gameplay.

---

### 115. Keybind conflict detection — ✅ Engine, Très facile

**Existe déjà ?** Non.

**Faisabilité** : Très haute. Le tableau `keys[K_LAST_KEY]` est dans `cl_keys.c` et contient les binds.

**Implémentation** :
- Commande `bindcheck` qui parcourt `keys[]` et pour chaque touche, liste toutes les actions liées
- Détecter les conflits (même touche liée à `+attack` et `+moveforward`, par exemple)
- Affichage dans la console

**Fichiers à modifier** : `code/client/cl_keys.c` (nouvelle commande `bindcheck`)

**Code existant pertinent** :
```c
// cl_keys.c contient déjà la structure keys[]
typedef struct {
    qboolean down;
    int repeats;
    char *binding;
} keydata_t;
```

**Estimation** : ~40 lignes.

---

### 119. Crosshair import/export — ✅ Engine/CGame, Très facile

**Existe déjà ?** Non.

**Faisabilité** : Très haute. C'est de la sérialisation de cvars.

**Le défi** : Les cvars de crosshair (`cg_crosshairSize`, `cg_crosshairColor`, `cg_crosshairHealth`, etc.) sont dans le cgame QVM. Mais l'engine peut les lire via `Cvar_VariableStringBuffer` et les écrire via `Cvar_Set`.

**Implémentation** :
- `crosshair_export <name>` : écrit un fichier `crosshairs/<name>.cfg` avec toutes les cvars `cg_crosshair*`
- `crosshair_import <name>` : exécute `exec crosshairs/<name>.cfg`
- `crosshair_list` : liste les presets disponibles
- Presets intégrés : `csgo`, `apex`, `quake`, `dot`, `cross`, `t-style`

**Fichiers à modifier** : `code/client/cl_main.c` (nouvelles commandes)

**Estimation** : ~60 lignes.

---

## Résumé des priorités d'implémentation

### 🟢 Top 5 — Implémentation immédiate (Engine pur, très facile)

| # | Feature | LOC estimé | Valeur |
|---|---------|-----------|--------|
| 115 | Keybind conflict detection | ~40 | Debug qualité de vie |
| 102 | Presets graphiques | ~100 | Onboarding nouveaux joueurs |
| 7 | Netgraph overlay | ~100 | Compétitif / debug |
| 6 | Auto-demo intelligent (pruning) | ~80 | Gestion d'espace disque |
| 54 | FPS limiter (mode sleep) | ~30 | Économie CPU/GPU/énergie |

### 🟡 Top 5 — Implémentation facile (Engine pur, valeur élevée)

| # | Feature | LOC estimé | Valeur |
|---|---------|-----------|--------|
| 8 | Screenshot manager (PNG + clean) | ~150 | Capture/création de contenu |
| 9 | Favoris serveurs + auto-reconnect | ~120 | Qualité de vie réseau |
| 10 | Coloration console | ~100 | Lisibilité debug |
| 1 | Profils de config | ~50 | Multi-configs |
| 119 | Crosshair import/export | ~60 | Personnalisation |

### 🔶 Features nécessitant une approche engine-side créative (overlay/hook)

| # | Feature | Risque | Valeur |
|---|---------|--------|--------|
| 12 | Floating ammo HUD | Bas (ps accessible) | Moyenne |
| 113 | Strafe jumping helper | Bas (ps accessible) | Élevée (formation) |
| 13 | Killstreak tracker | Moyen (events mod-spécifiques) | Moyenne |
| 11 | Hitmarker | Moyen (hook syscall son) | Élevée |
| 111 | FOV ultrawide | Moyen (conflit mod) | Moyenne |

---

## Note technique : Architecture engine vs cgame

```
┌─────────────────────────────────────────┐
│               CLIENT ENGINE              │
│  (code/client/, code/qcommon/)          │
│                                          │
│  ✅ Contrôle :                           │
│     - Console (cl_console.c)             │
│     - Demo record/playback (cl_main.c)   │
│     - Screenshots (cl_keys.c)            │
│     - Screen rendering (cl_scrn.c)       │
│     - Sound system (snd_*.c)             │
│     - Input (cl_input.c, cl_keys.c)     │
│     - Network parsing (cl_parse.c)       │
│     - Snapshot data (cl.snap.ps.*)       │
│                                          │
│  🔶 Accès limité :                       │
│     - Events mod-spécifiques (non doc)   │
│     - cgame syscall hook (cl_cgame.c)    │
├─────────────────────────────────────────┤
│            CGAME QVM (mod UrT)           │
│  (code fermé / binaire .qvm)             │
│                                          │
│  Contrôle exclusif :                     │
│     - HUD rendering (crosshair, score)   │
│     - Hit detection visuelle             │
│     - Weapon viewmodels                  │
│     - Menu system                        │
│     - Game event interpretation           │
└─────────────────────────────────────────┘
```

**Stratégie recommandée** : Pour les features 🔶 (overlay), implémenter un système d'**overlay engine-side post-cgame** qui se dessine après le rendu du mod. Cela permet d'ajouter des éléments visuels (netgraph, strafe helper, ammo counter) sans modifier le cgame QVM.