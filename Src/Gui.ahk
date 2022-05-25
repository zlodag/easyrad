Menu, Tray, NoStandard

; Icon
; Menu, Tray, Icon, Static/icon.ico

; Start Comard, Inteleviewer, Firefox and IE
Menu, Tray, Add, Launch Radiology Bundle, startLogInBundle
Menu, Tray, Add, Launch InteleViewer, startPacs
Menu, Tray, Add, Launch COMRAD, startComrad
Menu, Tray, Add, Launch Emacs, startEmacs
Menu, Tray, Add, Launch Anki, startAnki

Menu, Tray, Add ; Separator

; Toggle AT_HOME variable
Menu, Tray, Add, At home, toggleAtHome
If AT_HOME {
    Menu, Tray, Check, At home
} Else {
    Menu, Tray, UnCheck, At home
}

; Toggle IS_ONCALL variable
Menu, Tray, Add, On-call, toggleIsOncall
If IS_ONCALL {
    Menu, Tray, Check, On-call
} Else {
    Menu, Tray, UnCheck, On-call
}

Menu, Tray, Add ; Separator
Menu, Tray, Standard

toggleAtHome() {
    Menu, Tray, ToggleCheck, At home
    AT_HOME := !AT_HOME
    Return
}

toggleIsOncall() {
    Menu, Tray, ToggleCheck, On-call
    IS_ONCALL := !IS_ONCALL
    Return
}

Gui, New,, Easy Radiology
Gui, Add, Tab3, W500 H800, Auto Sign-In|Dictation|Keyboard|Imaging Launcher
Gui, Add, Text,, Inteleviewer Username:
Gui, Add, Edit, r1 vIVUsername
Gui, Add, Text,, Inteleviewer Password:
Gui, Add, Edit, r1 vIVPassword Password
Gui, Add, Text,, Comrad Username:
Gui, Add, Edit, r1 vComradUsername
Gui, Add, Text,, Comrad Password:
Gui, Add, Edit, r1 vComradPassword Password
Gui, Add, Button, Default w80, Launch!
;Gui, Show