#Include ../Common.ahk
#Include ../Lib/AHKHID.ahk
#Include ./WindowControl.ahk
#Include ./AutoTextSelector.ahk

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
                AutoTextSelectorGui(this.radwhere)
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