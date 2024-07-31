#Include ..\Common.ahk


TraySetIcon("Static/icon.ico")

tray := A_TrayMenu
tray.delete
tray.Add "Position windows", moveWindows
tray.Add
tray.Add("Launch Radiology Bundle", startAll)
tray.Add "Launch Inteleviewer", startIV
tray.Add "Launch Comrad", startRIS
tray.Add
tray.AddStandard()

startIV(*) {
    username := IniRead("config.ini", "Inteleviewer", "username")
    password := Base64ToString(IniRead("config.ini", "Inteleviewer", "password"))
    InteleviewerApp.login username, password
}

startRIS(*) {
    username := IniRead("config.ini", "Comrad", "username")
    Password := Base64ToString(IniRead("config.ini", "Comrad", "password"))
    ComradApp.login username, Password
}

startAll(*) {
    startIV()
    startRIS()
}

moveWindows(*) {
    try {
        WinMove 0, 0, , , ComradApp.GenericWinTitle
        WinMaximize ComradApp.GenericWinTitle
        WinMove 0, 1080, , , InteleviewerApp.SEARCH_WN
        WinMaximize InteleviewerApp.SEARCH_WN
        WinMove 650, 1100, 1260, 1000, PowerScribeApp.WinTitle
    }
}

;; Settings GUI
;; Global
;; Powerscribe
;; Inteleviewer
;; Comrad
;; Dictaphone
