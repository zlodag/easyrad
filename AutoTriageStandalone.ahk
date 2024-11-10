;@Ahk2Exe-SetVersion 0.0.5
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Src/Modules/AutoTriage/AutoTriage.ahk
#Include Src/Modules/AutoTriage/Tray.ahk

A_TrayMenu.Delete
AutoTriageTrayMenu.AddToMenu(A_TrayMenu)
A_TrayMenu.Add
A_TrayMenu.AddStandard()

^+f::
{
	MyForgetGui.Launch()
}
