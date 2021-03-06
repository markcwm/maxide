SuperStrict

'Rem
'bbdoc: Klepto/Scintilla Control
'End Rem
'Module klepto.Scintilla

Import Maxgui.Drivers

Import "Scintilla_Main.bmx"
'Import "TScintilla.bmx"
Import "Scintilla_Main.bmx"

Rem
bbdoc: 
EndRem
Type TScintillaGadget Extends TWindowsGadget
	
	Field _oldSelPos%, _oldSelLen% = 0
	Field readonly:Byte = False
	'Field numbers:Byte = False
	'Field _scintilla:TScintilla
	Field handle:Int
	Global _pagemargin# = 0.5
	
	' TScintilla
	
	Method SendEditor:Int(iMsg:Int, wParam:Int=0, lParam:Int=0)
		Return SendMessageW(handle, iMsg, wParam, lParam)
	End Method
	
	Method SendEditorString:Int(iMsg:Int, wParam:Int, lParam:String)
		Local lp:Byte Ptr = lParam.toCString()
		Local re:Int = SendEditor(iMsg, wParam, Int lp)
		MemFree lp ' fix
		Return re
	End Method
	
	Method SendEditorStringString:Int(iMsg:Int, wParam:String, lParam:String)
		Local wp:Byte Ptr = wParam.toCString()
		Local lp:Byte Ptr = lParam.toCString()
		Local re:Int = SendEditor(iMsg, Int wp, Int lp)
		MemFree wp ' fix
		MemFree lp
		Return re
	End Method
	
	Method ReceiveEditorString:String(iMsg:Int, length:Int)
		Local ch:Byte[] = New Byte[length]
		SendEditor(iMsg, length, Int Byte Ptr(ch))
		Local st:String = ""
		If length > 1
			st = String.FromBytes(ch, length-1)
		End If
		Return st
	End Method
	
	Method ReceiveEditorDataString:String(iMsg:Int ,data:Int, length:Int)
		Local ch:Byte[] = New Byte[length]
		SendEditor(iMsg, data, Int Byte Ptr(ch))
		Local st:String = ""
		If length > 1
			st = String.FromBytes(ch, length-1)
		EndIf
		Return st
	End Method
		
	Method SetLineNumbering(Margin:Int=0, State:Int=0)
		SendEditor(SCI_SETMARGINTYPEN, Margin, SC_MARGIN_NUMBER)
		If State = True Then
			SendEditor(SCI_SETMARGINWIDTHN, Margin, SendEditorString(SCI_TEXTWIDTH, 0, "_99999"))
			'numbers= True
		Else
			SendEditor(SCI_SETMARGINWIDTHN, Margin, 0)
			'numbers = False
		End If
	End Method
	
	Method SetMarginType(Margin:Int=0, Style:Int, Width:Int=0)
		SendEditor(SCI_SETMARGINTYPEN, Margin, Style)
		SendEditor(SCI_SETMARGINWIDTHN, Margin, Width)
	End Method
	
	'Method SetLexer(Lexer:Int = SCLEX_NULL)
	'	SendEditor(SCI_SETLEXER, Lexer)
	'End Method
	
	'Method GetLexer:Int()
	'	Return SendEditor(SCI_GETLEXER)
	'End Method
	
	'Method SetLexerKeyWords(Set:Int = 0, Keywords:String)
	'	SendEditorString(SCI_SETKEYWORDS, Set, KeyWords)
	'End Method

	'Method SetLexerStyle(Style:Int, target:Int, value:Int = 0)
	'	SendEditor(Style, target, value)
	'End Method
	
	'Method SetMarginSensitive(Margin:Int, sens:Int = False)
	'	SendEditor(SCI_SETMARGINSENSITIVEN, margin, sens)
	'End Method
	
	'Method SetProperty(property:String, value:String)
	'	SendEditorStringString(SCI_SETPROPERTY, property, value)
	'End Method
	
	'Method GetScintilla:TScintilla()
	'	Return _scintilla
	'End Method
	
	Function CreateScintillaGadget:TScintillaGadget(x:Int, y:Int, w:Int, h:Int, group:TGadget, style:Int=0)
		Return New TScintillaGadget.Initialize(x, y, w, h, group, style)
	End Function
	
	' TWindowsTextArea
	
	Method Create:TWindowsGadget(group:TGadget, style:Int, Text$="")
	End Method
	
	Method Initialize:TScintillaGadget(x:Int, y:Int, w:Int, h:Int, group:TGadget, style:Int)
	
		Local	xstyle:Int, wstyle:Int, hwnd:Int, parent:Int
		
		Self.style = style
		xstyle=WS_EX_CLIENTEDGE
		wstyle=WS_CHILD|WS_VSCROLL|WS_CLIPSIBLINGS
		wstyle:|ES_MULTILINE|ES_NOOLEDRAGDROP|ES_NOHIDESEL|ES_LEFT
		wstyle=WS_CHILD|WS_TABSTOP|WS_CLIPSIBLINGS
		parent=group.query(QUERY_HWND_CLIENT)
		hwnd=CreateWindowExW(xstyle, "Scintilla", "", wstyle, 0, 0, 0, 0, parent, 0, GetModuleHandleW(Null), Null)		
		
		_SetParent group
		'_scintilla = TScintilla.Init(hwnd)	
		handle = hwnd
		Register GADGET_TEXTAREA, hwnd
		SetShape(x, y, w, h)
		SetShow(True)
		Sensitize()
		
		SendEditor(SCI_SETMODEVENTMASK, SC_MODEVENTMASKALL)
		
		Return Self		
		
	EndMethod
		
	Method Free()
		Super.Free()
	EndMethod
	
	Method Activate:Int(cmd:Int)
		Select cmd
			Case ACTIVATE_CUT	
				SendEditor(SCI_CUT)
			Case ACTIVATE_COPY	
				SendEditor(SCI_COPY)
			Case ACTIVATE_PASTE
				SendEditor(SCI_PASTE)	
			Case ACTIVATE_PRINT
				DoPrint
			Case ACTIVATE_FOCUS
				SetFocus _hwnd
			Default
				Return Super.Activate(cmd)
		End Select
	EndMethod
	
	Method DoPaste()
		SendEditor(SCI_PASTE)
	EndMethod
	
	Method DoPrint:Int()
		
		Local tmpTextSelLen:Int = TextAreaSelLen(Self)
		
		Local tmpPrintDialog:PRINTDLGW = New PRINTDLGW
		
		tmpPrintDialog.flags = PD_RETURNDC | PD_HIDEPRINTTOFILE | PD_NOPAGENUMS
		If Not tmpTextSelLen Then tmpPrintDialog.flags:|PD_NOSELECTION
		
		tmpPrintDialog.hwndOwner = _hwnd
		
		If Not PrintDlg(Byte Ptr tmpPrintDialog) Then Return 0
		
		Local hdcPrinter:Int = tmpPrintDialog.hdc	
		
		Local tmpDoc:DOCINFOW = New DOCINFOW
		Local tmpDocTitle:Short Ptr = AppTitle.ToWString()
		tmpDoc.lpszDocName = tmpDocTitle
		
		Local tmpSuccess:Int = (StartDocW(hdcPrinter, Byte Ptr tmpDoc) > 0)
		
		If tmpSuccess Then
			
			Local _cursor:Int = TWindowsGUIDriver._cursor
			SetPointer(POINTER_WAIT)
			SetMapMode(hdcPrinter, MM_TEXT)
			
			Local wPage:Int = GetDeviceCaps(hdcPrinter, PHYSICALWIDTH)
			Local hPage:Int = GetDeviceCaps(hdcPrinter, PHYSICALHEIGHT)
			Local xPPI:Int = GetDeviceCaps(hdcPrinter, LOGPIXELSX)
			Local yPPI:Int = GetDeviceCaps(hdcPrinter, LOGPIXELSY)
			Local Margin:Rect = New Rect
			Margin.x1 = GetDeviceCaps(hdcPrinter, PHYSICALOFFSETX)
			margin.y1 = GetDeviceCaps(hdcPrinter, PHYSICALOFFSETY)
			margin.x2 = wPage - GetDeviceCaps(hdcPrinter, HORZRES) - margin.x1 	
			margin.y2 = hPage - GetDeviceCaps(hdcPrinter, VERTRES) - margin.y1 	
			
			Print margin.x1 + "; " + margin.y1 + " ;" + margin.x2 + ";" + margin.y2

			'Local tmpTextLengthStruct[] = [GTL_DEFAULT, 1200]
			'Local tmpTextLength = SendMessageW (_hwnd, EM_GETTEXTLENGTHEX, Int Byte Ptr tmpTextLengthStruct, 0)
			
			Local tmpTextPrinted:Int, tmpFormatRange:RangeToFormat = New RangeToFormat 
			
			tmpFormatRange.hdc = hdcPrinter
			tmpFormatRange.hdcTarget = hdcPrinter
			
			'tmpFormatRange.rcPageRight = (wPage*1440:Long)/xPPI
			'tmpFormatRange.rcPageBottom = (hPage*1440:Long)/yPPI
			
			'tmpFormatRange.range.rc.x1 = (1440*_pagemargin) ; tmpFormatRange.rcTop = (1440*_pagemargin)
			'tmpFormatRange.range.rc.y1 = tmpFormatRange.rcPageRight - (2880*_pagemargin)
			'tmpFormatRange.rcBottom = tmpFormatRange.rcPageBottom - (2880*_pagemargin)
	
			tmpFormatRange.rc = New Rect
			tmpFormatRange.rcPage = New Rect
			
			tmpFormatRange.rcPage.x2 = (wPage*1440:Long)/xPPI
			tmpFormatRange.rcPage.y2 = (hPage*1440:Long)/yPPI
			
			tmpFormatRange.rc.x1 = (1440*_pagemargin)
			tmpFormatRange.rc.y1 =  (1440*_pagemargin)
			tmpFormatRange.rc.x2 = tmpFormatRange.rcPage.x2 - (2880*_pagemargin)
			tmpFormatRange.rc.y2 = tmpFormatRange.rcPage.y2 - (2880*_pagemargin)

			tmpFormatRange.rcPage.x1 = 0
			tmpFormatRange.rcPage.y1 = 0
			
			If tmpPrintDialog.flags & PD_SELECTION Then
				tmpFormatRange.chrg = New CharacterRange
				tmpFormatRange.chrg.cpmin = SendEditor(SCI_GETSELECTIONSTART)
				tmpFormatRange.chrg.cpmax = SendEditor(SCI_GETSELECTIONEND)

			Else
				tmpFormatRange.chrg = New CharacterRange
				tmpFormatRange.chrg.cpmin = 0
				tmpFormatRange.chrg.cpmax = SendEditor(SCI_GETTEXTLENGTH)
			EndIf
			
			Print SendEditor(SCI_FORMATRANGE, False, 0)
			
			While tmpSuccess And (tmpTextPrinted < tmpFormatRange.chrg.cpmax)
				
				tmpFormatRange.chrg.cpMin = tmpTextPrinted
				
				tmpSuccess = (StartPage(hdcPrinter) > 0)
				If Not tmpSuccess Then Exit
				
				tmpTextPrinted = SendEditor(SCI_FORMATRANGE, True, Int Byte Ptr tmpFormatRange)
				'tmpTextPrinted = SendMessageW(_hwnd, EM_FORMATRANGE, True, Int Byte Ptr tmpFormatRange)
				Print "Printed " +  tmpTextPrinted
				tmpSuccess = (EndPage(hdcPrinter) > 0)
				
				'tmpTextPrinted = _scintilla.SendEditor(SCI_GETTEXTLENGTH)
			Wend
			
			If tmpSuccess Then EndDoc(hdcPrinter) Else AbortDoc(hdcPrinter)
			SendEditor(SCI_FORMATRANGE, False, 0)
			TWindowsGUIDriver._cursor = _cursor
			SetCursor _cursor
			
		EndIf
		
		GlobalFree(tmpPrintDialog.hDevMode)
		GlobalFree(tmpPrintDialog.hDevNames)
		DeleteDC(hdcPrinter)
		MemFree tmpDocTitle
		
		Return tmpSuccess
				
	EndMethod
	
	Method CharCount:Int()
		Return SendEditor(SCI_GETTEXTLENGTH)
	EndMethod
	
	Method SetStyle(r:Int, g:Int, b:Int, flags:Int, pos:Int, length:Int, units:Int)
	EndMethod
		
	Method InsertText(Text$, pos:Int, count:Int)
		SendEditorString(SCI_INSERTTEXT, pos, Text)
	EndMethod
	
	Method ReplaceText(pos:Int, length:Int, Text$, units:Int)
		If units=TEXTAREA_LINES
			Local n:Int=pos
			pos=CharAt(pos)
			If length>=0 length=CharAt(n+length)-pos
		EndIf			
		If length < 0 Then length = charcount() - pos	
'		Print pos + ";"+ (pos + length)
		SendEditor(SCI_SETTARGETSTART, pos)
		SendEditor(SCI_SETTARGETEND, pos + Length)
		SendEditorString(SCI_REPLACETARGET, Text.length, Text)
	EndMethod
	
	Method AreaText$(pos:Int, length:Int, units:Int)
		Local range:TextRange = New TextRange
		'range.chrg = New CharacterRange
		If length < 0 Then length = charcount()
		
		If units = TEXTAREA_LINES Then
			range.cpmin = CharAt(pos)
			range.cpmax = CharAt(pos + Length+1)
		Else
			range.cpmin = pos
			range.cpmax = pos+Length
		End If
		
		range.lpstrText = New Byte[2*(range.cpmax - range.cpmin)+2]
		Local tmpLength:Int = SendEditor(SCI_GETTEXTRANGE, 0, Int Byte Ptr range)
		'Print "Test : " + tmplength + " ; " + (range.cpmax - range.cpmin)
		Local Text:String = String.FromCString(Byte Ptr(range.lpstrText))
			
		Return Text
	EndMethod
	
	Method SetSelection(pos:Int, length:Int, units:Int)
		If units=TEXTAREA_LINES
			Local n:Int=pos
			pos=CharAt(pos)
			If length>=0 length=CharAt(n+length)-pos
		EndIf			
		If length < 0 Then length = charcount() - pos	
		Desensitize()
		SendEditor(SCI_GOTOPOS, pos)
		SendEditor(SCI_SETSELECTIONSTART, pos)
		SendEditor(SCI_SETSELECTIONEND, pos + length)
		Sensitize()
	EndMethod
	
	'Method SetMargins(leftmargin)
	
	Method SetTabs(tabs:Int)
		SendEditor(SCI_SETTABWIDTH, tabs)
	EndMethod

	Method SetTextColor(r:Int, g:Int, b:Int)
		SendEditor(SCI_STYLESETFORE, 0, r|(g Shl 8)|(b Shl 16))
	EndMethod

	Method SetColor(r:Int, g:Int, b:Int)
		SendEditor(SCI_STYLESETBACK, STYLE_DEFAULT, r|(g Shl 8)|(b Shl 16))
		SendEditor(SCI_STYLESETBACK, 0, r|(g Shl 8)|(b Shl 16))
	EndMethod
	
	'Method RemoveColor()
	
	Method GetCursorPos:Int(units:Int)
		Local pos:Int = SendEditor(SCI_GETSELECTIONSTART) '_scintilla.SendEditor(SCI_GETCURRENTPOS)
		If units = TEXTAREA_LINES Then
			Return LineAT(pos)
		End If
		Return pos
	EndMethod	
	
	Method GetSelectionLength:Int(units:Int)
		Local cpMin:Int = SendEditor(SCI_GETSELECTIONSTART)
		Local cpMax:Int = SendEditor(SCI_GETSELECTIONEND)
		If units=TEXTAREA_LINES 
			Return LineAt(cpMax)-LineAt(cpMin)
		Else
			Return cpMax-cpMin
		EndIf
	EndMethod

	Method CharAt:Int(Line:Int)
		If Line<0 Return 0
		If Line>AreaLen(TEXTAREA_LINES) Return charcount()
		Return SendEditor(SCI_POSITIONFROMLINE, Line, 0)
	EndMethod

	Method LineAt:Int(pos:Int)
		If pos<0 Return 0
		If pos>charcount() Return AreaLen(TEXTAREA_LINES)
		Return SendEditor(SCI_LINEFROMPOSITION, pos)
	EndMethod

	Method AreaLen:Int(units:Int)
		If units=TEXTAREA_LINES Return LineAt(charcount())
		Return charcount()
	EndMethod
	
	Method CharX:Int(char:Int)
		Return SendEditor(SCI_POINTXFROMPOSITION, 0, char)
	EndMethod
	
	Method CharY:Int(char:Int)
		Return SendEditor(SCI_POINTYFROMPOSITION, 0, char)
	EndMethod
	
	Method SetText(Text$)
		Local p:Byte Ptr = Text.toCString()
		SendEditor(SCI_SETTEXT, 0, Int p)
		MemFree p ' fix
	EndMethod
	
	Method AddText(Text$)
		SendEditorString(SCI_APPENDTEXT, Text.length, Text)
	EndMethod
	
	Method GetText$()
		Return AreaText(0, charcount(), TEXTAREA_CHARS)
	EndMethod
	
	'Method LockText()
	
	'Method UnlockText()
	
	'Method OnCommand(msg,wp)
	
	Method OnNotify:Int(wp:Int, lp:Int)
		Local nmhdr:Int Ptr
		Local event:TEvent
				
		nmhdr = Int Ptr(lp)
		
		Local notification:TSCNotification = New TSCNotification
		MemCopy Byte Ptr notification, nmhdr, SizeOf(notification)
		
		Local L:TScintillaEventData = TScintillaEventData.From(notification)
		
		'If ScintillaSCNToString(notification.Code) <> "Unknown" ' fix
		If ScintillaSCNToString(notification.Code) = "SCN_MODIFIED"
			.PostGuiEvent EVENT_GADGETACTION, Self, L.Code, , , , L
		ElseIf ScintillaSCNToString(notification.Code) = "SCN_UPDATEUI"..
		Or ScintillaSCNToString(notification.Code) = "SCN_MARGINCLICK"
			.PostGuiEvent EVENT_GADGETSELECT, Self, L.Code, , , , L
		EndIf
		
	EndMethod
	
	Method WndProc:Int(hwnd:Int, msg:Int, wp:Int, lp:Int)
	
		Local nmhdr:Int Ptr
		Local event:TEvent
		
		nmhdr = Int Ptr(wp)
		
		'If wp = 0 Then Return 0
		
		Select MSG
			Case WM_RBUTTONDOWN
				If GetSelectionLength(TEXTAREA_CHARS)=0 MSG=WM_LBUTTONDOWN
			Case WM_RBUTTONUP
				Local mx:Int=lp & $ffff
				Local my:Int = lp Shr 16
				.PostGuiEvent EVENT_GADGETMENU, Self, 0, 0, mx, my
			Case WM_KEYDOWN
				Local k:Int=wp'nmhdr[4]
				'Event Filter
				event = CreateEvent(EVENT_KEYDOWN, Self, k, keymods())
				If eventfilter <> Null
					If eventfilter(event, context) = 0 Return False
				EndIf
			Case WM_CHAR
				If readonly Return 1
				event=CreateEvent(EVENT_KEYCHAR, Self, wp, keymods())
				If eventfilter<>Null
					If eventfilter(event, context) = 0 Return False
				EndIf
			Case WM_SETTINGCHANGE
				DebugLog ("** SETTING Changed")
				SendEditor(WM_SETTINGCHANGE, wP, lP)
				'SendOutput(WM_SETTINGCHANGE, wParam, lParam)
			Case WM_SYSCOLORCHANGE
				DebugLog("** Color Changed\n")
				SendEditor(WM_SYSCOLORCHANGE, wP, lP)
				'SendOutput(WM_SYSCOLORCHANGE, wParam, lParam)
			Case WM_PALETTECHANGED
				DebugLog("** Palette Changed\n")
				SendEditor(WM_PALETTECHANGED, wP, lP)
					'//SendOutput(WM_PALETTECHANGED, wParam, lParam)
			Case WM_QUERYNEWPALETTE
				DebugLog("** Query palette\n")
				SendEditor(WM_QUERYNEWPALETTE, wP, lP)
				'//SendOutput(WM_QUERYNEWPALETTE, wParam, lParam)
		End Select
		
		Return Super.WndProc(hwnd, msg, wp, lp)

	EndMethod
	
	Method Class:Int()
		Return GADGET_TEXTAREA
	End Method
	
	' TWindowsGadget
	
	Method SetFont(font:TGuiFont)
		Local _font:TWindowsFont
		If TWindowsFont(font) Then _font = TWindowsFont(font) Else _font = TWindowsGUIDriver.GDIFont
		Rem
		Const FONT_NORMAL=0
		Const FONT_BOLD=1
		Const FONT_ITALIC=2
		Const FONT_UNDERLINE=4
		Const FONT_STRIKETHROUGH=8
		End Rem
'		Print "Style : " + _font.Style + ";" +((_font.Style & FONT_BOLD) >0)
		For Local I:Int = 0 To 99
			SendEditorString(SCI_STYLESETFONT, I, _Font.name)
			SendEditor(SCI_STYLESETSIZE, I, Int(_Font.Size))
			SendEditor(SCI_STYLESETBOLD, I, (_font.Style & FONT_BOLD) >0)
			SendEditor(SCI_STYLESETITALIC, I, (_font.Style & FONT_ITALIC) >0)
			SetLineNumbering(0, True)	
		Next
	End Method
	
	' Private
	
	Method KeyMods:Int()
		Local mods:Int
		If GetKeyState(VK_SHIFT)&$8000 mods:|MODIFIER_SHIFT
		If GetKeyState(VK_CONTROL)&$8000 mods:|MODIFIER_CONTROL
		If GetKeyState(VK_MENU)&$8000 mods:|MODIFIER_OPTION
		If GetKeyState(VK_LWIN)&$8000 Or GetKeyState(VK_RWIN)&$8000 mods:|MODIFIER_SYSTEM
		Return mods
	End Method
	
End Type

Rem
bbdoc: 
EndRem
Function CreateScintillaTextArea:TScintillaGadget(x:Int, y:Int, w:Int, h:Int, group:TGadget, style:Int=0)
	Return TScintillaGadget.CreateScintillaGadget(x, y, w, h, group, style)
End Function
