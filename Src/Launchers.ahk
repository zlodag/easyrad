startProxy() {
    Run, ../bin\px.exe
}

startEmacs() {
    if (WinExist("ahk_exe emacs.exe"))
        Return

    EnvSet, HOME, "C:\Users\shitu\OneDrive - Canterbury District Health Board\home"
    if Not AT_HOME {
        EnvSet, http_proxy, "http://127.0.0.1:3128"
        EnvSet, https_proxy, "http://127.0.0.1:3128"
        EnvSet, MY_CYGWIN, H:/Documents\Cygwin
        EnvSet, MY_LOCATION, work
        Run, startemacs - Work.bat
    } else {
        if WinExist("VPN Connect") {
            EnvSet, http_proxy, http://127.0.0.1:3128
            EnvSet, https_proxy, http://127.0.0.1:3128
        }
        EnvSet, MY_LOCATION, home
        EnvSet, MY_CYGWIN, C:\Cygwin64
        Run, C:\emacs-27.2-x86_64\bin\runemacs.exe   
    }
}

startComrad() {
    If (Not WinExist(COMRAD))
        Run, c:\comrad_java\cdhb.bat
        WinWaitActive, COMRAD
        Sleep, 5000
        ControlSend, ahk_parent, tus{Tab}cdhbxray1{Enter}, COMRAD
}

startPacs() {
    If (Not WinExist("ahk_exe InteleViewer.exe"))
        Run, "C:\Program Files\Intelerad Medical Systems\InteleViewer\CViewer\StartInteleViewer.exe"
        WinWaitActive, InteleViewer Login
        Click, 400 350
        Send, Imadoctor12{Enter}
}

startFirefox() {
    If (Not WinExist("ahk_exe firefox.exe"))
        Run, "C:\Users\tubos\AppData\Local\Mozilla Firefox\firefox.exe"
}

startIE() {
    If (Not WinExist("ahk_exe iexplorer.exe"))
        Run, iexplore.exe https://physicianscheduler.cdhb.health.nz/clairviaweb/
}

startAnki() {
    EnvSet, http_proxy, "http://127.0.0.1:3128"
    EnvSet, https_proxy, "http://127.0.0.1:3128"
    startProxy()
    Run, startanki.bat
}

startLogInBundle() {
    startComrad()
    startPacs()
    startIE()
    startEmacs()
}