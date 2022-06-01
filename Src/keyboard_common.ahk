;; ==================
;; Global keybindings
;; ==================

F13::
NumpadDiv:: 
  ;; Boss key
  ActivateComrad()
  GroupActivate, RadiologyGroup
  GroupActivate, RadiologyGroup
  GroupActivate, RadiologyGroup
Return

`::
  toggleInfoWindow() 
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

;; ====================================
;; Powerscribe
;; ====================================
#If WinActive(POWERSCRIBE)

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

;; =======================================
;; Hotkeys for when in Comparing Revisions
;; =======================================
#IfWinActive Compare Report Revisions

F1::
  WinGetText, visibleText
  RegExMatch(visibleText, "[A-Z]{3}[0-9]{4}", NHI)
  Clipboard := NHI
Return

F2::
  WinGetText, visibleText
  RegExMatch(visibleText, "[A-Z]{2}-[0-9]{8}-[A-Z]{2}", AccessionNumber)
  Clipboard := AccessionNumber
  StartNewSearch()
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

#If  ;; End IfWinActive