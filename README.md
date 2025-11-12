# dessinsterrifiants

Un petit projet en assembleur qui dessine (cercles, formes...) et dont les exécutables sont produits dans `output/`.

Ce README explique comment préparer un environnement pour compiler et exécuter les étapes localement, comment générer des captures d'écran, et quelques solutions pour Windows (WSL / Docker).

## Prérequis

Les commandes ci-dessous partent du principe d'un environnement Linux (ou WSL). Les exécutables sont générés avec `nasm` + `gcc` via le `Makefile`.

- nasm
- gcc
- make
- libx11-dev (pour l'affichage X11 lors de l'exécution)
- xvfb (pour exécuter en écran virtuel et prendre des captures)
- imagemagick (outil `import` pour capturer l'écran)

Sur Ubuntu / Debian :

```bash
sudo apt update
sudo apt install -y nasm gcc make libx11-dev xvfb imagemagick
```

Pour Windows, deux options recommandées :

- Utiliser WSL2 (recommandé) : installez WSL2 et une distribution Ubuntu, puis suivez les commandes Ubuntu ci-dessus.
- Utiliser Docker : voir la section "Docker" plus bas.

> Remarque : le dépôt contient un workflow GitHub Actions qui utilise `xvfb` pour exécuter les binaires et générer des captures (fichier `.github/workflows/captures.yml`). Vous pouvez vous en inspirer.

## Compilation

Le `Makefile` contient des cibles pour chaque étape : `etape1`, `etape2`, `etape3`, `etape4` (ou `etape4_1`, `etape4_2` selon le dépôt). Pour compiler toutes les étapes :

```bash
make all
```

Ou compiler les étapes individuellement :

```bash
make etape1
make etape2
make etape3
make etape4
```

Pour nettoyer :

```bash
make clean   # supprime les .out
make fclean  # supprime .out et .o
```

## Exécution

Les exécutables produits se trouvent dans `output/` et s'appellent `etape1.out`, `etape2.out`, etc.

Exemple d'exécution locale (sur un vrai serveur X ou via X11 forwarding) :

```bash
./output/etape1.out
```

Sur une machine sans affichage (serveur CI / headless) vous pouvez utiliser `xvfb-run` pour fournir un écran virtuel :

```bash
xvfb-run --auto-servernum -s "-screen 0 800x600x24" ./output/etape1.out
```

Adaptez `800x600` à la taille définie dans le fichier `etapes/common.asm` (%define WIDTH / HEIGHT). Le workflow GitHub Actions lit automatiquement ces valeurs.

## Générer des captures d'écran

Deux méthodes :

1) Utiliser le workflow GitHub Actions (automatique)

- Le fichier `.github/workflows/captures.yml` compile les exécutables et lance chaque binaire sous `xvfb-run`, puis utilise `import` (ImageMagick) pour capturer l'écran dans `output/screenshots/`.

2) Localement (WSL / Linux) :

```bash
mkdir -p output/screenshots
WINDOW_WIDTH=$(grep '%define WIDTH' etapes/common.asm | awk '{print $3}')
WINDOW_HEIGHT=$(grep '%define HEIGHT' etapes/common.asm | awk '{print $3}')

for etape in etape1 etape2 etape3 etape4_1 etape4_2; do
	xvfb-run --auto-servernum -s "-screen 0 ${WINDOW_WIDTH}x${WINDOW_HEIGHT}x24" sh -c "./output/${etape}.out & sleep 5; import -window root output/screenshots/${etape}.png"
done
```

Sur Windows + WSL, exécutez ces commandes dans la distribution WSL.

## Docker (optionnel)

Si vous préférez isoler l'environnement, vous pouvez utiliser Docker. Exemple rapide :

1) Créez un Dockerfile basé sur Ubuntu et installez les dépendances (nasm, gcc, make, libx11-dev, xvfb, imagemagick).
2) Montez le dépôt et lancez `make all` puis le script de capture ci-dessus à l'intérieur du container.

Je n'ai pas inclus ici de Dockerfile par défaut ; si vous voulez, je peux en fournir un prêt à l'emploi.

## Dépannage

- Erreur "nasm: command not found" -> installez `nasm`.
- Erreur lors de l'ouverture d'une fenêtre X -> utilisez `xvfb-run` en headless, ou exécutez dans un environnement X (WSL avec serveur X, ou Linux natif).
- Les captures sont noires ou blanches -> vérifiez que le binaire a le temps de dessiner (ajuster `sleep`), et que les dimensions (`WIDTH`/`HEIGHT`) sont correctes.

## Notes techniques

- Les dimensions de la fenêtre sont définies dans `etapes/common.asm` via les macros `%define WIDTH` et `%define HEIGHT`. Le workflow d'automatisation lit ces valeurs pour configurer l'écran virtuel.
- Les exécutables finissent généralement en `output/*.out`.

## Contribuer

Ouvrez une issue ou faites une PR si vous souhaitez : ajouter un Dockerfile, améliorer les captures, ou ajouter des cibles Make supplémentaires.

---

Si vous voulez, je peux :

- ajouter un `Dockerfile` prêt à l'emploi et un script `scripts/capture.sh` ;
- ou générer un petit guide PowerShell pour lancer WSL + Make depuis Windows.

Dites-moi ce que vous préférez et je l'ajoute.
