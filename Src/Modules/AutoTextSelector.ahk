#Include ../Common.ahk

class AutoTextSelectorGui extends Gui {
    __New(radwhere) {
        super.__new(, "AutoText", this) ;; set the event sink to this object
        if not radwhere.LoggedIn
            radwhere.Start()

        this.Add("GroupBox", , "Body")
        this.Add("Button", "w60 h50 Section", "Chest").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))
        this.Add("Button", "w60 h50", "Abdomen").OnEvent("Click", (*) => radwhere.InsertAutoText("xray abdo"))
        this.Add("Button", "w60 h50 Section ys", "C spine").OnEvent("Click", (*) => radwhere.InsertAutoText("xray c"))
        this.Add("Button", "w60 h50 xp", "T spine").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))
        this.Add("Button", "w60 h50 xp", "L spine").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))
        this.Add("Button", "w60 h50 xp", "Pelvis").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))
        this.Add("Button", "w60 h50 Section ys", "Trauma").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))
        this.Add("Button", "w60 h50 xp", "Post cast").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))
        this.Add("Button", "w60 h50 xp", "Post hip").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))
        this.Add("Button", "w60 h50 xp", "Post knee").OnEvent("Click", (*) => radwhere.InsertAutoText("xray chest"))

        CoordMode "Mouse", "Screen"
        MouseGetPos(&xps, &ypos)
        this.Show("x" xps " y" ypos)
    }
}