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

#Include, Src\Common.ahk
#Include, Src\Gui.ahk
#Include, Src\Launchers.ahk
#Include, Src\Dictation.ahk

GoSub, DictaphoneInit
Return ; End of auto-execution

#Include, Src\keyboard_custom.ahk
#Include, Src\ImageAnywhere.ahk