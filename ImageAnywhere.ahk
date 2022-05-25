#SingleInstance, Force
#NoEnv
SendMode Input
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 2
SetTitleMatchMode, Fast
#Include, src\Common.ahk

F1::
  Send ^c
  Sleep, 500
  if RegExMatch(Clipboard, "[A-Z]{2}-[0-9]{8}-[A-Z]{2}")
    OpenImageViaAccession(Clipboard)
  else if RegExMatch(Clipboard, "[A-Z]{3}[0-9]{4}")
    OpenImageViaNHI(Clipboard)
Return

#If WinActive(POWERSCRIBE)
F1::
  AccessionNumber := GetPowerScribeAccession()
  OpenImageViaAccession(AccessionNumber)
Return

#If