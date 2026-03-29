@echo off
SET foldername=%1

if "%foldername%"=="" (
    echo Usage: getcreatedir ^<foldername^>
    exit /b
)

md lib\pages\%foldername%\bindings
md lib\pages\%foldername%\controllers
md lib\pages\%foldername%\views

echo. 2>lib\pages\%foldername%\bindings\%foldername%_binding.dart
echo. 2>lib\pages\%foldername%\controllers\%foldername%_controller.dart
echo. 2>lib\pages\%foldername%\views\%foldername%_view.dart

echo Struktur folder dan file untuk '%foldername%' telah dibuat.
