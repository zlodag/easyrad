; PowerMic Buttons for PowerScribe 360
; by Tubo Shi MBBS

; AHK Version 1.1
; uses AHKHID from https://github.com/jleb/AHKHID

#Include src\Common.ahk
#Include lib\AHKHID\AHKHID.ahk


Gosub, DictaphoneExec
Return ; End of auto-execution


#Include src\Dictation.ahk
#Include src\keyboard_basic.ahk