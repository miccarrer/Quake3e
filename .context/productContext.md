# Product Context — Urban Terror Optimized

## Pourquoi ce projet existe ?

Urban Terror (UrT) est un mod total conversion pour Quake III Arena, devenu standalone. La communauté UrT 4.x a besoin d'un moteur moderne qui :
1. **Compile sur des OS modernes** (Windows 10/11, Linux récents, macOS ARM)
2. **Offre de bonnes performances** (renderers OpenGL optimisé et Vulkan)
3. **Supporte les fonctionnalités UrT** (format démo, console avancée, etc.)
4. **Est maintenable** (code propre, documentation, CI/CD)

## Problème résolu

Le moteur historique d'Urban Terror (ioq3-for-UrT) est vieux et non maintenu. Les alternatives :
- `ec-/Quake3e` : Excellent moteur mais **sans features UrT**
- `omg-urt/urbanterror-slim` : Quake3e + features UrT mais **peu documenté, CI legacy**
- **Ce projet** : Le meilleur des deux, proprement structuré et maintenu

## Utilisateurs cibles

1. **Joueurs UrT** : Qui veulent un client performant et stable
2. **Admins serveurs** : Qui veulent un serveur dédié fiable avec cvars utiles
3. **Développeurs** : Qui veulent une base de code propre pour faire évoluer le moteur

## Expérience utilisateur visée

- Build simple (`make` sur Linux, MSVC sur Windows)
- Binaires téléchargeables (GitHub Releases via CI)
- Documentation claire (README, BUILD, CVARS)
- Moteur visible dans le server browser UrT (modversion)