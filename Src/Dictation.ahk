; PowerMic Buttons for PowerScribe 360
; by Tubo Shi MBBS

; AHK Version 1.1
; uses AHKHID from https://github.com/jleb/AHKHID

DictaphoneExec:
    Gui +hwndhwnd ; stores window handle in hwnd
    ; Usage Page 1, Usage 0
    ; RIDEV_PAGEONLY only devices with top level collection is usage page 1 (Powermic)
    AHKHID_Register(1, 0, hwnd, RIDEV_PAGEONLY + RIDEV_INPUTSINK) 
    ; Exclude other devices of similar usage page
    AHKHID_Register(1, 5, hwnd, RIDEV_EXCLUDE)

    OnMessage(0x00FF, "InputMsg") ; intercept WM_INPUT
Return

powermicMap(data) {
    switch data {
    case 0x4: ; Dictate button pressed, toggle dictation on
        ActivatePowerScribe()
    case 0x1: ; Transcribe button
        toggleInfoWindow()
    case 0x2: ; Previous button
    case 0x8: ; Next button
    case 0x10: ; Fast Backward button
        if WinActiveViewer() {
            Send {PgUp}
        } else if WinActive(POWERSCRIBE) {
            Send {BackSpace}
        }
    case 0x20: ; Fast Forward button
        if WinActiveViewer() {
            Send {PgDn}
        } else if WinActive(POWERSCRIBE) {
            OpenNewLine()
        }
    case 0x40: ; Play/Stop button
        ActivateViewer()
        toggleLeftMouseZoom()
    case 0x100: ; Ok button
        if WinActiveViewer() {
            Send ^{BackSpace}
        } else if WinActive(POWERSCRIBE) {
            CopyTextArea()
            Sleep, 50
            ActivateEmacs()
        }
    case 0x80: ; Left custom button
        if WinActiveViewer() {
            Send d            
        } else if WinActive(POWERSCRIBE) {
            ToggleFindingsMode()
        }
        
    case 0x200: ; Right custom button
        static toggle := True
        if WinActiveViewer() {
            Send {F1}
        } else if WinActive(POWERSCRIBE) {
            if toggle {
                content := GetPowerScribeNHI()
            } else {
                content := GetPowerScribeAccession()
            }
            Clipboard := content
            ToolTip, '%content%' copied
            SetTimer, RemoveToolTip, -1000
            toggle := !toggle
        }        

    case 0x2000: ; Trigger button
        ActivatePowerScribe()
        Send {F12}
    Default: Return
    }
}

InputMsg(wParam, lParam) {
    Local r, h, vid, pid, uspg, us, data, fluency, mouse_id, x, y
    Critical ;Or otherwise you could get ERROR_INVALID_HANDLE

    ;Get device type
    r := AHKHID_GetInputInfo(lParam, II_DEVTYPE) 
    If (r = RIM_TYPEHID) {
        h := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)

        vid := AHKHID_GetDevInfo(h, DI_HID_VENDORID, True) ; Vendor ID = 0x554 = 1364 for Dictaphone Corp.
        pid := AHKHID_GetDevInfo(h, DI_HID_PRODUCTID, True) ; Product ID
        uspg := AHKHID_GetDevInfo(h, DI_HID_USAGEPAGE, True) ; Usage Page
        us := AHKHID_GetDevInfo(h, DI_HID_USAGE, True) ; Usage
        mid := AHKHID_GetDevInfo(h, DI_MSE_ID, True) ; Mouse ID

        if (vid = 1364) and (pid = 4097) and (uspg = 1) and (us = 0) { ; we have a PowerMic!
            r := AHKHID_GetInputData(lParam, uData)
            data := NumGet(uData,2, "Int")
            powermicMap(data)
        }
    }
}