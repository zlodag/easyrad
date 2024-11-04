class AHKHID {
    static DevInfoFlags := {
        ;Flags you can use in AHKHID_GetDevInfo
        ;http://msdn.microsoft.com/en-us/library/ms645581
        DEVTYPE: 4,    ;Type of the device. See RIM_ constants.
        MSE_ID: 8,    ;ID for the mouse device.
        MSE_NUMBEROFBUTTONS: 12,   ;Number of buttons for the mouse.
        MSE_SAMPLERATE: 16,   ;Number of data points per second. This information may not be applicable for every
        ;mouse device.
        MSE_HASHORIZONTALWHEEL: 20,   ;Vista and later only: TRUE if the mouse has a wheel for horizontal scrolling;
        ;otherwise, FALSE.
        KBD_TYPE: 8,    ;Type of the keyboard.
        KBD_SUBTYPE: 12,   ;Subtype of the keyboard.
        KBD_KEYBOARDMODE: 16,   ;Scan code mode.
        KBD_NUMBEROFFUNCTIONKEYS: 20,   ;Number of function keys on the keyboard.
        KBD_NUMBEROFINDICATORS: 24,   ;Number of LED indicators on the keyboard.
        KBD_NUMBEROFKEYSTOTAL: 28,   ;Total number of keys on the keyboard.
        HID_VENDORID: 8,    ;Vendor ID for the HID.
        HID_PRODUCTID: 12,   ;Product ID for the HID.
        HID_VERSIONNUMBER: 16,   ;Version number for the HID.
        HID_USAGEPAGE: 20 | 0x0100,  ;Top-level collection Usage Page for the device.
        HID_USAGE: 22 | 0x0100  ;Top-level collection Usage for the device.
    }

    static InputInfoFlags := {
        ;Flags you can use in AHKHID_GetInputInfo
        ;http://msdn.microsoft.com/en-us/library/ms645562
        DEVTYPE: 0,    ;Type of the device generating the raw input data. See RIM_ constants.
        DEVHANDLE: 8,    ;Handle to the device generating the raw input data.
        MSE_FLAGS: (08 + A_PtrSize * 2) | 0x0100,  ;Mouse state. This member can be any reasonable combination of the
        ;following values -> see MOUSE constants.
        MSE_BUTTONFLAGS: (12 + A_PtrSize * 2) | 0x0100,  ;Transition state of the mouse buttons. This member can be one or more of
        ;the following values -> see RI_MOUSE constants.
        MSE_BUTTONDATA: (14 + A_PtrSize * 2) | 0x1100,  ;If usButtonFlags is RI_MOUSE_WHEEL, this member is a signed value that
        ;specifies the wheel delta.
        MSE_RAWBUTTONS: (16 + A_PtrSize * 2),           ;Raw state of the mouse buttons.
        MSE_LASTX: (20 + A_PtrSize * 2) | 0x1000,  ;Motion in the X direction. This is signed relative motion or absolute
        ;motion, depending on the value of usFlags.
        MSE_LASTY: (24 + A_PtrSize * 2) | 0x1000,  ;Motion in the Y direction. This is signed relative motion or absolute
        ;motion, depending on the value of usFlags.
        MSE_EXTRAINFO: (28 + A_PtrSize * 2),           ;Device-specific additional information for the event.
        KBD_MAKECODE: (08 + A_PtrSize * 2) | 0x0100,  ;Scan code from the key depression. The scan code for keyboard overrun is
        ;KEYBOARD_OVERRUN_MAKE_CODE.
        KBD_FLAGS: (10 + A_PtrSize * 2) | 0x0100,  ;Flags for scan code information. It can be one or more of the following
        ;values -> see RI_KEY constants.
        KBD_VKEY: (14 + A_PtrSize * 2) | 0x0100,  ;Microsoft Windows message compatible virtual-key code.
        KBD_MSG: (16 + A_PtrSize * 2),           ;Corresponding window message, for example WM_KEYDOWN, WM_SYSKEYDOWN, and
        ;so forth.
        KBD_EXTRAINFO: (20 + A_PtrSize * 2),           ;Device-specific additional information for the event.
        HID_SIZE: (08 + A_PtrSize * 2),           ;Size, in bytes, of each HID input in bRawData.
        HID_COUNT: (12 + A_PtrSize * 2),           ;Number of HID inputs in bRawData.
        ;DO NOT USE WITH AHKHID_GetInputInfo. Use AHKHID_GetInputData instead to retrieve the raw data.
        HID_DATA: (16 + A_PtrSize * 2)           ;Raw input data as an array of bytes.
    }

    static RIM_Type := {
        ;Device type values returned by AHKHID_GetDevType as well as DI_DEVTYPE and II_DEVTYPE
        ;http://msdn.microsoft.com/en-us/library/ms645568
        TYPEMOUSE: 0,    ;The device is a mouse.
        TYPEKEYBOARD: 1,    ;The device is a keyboard.
        TYPEHID: 2    ;The device is an Human Interface Device (HID) that is not a keyboard and not a mouse.
    }

    static RID_Flags := {
        ;Different flags for RAWINPUTDEVICE structure (to be used with AHKHID_AddRegister and AHKHID_Register)
        ;http://msdn.microsoft.com/en-us/library/ms645565
        REMOVE: 0x00000001,   ;If set, this removes the top level collection from the inclusion list. This tells the
        ;operating system to stop reading from a device which matches the top level collection.
        EXCLUDE: 0x00000010,   ;If set, this specifies the top level collections to exclude when reading a complete
        ;usage page. This flag only affects a TLC whose usage page is already specified with
        ;RIDEV_PAGEONLY.
        PAGEONLY: 0x00000020,   ;If set, this specifies all devices whose top level collection is from the specified
        ;usUsagePage. Note that usUsage must be zero. To exclude a particular top level
        ;collection, use RIDEV_EXCLUDE.
        NOLEGACY: 0x00000030,   ;If set, this prevents any devices specified by usUsagePage or usUsage from generating
        ;legacy messages. This is only for the mouse and keyboard. See Remarks.
        INPUTSINK: 0x00000100,   ;If set, this enables the caller to receive the input even when the caller is not in
        ;the foreground. Note that hwndTarget must be specified.
        CAPTUREMOUSE: 0x00000200,   ;If set, the mouse button click does not activate the other window.
        NOHOTKEYS: 0x00000200,   ;If set, the application-defined keyboard device hotkeys are not handled. However, the
        ;system hotkeys; for example, ALT+TAB and CTRL+ALT+DEL, are still handled. By default,
        ;all keyboard hotkeys are handled. RIDEV_NOHOTKEYS can be specified even if
        ;RIDEV_NOLEGACY is not specified and hwndTarget is NULL.
        APPKEYS: 0x00000400,   ;Microsoft Windows XP Service Pack 1 (SP1): If set, the application command keys are
        ;handled. RIDEV_APPKEYS can be specified only if RIDEV_NOLEGACY is specified for a
        ;keyboard device.
        EXINPUTSINK: 0x00001000,   ;Vista and later only: If set, this enables the caller to receive input in the
        ;background only if the foreground application does not process it. In other words, if
        ;the foreground application is not registered for raw input, then the background
        ;application that is registered will receive the input.
        DEVNOTIFY: 0x00002000   ;Vista and later only: If set, this enables the caller to receive WM_INPUT_DEVICE_CHANGE
            ;notifications for device arrival and device removal.
    }

    static RIM_WParam := {
        ;Different values of wParam in the WM_INPUT message
        ;http://msdn.microsoft.com/en-us/library/ms645590
        INPUT: 0,    ;Input occurred while the application was in the foreground. The application must call
        ;DefWindowProc so the system can perform cleanup.
        INPUTSINK: 1    ;Input occurred while the application was not in the foreground. The application must call
            ;DefWindowProc so the system can perform the cleanup.
    }

    static GetRID_Flags := {
        ;Flags for GetRawInputData API call
        ;http://msdn.microsoft.com/en-us/library/ms645596
        INPUT: 0x10000003,    ;Get the raw data from the RAWINPUT structure.
        HEADER: 0x10000005    ;Get the header information from the RAWINPUT structure.
    }

    static RawMouse_Flags := {
        ;Flags for RAWMOUSE (part of RAWINPUT)
        ;http://msdn.microsoft.com/en-us/library/ms645578
        ;Flags for the II_MSE_FLAGS member
        MOUSE_MOVE_RELATIVE: 0,     ;Mouse movement data is relative to the last mouse position.
        MOUSE_MOVE_ABSOLUTE: 1,    ;Mouse movement data is based on absolute position.
        MOUSE_VIRTUAL_DESKTOP: 0x02,  ;Mouse coordinates are mapped to the virtual desktop (for a multiple monitor system)
        MOUSE_ATTRIBUTES_CHANGED: 0x04,  ;Mouse attributes changed; application needs to query the mouse attributes.
        ;Flags for the II_MSE_BUTTONFLAGS member
        RI_MOUSE_LEFT_BUTTON_DOWN: 0x0001,   ;Self-explanatory
        RI_MOUSE_LEFT_BUTTON_UP: 0x0002,  ;Self-explanatory
        RI_MOUSE_RIGHT_BUTTON_DOWN: 0x0004,   ;Self-explanatory
        RI_MOUSE_RIGHT_BUTTON_UP: 0x0008,  ;Self-explanatory
        RI_MOUSE_MIDDLE_BUTTON_DOWN: 0x0010,   ;Self-explanatory
        RI_MOUSE_MIDDLE_BUTTON_UP: 0x0020, ;Self-explanatory
        RI_MOUSE_BUTTON_4_DOWN: 0x0040,   ;XBUTTON1 changed to down.
        RI_MOUSE_BUTTON_4_UP: 0x0080,   ;XBUTTON1 changed to up.
        RI_MOUSE_BUTTON_5_DOWN: 0x0100,   ;XBUTTON2 changed to down.
        RI_MOUSE_BUTTON_5_UP: 0x0200,   ;XBUTTON2 changed to up.
        RI_MOUSE_WHEEL: 0x0400   ;Raw input comes from a mouse wheel. The wheel delta is stored in usButtonData.
    }

    static RawKeyboard_Flags := {
        ;Flags for the RAWKEYBOARD (part of RAWINPUT)
        ;http://msdn.microsoft.com/en-us/library/ms645575
        ;Flag for the II_KBD_MAKECODE member in the event of a keyboard overrun
        KEYBOARD_OVERRUN_MAKE_CODE: 0xFF,
        ;Flags for the II_KBD_FLAGS member
        RI_KEY_MAKE: 0,
        RI_KEY_BREAK: 1,
        RI_KEY_E0: 2,
        RI_KEY_E1: 4,
        RI_KEY_TERMSRV_SET_LED: 8,
        RI_KEY_TERMSRV_SHADOW: 0x10
    }

    static Initialize(bRefresh := false) {
        /*
        You don't have to call this function manually. It is automatically called by other functions to get the pointer of the
        RAWINPUTDEVICELIST struct array. However, if a new device is plugged in, you will have to refresh the listing by calling it
        with bRefresh = True. Returns -1 on error (with error message in ErrorLevel).
        */

        Static uHIDList, bInitialized := False

        If bInitialized And Not bRefresh
            Return StrPtr(uHIDList)

        ;Get the device count, or -1 on error
        iCount := this.GetDevCount()

        ;Prep var
        VarSetStrCapacity(&uHIDList, iCount * (A_PtrSize * 2))

        r := DllCall("GetRawInputDeviceList", "Ptr", StrPtr(uHIDList), "UInt*", &iCount, "UInt", A_PtrSize * 2)
        If (r = -1) {
            MsgBox("GetRawInputDeviceList call failed.")
            Return -1
        }

        bInitialized := True
        Return StrPtr(uHIDList)
    }

    static GetDevCount() {
        /*
        Returs the number of HID devices connected to this computer.
        Returns -1 on error.
        */

        ;Get the device count
        r := DllCall("GetRawInputDeviceList", "Ptr", 0, "UInt*", &iCount := 0, "UInt", A_PtrSize * 2)

        ;Check for error
        If (r = -1)
            Return -1
        Else
            Return iCount
    }

    static GetDevHandle(i) {
        /*
        Returns the handle of device i (starts at 1).
        Mostly used internally for API calls.
        */
        Source := this.Initialize()
        Return NumGet(Source, (i - 1) * (A_PtrSize * 2), "Int")
    }

    static GetDevIndex(Handle) {
        /*
        Returns the index (starts at 1) of the device in the enumeration with matching handle.
        Returns 0 if not found.
        */
        Loop this.GetDevCount()
            If (NumGet(this.Initialize(), (A_Index - 1) * (A_PtrSize * 2)) = Handle)
                Return A_Index
        Return 0
    }

    static GetDevType(i, IsHandle := false) {
        /*
        Returns the type of the device. See the RIM_ constants for possible values.
        If IsHandle is false, then i is considered the index (starts at 1) of the device in the enumeration.
        Otherwise it is the handle of the device.
        */
        if Not IsHandle
            Return NumGet(this.Initialize(), ((i - 1) * (A_PtrSize * 2)) + A_PtrSize, "UInt")
        Else
            Return NumGet(this.Initialize(), ((this.GetDevIndex(i) - 1) * (A_PtrSize * 2)) + A_PtrSize, "UInt")
    }

    static GetDevName(i, IsHandle := false) {
        /*
        Returns the name of the device (or empty string on error).
        If IsHandle is false, then i is considered the index (starts at 1) of the device in the enumeration.
        Otherwise it is the handle of the device.
        */

        ;Get handle if i is index
        h := IsHandle ? i : this.GetDevHandle(i)

        ;Get device name length.                                RIDI_DEVICENAME
        r := DllCall("GetRawInputDeviceInfo", "Ptr", h, "UInt", 0x20000007, "Ptr", 0, "UInt*", &iLength)
        If (r = -1)
            Return ""

        ;Get device name.
        VarSetStrCapacity(&s, (iLength + 1) * 2)                         ;RIDI_DEVICENAME
        r := DllCall("GetRawInputDeviceInfo", "Ptr", h, "UInt", 0x20000007, "Str", s, "UInt*", iLength)
        If (r = -1)
            Return ""

        Return s
    }

    static GetDevInfo(i, Flag, IsHandle := false) {
        /*
        Retrieves info from the RID_DEVICE_INFO struct. To retrieve a member, simply use the corresponding flag. A list of flags
        can be found at the top of the script (the constants starting with DI_). Each flag corresponds to a member in the struct.
        If IsHandle is false, then i is considered the index (starts at 1) of the device in the enumeration. Otherwise it is the
        handle of the device. Returns -1 on error (with error message in ErrorLevel).
        
        See Example 1 for an example on how to use it.
        */
        Static uInfo, iLastHandle := 0

        ;Get index if i is handle
        h := IsHandle ? i : this.GetDevHandle(i)

        ;Check if the handle changed
        If (h = iLastHandle) ;It's the same device. No need to call again
            Return NumGet(StrPtr(uInfo), Flag, this._NumIsShort(&Flag) ? "UShort" : "UInt")
        Else {

            ;Get device info buffer size.                           RIDI_DEVICEINFO
            r := DllCall("GetRawInputDeviceInfo", "Ptr", h, "UInt", 0x2000000b, "Ptr", 0, "UInt*", &iLength := 0)
            If (r = -1)
                Return -1

            ;Get device info
            VarSetStrCapacity(&uInfo, iLength)
            NumPut("UInt", iLength, StrPtr(uInfo)) ;Put length in struct RIDI_DEVICEINFO
            r := DllCall("GetRawInputDeviceInfo", "Ptr", h, "UInt", 0x2000000b, "Ptr", StrPtr(uInfo), "UInt*", iLength)
            If (r = -1)
                Return -1

            ;Successful. Keep handle.
            iLastHandle := h

            ;Retrieve data
            Return NumGet(StrPtr(uInfo), Flag, this._NumIsShort(&Flag) ? "UShort" : "UInt")
        }

        Return 0
    }

    static AddRegister(UsagePage := false, Usage := false, Handle := false, Flags := 0) {
        /*
        Allows you to queue up RAWINPUTDEVICE structures before doing the registration. To use it, you first need to initialize the
        variable by calling AHKHID_AddRegister(iNumberOfElements). To then add to the stack, simply call it with the parameters you
        want (eg. AHKHID_AddRegister(1,6,MyGuiHandle) for keyboards). When you're finally done, you just have to call
        AHKHID_Register() with no parameters. The function returns -1 if the struct is full. Redimensioning the struct will erase
        all previous structs added. On success, it returns the address of the array of structs (if you'd rather manipulate it
        yourself).
        
        See Example 2 for an example on how to use it.
        
        You will need to do this if you want to use advance features of the RAWINPUTDEVICE flags. For example, if you want to
        register all devices using Usage Page 1 but would like to exclude devices of Usage Page 1 using Usage 2 (keyboards), then
        you need to place two elements in the array. The first one is AHKHID_AddRegister(1,0,MyGuiHandle,RIDEV_PAGEONLY) and the
        second one is AHKHID_AddRegister(1,2,MyGuiHandle,RIDEV_EXCLUDE).
        
        Tip: Have a look at all the flags you can use (see the constants starting with RIDEV_). The most useful is RIDEV_INPUTSINK.
        Tip: Set Handle to 0 if you want the WM_INPUT messages to go to the window with keyboard focus.
        Tip: To unregister, use the flag RIDEV_REMOVE. Note that you also need to use the RIDEV_PAGEONLY flag if the TLC was
        registered with it.
        */
        Static uDev, iIndex := 0, iCount := 0

        ;Check if we just want the address
        If Not (UsagePage Or Usage Or Handle Or Flags)
            Return &uDev
        ;Check if we just want the count
        Else If (UsagePage = "Count")
            Return iCount
        ;Check if we're dimensioning the struct
        Else If UsagePage And Not (Usage Or Handle Or Flags) {
            iCount := UsagePage
            iIndex := 0
            VarSetStrCapacity(&uDev, iCount * (8 + A_PtrSize))
            Return &uDev
        }

        ;Check if there's space before adding data to struct
        If (iIndex = iCount)
            Return -1    ;Full capacity

        ;Check if hwnd needs to be null. RIDEV_REMOVE, RIDEV_EXCLUDE
        Handle := ((Flags & 0x00000001) Or (Flags & 0x00000010)) ? 0 : Handle

        ;Put in struct
        NumPut("UShort", UsagePage, uDev, (iIndex * (8 + A_PtrSize)) + 0)
        NumPut("UShort", Usage, uDev, (iIndex * (8 + A_PtrSize)) + 2)
        NumPut("UInt", Flags, uDev, (iIndex * (8 + A_PtrSize)) + 4)
        NumPut("Ptr", Handle, uDev, (iIndex * (8 + A_PtrSize)) + 8)

        ;Move to next slot
        iIndex += 1

        Return &uDev
    }

    static Register(UsagePage := false, Usage := false, Handle := false, Flags := 0) {
        /*
        This function can be used in two ways. If no parameters are specified, it will use the RAWINPUTDEVICE array created through
        AHKHID_AddRegister() and register. Otherwise, it will register only the specified parameters. For example, if you just want
        to register the mouse, you can simply do AHKHID_Register(1,2,MyGuiHandle). Returns 0 on success, returns -1 on error (with
        error message in ErrorLevel).
        
        See Example 2 for an example on how to use it with the RAWINPUTDEVICE.
        See Example 3 for an example on how to use it only with the specified parameters.
        */
        ;Check if we're using the AddRegister array or only a single struct
        before := this.GetDevCount()

        If Not (UsagePage Or Usage Or Handle Or Flags) {
            ;Call
            r := DllCall("RegisterRawInputDevices", "Ptr", this.AddRegister(), "UInt", this.AddRegister("Count"), "UInt", 8 + A_PtrSize)

            ;Check for error
            If Not r
                Return -1

            ;Build struct and call
        } Else {

            ;Prep var
            VarSetStrCapacity(&uDev, (8 + A_PtrSize))

            ;Check if hwnd needs to be null. RIDEV_REMOVE, RIDEV_EXCLUDE
            Handle := ((Flags & 0x00000001) Or (Flags & 0x00000010)) ? 0 : Handle

            NumPut("UShort", UsagePage, StrPtr(uDev), 0)
            NumPut("UShort", Usage, StrPtr(uDev), 2)
            NumPut("UInt", Flags, StrPtr(uDev), 4)
            NumPut("Ptr", Handle, StrPtr(uDev), 8)

            ;Call
            r := DllCall("RegisterRawInputDevices", "Ptr", StrPtr(uDev), "UInt", 1, "UInt", 8 + A_PtrSize)

            ;Check for error
            If Not r
                Return -1
        }

        after := this.GetDevCount()
        Return 0
    }

    static GetRegisteredDevs(&uDev) {
        /*
        This function allows you to get an array of the TLCs that have already been registered.
        It fills uDev with an array of RAWINPUTDEVICE and returns the number of elements in the array.
        Returns -1 on error (with error message in ErrorLevel).
        
        See Example 2 for an example on how to use it.
        */
        ;Get length
        VarSetStrCapacity(&iCount, 4)
        r := DllCall("GetRegisteredRawInputDevices", "Ptr", 0, "UInt*", iCount, "UInt", 8 + A_PtrSize)

        If (iCount > 0) {
            ;Prep var
            VarSetStrCapacity(&uDev, iCount * (8 + A_PtrSize))

            ;Call
            r := DllCall("GetRegisteredRawInputDevices", "Ptr", &uDev, "UInt*", iCount, "UInt", 8 + A_PtrSize)
            If (r = -1)
                Return -1
        }
        Return iCount
    }

    static GetInputInfo(InputHandle, Flag) {
        /*
        This function is used to retrieve the data upon receiving WM_INPUT messages. By passing the lParam of the WM_INPUT (0xFF00)
        messages, it can retrieve all the members of the RAWINPUT structure, except the raw data coming from HID devices (use
        AHKHID_GetInputData for that). To retrieve a member, simply specify the flag corresponding to the member you want, and call
        the function. A list of all the flags can be found at the top of this script (the constants starting with II_). Returns -1
        on error (with error message in ErrorLevel).
        
        See Example 2 for an example on how to use it to retrieve each member of the structure.
        See Example 3 for an example on how to interpret members which represent flags.
        
        Tip: You have to use Critical in your message function or you might get invalid handle errors.
        Tip: You can check the value of wParam to know if the application was in the foreground upon reception (see RIM_INPUT).
        */
        Static uRawInput, iLastHandle := 0

        ;Check if it's the same handle
        If (InputHandle = iLastHandle) ;We can retrieve the data without having to call again
            Return NumGet(StrPtr(uRawInput), Flag, this._NumIsShort(&Flag) ? (this._NumIsSigned(&Flag) ? "Short" : "UShort") : (this._NumIsSigned(&Flag) ? "Int" : (Flag = 8 ? "Ptr" : "UInt")))
        Else {    ;We need to get a fresh copy

            ;Get raw data size                                           RID_INPUT
            r := DllCall("GetRawInputData", "UInt", InputHandle, "UInt", 0x10000003, "Ptr", 0, "UInt*", &iSize := 0, "UInt", 8 + A_PtrSize * 2)
            If (r = -1)
                Return -1


            ;Prep var
            VarSetStrCapacity(&uRawInput, iSize)

            ;Get raw data                                                RID_INPUT
            r := DllCall("GetRawInputData", "UInt", InputHandle, "UInt", 0x10000003, "Ptr", StrPtr(uRawInput), "UInt*", &iSize, "UInt", 8 + A_PtrSize * 2)
            If (r = -1)
                Return -1
            Else If (r != iSize) {
                Return -1
            }

            ;Keep handle reference of current uRawInput
            iLastHandle := InputHandle

            ;Retrieve data
            Return NumGet(StrPtr(uRawInput), Flag, this._NumIsShort(&Flag) ? (this._NumIsSigned(&Flag) ? "Short" : "UShort") : (this._NumIsSigned(&Flag) ? "Int" : (Flag = 8 ? "Ptr" : "UInt")))
        }

        Return 0
    }

    static GetInputData(InputHandle, &uData) {
        /*
        This function is used to retrieve the data sent by HID devices of type RIM_TYPEHID (ie. neither keyboard nor mouse) upon
        receiving WM_INPUT messages. CAUTION: it does not check if the device is indeed of type HID. It is up to you to do so (you
        can use GetInputInfo for that). Specify the lParam of the WM_INPUT (0xFF00) message and the function will put in uData the
        raw data received from the device. It will then return the size (number of bytes) of uData. Returns -1 on error (with error
        message in ErrorLevel).
        
        See Example 2 for an example on how to use it (although you need an HID device of type RIM_TYPEHID to test it).
        */
        ;Get raw data size                                           RID_INPUT
        r := DllCall("GetRawInputData", "UInt", InputHandle, "UInt", 0x10000003, "Ptr", 0, "UInt*", &iSize := 0, "UInt", 8 + A_PtrSize * 2)
        If (r = -1)
            Return -1

        ;Prep var
        VarSetStrCapacity(&uRawInput, iSize)

        ;Get raw data                                                RID_INPUT
        r := DllCall("GetRawInputData", "UInt", InputHandle, "UInt", 0x10000003, "Ptr", StrPtr(uRawInput), "UInt*", &iSize, "UInt", 8 + A_PtrSize * 2)
        error := OSError()

        If (r = -1)
            Return -1
        Else If (r != iSize)
            Return -1


        ;Get the size of each HID input and the number of them
        iSize := NumGet(StrPtr(uRawInput), 8 + A_PtrSize * 2 + 0, "UInt") ;ID_HID_SIZE
        iCount := NumGet(StrPtr(uRawInput), 8 + A_PtrSize * 2 + 4, "UInt") ;ID_HID_COUNT

        ;Allocate memory
        VarSetStrCapacity(&uData, iSize * iCount)

        ;Copy bytes
        DllCall("RtlMoveMemory", "UInt", StrPtr(uData), "UInt", StrPtr(uRawInput) + 8 + A_PtrSize * 2 + 8, "UInt", iSize * iCount)

        Return (iSize * iCount)
    }

    ;Internal use only
    static _NumIsShort(&Flag) {
        If (Flag & 0x0100) {
            Flag ^= 0x0100    ;Remove it
            Return True
        }
        Return False
    }

    ;Internal use only
    static _NumIsSigned(&Flag) {
        If (Flag & 0x1000) {
            Flag ^= 0x1000    ;Remove it
            Return True
        }
        Return False
    }

}