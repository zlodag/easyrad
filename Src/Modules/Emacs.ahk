#Include ../Common.ahk

class EmacsApp {
    static WinTitle := "ahk_exe emacs.exe"
    static ClientPath := this.Path() "\emacsclientw.exe"
    static ServerFile := EnvGet("OneDrive") "\home\.emacs.d\server\server"

    static Path() {
        if A_ComputerName = "BALLANCE"
            path := "C:\Program Files\Emacs\emacs-28.2\bin"
        else {
            SplitPath(A_WorkingDir, , , , , &Drive)
            path := Drive "\\PortableApps\EmacsPortable\App\emacs\bin"
        }
        return path
    }

    static Start() {
        if A_ComputerName = "BALLANCE"
            Run "C:\Users\shitu\OneDrive\Desktop\emacs.bat"
        else
            Run this.Path() "\runemacs.exe"
    }

    static WinActive() {
        return WinActive(this.WinTitle)
    }

    static WinActivate() {
        if WinExist(this.WinTitle)
            WinActivate(this.WinTitle)
        else
            this.Start()
    }

    static CaptureByKeypress(key, id, content := "") {
        ;; DEPRECATED by Protocol-based Capture
        ;; ID is the accession / NHI
        ;; CONTENT is placeholder for future
        this.WinActivate()
        BlockInput 1
        old := A_Clipboard
        A_Clipboard := id
        ClipWait 1
        SendInput "^cc" . key
        Sleep 5000
        A_Clipboard := old
        BlockInput 0
    }

    static YankContent(content) {
        ;; Deprecated by Protocol-based Capture
        if content {
            BlockInput 1
            old := A_Clipboard
            A_Clipboard := content
            Send "^y"
            Sleep 1000
            A_Clipboard := old
            BlockInput 0
        }
    }

    static CaptureByProtocol(key, accession, study := "", content := "") {
        study := LC_UriEncode(study)
        content := LC_UriEncode(content)

        command := "org-protocol://capture"
            . "?template=" key
            . "&url=" accession
            . "&title=" study
            . "&body=" content

        EmacsApp.SendClientCommand(command)
        WinActivate(this.WinTitle)
    }

    static OpenStudyByAccession() {
        A_Clipboard := ""
        ControlSend "{F1}", , this.WinTitle
        ClipWait 1
        opener.OpenStudy(A_Clipboard)
    }

    static OpenComradReport() {
        A_Clipboard := ""
        Send "{F1}"
        ClipWait
        ComradApp.OpenOrder(A_Clipboard)
    }

    static SendClientCommand(command, no_wait := True) {
        arguments := ' -f ' . '"' this.ServerFile '"' . ' --alternate-editor="" '
        if no_wait
            arguments .= "--no-wait "

        If !WinExist(this.WinTitle)
            MsgBox "Emacs has not started yet"
        Run this.ClientPath arguments command
    }

    static CaptureReport() {
        Acc := PowerScribeApp.GetAccessionNumber()
        Findings := ControlGetText(PowerScribeApp.GetFindingsCtrl(), PowerScribeApp.WinTitle)

        A_Clipboard := ""
        Send "^c"
        ClipWait 1

        If A_Clipboard
            Content := A_Clipboard
        Else If Findings
            Content := Findings
        Else
            Content := ""

        ; EmacsApp.CaptureByProtocol("C", Acc, " ", Content)
        FileAppend Content, PowerScribeApp.GetCurrentDraftFilePath()
    }
}


toggleEmacs() {
    if PowerScribeApp.WinActive() {
        EmacsApp.WinActivate()
    }
    else if WinActive("ahk_exe emacs.exe") {
        PowerScribeApp.Activate()
    }
    else
        PowerScribeApp.Activate()
}

HotIfWinactive EmacsApp.WinTitle
Hotkey "#n", (*) => EmacsApp.YankContent(PowerScribeApp.GetAccessionNumber())
Hotkey "#v", (*) => EmacsApp.YankContent(PowerScribeApp.GetContentDWIM())