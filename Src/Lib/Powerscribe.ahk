#Include ../Common.ahk

class PowerScribeApp {

    static WinTitle := "PowerScribe 360 | Reporting"

    static WinGetClass() {
        Return WinGetClass(this.WinTitle)
    }

    static _EditorFormClassNN(formName, instanceId := "1") {
        classArray := StrSplit(this.WinGetClass(), ".")
        windowClassPostfix := classArray[-1]
        editorClass := "WindowsForms10." . formName . ".app.0." . windowClassPostfix . instanceId
        Return editorClass
    }

    static _FormatToolbarClassNN(toolbar) {
        Return this.WinGetClass() . toolbar
    }

    static GetAccessionClassNN() {
        Return this.WinGetClass() . 17
    }

    static GetEditorCtrl() {
        Return this._EditorFormClassNN("RICHEDIT50W")
    }

    static GetToolbarCtrl() {
        Return this._FormatToolbarClassNN("151")
    }

    static GetFindingsCtrl() {
        Return this._EditorFormClassNN("RICHEDIT50W", "2")
    }

    static GetFieldsCtrl() {
        Return this._EditorFormClassNN("LISTBOX")
    }

    static GetBrowserCtrl() {
        Return this._EditorFormClassNN("Window.8", "4")
    }

    static GetCurrentCtrl() {
        CurrentControl := ControlGetFocus(PowerScribeApp.WinTitle)
        Return ControlGetClassNN(CurrentControl)
    }

    static Activate() {
        If WinExist(this.WinTitle)
            WinActivate this.WinTitle
    }

    static WinActive() {
        Return WinActive(this.WinTitle)
    }

    static ToggleFindingsMode() {
        this.Activate()
        Send "!vf"
    }

    static ToggleFindingsWindow() {
        EditorControl := this.GetEditorCtrl()
        FindingsControl := this.GetFindingsCtrl()
        CurrentControl := this.GetCurrentCtrl()

        If (CurrentControl == EditorControl) {
            ControlFocus FindingsControl, this.WinTitle
        } Else If (CurrentControl == FindingsControl) {
            ControlFocus EditorControl, this.WinTitle
        }
    }

    static FindingsContent {
        get {
            Return ControlGetText(this.GetFindingsCtrl(), this.WinTitle)
        }

        set {
            ControlSetText(value, this.GetFindingsCtrl(), this.WinTitle)
        }
    }


    static GetCurrentDraftFilePath() {
        accession := this.GetAccessionNumber()
        path := A_MyDocuments "\Radiology\Drafts\"
        Return path . accession . ".org"
    }

    static SaveFindingsContent() {
        content := this.FindingsContent
        filename := this.GetCurrentDraftFilePath()
        command := filename

        If not content
            content := A_Clipboard

        Try
            FileDelete filename
        FileAppend content, filename
        TransientToolTip "Draft saved"
    }

    static LoadFindingsContent() {
        accession := this.GetAccessionNumber()
        filename := this.GetCurrentDraftFilePath()
        Try {
            content := FileRead(filename)
            this.FindingsContent := content
            FileDelete filename
        }
        Catch
            TransientToolTip "No draft available for Acc: " . accession
    }


    static GetNHI() {
        text := WinGetText(this.WinTitle)
        RegExMatch(text, RE_NHI, &NHI)
        Return NHI
    }

    static GetAccessionNumber() {
        text := WinGetText(this.WinTitle)
        RegExMatch(text, RE_ACC, &AccessionNumber)
        TransientToolTip(AccessionNumber[])
        Return AccessionNumber[]
    }

    static GetStudyDescription() {
        Control := this._EditorFormClassNN("STATIC", 2)
        Description := ControlGetText(Control, this.WinTitle)
        Return Description
    }

    static GetStudyClinicalHistory() {
        Control := this._EditorFormClassNN("STATIC", 32)
        Description := ControlGetText(Control, this.WinTitle)
        Return Description
    }

    static GetStudyReport() {
        Control := this._EditorFormClassNN("RICHEDIT50W", 1)
        Description := ControlGetText(Control, this.WinTitle)
        Return Description
    }

    ;; Keyboard related

    static ToggleRecording() {
        this.Activate()
        ControlSend "{F4}", "Speech", this.WinTitle
    }

    static ChangeConsultant() {
        Send "{LAlt Down}ta{LAlt Up}"
    }

    static CheckRevisions() {
        Send "{LAlt}ti"
    }

    static bold_and_upper() {
        control := this.GetToolbarCtrl()
        ControlClick control, this.WinTitle, , , , "x20 y20 NA"
        ControlClick control, this.WinTitle, , , , "x130 y20 NA"
    }

    static NextTabStop() {
        this._TabStop("{Down}", "{Tab}")
    }

    static PrevTabStop() {
        this._TabStop("{Up}", "{Blind}{Alt Up}{Shift Down}{Tab}")
    }

    static _TabStop(fastKeys, slowKeys) {
        highlightOn := EditGetSelectedText(this.GetEditorCtrl(), this.WinTitle)

        Try
            selectedFieldIndex := ControlGetIndex(this.GetFieldsCtrl(), this.WinTitle)
        Catch
            selectedFieldIndex := 0

        If highlightOn
            ControlSend fastKeys, this.GetFieldsCtrl(), this.WinTitle
        Else If selectedFieldIndex
            ControlChooseIndex selectedFieldIndex, this.GetFieldsCtrl(), this.WinTitle
        Else
            ControlSend slowKeys, this.GetEditorCtrl(), this.WinTitle
        this.Activate()
    }
}


; Not used for now, for selection autotext automatically in PowerScribe
;; PostMessage 513, 0, (3 * 16 << 16 | 0), PowerscribeApp.GetFieldsControl(), PowerScribeApp.WindowName
;; PostMessage 514, 0, 2, ctrl, powerscribe
