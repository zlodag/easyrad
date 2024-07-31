#include ../Common.ahk

class InteleViewerCOM {
    sid_regex := "PACS_SESSION_ID=(?P<sid>[a-z0-9]{32})"

    __New(url, username, password) {
        this.url := url
        this.username := username
        this.password := password
        this.client := this.SessionClient(url, username, password)
        this.sessionId := this.GetSessionId()
        this.viewer := this.CreateViewer()
    }

    static ConnectExistingSession() {
        ;; Open log file
        ;; return
    }

    SessionClient(url, username, password) {
        auth_url := url . "/Portal/login/ws/auth"
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", auth_url, true)
        whr.SetRequestHeader("Content-type", "application/x-www-form-urlencoded;charset=UTF-8")
        data := Format('username={1}&password={2}&mfaToken=&keepMeLoggedIn=false', username, password)
        whr.Send(data)
        whr.WaitForResponse()
        return whr
    }

    GetSessionId() {
        Cookies := this.client.getAllResponseHeaders()
        RegExMatch(Cookies, this.sid_regex, &result)
        return result.sid
    }

    CreateViewer() {
        oviewer := ComObject("InteleViewerServer.InteleViewerControl")
        oViewer.baseUrl := this.url
        oViewer.username := this.username
        oViewer.waitForLaunch := 1
        oViewer.sessionId := this.sessionId
        return oViewer
    }

    GetPriorStudies(NHI) {
        ;; Queries the Intelerad server for a string of prior studies
        ;; Caches the result for the current NHI
        static CurrentNHI := NHI
        static Response := ""

        if (CurrentNHI != NHI) or ( not Response) {
            url := this.url "/InteleBrowser/InteleBrowser.Search"

            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("POST", url, true)
            whr.SetRequestHeader("Content-type", "application/x-www-form-urlencoded")
            whr.Send("UserName=" this.username "&SID=" this.sessionId "&sf0=" NHI "&comparator0=EQUALS&searchScope=internal&Action=appletsearch&searchProtocolVersion=4")
            whr.WaitForResponse()
            Response := whr.ResponseText
        }
        return Response
    }

    OpenViaNHI(nhi) {
        this.viewer.loadOrder(0, nhi)
    }

    OpenViaAccession(accession) {
        try {
            this.viewer.loadOrderByAccessionNum(accession)
        } catch Error {
            MsgBox , , "Something went wrong, contact Tubo"
        }
    }
}