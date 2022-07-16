#Include, Src\Keyboard_common.ahk

;; ==================
;; Timers
;; ==================

;; ==================
;; Global keybindings
;; ==================

End::
  FileAppend, %ClipboardAll%, clip.xml
Return 

`::
  toggleEmacs()
Return

MButton::
  stickyRightMouse() {
    static switch := 0
    ActivateViewer()
    if switch {
      send {MButton}
      switch := 0
    } else {
      send {MButton Down}
      switch := 1
    }
  }

Tab::
  Send {Tab}
Return

#UseHook, Off
Tab & 1::
  KeyWait, 1
  CopySelectionAndOpenImage()
Return
#Usehook

Tab & 2::
  KeyWait, 2
  Send {F2}
Return

Tab & 3::
  KeyWait, 3 
  Send {F3}
Return

Tab & 4::
  KeyWait, 4
  Send {F4}
Return

Tab & 5::
  KeyWait, 5
  Send {F5}
Return

Tab & 6::
  KeyWait, 6
  Send {F6}
Return

Tab & 7::
  KeyWait, 7
  Send {F7}
Return

Tab & 8::
  KeyWait, 8
  Send {F8}
Return

Tab & 9::
  KeyWait, 9
  Send {F9}
Return

Tab & 0::
  KeyWait, 0
  Send {F10}
Return

Tab & -::
  KeyWait, -
  Send {F11}
Return

Tab & =::
  KeyWait, =
  Send {F12}
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
Return

;; ======================================
;; InterleViewer
;; ======================================
#If WinActive("^ ahk_exe InteleViewer.exe")

/* WheelRight::
  ;; Drag and drop images with "Mouse back button"
  Send "d{LButton Down}"
Return 
*/

/* WheelRight Up::
  Send "{LButton Up}"
  Sleep 250
  Send "z"
Return 
*/

Numpad0::
NumpadIns::
  ;; Numpad0/NumpadIns resets image
  Send ^{BackSpace}
Return

XButton2::
NumpadSub:: 
  Send {PgUp}
Return

XButton1::
NumpadAdd::
  Send {PgDn}
Return

XButton1 & WheelDown::
XButton1 & WheelUp::
  cycleIVWindow() {
    static window := 0
    if (A_ThisHotkey = "XButton1 & WheelDown") {
      switch window {
      case 0:
        Send {F5}
        window := 1
      return
    case 1:
      Send {F7}
      window := 0
    return
  }
} else if (A_ThisHotkey = "XButton1 & WheelUp") {
  Send {F2}
  window := 0
}
}

;; Call
^+c::
  match := IVGetCurrentStudy()
  EmacsCapture("c", match.ACC)
Return

;; Follow ups
^+f:: 
  match := IVGetCurrentStudy()
  EmacsCapture("f", match.ACC)
Return

;; Log case
^+l:: 
  match := IVGetCurrentStudy()
  EmacsCapture("l", match.ACC)
Return

;; Report
^+r:: 
  match := IVGetCurrentStudy()
  EmacsCapture("r", match.ACC)
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
  Send, ^c
  ClipWait, 1
  EmacsCapturePowerScribe("c", GetPowerScribeAccession(), Clipboard)
Return

^+f::
  Send, ^c
  ClipWait, 1
  EmacsCapturePowerScribe("f", GetPowerScribeAccession(), Clipboard)
Return

^+r::
  Send, ^c
  ClipWait, 1
  EmacsCapturePowerScribe("r", GetPowerScribeAccession(), Clipboard)
Return

^i::
  lines := SetPowerScribeFindings(AddNumbering(GetPowerScribeFindings()))
  Input, n,,{Space}{Enter}
  updated := PopLine(lines, n)
  SetPowerScribeFindings(RemoveNumbering(updated.Lines))
  Clipboard := updated.Selected
  Send ^v
Return

^+i::
  Clipboard := ExtractPowerScribeImpressions()
  ClipWait, 1
  Send, ^v
Return

!o::
  EditorControl := GetPowerScribeEditorCtrl()
  FindingsControl := GetPowerScribeFindingsCtrl()
  ControlGetFocus, CurrentControl, %POWERSCRIBE%

  if (CurrentControl == EditorControl) {
    ControlFocus, %FindingsControl%, %POWERSCRIBE%
  } else if (CurrentControl == FindingsControl) {
    ControlFocus, %EditorControl%, %POWERSCRIBE%
  }
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
#If WinActive("Compare Report Revisions")
Return

;; =======================================
;; Hotkeys for COMRAD
;; =======================================
#If WinActive("COMRAD")
Return

;; =======================================
;; Hotkeys for Emacs
;; =======================================
#If WinActive("^ahk_exe emacs.exe")
#y::
EmacsGetFindings()
Return

#w::
  findingsCtrl := GetPowerScribeFindingsCtrl()
  Send, !w
  ClipWait, 1
  ControlSetText, %findingsCtrl%, %Clipboard%, %POWERSCRIBE%
Return

CapsLock::
  ToggleRecording()
Return

Tab & 1::
  KeyWait, 1
  KeyWait, Tab
  openStudyFromEmacs()
Return

#If