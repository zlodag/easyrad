;; Constants
global POWERSCRIBE := "PowerScribe 360 | Reporting"
global INTELEVIEWER_SEARCH := "Search Tool"
global COMRAD := "COMRAD Medical Systems Ltd."

global PS_EDITOR_CTRL := GetEditorFormClassNN("RICHEDIT50W")
global PS_TOOLBAR_CTRL := GetFormatToolbarClassNN("151")
global PS_ACCESSION := GetAccessionClassNN()

GroupAdd, RadiologyGroup, ahk_exe InteleViewer.exe
GroupAdd, RadiologyGroup, %POWERSCRIBE%
GroupAdd, ViewerGroup, ^ ahk_exe InteleViewer.exe,,, %INTELEVIEWER_SEARCH% ; Main Inteleviewer
GroupAdd, EditorGroup, %POWERSCRIBE%
GroupAdd, EditorGroup, ^ ahk_exe emacs.exe

;; POWERSCRIBE 
;; ============

GetPowerScribeWindowClass() {
  WinGetClass, class, %POWERSCRIBE%
  return class
}

GetEditorFormClassNN(form, instance := "1") {
  classArray := StrSplit(GetPowerScribeWindowClass(), ".")
  windowClassPostfix := classArray[classArray.MaxIndex()]
  editorClass := "WindowsForms10." . form . ".app.0." . windowClassPostfix . instance
  return editorClass
}

GetFormatToolbarClassNN(toolbar) {
  return GetPowerScribeWindowClass() . toolbar
}

GetAccessionClassNN() {
  return GetPowerScribeWindowClass() . 17
}

GetPowerScribeEditorCtrl() {
  Return GetEditorFormClassNN("RICHEDIT50W")
}

GetPowerScribeToolbarCtrl() {
  Return GetFormatToolbarClassNN("151")
}

OpenNewLine() {
  Send {End}{Enter}
}

MoveCursorUp(n) {
  ControlSend, , {Up %n%}, %POWERSCRIBE%
}

MoveCursorDown(n) {
  ControlSend, , {Down %n%}, %POWERSCRIBE%
}

MoveCursorLeft(n) {
  ControlSend, , {Left %n%}, %POWERSCRIBE%
}

MoveCursorRight(n) {
  ControlSend, , {Right %n%}, %POWERSCRIBE%
}

ToggleFindingsMode() {
  ActivatePowerScribe()
  Send !vf
}

ToggleRecording() {
  ActivatePowerScribe()
  ControlSend, Speech, {F4}, %POWERSCRIBE%
}

GetPowerScribeNHI() {
  WinGetText, visibleText, %POWERSCRIBE%
  RegExMatch(visibleText, "[A-Z]{3}[0-9]{4}", NHI)
  Return NHI
}

GetPowerScribeAccession() {
  WinGetText, visibleText, %POWERSCRIBE%
  RegExMatch(visibleText, "[A-Z]{2}-[0-9]{8}-[A-Z]{2}", AccessionNumber)
  Return AccessionNumber
}

CopyTextArea() {
  Send ^a^c^+{Home}
}

/* LogCaseFromPowerScribe__() {
  FormatTime, ReportDate,, yyyy-MM-dd ddd HH:mm  
  WinGetText, visibleText, %POWERSCRIBE%
  findingsControl := GetEditorFormClassNN("RICHEDIT50W", "2")
  RegExMatch(visibleText, "[A-Z]{2}-[0-9]{8}-[A-Z]{2}", AccessionNumber)
  ControlGetText, findings, %findingsControl%, %POWERSCRIBE%
  findings := StrReplace(findings, "`r", "")
  Gui, add, Text,, Enter modality:
  Gui, Add, Edit, vmodality
  Gui, add, Text,, Enter description:
  Gui, Add, Edit, vdescription
  Gui, Show
  if ErrorLevel
    Return
  FileAppend,
  ( LTrim
  * [exam]
  :PROPERTIES:
  :REPORT_DATE: [%ReportDate%]
  :acession: %AccessionNumber%
  :END:
  %findings%`n
  ), *C:\Users\tubos\OneDrive - Canterbury District Health Board\home\notes\powerscribeFindings.org
  , UTF-8
} 
*/

;; INTELEVIEWER 
;; ============

WinActiveViewer() {
  return WinActive("ahk_exe InteleViewer.exe",, "Search Tool") or WinActive("ahk_exe InteleViewer.exe",, "Chat Window") 
}

StartNewSearch() {
  ActivateViewer()
  Send +/
}

ControlSendInteleviewerMain(k) {
  ControlSend, , %k%, %ViewerGroup%
}

ShowIVReport() {
  WinActivate, ahk_group RadiologyGroup
  Send v
}

;; DICTATION RELATED
;; =================

MoveCursorToCaret() {
  ActivatePowerScribe()
  MouseMove, A_CaretX, A_CaretY
}

MoveCursorToViewer() {
  ActivateViewer()
  MouseMove, 800, 800
}

toggleInfoWindow() {
  ;; Toggle between search window and powerscribe
  if (WinActive(POWERSCRIBE) or WinActive("ahk_exe emacs.exe")) {
    ActivateViewer()
    Send v
  } else {
    if IS_ONCALL {
      ActivateEmacs()
    } else {
      ActivatePowerScribe()
    }
  }
}

toggleLungWindow() { 
  static toggle := True
  if (toggle := !toggle)
    send "^{BackSpace}"
  else
    send "{F5}i"
}

toggleLeftMouseZoom() { 
  static toggle := True
  if (toggle := !toggle)
    send c
  else
    send z
}

;; MISC
;; ====

ActivateComrad() {
  WinActivate, %COMRAD%
}

ActivateSearchTool() {
  WinActivate, %INTELEVIEWER_SEARCH%
}

ActivatePowerScribe() {
  WinActivate, %POWERSCRIBE%
}

ActivateViewer() {
  SetTitleMatchMode, RegEx
  WinActivate, .*InteleViewer.* ahk_exe InteleViewer\.exe,, ^(Search.*)|(Chat.*)
}

ActivateEmacs() {
  WinActivate, ahk_exe emacs.exe
}

ActivateFirefox() {
  WinActivate, ahk_exe firefox.exe
}

GetIVUsername() {
  ;; Deprecated
  static username := ""
  if not username {
    WinGetTitle, title, ahk_exe InteleViewer.exe, , ,
    RegExMatch(title, "O)- ([A-Za-z]+) - InteleViewer", match)
    username := match.Value(1)
  }
  return username
}

GetIVSessionKey() {
  ;; Deprecated
  static SessionKey := ""
  if not SessionKey {
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    url := Format("https://app-cisintv-p.healthhub.health.nz/?method=view&userid={}&debug=0&nhi=0&accno=0", GetIVUsername())
    whr.Open("GET", url, true)
    whr.Send()
    whr.WaitForResponse()
    page := whr.ResponseText
    RegExMatch(page, "[a-z0-9]{32}", SessionKey)
  }
  return SessionKey
}

GetIVUsernameAndSessionId() {
  EnvGet, A_LocalAppData, LocalAppData
  tmpFile := A_LocalAppData "\Temp\CViewer.log"
  file := FileOpen(tmpFile, "r")
  if file {
    content := file.Read()
    RegExMatch(content, "O)(http://.+)/InteleViewerService/InteleViewerService\?username=([A-Za-z0-9]+)&sessionId=([a-z0-9]{32})", match)
    return match
    MsgBox % baseUrl username sessionId
  }
}

CreateIVComObj() {
  static oviewer := ComObjCreate("InteleViewerServer.InteleViewerContro.1")
  match := GetIVUsernameAndSessionId()
  baseUrl := match.Value(1)
  username := match.Value(2)
  sessionId := match.Value(3)
  oViewer.baseUrl := baseUrl
  oViewer.username := username
  oViewer.waitForLaunch := 1
  oViewer.sessionId := sessionId
  return oViewer
}

OpenImageViaNHI(nhi) {
  static iv
  if not iv {
    iv := CreateIVComObj()
  }
  iv.loadOrder(0, nhi)
}

OpenImageViaAccession(accession) {
  static iv 
  if not iv {
    iv := CreateIVComObj()
  }
  iv.loadOrderByAccessionNum(accession)
}

RemoveToolTip() {
  ToolTip
}
