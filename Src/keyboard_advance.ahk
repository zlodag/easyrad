
;; ==================
;; Global keybindings
;; ==================

;; Boss key
F13::
NumpadDiv:: 
  ActivateComrad()
  GroupActivate, RadiologyGroup
  GroupActivate, RadiologyGroup
  GroupActivate, RadiologyGroup
Return

`::
  FileAppend, %ClipboardAll%, C:\Users\tubos\OneDrive - Canterbury District Health Board\home\clip.rtf, UTF-8
Return

~::
  FileRead, Clipboard, *c C:\Users\tubos\OneDrive - Canterbury District Health Board\home\clip.rtf
  MsgBox % Clipboard
F1::
  Send ^c
  Sleep, 500
  if RegExMatch(Clipboard, "[A-Z]{2}-[0-9]{8}-[A-Z]{2}")
    OpenImageViaAccession(Clipboard)
  else if RegExMatch(Clipboard, "[A-Z]{3}[0-9]{4}")
    OpenImageViaNHI(Clipboard)
Return

;; ===============================================
;; Hotkeys for when in InterleView or PowerScribe
;; ===============================================
#IfWinActive ahk_group RadiologyGroup 

ESC::
CapsLock::
  ToggleRecording()
Return

^ESC::
^CapsLock::
  ToggleFindingsMode()
Return

NumpadDot::
NumpadDel::
  ShowIVReport()
Return

Tab::
  ;; next fields
  control := GetPowerScribeEditorCtrl()
  ActivatePowerScribe()
  ControlSend, %control%, {Tab}, %POWERSCRIBE%
Return

;; prev fields
+Tab::
  control := GetPowerScribeEditorCtrl()
  ActivatePowerScribe()
  ControlSend, %control%, {Blind}{Alt Up}{Shift Down}{Tab}, %POWERSCRIBE%
Return

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

^z::
  Send !p
Return

NumpadSub:: PgUp
NumpadAdd::PgDn

;; ======================================
;; InterleViewer Search
;; ======================================
#If WinActive(INTELEVIEWER_SEARCH)

;; Capture Emacs case
F2::
  Send, ^c
  ActivateEmacs()
  Send ^ccc
  sleep 500
  Send ^y{Enter}
  ActivatePowerScribe()
  sleep 50
  Send ^c
  sleep 50
  ActivateEmacs()
  Send +!.^y[^e
Return

;; ====================================
;; Powerscribe
;; ====================================
#If WinActive(POWERSCRIBE)
  #Include src\Emacs.ahk

#c::
  change_consultant()
  { 
    Send {LAlt Down}ta{LAlt Up}
  }
Return

#d::
  check_revisions()
  { 
    Send {LAlt Down}ti{LAlt Up}
    Sleep, 200
    Send {Tab}
  }
Return

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

F1::
  AccessionNumber := GetPowerScribeAccession()
  OpenImageViaAccession(AccessionNumber)
Return

;; Log case
F2::
  Clipboard := GetPowerScribeAccession()
  ActivateEmacs()
  Send ^ccc
  sleep 500
  Send ^y{Enter}
  ActivatePowerScribe()
  sleep 50
  Send ^c
  sleep 50
  ActivateEmacs()
  Send +!.^y[^e
Return

;; Copy Accession Number
F3::
  content := GetPowerScribeAccession()
  Clipboard := content
  ToolTip, Copied: %content%
  SetTimer, RemoveToolTip, -1000
Return

;; Copy NHI
!F3::
  content := GetPowerScribeNHI()
  Clipboard := content
  ToolTip, Copied: %content%
  SetTimer, RemoveToolTip, -1000
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

F1::
  AccessionNumber := GetPowerScribeAccession()
  OpenImageViaAccession(AccessionNumber)
Return

Down::
  Send {Enter}
  Send {Down}
  Sleep 500
  check_revisions()
Return

Up::
  Send {Enter}
  Send {Up}
  Sleep 500
  check_revisions()
Return

b::ControlSend, {PgUp}, GetEditorFormClassNN("RichEdit20W")
j::ControlSend, {Down}, GetEditorFormClassNN("RichEdit20W")
k::ControlSend, {Up}, GetEditorFormClassNN("RichEdit20W")

;; =======================================
;; Hotkeys for COMRAD
;; =======================================

#IfWinActive COMRAD

  #IfWinActive ahk_exe emacs.exe
    ~F1::
      Sleep, 500
      if RegExMatch(Clipboard, "[A-Z]{2}-[0-9]{8}-[A-Z]{2}")
        OpenImageViaAccession(Clipboard)
      else if RegExMatch(Clipboard, "[A-Z]{3}[0-9]{4}")
        OpenImageViaNHI(Clipboard)
    Return

    #If