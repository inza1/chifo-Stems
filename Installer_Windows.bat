@echo off
setlocal
cd /d "%~dp0"
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Demande des droits administrateur...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
echo === General-Osiris Stems : installation Windows ===
where cmake >nul 2>&1 || ( echo Installation de CMake... & winget install -e --id Kitware.CMake --accept-source-agreements --accept-package-agreements )
where git >nul 2>&1 || ( echo Installation de Git... & winget install -e --id Git.Git --accept-source-agreements --accept-package-agreements )
set "CM=cmake"
if exist "%ProgramFiles%\CMake\bin\cmake.exe" set "CM=%ProgramFiles%\CMake\bin\cmake.exe"
"%CM%" -S . -B build
if errorlevel 1 (
  echo.
  echo Il manque probablement Visual Studio Build Tools. Installation ^(10-20 min^)...
  winget install -e --id Microsoft.VisualStudio.2022.BuildTools --accept-source-agreements --accept-package-agreements --override "--passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
  "%CM%" -S . -B build || ( echo Echec de la configuration. & pause & exit /b 1 )
)
"%CM%" --build build --config Release --parallel || ( echo Echec de la compilation. & pause & exit /b 1 )
xcopy "build\OsirisStems_artefacts\Release\VST3\General-Osiris Stems.vst3" "%CommonProgramFiles%\VST3\General-Osiris Stems.vst3\" /E /I /Y >nul
mkdir "%ProgramData%\General Osiris\models" 2>nul
copy /Y "build\OsirisStems_artefacts\ONNX_Runtime\onnxruntime.dll" "%ProgramData%\General Osiris\" >nul
if not exist "%ProgramData%\General Osiris\models\drumsep.json" copy "Models\drumsep.json" "%ProgramData%\General Osiris\models\" >nul
echo.
echo TERMINE. Rescannez les plugins VST3 dans votre DAW.
echo Modele IA : dans le plugin, onglet Batterie, bouton "Installer le modele IA" (telechargement automatique).
pause
