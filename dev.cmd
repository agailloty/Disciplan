@echo off
rem Lancement de Disciplan en dev (API + client Flutter) depuis cmd.exe :
rem   dev.cmd  [options de dev.ps1, ex. -Device windows]
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0dev.ps1" %*
