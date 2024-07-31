#Include ../Common.ahk

class RadWhereCOM {
    __New() {
        this.ctrl := ComObject("RadWhereAx.RadWhereCtrl.1")
    }

    accessionNumbers {
        get {
            return this.ctrl.accessionNumbers
        }
    }

    LoggedIn {
        get {
            return this.ctrl.LoggedIn
        }
    }

    Start() {
        this.ctrl.Start()
    }

    InsertAutoText(name, replace := false) {
        If not this.LoggedIn
            this.Start()
        this.ctrl.InsertAutoText(name, replace)
    }
}