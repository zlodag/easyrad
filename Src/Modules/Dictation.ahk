#Include ../Common.ahk
#Include ../Lib/AHKHID.ahk
#Include ./WindowControl.ahk

class Dictaphone extends Gui {

    __New(radwhere) {
        super.__new(, , this)
        hwnd := this.Hwnd
        this.radwhere := radwhere

        ; Usage Page 1, Usage 0
        ; RIDEV_PAGEONLY only devices with top level collection is usage page 1 (Powermic)
        AHKHID.Register(1, 0, hwnd, AHKHID.RID_Flags.PAGEONLY + AHKHID.RID_Flags.INPUTSINK)
        ; Exclude other devices of similar usage page
        AHKHID.Register(1, 5, hwnd, AHKHID.RID_Flags.EXCLUDE)
        OnMessage(0x00FF, (parameters*) => this.InputMsg(parameters*)) ; intercept WM_INPUT
    }

    InputMsg(wParam, lParam, others*) {
        Local r, h, vid, pid, uspg, us, data
        Critical ;Or otherwise you could get ERROR_INVALID_HANDLE

        ;Get device type
        r := AHKHID.GetInputInfo(lParam, AHKHID.InputInfoFlags.DEVTYPE)
        If (r = AHKHID.RIM_Type.TYPEHID) {
            h := AHKHID.GetInputInfo(lParam, AHKHID.InputInfoFlags.DEVHANDLE)
            vid := AHKHID.GetDevInfo(h, AHKHID.DevInfoFlags.HID_VENDORID, True) ; Vendor ID = 0x554 = 1364 for Dictaphone Corp.
            pid := AHKHID.GetDevInfo(h, AHKHID.DevInfoFlags.HID_PRODUCTID, True) ; Product ID
            uspg := AHKHID.GetDevInfo(h, AHKHID.DevInfoFlags.HID_USAGEPAGE, True) ; Usage Page
            us := AHKHID.GetDevInfo(h, AHKHID.DevInfoFlags.HID_USAGE, True) ; Usage
            mid := AHKHID.GetDevInfo(h, AHKHID.DevInfoFlags.MSE_ID, True) ; Mouse ID

            if (vid = 1364) and (pid = 4097) and (uspg = 1) and (us = 0) { ; we have a PowerMic!
                r := AHKHID.GetInputData(lParam, &uData)
                data := NumGet(StrPtr(uData), 2, "UShort")
                this.PowermicMap(data)
            }
        }
    }

    PowermicMap(data) {
        switch data {
            case 0x4: ; Dictate button pressed, toggle dictation on
                PowerScribeApp.Activate()
            case 0x1: ; Transcribe button
                toggleInfoWindow()
            case 0x2: ; Previous button
                If WinActive("Anki")
                    Send 1
                Else if InteleviewerApp.ViewerActive()
                    Send "{PgUp}"
            case 0x8: ; Next button
                If WinActive("Anki")
                    Send 3
                Else if InteleviewerApp.ViewerActive()
                    Send "{PgDn}"
            case 0x10: ; Fast Backward button
            case 0x20: ; Fast Forward button
            case 0x40: ; Play/Stop button
                ; ActivateViewer()
                ; toggleLeftMouseZoom()
            case 0x100: ; Ok button
                ; if WinActiveViewer() {
                ;     Send "^ { BackSpace }"
                ; } else if WinActive(POWERSCRIBE) {
                ;     ActivateEmacs()
                ;     Sleep 100
                ;     EmacsGetFindings()
                ; } else if WinActive("ahk_exe emacs.exe") {
                ;     ActivatePowerScribe()
                ; }
            case 0x80: ; Left custom button
                If InteleviewerApp.ViewerActive() or WinActive(InteleviewerDictaphoneGui.winTitle)
                    InteleviewerDictaphoneGui.toggle()
                Else If PowerScribeApp.WinActive() or WinActive(AutoTextSelectorGui.winTitle)
                    AutoTextSelectorGui.toggle(this.radwhere)
            case 0x200: ; Right custom button
                Acc := InteleviewerApp.GetLatestAccession()
                Output := InteleviewerApp.GenerateComparisonLine(Acc)
                EditPaste Output, PowerScribeApp.GetEditorCtrl(), PowerScribeApp.WinTitle
            case 0x2000: ; Trigger button
                PowerScribeApp.Activate()
                Send "{F12}"
            Default: Return
        }
    }
}

class AutoTextSelectorGui extends Gui {
    static winTitle := "Insert AutoText"

    __New(radwhere) {
        super.__new("-SysMenu AlwaysOnTop", %this.__Class%.winTitle, this) ;; set the event sink to this object
        if not radwhere.LoggedIn
            radwhere.Start()

        this.OnEvent("Escape", (*) => this.Destroy())

        this.Add("GroupBox", "w210 h260", "Radiography")
        this.Add("Button", "xp5 yp15 w60 h50 Section", "Chest").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))
        this.Add("Button", "w60 h50", "Abdomen").OnEvent("Click", (*) => radwhere.InsertAutoText("xray abdomen"))
        this.Add("Button", "w60 h50 Section ys", "C spine").OnEvent("Click", (*) => radwhere.InsertAutoText("xray spine cervical"))
        this.Add("Button", "w60 h50 xp", "T spine").OnEvent("Click", (*) => radwhere.InsertAutoText("xray spine thoracic"))
        this.Add("Button", "w60 h50 xp", "L spine").OnEvent("Click", (*) => radwhere.InsertAutoText("xray spine lumbar"))
        this.Add("Button", "w60 h50 xp", "Pelvis").OnEvent("Click", (*) => radwhere.InsertAutoText("xray pelvis"))
        this.Add("Button", "w60 h50 Section ys", "Trauma").OnEvent("Click", (*) => radwhere.InsertAutoText("xray acute"))
        this.Add("Button", "w60 h50 xp", "Post cast").OnEvent("Click", (*) => radwhere.InsertAutoText("xray cast"))
        this.Add("Button", "w60 h50 xp", "Post op").OnEvent("Click", (*) => radwhere.InsertAutoText("xray post"))

        CoordMode "Mouse", "Screen"
        MouseGetPos(&xps, &ypos)
        this.Show("x" xps " y" ypos)
    }

    static toggle(radwhere) {
        If WinExist(this.winTitle)
            WinClose(this.winTitle)
        Else
            AutoTextSelectorGui(radwhere)
    }
}

class InteleviewerDictaphoneGui extends Gui {
    static winTitle := "Inteleviewer Controller"

    __New() {
        super.__new("-SysMenu AlwaysOnTop", %this.__Class%.winTitle, this) ;; set the event sink to this object
        this.OnEvent("Escape", (*) => this.Destroy())

        this.Add("GroupBox", "w280 h80 Section", "Series Layout")
        this.Add("Button", "xp5 yp15 w60 h50", "1").OnEvent("Click", (*) => this.ControlSend("1"))
        this.Add("Button", "yp w60 h50", "2").OnEvent("Click", (*) => this.ControlSend("2"))
        this.Add("Button", "yp w60 h50", "3").OnEvent("Click", (*) => this.ControlSend("3"))
        this.Add("Button", "yp w60 h50", "4").OnEvent("Click", (*) => this.ControlSend("4"))
        this.Add("GroupBox", "xs w280 h80 Section", "Window and Level")
        this.Add("Button", "xp5 yp15 w60 h50", "Reset").OnEvent("Click", (*) => this.ControlSend("{F2}"))
        this.Add("Button", "yp w60 h50", "Lung").OnEvent("Click", (*) => this.ControlSend("{F5}"))
        this.Add("Button", "yp w60 h50", "Brain").OnEvent("Click", (*) => this.ControlSend("{F6}"))
        this.Add("Button", "yp w60 h50", "Bone").OnEvent("Click", (*) => this.ControlSend("{F7}"))

        CoordMode "Mouse", "Screen"
        MouseGetPos(&xps, &ypos)
        this.Show("x" xps " y" ypos)
    }

    ControlSend(keys) {
        WinActivate InteleviewerApp.WinTitle_Viewer, , InteleviewerApp.WinTitle_Viewer_Exclude
        Send keys
    }

    static toggle() {
        If WinExist(this.winTitle)
            WinClose(this.winTitle)
        Else
            InteleviewerDictaphoneGui()
    }
}