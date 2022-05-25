#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include, <Vis2>

GetIVSearchAccession() {
  return OCR(INTELEVIEWER_SEARCH,"",[275,125,100,20])
}

GetIVSearchNHI() {
  return OCR(INTELEVIEWER_SEARCH,"",[35,100,55,20])
}

GetComradNHI() {
  return OCR(COMRAD, "", [35,55,70,25])
}