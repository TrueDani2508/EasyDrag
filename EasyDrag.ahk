#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
; Menu, Tray, Icon, %A_ScriptDir%\EasyDrag.ico
Menu, Tray, NoStandard ; remove standard Menu items
Menu, Tray, add, Exit, MenuHandler  ; Creates a new menu item.


; The Double-Alt modifier is activated by pressing
; Alt twice, much like a double-click. Hold the second
; press down until you click.
;
; The shortcuts:
;  Alt + Left Button  : Drag to move a window.
;  Alt + Right Button : Drag to resize a window.
;  Double-Alt + Left Button   : Minimize a window.
;  Double-Alt + Right Button  : Maximize/Restore a window.
;  Double-Alt + Middle Button : Close a window.
;
; You can optionally release Alt after the first
; click rather than holding it down the whole time. 




; This is the setting that runs smoothest on my
; system. Depending on your video card and cpu
; power, you may want to raise or lower this value.
SetWinDelay,2

CoordMode,Mouse
return


^LButton::
IfWinExist, Dota 2
{
	return
}
if WinActive("ahk_class WorkerW") ; Need to improve this with WinGet
{
	return
}
If DoubleAlt
{
	MouseGetPos,,,KDE_id
	; Toggle between maximized and restored state.
	WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
	If KDE_Win
		WinRestore,ahk_id %KDE_id%
	Else
		WinMaximize,ahk_id %KDE_id%
	DoubleAlt := false
	return
}
; Get the initial mouse position and window id, and
; abort if the window is maximized.
MouseGetPos,KDE_X1,KDE_Y1,KDE_id
WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
If KDE_Win
	return
; Get the initial window position.
WinGetPos,KDE_WinX1,KDE_WinY1,,,ahk_id %KDE_id%
Loop
{
	GetKeyState,KDE_Button,LButton,P ; Break if button has been released.
	If KDE_Button = U
		break
	MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
	KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
	KDE_Y2 -= KDE_Y1
	KDE_WinX2 := (KDE_WinX1 + KDE_X2) ; Apply this offset to the window position.
	KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
	WinMove,ahk_id %KDE_id%,,%KDE_WinX2%,%KDE_WinY2% ; Move the window to the new position.
}
return

^RButton::
IfWinExist, Dota 2
{
	return
}
If DoubleAlt
{
	MouseGetPos,,,KDE_id
	; This message is mostly equivalent to WinMinimize,
	; but it avoids a bug with PSPad.
	PostMessage,0x112,0xf020,,,ahk_id %KDE_id%
	DoubleAlt := false
	return
}
; Get the initial mouse position and window id, and
; abort if the window is maximized.
MouseGetPos,KDE_X1,KDE_Y1,KDE_id
WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
If KDE_Win
	return
; Get the initial window position and size.
WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
; Define the window region the mouse is currently in.
; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
If (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
	KDE_WinLeft := 1
Else
	KDE_WinLeft := -1
If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
	KDE_WinUp := 1
Else
	KDE_WinUp := -1
Loop
{
	GetKeyState,KDE_Button,RButton,P ; Break if button has been released.
	If KDE_Button = U
		break
	MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
	; Get the current window position and size.
	WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
	KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
	KDE_Y2 -= KDE_Y1
	; Then, act according to the defined region.
	WinMove,ahk_id %KDE_id%,, KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2  ; X of resized window
	, KDE_WinY1 +   (KDE_WinUp+1)/2*KDE_Y2  ; Y of resized window
	, KDE_WinW  -     KDE_WinLeft  *KDE_X2  ; W of resized window
	, KDE_WinH  -       KDE_WinUp  *KDE_Y2  ; H of resized window
	KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
	KDE_Y1 := (KDE_Y2 + KDE_Y1)
}
return

; "Alt + MButton" may be simpler, but I
; like an extra measure of security for
; an operation like this.
^MButton::


MouseGetPos,,,KDE_id
WinClose,ahk_id %KDE_id%
DoubleAlt := false
return

return

; This detects "double-clicks" of the Alt key.
~Ctrl::
DoubleAlt := A_PriorHotKey = "~Ctrl" AND A_TimeSincePriorHotkey < 400
Sleep 0
SetScrollLockState,Off
KeyWait Ctrl  ; This prevents the keyboard's auto-repeat feature from interfering.
return


MenuHandler:
for Item in ComObjGet( "winmgmts:" ).ExecQuery("Select * from Win32_Process") {
	Commandline := Item.Commandline
	StringReplace Parameters, Commandline, % Item.ExecutablePath
	;StringReplace Parameters, Parameters, ""
	if (Trim(Parameters) <> "")
		if (Item.Name = "EasyDrag.exe"){
			
				id:=Item.ProcessId
				Process,close, % id
			
		}
        if (Item.Name = "AutoHotKey.exe"){
			
				id:=Item.ProcessId
				Process,close, % id
			
		}
}
return