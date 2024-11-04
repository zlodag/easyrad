class ConcertoWeb {

    static GetIVSessionKey(username) {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        url := Format("https://app-cisintv-p.healthhub.health.nz/?method=view&userid={}&debug=0&nhi=0&accno=0", username)
        whr.Open("GET", url, true)
        whr.Send()
        whr.WaitForResponse()
        page := whr.ResponseText
        RegExMatch(page, "[a-z0-9]{32}", &SessionKey)
        return SessionKey[]
    }

    static OpenPatientProfile(NHI) {
        url := "https://adfs.cdhb.health.nz/adfs/ls/idpinitiatedsignon.aspx?RelayState=RPID%3Dapp-ciscp-p%26RelayState%3Dhttps%253A%252F%252Fapp-ciscp-p.healthhub.health.nz%252Flogin-auth%252Fsaml%253Fpath%253D%252Fpatient%252F" . nhi . "%25402.16.840.1.113883.2.18.2%252Fportal"
        Run "msedge.exe " url " --new-window"
    }

    static OpenHighlightedPatientProfile() {
        oldClip := A_Clipboard
        A_Clipboard := ""
        Send "^c"
        ClipWait 1
        this.OpenPatientProfile(A_Clipboard)
        A_Clipboard := oldClip
    }
}