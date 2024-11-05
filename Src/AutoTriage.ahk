;@Ahk2Exe-SetVersion 0.0.3
#Requires AutoHotkey v2.0
#Include <SQLite\SQLite>
#Include <_JXON>
#SingleInstance Force
SetTitleMatchMode 1

DbFilename := "Database.sqlite3"
if A_IsCompiled && !FileExist(DbFilename) {
	FileInstall "Database.sqlite3", DbFilename
}
;~ if MsgBox("Overwrite existing database?",,"Y/N Icon?") == "Yes"

DirCreate A_AppData "\AutoTriage"
IniFilename := A_AppData "\AutoTriage\Settings.ini"

IniSettingsSectionName := "Settings"
IniKeySettingEnableStudySelector := "EnableStudySelector"
ClickLocation := {x: 16, y: 114}
DefaultEnableStudySelector := 1
StudySelectorMenuName := "Use study selector"
IniDefaultsSectionName := "Defaults"
IniKeyDefaultTriageRank := "TriageRank"
DefaultTriageRank := 3
TriageRankDisabledMenuName := "Disabled"


; ERROR_LOG SETUP

ErrorLog(msg) {
	FileAppend A_Now ": " msg "`n", A_ScriptDir "\ErrorLog.txt"
}

; TRAY MENU SETUP

SetChecked(MyMenu, ItemName, checked) {
	if checked
		MyMenu.Check(ItemName)
	else
		MyMenu.Uncheck(ItemName)
}
GetEnableStudySelector() => IniRead(IniFilename, IniSettingsSectionName, IniKeySettingEnableStudySelector, DefaultEnableStudySelector)
SetEnableStudySelector(enabled) => IniWrite(enabled, IniFilename, IniSettingsSectionName, IniKeySettingEnableStudySelector)
GetDefaultTriageRank() => IniRead(IniFilename, IniDefaultsSectionName, IniKeyDefaultTriageRank, DefaultTriageRank)
SetDefaultTriageRank(rank) => IniWrite(rank, IniFilename, IniDefaultsSectionName, IniKeyDefaultTriageRank)
SettingEnableStudySelectorMenuCallback(ItemName, ItemPos, MyMenu) {
	EnableStudySelector := GetEnableStudySelector()
	SetEnableStudySelector(!EnableStudySelector)
	SetChecked(MyMenu, ItemName, !EnableStudySelector)
}
DefaultTriageRankMenuCallback(MenuItemSelected, *) {
	SetDefaultTriageRank(TriageRankDisabledMenuName = MenuItemSelected ? 0 : MenuItemSelected)
	UpdateDefaultTriageRankMenu(MenuItemSelected)
}
UpdateDefaultTriageRankMenu(MenuItemSelected) {
	SetChecked(DefaultTriageRankMenu, TriageRankDisabledMenuName, TriageRankDisabledMenuName = MenuItemSelected)
	Loop 5
		SetChecked(DefaultTriageRankMenu, A_Index, A_Index = MenuItemSelected)
}

A_TrayMenu.Add()
DefaultTriageRankMenu := Menu()
DefaultTriageRankMenu.Add(TriageRankDisabledMenuName, DefaultTriageRankMenuCallback)
Loop 5 {
	DefaultTriageRankMenu.Add(A_Index, DefaultTriageRankMenuCallback)
}
UpdateDefaultTriageRankMenu(GetDefaultTriageRank() || TriageRankDisabledMenuName)
A_TrayMenu.Add("Default rank", DefaultTriageRankMenu)
A_TrayMenu.Add(StudySelectorMenuName, SettingEnableStudySelectorMenuCallback)
SetChecked(A_TrayMenu, StudySelectorMenuName, GetEnableStudySelector())
A_TrayMenu.Add("Forget alias", ForgetAlias)

class Request {
	__New(strToParse) {
		Loop Parse StrReplace(strToParse, ", ", "�"), "�"
		{
			keyVal := StrSplit(A_LoopField, "=",,2)
			switch keyVal[1] {
				case "rf_exam_type":
					switch keyVal[2] {
						case "CT": this.modalityId := 1
						case "MR": this.modalityId := 2
						case "US": this.modalityId := 3
						case "SC": this.modalityId := 4
						default:
							this.modalityId := 0
							TrayTip 'Modality "' keyVal[2] '" not supported'
							;~ Exit
						;~ case "MR": this.modalityId := 2
					}
				case "rf_reason":
					this.exam := keyVal[2]
					this.exam := StrReplace(this.exam, "LEFT")
					this.exam := StrReplace(this.exam, "RIGHT")
					this.exam := StrReplace(this.exam, "PLEASE") ; no special treatment for politeness
					this.exam := RegExReplace(this.exam, "\bAND\b", " ")
					this.exam := Trim(this.exam)
					this.exam := RegExReplace(this.exam, "\s+", " ")
				case "rf_original_priority":
					this.priority := keyVal[2]
			}
		}
		if !this.HasOwnProp("priority") || !this.HasOwnProp("exam") || !this.HasOwnProp("modalityId") {
			TrayTip "Click on the referral in the left pane and try again"
			Exit
		}
	}
	Print() {
		TrayTip "ModalityId: " this.modalityId "`nExam requested: " this.exam "`nPriority: " this.priority
	}
}


GetRequest(str) {
	if RegExMatch(str, "\[(.*)\]", &match) {
		return Request(match[1])
	} else {
		TrayTip "No match"
		Exit
	}
}


OpenDb(writeable) => SQLite(DbFilename, writeable ? SQLITE_OPEN_READWRITE : SQLITE_OPEN_READONLY)

GetExamMatch(modalityId, name, db) {
	result := db.Exec("SELECT body_part.name AS body_part, code FROM label JOIN examination ON label.examination = examination.id JOIN body_part ON examination.body_part = body_part.id WHERE modality = " modalityId " AND label.name = '" name "'")
	if (!result.count) {
		result := db.Exec("SELECT body_part.name AS body_part, code FROM examination JOIN body_part ON examination.body_part = body_part.id WHERE modality = " modalityId " AND examination.name = '" name "'")
	}
	return result
}

FillOutExam(bodyPart, code) {
	; Fill out body part with minimal keystrokes
	switch bodyPart {
		case "CHEST/ABDO": SendEvent "CHEST/"
		case "CHEST": SendEvent "{Home}C"
		default:
			firstLetter := SubStr(bodyPart, 1,  1)
			switch firstLetter {
				case "A","N","O","S": SendEvent SubStr(bodyPart, 1,  2)
				default: SendEvent firstLetter
			}

	}
	SendEvent "{Tab 7}{Home}{Tab}" code "+{Tab}" ;  Tab to "Code" cell (need 7 rather than 6 if CONT_SENST is showing), enter code, Shift-tab out of cell

}

ShowStudySelector(modalityId, examRequested){

	db := OpenDb(false)

	MyGui := Gui(,"Select study")
	MyGui.AddText(, "Requested study:")
	RequestedStudy := MyGui.AddEdit("ys w400", examRequested)
	RequestedStudy.Opt("ReadOnly")

	RememberChoice := MyGui.AddCheckBox("xs", "Remember alias")
	;~ RememberChoice.Value := false

	Tabs := MyGui.AddTab3("Section xs", ["Search", "Choose"])
	Tabs.UseTab(1)
	MyGui.AddText("Section", "Filter:")
	FilterText := MyGui.AddEdit("ys")
	ListView := MyGui.AddListView("xs w500 r20", ["Code", "Description"])
	Tabs.UseTab(2)
	TreeView := MyGui.AddTreeView("w500 r24")
	ListView.OnEvent("DoubleClick", LV_DoubleClick)
	FilterText.OnEvent("Change", OnSearchChange)
	TreeView.OnEvent("DoubleClick", TV_DoubleClick)

	currentBodyPart := ""
	for exam in db.Exec("SELECT code, examination.name, body_part.name AS body_part FROM examination JOIN body_part ON examination.body_part = body_part.id WHERE modality = " modalityId " ORDER BY examination.body_part, examination.name").rows {
		ListView.Add(,exam.code, exam.name)
		if exam.body_part != currentBodyPart {
			currentBodyPart := exam.body_part
			currentBodyPartBranchId := TreeView.Add(currentBodyPart)
		}
		TreeView.Add(exam.name, currentBodyPartBranchId)
	}
	db.Close()
	FilterText.Focus()
	MyGui.Show()

	LV_DoubleClick(LV, RowNumber)
	{
		if RowNumber ; do not trigger on header row
			OnExamSelected(LV.GetText(RowNumber, 2))
	}
	TV_DoubleClick(TV, ID)
	{
		if TV.GetParent(ID) { ; do not trigger on top level items
			OnExamSelected(TV.GetText(ID))
		}
	}
	OnExamSelected(canonical) {
		remember := RememberChoice.Value
		alias := RequestedStudy.Value
		MyGui.Destroy()
		db := OpenDb(remember) ; open in read/write mode depending on checkbox
		if remember {
			db.Exec("INSERT INTO label (name, examination) VALUES ('" alias "', (SELECT id FROM examination WHERE name = '" canonical "' and modality = '" modalityId "'))")
		}
		result := GetExamMatch(modalityId, canonical, db)
		db.Close()
		if (result.count) {
			FillOutExam(result[1,"body_part"], result[1,"code"])
		}
		if remember && RegExMatch(WinGetTitle("COMRAD Medical Systems Ltd. ahk_class SunAwtFrame"), "User:(\S+)", &match) { ; Send to Firebase
			obj := Map("user",match[1],"alias",alias,"canonical",canonical,"timestamp",Map(".sv","timestamp"))
			try {
				whr := ComObject("WinHttp.WinHttpRequest.5.1")
				whr.Open("POST", "https://cogent-script-128909-default-rtdb.firebaseio.com/alias.json", false) ; sync
				whr.SetRequestHeader("Content-Type", "application/json")
				whr.Send(jxon_dump(obj, 0))
				;~ whr.WaitForResponse(3) ; timeout in 3 seconds
				;~ MsgBox "Success!`nRequest body: `n" jxon_dump(obj, 2)
			} catch Error as err {
				ErrorLog(err.Message ", Request body: '" jxon_dump(obj, 0) "'")
			}
		}
	}
	OnSearchChange(ctrlObj, *) {
		ListView.Opt("-Redraw")
		ListView.Delete()
		query := "SELECT code, examination.name, body_part.name AS body_part FROM examination JOIN body_part ON examination.body_part = body_part.id WHERE modality = " modalityId
		if StrLen(ctrlObj.Value) {
			query .= " AND (examination.name LIKE '%" ctrlObj.Value "%' OR examination.code LIKE '%" ctrlObj.Value "%')"
		}
		query .= " ORDER BY examination.body_part, examination.name"
		db := OpenDb(false)
		for exam in db.Exec(query).rows {
			ListView.Add(,exam.code, exam.name)
		}
		db.Close()
		ListView.Opt("+Redraw")
	}
}

; HOTKEYS

^+f::
ForgetAlias(*)
{
	ForgetGui := Gui(,"Forget alias")
	ForgetGui.AddText("Section", "Filter:")
	FilterText := ForgetGui.AddEdit("ys")
	FilterText.OnEvent("Change", OnSearchChange)
	ListView := ForgetGui.AddListView("xs w500 r20", ["Alias", "Code", "Description"])

	db := OpenDb(false)
	for label in db.Exec("SELECT label.name AS alias, code, examination.name AS canonical FROM label JOIN examination ON label.examination = examination.id ORDER BY modality, body_part, examination.name").rows {
		ListView.Add(, label.alias, label.code, label.canonical)
	}
	db.Close()
	ListView.ModifyCol()
	ListView.OnEvent("ItemSelect", OnItemSelect)
	ForgetBtn := ForgetGui.AddButton("Default w80")
	UpdateForgetButton(0)
	ForgetBtn.OnEvent("Click", OnForgetButtonClick)  ; Call MyBtn_Click when clicked.
	FilterText.Focus()
	ForgetGui.Show()

	OnItemSelect(ctrlObj, item, selected){
		UpdateForgetButton(ctrlObj.GetCount("S"))
	}
	UpdateForgetButton(count){
		ForgetBtn.Text := "Forget " count " item" (count = 1 ? "" : "s")
		ForgetBtn.Enabled := count > 0
	}
	OnForgetButtonClick(ctrlObj, *) {
		query := "DELETE FROM label WHERE name IN ("
		RowNumber := 0  ; This causes the first loop iteration to start the search at the top of the list.
		Loop
		{
			First := (RowNumber = 0)
			RowNumber := ListView.GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
			if not RowNumber  ; The above returned zero, so there are no more selected rows.
				break
			else if !First
				query .= ","
			Text := ListView.GetText(RowNumber)
			query .= "'" Text "'"
		}
		query .= ")"
		ForgetGui.Destroy()
		db := OpenDb(true)
		db.Exec(query)
		db.Close()
	}
	OnSearchChange(ctrlObj, *) {
		ListView.Opt("-Redraw")
		ListView.Delete()
		query := "SELECT label.name AS alias, code, examination.name AS canonical FROM label JOIN examination ON label.examination = examination.id"
		if StrLen(ctrlObj.Value) {
			query .= " WHERE label.name LIKE '%" ctrlObj.Value "%' OR examination.name LIKE '%" ctrlObj.Value "%' OR code LIKE '%" ctrlObj.Value "%'"
		}
		query .= " ORDER BY modality, body_part, examination.name"
		db := OpenDb(false)
		for label in db.Exec(query).rows {
			ListView.Add(, label.alias, label.code, label.canonical)
		}
		db.Close()
		ListView.Opt("+Redraw")
		UpdateForgetButton(0)
	}
}


#HotIf WinActive("COMRAD Medical Systems Ltd. ahk_class SunAwtFrame")

;~ t:: ; test clipboard 
;~ {
	;~ A_Clipboard := ""
	;~ SendEvent "^c" ; Copy
	;~ if !ClipWait(0.25)
		;~ ToolTip "No request found"
	;~ else if RegExMatch(A_Clipboard, "\[.*\]")
		;~ ToolTip "Success!"
	;~ else
		;~ ToolTip "Failure, copied: " A_Clipboard
;~ }

MButton::
Numpad0::
Numpad1::
Numpad2::
Numpad3::
Numpad4::
Numpad5::
{
	if ThisHotkey = "MButton" {
		MouseGetPos ,,&win
		if (win != WinGetID()) {
			Click "M"
			Exit
		}
	}
	SendEvent "!c" ; Close any AMR popup with Alt+C

	; Click on the left panel

	MouseGetPos &x, &y, &win
	if ThisHotkey = "MButton" && win != WinGetID() {
		Click "M"
		Exit
	}

	; Click on the triage tree pane
	;~ DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
	;~ DllCall("Shcore.dll\GetDpiForMonitor", "ptr", DllCall("MonitorFromWindow", "ptr", WinGetID(), "int", 2, "ptr"), "int", 0, "uint*", &dpiX := 0, "uint*", &dpiY := 0)
	;~ Click ClickLocation.x*dpiX//A_ScreenDPI, ClickLocation.y*dpiY//A_ScreenDPI
	;~ MouseMove x, y

	; OR

	; https://www.ibm.com/docs/en/sdk-java-technology/8?topic=applications-default-swing-key-bindings
	; Automatically moves focus if on triage
	; F8 Move to splitter bar
	; F6 Move between panes (need to do this twice to get out of the pdf viewer)
	;~ SendEvent "^{Up}{F8}{F6}{Tab}" ; Move from page to tab (escapes from pdf)
	; OR
	;~ SendEvent "{F6}{F8}{F6}{Tab}"
	; OR
	SendEvent "{F6}{Tab}" ; Fast, but causes a problem by launching the chat window if the user is higher than the main panes in the hierarchy, e.g. if Autonext has just been toggled and focus has not been returned to the panes

	RestoreClipboard := A_Clipboard
	A_Clipboard := ""
	SendEvent "^c" ; Copy
	if !ClipWait(0.1) { ; the focus may have orignally been on the pdf viewer
		SendEvent "{F6}{Tab}^c"
		if !ClipWait(0.1) {
			TrayTip "No request found"
			Exit
		}
	}

	r := GetRequest(A_Clipboard)
	SendEvent "{Tab}" ; Tab to "Radiology Category"
	switch {
		case r.priority == "null": ; No "Clinical category" copied
			TrayTip "No clinical category",,2
		case InStr(r.priority, "Immediate", 0): ; STAT
			SendEvent "{Home}S"
		case InStr(r.priority, "24 hours", 0): ; 24 hours
			SendEvent "{Home}2"
		case InStr(r.priority, "4 hours", 0): ; 4 hours (this line has to be after the line matching 24 hours)
			SendEvent "{Home}4"
		case InStr(r.priority, "days", 0): ; 2(-3) days
			SendEvent "{Home}22"
		case InStr(r.priority, "2 weeks", 0): ; 2 weeks
			SendEvent "{Home}222"
		case InStr(r.priority, "4 weeks", 0): ; 4 weeks
			SendEvent "{Home}44"
		case InStr(r.priority, "6 weeks", 0): ; 6 weeks - never used
			SendEvent "{Home}6"
		default: ; Planned
			SendEvent "{Home}P"
	}
	SendEvent "{Tab 7}" ; Tab to "Rank"
	switch ThisHotkey {
		case "Numpad0": TriageRank := 0
		case "Numpad1": TriageRank := 1
		case "Numpad2": TriageRank := 2
		case "Numpad3": TriageRank := 3
		case "Numpad4": TriageRank := 4
		case "Numpad5": TriageRank := 5
		default: TriageRank := Integer(GetDefaultTriageRank()) ; 0 if disabled
	}
	if TriageRank {
		SendEvent "^a" ; Select all
		SendEvent TriageRank ; Set rank
	}
	SendEvent "{Tab 2}" ; Tab to "Body Part"
	if r.modalityId {
		db := OpenDb(false)
		result := GetExamMatch(r.modalityId, r.exam, db)
		db.Close()
		if (result.count) {
			FillOutExam(result[1,"body_part"], result[1,"code"])
		} else if (GetEnableStudySelector()) {
			ShowStudySelector(r.modalityId, r.exam)
		}
	}
	A_Clipboard := RestoreClipboard
}

RButton::
NumpadEnter::
{
	MouseGetPos &x, &y, &win
	if (win = WinGetID()) {
		SendEvent "!s" ; "Save as Complete" with Alt+S
		;~ SendEvent "!k" ; "Skip" with Alt+K - for testing
	} else if ThisHotkey = "RButton" {
		Click "R"
	}
}
