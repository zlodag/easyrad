#Include, Src\Keyboard_common.ahk

;; ==================
;; Global keybindings
;; ==================

End::
  IVGetRelatedNHIForCurrentStudy()
Return

/*
~::
  FileRead, Clipboard, *c C:\Users\tubos\OneDrive - Canterbury District Health Board\home\clip.rtf
  MsgBox % Clipboard 
*/

;; ===============================================
;; Hotkeys for when in InterleView or PowerScribe
;; ===============================================
#IfWinActive ahk_group RadiologyGroup 

[::
  toggleInfoWindow()
Return

]::
  ActivateFirefox()
Return

;; ======================================
;; InterleViewer
;; ======================================
#If WinActive("^ ahk_exe InteleViewer.exe")

XButton1::
  ;; Drag and drop images with "Mouse back button"
  Send "d{LButton Down}"
Return

XButton1 Up::
  Send "{LButton Up}"
  Sleep 250
  Send "z"
Return

Numpad0::
NumpadIns::
  ;; Numpad0/NumpadIns resets image
  Send ^{BackSpace}
Return

Space::
  toggleLeftMouseZoom()
Return

NumpadSub:: PgUp
NumpadAdd::PgDn

;; Capture Emacs case for on-call when study not coded by Techs
^+c::
  match := GetIVCurrentAccessionAndNHI()
  Clipboard := match.Value(1)
  ClipWait, 1
  EmacsCapture("c")
Return

;; Capture Emacs case for follow ups or collecting
^+f:: 
  match := GetIVCurrentAccessionAndNHI()
  Clipboard := match.Value(1)
  ClipWait, 1
  EmacsCapture("f")
Return

;; ======================================
;; InterleViewer Search
;; ======================================
#If WinActive(INTELEVIEWER_SEARCH)
Return

;; ====================================
;; Powerscribe
;; ====================================
#If WinActive(POWERSCRIBE)
  #Include src\Emacs.ahk

;; Bold
^*::
  send_reset("{Control Down}b{Control Up}")
Return

;; Title case (upper case and bold)
^$::
NumpadHome::
  control := GetPowerScribeToolbarCtrl()
  ControlClick %control%, %POWERSCRIBE%,,,, "x20 y20 NA"
  ControlClick %control%, %POWERSCRIBE%,,,, "x130 y20 NA"
Return

;; Log case
^+c::
  Clipboard := GetPowerScribeAccession()
  ClipWait, 1
  EmacsCapturePowerScribe("c")
Return

^+f::
  Clipboard := GetPowerScribeAccession()
  ClipWait, 1
  EmacsCapturePowerScribe("f")
Return

;; Search for relevant reports
F5::
  InputBox, needle, "Search Report", "What would you like to search?"
  loop {
    ControlGetText, content, ps_editor_ctrl, POWERSCRIBE
    foundPos := InStr(content, needle)
    if (foundPos = 0) {
      ControlSend "{Down}", GetFormatToolbarClassNN(4), POWERSCRIBE
      sleep, 500
    } else {
      break
    }
  }
Return

;; =======================================
;; Hotkeys for when in Comparing Revisions
;; =======================================
#IfWinActive Compare Report Revisions
Return

;; =======================================
;; Hotkeys for COMRAD
;; =======================================
#IfWinActive COMRAD
Return
