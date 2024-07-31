#include ../Common.ahk

GroupAdd "RadiologyGroup", "ahk_exe InteleViewer.exe"
GroupAdd "RadiologyGroup", PowerscribeApp.WinTitle
GroupAdd "ViewerGroup", "^ ahk_exe InteleViewer.exe", , , InteleviewerApp.WinTitle_Search
GroupAdd "EditorGroup", PowerScribeApp.WinTitle
GroupAdd "EditorGroup", "^ ahk_exe emacs.exe"

toggleInfoWindow() {
    ;; Toggle between search window and powerscribe
    if (PowerScribeApp.isActive() or WinActive("ahk_exe emacs.exe")) {
        InteleviewerApp.ActivateReport()
    } else {
        PowerScribeApp.Activate()
    }
}