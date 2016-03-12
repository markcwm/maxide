'*********************************************************************************
'
'	Scintilla Module for MAX GUI (Win32 only)
'
'
'
'
'
'
'
'**********************************************************************************

'These structures are defined to be exactly the same shape as the Win32
'CHARRANGE, TEXTRANGE, FINDTEXTEX, FORMATRANGE, And NMHDR structs.
'So older code that treats Scintilla as a RichEdit will work.

Type CharacterRange
	Field cpmin:Int
	Field cpmax:Int
EndType

Type TEXTRANGE
	Field cpmin:Int
	Field cpmax:Int
	Field lpstrText:Byte Ptr
End Type

Type TextToFind
 	Field chrg:CharacterRange
 	Field lpstrText:Byte Ptr
 	Field chrgText:CharacterRange
EndType

Type NotifyHeader
	' hwndFrom is really an environment specifc window handle Or pointer
 	' but most clients of Scintilla.h do Not have This Type visible.
 	' WindowID hwndFrom;
	Field hwndFrom:Int
	Field idFrom:Int
	Field code:Int
EndType

Type SCNotification
	'Field NMHDR:NotifyHeader
	Field hwndFrom:Int
	Field idFrom:Int
	Field code:Int

	Field position:Int			' SCN_STYLENEEDED, SCN_MODIFIED, SCN_DWELLSTART, SCN_DWELLEND
	Field ch:Int				' SCN_CHARADDED, SCN_KEY
	Field modifiers:Int			' SCN_KEY
	Field modificationType:Int	' SCN_MODIFIED
	Field text:Byte Ptr				' SCN_MODIFIED
	Field length:Int			' SCN_MODIFIED
	Field linesAdded:Int		' SCN_MODIFIED
	Field message:Int			' SCN_MACRORECORD
	Field wParam:Int			' SCN_MACRORECORD
	Field lParam:Int			' SCN_MACRORECORD
	Field line:Int				' SCN_MODIFIED
	Field foldLevelNow:Int		' SCN_MODIFIED
	Field foldLevelPrev:Int		' SCN_MODIFIED
	Field margin:Int			' SCN_MARGINCLICK
	Field listType:Int			' SCN_USERLISTSELECTION
	Field x:Int				' SCN_DWELLSTART, SCN_DWELLEND
	Field y:Int				' SCN_DWELLSTART, SCN_DWELLEND
EndType

Type RangeToFormat
	Field hdc:Int
	Field hdcTarget:Int
	Field rc:RECT
	Field rcPage:RECT
	Field chrg:CharacterRange
EndType



Type RECT
	Field x1% , y1%, x2% , y2%
EndType

Type TScintillaEventData
	Field code:Int
	Field position:Int			' SCN_STYLENEEDED, SCN_MODIFIED, SCN_DWELLSTART, SCN_DWELLEND
	Field ch:Int				' SCN_CHARADDED, SCN_KEY
	Field modifiers:Int			' SCN_KEY
	Field modificationType:Int	' SCN_MODIFIED
	Field text:String				' SCN_MODIFIED
	Field length:Int			' SCN_MODIFIED
	Field linesAdded:Int		' SCN_MODIFIED
	Field message:Int			' SCN_MACRORECORD
	Field wParam:Int			' SCN_MACRORECORD
	Field lParam:Int			' SCN_MACRORECORD
	Field line:Int				' SCN_MODIFIED
	Field foldLevelNow:Int		' SCN_MODIFIED
	Field foldLevelPrev:Int		' SCN_MODIFIED
	Field margin:Int			' SCN_MARGINCLICK
	Field listType:Int			' SCN_USERLISTSELECTION
	Field x:Int				' SCN_DWELLSTART, SCN_DWELLEND
	Field y:Int				' SCN_DWELLSTART, SCN_DWELLEND
	
	Function From:TScintillaEventData(Note:SCNotification)
		Local data:TScintillaEventData = New TScintillaEventData
		data.code = note.code
		data.position = note.position
		data.ch = note.ch
		data.modifiers = note.modifiers
		data.modificationType = note.modificationType
		data.text = String.FromCString(note.text)
		data.text = data.text.Replace(Chr(13),Chr(10))[..note.length]
		data.length = note.length
		data.linesadded = note.linesadded
		data.message = note.message
		data.wParam = note.wParam
		data.lParam = note.lParam
		data.line = note.line
		data.foldLevelNow = note.foldlevelnow
		data.foldlevelPrev = note.foldlevelPrev
		data.margin = note.margin
		data.listType = note.listType
		data.x = note.x
		data.y = note.y
		Return data
	End Function
	
	Method toString:String()
		Return "Scintilla Notification: " + ScintillaSCNToString(code) 
	End Method
	
	Method Delete()
	End Method
End Type		

