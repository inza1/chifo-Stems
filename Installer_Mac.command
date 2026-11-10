#!/bin/bash
# Double-cliquez sur ce fichier : il compile et installe tout (AU pour Logic Pro + VST3).
cd "$(dirname "$0")"
set -e
echo "=== General-Osiris Stems : installation Mac ==="
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Les outils Apple (Xcode Command Line Tools) vont s'installer. Validez la fenetre qui s'ouvre,"
  echo "puis re-double-cliquez sur ce fichier quand c'est termine."
  xcode-select --install; read -n 1 -s -r -p "Appuyez sur une touche..."; exit 0
fi
CMAKE=cmake
if ! command -v cmake >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then brew install cmake
  else
    echo "Telechargement de CMake (portable)..."
    mkdir -p .tools && curl -L -o .tools/cmake.tgz https://github.com/Kitware/CMake/releases/download/v3.29.6/cmake-3.29.6-macos-universal.tar.gz
    tar -xzf .tools/cmake.tgz -C .tools
    CMAKE="$PWD/.tools/cmake-3.29.6-macos-universal/CMake.app/Contents/bin/cmake"
  fi
fi
LOG="$PWD/build.log"; : > "$LOG"
fail() {
  echo ""; echo "=== ECHEC. Erreurs principales : ==="
  grep -E "error:|CMake Error|Error [0-9]" "$LOG" | head -15
  echo ""; echo "Journal complet : $LOG (envoyez-moi les lignes ci-dessus ou ce fichier)"
  read -n 1 -s -r -p "Appuyez sur une touche..."; exit 1
}
set -o pipefail
"$CMAKE" -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="$(uname -m)" 2>&1 | tee -a "$LOG" || fail
"$CMAKE" --build build --config Release --parallel 2>&1 | tee -a "$LOG" || fail
for f in "$HOME/Library/Audio/Plug-Ins/Components/General-Osiris Stems.component" "$HOME/Library/Audio/Plug-Ins/VST3/General-Osiris Stems.vst3" "$HOME/Library/Application Support/General Osiris/libonnxruntime.dylib"; do
  if [ -e "$f" ]; then xattr -cr "$f" 2>/dev/null || true; codesign --force --deep -s - "$f" 2>/dev/null || true; fi
done
killall -9 AudioComponentRegistrar 2>/dev/null || true
echo ""
echo "TERMINE. Redemarrez Logic Pro (Reglages > Plug-ins > rechercher les nouveaux plug-ins)."
echo "Modele IA : dans le plugin, onglet Batterie, bouton 'Installer le modele IA' (telechargement automatique)."
read -n 1 -s -r -p "Appuyez sur une touche pour fermer..."
