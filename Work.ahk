; EasyRad - Radiology Automation Suite
; by Tubo Shi MBChB

#SingleInstance Force
SetCapsLockState "AlwaysOff"

#Include Src\Common.ahk
#Include Src\Gui\Tray.ahk
#Include Src\Modules\Emacs.ahk
#Include Src\Modules\Keyboard.ahk
#Include Src\Modules\Dictation.ahk
#Include Src\keyboard_custom.ahk

Config := UserConfig(A_MyDocuments . "\EasyRad.ini")
inteleviewer := InteleviewerApp()