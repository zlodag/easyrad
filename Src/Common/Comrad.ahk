#Include ../Common.ahk

class ComradApp {
    static GenericWinTitle := "COMRAD Medical Systems Ltd"
    static LoggedInWinTitle := this.GenericWinTitle . ".*Client ID"
    static SelectInterfaceWinTitle := "COMRAD Login - Select Network Interface"
    static ahk_exe := " ahk_exe javaw.exe"

    static WinActivate() {
        WinActivate this.GenericWinTitle
    }

    static WinActive() {
        return WinActive(this.GenericWinTitle)
    }

    static WinExist() {
        return WinExist(this.GenericWinTitle)
    }

    static LoggedIn() {
        PrevMatchMode := SetTitleMatchMode("RegEx")
        loggedIn := WinExist(this.GenericWinTitle . ".*Client ID")
        SetTitleMatchMode(PrevMatchMode)
        return loggedIn
    }

    static OpenOrder(accession) {
        ;; Write to I:/AccessionNumber.ims
        ;; File contains the accession number only
        FileDelete "V:\*.ims"
        FileAppend accession, "V:\AccessionNumber.ims"
    }

    static login(username, password, interface := 1) {
        If ComradApp.LoggedIn() {
            TransientTrayTip "Comrad is already running"
            return
        } Else If WinExist(this.GenericWinTitle) {
            this._send_cred(username, password)
            return
        } Else If WinExist(this.SelectInterfaceWinTitle) {
            this._select_interface(interface)
            this._send_cred(username, password)
            return
        } Else {
            Run A_ComSpec ' /c c:\comrad_java\cdhb.bat'
            WinWait "Wget"
            WinWaitClose "Wget"
            If WinWait(this.SelectInterfaceWinTitle, , 5)
                this._select_interface(interface)
            If WinWait(this.GenericWinTitle, , 5)
                this._send_cred(username, password)
            return
        }
    }

    static _send_cred(username, password) {
        BlockInput 1
        Sleep 500
        SetKeyDelay 10, 10
        ControlSend username "{Tab}" password "{Enter}", , this.GenericWinTitle
        BlockInput 0
        WinWaitClose this.GenericWinTitle
    }

    static _select_interface(interface) {
        Loop interface
            ControlSend "{Tab}", , this.SelectInterfaceWinTitle
        ControlSend "{Space}", , this.SelectInterfaceWinTitle
    }
}