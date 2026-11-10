# General-Osiris Stems (AU + VST3) — installation facile

## Option A (la plus simple) : installeurs prets a double-cliquer, sans rien installer
1. Creez un compte gratuit sur github.com, puis un depot (New repository).
2. Envoyez-y tout le contenu de ce dossier (Add file > Upload files, glissez tout).
   ATTENTION : le dossier `.github` est cache sur Mac (Cmd+Maj+.). S'il n'est pas envoye : Add file > Create new file,
   nom `.github/workflows/build.yml`, collez le contenu de `BUILD_WORKFLOW_COPIE.yml`.
3. Onglet **Actions** > attendez ~15-20 min > cliquez sur l'execution > telechargez **Installeur-macos** et/ou **Installeur-windows**.
4. Double-cliquez : `General-Osiris-Stems-Mac.pkg` (clic droit > Ouvrir si Apple bloque) ou `General-Osiris-Stems-Setup-Windows.exe`
   (si SmartScreen bloque : Informations complementaires > Executer quand meme).
5. Redemarrez votre DAW (Logic : Reglages > Plug-ins > rechercher les nouveaux plug-ins).

## Option B : installer depuis ce dossier (compile sur votre machine)
- **Mac** : double-clic sur `Installer_Mac.command` (clic droit > Ouvrir la 1re fois).
- **Windows** : double-clic sur `Installer_Windows.bat` (il demande les droits admin et installe les outils manquants).

## Modele IA de separation (1 clic dans le plugin)
Onglet **Batterie / Stems** > bouton **Installer le modele IA** : le plugin telecharge les 3 fichiers (~60 Mo au total)
depuis Hugging Face (Faridzar/timbrica-drum-separator, licence **CC BY-NC-SA 4.0 : usage non commercial uniquement**).
Ensuite le meme bouton devient **Separer (IA ONNX)**.
- Le modele attend une piste de **batterie seule** et produit kick / snare / toms ; charleston+cymbales = le reste (case Charleston).
- Hypotheses non verifiees : fenetre Hann periodique + STFT centre. Si le son est trouble, mettez `"center": false` dans `drumsep.json`.
- Autre modele : voir `Models/drumsep.waveform.json.example` et `Tools/inspect_onnx.py` (envoyez-moi sa sortie pour adaptation).
- Dossiers : Mac `~/Library/Application Support/General Osiris/models/`, Windows `%APPDATA%\General Osiris\models\`.

## Utilisation
- **Batterie / Stems** : glissez un fichier sur une case (un stem par case), ou ailleurs pour la separation IA (sinon Auto-split approximatif).
  Les stems sont **dans le plugin** (cases "[charge]") et jouent via "Lecture" ou le transport du DAW.
  Pour les recuperer en fichiers : **Exporter les stems (WAV)** -> dossier Musique/General-Osiris Stems/<date>, a glisser dans Logic.
  (Les sorties multiples par stem existent dans le code, mais Logic ne les propose en general pas pour un plugin d'effet.)
- **Voix > MIDI** : glissez une voix, reglez le BPM, glissez la bande orange/bleue dans une piste du DAW (voix monophonique).
- **Effets** : un onglet par module, bouton Activer, menu Presets. Sidechain : choisissez la source dans l'entree sidechain du plugin.
