; PowerMic Buttons for PowerScribe 360
; by Tubo Shi MBBS
#Include %A_ScriptDir%
#NoEnv
#SingleInstance, force
#InstallKeybdHook
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode, 2
SetTitleMatchMode, Fast
SetCapsLockState, AlwaysOff ; Disables CapsLock globally

#Include, Lib\AHKHID.ahk
#Include, Src\Common.ahk
#Include, Src\Gui.ahk

Gosub, DictaphoneExec
Return ; End of auto-execution

#Include, Src\Launchers.ahk
#Include, Src\Dictation.ahk
#Include, Src\keyboard_advance.ahk