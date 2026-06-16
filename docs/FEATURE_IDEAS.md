# 💡 Feature Ideas — Urban Terror Optimized

> **Brainstorming document** — propositions de features/modifications classées par
> audience et par priorité. **Contrainte absolue** : compatibilité binaire avec les
> clients et serveurs legacy (pas de changement du protocole réseau
> `entityState_t` / `playerState_t` / `msg_t`, pas de nouveaux opcodes, pas de
> modification des indices de configstrings utilisés par le mod).

**Règle d'or** : tout ce qui passe par **userinfo** (clé-valeur texte),
**servercommands** (`SV_SendServerCommand` = texte), **configstrings** non-utilisées,
ou **commandes console** est « gratuit » en termes de compatibilité.

---

## 📋 Table des matières

- [🎮 Joueurs (client-side, zéro impact serveur)](#-joueurs-client-side-zéro-impact-serveur)
- [🛡️ Admins Serveur (cvars + commandes, zéro protocole)](#-admins-serveur-cvars--commandes-zéro-protocole)
- [🔧 Développeurs (outillage engine + debugging)](#-développeurs-outillage-engine--debugging)
- [🌐 Multimédia & Rendu](#-multimédia--rendu)
- [🌟 Idées créatives / Bonus](#-idées-créatives--bonus)
- [📊 Tableau récapitulatif prioritaire](#-tableau-récapitulatif-prioritaire)
- [🔗 Idées issues de l'exploration du code](#-idées-issues-de-lexploration-du-code)
- [🎮 Joueurs — Extensions avancées](#-joueurs--extensions-avancées)
- [🔧 Développeurs — Extensions avancées](#-développeurs--extensions-avancées)


## 🎮 Joueurs (client-side, zéro impact serveur)

### 1. Système d'identités / profils incognito (identity switching)
- **Cas d'usage** : un joueur veut se connecter sous différentes identités (nom, apparence, binds textuels, tags de clan) sans tout reconfigurer à chaque fois
- **Différence avec `exec`** : `exec` charge TOUT (cvars graphiques, réseau, etc.), ce qui écrase les réglages courants. Une identité ne charge que ce qui relève de l'identité : nom, modèle/skin, binds de chat, coloration de nom, tag de clan
- **Cvars** : `cl_identity` (nom du profil actif, chargé au démarrage via `autoexec.cfg`)
- **Commandes** : `saveidentity <name>` (sauvegarde sélective : `name`, `model`, `headmodel`, `team_model`, `team_headmodel`, `clan`, binds `say`/`say_team`), `loadidentity <name>`, `listidentities`
- **Fichiers** : stockés dans `identities/<name>.cfg` — format .cfg standard mais ne contenant que les cvars/binds d'identité
- **Sélectivité** : `saveidentity` ne sauve que l'identité, pas les réglages graphiques/réseau → peut être chargé sans casser la config de jeu
- **Bonus** : `name_rotate` — cycle automatique parmi une liste de noms à chaque connexion (anti-tracking)
- **Difficulté** : Facile — `writeconfig` sélectif + chargement via `exec` sur un sous-ensemble de cvars
- **Compat** : ✅ 100% local (les cvars d'identité transitent par userinfo, déjà géré par les serveurs legacy)

### 2. Démo avancée : timeline + bookmarks + vitesses
- Barre de timeline scrubbable, bookmarks nommés (jump-to), presets de vitesse (0.25x/0.5x/2x/4x)
- **Cvars/Commandes** : `demo_bookmark <name>`, `demo_goto <name|time>`, `demo_speed <0.1-10>`
- **Difficulté** : Moyenne — le code demo existe (`cl_main.c`, `cl_parse.c`), il faut ajouter l'UI timeline
- **Compat** : ✅ Lecture locale du fichier `.dm_*`

### 3. Indicateurs de dégâts directionnels
- Flèches/arcs rouges autour du crosshair indiquant la direction d'où on prend des dégâts
- Les events de dégâts (`EV_PAIN`, `EV_DAMAGE` selon le mod) sont **déjà** dans les snapshots — purement rendu client
- **Cvar** : `cg_damageIndicator` (on/off/opacity/duration/style)
- **Difficulté** : Facile — parsing d'events existants + rendu 2D
- **Compat** : ✅ Rendu uniquement

### 4. Scoreboard enrichi (stats étendues)
- Afficher accuracy par arme, killstreak actuel, hits/headshots (si le mod expose les données via configstrings ou servercommands)
- Même sans données serveur : calculer localement le K/D ratio, streaks, temps de survie, meilleurs fragments
- **Cvars** : `cg_scoreboardStats` (on/off), `cg_scoreboardFormat` (classic/compact/extended)
- **Difficulté** : Facile — les données de base (frags/deaths/ping/score) sont déjà dans les snapshots
- **Compat** : ✅ Calcul local

### 5. Crosshair dynamique personnalisable
- Crosshair qui s'élargit selon le mouvement (strafe/marche/saut) via prédiction client
- Plus de types de crosshair, couleur RGB custom avec alpha, hitmarker (flash couleur quand on touche)
- **Cvars** : `cg_crosshairDynamic`, `cg_crosshairColor` (hex RGB), `cg_crosshairHitMarker`
- **Difficulté** : Facile — la prédiction de mouvement existe côté client
- **Compat** : ✅ Rendu + prédiction locale

### 6. Enregistrement auto-démo intelligent
- Auto-start demo au début d'un match/round, auto-stop à la fin
- Auto-prune : garder les N dernières démos, supprimer les plus anciennes
- **Note** : `cl_autoRecordDemo` existe déjà (binaire on/off), il faut ajouter le pruning et les triggers intelligents
- **Cvars** : `cl_autoDemoKeep` (nombre à conserver), `cl_autoDemoMinSize` (supprimer les démos < N KB, probablement vides)
- **Difficulté** : Facile
- **Compat** : ✅ Local

### 7. Overlay qualité de connexion (latency graph)
- Mini-graphe temps réel du ping et packet loss sur N secondes (données déjà dans `cl.snap.ping`)
- Indicateur visuel de jitter (variation de ping), chute de packets
- **Cvar** : `cg_netgraph` (off/text/graph/both), `cg_netgraphTime` (fenêtre en secondes)
- **Difficulté** : Très facile
- **Compat** : ✅ Données client existantes

### 8. Screenshot manager étendu
- Screenshots en PNG (le code JPEG existe déjà, ajout PNG), organisés par date/map
- Mode "clean screenshot" : capture sans HUD/crosshair (`cg_draw2D 0` temporaire pendant la capture)
- Série de screenshots (burst mode) pour stop-motion
- **Cvars** : `cl_screenshotFormat` (jpg/png/tga), `cl_screenshotQuality`, `cl_screenshotClean`
- **Difficulté** : Facile
- **Compat** : ✅ Local

### 9. Système de favoris serveurs / historique étendu
- Marquer des serveurs comme favoris, trier par historique de connexion
- Tags personnalisables sur les serveurs ("training", "competitive", etc.)
- Auto-reconnect intelligent avec backoff exponentiel
- **Cvars** : `cl_autoReconnect` (on/off), `cl_autoReconnectDelay`
- **Difficulté** : Facile — étendre le browser existant
- **Compat** : ✅ Local (le browser utilise déjà le protocole `getstatus`/`getinfo`)

### 10. Coloration syntaxique console
- Les cvars en couleur A, les commandes en couleur B, les timestamps en gris, les erreurs en rouge
- Recherche/filtrage dans l'historique de console (Ctrl+F)
- **Cvars** : `con_colorize` (on/off), `con_searchHighlight`
- **Difficulté** : Facile — le système de couleur `^1`-`^7` existe déjà, la console à onglets est déjà là
- **Compat** : ✅ Local

### 11. Hitmarker visuel et sonore
- Flash du crosshair + son court quand on touche un ennemi (détection via events réseau existants)
- Différenciation headshot/bodyshot si le mod l'expose
- **Cvars** : `cg_hitMarker` (on/off), `cg_hitMarkerColor`, `cg_hitMarkerSound`
- **Difficulté** : Très facile
- **Compat** : ✅ Events réseau existants

### 12. Compteur de munitions flottant (floating ammo HUD)
- Affichage discret du compteur de munitions près du crosshair plutôt qu'au coin de l'écran
- **Cvars** : `cg_floatingAmmo` (on/off), `cg_floatingAmmoPosition`
- **Difficulté** : Facile
- **Compat** : ✅ Local

### 13. killstreak / multikill tracker visuel
- Notification animée quand on enchaîne les kills (double kill, triple kill, etc.)
- Timer visible du streak actuel, record de la session
- **Cvars** : `cg_killstreakNotify`, `cg_killstreakSound`
- **Difficulté** : Facile — tracker local basé sur les events de frag
- **Compat** : ✅ Local

### 14. Spectateur : free-cam amélioré
- Mode free-cam avec vitesse ajustable, interpolation fluide entre points d'observation
- Bookmark de positions de caméra pour revoir une scène sous un angle précis
- **Cvars** : `cg_specCamSpeed`, `cg_specCamInterp`
- **Difficulté** : Moyenne
- **Compat** : ✅ Local (spectateur utilise déjà les snapshots)

---

## 🛡️ Admins Serveur (cvars + commandes, zéro protocole)

### 15. Bans temporaires + ban par GUID
- Extension du système de ban existant (`serverBans[]` dans `server.h`) avec durée d'expiration
- `banaddr <IP> <minutes> <reason>` → ban temporaire auto-expirable
- Ban par `cl_guid` (déjà transmis dans userinfo) en plus de l'IP
- **Commandes** : `banguid <guid> <minutes> <reason>`, `listbans` (avec colonne "expires")
- **Difficulté** : Moyenne — étend `sv_ccmds.c` + structures existantes, le GUID est déjà dans userinfo
- **Compat** : ✅ Le GUID est déjà transporté

### 16. Commandes programmées / cron serveur
- Système de scheduled commands : `sv_cron "*/30 * * * * say Need players? Join our Discord!"`
- Messages récurrents (annonces), map rotation automatique à heures fixes
- **Cvars** : `sv_cronFile` (chemin fichier de règles cron)
- **Difficulté** : Facile — timer dans la boucle serveur (`SV_Frame`), exécution via `Cbuf_AddText`
- **Compat** : ✅ Local au serveur

### 17. Audit log RCON
- Toutes les commandes RCON journalisées dans un fichier avec timestamp, IP source, commande complète
- **Cvars** : `sv_rconLog` (chemin du fichier), `sv_rconLogRotate` (taille max avant rotation)
- **Difficulté** : Très facile — interception dans le handler RCON existant
- **Valeur sécurité** : Élevée — détection d'abus, forensic
- **Compat** : ✅ Local au serveur

### 18. Gestion AFK automatique
- `sv_afkTime` (secondes) — auto-kick ou auto-spectate les joueurs sans input
- `sv_afkAction` (kick/spectate/spec-then-kick), `sv_afkWarning` (avertir N secondes avant)
- **Difficulté** : Facile — tracker `lastUsercmd` dans `SV_ClientThink`
- **Compat** : ✅ Le serveur a déjà accès aux usercmds

### 19. Status JSON export (pour bots/tools web)
- Commande `statusjson` qui output le status serveur en JSON (`json.h` existe déjà dans qcommon !)
- Permet l'intégration avec Discord bots, panneaux web, monitoring (Grafana, Prometheus, etc.)
- Endpoint status HTTP léger (polling)
- **Commandes** : `statusjson`, `playerlistjson`
- **Difficulté** : Facile — formater les données de `SV_Status_f` en JSON
- **Compat** : ✅ Aucun changement de protocole de jeu

### 20. Limite de ping dynamique
- `sv_maxPing` — kick automatique des joueurs dont le ping dépasse X ms de manière soutenue (pas un spike isolé)
- `sv_maxPingWarnings` (nombre d'avertissements avant kick), `sv_pingGracePeriod` (période d'échantillonnage)
- **Difficulté** : Facile — `client->ping` est déjà tracké
- **Compat** : ✅ Données serveur existantes

### 21. Système de ready-up / warmup compétitif
- `sv_readyup 1` — mode où le match ne commence que quand tous les joueurs sont "ready"
- Implémenté via userinfo key `ready` (déjà transportable) ou via servercommand texte
- **Cvars** : `sv_readyup` (on/off), `sv_readyupMinReady` (pourcentage requis), `sv_readyupTimeout`
- **Difficulté** : Moyenne — gestion d'état côté serveur
- **Compat** : ✅ Via userinfo key ou servercommand

### 22. Rate limiting RCON renforcé + anti-bruteforce
- Le code a déjà `rateLimit_t` et `leakyBucket_t` — étendre avec un compteur de tentatives RCON échouées
- Bannir temporairement les IPs qui brute-forcent le mot de passe RCON
- **Cvars** : `sv_rconMaxAttempts`, `sv_rconBanTime` (ban temporaire en minutes)
- **Difficulté** : Facile — réutiliser l'infrastructure de rate limiting existante
- **Compat** : ✅ Local au serveur

### 23. Mute/Silence système
- `mute <player>` / `unmute <player>` — empêche un joueur de parler (chat), avec durée optionnelle
- `sv_muteList` persistant (par GUID ou IP)
- **Difficulté** : Facile — filtrage côté serveur dans le handler de chat
- **Compat** : ✅ Filtrage des commandes texte existantes

### 24. Map vote / RTV (Rock The Vote) natif
- Système de vote de map intégré au serveur (sans dépendre du mod)
- `rtv` (rock the vote), `votemap <mapname>`, `vote <yes|no>`
- **Cvars** : `sv_mapvote` (on/off), `sv_mapvoteRatio` (0.5 = majorité), `sv_mapvoteTime`
- **Difficulté** : Moyenne — gestion de vote + communication via servercommands
- **Compat** : ✅ Via servercommands texte

### 25. Motd personnalisé et enrichi
- Message of the Day configurable avec support multi-lignes, couleurs, variables dynamiques
- Affichage automatique à la connexion et optionnellement périodique
- **Cvars** : `sv_motdFile` (chemin), `sv_motdInterval` (0 = seulement à la connexion)
- **Difficulté** : Très facile
- **Compat** : ✅ Via servercommands

### 26. Whitelist de mods / checksums
- `sv_modWhitelist` — n'accepter que les mods avec des checksums spécifiques (anti-cheat léger)
- **Cvars** : `sv_modWhitelistFile`
- **Difficulté** : Moyenne — étendre le système de pure/pakcheck existant
- **Compat** : ✅ Le système de checksum existe déjà

### 27. Auto-équilibrage des équipes
- `sv_autoBalance 1` — répartir automatiquement les joueurs entre équipes
- Options : équilibrer par nombre, par skill (score/K-D ratio), au prochain spawn
- **Cvars** : `sv_autoBalanceMode` (count/score/kd), `sv_autoBalanceThreshold` (différence max tolérée)
- **Difficulté** : Moyenne — intervention dans la logique de team (doit coopérer avec le mod via userinfo/forceskin)
- **Compat** : ⚠️ Dépend de la coopération du mod (userinfo `team` key)

### 28. Serveur : backup et rotation de logs automatique
- Rotation automatique des fichiers de log serveur par taille ou par jour
- **Cvars** : `sv_logRotateSize`, `sv_logKeepDays`
- **Difficulté** : Facile
- **Compat** : ✅ Local

---

## 🔧 Développeurs (outillage engine + debugging)

### 29. Profiler intégré (frame timing breakdown)
- **Cvar** : `com_profiler` (0=off, 1=console, 2=CSV file, 3=on-screen overlay)
- Dump par frame le temps passé en : renderer, game logic (VM), network, sound, filesystem
- Identifier les bottlenecks en temps réel
- **Difficulté** : Facile — wrappers de timer autour des sections existantes dans `Com_Frame`
- **Compat** : ✅ Outil de développement

### 30. Logger de trafic réseau (protocol debugger)
- `cl_netlog` / `sv_netlog` : dump de tout le trafic réseau dans un fichier avec timestamps
- Format pcap-compatible pour analyse avec Wireshark
- Invaluable pour debug de protocole, reverse engineering de mods, optimisation
- **Cvars** : `cl_netLog` (chemin), `sv_netLog` (chemin)
- **Difficulté** : Facile — wrapper dans `NET_Transport` / netchan
- **Compat** : ✅ Passif

### 31. Hot-reload de VM (développement)
- Commande `vm_reload` qui recharge le QVM (`.qvm`) sans redémarrer le serveur
- Gain de temps énorme pour le développement de mods/game logic
- **Note** : `VM_Restart` / `SV_RestartGameProgs` existe déjà, il faut gérer la préservation d'état minimale
- **Difficulté** : Moyenne
- **Compat** : ✅ Outil dev

### 32. Tracking mémoire détaillé (leak detection)
- `mem_stats` : breakdown de l'usage hunk/zone par tag, détection de fuites au shutdown
- Compteur d'allocations par type/source, histogramme des tailles
- **Commandes** : `mem_stats`, `mem_dump`, `mem_trace` (en mode debug)
- **Difficulté** : Facile — wrapper `Z_Malloc`/`Hunk_Alloc` avec metadata
- **Compat** : ✅ Outil dev

### 33. Overlay de debug enrichi (`developer 2/3`)
- `developer 2` : entity counts, temps frame, usage réseau, mémoire, events count
- `developer 3` : tous les events, traces de snapshots, configstring changes
- **Difficulté** : Très facile — étendre le système de print existant
- **Compat** : ✅ Outil dev

### 34. Watch de cvars (surveillance temps réel)
- `cvar_watch <name>` — affiche en console chaque fois que la cvar change, avec ancienne/nouvelle valeur et stack trace si possible
- **Difficulté** : Facile
- **Compat** : ✅ Local

### 35. Génération de documentation automatique des cvars
- Commande `cvar_dumpmd` qui génère un fichier Markdown listant toutes les cvars avec leur description, valeur par défaut, flags
- **Note** : le système de `Cvar_SetDescription` existe déjà !
- **Difficulté** : Très facile
- **Compat** : ✅ Local

### 36. Valgrind/ASan-friendly mode
- Mode compilation et runtime qui désactive les optimisations dangereuses pour les sanitizers (déjà partiellement fait avec ASan en CI)
- Cvar de runtime pour forcer l'alignment padding, vérifier les bornes
- **Difficulté** : Facile (déjà couvert par CI ASan/UBSan)
- **Compat** : ✅ Dev

---

## 🌐 Multimédia & Rendu

### 37. Capture vidéo avec overlays (HUD dans l'AVI)
- Actuellement l'AVI capture la frame raw sans HUD post-processing — permettre d'inclure le HUD
- **Cvars** : `cl_aviCaptureHUD` (on/off)
- **Difficulté** : Facile — modifier la chaîne de capture dans `cl_avi.c`
- **Compat** : ✅ Local

### 38. Mode observer "cinématique"
- Rendering cinématique en spectateur : depth of field, motion blur, letterbox, film grain
- Idéal pour créer des vidéos/machinima
- **Cvars** : `r_cinematicMode`, `r_cinematicDOF`, `r_cinematicGrain`
- **Difficulté** : Moyenne — shaders additionnels dans le renderer
- **Compat** : ✅ Local (renderer Vulkan/OpenGL existe déjà)

### 39. Support audio étendu (FLAC, WAV 24-bit)
- Ajout de décodeurs FLAC en plus d'Ogg Vorbis (le système `snd_codec` est modulaire)
- Support WAV 24-bit/32-bit float pour qualité audio maximale
- **Difficulté** : Moyenne — nouveau codec dans le système existant
- **Compat** : ✅ Local

### 40. Audio : HRTF / spatialisation 3D
- Rendu audio binaural (HRTF) pour un positionnement 3D plus immersif avec casque
- **Cvars** : `s_hrtf` (on/off), `s_hrtfProfile`
- **Difficulté** : Difficile — nécessite un backend audio avancé (OpenAL ou implémentation HRTF)
- **Compat** : ✅ Local

### 41. Replay buffer (shadow recording)
- Enregistrer en continu les N dernières secondes en mémoire, sauvegarder à la demande (style ShadowPlay/OBS replay buffer)
- **Cvars** : `cl_replayBuffer` (secondes), `cl_replaySave` (commande pour dump)
- **Difficulté** : Difficile — buffering mémoire + encodage à la volée
- **Compat** : ✅ Local

### 42. HDR rendering / tone mapping
- Pipeline HDR avec tone mapping pour un rendu plus réaliste (surtout utile avec le renderer Vulkan)
- **Cvars** : `r_hdr` (on/off), `r_toneMappingExposure`, `r_toneMappingMode`
- **Difficulté** : Difficile — pipeline renderer
- **Compat** : ✅ Local

### 43. Upscaling / FSR / DLSS-like
- Pour les configs low-end : upscaling FSR (FidelityFX Super Resolution) intégré
- **Cvars** : `r_upscaleMode` (off/fsr/fsr2), `r_upscaleQuality`
- **Difficulté** : Difficile — shaders avancés
- **Compat** : ✅ Local

---

## 🌟 Idées créatives / Bonus

### 44. Scripting Lua côté serveur (plugin system)
- Hook Lua sur les events serveur (connect, disconnect, frag, chat, command, mapchange)
- Permet aux admins de customiser le gameplay sans modifier le QVM ni casser le protocole
- Exemples : auto-messages custom, règles anti-spam, mini-jeux, economy systems, stats logging
- **Cvars** : `sv_luaPlugins` (répertoire), `sv_luaDebug` (verbose)
- **Difficulté** : Moyenne-Difficile — intégrer un runtime Lua, mais très forte valeur pour la communauté
- **Compat** : ✅ Si les hooks n'altèrent pas le protocole

### 45. Spectator delay (anti-ghosting compétitif)
- `sv_specDelay` : les spectateurs voient le jeu avec N secondes de délai
- Empêche le ghosting (spectateur qui donne l'info de position aux joueurs en vocal)
- Implémenté en bufferisant les snapshots côté serveur pour les clients spectateurs
- **Note** : le système de snapshot storage existe déjà (`snapFrames[]`), il faut un mode delayed pour les specs
- **Difficulté** : Moyenne
- **Compat** : ✅ Le serveur garde déjà des frames en mémoire

### 46. Vote map pondéré / statistiques de maps
- Tracker les votes par map, générer une rotation pondérée par les préférences des joueurs
- `mapstats` command pour voir les maps les plus/moins jouées, win rates par équipe
- **Cvars** : `sv_mapStatsFile` (persistance), `sv_weightedRotation` (on/off)
- **Difficulté** : Facile — logging + logique de rotation
- **Compat** : ✅ Local serveur

### 47. Discord webhook integration
- Envoyer des notifications Discord via webhook : match start/end, admin actions, player counts milestones
- **Cvars** : `sv_discordWebhook`, `sv_discordEvents` (quels events notifier)
- **Difficulté** : Moyenne — HTTP POST avec libcurl (déjà vendored !)
- **Compat** : ✅ Sortant uniquement

### 48. Demo to video batch converter
- Commande `demo2avi <demoname>` / `demo2png` qui convertit une démo en vidéo/images automatiquement
- Mode headless (sans affichage) pour conversion serveur/CI
- **Cvars** : `cl_batchConvertFps`, `cl_batchConvertFormat`
- **Difficulté** : Moyenne — orchestration du playback + capture
- **Compat** : ✅ Local

### 49. Anti-cheat : screenshots automatiques
- Côté serveur : demander des screenshots aléatoires aux clients et les recevoir (si le client implémente l'upload)
- **Note** : nécessite coopération client, donc principalement pour les clients « optimized »
- **Commandes** : `sv_requestScreenshot <player>`, `sv_autoScreenshotChance`
- **Difficulté** : Moyenne — channel d'upload (utilise le download channel inversé ?)
- **Compat** : ⚠️ Nécessite client compatible (mais les clients legacy ignorent la demande)

### 50. Client : skin/customization étendu (client-side only)
- Override local des textures/models pour personnalisation visuelle (uniquement vu par le joueur local)
- **Cvars** : `cg_customSkins` (on/off), `cg_skinPath`
- **Difficulté** : Moyenne
- **Compat** : ✅ Local (override de fichiers)

### 51. Serveur : modes de jeu custom via VM hooks
- Hooks côté serveur pour modifier des règles sans changer le QVM : respawn time, weapon restrictions, damage multipliers
- Implémenté via le système Lua (#44) ou via cvars dédiées qui sont lues par le mod
- **Cvars** : `sv_damageMultiplier`, `sv_respawnTime`, `sv_weaponRestrictions`
- **Difficulté** : Variable selon l'approche
- **Compat** : ⚠️ Les cvars doivent être lues par le mod

### 52. Client : rich presence (Discord GameSDK)
- Afficher le statut de jeu dans Discord ("Playing Urban Terror on map X")
- **Cvars** : `cl_discordRPC` (on/off)
- **Difficulté** : Moyenne — intégration Discord SDK
- **Compat** : ✅ Local

### 53. Serveur : géofencing par TLD
- Le système de TLD existe déjà (`sv_clientTLD`, `client->tld`, `client->country`)
- Restreindre l'accès par pays : `sv_countryWhitelist` / `sv_countryBlacklist`
- **Difficulté** : Facile — étendre le filtrage existant (`sv_filter.c`)
- **Compat** : ✅ L'infrastructure TLD est déjà là

### 54. Client : FPS limiter intelligent
- Limiteur de FPS adaptatif pour réduire l'usage GPU/CPU sans tearing
- **Note** : VSync existe, mais un FPS cap logiciel est plus réactif
- **Cvars** : `r_maxFPS` (0 = illimité), `r_maxFPSMode` (sleep/busy)
- **Difficulté** : Facile
- **Compat** : ✅ Local

### 55. Client : raccourcis clavier configurables (macros)
- Système de macros : une touche qui exécute une séquence de commandes
- **Commandes** : `bindmacro <key> <name>`, `macro <name> cmd1; cmd2; cmd3`
- **Cvars** : `cl_macroFile` (persistance)
- **Difficulté** : Facile — étendre le système de bind
- **Compat** : ✅ Local

---

## 📊 Tableau récapitulatif prioritaire

| # | Feature | Audience | Difficulté | Impact | Compat legacy |
|---|---------|----------|------------|--------|---------------|
| 15 | Bans temporaires + GUID | Admins | Moyenne | Élevé | ✅ |
| 17 | Audit log RCON | Admins | Très facile | Élevé (sécurité) | ✅ |
| 19 | Status JSON export | Admins/Devs | Facile | Élevé | ✅ |
| 3 | Indicateurs dégâts directionnels | Joueurs | Facile | Moyen | ✅ |
| 5 | Crosshair dynamique + hitmarker | Joueurs | Facile | Moyen | ✅ |
| 6 | Auto-demo intelligent | Joueurs | Facile | Moyen | ✅ |
| 29 | Profiler intégré | Devs | Facile | Élevé | ✅ |
| 18 | Gestion AFK | Admins | Facile | Moyen | ✅ |
| 1 | Profils de config | Joueurs | Très facile | Moyen | ✅ |
| 44 | Scripting Lua serveur | Admins/Devs | Difficile | Très élevé | ✅ |
| 47 | Discord webhook | Admins | Moyenne | Élevé | ✅ |
| 24 | Map vote / RTV natif | Admins/Joueurs | Moyenne | Élevé | ✅ |
| 30 | Logger trafic réseau | Devs | Facile | Élevé | ✅ |
| 45 | Spectator delay | Compétitif | Moyenne | Moyen | ✅ |
| 7 | Netgraph overlay | Joueurs | Très facile | Faible | ✅ |
| 11 | Hitmarker visuel/sonore | Joueurs | Très facile | Moyen | ✅ |
| 13 | Killstreak tracker | Joueurs | Facile | Faible | ✅ |
| 16 | Commandes cron serveur | Admins | Facile | Moyen | ✅ |
| 22 | Anti-bruteforce RCON | Admins | Facile | Élevé (sécurité) | ✅ |
| 35 | Doc auto cvars | Devs | Très facile | Moyen | ✅ |
| 53 | Géofencing par TLD | Admins | Facile | Moyen | ✅ |
| 41 | Replay buffer | Joueurs/Créateurs | Difficile | Élevé | ✅ |
| 48 | Demo→video batch | Créateurs | Moyenne | Moyen | ✅ |
| 52 | Rich presence Discord | Joueurs | Moyenne | Faible | ✅ |
| 27 | Auto-équilibrage équipes | Admins | Moyenne | Moyen | ⚠️ |
| 10 | Filtrage/recherche console | Joueurs | Facile | Faible | ✅ |
| 34 | Cvar watch | Devs | Facile | Moyen | ✅ |
| 54 | FPS limiter | Joueurs | Facile | Faible | ✅ |
| 38 | Mode cinématique spectateur | Créateurs | Moyenne | Faible | ✅ |

---

## 🔗 Idées issues de l'exploration du code

Ces idées sont dérivées directement de l'analyse du code source existant :

### 56. Étendre `cl_autoRecordDemo` (existant) avec triggers intelligents
- **Source** : `cl_main.c` a déjà `cl_autoRecordDemo` (on/off) — l'étendre avec déclenchement par event (match start, round start)
- **Cvars à ajouter** : `cl_autoDemoTrigger` (connect/match/round/manual), `cl_autoDemoNaming` (date/map/server)

### 57. Étendre le pipeline vidéo `cl_aviPipeFormat` (existant)
- **Source** : `cl_avi.c` supporte déjà le piping vers ffmpeg — ajouter des presets (youtube, twitch, archive)
- **Cvars** : `cl_aviPreset` (youtube4k/youtube1080/twitch/archive)

### 58. Étendre le système de filtre serveur (`sv_filter.c`)
- **Source** : `sv_filter.c` existe déjà avec `SV_LoadFilters` / `SV_RunFilters` — l'enrichir avec plus de conditions
- Filtres par : pays (TLD), GUID, version client, heure de connexion, charge serveur

### 59. Étendre le rate limiting (`rateLimit_t` / `leakyBucket_t`)
- **Source** : structures existantes dans `server.h` — les rendre configurables dynamiquement
- **Cvars** : `sv_rateLimitConnect`, `sv_rateLimitInfo`, `sv_rateLimitGamestate`

### 60. Configstring browser / inspector (dev tool)
- **Source** : les configstrings sont centrales au protocole — un outil pour visualiser/toutes les CS en temps réel
- **Commande** : `cs_dump`, `cs_watch <index>`
- **Difficulté** : Très facile — `SV_GetConfigstring` existe déjà

### 61. Wrapper autour de `json.h` (déjà présent)
- **Source** : `code/qcommon/json.h` existe mais semble sous-utilisé — l'exploiter pour des exports structurés
- Applications : status JSON, config export, stats dump, debug info

### 62. Étendre le système de TLD/pays
- **Source** : `sv_clientTLD`, `client->tld`, `client->country`, `SV_PrintLocations_f` existent déjà
- Applications : géofencing (#53), affichage pays dans le scoreboard, statistiques géographiques

---

## Notes d'implémentation

### Contraintes de compatibilité (rappel)

| Élément | Modifiable ? | Note |
|---------|-------------|------|
| `entityState_t` / `playerState_t` | ❌ | Casserait tous les clients/serveurs |
| Opcodes réseau (`svc_*`, `clc_*`) | ❌ | Casserait le protocole |
| `msg_t` / `netchan_t` format | ❌ | Casserait le transport |
| Indices de configstrings utilisés | ❌ | Casserait le mod |
| **Userinfo keys** | ✅ | Ajouter des clés = ignorées par les legacy |
| **ServerCommands** (texte) | ✅ | Commandes inconnues = ignorées par les legacy |
| **Configstrings non-utilisées** | ✅ | Zones réservées/disponibles |
| **Cvars** | ✅ | Nouvelles cvars = ignorées par les legacy |
| **Commandes console** | ✅ | Commandes inconnues = ignorées |

### Zones du code à toucher par type de feature

| Type de feature | Fichiers principaux |
|----------------|-------------------|
| Client HUD/rendu | `code/client/cl_scrn.c`, `code/client/cl_cgame.c`, cgame VM |
| Client input | `code/client/cl_input.c`, `code/client/cl_keys.c` |
| Client demo | `code/client/cl_main.c`, `code/client/cl_parse.c`, `code/client/cl_avi.c` |
| Client console | `code/client/cl_console.c` |
| Serveur admin | `code/server/sv_ccmds.c`, `code/server/sv_client.c`, `code/server/sv_main.c` |
| Serveur réseau | `code/server/sv_net_chan.c`, `code/server/sv_snapshot.c` |
| Serveur bans/filtres | `code/server/sv_ccmds.c`, `code/server/sv_filter.c` |
| Développement/debug | `code/qcommon/common.c`, `code/qcommon/cvar.c`, `code/qcommon/files.c` |

---

## 🤖 Bots & AI

### 63. Gestion dynamique de bots (auto-fill)
- Maintenir automatiquement un nombre minimum de joueurs (`bot_minplayers` existe déjà !)
- Étendre avec : difficulty progressive (les bots s'adaptent au niveau moyen des humains), rotation de bots (pas toujours les mêmes noms/personnalités)
- **Cvars** : `bot_autoDifficulty` (on/off), `bot_difficultyWindow` (nombre de frags pour recalculer), `bot_namePool` (fichier de noms custom)
- **Difficulté** : Facile — `bot_minplayers` existe, étendre la logique
- **Compat** : ✅ Local serveur

### 64. Bot profiling et personnalités
- Le botlib supporte déjà les "characters" (`be_ai_char.c`) — créer des profils de personnalités UrT-spécifiques
- Bots avec styles distincts : rusher, camper, sniper, support
- **Cvars** : `bot_personalityMode` (random/balanced/custom)
- **Difficulté** : Facile — étendre le système de characters existant
- **Compat** : ✅ Local

### 65. Bot waypoints/AAS visualisation temps réel (dev tool)
- Overlay visuel du maillage AAS, reachabilities, zones navigables
- `bot_debug` / `bot_reachability` existent déjà — les rendre plus accessibles aux mappeurs
- **Cvars** : `bot_debugOverlay` (on/off/transparent), `bot_debugArea` (highlight une zone)
- **Difficulté** : Facile — étendre le debug draw existant
- **Compat** : ✅ Dev

### 66. Waypoint editor intégré pour mappeurs
- Éditeur visuel pour créer/modifier des waypoints AAS directement en jeu
- Sauvegarde/chargement de fichiers `.aas` depuis l'éditeur
- **Difficulté** : Difficile — éditeur visuel complet
- **Compat** : ✅ Dev (outil de mapping)

---

## 🔊 Voix / Communication

### 67. VoIP intégré (opus codec)
- **Note technique** : Les opcodes `svc_voipOpus` / `clc_voipOpus` sont **déjà réservés** dans `qcommon.h` (commentés "ioq3 extension") ! Le protocole a déjà la place pour le VoIP.
- Implémentation : encoder/decoder Opus (libopus), capture microphone via SDL, transmission via le channel existant
- **Cvars** : `cl_voip` (on/off), `cl_voipSend`, `cl_voipGain`, `cl_voipShowMeter`
- **Difficulté** : Difficile — intégration codec + capture audio + UI
- **Compat** : ✅ Les opcodes sont réservés, les clients legacy ignorent les packets VoIP

### 68. Chat vocaux presets (voice commands)
- Système de voice chats pré-enregistrés (radio commands) : "Enemy spotted!", "Need backup!", etc.
- Déclenchement par binds clavier, transmission via servercommands (texte) ou VoIP (audio)
- **Cvars** : `cg_voiceChats` (on/off), `cg_voiceChatVolume`
- **Difficulté** : Facile (presets audio) à Difficile (si couplé au VoIP)
- **Compat** : ✅ Via servercommands texte pour la version simple

### 69. Text-to-speech pour les messages chat
- Lecture vocale des messages chat (accessibilité, ou pour les spectateurs AFK)
- **Cvars** : `cg_tts` (on/off), `cg_ttsVoice`, `cg_ttsFilter` (all/team/partial)
- **Difficulté** : Moyenne — intégration d'un moteur TTS (espeak, flite)
- **Compat** : ✅ Local

---

## ♿ Accessibilité

### 70. Mode daltonien (colorblind mode)
- Recolorer les indicateurs de jeu qui dépendent de la couleur (équipe rouge/bleue, indicateurs de dégâts, HUD)
- Palettes alternatives : protanopie, deutéranopie, tritanopie
- **Cvars** : `cg_colorblindMode` (off/protanopia/deuteranopia/tritanopia), `cg_colorblindEnemy`, `cg_colorblindFriendly`
- **Difficulté** : Facile — recoloration des éléments de HUD
- **Compat** : ✅ Local

### 71. Sous-titres pour les événements sonores
- Afficher du texte pour les sons importants : pas de sprint, recharge, grenade, hitmarker sonore
- Essentiel pour les joueurs malentendants
- **Cvars** : `cg_subtitles` (off/events/all), `cg_subtitleSize`, `cg_subtitleDuration`
- **Difficulté** : Facile — mapping son→texte + rendu
- **Compat** : ✅ Local

### 72. Échelles de UI ajustables (scalabilité)
- Permettre d'agrandir/réduire tous les éléments de HUD indépendamment
- **Cvars** : `cg_hudScale` (global), `cg_crosshairScale`, `cg_scoreboardScale`, `cg_fontScale`
- **Difficulté** : Facile — multiplier les dimensions de rendu
- **Compat** : ✅ Local

### 73. Mode high-contrast
- Augmenter le contraste du HUD, crosshair, texte pour une meilleure lisibilité
- **Cvars** : `cg_highContrast` (on/off), `cg_contrastLevel`
- **Difficulté** : Très facile
- **Compat** : ✅ Local

### 74. Keybinds remapping universel (controller/souris étendu)
- Support complet des manettes (controllers) avec remapping complet
- Deadzone ajustable pour les sticks, sensibilité ADS (aim-down-sights) séparée
- **Cvars** : `in_controllerMode`, `in_stickDeadzone`, `in_aimSensitivityADS`
- **Difficulté** : Moyenne — SDL2 supporte déjà les controllers
- **Compat** : ✅ Local

---

## 🏆 Compétitif / Match

### 75. Demo POV auto par joueur (tournament mode)
- En mode tournoi (`sv_tournament 1`), chaque joueur enregistre automatiquement sa POV
- Serveur peut demander/collecter les démos POV des joueurs via un channel de transfert
- **Cvars** : `sv_tournament`, `sv_collectPOV`
- **Difficulté** : Difficile (collecte serveur) / Facile (auto-record local)
- **Compat** : ⚠️ Collecte nécessite client compatible

### 76. Stats de match export (JSON/CSV)
- À la fin d'un match, générer un fichier de stats détaillé : kills, deaths, weapons utilisées, flags, temps par zone
- Format JSON pour intégration web, CSV pour tableurs
- **Commandes** : `exportmatchstats <filename>`
- **Cvars** : `sv_autoExportStats` (on/off), `sv_statsFormat` (json/csv)
- **Difficulté** : Facile — collecte des events + formatage
- **Compat** : ✅ Local serveur

### 77. Pause / timeout système
- Permettre aux équipes de demander un timeout/pause en match
- `sv_timeouts` (nombre de timeouts par équipe), `sv_timeoutDuration` (durée en secondes)
- Implémenté via servercommands texte + gel du game time
- **Difficulté** : Moyenne — coopération avec le mod (gel de `level.time`)
- **Compat** : ⚠️ Nécessite coopération mod pour le gel

### 78. Ready-up obligatoire en compétitif (extension du #21)
- Countdown synchronisé avant le début du match ("Match starts in 5...4...3...")
- Phase de warmup avec settings différenciés
- **Cvars** : `sv_matchCountdown`, `sv_warmupConfig`
- **Difficulté** : Facile — timer + servercommands
- **Compat** : ✅ Via servercommands

### 79. Save/restore de match state (pause/reprise longue)
- Sauvegarder l'état complet d'un match (positions, scores, timers) pour reprise ultérieure
- **Note** : très complexe car nécessite serialization de l'état game VM
- **Difficulté** : Très difficile
- **Compat** : ❌ Casserait probablement la compat (état VM)

---

## 🌍 Communauté & Social

### 80. Système d'amis (friends list)
- Tracker ses amis, voir quand ils sont en ligne et sur quel serveur
- **Cvars** : `cl_friendsList` (fichier)
- **Difficulté** : Moyenne — polling du master server + des serveurs
- **Compat** : ✅ Local (utilise le protocole existant)

### 81. Clans / tags automatiques
- Détection automatique des tags de clan dans les noms, colorisation
- Option pour afficher un préfixe d'équipe/clan dans le scoreboard
- **Cvars** : `cg_clanTagColor`, `cg_clanTagDetect`
- **Difficulté** : Facile
- **Compat** : ✅ Local

### 82. Replay sharing / highlight system
- Système pour marquer des moments dans une démo ("highlights") et les partager
- Les highlights sont des bookmarks timestampés dans le fichier démo
- **Cvars** : `demo_highlight`, `demo_exportHighlights`
- **Difficulté** : Facile (bookmarks) à Moyenne (export vidéo des highlights)
- **Compat** : ✅ Local

### 83. Wiki/aide intégrée (command reference)
- Commande `help <command>` qui affiche l'aide d'une commande ou cvar directement en jeu
- Base de données embarquée ou récupérée depuis le serveur
- **Difficulté** : Facile — `Cvar_SetDescription` existe déjà
- **Compat** : ✅ Local

### 84. Notification système (toasts)
- Notifications non-intrusives (toasts) pour les events : ami connecté, vote commencé, map change imminent
- **Cvars** : `cg_notifications` (on/off), `cg_notificationDuration`, `cg_notificationPosition`
- **Difficulté** : Facile — rendu 2D + gestion de queue
- **Compat** : ✅ Local

---

## ⚡ Performance & Optimisation

### 85. Préchargement de maps (prefetch)
- Précharger la map suivante en arrière-plan pendant que la map actuelle se termine
- Réduit le temps de chargement perçu lors des changements de map
- **Cvars** : `cl_mapPrefetch` (on/off)
- **Difficulté** : Difficile — gestion de cache et de thread
- **Compat** : ✅ Local

### 86. Texture streaming (LOD dynamique)
- Chargement/déchargement dynamique des textures selon la distance et la VRAM disponible
- Réduit l'usage VRAM sur les configs modestes
- **Cvars** : `r_textureStreaming` (on/off), `r_textureStreamingBudget`
- **Difficulté** : Difficile — pipeline renderer
- **Compat** : ✅ Local

### 87. Netcode : compression LZ4 des snapshots
- Compresser les snapshots serveur→client avec LZ4 (plus rapide que zlib)
- **Note** : changer la compression ne change pas le format des données, juste le transport
- **Cvars** : `sv_snapshotCompression` (off/zstd/lz4), `cl_snapshotCompression`
- **Difficulté** : Moyenne — wrapper compression
- **Compat** : ⚠️ Les clients legacy doivent gérer la nouvelle compression (négociation requise)

### 88. Cache de shaders compilés (Vulkan)
- Sauvegarder les SPIR-V compilés sur disque pour éviter la recompilation au démarrage
- **Cvars** : `r_shaderCache` (on/off), `r_shaderCachePath`
- **Difficulté** : Moyenne — spécifique au renderervk
- **Compat** : ✅ Local

### 89. Metrics Prometheus / monitoring endpoint
- Exposer des métriques serveur au format Prometheus pour monitoring (Grafana)
- **Note** : peut utiliser un mini-serveur HTTP ou un fichier texte périodique
- **Cvars** : `sv_metricsEnable`, `sv_metricsPort`
- **Difficulté** : Moyenne — endpoint HTTP + formatage
- **Compat** : ✅ Sortant uniquement

### 90. Client : adaptive quality (dynamic resolution)
- Réduire automatiquement la résolution de rendu quand les FPS chutent (maintien de FPS cible)
- **Cvars** : `r_adaptiveQuality` (on/off), `r_adaptiveTargetFPS`, `r_adaptiveMinScale`
- **Difficulté** : Moyenne — dynamique render scale
- **Compat** : ✅ Local

---

## 🔒 Sécurité & Anti-abus

### 91. Client : protection contre les configs malveillantes
- Détecter et bloquer les configs/scripts envoyés par le serveur qui pourraient contenir des commandes dangereuses
- Whitelist de commandes autorisées dans les servercommands
- **Cvars** : `cl_execWhitelist` (on/off)
- **Difficulté** : Facile — filtrage dans le handler de servercommands
- **Compat** : ✅ Local

### 92. Serveur : détection de wallhack assistée (heuristiques)
- Analyse heuristique côté serveur : tracker les patterns de visée suspects (aim-lock, tracking à travers les murs)
- Logging des suspects pour review manuelle, pas de ban automatique
- **Cvars** : `sv_aimAnalysis` (on/off), `sv_aimLogSuspects`
- **Difficulté** : Difficile — heuristiques complexes
- **Compat** : ✅ Local serveur

### 93. Protection contre le vote abuse
- Limiter les votes par joueur par période de temps
- Anti-spam de vote, cooldown entre votes
- **Cvars** : `sv_voteCooldown`, `sv_voteMaxPerPlayer`, `sv_voteMinInterval`
- **Difficulté** : Facile — compteur dans la logique de vote
- **Compat** : ✅ Local serveur

### 94. Validation stricte des userinfo
- Le serveur valide/sanitize les userinfo keys des clients (noms trop longs, caractères spéciaux,tentatives d'injection)
- **Cvars** : `sv_userinfoValidation` (strict/normal/off), `sv_maxNameLength`
- **Difficulté** : Facile — filtering
- **Compat** : ✅ Local serveur

### 95. Client : sandbox des downloads
- Validation des fichiers téléchargés (checksum, taille max, type) avant écriture sur disque
- Quarantaine des fichiers suspects
- **Cvars** : `cl_downloadSandbox` (on/off), `cl_downloadMaxSize`, `cl_downloadWhitelist`
- **Difficulté** : Facile — étendre `CL_FirstDownload` existant
- **Compat** : ✅ Local

---

## 🎨 Mapping & Modding

### 96. Map testing mode (dev)
- Mode qui affiche les triggers, clips, portails de vis, spawn points
- **Cvars** : `developer 4` (ou `r_mapDebug`), `r_showTriggers`, `r_showClipbrushes`
- **Difficulté** : Facile — étendre le debug draw du renderer
- **Compat** : ✅ Dev

### 97. Live shader reloading (dev)
- Rechargement à chaud des shaders pendant le développement
- **Cvars** : `r_shaderHotReload` (on/off), `r_shaderWatchPath`
- **Difficulté** : Moyenne — file watcher + reload pipeline
- **Compat** : ✅ Dev

### 98. Map decompiler / inspector
- Outil pour inspecter une map BSP : counts d'entités, brushes, surfaces, portails
- **Commandes** : `map_info`, `map_stats`, `ent_list`
- **Difficulté** : Facile — lecture du BSP
- **Compat** : ✅ Dev

### 99. Shader playground / editor (dev)
- Éditeur de shaders en temps réel avec preview (style Shadertoy)
- **Difficulté** : Très difficile — éditeur complet
- **Compat** : ✅ Dev

### 100. Light entity preview (dev)
- Visualisation des light entities et de leur influence en temps réel
- **Cvars** : `r_showLightGrid`, `r_lightPreview`
- **Difficulté** : Moyenne
- **Compat** : ✅ Dev

---

## 🎮 Joueurs — Extensions avancées

### 101. Minimap / radar tactique
- Minimap en overlay montrant les coéquipiers, objectifs, zones de combat (dernière position connue des ennemis)
- Données déjà disponibles dans les snapshots (positions des entités visibles, objectifs)
- **Cvars** : `cg_minimap` (on/off), `cg_minimapSize`, `cg_minimapPosition`, `cg_minimapZoom`, `cg_minimapRotate` (alignée sur la vue du joueur ou Nord en haut)
- **Difficulté** : Moyenne — rendu 2D + extraction des données snapshot
- **Compat** : ✅ Local (lecture des snapshots)

### 102. Presets graphiques (quick-switch)
- Presets prédéfinis : "ultra-competitive" (tout bas, max FPS), "balanced", "cinematic" (bloom, HDR, high quality), "potato" (minimum viable)
- Un seul clic/binding pour switcher entre presets
- **Commandes** : `gfx_preset competitive`, `gfx_preset cinematic`, etc.
- **Cvars** : `r_lastPreset` (pour mémoriser/revenir)
- **Difficulté** : Très facile — changer un lot de cvars d'un coup
- **Compat** : ✅ Local

### 103. FOV par arme / par scope (weapon-specific FOV)
- FOV différent quand on vise avec un scope (zoom), un pistolet, un fusil
- Le système de zoom existe déjà dans le mod, mais un FOV custom supplémentaire pour le hip-fire serait utile
- **Cvars** : `cg_weaponFOV_pistol`, `cg_weaponFOV_rifle`, `cg_weaponFOV_sniper`, `cg_weaponFOV_default`
- **Difficulté** : Facile — le mod expose l'arme actuelle dans `ps->weapon`
- **Compat** : ✅ Local

### 104. Normalisation audio / compresseur dynamique
- Normaliser les sons du jeu : compresser les sons forts (explosions) et amplifier les sons faibles (pas)
- Égaliseur paramétrique pour ajuster les fréquences
- Séparation des canaux volume : armes, pas, voix (chat), ambiance, musique
- **Cvars** : `s_compressor` (on/off), `s_compressorThreshold`, `s_eqLow`, `s_eqMid`, `s_eqHigh`, `s_volumeWeapons`, `s_volumeFootsteps`, `s_volumeAmbient`
- **Difficulté** : Moyenne — traitement audio dans le mixer (`snd_mix.c`)
- **Compat** : ✅ Local

### 105. Third-person deathcam
- Lorsqu'on meurt, voir son propre corps en troisième personne pendant quelques secondes avant le respawn
- Caméra qui suit le tueur (killer-cam)
- **Cvars** : `cg_deathcamMode` (off/thirdperson/killercam/slowmo), `cg_deathcamDuration`
- **Difficulté** : Moyenne — interception de l'event de mort + repositionnement caméra
- **Compat** : ✅ Local

### 106. Auto-screenshot sur événements (killstreak, ace, etc.)
- Capture automatique d'écran sur des events notables : 5-kill streak, ace (toute l'équipe adverse éliminée), last-stand win
- **Cvars** : `cg_autoScreenshot` (bitmask: killstreak/ace/matchend/clutch), `cg_screenshotDelay` (délai pour capturer au bon moment)
- **Difficulté** : Facile — tracker local + capture existante
- **Compat** : ✅ Local

### 107. Weapon switch wheel (sélecteur radial)
- Sélecteur d'arme radial (wheel) activé par une touche, montrant les armes disponibles avec icônes
- Plus rapide et intuitif que les touches numériques pour les nouveaux joueurs
- **Cvars** : `cg_weaponWheel` (on/off), `cg_weaponWheelKey`, `cg_weaponWheelScale`
- **Difficulté** : Moyenne — rendu 2D + gestion d'input
- **Compat** : ✅ Local

### 108. Colorblind-safe enemy/teammate indicators (extension du #70)
- Coloriser les modèles joueurs, les flèches au-dessus des têtes, les indicateurs de hit avec des couleurs distinctes au-delà du rouge/bleu
- Patterns supplémentaires (rayures, triangles vs cercles) en plus des couleurs
- **Cvars** : `cg_teamIndicatorShape` (circle/triangle/square/diamond), `cg_enemyIndicatorShape`
- **Difficulté** : Facile
- **Compat** : ✅ Local

### 109. Console : autocompletion améliorée et historique
- Autocomplétion fuzzy (chercher par portion, pas seulement par préfixe)
- Historique de console navigable avec flèches haut/bas (existe partiellement)
- Copier-coller depuis/vers la console
- **Cvars** : `con_fuzzyComplete` (on/off), `con_historySize`
- **Difficulté** : Facile — étendre `Cmd_CompleteCommand` existant
- **Compat** : ✅ Local

### 110. Mouse polling rate / raw input tuning
- Ajuster le taux de polling de la souris (125Hz/500Hz/1000Hz) — sur Linux c'est géré par l'OS, mais le raw input peut être tuné
- Courbe d'accélération personnalisable (raw input + custom accel curve)
- **Cvars** : `in_rawPollingRate`, `in_customAccelCurve` (points de contrôle)
- **Difficulté** : Facile pour l'accel, difficile pour le polling rate (OS-level)
- **Compat** : ✅ Local

### 111. FOV scaling pour ultrawide / multi-moniteur
- Ajustement automatique du FOV selon le ratio d'aspect (21:9, 32:9, multi-moniteur horizontal)
- Les configurations multi-moniteurs sont déjà supportées (`r_windowMarginTop/Bottom/Left/Right` existent !)
- **Cvars** : `cg_autoFOV` (on/off), `cg_fovScale` (multiplicateur), `cg_fovMin`/`cg_fovMax`
- **Difficulté** : Facile — ajustement de `ps->fov` côté client
- **Compat** : ✅ Local

### 112. Training mode / mode entraînement (solo)
- Mode entraînement local : cibles mobiles, stats de précision en temps réel, replay des tirs
- Bot spawners configurables (difficulté, armes, comportement)
- **Cvars** : `cg_trainingMode` (on/off), `cg_trainingShowStats`, `cg_trainingTargetSpeed`
- **Difficulté** : Moyenne — modules cgame additionnels
- **Compat** : ✅ Local (peut coopérer avec le mod via userinfo)

### 113. Movement/strafe jumping helper (visual feedback)
- Indicateur visuel d'alignement optimal pour strafe jumping (bunny hop, circle jump)
- Vecteur de vélocité affiché, indicateur d'angle de strafe optimal
- Outil d'apprentissage pour les débutants
- **Cvars** : `cg_strafeHelper` (off/vector/optimal_angle/text), `cg_strafeHelperColor`
- **Difficulté** : Facile — les données de vélocité sont dans `ps->velocity`
- **Compat** : ✅ Local

### 114. Hit sound / damage feedback personnalisable (son)
- Sons personnalisables pour les hits, headshots, kills, et être touché
- Pitch/volume variable selon les dégâts infligés (feedback audio plus riche)
- **Cvars** : `cg_hitSoundHeadshot`, `cg_hitSoundBody`, `cg_hitSoundKill`, `cg_damageSoundPitch`
- **Difficulté** : Facile — interception des events + playback
- **Compat** : ✅ Local

### 115. Key bind conflict detection
- Détection automatique des conflits de binds (deux actions sur la même touche)
- Avertissement visuel dans le menu de configuration
- **Commandes** : `bindcheck` (liste les conflits)
- **Difficulté** : Très facile — parcours de `keys[]` array
- **Compat** : ✅ Local

### 116. Spectator info overlay (POV info, follow cam info)
- En mode spectateur, overlay montrant le nom du joueur suivi, son arme, ses HP, sa munition
- Indicateur de mode de caméra (first-person/third-person/free-cam)
- **Cvars** : `cg_specInfoOverlay` (on/off), `cg_specInfoPosition`
- **Difficulté** : Facile — données disponibles dans les snapshots
- **Compat** : ✅ Local

### 117. Watermark / stream overlay
- Overlay personnalisable pour le streaming : nom du joueur, logo, score, timer de match
- Position et opacité configurables, masquage automatique du HUD de jeu pour le stream
- **Cvars** : `cg_streamOverlay` (on/off), `cg_streamName`, `cg_streamLogo`
- **Difficulté** : Facile — rendu 2D
- **Compat** : ✅ Local

### 118. Spawn protection indicator
- Indicateur visuel quand on est sous spawn protection (bouclier/aura)
- Timer visible du temps de protection restant
- **Cvars** : `cg_spawnProtectIndicator` (on/off), `cg_spawnProtectColor`
- **Difficulté** : Facile — dépend du mod pour exposer l'état
- **Compat** : ✅ Local (si le mod expose via configstring ou ps flag)

### 119. Crosshair share/import-export
- Système pour exporter/importer des configurations de crosshair (format texte partageable)
- Bibliothèque de crosshairs préétablis (style CS:GO, style Apex, etc.)
- **Commandes** : `crosshair_export <name>`, `crosshair_import <string>`
- **Difficulté** : Très facile — sérialisation de cvars
- **Compat** : ✅ Local

### 120. Demo smooth camera paths (cinematic tool)
- Création de chemins de caméra pour les démos : définir des points-clés, interpoler entre eux
- Outil pour créateurs de contenu / machinima
- **Cvars/Commandes** : `demo_campath_add`, `demo_campath_play`, `demo_campath_clear`, `cg_camInterpMode`
- **Difficulté** : Moyenne — interpolation spline + système de stockage
- **Compat** : ✅ Local

---

## 🔧 Développeurs — Extensions avancées

### 121. Cvar groups / catégories pour UI organisée
- **Note technique** : `Cvar_SetGroup` existe déjà avec `CVG_RENDERER` ! Étendre à plus de groupes : `CVG_GAMEPLAY`, `CVG_NETWORK`, `CVG_AUDIO`, `CVG_INPUT`, `CVG_SERVER`, `CVG_COMPATIBILITY`
- Permet de filtrer/organiser les cvars dans les menus et la documentation auto
- **Cvars** : nouvelles valeurs d'enum pour `cvarGroup_t`
- **Difficulté** : Très facile — l'infrastructure existe
- **Compat** : ✅ Local

### 122. VM bytecode disassembler / inspector
- Outil pour désassembler et inspecter le bytecode des QVMs chargés (`.qvm`)
- Visualisation des syscalls, des appels `vmMain`, de la stack
- **Commandes** : `vm_disasm <module>`, `vm_inspect <addr>`
- **Difficulté** : Moyenne — le VM compilé existe, il faut le mode interprété pour l'inspection
- **Compat** : ✅ Dev

### 123. Hunk/Zone memory pool visualization
- Visualisation graphique de l'utilisation du hunk et de la zone (fragmentation, usage par tag)
- Heatmap des blocs mémoire, détection de fragmentation
- **Commandes** : `mem_visualize`, `mem_heatmap`
- **Cvars** : `mem_visualizeScale`
- **Difficulté** : Facile — étendre `Hunk_Log`/`Z_LogHeap` existants
- **Compat** : ✅ Dev

### 124. Snapshot delta visualizer
- Outil pour visualiser les deltas entre snapshots consécutifs (quels champs ont changé, quels entityStates)
- Invaluable pour optimiser le trafic réseau et comprendre les snapshots
- **Commandes** : `snap_diff`, `snap_watch <entitynum>`
- **Cvars** : `cl_snapDebug` (on/off)
- **Difficulté** : Facile — comparaison de structures `entityState_t`
- **Compat** : ✅ Dev

### 125. Config string usage analyzer
- Analyseur de l'utilisation des configstrings : quelles CS sont utilisées, par qui, taille occupée
- Détection de CS leak (non-libérées), optimisation de la bande passante
- **Commandes** : `cs_analyze`, `cs_usage_report`
- **Difficulté** : Facile — `SV_GetConfigstring`/`SV_SetConfigstring` existent
- **Compat** : ✅ Dev

### 126. Engine API documentation generator
- Génération automatique de documentation pour les trap calls du VM (liste des syscalls disponibles, leurs signatures)
- Basé sur les tables de dispatch dans `sv_game.c` / `cl_cgame.c`
- **Commandes** : `dump_vm_api`, `dump_trap_table`
- **Difficulté** : Facile — extraction des tables de dispatch existantes
- **Compat** : ✅ Dev

### 127. Automated regression test framework
- Framework de tests de régression pour le moteur : scénarios scriptés, comparaison de rendu, benchmarks
- Extension du système de tests existant (`tests/` avec fuzz + unit tests)
- **Commandes** : `run_regression_tests`, `test_render_compare`
- **Difficulté** : Moyenne-Difficile
- **Compat** : ✅ Dev/CI

### 128. Shader validation / linting
- Validateur de shaders : détecter les erreurs de syntaxe, les stages manquants, les textures inexistantes
- **Commandes** : `shader_lint <path>`, `shader_validate_all`
- **Difficulté** : Facile — parser les fichiers `.shader` existants
- **Compat** : ✅ Dev

### 129. Frame capture & deterministic replay
- Capturer une frame complète (état + inputs) pour rejouer de manière déterministe
- Outil de debug ultime pour reproduire un crash visuel ou un glitch
- **Cvars** : `com_frameCapture` (on/off), `com_replayFrames`
- **Difficulté** : Difficile — nécessite capture complète de l'état engine
- **Compat** : ✅ Dev

### 130. Performance regression CI benchmark
- Benchmark automatisé avec un démo de référence, comparaison des performances commit par commit
- Détection automatique des regressions FPS / mémoire / réseau
- **Difficulté** : Moyenne — `timedemo` existe déjà, ajouter la comparaison
- **Compat** : ✅ CI

### 131. Map entity validator
- Validation des entités d'une map BSP : références manquantes, targetnames non résolus, spawns mal placés
- **Commandes** : `map_validate <mapname>`
- **Difficulté** : Facile — parser les entity strings du BSP
- **Compat** : ✅ Dev

### 132. Network protocol fuzzer (extension)
- Étendre le fuzzer existant (`tests/fuzz/`) avec des cas spécifiques au protocole de jeu
- Génération de packets malformés pour tester la robustesse du parser réseau
- **Difficulté** : Moyenne — extension du framework de fuzz existant
- **Compat** : ✅ Dev/CI

### 133. Build system modernization (CMake)
- Migration progressive vers CMake (ou au moins un wrapper CMake autour du Makefile actuel)
- Meilleur support IDE (VS Code, CLion), génération de projet multi-plateforme
- **Difficulté** : Moyenne — gros travail initial, gain à long terme
- **Compat** : ✅ Build system

### 134. Plugin/module system for engine extensions
- Système de plugins dynamiques (.so/.dll) pour étendre le moteur sans recompiler
- Hooks sur les événements engine (frame, render, network, input)
- **Cvars** : `com_plugins` (liste), `com_pluginsDir`
- **Difficulté** : Difficile — refactoring de l'architecture engine
- **Compat** : ✅ Architecture

### 135. Engine telemetry / crash reporting
- Système de télémétrie anonymisé : stats de performance, crashes avec stack trace
- Rapport de crash formaté (JSON) avec infos système, version, config
- **Cvars** : `com_telemetry` (on/off), `com_crashReport` (on/off)
- **Difficulté** : Moyenne — déjà partiellement couvert par le système d'erreur existant
- **Compat** : ✅ Sortant

---

## Thème : Console, Commandes & Configs (bonus #136–155)

### 136. Console search/filter (Ctrl+F)
- Recherche en direct dans le scrollback console avec surlignage
- Filtrage par texte, par couleur (chat vs système), par niveau
- **Cvars** : `con_searchHighlight` (on/off), `con_searchCaseSensitive`
- **Commandes** : ouverture via `Ctrl+F`, `con_search <text>`, `con_clearsearch`
- **Difficulté** : Facile — le texte est dans `con->text[]` avec couleurs par char
- **Compat** : ✅ Client-side, pas d'impact réseau
- **Fichiers** : `code/client/cl_console.c`

### 137. Console history persistence (cross-session)
- Sauvegarde de l'historique des commandes (`Con_SaveField`) sur disque entre sessions
- Évite de perdre l'historique au restart / crash
- **Cvars** : `con_historySave` (on/off), `con_historySize` (nombre de lignes)
- **Fichier** : `console_history.txt` dans le gamedir
- **Difficulté** : Facile — `Con_SaveField` existe déjà en mémoire, juste ajouter I/O fichier
- **Compat** : ✅ Client-side
- **Fichiers** : `code/client/cl_console.c`, `code/client/cl_keys.c`

### 138. Command alias system
- Système d'alias comme dans Source/GoldSrc : `alias name "command string"`
- Permet de créer des raccourcis personnalisés sans scripts externes
- **Commandes** : `alias <name> <command>`, `unalias <name>`, `aliaslist`
- **Difficulté** : Facile — wrapper autour de `Cmd_AddCommand` avec stockage de la chaîne
- **Compat** : ✅ Client-side ; les alias sont locaux, non envoyés au serveur
- **Fichiers** : `code/qcommon/cmd.c`

### 139. Config diff & merge tool
- Comparaison de la config actuelle avec un fichier de référence
- Affichage des cvars qui diffèrent, avec valeurs old/new
- **Commandes** : `cfg_diff <file>`, `cfg_merge <file>` (applique seulement les diffs)
- **Difficulté** : Facile — parser un .cfg + comparer avec `Cvar_VariableString`
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/cvar.c`

### 140. Console transparency & height control
- Hauteur de console configurable (actuellement hardcoded à 0.5 = demi-écran)
- Transparence du fond de console
- **Cvars** : `con_height` (0.1–1.0), `con_opacity` (0.0–1.0)
- **Difficulté** : Très facile — changer `con->finalFrac = 0.5` en `con_height->value`
- **Compat** : ✅ Client-side
- **Fichiers** : `code/client/cl_console.c` (`Con_RunConsole`)

### 141. Conditional exec (exec_if)
- Exécution conditionnelle de commandes basée sur la valeur d'une cvar
- Syntaxe : `exec_if <cvar> <operator> <value> <command>`
- Exemple : `exec_if com_machine cpu x86_64 exec amd64.cfg`
- **Difficulté** : Facile — parser + `Cvar_VariableValue` + `Cmd_ExecuteString`
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/cmd.c`

### 142. Cvar lock / read-only mode
- Verrouiller une cvar pour empêcher sa modification accidentelle
- Utile pour les configs compétitives (verrouiller les réglages validés)
- **Commandes** : `cvar_lock <name>`, `cvar_unlock <name>`, `cvar_locklist`
- **Difficulté** : Facile — ajouter un flag `CVAR_LOCKED` + check dans `Cvar_Set`
- **Compat** : ✅ Client-side ; le verrou est local, le serveur peut toujours envoyer des valeurs
- **Fichiers** : `code/qcommon/cvar.c`

### 143. Console word-wrap awareness
- Le texte console wrap actuellement au caractères près (`con->linewidth`)
- Word-wrap respectant les espaces/mots pour une meilleure lisibilité
- **Cvars** : `con_wordwrap` (on/off)
- **Difficulté** : Moyenne — le buffer `con->text[]` est indexé par colonne, il faut pré-calculer les wraps
- **Compat** : ✅ Client-side
- **Fichiers** : `code/client/cl_console.c`

### 144. Command timing & profiling
- Mesurer le temps d'exécution d'une commande
- **Commandes** : `time <command>` → affiche le temps en ms
- **Difficulté** : Très facile — wrapper avec `Sys_Milliseconds()` avant/après
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/cmd.c`

### 145. Config auto-reload (file watcher)
- Rechargement automatique d'un fichier de config quand il change sur disque
- Utile pour le développement itératif de configs
- **Cvars** : `cfg_watch <file>` (enregistre un fichier à surveiller), `cfg_watchInterval` (ms)
- **Difficulté** : Moyenne — polling via `FS_GetFileList` + checksum ou mtime
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/files.c`, `code/qcommon/cmd.c`

### 146. Enhanced autocomplete (fuzzy + descriptions)
- Autocomplétion fuzzy (tolérance aux fautes) au lieu de prefix-match strict
- Affichage des descriptions de cvars pendant l'autocomplétion
- **Cvars** : `con_fuzzyComplete` (on/off), `con_showDescriptions` (on/off)
- **Difficulté** : Facile — modifier `FindMatches` dans `Field_CompleteCommand`
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/common.c` (`Field_CompleteCommand`)

### 147. Cvar categories & grouped listing
- Catégorisation des cvars (graphics, network, input, game, etc.)
- Listing groupé pour une navigation plus claire
- **Commandes** : `cvarlist_cat` (affiche par catégorie), `cvarlist graphics`, etc.
- **Difficulté** : Facile — mapping cvar→catégorie basé sur le préfixe (`r_`, `cl_`, `cg_`, `in_`, etc.)
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/cvar.c` (`Cvar_List_f`)

### 148. Console timestamp & source tagging
- Affichage optionnel d'un timestamp `[HH:MM:SS]` devant chaque ligne
- Tag de source `[SERVER]`, `[CLNOP]`, `[RCON]`, `[CHAT]` pour filtrage
- **Cvars** : `con_timestamps` (on/off), `con_sourceTags` (on/off)
- **Difficulté** : Facile — `Con_Print` peut préfixer avant d'insérer dans `con->text`
- **Compat** : ✅ Client-side
- **Fichiers** : `code/client/cl_console.c`

### 149. Config snapshot & rollback
- Snapshot de l'état actuel des cvars, avec possibilité de rollback
- **Commandes** : `cfg_snapshot <name>`, `cfg_rollback <name>`, `cfg_snaplist`
- **Difficulté** : Facile — `Cvar_Get` sur toutes les cvars + sérialisation
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/cvar.c`

### 150. Multi-paste & clipboard enhancement
- Support du copier-coller multi-ligne dans la console
- `Ctrl+V` insère le contenu du clipboard système (SDL clipboard)
- **Cvars** : `con_pasteNewlines` (on/off — convertir newlines en `;` ou ignorer)
- **Difficulté** : Facile — SDL `SDL_GetClipboardText` existe, parser les newlines
- **Compat** : ✅ Client-side
- **Fichiers** : `code/client/cl_keys.c`, `code/sdl/sdl_input.c`

### 151. Command macro / mini-scripting
- Extension du système `vstr` avec variables, conditionnels et boucles limitées
- Syntaxe : `set myvar 1; if $myvar == 1 then echo hello`
- **Difficulté** : Moyenne — mini-interpréteur dans `cmd.c`
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/cmd.c`

### 152. Cvar change notification feed
- Notification temps réel quand une cvar surveillée change
- **Commandes** : `cvar_watch <name>` (surveille), `cvar_unwatch <name>`
- **Cvars** : `con_cvarNotify` (on/off — notification visuelle)
- **Difficulté** : Très facile — callback dans `Cvar_Set` si la cvar est dans une watchlist
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/cvar.c`

### 153. Config encryption / obfuscation
- Chiffrement optionnel des configs (pour les configs compétitives protégées)
- **Commandes** : `writeconfig_enc <file> <password>`, `exec_enc <file> <password>`
- **Difficulté** : Moyenne — AES simple ou XOR avec key derivation
- **Compat** : ✅ Client-side
- **Fichiers** : `code/qcommon/files.c`, nouveau `code/qcommon/crypto.c`

### 154. Console bookmark & jump system
- Marquer des lignes importantes dans le scrollback et y revenir rapidement
- **Commandes** : `con_bookmark` (marque la ligne courante), `con_nextmark`, `con_prevmark`
- **Difficulté** : Facile — tableau de line numbers + navigation dans `con->display`
- **Compat** : ✅ Client-side
- **Fichiers** : `code/client/cl_console.c`

### 155. Smart condump (filtered & formatted)
- Export console avec filtres (par date, par couleur, par texte)
- Formats multiples : texte brut, HTML (avec couleurs), Markdown
- **Commandes** : `condump_html <file>`, `condump_filtered <file> <regex>`
- **Difficulté** : Facile — extension de `Con_Dump_f` existant
- **Compat** : ✅ Client-side
- **Fichiers** : `code/client/cl_console.c` (`Con_Dump_f`)

---

*Document vivant — à enrichir au fil du brainstorming et de l'implémentation. 155 idées au total.*
