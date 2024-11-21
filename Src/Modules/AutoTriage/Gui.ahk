#Requires AutoHotkey v2.0
#Include Database.ahk
#Include ../AutoTriage.ahk

ErrorLog(msg) {
	FileAppend A_Now ": " msg "`n", A_ScriptDir "\ErrorLog.txt"
}

class SelectStudyGui extends Gui {

    __New(){
        this.modalityId := 0
        super.__New(,"Select study to protocol")
        this.AddText(, "Requested study:")
        this.RequestedStudy := this.AddEdit("ys w400")
        this.RequestedStudy.Opt("ReadOnly")

        this.RememberChoice := this.AddCheckBox("xs", "Remember alias")

        Tabs := this.AddTab3("Section xs", ["Search", "Choose"])
        Tabs.UseTab(1)
        this.AddText("Section", "Filter:")
        this.FilterText := this.AddEdit("ys")
        this.ListView := this.AddListView("xs w500 r20", ["Code", "Description"])
        Tabs.UseTab(2)
        this.TreeView := this.AddTreeView("w500 r24")
        this.ListView.OnEvent("DoubleClick", LV_DoubleClick)
        this.FilterText.OnEvent("Change", OnSearchChange)
        this.TreeView.OnEvent("DoubleClick", TV_DoubleClick)

        OnSearchChange(ctrlObj, *) {
            this.ListView.Opt("-Redraw")
            this.ListView.Delete()
            db := Database(false)
            for exam in db.GetExams(this.modalityId, ctrlObj.Value) {
                this.ListView.Add(,exam.code, exam.name)
            }
            db.Close()
            this.ListView.Opt("+Redraw")
        }
        LV_DoubleClick(LV, RowNumber)
        {
            if RowNumber ; do not trigger on header row
                this.OnExamSelected(LV.GetText(RowNumber, 2))
        }
        TV_DoubleClick(TV, ID)
        {
            if TV.GetParent(ID) { ; do not trigger on top level items
                this.OnExamSelected(TV.GetText(ID))
            }
        }
    }

    OnExamSelected(canonical) {
        this.Hide()
		remember := this.RememberChoice.Value
		alias := this.RequestedStudy.Value
		db := Database(remember) ; open in read/write mode depending on checkbox
		if remember {
			db.RememberAlias(alias, canonical, this.modalityId)
		}
		result := db.GetExamMatch(this.modalityId, canonical)
		db.Close()
		if (result.count) {
			FillOutExam(result[1,"body_part"], result[1,"code"])
		}
		if remember && RegExMatch(WinGetTitle("COMRAD Medical Systems Ltd. ahk_class SunAwtFrame"), "User:(\w+)", &match) { ; Send to Firebase
			obj := Map("user",match[1],"alias",alias,"canonical",canonical,"timestamp",Map(".sv","timestamp"))
			try {
				whr := ComObject("WinHttp.WinHttpRequest.5.1")
				whr.Open("POST", "https://cogent-script-128909-default-rtdb.firebaseio.com/alias.json", true) ; async
				whr.SetRequestHeader("Content-Type", "application/json")
				whr.Send(jxon_dump(obj, 0))
				whr.WaitForResponse(3) ; timeout in 3 seconds
				;~ MsgBox "Success!`nRequest body: `n" jxon_dump(obj, 2)
			} catch Error as err {
				ErrorLog(err.Message ", Request body: '" jxon_dump(obj, 0) "'")
			}
		}
	}

    Launch(modalityId, examRequested){
        this.modalityId := modalityId
        this.RequestedStudy.Value := examRequested
        this.RememberChoice.Value := false
        this.FilterText.Value := ""
		this.ListView.Delete()
        db := Database(false)
        currentBodyPart := ""
        for exam in db.GetExams(modalityId) {
            this.ListView.Add(,exam.code, exam.name)
            if exam.body_part != currentBodyPart {
                currentBodyPart := exam.body_part
                currentBodyPartBranchId := this.TreeView.Add(currentBodyPart)
            }
            this.TreeView.Add(exam.name, currentBodyPartBranchId)
        }
        db.Close()
        this.Show()
        this.FilterText.Focus()
    }
}

class ForgetGui extends Gui {
    
    __New(){
        super.__New(,"Forget aliases")
        this.AddText("Section", "Filter:")
        this.FilterText := this.AddEdit("ys")
        this.FilterText.OnEvent("Change", OnSearchChange)
        this.ListView := this.AddListView("xs w500 r20", ["Alias", "Code", "Description"])
        this.ListView.OnEvent("ItemSelect", OnItemSelect)
        this.ForgetBtn := this.AddButton("Default w120")
        this.ForgetBtn.OnEvent("Click", OnForgetButtonClick)

        OnItemSelect(ctrlObj, item, selected){
            this.UpdateForgetButton(ctrlObj.GetCount("S"))
        }

        OnForgetButtonClick(ctrlObj, *) {
            this.Hide()
            aliases := Array()
            RowNumber := 0  ; This causes the first loop iteration to start the search at the top of the list.
            While RowNumber := this.ListView.GetNext(RowNumber) {  ; Resume the search at the row after that found by the previous iteration.
                aliases.Push(this.ListView.GetText(RowNumber))
            }
            db := Database(true)
            db.ForgetAliases(aliases)
            db.Close()
        }
    
        OnSearchChange(ctrlObj, *) {
            this.ListView.Opt("-Redraw")
            this.ListView.Delete()
            db := Database(false)
            for alias in db.GetAliases(ctrlObj.Value) {
                this.ListView.Add(, alias.name, alias.code, alias.canonical)
            }
            db.Close()
            this.ListView.Opt("+Redraw")
            this.UpdateForgetButton(0)
        }    
    
    }

    UpdateForgetButton(count){
        this.ForgetBtn.Text := "Forget " count " alias" (count = 1 ? "" : "es")
        this.ForgetBtn.Enabled := count > 0
    }

    Launch(*){
        this.FilterText.Value := ""
        this.ListView.Opt("-Redraw")
        this.ListView.Delete()
        ; db := Database(false)
        for alias in Database.GetAliases() {
            this.ListView.Add(, alias[1], alias[2], alias[3])
        }
        ; db.Close()
        this.ListView.ModifyCol()
        this.ListView.Opt("+Redraw")
        this.UpdateForgetButton(0)
        this.Show()
        this.FilterText.Focus()
    }

}