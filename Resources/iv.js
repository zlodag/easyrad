function init(action, userid, sid, nhi, accno, debug) {
    
    switch (action) {
        case "view":
        case "launch":
            launchViewer(action, userid, sid, nhi, accno, debug);
            break;
        case "shutdown":
            shutdownViewer();
            break;
    }
    // close ourselves
    if (parent.opener && !debug) {
        window.close();
    }

}

function launchViewer(action, userid, sid, nhi, accno, debug) {
    var rc = 0;
    
    try {
        oViewer = new ActiveXObject("InteleViewerServer.InteleViewerContro.1");
        document.write("<div class=\"instructions\"><table><tr><th span=\"1\" style=\"width:90%;\">Using InteleViewer Via HCS</th></tr>"
		+ "<tr><td colspan=\"2\" style=\"color:#172271\"><b><u>DICOM Index: Enable Access PRG/CRG and Southern DHB Imaging</u></b></td></tr>"
		+ "<tr><td>To view imaging in South Island Regional PACS (SIRPACS), Pacific Radiology Group (CRG) and Southern DHB (SDHB) imaging.<br/>NOTE: Patient must already have prior SIRPACS studies for indexed imaging to be available. See below in âKey Pointsâ for instructions if you cannot see CRG/SDHB imaging.<ol><li>Click on a case from the Studies list and drag the image down to the main viewing area.</li>"
		+ "<li>Click the <u>View Reports</u> button.  Available CRG and SDHB reports are appended to the end of the SIRPACS list.</li>"
		+ "<li>Confirm the identity of the patient, and tick the Same Patient box.</li>"
		+ "<li>Return to the main InteleViewer window to view the full Studies list.<br/>Note: This symbol indicates unretrieved CRG and SDHB imaging.   "
		+ "<img src=\"/images/CloudDownload.png\" alt=\"Cloud Download Image\" width=\"29px\" height=\"26px\"></li></ol></td>"
		+ "<td><img src=\"/images/ViewReports.png\" alt=\"View Reports Image\" width=\"139px\" height=\"74px\">"
		+ "<br/><br/><img src=\"/images/SamePatient.png\" alt=\"Same Patient Image\" width=\"181px\" height=\"86px\"></td></tr>"
		+ "<tr><td colspan=\"2\"><i><u>Key points:</u>"
		+ "<ul><li>IF NO PRIOR SIRPACS imaging, you will NOT be able to see CRG/SDHB Imaging immediately. Contact SIRPACS Team x80333 or pacs@cdhb.health.nz to enquire if CRG/SDHB can be manually retrieved.</li>"
		+ "<li>If you do not get the retrieve message Yes/No box, perform manual search same as instructions below under <u>Entering Impressions, steps 1-4 first.</u></li>"
		+ "<li>Confirm the 'CRG and SDHB'-suffixed patient details match.</li>"
		+ "<li>Larger studies, ie CT/MR, may take several minutes to fully retrieve.</li>"
		+ "<li>Retrieve only the specific studies needed as part of patient's clinical care.</li>"
		+ "<li>The DICOM Index will only update when a final report is available against that study"		
		+ "<li>Imaging marked VIP or for an opted-out patient will not display.</li></ul></i></td></tr>"
		+ "<tr><td colspan=\"2\" style=\"color:#172271\"><b><u>Entering Impressions</u></b></td></tr>"
		+ "<tr><td>To activate the option to enter an impression against a patient visit:"
		+ "<ol><li>Click the <u>Search Tool</u> button. <img src=\"/images/SearchTool.png\" alt=\"Search Tool Image\" width=\"33px\" height=\"38px\"></li>"
		+ "<li>On the Search tab, enter the patient NHI and press <u>Enter</u>.</li><li>Find and double-click the required study in the list.</li>"
		+ "<li>When opened, click <u>View Reports</u>.</li><li>The <u>Impressions</u> button should now be active.</li></ol></td>"
		+ "<td><img src=\"/images/ViewReports.png\" alt=\"View Reports Image\" width=\"139px\" height=\"74px\">"
		+ "<br/><br/><img src=\"/images/Impressions.png\" alt=\"Impressions Image\" width=\"119px\" height=\"79px\"></td></tr>"
		+ "<tr><td colspan=\"2\" style=\"color:#172271\"><b><u>Accessing InteleViewer Directly from the Desktop</u></b></td></tr>"
		+ "<tr><td colspan=\"1\">You are also able to access InteleViewer directly from the desktop.  "
		+ "Click on the InteleViewer icon on the desktop or launch bar to access the application.</td>"
		+ "<td><img src=\"/images/InteleViewerIcon.png\" alt=\"InteleViewer Image\" width=\"35px\" height=\"35px\"></td></tr>"
		+ "<td colspan=\"2\"><br/>Note: InteleViewer has a separate login and password."
		+ "<br/><i>Please contact the SIRPACS Team on <b>x80333 (03 364-0333)</b> for direct login assistance.</i></font></td></tr></table>"
		+ "</div>");
    } catch (e) {
        document.write("<div class=\"error\"><b>Error: Unable to run the InteleViewer program on your PC.</b>"
		+ "<br/>(Reason: " + e.message + ")");
        document.write("<p>This problem is most likely due to your PC not having InteleViewer installed.</p>"
		+ "<p>Please contact the PACS Help Desk on extn 80333 (03 364-0333) for assistance <br/>OR you may like to request PACS access by <br/>printing and completing the <a href=\"http://intraweb.cdhb.local/pacs/PACS-Access.htm\">PACS Access Request Form</a> on our Intranet</p></div>");
        return;
    }
    if (debug == 1) {
        document.write("<br/>Control Version: " + oViewer.interfaceVersion);
        document.write("<br/>User: " + userid);
        document.write("<br/>SID: " + sid);
        document.write("<br/>NHI: " + nhi);
        document.write("<br/>Accession : " + accno);
    }

    //oViewer.baseUrl = "http://database1";
    oViewer.baseUrl = "http://app-intelerad-p.healthhub.health.nz";
    //oViewer.baseUrl = "http://159.117.33.40";
    // Testing for PACS
    //oViewer.baseUrl = "http://159.117.33.41";
    //oViewer.baseUrl = "http://database2";

    oViewer.username = userid;
    oViewer.sessionId = sid;
    oViewer.waitForLaunch = 1;
    try {
        if (action == "view") {
            oViewer.loadOrderByAccessionNum(accno);
        } else {
            oViewer.launch();
        }
    } catch (e) {
        document.write("<p>Error: " + (e.number & 0x00FF) + " " + e.message + "<br/>");
        rc = 1;
        return false;
    }

    // loaded
    self.opener = self;
    var progress = document.getElementById("statusmsg");
    if (debug) progress.innerHTML += "<br>Session loaded.";

    return true;
}

function shutdownViewer() {
    var rc = 0;
    if (debug) { document.write("<br/>Shutting down InteleViewer..."); }
    try {
        oViewer = new ActiveXObject("InteleViewerServer.InteleViewerContro.1");
        oViewer.shutdown();
    } catch (e) {
        document.write((e.number & 0x00FF) + " " + e.description + "<br>");
        return;
    }
}