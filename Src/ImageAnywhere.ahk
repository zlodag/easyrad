F1::
  oldClip := Clipboard
  Clipboard := ""
  Send ^c
  ClipWait, 1
  Clipboard := Trim(Clipboard)

  if RegExMatch(Clipboard, RE_ACC) {
    TransientToolTip("Acc: " Clipboard)
    OpenImageViaAccession(Clipboard)
  }
  else if RegExMatch(Clipboard, RE_NHI) {
    TransientToolTip("NHI: " Clipboard)
    OpenImageViaNHI(Clipboard)
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
  Acc := GetIVLastAccession()
  Date := GetIVStudyDate(Acc)
  SendInput, %Date%
  TransientToolTip(Acc " : " Date)
Return



#If WinActive("^ ahk_exe InteleViewer.exe",,"Chat Window")

F1::
^c::
  match := GetIVCurrentAccessionAndNHI()
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

#IfWinActive ahk_exe emacs.exe

~F1::
  Sleep, 500
  if RegExMatch(Clipboard, RE_ACC)
    OpenImageViaAccession(Clipboard)
  else if RegExMatch(Clipboard, RE_NHI)
    OpenImageViaNHI(Clipboard)
Return

#If