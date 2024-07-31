#Include ../Common.ahk

class EmacsKeys {
    __New() {
        this.prefixes := Map()

        this.Keymap := Map() ;; A map of TriggerKeys to an Array of "PrefixArray" to "Callback"
        this.PrefixStates := Array()

        this.active_region := false
    }

    RegisterPrefixedHotkey(prefix, key, callback) {
        ;; Save prefix and key combo to instance property
        try {
            store := this.prefixes[prefix]
            store[key] := callback
        }
        catch {
            store := Map(key, callback)
            this.prefixes[prefix] := store
        }
    }

    PrefixCallback(prefix) {
        _callback(e) {
            ih := InputHook("BCL0T2")
            ih.VisibleNonText := false
            ih.VisibleText := false

            ih.KeyOpt("{All}", "E")
            ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")
            ih.Start()
            ih.Wait()
            pressed := RegExReplace(ih.EndMods . ih.EndKey, "[<>]")
            if (this.prefixes[prefix].Has(pressed)) {
                callback := this.prefixes[prefix].Get(pressed)
                callback()
            }
        }
        return _callback
    }

    DefineKey(keyString, callback) {
        ;; Define a keyboard shortcut
        keys := StrSplit(keyString, " ", MaxParts := 2)

        if keys.Length = 1 {
            Hotkey keyString, callback
        } else {
            prefix := keys[1]
            key := keys[2]
            this.RegisterPrefixedHotkey(prefix, key, callback)
            Hotkey prefix, this.PrefixCallback(prefix)
        }
    }

    static TestCallback() {
        MsgBox A_ThisHotkey
    }

    ;; ===== Motion =====

    toggleActiveRegion() {
        this.active_region := !this.active_region
    }

    turnOffActiveRegion() {
        this.active_region := false
    }

    region_aware(key) {
        if this.active_region
            Send "+" . key
        Else
            Send key
    }
    move_beginning_of_line() {
        this.region_aware("{HOME}")
    }

    move_end_of_line() {
        this.region_aware("{END}")
    }

    move_beginning_of_file() {
        this.region_aware("^{HOME}")
    }

    move_end_of_file() {
        this.region_aware("^{END}")
    }

    previous_line() {
        this.region_aware("{Up}")
    }

    next_line() {
        this.region_aware("{Down}")
    }

    forward_char() {
        this.region_aware("{Right}")
    }

    backward_char() {
        this.region_aware("{Left}")
    }

    forward_word() {
        this.region_aware("^{Right}")
    }

    backward_word() {
        this.region_aware("^{Left}")
    }

    ;; ===== Editing commands =====
    delete_char() {
        send("{Del}")
        this.turnOffActiveRegion()
    }

    delete_word() {
        send("^{Del}")
        this.turnOffActiveRegion()
    }

    delete_backward_char() {
        send("{BS}")
        this.turnOffActiveRegion()
    }

    delete_backward_word() {
        send("^{BS}")
        this.turnOffActiveRegion()
    }

    kill_line() {
        Send "{ShiftDown}{END}{SHIFTUP}"
        Sleep 25 ;[ms] this value depends on your environment
        Send "^x"
        this.turnOffActiveRegion()
    }

    open_line_above() {
        Send("{HOME}{Enter}{Up}")
        this.turnOffActiveRegion()
    }

    enter() {
        Send("{Enter}")
        this.turnOffActiveRegion()
    }

    open_line_below() {
        Send "{End}{Enter}"
        this.turnOffActiveRegion()
    }

    undo() {
        Send("^z")
        this.turnOffActiveRegion()
    }

    redo() {
        Send "^y"
        this.turnOffActiveRegion()
    }

    ;; ==== Text manipulation =====

    transpose_chars() {
        send "+{Right}"
        send "^x{Left}"
        send "^v"
        this.turnOffActiveRegion()
    }

    transpose_words() {
        send "^+{Right}"
        send "^x^{Left}"
        send "^v"
        this.turnOffActiveRegion()
    }

    quit() {
        if this.active_region {
            this.active_region := false
            send("{ESC}{Right}")
        } else {
            send("{ESC}")
        }
    }

    select_all() {
        Send "{Control Down}a{Control Up}"
    }

    CopyTextArea() {
        Send "^a^c^+{Home}"
        this.turnOffActiveRegion()
    }

    bold() {
        Send "{Control Down}b{Control Up}"
    }

    bullet() {
        Send "^+l"
    }

    static bindDefaultKeys(windowName) {
        e := EmacsKeys()
        HotIfWinactive windowName
        #UseHook true
        ;; Motion
        e.DefineKey("^vk20", (*) => e.toggleActiveRegion())
        e.DefineKey("^b", (*) => e.backward_char())
        e.DefineKey("!b", (*) => e.backward_word())
        e.DefineKey("^f", (*) => e.forward_char())
        e.DefineKey("!f", (*) => e.forward_word())
        e.DefineKey("^n", (*) => e.next_line())
        e.DefineKey("^p", (*) => e.previous_line())
        e.DefineKey("^a", (*) => e.move_beginning_of_line())
        e.DefineKey("^e", (*) => e.move_end_of_line())
        e.DefineKey("!<", (*) => e.move_beginning_of_file())
        e.DefineKey("!>", (*) => e.move_end_of_file())
        ;; Line
        e.DefineKey("^k", (*) => e.kill_line())
        e.DefineKey("^o", (*) => e.open_line_above())
        e.DefineKey("^j", (*) => e.enter())
        e.DefineKey("^x h", (*) => e.select_all())
        ;; Copy, cut, paste
        e.DefineKey("!w", (*) => Send("^c"))
        e.DefineKey("^w", (*) => Send("^x"))
        e.DefineKey("^y", (*) => Send("^v"))
        e.DefineKey("^/", (*) => e.undo())
        e.DefineKey("^+/", (*) => e.redo())
        ;; Manipulation
        e.DefineKey("^d", (*) => e.delete_char())
        e.DefineKey("!d", (*) => e.delete_word())
        e.DefineKey("^h", (*) => e.delete_backward_char())
        e.DefineKey("!h", (*) => e.delete_backward_word())
        e.DefineKey("!t", (*) => e.transpose_words())
        e.DefineKey("^t", (*) => e.transpose_chars())
        ;; Others
        e.DefineKey("^s", (*) => Send("^f")) ;; Search
        e.DefineKey("^r", (*) => Send("^h")) ;; Replace
        e.DefineKey("^x s", (*) => Send("^s"))
        e.DefineKey("^g", (*) => e.quit())
        return e
    }
}


powerscribeKeys := EmacsKeys.bindDefaultKeys(PowerScribeApp.WinTitle)
powerscribeKeys.DefineKey("!o", (*) => PowerScribeApp.ToggleFindingsWindow())
powerscribeKeys.DefineKey("^c *", (*) => PowerScribeApp.bold_and_upper)
powerscribeKeys.DefineKey("^c -", (*) => powerscribeKeys.bullet())
powerscribeKeys.DefineKey("^c b", (*) => powerscribeKeys.bold())
powerscribeKeys.DefineKey("^x s", (*) => PowerScribeApp.SaveFindingsContent())
powerscribeKeys.DefineKey("^x o", (*) => PowerScribeApp.LoadFindingsContent())
powerscribeKeys.DefineKey("^+c", (*) => EmacsApp.CaptureReport())
powerscribeKeys.DefineKey("^+f", (*) => EmacsApp.CaptureByProtocol("F", PowerScribeApp.GetAccessionNumber(), PowerScribeApp.GetStudyDescription(), PowerScribeApp.GetStudyReport()))
powerscribeKeys.DefineKey("^+l", (*) => EmacsApp.CaptureByProtocol("L", PowerScribeApp.GetAccessionNumber(), PowerScribeApp.GetStudyDescription(), PowerScribeApp.GetStudyReport()))