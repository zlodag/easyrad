SetWorkingDir, %A_ScriptDir%

;; Constants
global POWERSCRIBE := "PowerScribe 360 | Reporting"
global INTELEVIEWER_SEARCH := "Search Tool"
global COMRAD := "COMRAD Medical Systems Ltd."

global PS_EDITOR_CTRL := GetEditorFormClassNN("RICHEDIT50W")
global PS_TOOLBAR_CTRL := GetFormatToolbarClassNN("151")
global PS_ACCESSION := GetAccessionClassNN()

global RE_NHI := "[A-Z]{3}[0-9]{4}[A-Z]{0,5}"
global RE_ACC := "(?:(?:[A-Z]{2}-)?[0-9]+-[A-Z]{2,5})|(?:[0-9]{4}[A-Z]?[0-9]+[A-Z]+)"

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
  RegExMatch(visibleText, RE_NHI, NHI)
  Return NHI
}

GetPowerScribeAccession() {
  WinGetText, visibleText, %POWERSCRIBE%
  RegExMatch(visibleText, RE_ACC, AccessionNumber)
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

GetIVUsernameViaWindowTitle() {
  ;; Deprecated
  static username := ""
  if not username {
    WinGetTitle, title, ahk_exe InteleViewer.exe, , ,
    RegExMatch(title, "O)- ([A-Za-z]+) - InteleViewer", match)
    username := match.Value(1)
  }
  return username
}

GetIVSessionKeyViaHCS() {
  ;; Deprecated
  static SessionKey := ""
  if not SessionKey {
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    url := Format("https://app-cisintv-p.healthhub.health.nz/?method=view&userid={}&debug=0&nhi=0&accno=0", GetIVUsernameViaWindowTitle())
    whr.Open("GET", url, true)
    whr.Send()
    whr.WaitForResponse()
    page := whr.ResponseText
    RegExMatch(page, "[a-z0-9]{32}", SessionKey)
  }
  return SessionKey
}

IVOpenLogFile() {
  EnvGet, A_LocalAppData, LocalAppData
  tmpFile := A_LocalAppData "\Temp\CViewer.log"
  FileRead, Content, %tmpFile%
  return Content
}

IVGetRelevantLog() {
  log := IVOpenLogFile()
  CurrentNHI := GetIVCurrentAccessionAndNHI().NHI
  StudyStart := RegExMatch(log, CurrentNHI)
  Content := SubStr(log, StudyStart)
  return Content
}

GetIVLastAccession() {
  content := IVGetRelevantLog()
  RE_findUid := "sO).*Drag started for thumbnail dataset PersistentImageId \[mSeriesInstanceUid=([0-9.]+),"
  RE_prior := "sO).*Loading matched prior study: Study \[[-A-Za-z]+ Acc (?P<ACC>" RE_ACC ")"
  RegExMatch(content, RE_findUid, LastDragged)
  RegExMatch(content, RE_prior, Previous)

  if (LastDragged.Pos(1) > Previous.Pos(1)) {
    Uid := LastDragged.Value(1)
    RE_findAcc := "O)Acc \[(?P<ACC>" RE_ACC ")\], series UID \[" Uid "\],"
    RegExMatch(content, RE_findAcc, match)
    return match.ACC
  } else {
    return Previous.ACC
  }
}

GetIVCurrentAccessionAndNHI() {
  ;; Pretty much guarantees the current study NHI and Accession number, but not the earliest position.
  content := IVOpenLogFile()
  needle := "sO).*active order: DefaultOrderId\[PatId=(?P<NHI>" RE_NHI ") AccNum=(?P<ACC>" RE_ACC ")\]"
  RegExMatch(content, needle, match)
  return match
}

GetIVStudyDate(accessionNumber) {
  nhi := GetIVCurrentAccessionAndNHI().NHI
  priors := IVSearchStudiesByNHI(IVGetRelatedNHIForCurrentStudy())
  needle := "O)" accessionNumber "\|(?P<Date>[0-9]{4}/[0-9]{2}/[0-9]{2})"
  RegExMatch(priors, needle, match)
  ;MsgBox % priors
  ;MsgBox % "NHI: " nhi ", Acc: " accessionNumber " Date: " match.Date
  Date := IVFormatDate(match.Date)
  return Date
}

IVFormatDate(Date) {
  if (not Date)
    Return ""
  Date := strReplace(Date, "/", "")
  FormatTime, Date, %Date%, dd/MM/yyyy
  return Date
}

IVSearchStudiesByNHI(nhi) {
  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1") 
  match := GetIVUsernameAndSessionId()
  baseUrl := match.baseUrl
  username := match.username
  sessionId := match.sid
  url := baseUrl "/InteleBrowser/InteleBrowser.Search"

  whr.Open("POST", url, true)
  whr.SetRequestHeader("Content-type", "application/x-www-form-urlencoded")
  whr.Send("UserName=" username "&SID=" sessionId "&sf0=" nhi "&comparator0=EQUALS&searchScope=internal&Action=appletsearch&searchProtocolVersion=4")
  whr.WaitForResponse()
  return whr.ResponseText
}

IVGetRelatedNHIForCurrentStudy() {
  nhi := GetIVCurrentAccessionAndNHI().NHI
  log := IVGetRelevantLog()
  RegExMatch(log, "sO).*Build the task to search related series for \[(?P<NHIs>[A-Z0-9, ]+)\]", match)
  result := StrReplace(match.NHIs, ", ", "%5C")
  ;MsgBox % "IVGetRelatedNHI: NHI: " nhi ", result: " result
  Return result
}

GetIVUsernameAndSessionId() {
  content := IVOpenLogFile()
  url := "(?P<baseUrl>http://.+)/InteleViewerService/InteleViewerService\"
  RegExMatch(content, "O)" url "?username=(?P<username>[A-Za-z0-9]+)&sessionId=(?P<sid>[a-z0-9]{32})", match)
  return match
}

CreateIVComObj() {
  oviewer := ComObjCreate("InteleViewerServer.InteleViewerContro.1")
  match := GetIVUsernameAndSessionId()
  oViewer.baseUrl := match.baseUrl
  oViewer.username := match.username
  oViewer.waitForLaunch := 1
  oViewer.sessionId := match.sid
  ;oViewer.sessionId := "c3488773c75b0c219ce374193d2b6a76" ; test sessionKey
  return oViewer
}

OpenImageViaNHI(nhi) {
  static iv := CreateIVComObj()
  iv.loadOrder(0, nhi)
}

OpenImageViaAccession(accession) {
  static iv := CreateIVComObj()
  iv.loadOrderByAccessionNum(accession)
}

RemoveToolTip() {
  ToolTip
}

TransientToolTip(text) {
  ToolTip, %text%
  SetTimer, RemoveToolTip, -1000
}

;; Emacs related
EmacsCapture(key) {
  ActivateEmacs()
  Send ^cc%key%
  sleep 1000
  Send ^y{Enter}
}

EmacsCapturePowerScribe(key) {
  EmacsCapture(key)
  Sleep 1000
  ActivatePowerScribe()
  WinWaitActive, %POWERSCRIBE%
  Send ^c
  ClipWait, 1
  ActivateEmacs()
  Send +!.^y[^e
}