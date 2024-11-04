#Include ../Common.ahk

class AutoTextSelectorGui extends Gui {
    __New(radwhere) {
        super.__new("-SysMenu AlwaysOnTop", "Insert AutoText", this) ;; set the event sink to this object
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
}

; Debug only
; radwhere := RadWhereCOM()
; `:: AutoTextSelectorGui(radwhere)
