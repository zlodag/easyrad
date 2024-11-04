RE_NHI := "[A-Z]{3}" . "[0-9]{4}" . "[A-Z]{0,5}"
RE_ACC := "(?:(?:[A-Z]{2}-)?[0-9]+-[A-Z]{2,5})" . "|" . "(?:[0-9]{4}[A-Z]+[0-9]+[-A-Z0-9]+)"

#Include Lib\Powerscribe.ahk
#Include Lib\RadWhereCOM.ahk
#Include Lib\Inteleviewer.ahk
#Include Lib\InteleviewerCOM.ahk
#Include Lib\Comrad.ahk
#Include Lib\Concerto.ahk
#Include Lib\Utils.ahk
#Include Lib\Config.ahk

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