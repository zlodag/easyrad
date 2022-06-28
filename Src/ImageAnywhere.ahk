F1::
  oldClip := Clipboard
  Clipboard := ""
  Send ^c
  ClipWait, 1

  if RegExMatch(Clipboard, RE_ACC, match) {
    TransientToolTip("Acc: " Clipboard)
    OpenImageViaAccession(match)
  }
  else if RegExMatch(Clipboard, RE_NHI, match) {
    TransientToolTip("NHI: " Clipboard)
    OpenImageViaNHI(match)
  }

  Clipboard := oldClip
Return

#If WinActive(POWERSCRIBE)

F1::
  AccessionNumber := GetPowerScribeAccession()
  OpenImageViaAccession(AccessionNumber)
Return

;; Copy Accession Number
F2::
  Acc := GetPowerScribeAccession()
  NHI := GetPowerScribeNHI()

  if (Clipboard == Acc && NHI) {
    Clipboard := NHI
    TransientToolTip("NHI copied: " Clipboard) 
  }
  else if (Clipboard == NHI && Acc) {
    Clipboard := Acc
    TransientToolTip("Acc copied: " Clipboard)
  }
  else {
    Clipboard := Acc
    TransientToolTip("Acc copied: " Clipboard)
  }
Return

Insert::
  Acc := IVGetLatestAccession()
  Date := IVGetStudyDate(Acc)
  SendInput, %Date%
  TransientToolTip(Acc " : " Date)
Return

#If WinActive("^ ahk_exe InteleViewer.exe",,"Chat Window")

F1::
  match := IVGetCurrentStudy()
  Acc := match.Value(1)
  NHI := match.Value(2) 
  if (Clipboard == Acc) {
    Clipboard := NHI
    TransientToolTip("NHI copied: " Clipboard) 
  }
  else if (Clipboard == NHI) {
    Clipboard := Acc
    TransientToolTip("Acc copied: " Clipboard)
  }
  else {
    Clipboard := Acc
    TransientToolTip("Acc copied: " Clipboard)
  }
Return

^c::
  Clipboard := IVGetLatestAccession()
  ClipWait, 1
  TransientToolTip("Acc copied: " Clipboard)
Return

#IfWinActive ahk_exe emacs.exe

~F1::
  Sleep, 500
  if RegExMatch(Clipboard, RE_ACC)
    OpenImageViaAccession(Clipboard)
  else if RegExMatch(Clipboard, RE_NHI)
    OpenImageViaNHI(Clipboard)
Return

#If