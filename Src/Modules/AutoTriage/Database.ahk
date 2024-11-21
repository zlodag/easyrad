#Requires AutoHotkey v2.0
#Include ../../Lib/SQLite/SQLite.ahk
#Include ../../Lib/Class_SQLiteDB.ahk
; todo - refactor to use Class_SQLiteDB and prepared statements https://www.autohotkey.com/boards/viewtopic.php?f=83&t=95389

class Database {

    static _DbFilename := "Database/AutoTriage.sqlite3"
    
    static _db := SQLiteDB()

    static __New() {
        if !FileExist(Database._DbFilename) {
            if (A_IsCompiled) {
                DirCreate "Database"
                FileInstall "Database/AutoTriage.sqlite3", Database._DbFilename
            } else {
                throw Error("Database file not found", , Database._DbFilename)
            }
        }
        this._db.OpenDB(Database._DbFilename, "W", false)
        OnExit((*) => this._db.CloseDB())
    }

    static GetExams(modalityId, searchStr := "") {
        query := "SELECT code, examination.name, body_part.name AS body_part FROM examination JOIN body_part ON examination.body_part = body_part.id WHERE modality = " modalityId
		if StrLen(searchStr) {
			query .= " AND (examination.name LIKE '%" searchStr "%' OR code LIKE '%" searchStr "%')"
		}
		query .= " ORDER BY examination.body_part, examination.name"
        return this._db.Exec(query).rows
    }

    static GetAliases(searchStr := "") {

        query := "SELECT label.name, code, examination.name AS canonical FROM label JOIN examination ON label.examination = examination.id"
        if StrLen(searchStr) {
            query .= " WHERE label.name LIKE '%?1%' OR examination.name LIKE '%?1%' OR code LIKE '%?1%'"
        }
        query .= " ORDER BY modality, body_part, examination.name"
        if !this._db.Prepare(query, &Prepared)
            throw Error("Msg:`t" . this._db.ErrorMsg . "`nCode:`t" . this._db.ErrorCode)
        try {
            if StrLen(searchStr) && !Prepared.Bind(Map("Text", searchStr))
                throw Error("Msg:`t" . Prepared.ErrorMsg . "`nCode:`t" . Prepared.ErrorCode)
            result := []
            while (RC := Prepared.Step(&Row)) > 0 {
                result.Push(Row.Clone())
            }
            if (RC = 0) {
                throw Error("Msg:`t" . Prepared.ErrorMsg . "`nCode:`t" . Prepared.ErrorCode)
            }
            return result
        } finally {
            Prepared.Free()
        }
    }

    static GetExamMatch(modalityId, name) {
        result := this._db.Exec("SELECT body_part.name AS body_part, code FROM label JOIN examination ON label.examination = examination.id JOIN body_part ON examination.body_part = body_part.id WHERE modality = " modalityId " AND label.name = '" name "'")
        if (!result.count) {
            result := this._db.Exec("SELECT body_part.name AS body_part, code FROM examination JOIN body_part ON examination.body_part = body_part.id WHERE modality = " modalityId " AND examination.name = '" name "'")
        }
        return result
    }

    static RememberAlias(alias, canonical, modalityId) => this._db.Exec("INSERT INTO label (name, examination) VALUES ('" alias "', (SELECT id FROM examination WHERE name = '" canonical "' and modality = '" modalityId "'))")

    static ForgetAliases(aliases) {
        query := "DELETE FROM label WHERE name IN ("
        for alias in aliases {
            if A_Index > 1
				query .= ","
            query .= "'" alias "'"
        }
        query .= ")"
        this._db.Exec(query)
    }

    ; static Close() => this._db.Close()

}