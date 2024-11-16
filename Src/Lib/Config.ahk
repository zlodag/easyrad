#Requires AutoHotkey v2.0

; #include Utils.ahk

class Config {

    static __New() {
        DirCreate this._IniPath
    }

    static _IniPath := A_MyDocuments
    ; static IniPath := A_AppData "\EasyRad"
    static _IniFilename := this._IniPath "\EasyRad.ini"

    ; static _Read(sectionName, key, default) => IniRead(this._IniFilename, sectionName, key, default)
    ; static _Write(sectionName, key, value) => IniWrite(value, this._IniFilename, sectionName, key)

    class Section {
        __New(sectionName, defaults) {
            this._sectionName := sectionName
            this._defaults := defaults
        }
        __Item[key] {
            get => IniRead(Config._IniFilename, this._sectionName, key, this._defaults.Get(key,""))
            set => IniWrite(value, Config._IniFilename, this._sectionName, key)
        }
    }

    static AutoTriage := Config.Section("AutoTriage", Map(
        "UseStudySelector", 1,
        "DefaultTriageRank", 3,
    ))
    static Comrad := Config.Section("Comrad", Map(
    ))
    class InteleViewer {
        static Sites := Map(
            "CDHB", "http://app-inteleradha-p.healthhub.health.nz",
            "PRG", "https://pacs.pacificradiology.com",
            "Reform", "https://pacs.reformradiology.co.nz",
            "Beyond", "https://pacs.beyondradiology.co.nz",
        )
    } 
    static IV := Config.Section("Inteleviewer", Map(
        "CDHB URL", Config.InteleViewer.Sites["CDHB"],
        "PRG URL", Config.InteleViewer.Sites["PRG"],
        "Reform URL", Config.InteleViewer.Sites["Reform"],
        "Beyond URL", Config.InteleViewer.Sites["Beyond"],
    ))


    ; class AutoTriage extends Config.Section {

    ;     static _SectionName := "AutoTriage"
    ;     static _UseStudySelectorKey := "UseStudySelector"
    ;     static _UseStudySelectorDefault := 1
    ;     static _DefaultTriageRankKey := "TriageRank"
    ;     static _DefaultTriageRankDefault := 3
    ;     ; static _Read(key, default) => Config._Read(this._SectionName, key, default)
    ;     ; static _Write(key, value) => Config._Write(this._SectionName, key, value)    
    ;     UseStudySelector { ; returns an integer
    ;         get => Integer(this._Read(Config.AutoTriage._UseStudySelectorKey, Config.AutoTriage._UseStudySelectorDefault))
    ;         set => this._Write(Config.AutoTriage._UseStudySelectorKey, value)
    ;     }
    ;     DefaultTriageRank {
    ;         get => this._Read(Config.AutoTriage._DefaultTriageRankKey, Config.AutoTriage._DefaultTriageRankDefault)
    ;         set => this._Write(Config.AutoTriage._DefaultTriageRankKey, value)
    ;     }
    ; }

    ; class Comrad {
    ;     static _SectionName := "Comrad"
    ;     static _UsernameKey := "Username"
    ;     static _PasswordKey := "Password"

    ;     static _Read(key, default) => Config._Read(this._SectionName, key, default)
    ;     static _Write(key, value) => Config._Write(this._SectionName, key, value)

    ;     static Username {
    ;         get => this._Read(this._UsernameKey, "")
    ;         set => this._Write(this._UsernameKey, value)
    ;     }
    ;     static PW {
    ;         get => this._Read(this._PasswordKey, "")
    ;         set => this._Write(this._PasswordKey, value)
    ;     }
    ; }



    ; __New(FileName) {
    ;     if not FileExist(FileName)
    ;         FileAppend "", FileName, "UTF-16-RAW"

    ;     this.FileName := FileName
    ;     this.Comrad := Map()
    ;     this.IV := Map("CDHB", Map(), "PRG", Map(), "Reform", Map(), "Beyond", Map())
    ;     this.loadConfig()
    ; }

    ; static loadConfig() {
    ;     this.Comrad["Username"] := IniRead(this.FileName, "Comrad", "Username", "")
    ;     this.Comrad["PW"] := IniRead(this.FileName, "Comrad", "Password", "")

    ;     this.IV["CDHB"]["Url"] := IniRead(this.FileName, "Inteleviewer", "CDHB URL", "http://app-inteleradha-p.healthhub.health.nz")
    ;     this.IV["CDHB"]["Username"] := IniRead(this.FileName, "Inteleviewer", "CDHB Username", "")
    ;     this.IV["CDHB"]["PW"] := IniRead(this.FileName, "Inteleviewer", "CDHB Password", "")
    ;     this.IV["PRG"]["Url"] := IniRead(this.FileName, "Inteleviewer", "PRG URL", "https://pacs.pacificradiology.com")
    ;     this.IV["PRG"]["Username"] := IniRead(this.FileName, "Inteleviewer", "PRG Username", "")
    ;     this.IV["PRG"]["PW"] := IniRead(this.FileName, "Inteleviewer", "PRG Password", "")
    ;     this.IV["Reform"]["Url"] := IniRead(this.FileName, "Inteleviewer", "Reform URL", "https://pacs.reformradiology.co.nz")
    ;     this.IV["Reform"]["Username"] := IniRead(this.FileName, "Inteleviewer", "Reform Username", "")
    ;     this.IV["Reform"]["PW"] := IniRead(this.FileName, "Inteleviewer", "Reform Password", "")
    ;     this.IV["Beyond"]["Url"] := IniRead(this.FileName, "Inteleviewer", "Beyond URL", "https://pacs.beyondradiology.co.nz")
    ;     this.IV["Beyond"]["Username"] := IniRead(this.FileName, "Inteleviewer", "Beyond Username", "")
    ;     this.IV["Beyond"]["PW"] := IniRead(this.FileName, "Inteleviewer", "Beyond Password", "")
        
    ;     this.AutoTriage := {
    ;         UseStudySelector: Integer(IniRead(this.FileName, Config.AutoTriageSectionName, Config.AutoTriageUseStudySelectorKey, Config.AutoTriageUseStudySelectorDefault)),
    ;         DefaultTriageRank: Integer(IniRead(this.FileName, Config.AutoTriageSectionName, Config.AutoTriageDefaultTriageRankKey, Config.AutoTriageDefaultTriageRankDefault)),
    ;     }
    ; }

    ; saveConfig() {
    ;     IniWrite(this.Comrad["Username"], this.FileName, "Comrad", "Username")
    ;     IniWrite(this.Comrad["PW"], this.FileName, "Comrad", "Password")

    ;     IniWrite(this.IV["CDHB"]["Url"], this.FileName, "Inteleviewer", "CDHB URL")
    ;     IniWrite(this.IV["CDHB"]["Username"], this.FileName, "Inteleviewer", "CDHB Username")
    ;     IniWrite(this.IV["CDHB"]["PW"], this.FileName, "Inteleviewer", "CDHB Password")

    ;     IniWrite(this.IV["PRG"]["Url"], this.FileName, "Inteleviewer", "PRG URL")
    ;     IniWrite(this.IV["PRG"]["Username"], this.FileName, "Inteleviewer", "PRG Username")
    ;     IniWrite(this.IV["PRG"]["PW"], this.FileName, "Inteleviewer", "PRG Password")

    ;     IniWrite(this.IV["Reform"]["Url"], this.FileName, "Inteleviewer", "Reform URL")
    ;     IniWrite(this.IV["Reform"]["Username"], this.FileName, "Inteleviewer", "Reform Username")
    ;     IniWrite(this.IV["Reform"]["PW"], this.FileName, "Inteleviewer", "Reform Password")

    ;     IniWrite(this.IV["Beyond"]["Url"], this.FileName, "Inteleviewer", "Beyond URL")
    ;     IniWrite(this.IV["Beyond"]["Username"], this.FileName, "Inteleviewer", "Beyond Username")
    ;     IniWrite(this.IV["Beyond"]["PW"], this.FileName, "Inteleviewer", "Beyond Password")

    ;     IniWrite(this.AutoTriage.UseStudySelector, this.FileName, Config.AutoTriageSectionName, Config.AutoTriageUseStudySelectorKey)
    ;     IniWrite(this.AutoTriage.DefaultTriageRank, this.FileName, Config.AutoTriageSectionName, Config.AutoTriageDefaultTriageRankKey)
    ; }
}