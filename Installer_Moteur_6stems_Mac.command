#!/bin/bash
# Installe le moteur open source stems.cpp + le modele DrumSep 6 stems (kick, snare, toms, hi-hat, ride, crash).
# ATTENTION : verifiez les licences du moteur (github.com/betweentwomidnights/stems.cpp) et du modele avant tout usage commercial.
set -e
ENG="$HOME/General-Osiris-Engine"
DEST="$HOME/Library/Application Support/General Osiris/models"
mkdir -p "$ENG" "$DEST"
command -v git >/dev/null || { echo "git manquant : installez les outils Xcode (xcode-select --install)"; read -n 1 -s -r -p "..."; exit 1; }
cd "$ENG"
[ -d stems.cpp ] || git clone --recursive https://github.com/betweentwomidnights/stems.cpp
cd stems.cpp
./build.sh metal
./models.sh mdx23c_drumsep
BIN=$(find . -name stems-split -type f | head -1)
MODEL=$(find . -name "*drumsep*.gguf" | head -1)
if [ -z "$BIN" ] || [ -z "$MODEL" ]; then echo "Moteur ou modele introuvable apres installation."; read -n 1 -s -r -p "..."; exit 1; fi
BIN="$PWD/${BIN#./}"; MODEL="$PWD/${MODEL#./}"
[ -f "$DEST/drumsep.json" ] && cp "$DEST/drumsep.json" "$DEST/drumsep.json.bak"
cat > "$DEST/drumsep.json" <<JSON
{ "mode": "external_cli", "sample_rate": 44100, "command": "$BIN", "model": "$MODEL" }
JSON
echo ""
echo "TERMINE. Rouvrez le plugin : le bouton 'Separer (IA)' utilise maintenant le modele 6 stems."
read -n 1 -s -r -p "Appuyez sur une touche..."
