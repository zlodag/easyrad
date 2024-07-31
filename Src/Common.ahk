RE_NHI := "[A-Z]{3}" . "[0-9]{4}" . "[A-Z]{0,5}"
RE_ACC := "(?:(?:[A-Z]{2}-)?[0-9]+-[A-Z]{2,5})" . "|" . "(?:[0-9]{4}[A-Z]+[0-9]+[-A-Z0-9]+)"

#Include Common/Powerscribe.ahk
#Include Common/RadWhereCOM.ahk
#Include Common/Inteleviewer.ahk
#Include Common/InteleviewerCOM.ahk
#Include Common/Comrad.ahk
#Include Common/Concerto.ahk
#Include Common/Utils.ahk
#Include Common/Config.ahk

#UseHook true

SetTitleMatchMode "RegEx"

;; ===== Notifications =====

TransientToolTip(text) {
  ToolTip text
  SetTimer RemoveToolTip, -1000

  RemoveToolTip() {
    ToolTip
  }
}

TransientTrayTip(text) {
  TrayTip text
  SetTimer RemoveTrayTip, -2000

  RemoveTrayTip() {
    TrayTip  ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion, 1, 3) = "10." {
      A_IconHidden := true
      Sleep 200  ; It may be necessary to adjust this sleep.
      A_IconHidden := false
    }
  }
}

MonitorInfo() {
  MonitorCount := MonitorGetCount()
  MonitorPrimary := MonitorGetPrimary()
  MsgBox "Monitor Count:`t" MonitorCount "`nPrimary Monitor:`t" MonitorPrimary
  Loop MonitorCount
  {
    MonitorGet A_Index, &L, &T, &R, &B
    MonitorGetWorkArea A_Index, &WL, &WT, &WR, &WB
    MsgBox
    (
      "Monitor:`t#" A_Index "
        Name:`t" MonitorGetName(A_Index) "
        Left:`t" L " (" WL " work)
        Top:`t" T " (" WT " work)
        Right:`t" R " (" WR " work)
        Bottom:`t" B " (" WB " work)"
    )
  }
}