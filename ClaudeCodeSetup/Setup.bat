@echo off
chcp 65001 >nul
title Claude Code Setup
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_internal.ps1"
pause
