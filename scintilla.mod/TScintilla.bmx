SuperStrict

Import "Scintilla_Main.bmx"

Type TScintilla
	Field _handle:Int
	
	Function Init:TScintilla(handle:Int)
		Local S:TScintilla = New TScintilla
		S._handle = handle
		Return S
	End Function	
	'internal functions advanced use only
	
Rem
bbdoc: SENDEDITOR
End Rem
	Method SendEditor:Int(Msg:Int , wParam:Int = 0 , lParam:Int = 0)
		Return SendMessageW(_handle , msg , wparam , lParam)
	End Method
	
Rem
bbdoc: SENDEDITORSTRING
End Rem
	Method SendEditorString:Int(msg:Int , wParam:Int , lParam:String)
		Local p:Byte Ptr = lparam.toCString()
		Local result:Int = SendEditor(msg , wParam , Int p)
		MemFree p ' munch fix - ToCString memory leaks
		Return result
	End Method
	

Rem
bbdoc: SENDEDITORSTRINGSTRING
End Rem
	Method SendEditorStringString:Int(msg:Int , wParam:String , lParam:String)
		Local w:Byte Ptr = wparam.toCString()
		Local l:Byte Ptr = lparam.toCString()
		Local result:Int = SendEditor(msg , Int w , Int l)
		MemFree w ' munch fix - ToCString memory leaks
		MemFree l
		Return result
	End Method
	

Rem
bbdoc: RECEIVEEDITORSTRING
End Rem
	Method ReceiveEditorString:String(msg:Int , Length:Int )
		Local chars:Byte[] = New Byte[length]
		SendEditor(msg , length, Int Byte Ptr(chars) )
		Local Text:String = ""
		If length > 1
			Text = String.FromBytes(chars,length-1)
		End If

		Return Text
	End Method
	
Rem
bbdoc: RECEIVEEDITORSTRING
End Rem
	Method ReceiveEditorDataString:String(msg:Int ,data:Int, Length:Int )
		Local chars:Byte[] = New Byte[length]
		SendEditor(msg , data, Int Byte Ptr(chars) )
		Local Text:String = ""
		If length > 1
			Text = String.FromBytes(chars,length-1)
		End If

		Return Text
	End Method

	'Wrapper Functions
	
	'Text retrieval and modification
	

Rem
bbdoc: GETTEXT
about: <p><b id="SCI_GETTEXT">SCI_GETTEXT(int length, char *text)</b><br />
     This returns <code>length</code>-1 characters of text from the start of the document plus one
    terminating 0 character. To collect all the text in a document, use <code>SCI_GETLENGTH</code>
    to get the number of characters in the document (<code>nLen</code>), allocate a character
    buffer of length <code>nLen+1</code> bytes, then call <code>SCI_GETTEXT(nLen+1, char
    *text)</code>. If the text argument is 0 then the length that should be allocated to store the
    entire document is returned.
    If you then save the text, you should use <code>SCI_SETSAVEPOINT</code> to mark
    the text as unmodified.</p>
See Also: <code><a class="message" href="#SCI_GETSELTEXT">SCI_GETSELTEXT</a>, <a
    class="message" href="#SCI_GETCURLINE">SCI_GETCURLINE</a>, <a class="message"
    href="#SCI_GETLINE">SCI_GETLINE</a>, <a class="message"
    href="#SCI_GETSTYLEDTEXT">SCI_GETSTYLEDTEXT</a>, <a class="message"
    href="#SCI_GETTEXTRANGE">SCI_GETTEXTRANGE</a></code>
End Rem
	Method GetText:String(length:Int)
		Return ReceiveEditorString(SCI_GETTEXT,length)
	End Method
	

Rem
bbdoc: SETTEXT
about: <p><b id="SCI_SETTEXT">SCI_SETTEXT(&lt;unused&gt;, const char *text)</b><br />
     This replaces all the text in the document with the zero terminated text string you pass
    in.</p>
End Rem
	Method SetText(Text:String)
		SendEditorString(SCI_SETTEXT , 0 , Text)
	End Method
	

Rem
bbdoc: SETSAVEPOINT
about: <p><b id="SCI_SETSAVEPOINT">SCI_SETSAVEPOINT</b><br />
     This message tells Scintilla that the current state of the document is unmodified. This is
    usually done when the file is saved or loaded, hence the name "save point". As Scintilla
    performs undo and redo operations, it notifies the container that it has entered or left the
    save point with <code><a class="message"
    href="#SCN_SAVEPOINTREACHED">SCN_SAVEPOINTREACHED</a></code> and <code><a class="message"
    href="#SCN_SAVEPOINTLEFT">SCN_SAVEPOINTLEFT</a></code> <a class="jump"
    href="#Notifications">notification messages</a>, allowing the container to know if the file
    should be considered dirty or not.</p>
See Also: <code><a class="message" href="#SCI_EMPTYUNDOBUFFER">SCI_EMPTYUNDOBUFFER</a>, <a
    class="message" href="#SCI_GETMODIFY">SCI_GETMODIFY</a></code>
End Rem
	Method SetSavePoint()
		SendEditor(SCI_SETSAVEPOINT)
	End Method
	

Rem
bbdoc: GETLINE
about: <p><b id="SCI_GETLINE">SCI_GETLINE(int line, char *text)</b><br />
     This fills the buffer defined by text with the contents of the nominated line (lines start at
    0). The buffer is not terminated by a 0 character. It is up to you to make sure that the buffer
    is long enough for the text, use <a class="message"
    href="#SCI_LINELENGTH"><code>SCI_LINELENGTH(int line)</code></a>. The returned value is the
    number of characters copied to the buffer. The returned text includes any end of line
    characters. If you ask for a line number outside the range of lines in the document, 0
    characters are copied. If the text argument is 0 then the length that should be allocated
    to store the entire line is returned.</p>
See Also: <code><a class="message" href="#SCI_GETCURLINE">SCI_GETCURLINE</a>, <a
    class="message" href="#SCI_GETSELTEXT">SCI_GETSELTEXT</a>, <a class="message"
    href="#SCI_GETTEXTRANGE">SCI_GETTEXTRANGE</a>, <a class="message"
    href="#SCI_GETSTYLEDTEXT">SCI_GETSTYLEDTEXT</a>, <a class="message"
    href="#SCI_GETTEXT">SCI_GETTEXT</a></code>
End Rem
	Method GetLine:String(Line:Int)
		Return ReceiveEditorString(SCI_GETLINE,Line)
	End Method
	

Rem
bbdoc: REPLACESEL
about: <p><b id="SCI_REPLACESEL">SCI_REPLACESEL(&lt;unused&gt;, const char *text)</b><br />
     The currently selected text between the <a class="jump" href="#SelectionAndInformation">anchor
    and the current position</a> is replaced by the 0 terminated text string. If the anchor and
    current position are the same, the text is inserted at the caret position. The caret is
    positioned after the inserted text and the caret is scrolled into view.</p>
End Rem
	Method ReplaceSel(Text:String)
		SendEditorString(SCI_REPLACESEL , 0 , Text)
	End Method
	

Rem
bbdoc: SETREADONLY
about: <p><b id="SCI_SETREADONLY">SCI_SETREADONLY(bool readOnly)</b><br />
     <b id="SCI_GETREADONLY">SCI_GETREADONLY</b><br />
     These messages set and get the read-only flag for the document. If you mark a document as read
    only, attempts to modify the text cause the <a class="message"
    href="#SCN_MODIFYATTEMPTRO"><code>SCN_MODIFYATTEMPTRO</code></a> notification.</p>
End Rem
	Method SetReadonly(readOnly:Byte)
		SendEditor(SCI_SETREADONLY, readOnly)
	End Method
		

Rem
bbdoc: GETREADONLY
End Rem
	Method GetReadonly:Int()
		Return SendEditor(SCI_GETREADONLY)
	End Method
	

Rem
bbdoc: GETTEXTRANGE
about: <p><b id="SCI_GETTEXTRANGE">SCI_GETTEXTRANGE(&lt;unused&gt;, <a class="jump"
    href="#TextRange">TextRange</a> *tr)</b><br />
     This collects the text between the positions <code>cpMin</code> and <code>cpMax</code> and
    copies it to <code>lpstrText</code> (see <code>struct TextRange</code> in
    <code>Scintilla.h</code>). If <code>cpMax</code> is -1, text is returned to the end of the
    document. The text is 0 terminated, so you must supply a buffer that is at least 1 character
    longer than the number of characters you wish to read. The return value is the length of the
    returned text not including the terminating 0.</p>
See Also: <code><a class="message" href="#SCI_GETSELTEXT">SCI_GETSELTEXT</a>, <a
    class="message" href="#SCI_GETLINE">SCI_GETLINE</a>, <a class="message"
    href="#SCI_GETCURLINE">SCI_GETCURLINE</a>, <a class="message"
    href="#SCI_GETSTYLEDTEXT">SCI_GETSTYLEDTEXT</a>, <a class="message"
    href="#SCI_GETTEXT">SCI_GETTEXT</a></code>
End Rem
	Method GetTextrange:String(cpmin:Int, cpmax:Int)
		Local range:TextRange = New TextRange				
		range.cpmin = cpmin
		range.cpmax = cpmax
		range.lpstrText = New Byte[(range.cpmax - range.cpmin)+1]
		
		Local tmpLength:Int =  SendEditor(SCI_GETTEXTRANGE ,0 , Int Byte Ptr range)
		'Print "Test : " + tmplength + " ; " + (range.cpmax - range.cpmin)
		Local Text:String = String.FromCString(Byte Ptr(range.lpstrText))
			
		Return Text
	End Method
	

Rem
bbdoc: ALLOCATE
about: <p><b id="SCI_ALLOCATE">SCI_ALLOCATE(int bytes, &lt;unused&gt;)</b><br />
     Allocate a document buffer large enough to store a given number of bytes.
     The document will not be made smaller than its current contents.</p>
End Rem
	Method Allocate(bytes:Int)
		SendEditor(SCI_ALLOCATE,bytes)
	End Method
	

Rem
bbdoc: ADDTEXT
about: <p><b id="SCI_ADDTEXT">SCI_ADDTEXT(int length, const char *s)</b><br />
     This inserts the first <code>length</code> characters from the string <code>s</code>
    at the current position. This will include any 0's in the string that you might have expected
    to stop the insert operation. The current position is set at the end of the inserted text,
    but it is not scrolled into view.</p>
End Rem
	Method AddText(length:Int,Text:String)
		SendEditorString(SCI_ADDTEXT,length,Text)
	End Method
	

Rem
bbdoc: ADDSTYLEDTEXT
about: <p><b id="SCI_ADDSTYLEDTEXT">SCI_ADDSTYLEDTEXT(int length, cell *s)</b><br />
     This behaves just like <code>SCI_ADDTEXT</code>, but inserts styled text.</p>
End Rem
	Method AddStyledText(length:Int,Text:String)
		SendEditorString(SCI_ADDSTYLEDTEXT,length,Text)
	End Method
	

Rem
bbdoc: INSERTTEXT
about: <p><b id="SCI_INSERTTEXT">SCI_INSERTTEXT(int pos, const char *text)</b><br />
     This inserts the zero terminated <code>text</code> string at position <code>pos</code> or at
    the current position if <code>pos</code> is -1. If the current position is after the insertion point
    then it is moved along with its surrounding text but no scrolling is performed.</p>
End Rem
	Method InsertText(pos:Int,Text:String)
		SendEditorString(SCI_INSERTTEXT,pos,Text)
	End Method
	

Rem
bbdoc: CLEARALL
about: <p><b id="SCI_CLEARALL">SCI_CLEARALL</b><br />
     Unless the document is read-only, this deletes all the text.</p>
End Rem
	Method ClearAll()
		SendEditor(SCI_CLEARALL)
	End Method
	

Rem
bbdoc: CLEARDOCUMENTSTYLE
about: <p><b id="SCI_CLEARDOCUMENTSTYLE">SCI_CLEARDOCUMENTSTYLE</b><br />
     When wanting to completely restyle the document, for example after choosing a lexer, the
    <code>SCI_CLEARDOCUMENTSTYLE</code> can be used to clear all styling information and reset the
    folding state.</p>
End Rem
	Method ClearDocumentstyle()
		SendEditor(SCI_CLEARDOCUMENTSTYLE)
	End Method
	

Rem
bbdoc: GETLENGTH
End Rem
	Method GetLength:Int()
		Return SendEditor(SCI_GETLENGTH)
	End Method
	

Rem
bbdoc: GETCHARAT
about: <p><b id="SCI_GETCHARAT">SCI_GETCHARAT(int pos)</b><br />
     This returns the character at <code>pos</code> in the document or 0 if <code>pos</code> is
    negative or past the end of the document.</p>
End Rem
	Method GetCharAt:Int(pos:Int)
		Return SendEditor(SCI_GETCHARAT,pos)
	End Method
	

Rem
bbdoc: GETCURRENTPOS
about: <p><b id="SCI_GETCURRENTPOS">SCI_GETCURRENTPOS</b><br />
     This returns the current position.</p>
End Rem
	Method GetCurrentPos:Int()
		Return SendEditor(SCI_GETCURRENTPOS)
	End Method
	

Rem
bbdoc: GETANCHOR
about: <p><b id="SCI_GETANCHOR">SCI_GETANCHOR</b><br />
     This returns the current anchor position.</p>
End Rem
	Method GetAnchor:Int()
		Return SendEditor(SCI_GETANCHOR)
	End Method
	

Rem
bbdoc: GETSTYLEAT
about: <p><b id="SCI_GETSTYLEAT">SCI_GETSTYLEAT(int pos)</b><br />
     This returns the style at <code>pos</code> in the document, or 0 if <code>pos</code> is
    negative or past the end of the document.</p>
End Rem
	Method GetStyleAt:Int(pos:Int)
		Return SendEditor(SCI_GETSTYLEAT, pos)
	End Method
	

Rem
bbdoc: REDO
about: <p><b id="SCI_REDO">SCI_REDO</b><br />
     <b id="SCI_CANREDO">SCI_CANREDO</b><br />
     <code>SCI_REDO</code> undoes the effect of the last <code>SCI_UNDO</code> operation.</p>
End Rem
	Method Redo()
		SendEditor(SCI_REDO)
	End Method
	

Rem
bbdoc: SETUNDOCOLLECTION
about: <p><b id="SCI_SETUNDOCOLLECTION">SCI_SETUNDOCOLLECTION(bool collectUndo)</b><br />
     <b id="SCI_GETUNDOCOLLECTION">SCI_GETUNDOCOLLECTION</b><br />
     You can control whether Scintilla collects undo information with
    <code>SCI_SETUNDOCOLLECTION</code>. Pass in <code>true</code> (1) to collect information and
    <code>false</code> (0) to stop collecting. If you stop collection, you should also use
    <code>SCI_EMPTYUNDOBUFFER</code> to avoid the undo buffer being unsynchronized with the data in
    the buffer.</p>
End Rem
	Method SetUndoCollection(state:Int)
		SendEditor(SCI_SETUNDOCOLLECTION,state)
	End Method
	

Rem
bbdoc: SELECTALL
about: <p><b id="SCI_SELECTALL">SCI_SELECTALL</b><br />
     This selects all the text in the document. The current position is not scrolled into view.</p>
End Rem
	Method SelectAll()
		SendEditor(SCI_SELECTALL)
	End Method
	
Rem
bbdoc: GETSTYLEDTEXT
about: <p><b id="SCI_GETSTYLEDTEXT">SCI_GETSTYLEDTEXT(&lt;unused&gt;, <a class="jump"
    href="#TextRange">TextRange</a> *tr)</b><br />
     This collects styled text into a buffer using two bytes for each cell, with the character at
    the lower address of each pair and the style byte at the upper address. Characters between the
    positions <code>cpMin</code> and <code>cpMax</code> are copied to <code>lpstrText</code> (see
    <code>struct TextRange</code> in <code>Scintilla.h</code>). Two 0 bytes are added to the end of
    the text, so the buffer that <code>lpstrText</code> points at must be at least
    <code>2*(cpMax-cpMin)+2</code> bytes long. No check is made for sensible values of
    <code>cpMin</code> or <code>cpMax</code>. Positions outside the document return character codes
    and style bytes of 0.</p>
See Also: <code><a class="message" href="#SCI_GETSELTEXT">SCI_GETSELTEXT</a>, <a
    class="message" href="#SCI_GETLINE">SCI_GETLINE</a>, <a class="message"
    href="#SCI_GETCURLINE">SCI_GETCURLINE</a>, <a class="message"
    href="#SCI_GETTEXTRANGE">SCI_GETTEXTRANGE</a>, <a class="message"
    href="#SCI_GETTEXT">SCI_GETTEXT</a></code>
End Rem
	Method GetStyledText:Byte Ptr(cpmin:Int,cpmax:Int)
		Local range:TextRange = New TextRange				
		range.cpmin = cpmin
		range.cpmax = cpmax
		range.lpstrText = New Byte[2*(range.cpmax - range.cpmin)+2]
		
		Local tmpLength:Int =  SendEditor(SCI_GETSTYLEDTEXT ,0 , Int Byte Ptr range)
		'Print "Test : " + tmplength + " ; " + (range.cpmax - range.cpmin)
		Return range.lpstrText		
	End Method
	

Rem
bbdoc: CANREDO
End Rem
	Method CanRedo:Int()
		Return SendEditor(SCI_CANREDO)
	End Method
	

Rem
bbdoc: MARKERLINEFROMHANDLE
about: <p><b id="SCI_MARKERLINEFROMHANDLE">SCI_MARKERLINEFROMHANDLE(int markerHandle)</b><br />
     The <code>markerHandle</code> argument is an identifier for a marker returned by <a
    class="message" href="#SCI_MARKERADD"><code>SCI_MARKERADD</code></a>. This function searches
    the document for the marker with this handle and returns the line number that contains it or -1
    if it is not found.</p>
End Rem
	Method MarkerLineFromHandle:Int(handle:Int)
		Return SendEditor(SCI_MARKERLINEFROMHANDLE,handle)
	End Method
	

Rem
bbdoc: MARKERDELETEHANDLE
about: <p><b id="SCI_MARKERDELETEHANDLE">SCI_MARKERDELETEHANDLE(int markerHandle)</b><br />
     The <code>markerHandle</code> argument is an identifier for a marker returned by <a
    class="message" href="#SCI_MARKERADD"><code>SCI_MARKERADD</code></a>. This function searches
    the document for the marker with this handle and deletes the marker if it is found.</p>
End Rem
	Method MarkerDeleteHandle(handle:Int)
		SendEditor(SCI_MARKERDELETEHANDLE, handle)
	End Method
	

Rem
bbdoc: GETUNDOCOLLECTION
End Rem
	Method GetUndoCollection:Int()
		Return SendEditor(SCI_GETUNDOCOLLECTION)
	End Method
	

Rem
bbdoc: GETVIEWWS
End Rem
	Method GetViewWS:Int()
		Return SendEditor(SCI_GETVIEWWS)
	End Method
	

Rem
bbdoc: SETVIEWWS
about: <p><b id="SCI_SETVIEWWS">SCI_SETVIEWWS(int wsMode)</b><br />
     <b id="SCI_GETVIEWWS">SCI_GETVIEWWS</b><br />
     White space can be made visible which may be useful for languages in which white space is
    significant, such as Python. Space characters appear as small centred dots and tab characters
    as light arrows pointing to the right. There are also ways to control the display of <a
    class="jump" href="#LineEndings">end of line characters</a>. The two messages set and get the
    white space display mode. The <code>wsMode</code> argument can be one of:</p>
End Rem
	Method SetViewWS(wsmode:Int)
		SendEditor(SCI_SETVIEWWS,wsmode)
	End Method
	

Rem
bbdoc: POSITIONFROMPOINT
about: <p><b id="SCI_POSITIONFROMPOINT">SCI_POSITIONFROMPOINT(int x, int y)</b><br />
     <b id="SCI_POSITIONFROMPOINTCLOSE">SCI_POSITIONFROMPOINTCLOSE(int x, int y)</b><br />
     <code>SCI_POSITIONFROMPOINT</code> finds the closest character position to a point and
    <code>SCI_POSITIONFROMPOINTCLOSE</code> is similar but returns -1 if the point is outside the
    window or not close to any characters.</p>
End Rem
	Method PositionFromPoint:Int(x:Int,y:Int)
		Return SendEditor(SCI_POSITIONFROMPOINT,x,y)
	End Method
	

Rem
bbdoc: POSITIONFROMPOINTCLOSE
End Rem
	Method PositionFromPointClose:Int(x:Int,y:Int)
		Return SendEditor(SCI_POSITIONFROMPOINTCLOSE,x,y)
	End Method
	

Rem
bbdoc: GOTOLINE
about: <p><b id="SCI_GOTOLINE">SCI_GOTOLINE(int line)</b><br />
     This removes any selection and sets the caret at the start of line number <code>line</code>
    and scrolls the view (if needed) to make it visible. The anchor position is set the same as the
    current position. If <code>line</code> is outside the lines in the document (first line is 0),
    the line set is the first or last.</p>
End Rem
	Method Gotoline(Line:Int)
		SendEditor(SCI_GOTOLINE, Line)
	End Method
	

Rem
bbdoc: GOTOPOS
about: <p><b id="SCI_GOTOPOS">SCI_GOTOPOS(int pos)</b><br />
     This removes any selection, sets the caret at <code>pos</code> and scrolls the view to make
    the caret visible, if necessary. It is equivalent to
    <code>SCI_SETSEL(pos, pos)</code>. The anchor position is set the same as the current
    position.</p>
End Rem
	Method GotoPos(pos:Int)
		SendEditor(SCI_GOTOPOS,pos)
	End Method
	

Rem
bbdoc: SETANCHOR
about: <p><b id="SCI_SETANCHOR">SCI_SETANCHOR(int pos)</b><br />
     This sets the anchor position and creates a selection between the anchor position and the
    current position. The caret is not scrolled into view.</p>
See Also: <a class="message" href="#SCI_SCROLLCARET"><code>SCI_SCROLLCARET</code></a>
End Rem
	Method SetAnchor(pos:Int)
		SendEditor(SCI_SETANCHOR, pos)
	End Method
	

Rem
bbdoc: GETCURLINE
about: <p><b id="SCI_GETCURLINE">SCI_GETCURLINE(int textLen, char *text)</b><br />
     This retrieves the text of the line containing the caret and returns the position within the
    line of the caret. Pass in <code>char* text</code> pointing at a buffer large enough to hold
    the text you wish to retrieve and a terminating 0 character.
    Set <code>textLen</code> to the
    length of the buffer which must be at least 1 to hold the terminating 0 character.
    If the text argument is 0 then the length that should be allocated
    to store the entire current line is returned.</p>
See Also: <code><a class="message" href="#SCI_GETSELTEXT">SCI_GETSELTEXT</a>, <a
    class="message" href="#SCI_GETLINE">SCI_GETLINE</a>, <a class="message"
    href="#SCI_GETTEXT">SCI_GETTEXT</a>, <a class="message"
    href="#SCI_GETSTYLEDTEXT">SCI_GETSTYLEDTEXT</a>, <a class="message"
    href="#SCI_GETTEXTRANGE">SCI_GETTEXTRANGE</a></code>
End Rem
	Method GetCurline:Int()
		Return SendEditor(SCI_GETCURLINE)
	End Method
	

Rem
bbdoc: GETENDSTYLED
about: <p><b id="SCI_GETENDSTYLED">SCI_GETENDSTYLED</b><br />
     Scintilla keeps a record of the last character that is likely to be styled correctly. This is
    moved forwards when characters after it are styled and moved backwards if changes are made to
    the text of the document before it. Before drawing text, this position is checked to see if any
    styling is needed and, if so, a <code><a class="message"
    href="#SCN_STYLENEEDED">SCN_STYLENEEDED</a></code> notification message is sent to the
    container. The container can send <code>SCI_GETENDSTYLED</code> to work out where it needs to
    start styling. Scintilla will always ask to style whole lines.</p>
End Rem
	Method GetEndStyled:Int()
		Return SendEditor(SCI_GETENDSTYLED)
	End Method
	

Rem
bbdoc: CONVERTEOLS
about: <p><b id="SCI_CONVERTEOLS">SCI_CONVERTEOLS(int eolMode)</b><br />
     This message changes all the end of line characters in the document to match
    <code>eolMode</code>. Valid values are: <code>SC_EOL_CRLF</code> (0), <code>SC_EOL_CR</code>
    (1), or <code>SC_EOL_LF</code> (2).</p>
End Rem
	Method ConvertEOLs(eolMode:Int)
		SendEditor(SCI_CONVERTEOLS,eolMode)
	End Method
	

Rem
bbdoc: GETEOLMODE
End Rem
	Method GetEOLMode:Int()
		Return SendEditor(SCI_GETEOLMODE)
	End Method
	

Rem
bbdoc: SETEOLMODE
about: <p><b id="SCI_SETEOLMODE">SCI_SETEOLMODE(int eolMode)</b><br />
     <b id="SCI_GETEOLMODE">SCI_GETEOLMODE</b><br />
     <code>SCI_SETEOLMODE</code> sets the characters that are added into the document when the user
    presses the Enter key. You can set <code>eolMode</code> to one of <code>SC_EOL_CRLF</code> (0),
    <code>SC_EOL_CR</code> (1), or <code>SC_EOL_LF</code> (2). The <code>SCI_GETEOLMODE</code>
    message retrieves the current state.</p>
End Rem
	Method SetEOLMode(eolMode:Int)
		SendEditor(SCI_SETEOLMODE,eolMode)
	End Method
	

Rem
bbdoc: STARTSTYLING
about: <p><b id="SCI_STARTSTYLING">SCI_STARTSTYLING(int pos, int mask)</b><br />
     This prepares for styling by setting the styling position <code>pos</code> to start at and a
    <code>mask</code> indicating which bits of the style bytes can be set. The mask allows styling
    to occur over several passes, with, for example, basic styling done on an initial pass to
    ensure that the text of the code is seen quickly and correctly, and then a second slower pass,
    detecting syntax errors and using indicators to show where these are. For example, with the
    standard settings of 5 style bits and 3 indicator bits, you would use a <code>mask</code> value
    of 31 (0x1f) if you were setting text styles and did not want to change the indicators. After
    <code>SCI_STARTSTYLING</code>, send multiple <code>SCI_SETSTYLING</code> messages for each
    lexical entity to style.</p>
End Rem
	Method StartStyling(pos:Int,mask:Int)
		SendEditor(SCI_STARTSTYLING,pos,mask)
	End Method
	

Rem
bbdoc: SETSTYLING
about: <p><b id="SCI_SETSTYLING">SCI_SETSTYLING(int length, int style)</b><br />
     This message sets the style of <code>length</code> characters starting at the styling position
    and then increases the styling position by <code>length</code>, ready for the next call. If
    <code>sCell</code> is the style byte, the operation is:<br />
     <code>if ((sCell &amp; mask) != style) sCell = (sCell &amp; ~mask) | (style &amp;
    mask);</code><br />
    </p>
End Rem
	Method SetStyling(length:Int,style:Int)
		SendEditor(SCI_SETSTYLING,length,style)
	End Method
	

Rem
bbdoc: GETBUFFEREDDRAW
End Rem
	Method GetBufferedDraw:Int()
		Return SendEditor(SCI_GETBUFFEREDDRAW)
	End Method
	

Rem
bbdoc: SETBUFFEREDDRAW
about: <p><b id="SCI_SETBUFFEREDDRAW">SCI_SETBUFFEREDDRAW(bool isBuffered)</b><br />
     <b id="SCI_GETBUFFEREDDRAW">SCI_GETBUFFEREDDRAW</b><br />
     These messages turn buffered drawing on or off and report the buffered drawing state. Buffered
    drawing draws each line into a bitmap rather than directly to the screen and then copies the
    bitmap to the screen. This avoids flickering although it does take longer. The default is for
    drawing to be buffered.</p>
End Rem
	Method SetBufferedDraw(isbuffered:Int)
		SendEditor(SCI_SETBUFFEREDDRAW, isbuffered)
	End Method
	

Rem
bbdoc: SETTABWIDTH
about: <p><b id="SCI_SETTABWIDTH">SCI_SETTABWIDTH(int widthInChars)</b><br />
     <b id="SCI_GETTABWIDTH">SCI_GETTABWIDTH</b><br />
     <code>SCI_SETTABWIDTH</code> sets the size of a tab as a multiple of the size of a space
    character in <code>STYLE_DEFAULT</code>. The default tab width is 8 characters. There are no
    limits on tab sizes, but values less than 1 or large values may have undesirable effects.</p>
End Rem
	Method SetTabwidth(width:Int)
		SendEditor(SCI_SETTABWIDTH, width)
	End Method
	

Rem
bbdoc: GETTABWIDTH
End Rem
	Method GetTabwidth:Int()
		Return SendEditor(SCI_GETTABWIDTH)
	End Method
	

Rem
bbdoc: SETCODEPAGE
about: <p><b id="SCI_SETCODEPAGE">SCI_SETCODEPAGE(int codePage)</b><br />
     <b id="SCI_GETCODEPAGE">SCI_GETCODEPAGE</b><br />
     Scintilla has some support for Japanese, Chinese and Korean DBCS. Use this message with
    <code>codePage</code> set to the code page number to set Scintilla to use code page information
    to ensure double byte characters are treated as one character rather than two. This also stops
    the caret from moving between the two bytes in a double byte character.
    Do not use this message to choose between different single byte character sets: it doesn't do that.
    Call with
    <code>codePage</code> set to zero to disable DBCS support. The default is
    <code>SCI_SETCODEPAGE(0)</code>.</p>
End Rem
	Method SetCodepage(codepage:Int)
		SendEditor(SCI_SETCODEPAGE, codepage)
	End Method
'break
	

Rem
bbdoc: SETUSEPALETTE
about: <p><b id="SCI_SETUSEPALETTE">SCI_SETUSEPALETTE(bool allowPaletteUse)</b><br />
     <b id="SCI_GETUSEPALETTE">SCI_GETUSEPALETTE</b><br />
     On 8 bit displays, which can only display a maximum of 256 colours, the graphics environment
    mediates between the colour needs of applications through the use of palettes. On GTK+,
    Scintilla always uses a palette.</p>
End Rem
	Method SetUsePalette(allow:Int)
		SendEditor(SCI_SETUSEPALETTE, allow)
	End Method
	

Rem
bbdoc: MARKERDEFINE
about: <p><b id="SCI_MARKERDEFINE">SCI_MARKERDEFINE(int markerNumber, int markerSymbols)</b><br />
     This message associates a marker number in the range 0 to 31 with one of the marker symbols or
    an ASCII character. The general-purpose marker symbols currently available are:<br />
     <code>SC_MARK_CIRCLE</code>, <code>SC_MARK_ROUNDRECT</code>, <code>SC_MARK_ARROW</code>,
    <code>SC_MARK_SMALLRECT</code>, <code>SC_MARK_SHORTARROW</code>, <code>SC_MARK_EMPTY</code>,
    <code>SC_MARK_ARROWDOWN</code>, <code>SC_MARK_MINUS</code>, <code>SC_MARK_PLUS</code>,
    <code>SC_MARK_ARROWS</code>, <code>SC_MARK_DOTDOTDOT</code>, <code>SC_MARK_EMPTY</code>,
    <code>SC_MARK_BACKGROUND</code>, <code>SC_MARK_LEFTRECT</code>,
    <code>SC_MARK_FULLRECT</code>, and <code>SC_MARK_UNDERLINE</code>.</p>
End Rem
	Method MarkerDefine(marker:Int, markersymbol:Int)
		SendEditor(SCI_MARKERDEFINE,marker,markersymbol)
	End Method
	

Rem
bbdoc: MARKERSETFORE
about: <p><b id="SCI_MARKERSETFORE">SCI_MARKERSETFORE(int markerNumber, int <a class="jump"
    href="#colour">colour</a>)</b><br />
     <b id="SCI_MARKERSETBACK">SCI_MARKERSETBACK(int markerNumber, int <a class="jump"
    href="#colour">colour</a>)</b><br />
     These two messages set the foreground and background colour of a marker number.</p>
End Rem
	Method MarkerSetFore(markerNumber:Int, R:Int,G:Int,B:Int)
		SendEditor(SCI_MARKERSETFORE,markernumber,EncodeColor(R,G,B))
	End Method
	

Rem
bbdoc: MARKERSETBACK
End Rem
	Method MarkerSetBack(markerNumber:Int, R:Int,G:Int,B:Int)
		SendEditor(SCI_MARKERSETBACK,markerNumber,EncodeColor(R,G,B))
	End Method
	

Rem
bbdoc: MARKERADD
about: <p><b id="SCI_MARKERADD">SCI_MARKERADD(int line, int markerNumber)</b><br />
     This message adds marker number <code>markerNumber</code> to a line. The message returns -1 if
    this fails (illegal line number, out of memory) or it returns a marker handle number that
    identifies the added marker. You can use this returned handle with <a class="message"
    href="#SCI_MARKERLINEFROMHANDLE"><code>SCI_MARKERLINEFROMHANDLE</code></a> to find where a
    marker is after moving or combining lines and with <a class="message"
    href="#SCI_MARKERDELETEHANDLE"><code>SCI_MARKERDELETEHANDLE</code></a> to delete the marker
    based on its handle. The message does not check the value of markerNumber, nor does it
    check if the line already contains the marker.</p>
End Rem
	Method MarkerAdd(Line:Int,markerNumber:Int)
		SendEditor(SCI_MARKERADD,Line,markerNumber)
	End Method
	

Rem
bbdoc: MARKERDELETE
about: <p><b id="SCI_MARKERDELETE">SCI_MARKERDELETE(int line, int markerNumber)</b><br />
     This searches the given line number for the given marker number and deletes it if it is
    present. If you added the same marker more than once to the line, this will delete one copy
    each time it is used. If you pass in a marker number of -1, all markers are deleted from the
    line.</p>
End Rem
	Method MarkerDelete(Line:Int,markerNumber:Int)
		SendEditor(SCI_MARKERDELETE,Line,markerNumber)
	End Method
	

Rem
bbdoc: MARKERDELETEALL
about: <p><b id="SCI_MARKERDELETEALL">SCI_MARKERDELETEALL(int markerNumber)</b><br />
     This removes markers of the given number from all lines. If markerNumber is -1, it deletes all
    markers from all lines.</p>
End Rem
	Method MarkerDeleteAll(markerNumber:Int = -1)
		SendEditor(SCI_MARKERDELETEALL, markerNumber)
	End Method
	

Rem
bbdoc: MARKERGET
about: <p><b id="SCI_MARKERGET">SCI_MARKERGET(int line)</b><br />
     This returns a 32-bit integer that indicates which markers were present on the line. Bit 0 is
    set if marker 0 is present, bit 1 for marker 1 and so on.</p>
End Rem
	Method MarkerGet:Int(Line:Int)
		Return SendEditor(SCI_MARKERGET,Line)
	End Method
	

Rem
bbdoc: MARKERNEXT
about: <p><b id="SCI_MARKERNEXT">SCI_MARKERNEXT(int lineStart, int markerMask)</b><br />
     <b id="SCI_MARKERPREVIOUS">SCI_MARKERPREVIOUS(int lineStart, int markerMask)</b><br />
     These messages search efficiently for lines that include a given set of markers. The search
    starts at line number <code>lineStart</code> and continues forwards to the end of the file
    (<code>SCI_MARKERNEXT</code>) or backwards to the start of the file
    (<code>SCI_MARKERPREVIOUS</code>). The <code>markerMask</code> argument should have one bit set
    for each marker you wish to find. Set bit 0 to find marker 0, bit 1 for marker 1 and so on. The
    message returns the line number of the first line that contains one of the markers in
    <code>markerMask</code> or -1 if no marker is found.</p>
End Rem
	Method MarkerNext:Int(lineStart:Int, markerMask:Int)
		SendEditor(SCI_MARKERNEXT,lineStart,markerMask)
	End Method
	

Rem
bbdoc: MARKERPREVIOUS
End Rem
	Method MarkerPrevious(lineStart:Int, markerMask:Int)
		SendEditor(SCI_MARKERPREVIOUS,lineStart, markerMask)
	End Method
	

Rem
bbdoc: MARKERDEFINEPIXMAP
about: <p><b id="SCI_MARKERDEFINEPIXMAP">SCI_MARKERDEFINEPIXMAP(int markerNumber, const char
    *xpm)</b><br />
     Markers can be set to pixmaps with this message. The XPM format is used for the pixmap and it
    is limited to pixmaps that use one character per pixel with no named colours.
    The transparent colour may be named 'None'.
    The data should be null terminated.
    Pixmaps use the <code>SC_MARK_PIXMAP</code> marker symbol. You can find the full description of
    the XPM format <a class="jump" href="http://koala.ilog.fr/lehors/xpm.html">here</a>.</p>
End Rem
	Method MarkerDefinepPixmap(markerNumber:Int, xpm:String)
		SendEditorString(SCI_MARKERDEFINEPIXMAP,markerNumber,xpm)
	End Method
	

Rem
bbdoc: MARKERADDSET
about: <p><b id="SCI_MARKERADDSET">SCI_MARKERADDSET(int line, int markerMask)</b><br />
     This message can add one or more markers to a line with a single call, specified in the same "one-bit-per-marker" 32-bit integer format returned by
    <a class="message" href="#SCI_MARKERGET"><code>SCI_MARKERGET</code></a>
    (and used by the mask-based marker search functions
    <a class="message" href="#SCI_MARKERNEXT"><code>SCI_MARKERNEXT</code></a> and
    <a class="message" href="#SCI_MARKERPREVIOUS"><code>SCI_MARKERPREVIOUS</code></a>).
    As with
    <a class="message" href="#SCI_MARKERADD"><code>SCI_MARKERADD</code></a>, no check is made
    to see if any of the markers are already present on the targeted line.</p>
End Rem
	Method MarkerAddSet(Line:Int, markerMask:Int)
		SendEditor(SCI_MARKERADDSET,Line,markerMask)
	End Method
	

Rem
bbdoc: MARKERSETALPHA
about: <p><b id="SCI_MARKERSETALPHA">SCI_MARKERSETALPHA(int markerNumber, int <a class="jump"
    href="#alpha">alpha</a>)</b><br />
     When markers are drawn in the content area, either because there is no margin for them or
     they are of <code>SC_MARK_BACKGROUND</code> or <code>SC_MARK_UNDERLINE</code> types, they may be drawn translucently by
     setting an alpha value.</p>
End Rem
	Method MarkerSetAlpha(markerNumber:Int, alpha:Int)
		SendEditor(SCI_MARKERSETALPHA,markerNumber,alpha)
	End Method
	

Rem
bbdoc: SETMARGINTYPEN
about: <p><b id="SCI_SETMARGINTYPEN">SCI_SETMARGINTYPEN(int margin, int iType)</b><br />
     <b id="SCI_GETMARGINTYPEN">SCI_GETMARGINTYPEN(int margin)</b><br />
     These two routines set and get the type of a margin. The margin argument should be 0, 1, 2, 3 or 4.
    You can use the predefined constants <code>SC_MARGIN_SYMBOL</code> (0) and
    <code>SC_MARGIN_NUMBER</code> (1) to set a margin as either a line number or a symbol margin.
    A margin with application defined text may use <code>SC_MARGIN_TEXT</code> (4) or
    <code>SC_MARGIN_RTEXT</code> (5) to right justify the text.
    By convention, margin 0 is used for line numbers and the next two are used for symbols. You can
    also use the constants <code>SC_MARGIN_BACK</code> (2) and <code>SC_MARGIN_FORE</code> (3) for
    symbol margins that set their background colour to match the STYLE_DEFAULT background and
    foreground colours.</p>
End Rem
	Method SetMarginTypen(margin:Int,iType:Int)
		SendEditor(SCI_SETMARGINTYPEN,margin,iType)
	End Method
	

Rem
bbdoc: GETMARGINTYPEN
End Rem
	Method GetMarginTypen:Int(margin:Int)
		Return SendEditor(SCI_GETMARGINTYPEN,margin)
	End Method
	

Rem
bbdoc: SETMARGINWIDTHN
about: <p><b id="SCI_SETMARGINWIDTHN">SCI_SETMARGINWIDTHN(int margin, int pixelWidth)</b><br />
     <b id="SCI_GETMARGINWIDTHN">SCI_GETMARGINWIDTHN(int margin)</b><br />
     These routines set and get the width of a margin in pixels. A margin with zero width is
    invisible. By default, Scintilla sets margin 1 for symbols with a width of 16 pixels, so this
    is a reasonable guess if you are not sure what would be appropriate. Line number margins widths
    should take into account the number of lines in the document and the line number style. You
    could use something like <a class="message"
    href="#SCI_TEXTWIDTH"><code>SCI_TEXTWIDTH(STYLE_LINENUMBER, "_99999")</code></a> to get a
    suitable width.</p>
End Rem
	Method SetMarginWidthN(margin:Int, width:Int)
		SendEditor(SCI_SETMARGINWIDTHN,margin,width)
	End Method
	

Rem
bbdoc: GETMARGINWIDTHN
End Rem
	Method GetMarginWidthN:Int(margin:Int)
		Return SendEditor(SCI_GETMARGINWIDTHN,margin)
	End Method
	

Rem
bbdoc: SETMARGINMASKN
about: <p><b id="SCI_SETMARGINMASKN">SCI_SETMARGINMASKN(int margin, int mask)</b><br />
     <b id="SCI_GETMARGINMASKN">SCI_GETMARGINMASKN(int margin)</b><br />
     The mask is a 32-bit value. Each bit corresponds to one of 32 logical symbols that can be
    displayed in a margin that is enabled for symbols. There is a useful constant,
    <code>SC_MASK_FOLDERS</code> (0xFE000000 or -33554432), that is a mask for the 7 logical
    symbols used to denote folding. You can assign a wide range of symbols and colours to each of
    the 32 logical symbols, see <a href="#Markers">Markers</a> for more information. If <code>(mask
    &amp; SC_MASK_FOLDERS)==0</code>, the margin background colour is controlled by style 33 (<a
    class="message" href="#StyleDefinition"><code>STYLE_LINENUMBER</code></a>).</p>
End Rem
	Method SetMarginMaskN(margin:Int,mask:Int)
		SendEditor(SCI_SETMARGINMASKN,margin,mask)
	End Method
	

Rem
bbdoc: GETMARGINMASKN
End Rem
	Method GetMarginMaskN:Int(margin:Int)
		Return SendEditor(SCI_GETMARGINMASKN, margin)
	End Method
	

Rem
bbdoc: SETMARGINSENSITIVEN
about: <p><b id="SCI_SETMARGINSENSITIVEN">SCI_SETMARGINSENSITIVEN(int margin, bool
    sensitive)</b><br />
     <b id="SCI_GETMARGINSENSITIVEN">SCI_GETMARGINSENSITIVEN(int margin)</b><br />
     Each of the five margins can be set sensitive or insensitive to mouse clicks. A click in a
    sensitive margin sends a <a class="message"
    href="#SCN_MARGINCLICK"><code>SCN_MARGINCLICK</code></a> <a class="jump"
    href="#Notifications">notification</a> to the container. Margins that are not sensitive act as
    selection margins which make it easy to select ranges of lines. By default, all margins are
    insensitive.</p>
End Rem
	Method SetMarginSensitiveN(margin:Int,sensitive:Int)
		SendEditor(SCI_SETMARGINSENSITIVEN,margin,sensitive)
	End Method
	

Rem
bbdoc: GETMARGINSENSITIVEN
End Rem
	Method GetMarginSensitiveN:Int(margin:Int)
		Return SendEditor(SCI_GETMARGINSENSITIVEN,margin)
	End Method
	

Rem
bbdoc: STYLECLEARALL
about: <p><b id="SCI_STYLECLEARALL">SCI_STYLECLEARALL</b><br />
     This message sets all styles to have the same attributes as <code>STYLE_DEFAULT</code>. If you
    are setting up Scintilla for syntax colouring, it is likely that the lexical styles you set
    will be very similar. One way to set the styles is to:<br />
     1. Set <code>STYLE_DEFAULT</code> to the common features of all styles.<br />
     2. Use <code>SCI_STYLECLEARALL</code> to copy this to all styles.<br />
     3. Set the style attributes that make your lexical styles different.</p>
End Rem
	Method StyleClearAll()
		SendEditor(SCI_STYLECLEARALL)
	End Method
	

Rem
bbdoc: STYLESETFORE
about: <p><b id="SCI_STYLESETFORE">SCI_STYLESETFORE(int styleNumber, int <a class="jump"
    href="#colour">colour</a>)</b><br />
    <b id="SCI_STYLEGETFORE">SCI_STYLEGETFORE(int styleNumber)</b><br />
    <b id="SCI_STYLESETBACK">SCI_STYLESETBACK(int styleNumber, int <a class="jump"
    href="#colour">colour</a>)</b><br />
    <b id="SCI_STYLEGETBACK">SCI_STYLEGETBACK(int styleNumber)</b><br />
    Text is drawn in the foreground colour. The space in each character cell that is not occupied
    by the character is drawn in the background colour.</p>
End Rem
	Method StyleSetFore(styleNumber:Int, R:Int,G:Int,B:Int)
		SendEditor(SCI_STYLESETFORE,styleNumber, EncodeColor(R,G,B))
	End Method
	

Rem
bbdoc: STYLESETBACK
End Rem
	Method StyleSetBack(styleNumber:Int, R:Int,G:Int,B:Int)
		SendEditor(SCI_STYLESETBACK,styleNumber, EncodeColor(R,G,B))
	End Method
	

Rem
bbdoc: STYLESETBOLD
End Rem
	Method StyleSetBold(styleNumber:Int,bold:Int)
		SendEditor(SCI_STYLESETBOLD,styleNumber,bold)
	End Method
	

Rem
bbdoc: STYLESETITALIC
End Rem
	Method StyleSetItalic(styleNumber:Int,italic:Int)
		SendEditor(SCI_STYLESETITALIC,styleNumber,italic)
	End Method
	

Rem
bbdoc: STYLESETSIZE
End Rem
	Method StyleSetSize(styleNumber:Int,size:Int)
		SendEditor(SCI_STYLESETSIZE,styleNumber,size)
	End Method
	

Rem
bbdoc: STYLESETFONT
about: <p><b id="SCI_STYLESETFONT">SCI_STYLESETFONT(int styleNumber, const char *fontName)</b><br />
    <b id="SCI_STYLEGETFONT">SCI_STYLEGETFONT(int styleNumber, char *fontName)</b><br />
    <b id="SCI_STYLESETSIZE">SCI_STYLESETSIZE(int styleNumber, int sizeInPoints)</b><br />
    <b id="SCI_STYLEGETSIZE">SCI_STYLEGETSIZE(int styleNumber)</b><br />
    <b id="SCI_STYLESETBOLD">SCI_STYLESETBOLD(int styleNumber, bool bold)</b><br />
    <b id="SCI_STYLEGETBOLD">SCI_STYLEGETBOLD(int styleNumber)</b><br />
    <b id="SCI_STYLESETITALIC">SCI_STYLESETITALIC(int styleNumber, bool italic)</b><br />
    <b id="SCI_STYLEGETITALIC">SCI_STYLEGETITALIC(int styleNumber)</b><br />
     These messages (plus <a class="message"
    href="#SCI_STYLESETCHARACTERSET"><code>SCI_STYLESETCHARACTERSET</code></a>) set the font
    attributes that are used to match the fonts you request to those available. The
    <code>fontName</code> is a zero terminated string holding the name of a font. Under Windows,
    only the first 32 characters of the name are used and the name is not case sensitive. For
    internal caching, Scintilla tracks fonts by name and does care about the casing of font names,
    so please be consistent. On GTK+ 2.x, either GDK or Pango can be used to display text.
    Pango antialiases text, works well with Unicode and is better supported in recent versions of GTK+
    but GDK is faster.
    Prepend a '!' character to the font name to use Pango.</p>
End Rem
	Method StyleSetFont(styleNumber:Int,_FontName:String)
		SendEditorString(SCI_STYLESETFONT,stylenumber,_fontname)
	End Method
	

Rem
bbdoc: STYLESETEOLFILLED
about: <p><b id="SCI_STYLESETEOLFILLED">SCI_STYLESETEOLFILLED(int styleNumber, bool
    eolFilled)</b><br />
    <b id="SCI_STYLEGETEOLFILLED">SCI_STYLEGETEOLFILLED(int styleNumber)</b><br />
    If the last character in the line has a style with this attribute set, the remainder of the
    line up to the right edge of the window is filled with the background colour set for the last
    character. This is useful when a document contains embedded sections in another language such
    as HTML pages with embedded JavaScript. By setting <code>eolFilled</code> to <code>true</code>
    and a consistent background colour (different from the background colour set for the HTML
    styles) to all JavaScript styles then JavaScript sections will be easily distinguished from
    HTML.</p>
End Rem
	Method StyleSetEOLFilled(styleNumber:Int, eolFilled:Int)
		SendEditor(SCI_STYLESETEOLFILLED,styleNumber,eolFilled)
	End Method
	

Rem
bbdoc: STYLERESETDEFAULT
about: <p><b id="SCI_STYLERESETDEFAULT">SCI_STYLERESETDEFAULT</b><br />
     This message resets <code>STYLE_DEFAULT</code> to its state when Scintilla was
    initialised.</p>
End Rem
	Method StyleResetDefault()
		SendEditor(SCI_STYLERESETDEFAULT)
	End Method
	

Rem
bbdoc: STYLESETUNDERLINE
about: <p><b id="SCI_STYLESETUNDERLINE">SCI_STYLESETUNDERLINE(int styleNumber, bool
    underline)</b><br />
    <b id="SCI_STYLEGETUNDERLINE">SCI_STYLEGETUNDERLINE(int styleNumber)</b><br />
    You can set a style to be underlined. The underline is drawn in the foreground colour. All
    characters with a style that includes the underline attribute are underlined, even if they are
    white space.</p>
End Rem
	Method StyleSetUnderline(styleNumber:Int, underline:Int)
		SendEditor(SCI_STYLESETUNDERLINE,styleNumber,underline)
	End Method
	

Rem
bbdoc: STYLEGETFORE
End Rem
	Method StyleGetFore:Int(styleNumber:Int)
		Return SendEditor(SCI_STYLEGETFORE,styleNumber)
	End Method
	

Rem
bbdoc: STYLEGETBACK
End Rem
	Method StyleGetBack:Int(styleNumber:Int)
		Return SendEditor(SCI_STYLEGETBACK,styleNumber)
	End Method
	

Rem
bbdoc: STYLEGETBOLD
End Rem
	Method StyleGetBold:Int(styleNumber:Int)
		Return SendEditor(SCI_STYLEGETBOLD,styleNumber)
	End Method
	

Rem
bbdoc: STYLEGETITALIC
End Rem
	Method StyleGetItalic:Int(styleNumber:Int)
		Return SendEditor(SCI_STYLEGETITALIC,styleNumber)
	End Method
	

Rem
bbdoc: STYLEGETSIZE
End Rem
	Method StyleGetSize:Int(styleNumber:Int)
		Return SendEditor(SCI_STYLEGETSIZE,styleNumber)
	End Method
	

Rem
bbdoc: STYLEGETFONT
End Rem
	Method StyleGetFont:String(styleNumber:Int)
		Return ReceiveEditorDataString(SCI_STYLEGETFONT,styleNumber,32)
	End Method
	

Rem
bbdoc: STYLEGETEOLFILLED
End Rem
	Method StyleGetEolFilled:Int(stylenumber:Int)
		Return SendEditor(SCI_STYLEGETEOLFILLED,stylenumber)
	End Method
	

Rem
bbdoc: STYLEGETUNDERLINE
End Rem
	Method StyleGetUnderline(stylenumber:Int)
		SendEditor(SCI_STYLEGETUNDERLINE,stylenumber)
	End Method
	

Rem
bbdoc: STYLEGETCASE
End Rem
	Method StyleGetCase:Int(stylenumber:Int)
		Return SendEditor(SCI_STYLEGETCASE,stylenumber)
	End Method
	

Rem
bbdoc: STYLEGETCHARACTERSET
End Rem
	Method StyleGetCharacterset:Int(stylenumber:Int)
		Return SendEditor(SCI_STYLEGETCHARACTERSET,styleNumber)
	End Method
	

Rem
bbdoc: STYLEGETVISIBLE
End Rem
	Method StyleGetVisible:Int(stylenumber:Int)
		Return SendEditor(SCI_STYLEGETVISIBLE,stylenumber)
	End Method
	

Rem
bbdoc: STYLEGETCHANGEABLE
End Rem
	Method StyleGetChangeable:Int(styleNumber:Int)
		Return SendEditor(SCI_STYLEGETCHANGEABLE,stylenumber)
	End Method
	

Rem
bbdoc: STYLEGETHOTSPOT
End Rem
	Method StyleGetHotSpot:Int(stylenumber:Int)
		Return SendEditor(SCI_STYLEGETHOTSPOT,stylenumber)
	End Method
	

Rem
bbdoc: STYLESETCASE
about: <p><b id="SCI_STYLESETCASE">SCI_STYLESETCASE(int styleNumber, int caseMode)</b><br />
    <b id="SCI_STYLEGETCASE">SCI_STYLEGETCASE(int styleNumber)</b><br />
    The value of caseMode determines how text is displayed. You can set upper case
    (<code>SC_CASE_UPPER</code>, 1) or lower case (<code>SC_CASE_LOWER</code>, 2) or display
    normally (<code>SC_CASE_MIXED</code>, 0). This does not change the stored text, only how it is
    displayed.</p>
End Rem
	Method StyleSetCase(styleNumber:Int, casemode:Int)
		SendEditor(SCI_STYLESETCASE, styleNumber:Int, casemode:Int)
	End Method
	

Rem
bbdoc: STYLESETCHARACTERSET
about: <p><b id="SCI_STYLESETCHARACTERSET">SCI_STYLESETCHARACTERSET(int styleNumber, int
    charSet)</b><br />
    <b id="SCI_STYLEGETCHARACTERSET">SCI_STYLEGETCHARACTERSET(int styleNumber)</b><br />
    You can set a style to use a different character set than the default. The places where such
    characters sets are likely to be useful are comments and literal strings. For example,
    <code>SCI_STYLESETCHARACTERSET(SCE_C_STRING, SC_CHARSET_RUSSIAN)</code> would ensure that
    strings in Russian would display correctly in C and C++ (<code>SCE_C_STRING</code> is the style
    number used by the C and C++ lexer to display literal strings; it has the value 6). This
    feature works differently on Windows and GTK+.</p>
End Rem
	Method StyleSetCharacterset(styleNumber:Int, charset:Int)
		SendEditor(SCI_STYLESETCHARACTERSET, styleNumber, charset)
	End Method
	

Rem
bbdoc: STYLESETHOTSPOT
about: <p><b id="SCI_STYLESETHOTSPOT">SCI_STYLESETHOTSPOT(int styleNumber, bool
    hotspot)</b><br />
    <b id="SCI_STYLEGETHOTSPOT">SCI_STYLEGETHOTSPOT(int styleNumber)</b><br />
    This style is used to mark ranges of text that can detect mouse clicks.
    The cursor changes to a hand over hotspots, and the foreground, and background colours
    may change and an underline appear to indicate that these areas are sensitive to clicking.
    This may be used to allow hyperlinks to other documents.</p>
End Rem
	Method StyleSetHotspot(stylenumber:Int, hotspot:Int)
		SendEditor(SCI_STYLESETHOTSPOT)
	End Method
	

Rem
bbdoc: SETSELFORE
about: <p><b id="SCI_SETSELFORE">SCI_SETSELFORE(bool useSelectionForeColour, int <a class="jump"
    href="#colour">colour</a>)</b><br />
     <b id="SCI_SETSELBACK">SCI_SETSELBACK(bool useSelectionBackColour, int <a class="jump"
    href="#colour">colour</a>)</b><br />
     You can choose to override the default selection colouring with these two messages. The colour
    you provide is used if you set <code>useSelection*Colour</code> to <code>true</code>. If it is
    set to <code>false</code>, the default styled colouring is used and the <code>colour</code>
    argument has no effect.</p>
End Rem
	Method SetSelFore(useSelectionForeColour:Int, r:Int, g:Int, b:Int)
		SendEditor(SCI_SETSELFORE, useSelectionForeColour, EncodeColor(r, g, b))
	End Method
	

Rem
bbdoc: SETSELBACK
End Rem
	Method SetSelBack(useSelectionBackColour:Int, r:Int, g:Int, b:Int)
		SendEditor(SCI_SETSELBACK, useSelectionBackColour, EncodeColor(r, g, b))
	End Method
	

Rem
bbdoc: GETSELALPHA
End Rem
	Method GetSelAlpha:Int()
		Return SendEditor(SCI_GETSELALPHA)
	End Method
	

Rem
bbdoc: SETSELALPHA
about: <p><b id="SCI_SETSELALPHA">SCI_SETSELALPHA(int <a class="jump" href="#alpha">alpha</a>)</b><br />
     <b id="SCI_GETSELALPHA">SCI_GETSELALPHA</b><br />
     The selection can be drawn translucently in the selection background colour by
     setting an alpha value.</p>
End Rem
	Method SetSelAlpha(Alpha:Int)
		SendEditor(SCI_SETSELALPHA, Alpha)
	End Method
	

Rem
bbdoc: GETSELEOLFILLED
End Rem
	Method GetSelEolFilled:Int()
		Return SendEditor(SCI_GETSELEOLFILLED)
	End Method
	

Rem
bbdoc: SETSELEOLFILLED
about: <p><b id="SCI_SETSELEOLFILLED">SCI_SETSELEOLFILLED(bool filled)</b><br />
     <b id="SCI_GETSELEOLFILLED">SCI_GETSELEOLFILLED</b><br />
     The selection can be drawn up to the right hand border by setting this property.</p>
End Rem
	Method SetSelEolFilled(filled:Int)
		SendEditor(SCI_SETSELEOLFILLED, filled)
	End Method
	

Rem
bbdoc: SETCARETFORE
about: <p><b id="SCI_SETCARETFORE">SCI_SETCARETFORE(int <a class="jump"
    href="#colour">colour</a>)</b><br />
     <b id="SCI_GETCARETFORE">SCI_GETCARETFORE</b><br />
     The colour of the caret can be set with <code>SCI_SETCARETFORE</code> and retrieved with
    <code>SCI_GETCARETFORE</code>.</p>
End Rem
	Method SetCaretFore()
		SendEditor(SCI_SETCARETFORE)
	End Method
	

Rem
bbdoc: ASSIGNCMDKEY
about: <p><b id="SCI_ASSIGNCMDKEY">SCI_ASSIGNCMDKEY(int <a class="jump"
    href="#keyDefinition">keyDefinition</a>, int sciCommand)</b><br />
     This assigns the given key definition to a Scintilla command identified by
    <code>sciCommand</code>. <code>sciCommand</code> can be any <code>SCI_*</code> command that has
    no arguments.</p>
End Rem
	Method Assigncmdkey()
		SendEditor(SCI_ASSIGNCMDKEY)
	End Method
	

Rem
bbdoc: CLEARCMDKEY
about: <p><b id="SCI_CLEARCMDKEY">SCI_CLEARCMDKEY(int <a class="jump"
    href="#keyDefinition">keyDefinition</a>)</b><br />
     This makes the given key definition do nothing by assigning the action <code>SCI_NULL</code>
    to it.</p>
End Rem
	Method Clearcmdkey()
		SendEditor(SCI_CLEARCMDKEY)
	End Method
	

Rem
bbdoc: CLEARALLCMDKEYS
about: <p><b id="SCI_CLEARALLCMDKEYS">SCI_CLEARALLCMDKEYS</b><br />
     This command removes all keyboard command mapping by setting an empty mapping table.</p>
End Rem
	Method Clearallcmdkeys()
		SendEditor(SCI_CLEARALLCMDKEYS)
	End Method
	

Rem
bbdoc: SETSTYLINGEX
about: <p><b id="SCI_SETSTYLINGEX">SCI_SETSTYLINGEX(int length, const char *styles)</b><br />
     As an alternative to <code>SCI_SETSTYLING</code>, which applies the same style to each byte,
    you can use this message which specifies the styles for each of <code>length</code> bytes from
    the styling position and then increases the styling position by <code>length</code>, ready for
    the next call. The <code>length</code> styling bytes pointed at by <code>styles</code> should
    not contain any bits not set in mask.</p>
End Rem
	Method Setstylingex()
		SendEditor(SCI_SETSTYLINGEX)
	End Method
	

Rem
bbdoc: STYLESETVISIBLE
about: <p><b id="SCI_STYLESETVISIBLE">SCI_STYLESETVISIBLE(int styleNumber, bool visible)</b><br />
    <b id="SCI_STYLEGETVISIBLE">SCI_STYLEGETVISIBLE(int styleNumber)</b><br />
    Text is normally visible. However, you can completely hide it by giving it a style with the
    <code>visible</code> set to 0. This could be used to hide embedded formatting instructions or
    hypertext keywords in HTML or XML.</p>
End Rem
	Method Stylesetvisible()
		SendEditor(SCI_STYLESETVISIBLE)
	End Method
	

Rem
bbdoc: GETCARETPERIOD
End Rem
	Method Getcaretperiod()
		SendEditor(SCI_GETCARETPERIOD)
	End Method
	

Rem
bbdoc: SETCARETPERIOD
about: <p><b id="SCI_SETCARETPERIOD">SCI_SETCARETPERIOD(int milliseconds)</b><br />
     <b id="SCI_GETCARETPERIOD">SCI_GETCARETPERIOD</b><br />
     The rate at which the caret blinks can be set with <code>SCI_SETCARETPERIOD</code> which
    determines the time in milliseconds that the caret is visible or invisible before changing
    state. Setting the period to 0 stops the caret blinking. The default value is 500 milliseconds.
    <code>SCI_GETCARETPERIOD</code> returns the current setting.</p>
End Rem
	Method Setcaretperiod()
		SendEditor(SCI_SETCARETPERIOD)
	End Method
	

Rem
bbdoc: SETWORDCHARS
about: <p><b id="SCI_SETWORDCHARS">SCI_SETWORDCHARS(&lt;unused&gt;, const char *chars)</b><br />
     Scintilla has several functions that operate on words, which are defined to be contiguous
    sequences of characters from a particular set of characters. This message defines which
    characters are members of that set. The character sets are set to default values before processing this
    function.
    For example, if you don't allow '_' in your set of characters
    use:<br />
     <code>SCI_SETWORDCHARS(0, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")</code>;</p>
End Rem
	Method Setwordchars()
		SendEditor(SCI_SETWORDCHARS)
	End Method
	

Rem
bbdoc: BEGINUNDOACTION
about: <p><b id="SCI_BEGINUNDOACTION">SCI_BEGINUNDOACTION</b><br />
     <b id="SCI_ENDUNDOACTION">SCI_ENDUNDOACTION</b><br />
     Send these two messages to Scintilla to mark the beginning and end of a set of operations that
    you want to undo all as one operation but that you have to generate as several operations.
    Alternatively, you can use these to mark a set of operations that you do not want to have
    combined with the preceding or following operations if they are undone.</p>
End Rem
	Method Beginundoaction()
		SendEditor(SCI_BEGINUNDOACTION)
	End Method
	

Rem
bbdoc: ENDUNDOACTION
End Rem
	Method Endundoaction()
		SendEditor(SCI_ENDUNDOACTION)
	End Method
	

Rem
bbdoc: INDICSETSTYLE
about: <p><b id="SCI_INDICSETSTYLE">SCI_INDICSETSTYLE(int indicatorNumber, int
    indicatorStyle)</b><br />
     <b id="SCI_INDICGETSTYLE">SCI_INDICGETSTYLE(int indicatorNumber)</b><br />
     These two messages set and get the style for a particular indicator. The indicator styles
    currently available are:</p>
End Rem
	Method Indicsetstyle()
		SendEditor(SCI_INDICSETSTYLE)
	End Method
	

Rem
bbdoc: INDICGETSTYLE
End Rem
	Method Indicgetstyle()
		SendEditor(SCI_INDICGETSTYLE)
	End Method
	

Rem
bbdoc: INDICSETFORE
about: <p><b id="SCI_INDICSETFORE">SCI_INDICSETFORE(int indicatorNumber, int <a class="jump"
    href="#colour">colour</a>)</b><br />
     <b id="SCI_INDICGETFORE">SCI_INDICGETFORE(int indicatorNumber)</b><br />
     These two messages set and get the colour used to draw an indicator. The default indicator
    colours are equivalent to:<br />
     <code>SCI_INDICSETFORE(0, 0x007f00);</code> (dark green)<br />
     <code>SCI_INDICSETFORE(1, 0xff0000);</code> (light blue)<br />
     <code>SCI_INDICSETFORE(2, 0x0000ff);</code> (light red)</p>
End Rem
	Method Indicsetfore()
		SendEditor(SCI_INDICSETFORE)
	End Method
	

Rem
bbdoc: INDICGETFORE
End Rem
	Method Indicgetfore()
		SendEditor(SCI_INDICGETFORE)
	End Method
	

Rem
bbdoc: INDICSETUNDER
about: <p><b id="SCI_INDICSETUNDER">SCI_INDICSETUNDER(int indicatorNumber, bool under)</b><br />
     <b id="SCI_INDICGETUNDER">SCI_INDICGETUNDER(int indicatorNumber)</b><br />
     These two messages set and get whether an indicator is drawn under text or over(default).
     Drawing under text works only for modern indicators when <a class="message" href="#SCI_SETTWOPHASEDRAW">two phase drawing</a>
     is enabled.</p>
End Rem
	Method Indicsetunder()
		SendEditor(SCI_INDICSETUNDER)
	End Method
	

Rem
bbdoc: INDICGETUNDER
End Rem
	Method Indicgetunder()
		SendEditor(SCI_INDICGETUNDER)
	End Method
	

Rem
bbdoc: SETWHITESPACEFORE
about: <p><b id="SCI_SETWHITESPACEFORE">SCI_SETWHITESPACEFORE(bool useWhitespaceForeColour, int <a
    class="jump" href="#colour">colour</a>)</b><br />
     <b id="SCI_SETWHITESPACEBACK">SCI_SETWHITESPACEBACK(bool useWhitespaceBackColour, int <a
    class="jump" href="#colour">colour</a>)</b><br />
     By default, the colour of visible white space is determined by the lexer in use. The
    foreground and/or background colour of all visible white space can be set globally, overriding
    the lexer's colours with <code>SCI_SETWHITESPACEFORE</code> and
    <code>SCI_SETWHITESPACEBACK</code>.</p>
End Rem
	Method Setwhitespacefore()
		SendEditor(SCI_SETWHITESPACEFORE)
	End Method
	

Rem
bbdoc: SETWHITESPACEBACK
End Rem
	Method Setwhitespaceback()
		SendEditor(SCI_SETWHITESPACEBACK)
	End Method
	

Rem
bbdoc: SETSTYLEBITS
about: <p><b id="SCI_SETSTYLEBITS">SCI_SETSTYLEBITS(int bits)</b><br />
     <b id="SCI_GETSTYLEBITS">SCI_GETSTYLEBITS</b><br />
     This pair of routines sets and reads back the number of bits in each cell to use for styling,
    to a maximum of 7 style bits. The remaining bits can be used as indicators. The standard
    setting is <code>SCI_SETSTYLEBITS(5)</code>.
    The number of styling bits needed by the current lexer can be found with
    <a class="message" href="#SCI_GETSTYLEBITSNEEDED">SCI_GETSTYLEBITSNEEDED</a>.</p>
End Rem
	Method Setstylebits()
		SendEditor(SCI_SETSTYLEBITS)
	End Method
	

Rem
bbdoc: GETSTYLEBITS
End Rem
	Method Getstylebits()
		SendEditor(SCI_GETSTYLEBITS)
	End Method
	

Rem
bbdoc: SETLINESTATE
about: <p><b id="SCI_SETLINESTATE">SCI_SETLINESTATE(int line, int value)</b><br />
     <b id="SCI_GETLINESTATE">SCI_GETLINESTATE(int line)</b><br />
     As well as the 8 bits of lexical state stored for each character there is also an integer
    stored for each line. This can be used for longer lived parse states such as what the current
    scripting language is in an ASP page. Use <code>SCI_SETLINESTATE</code> to set the integer
    value and <code>SCI_GETLINESTATE</code> to get the value.
    Changing the value produces a <a class="message" href="#SC_MOD_CHANGELINESTATE">SC_MOD_CHANGELINESTATE</a> notification.
    </p>
End Rem
	Method Setlinestate()
		SendEditor(SCI_SETLINESTATE)
	End Method
	

Rem
bbdoc: GETLINESTATE
End Rem
	Method Getlinestate()
		SendEditor(SCI_GETLINESTATE)
	End Method
	

Rem
bbdoc: GETMAXLINESTATE
about: <p><b id="SCI_GETMAXLINESTATE">SCI_GETMAXLINESTATE</b><br />
     This returns the last line that has any line state.</p>
End Rem
	Method Getmaxlinestate()
		SendEditor(SCI_GETMAXLINESTATE)
	End Method
	

Rem
bbdoc: GETCARETLINEVISIBLE
End Rem
	Method Getcaretlinevisible()
		SendEditor(SCI_GETCARETLINEVISIBLE)
	End Method
	

Rem
bbdoc: SETCARETLINEVISIBLE
about: <p><b id="SCI_SETCARETLINEVISIBLE">SCI_SETCARETLINEVISIBLE(bool show)</b><br />
     <b id="SCI_GETCARETLINEVISIBLE">SCI_GETCARETLINEVISIBLE</b><br />
     <b id="SCI_SETCARETLINEBACK">SCI_SETCARETLINEBACK(int <a class="jump"
    href="#colour">colour</a>)</b><br />
     <b id="SCI_GETCARETLINEBACK">SCI_GETCARETLINEBACK</b><br />
     <b id="SCI_SETCARETLINEBACKALPHA">SCI_SETCARETLINEBACKALPHA(int <a class="jump" href="#alpha">alpha</a>)</b><br />
     <b id="SCI_GETCARETLINEBACKALPHA">SCI_GETCARETLINEBACKALPHA</b><br />
     You can choose to make the background colour of the line containing the caret different with
    these messages. To do this, set the desired background colour with
    <code>SCI_SETCARETLINEBACK</code>, then use <code>SCI_SETCARETLINEVISIBLE(true)</code> to
    enable the effect. You can cancel the effect with <code>SCI_SETCARETLINEVISIBLE(false)</code>.
    The two <code>SCI_GETCARET*</code> functions return the state and the colour. This form of
    background colouring has highest priority when a line has markers that would otherwise change
    the background colour.
           The caret line may also be drawn translucently which allows other background colours to show
           through. This is done by setting the alpha (translucency) value by calling
           SCI_SETCARETLINEBACKALPHA. When the alpha is not SC_ALPHA_NOALPHA,
           the caret line is drawn after all other features so will affect the colour of all other features.
          </p>
End Rem
	Method Setcaretlinevisible()
		SendEditor(SCI_SETCARETLINEVISIBLE)
	End Method
	

Rem
bbdoc: GETCARETLINEBACK
End Rem
	Method Getcaretlineback()
		SendEditor(SCI_GETCARETLINEBACK)
	End Method
	

Rem
bbdoc: SETCARETLINEBACK
End Rem
	Method Setcaretlineback()
		SendEditor(SCI_SETCARETLINEBACK)
	End Method
	

Rem
bbdoc: STYLESETCHANGEABLE
about: <p><b id="SCI_STYLESETCHANGEABLE">SCI_STYLESETCHANGEABLE(int styleNumber, bool
    changeable)</b><br />
    <b id="SCI_STYLEGETCHANGEABLE">SCI_STYLEGETCHANGEABLE(int styleNumber)</b><br />
    This is an experimental and incompletely implemented style attribute. The default setting is
    <code>changeable</code> set <code>true</code> but when set <code>false</code> it makes text
    read-only. Currently it only stops the caret from being within not-changeable text and does not
    yet stop deleting a range that contains not-changeable text.</p>
End Rem
	Method Stylesetchangeable()
		SendEditor(SCI_STYLESETCHANGEABLE)
	End Method
	

Rem
bbdoc: AUTOCSHOW
about: <p><b id="SCI_AUTOCSHOW">SCI_AUTOCSHOW(int lenEntered, const char *list)</b><br />
     This message causes a list to be displayed. <code>lenEntered</code> is the number of
    characters of the word already entered and <code>list</code> is the list of words separated by
    separator characters. The initial separator character is a space but this can be set or got
    with <a class="message" href="#SCI_AUTOCSETSEPARATOR"><code>SCI_AUTOCSETSEPARATOR</code></a>
    and <a class="message"
    href="#SCI_AUTOCGETSEPARATOR"><code>SCI_AUTOCGETSEPARATOR</code></a>.</p>
End Rem
	Method Autocshow()
		SendEditor(SCI_AUTOCSHOW)
	End Method
	

Rem
bbdoc: AUTOCCANCEL
about: <p><b id="SCI_AUTOCCANCEL">SCI_AUTOCCANCEL</b><br />
     This message cancels any displayed autocompletion list. When in autocompletion mode, the list
    should disappear when the user types a character that can not be part of the autocompletion,
    such as '.', '(' or '[' when typing an identifier. A set of characters that will cancel
    autocompletion can be specified with <a class="message"
    href="#SCI_AUTOCSTOPS"><code>SCI_AUTOCSTOPS</code></a>.</p>
End Rem
	Method Autoccancel()
		SendEditor(SCI_AUTOCCANCEL)
	End Method
	

Rem
bbdoc: AUTOCACTIVE
about: <p><b id="SCI_AUTOCACTIVE">SCI_AUTOCACTIVE</b><br />
     This message returns non-zero if there is an active autocompletion list and zero if there is
    not.</p>
End Rem
	Method Autocactive()
		SendEditor(SCI_AUTOCACTIVE)
	End Method
	

Rem
bbdoc: AUTOCPOSSTART
about: <p><b id="SCI_AUTOCPOSSTART">SCI_AUTOCPOSSTART</b><br />
     This returns the value of the current position when <code>SCI_AUTOCSHOW</code> started display
    of the list.</p>
End Rem
	Method Autocposstart()
		SendEditor(SCI_AUTOCPOSSTART)
	End Method
	

Rem
bbdoc: AUTOCCOMPLETE
about: <p><b id="SCI_AUTOCCOMPLETE">SCI_AUTOCCOMPLETE</b><br />
     This message triggers autocompletion. This has the same effect as the tab key.</p>
End Rem
	Method Autoccomplete()
		SendEditor(SCI_AUTOCCOMPLETE)
	End Method
	

Rem
bbdoc: AUTOCSTOPS
about: <p><b id="SCI_AUTOCSTOPS">SCI_AUTOCSTOPS(&lt;unused&gt;, const char *chars)</b><br />
     The <code>chars</code> argument is a string containing a list of characters that will
    automatically cancel the autocompletion list. When you start the editor, this list is
    empty.</p>
End Rem
	Method Autocstops()
		SendEditor(SCI_AUTOCSTOPS)
	End Method
	

Rem
bbdoc: AUTOCSETSEPARATOR
about: <p><b id="SCI_AUTOCSETSEPARATOR">SCI_AUTOCSETSEPARATOR(char separator)</b><br />
     <b id="SCI_AUTOCGETSEPARATOR">SCI_AUTOCGETSEPARATOR</b><br />
     These two messages set and get the separator character used to separate words in the
    <code>SCI_AUTOCSHOW</code> list. The default is the space character.</p>
End Rem
	Method Autocsetseparator()
		SendEditor(SCI_AUTOCSETSEPARATOR)
	End Method
	

Rem
bbdoc: AUTOCGETSEPARATOR
End Rem
	Method Autocgetseparator()
		SendEditor(SCI_AUTOCGETSEPARATOR)
	End Method
	

Rem
bbdoc: AUTOCSELECT
about: <p><b id="SCI_AUTOCSELECT">SCI_AUTOCSELECT(&lt;unused&gt;, const char *select)</b><br />
     <b id="SCI_AUTOCGETCURRENT">SCI_AUTOCGETCURRENT</b><br />
     This message selects an item in the autocompletion list. It searches the list of words for the
    first that matches <code>select</code>. By default, comparisons are case sensitive, but you can
    change this with <a class="message"
    href="#SCI_AUTOCSETIGNORECASE"><code>SCI_AUTOCSETIGNORECASE</code></a>. The match is character
    by character for the length of the <code>select</code> string. That is, if select is "Fred" it
    will match "Frederick" if this is the first item in the list that begins with "Fred". If an
    item is found, it is selected. If the item is not found, the autocompletion list closes if
    auto-hide is true (see <a class="message"
    href="#SCI_AUTOCSETAUTOHIDE"><code>SCI_AUTOCSETAUTOHIDE</code></a>).<br />
    The current selection can be retrieved with <code>SCI_AUTOCGETCURRENT</code>
    </p>
End Rem
	Method Autocselect()
		SendEditor(SCI_AUTOCSELECT)
	End Method
	

Rem
bbdoc: AUTOCSETCANCELATSTART
about: <p><b id="SCI_AUTOCSETCANCELATSTART">SCI_AUTOCSETCANCELATSTART(bool cancel)</b><br />
     <b id="SCI_AUTOCGETCANCELATSTART">SCI_AUTOCGETCANCELATSTART</b><br />
     The default behavior is for the list to be cancelled if the caret moves before the location it
    was at when the list was displayed. By calling this message with a <code>false</code> argument,
    the list is not cancelled until the caret moves before the first character of the word being
    completed.</p>
End Rem
	Method Autocsetcancelatstart()
		SendEditor(SCI_AUTOCSETCANCELATSTART)
	End Method
	

Rem
bbdoc: AUTOCGETCANCELATSTART
End Rem
	Method Autocgetcancelatstart()
		SendEditor(SCI_AUTOCGETCANCELATSTART)
	End Method
	

Rem
bbdoc: AUTOCSETFILLUPS
about: <p><b id="SCI_AUTOCSETFILLUPS">SCI_AUTOCSETFILLUPS(&lt;unused&gt;, const char *chars)</b><br />
     If a fillup character is typed with an autocompletion list active, the currently selected item
    in the list is added into the document, then the fillup character is added. Common fillup
    characters are '(', '[' and '.' but others are possible depending on the language. By default,
    no fillup characters are set.</p>
End Rem
	Method Autocsetfillups()
		SendEditor(SCI_AUTOCSETFILLUPS)
	End Method
	

Rem
bbdoc: AUTOCSETCHOOSESINGLE
about: <p><b id="SCI_AUTOCSETCHOOSESINGLE">SCI_AUTOCSETCHOOSESINGLE(bool chooseSingle)</b><br />
     <b id="SCI_AUTOCGETCHOOSESINGLE">SCI_AUTOCGETCHOOSESINGLE</b><br />
     If you use <code>SCI_AUTOCSETCHOOSESINGLE(1)</code> and a list has only one item, it is
    automatically added and no list is displayed. The default is to display the list even if there
    is only a single item.</p>
End Rem
	Method Autocsetchoosesingle()
		SendEditor(SCI_AUTOCSETCHOOSESINGLE)
	End Method
	

Rem
bbdoc: AUTOCGETCHOOSESINGLE
End Rem
	Method Autocgetchoosesingle()
		SendEditor(SCI_AUTOCGETCHOOSESINGLE)
	End Method
	

Rem
bbdoc: AUTOCSETIGNORECASE
about: <p><b id="SCI_AUTOCSETIGNORECASE">SCI_AUTOCSETIGNORECASE(bool ignoreCase)</b><br />
     <b id="SCI_AUTOCGETIGNORECASE">SCI_AUTOCGETIGNORECASE</b><br />
     By default, matching of characters to list members is case sensitive. These messages let you
    set and get case sensitivity.</p>
End Rem
	Method Autocsetignorecase()
		SendEditor(SCI_AUTOCSETIGNORECASE)
	End Method
	

Rem
bbdoc: AUTOCGETIGNORECASE
End Rem
	Method Autocgetignorecase()
		SendEditor(SCI_AUTOCGETIGNORECASE)
	End Method
	

Rem
bbdoc: USERLISTSHOW
about: <p><b id="SCI_USERLISTSHOW">SCI_USERLISTSHOW(int listType, const char *list)</b><br />
     The <code>listType</code> parameter is returned to the container as the <code>wParam</code>
    field of the <a class="message" href="#SCNotification"><code>SCNotification</code></a>
    structure. It must be greater than 0 as this is how Scintilla tells the difference between an
    autocompletion list and a user list. If you have different types of list, for example a list of
    buffers and a list of macros, you can use <code>listType</code> to tell which one has returned
    a selection. </p>
End Rem
	Method Userlistshow()
		SendEditor(SCI_USERLISTSHOW)
	End Method
	

Rem
bbdoc: AUTOCSETAUTOHIDE
about: <p><b id="SCI_AUTOCSETAUTOHIDE">SCI_AUTOCSETAUTOHIDE(bool autoHide)</b><br />
     <b id="SCI_AUTOCGETAUTOHIDE">SCI_AUTOCGETAUTOHIDE</b><br />
     By default, the list is cancelled if there are no viable matches (the user has typed
    characters that no longer match a list entry). If you want to keep displaying the original
    list, set <code>autoHide</code> to <code>false</code>. This also effects <a class="message"
    href="#SCI_AUTOCSELECT"><code>SCI_AUTOCSELECT</code></a>.</p>
End Rem
	Method Autocsetautohide()
		SendEditor(SCI_AUTOCSETAUTOHIDE)
	End Method
	

Rem
bbdoc: AUTOCGETAUTOHIDE
End Rem
	Method Autocgetautohide()
		SendEditor(SCI_AUTOCGETAUTOHIDE)
	End Method
	

Rem
bbdoc: AUTOCSETDROPRESTOFWORD
about: <p><b id="SCI_AUTOCSETDROPRESTOFWORD">SCI_AUTOCSETDROPRESTOFWORD(bool dropRestOfWord)</b><br />
     <b id="SCI_AUTOCGETDROPRESTOFWORD">SCI_AUTOCGETDROPRESTOFWORD</b><br />
     When an item is selected, any word characters following the caret are first erased if
    <code>dropRestOfWord</code> is set <code>true</code>. The default is <code>false</code>.</p>
End Rem
	Method Autocsetdroprestofword()
		SendEditor(SCI_AUTOCSETDROPRESTOFWORD)
	End Method
	

Rem
bbdoc: AUTOCGETDROPRESTOFWORD
End Rem
	Method Autocgetdroprestofword()
		SendEditor(SCI_AUTOCGETDROPRESTOFWORD)
	End Method
	

Rem
bbdoc: REGISTERIMAGE
End Rem
	Method Registerimage()
		SendEditor(SCI_REGISTERIMAGE)
	End Method
	

Rem
bbdoc: CLEARREGISTEREDIMAGES
End Rem
	Method Clearregisteredimages()
		SendEditor(SCI_CLEARREGISTEREDIMAGES)
	End Method
	

Rem
bbdoc: AUTOCGETTYPESEPARATOR
End Rem
	Method Autocgettypeseparator()
		SendEditor(SCI_AUTOCGETTYPESEPARATOR)
	End Method
	

Rem
bbdoc: AUTOCSETTYPESEPARATOR
End Rem
	Method Autocsettypeseparator()
		SendEditor(SCI_AUTOCSETTYPESEPARATOR)
	End Method
	

Rem
bbdoc: AUTOCSETMAXWIDTH
End Rem
	Method Autocsetmaxwidth()
		SendEditor(SCI_AUTOCSETMAXWIDTH)
	End Method
	

Rem
bbdoc: AUTOCGETMAXWIDTH
End Rem
	Method Autocgetmaxwidth()
		SendEditor(SCI_AUTOCGETMAXWIDTH)
	End Method
	

Rem
bbdoc: AUTOCSETMAXHEIGHT
End Rem
	Method Autocsetmaxheight()
		SendEditor(SCI_AUTOCSETMAXHEIGHT)
	End Method
	

Rem
bbdoc: AUTOCGETMAXHEIGHT
End Rem
	Method Autocgetmaxheight()
		SendEditor(SCI_AUTOCGETMAXHEIGHT)
	End Method
	

Rem
bbdoc: SETINDENT
about: <p><b id="SCI_SETINDENT">SCI_SETINDENT(int widthInChars)</b><br />
     <b id="SCI_GETINDENT">SCI_GETINDENT</b><br />
     <code>SCI_SETINDENT</code> sets the size of indentation in terms of the width of a space in <a
    class="message" href="#StyleDefinition"><code>STYLE_DEFAULT</code></a>. If you set a width of
    0, the indent size is the same as the tab size. There are no limits on indent sizes, but values
    less than 0 or large values may have undesirable effects.
    </p>
End Rem
	Method Setindent()
		SendEditor(SCI_SETINDENT)
	End Method
	

Rem
bbdoc: GETINDENT
End Rem
	Method Getindent()
		SendEditor(SCI_GETINDENT)
	End Method
	

Rem
bbdoc: SETUSETABS
about: <p><b id="SCI_SETUSETABS">SCI_SETUSETABS(bool useTabs)</b><br />
     <b id="SCI_GETUSETABS">SCI_GETUSETABS</b><br />
     <code>SCI_SETUSETABS</code> determines whether indentation should be created out of a mixture
    of tabs and spaces or be based purely on spaces. Set <code>useTabs</code> to <code>false</code>
    (0) to create all tabs and indents out of spaces. The default is <code>true</code>. You can use
    <a class="message" href="#SCI_GETCOLUMN"><code>SCI_GETCOLUMN</code></a> to get the column of a
    position taking the width of a tab into account.</p>
End Rem
	Method Setusetabs()
		SendEditor(SCI_SETUSETABS)
	End Method
	

Rem
bbdoc: GETUSETABS
End Rem
	Method Getusetabs()
		SendEditor(SCI_GETUSETABS)
	End Method
	

Rem
bbdoc: SETLINEINDENTATION
about: <p><b id="SCI_SETLINEINDENTATION">SCI_SETLINEINDENTATION(int line, int indentation)</b><br />
     <b id="SCI_GETLINEINDENTATION">SCI_GETLINEINDENTATION(int line)</b><br />
     The amount of indentation on a line can be discovered and set with
    <code>SCI_GETLINEINDENTATION</code> and <code>SCI_SETLINEINDENTATION</code>. The indentation is
    measured in character columns, which correspond to the width of space characters.</p>
End Rem
	Method Setlineindentation()
		SendEditor(SCI_SETLINEINDENTATION)
	End Method
	

Rem
bbdoc: GETLINEINDENTATION
End Rem
	Method Getlineindentation()
		SendEditor(SCI_GETLINEINDENTATION)
	End Method
	

Rem
bbdoc: GETLINEINDENTPOSITION
about: <p><b id="SCI_GETLINEINDENTPOSITION">SCI_GETLINEINDENTPOSITION(int line)</b><br />
     This returns the position at the end of indentation of a line.</p>
End Rem
	Method Getlineindentposition()
		SendEditor(SCI_GETLINEINDENTPOSITION)
	End Method
	

Rem
bbdoc: GETCOLUMN
about: <p><b id="SCI_GETCOLUMN">SCI_GETCOLUMN(int pos)</b><br />
     This message returns the column number of a position <code>pos</code> within the document
    taking the width of tabs into account. This returns the column number of the last tab on the
    line before <code>pos</code>, plus the number of characters between the last tab and
    <code>pos</code>. If there are no tab characters on the line, the return value is the number of
    characters up to the position on the line. In both cases, double byte characters count as a
    single character. This is probably only useful with monospaced fonts.</p>
End Rem
	Method Getcolumn()
		SendEditor(SCI_GETCOLUMN)
	End Method
	

Rem
bbdoc: SETHSCROLLBAR
about: <p><b id="SCI_SETHSCROLLBAR">SCI_SETHSCROLLBAR(bool visible)</b><br />
     <b id="SCI_GETHSCROLLBAR">SCI_GETHSCROLLBAR</b><br />
     The horizontal scroll bar is only displayed if it is needed for the assumed width.
     If you never wish to see it, call
    <code>SCI_SETHSCROLLBAR(0)</code>. Use <code>SCI_SETHSCROLLBAR(1)</code> to enable it again.
    <code>SCI_GETHSCROLLBAR</code> returns the current state. The default state is to display it
    when needed.</p>
End Rem
	Method Sethscrollbar()
		SendEditor(SCI_SETHSCROLLBAR)
	End Method
	

Rem
bbdoc: GETHSCROLLBAR
End Rem
	Method Gethscrollbar()
		SendEditor(SCI_GETHSCROLLBAR)
	End Method
	

Rem
bbdoc: SETINDENTATIONGUIDES
about: <p><b id="SCI_SETINDENTATIONGUIDES">SCI_SETINDENTATIONGUIDES(int indentView)</b><br />
     <b id="SCI_GETINDENTATIONGUIDES">SCI_GETINDENTATIONGUIDES</b><br />
     Indentation guides are dotted vertical lines that appear within indentation white space every
    indent size columns. They make it easy to see which constructs line up especially when they
    extend over multiple pages. Style <a class="message"
    href="#StyleDefinition"><code>STYLE_INDENTGUIDE</code></a> (37) is used to specify the
    foreground and background colour of the indentation guides.</p>
End Rem
	Method Setindentationguides()
		SendEditor(SCI_SETINDENTATIONGUIDES)
	End Method
	

Rem
bbdoc: GETINDENTATIONGUIDES
End Rem
	Method Getindentationguides()
		SendEditor(SCI_GETINDENTATIONGUIDES)
	End Method
	

Rem
bbdoc: SETHIGHLIGHTGUIDE
about: <p><b id="SCI_SETHIGHLIGHTGUIDE">SCI_SETHIGHLIGHTGUIDE(int column)</b><br />
     <b id="SCI_GETHIGHLIGHTGUIDE">SCI_GETHIGHLIGHTGUIDE</b><br />
     When brace highlighting occurs, the indentation guide corresponding to the braces may be
    highlighted with the brace highlighting style, <a class="message"
    href="#StyleDefinition"><code>STYLE_BRACELIGHT</code></a> (34). Set <code>column</code> to 0 to
    cancel this highlight.</p>
End Rem
	Method Sethighlightguide()
		SendEditor(SCI_SETHIGHLIGHTGUIDE)
	End Method
	

Rem
bbdoc: GETHIGHLIGHTGUIDE
End Rem
	Method Gethighlightguide()
		SendEditor(SCI_GETHIGHLIGHTGUIDE)
	End Method
	

Rem
bbdoc: GETLINEENDPOSITION
about: <p><b id="SCI_GETLINEENDPOSITION">SCI_GETLINEENDPOSITION(int line)</b><br />
     This returns the position at the end of the line, before any line end characters. If <code>line</code>
    is the last line in the document (which does not have any end of line characters), the result is the size of the
    document. If <code>line</code> is negative or <code>line</code> &gt;= <a class="message"
    href="#SCI_GETLINECOUNT"><code>SCI_GETLINECOUNT()</code></a>, the result is undefined.</p>
End Rem
	Method Getlineendposition()
		SendEditor(SCI_GETLINEENDPOSITION)
	End Method
	

Rem
bbdoc: GETCODEPAGE
End Rem
	Method Getcodepage()
		SendEditor(SCI_GETCODEPAGE)
	End Method
	

Rem
bbdoc: GETCARETFORE
End Rem
	Method Getcaretfore()
		SendEditor(SCI_GETCARETFORE)
	End Method
	

Rem
bbdoc: GETUSEPALETTE
End Rem
	Method Getusepalette()
		SendEditor(SCI_GETUSEPALETTE)
	End Method
	

Rem
bbdoc: SETCURRENTPOS
about: <p><b id="SCI_SETCURRENTPOS">SCI_SETCURRENTPOS(int pos)</b><br />
     This sets the current position and creates a selection between the anchor and the current
    position. The caret is not scrolled into view.</p>
See Also: <a class="message" href="#SCI_SCROLLCARET"><code>SCI_SCROLLCARET</code></a>
End Rem
	Method Setcurrentpos()
		SendEditor(SCI_SETCURRENTPOS)
	End Method
	

Rem
bbdoc: SETSELECTIONSTART
about: <p><b id="SCI_SETSELECTIONSTART">SCI_SETSELECTIONSTART(int pos)</b><br />
     <b id="SCI_SETSELECTIONEND">SCI_SETSELECTIONEND(int pos)</b><br />
     These set the selection based on the assumption that the anchor position is less than the
    current position. They do not make the caret visible. The table shows the positions of the
    anchor and the current position after using these messages.</p>
End Rem
	Method Setselectionstart()
		SendEditor(SCI_SETSELECTIONSTART)
	End Method
	

Rem
bbdoc: GETSELECTIONSTART
about: <p><b id="SCI_GETSELECTIONSTART">SCI_GETSELECTIONSTART</b><br />
     <b id="SCI_GETSELECTIONEND">SCI_GETSELECTIONEND</b><br />
     These return the start and end of the selection without regard to which end is the current
    position and which is the anchor. <code>SCI_GETSELECTIONSTART</code> returns the smaller of the
    current position or the anchor position. <code>SCI_GETSELECTIONEND</code> returns the larger of
    the two values.</p>
End Rem
	Method Getselectionstart()
		SendEditor(SCI_GETSELECTIONSTART)
	End Method
	

Rem
bbdoc: SETSELECTIONEND
End Rem
	Method Setselectionend()
		SendEditor(SCI_SETSELECTIONEND)
	End Method
	

Rem
bbdoc: GETSELECTIONEND
End Rem
	Method Getselectionend()
		SendEditor(SCI_GETSELECTIONEND)
	End Method
	

Rem
bbdoc: SETPRINTMAGNIFICATION
about: <p><b id="SCI_SETPRINTMAGNIFICATION">SCI_SETPRINTMAGNIFICATION(int magnification)</b><br />
     <b id="SCI_GETPRINTMAGNIFICATION">SCI_GETPRINTMAGNIFICATION</b><br />
     <code>SCI_GETPRINTMAGNIFICATION</code> lets you to print at a different size than the screen
    font. <code>magnification</code> is the number of points to add to the size of each screen
    font. A value of -3 or -4 gives reasonably small print. You can get this value with
    <code>SCI_GETPRINTMAGNIFICATION</code>.</p>
End Rem
	Method Setprintmagnification()
		SendEditor(SCI_SETPRINTMAGNIFICATION)
	End Method
	

Rem
bbdoc: GETPRINTMAGNIFICATION
End Rem
	Method Getprintmagnification()
		SendEditor(SCI_GETPRINTMAGNIFICATION)
	End Method
	

Rem
bbdoc: SETPRINTCOLOURMODE
about: <p><b id="SCI_SETPRINTCOLOURMODE">SCI_SETPRINTCOLOURMODE(int mode)</b><br />
     <b id="SCI_GETPRINTCOLOURMODE">SCI_GETPRINTCOLOURMODE</b><br />
     These two messages set and get the method used to render coloured text on a printer that is
    probably using white paper. It is especially important to consider the treatment of colour if
    you use a dark or black screen background. Printing white on black uses up toner and ink very
    many times faster than the other way around. You can set the mode to one of:</p>
End Rem
	Method Setprintcolourmode()
		SendEditor(SCI_SETPRINTCOLOURMODE)
	End Method
	

Rem
bbdoc: GETPRINTCOLOURMODE
End Rem
	Method Getprintcolourmode()
		SendEditor(SCI_GETPRINTCOLOURMODE)
	End Method
	

Rem
bbdoc: FINDTEXT
about: <p><b id="SCI_FINDTEXT">SCI_FINDTEXT(int searchFlags, <a class="jump"
    href="#TextToFind">TextToFind</a> *ttf)</b><br />
     This message searches for text in the document. It does not use or move the current selection.
    The <a class="jump" href="#searchFlags"><code>searchFlags</code></a> argument controls the
    search type, which includes regular expression searches.</p>
End Rem
	Method Findtext()
		SendEditor(SCI_FINDTEXT)
	End Method
	

Rem
bbdoc: FORMATRANGE
about: <p><b id="SCI_FORMATRANGE">SCI_FORMATRANGE(bool bDraw, RangeToFormat *pfr)</b><br />
     This call allows Windows users to render a range of text into a device context. If you use
    this for printing, you will probably want to arrange a page header and footer; Scintilla does
    not do this for you. See <code>SciTEWin::Print()</code> in <code>SciTEWinDlg.cxx</code> for an
    example. Each use of this message renders a range of text into a rectangular area and returns
    the position in the document of the next character to print.</p>
End Rem
	Method Formatrange()
		SendEditor(SCI_FORMATRANGE)
	End Method
	

Rem
bbdoc: GETFIRSTVISIBLELINE
about: <p><b id="SCI_GETFIRSTVISIBLELINE">SCI_GETFIRSTVISIBLELINE</b><br />
     This returns the line number of the first visible line in the Scintilla view. The first line
    in the document is numbered 0. The value is a visible line rather than a document line.</p>
End Rem
	Method Getfirstvisibleline()
		SendEditor(SCI_GETFIRSTVISIBLELINE)
	End Method
	

Rem
bbdoc: GETLINECOUNT
about: <p><b id="SCI_GETLINECOUNT">SCI_GETLINECOUNT</b><br />
     This returns the number of lines in the document. An empty document contains 1 line. A
    document holding only an end of line sequence has 2 lines.</p>
End Rem
	Method Getlinecount()
		SendEditor(SCI_GETLINECOUNT)
	End Method
	

Rem
bbdoc: SETMARGINLEFT
about: <p><b id="SCI_SETMARGINLEFT">SCI_SETMARGINLEFT(&lt;unused&gt;, int pixels)</b><br />
     <b id="SCI_GETMARGINLEFT">SCI_GETMARGINLEFT</b><br />
     <b id="SCI_SETMARGINRIGHT">SCI_SETMARGINRIGHT(&lt;unused&gt;, int pixels)</b><br />
     <b id="SCI_GETMARGINRIGHT">SCI_GETMARGINRIGHT</b><br />
     These messages set and get the width of the blank margin on both sides of the text in pixels.
    The default is to one pixel on each side.</p>
End Rem
	Method Setmarginleft()
		SendEditor(SCI_SETMARGINLEFT)
	End Method
	

Rem
bbdoc: GETMARGINLEFT
End Rem
	Method Getmarginleft()
		SendEditor(SCI_GETMARGINLEFT)
	End Method
	

Rem
bbdoc: SETMARGINRIGHT
End Rem
	Method Setmarginright()
		SendEditor(SCI_SETMARGINRIGHT)
	End Method
	

Rem
bbdoc: GETMARGINRIGHT
End Rem
	Method Getmarginright()
		SendEditor(SCI_GETMARGINRIGHT)
	End Method
	

Rem
bbdoc: GETMODIFY
about: <p><b id="SCI_GETMODIFY">SCI_GETMODIFY</b><br />
     This returns non-zero if the document is modified and 0 if it is unmodified. The modified
    status of a document is determined by the undo position relative to the save point. The save
    point is set by <a class="message" href="#SCI_SETSAVEPOINT"><code>SCI_SETSAVEPOINT</code></a>,
    usually when you have saved data to a file.</p>
End Rem
	Method Getmodify()
		SendEditor(SCI_GETMODIFY)
	End Method
	

Rem
bbdoc: SETSEL
about: <p><b id="SCI_SETSEL">SCI_SETSEL(int anchorPos, int currentPos)</b><br />
     This message sets both the anchor and the current position. If <code>currentPos</code> is
    negative, it means the end of the document. If <code>anchorPos</code> is negative, it means
    remove any selection (i.e. set the anchor to the same position as <code>currentPos</code>). The
    caret is scrolled into view after this operation.</p>
End Rem
	Method Setsel()
		SendEditor(SCI_SETSEL)
	End Method
	

Rem
bbdoc: GETSELTEXT
End Rem
	Method Getseltext()
		SendEditor(SCI_GETSELTEXT)
	End Method
	

Rem
bbdoc: HIDESELECTION
about: <p><b id="SCI_HIDESELECTION">SCI_HIDESELECTION(bool hide)</b><br />
     The normal state is to make the selection visible by drawing it as set by <a class="message"
    href="#SCI_SETSELFORE"><code>SCI_SETSELFORE</code></a> and <a class="message"
    href="#SCI_SETSELBACK"><code>SCI_SETSELBACK</code></a>. However, if you hide the selection, it
    is drawn as normal text.</p>
End Rem
	Method Hideselection()
		SendEditor(SCI_HIDESELECTION)
	End Method
	

Rem
bbdoc: POINTXFROMPOSITION
about: <p><b id="SCI_POINTXFROMPOSITION">SCI_POINTXFROMPOSITION(&lt;unused&gt;, int pos)</b><br />
     <b id="SCI_POINTYFROMPOSITION">SCI_POINTYFROMPOSITION(&lt;unused&gt;, int pos)</b><br />
     These messages return the x and y display pixel location of text at position <code>pos</code>
    in the document.</p>
End Rem
	Method Pointxfromposition()
		SendEditor(SCI_POINTXFROMPOSITION)
	End Method
	

Rem
bbdoc: POINTYFROMPOSITION
End Rem
	Method Pointyfromposition()
		SendEditor(SCI_POINTYFROMPOSITION)
	End Method
	

Rem
bbdoc: LINEFROMPOSITION
about: <p><b id="SCI_LINEFROMPOSITION">SCI_LINEFROMPOSITION(int pos)</b><br />
     This message returns the line that contains the position <code>pos</code> in the document. The
    return value is 0 if <code>pos</code> &lt;= 0. The return value is the last line if
    <code>pos</code> is beyond the end of the document.</p>
End Rem
	Method Linefromposition()
		SendEditor(SCI_LINEFROMPOSITION)
	End Method
	

Rem
bbdoc: POSITIONFROMLINE
about: <p><b id="SCI_POSITIONFROMLINE">SCI_POSITIONFROMLINE(int line)</b><br />
     This returns the document position that corresponds with the start of the line. If
    <code>line</code> is negative, the position of the line holding the start of the selection is
    returned. If <code>line</code> is greater than the lines in the document, the return value is
    -1. If <code>line</code> is equal to the number of lines in the document (i.e. 1 line past the
    last line), the return value is the end of the document.</p>
End Rem
	Method Positionfromline()
		SendEditor(SCI_POSITIONFROMLINE)
	End Method
	

Rem
bbdoc: LINESCROLL
about: <p><b id="SCI_LINESCROLL">SCI_LINESCROLL(int column, int line)</b><br />
     This will attempt to scroll the display by the number of columns and lines that you specify.
    Positive line values increase the line number at the top of the screen (i.e. they move the text
    upwards as far as the user is concerned), Negative line values do the reverse.</p>
End Rem
	Method Linescroll()
		SendEditor(SCI_LINESCROLL)
	End Method
	

Rem
bbdoc: SCROLLCARET
about: <p><b id="SCI_SCROLLCARET">SCI_SCROLLCARET</b><br />
     If the current position (this is the caret if there is no selection) is not visible, the view
    is scrolled to make it visible according to the current caret policy.</p>
End Rem
	Method Scrollcaret()
		SendEditor(SCI_SCROLLCARET)
	End Method
	
	
	
	'Method Null()
	'	SendEditor(SCI_NULL)
	'End Method
	

Rem
bbdoc: CANPASTE
End Rem
	Method Canpaste()
		SendEditor(SCI_CANPASTE)
	End Method
	

Rem
bbdoc: CANUNDO
End Rem
	Method Canundo()
		SendEditor(SCI_CANUNDO)
	End Method
	

Rem
bbdoc: EMPTYUNDOBUFFER
about: <p><b id="SCI_EMPTYUNDOBUFFER">SCI_EMPTYUNDOBUFFER</b><br />
     This command tells Scintilla to forget any saved undo or redo history. It also sets the save
    point to the start of the undo buffer, so the document will appear to be unmodified. This does
    not cause the <code><a class="message"
    href="#SCN_SAVEPOINTREACHED">SCN_SAVEPOINTREACHED</a></code> notification to be sent to the
    container.</p>
See Also: <a class="message" href="#SCI_SETSAVEPOINT"><code>SCI_SETSAVEPOINT</code></a>
End Rem
	Method Emptyundobuffer()
		SendEditor(SCI_EMPTYUNDOBUFFER)
	End Method
	

Rem
bbdoc: UNDO
about: <p><b id="SCI_UNDO">SCI_UNDO</b><br />
     <b id="SCI_CANUNDO">SCI_CANUNDO</b><br />
     <code>SCI_UNDO</code> undoes one action, or if the undo buffer has reached a
    <code>SCI_ENDUNDOACTION</code> point, all the actions back to the corresponding
    <code>SCI_BEGINUNDOACTION</code>.</p>
End Rem
	Method Undo()
		SendEditor(SCI_UNDO)
	End Method
	

Rem
bbdoc: CUT
about: <p><b id="SCI_CUT">SCI_CUT</b><br />
     <b id="SCI_COPY">SCI_COPY</b><br />
     <b id="SCI_PASTE">SCI_PASTE</b><br />
     <b id="SCI_CLEAR">SCI_CLEAR</b><br />
     <b id="SCI_CANPASTE">SCI_CANPASTE</b><br />
     <b id="SCI_COPYALLOWLINE">SCI_COPYALLOWLINE</b><br />
     These commands perform the standard tasks of cutting and copying data to the clipboard,
    pasting from the clipboard into the document, and clearing the document.
    <code>SCI_CANPASTE</code> returns non-zero if the document isn't read-only and if the selection
    doesn't contain protected text. If you need a "can copy" or "can cut", use
    <code>SCI_GETSELECTIONSTART()-SCI_GETSELECTIONEND()</code>, which will be non-zero if you can
    copy or cut to the clipboard.</p>
End Rem
	Method Cut()
		SendEditor(SCI_CUT)
	End Method
	

Rem
bbdoc: COPY
End Rem
	Method Copy()
		SendEditor(SCI_COPY)
	End Method
	

Rem
bbdoc: PASTE
End Rem
	Method Paste()
		SendEditor(SCI_PASTE)
	End Method
	

Rem
bbdoc: CLEAR
End Rem
	Method Clear()
		SendEditor(SCI_CLEAR)
	End Method
		

Rem
bbdoc: GETTEXTLENGTH
about: <p><b id="SCI_GETTEXTLENGTH">SCI_GETTEXTLENGTH</b><br />
     <b id="SCI_GETLENGTH">SCI_GETLENGTH</b><br />
     Both these messages return the length of the document in bytes.</p>
End Rem
	Method Gettextlength()
		SendEditor(SCI_GETTEXTLENGTH)
	End Method
	

Rem
bbdoc: GETDIRECTFUNCTION
about: <p><b id="SCI_GETDIRECTFUNCTION">SCI_GETDIRECTFUNCTION</b><br />
     This message returns the address of the function to call to handle Scintilla messages without
    the overhead of passing through the Windows messaging system. You need only call this once,
    regardless of the number of Scintilla windows you create.</p>
End Rem
	Method Getdirectfunction()
		SendEditor(SCI_GETDIRECTFUNCTION)
	End Method
	

Rem
bbdoc: GETDIRECTPOINTER
about: <p><b id="SCI_GETDIRECTPOINTER">SCI_GETDIRECTPOINTER</b><br />
     This returns a pointer to data that identifies which Scintilla window is in use. You must call
    this once for each Scintilla window you create. When you call the direct function, you must
    pass in the direct pointer associated with the target window.</p>
End Rem
	Method Getdirectpointer()
		SendEditor(SCI_GETDIRECTPOINTER)
	End Method
	

Rem
bbdoc: SETOVERTYPE
about: <p><b id="SCI_SETOVERTYPE">SCI_SETOVERTYPE(bool overType)</b><br />
     <b id="SCI_GETOVERTYPE">SCI_GETOVERTYPE</b><br />
     When overtype is enabled, each typed character replaces the character to the right of the text
    caret. When overtype is disabled, characters are inserted at the caret.
    <code>SCI_GETOVERTYPE</code> returns <code>TRUE</code> (1) if overtyping is active, otherwise
    <code>FALSE</code> (0) will be returned. Use <code>SCI_SETOVERTYPE</code> to set the overtype
    mode.</p>
End Rem
	Method Setovertype()
		SendEditor(SCI_SETOVERTYPE)
	End Method
	

Rem
bbdoc: GETOVERTYPE
End Rem
	Method Getovertype()
		SendEditor(SCI_GETOVERTYPE)
	End Method
	

Rem
bbdoc: SETCARETWIDTH
about: <p><b id="SCI_SETCARETWIDTH">SCI_SETCARETWIDTH(int pixels)</b><br />
     <b id="SCI_GETCARETWIDTH">SCI_GETCARETWIDTH</b><br />
     The width of the line caret can be set with <code>SCI_SETCARETWIDTH</code> to a value of
    0, 1, 2 or 3 pixels. The default width is 1 pixel. You can read back the current width with
    <code>SCI_GETCARETWIDTH</code>. A width of 0 makes the caret invisible (added at version
    1.50), similar to setting the caret style to CARETSTYLE_INVISIBLE (though not interchangable).
    This setting only affects the width of the cursor when the cursor style is set to line caret
    mode, it does not affect the width for a block caret.</p>
End Rem
	Method Setcaretwidth()
		SendEditor(SCI_SETCARETWIDTH)
	End Method
	

Rem
bbdoc: GETCARETWIDTH
End Rem
	Method Getcaretwidth()
		SendEditor(SCI_GETCARETWIDTH)
	End Method
	

Rem
bbdoc: SETTARGETSTART
about: <p><b id="SCI_SETTARGETSTART">SCI_SETTARGETSTART(int pos)</b><br />
     <b id="SCI_GETTARGETSTART">SCI_GETTARGETSTART</b><br />
     <b id="SCI_SETTARGETEND">SCI_SETTARGETEND(int pos)</b><br />
     <b id="SCI_GETTARGETEND">SCI_GETTARGETEND</b><br />
     These functions set and return the start and end of the target. When searching in non-regular
    expression mode, you can set start greater than end to find the last matching text in the
    target rather than the first matching text. The target is also set by a successful
    <code>SCI_SEARCHINTARGET</code>.</p>
End Rem
	Method Settargetstart()
		SendEditor(SCI_SETTARGETSTART)
	End Method
	

Rem
bbdoc: GETTARGETSTART
End Rem
	Method Gettargetstart()
		SendEditor(SCI_GETTARGETSTART)
	End Method
	

Rem
bbdoc: SETTARGETEND
End Rem
	Method Settargetend()
		SendEditor(SCI_SETTARGETEND)
	End Method
	

Rem
bbdoc: GETTARGETEND
End Rem
	Method Gettargetend()
		SendEditor(SCI_GETTARGETEND)
	End Method
	

Rem
bbdoc: REPLACETARGET
about: <p><b id="SCI_REPLACETARGET">SCI_REPLACETARGET(int length, const char *text)</b><br />
     If <code>length</code> is -1, <code>text</code> is a zero terminated string, otherwise
    <code>length</code> sets the number of character to replace the target with.
           After replacement, the target range refers to the replacement text.
           The return value
    is the length of the replacement string.<br />
    Note that the recommended way to delete text in the document is to set the target to the text to be removed,
    and to perform a replace target with an empty string.</p>
End Rem
	Method Replacetarget()
		SendEditor(SCI_REPLACETARGET)
	End Method
	

Rem
bbdoc: REPLACETARGETRE
about: <p><b id="SCI_REPLACETARGETRE">SCI_REPLACETARGETRE(int length, const char *text)</b><br />
     This replaces the target using regular expressions. If <code>length</code> is -1,
    <code>text</code> is a zero terminated string, otherwise <code>length</code> is the number of
    characters to use. The replacement string is formed from the text string with any sequences of
    <code>\1</code> through <code>\9</code> replaced by tagged matches from the most recent regular
    expression search.
           After replacement, the target range refers to the replacement text.
           The return value is the length of the replacement string.</p>
See Also: <a class="message" href="#SCI_FINDTEXT"><code>SCI_FINDTEXT</code></a>
End Rem
	Method Replacetargetre()
		SendEditor(SCI_REPLACETARGETRE)
	End Method
	

Rem
bbdoc: SEARCHINTARGET
about: <p><b id="SCI_SEARCHINTARGET">SCI_SEARCHINTARGET(int length, const char *text)</b><br />
     This searches for the first occurrence of a text string in the target defined by
    <code>SCI_SETTARGETSTART</code> and <code>SCI_SETTARGETEND</code>. The text string is not zero
    terminated; the size is set by <code>length</code>. The search is modified by the search flags
    set by <code>SCI_SETSEARCHFLAGS</code>. If the search succeeds, the target is set to the found
    text and the return value is the position of the start of the matching text. If the search
    fails, the result is -1.</p>
End Rem
	Method Searchintarget()
		SendEditor(SCI_SEARCHINTARGET)
	End Method
	

Rem
bbdoc: SETSEARCHFLAGS
about: <p><b id="SCI_SETSEARCHFLAGS">SCI_SETSEARCHFLAGS(int searchFlags)</b><br />
     <b id="SCI_GETSEARCHFLAGS">SCI_GETSEARCHFLAGS</b><br />
     These get and set the <a class="jump" href="#searchFlags"><code>searchFlags</code></a> used by
    <code>SCI_SEARCHINTARGET</code>. There are several option flags including a simple regular
    expression search.</p>
End Rem
	Method Setsearchflags()
		SendEditor(SCI_SETSEARCHFLAGS)
	End Method
	

Rem
bbdoc: GETSEARCHFLAGS
End Rem
	Method Getsearchflags()
		SendEditor(SCI_GETSEARCHFLAGS)
	End Method
	

Rem
bbdoc: CALLTIPSHOW
about: <p><b id="SCI_CALLTIPSHOW">SCI_CALLTIPSHOW(int posStart, const char *definition)</b><br />
     This message starts the process by displaying the call tip window. If a call tip is already
    active, this has no effect.<br />
     <code>posStart</code> is the position in the document at which to align the call tip. The call
    tip text is aligned to start 1 line below this character unless you have included up and/or
    down arrows in the call tip text in which case the tip is aligned to the right-hand edge of
    the rightmost arrow. The assumption is that you will start the text with something like
    "\001 1 of 3 \002".<br />
     <code>definition</code> is the call tip text. This can contain multiple lines separated by
    '\n' (Line Feed, ASCII code 10) characters. Do not include '\r' (Carriage Return, ASCII
     code 13), as this will most likely print as an empty box. '\t' (Tab, ASCII code 9) is
     supported if you set a tabsize with
    <code><a class="message" href="#SCI_CALLTIPUSESTYLE">SCI_CALLTIPUSESTYLE</a></code>.<br /></p>
End Rem
	Method Calltipshow()
		SendEditor(SCI_CALLTIPSHOW)
	End Method
	

Rem
bbdoc: CALLTIPCANCEL
about: <p><b id="SCI_CALLTIPCANCEL">SCI_CALLTIPCANCEL</b><br />
     This message cancels any displayed call tip. Scintilla will also cancel call tips for you if
    you use any keyboard commands that are not compatible with editing the argument list of a
    function.</p>
End Rem
	Method Calltipcancel()
		SendEditor(SCI_CALLTIPCANCEL)
	End Method
	

Rem
bbdoc: CALLTIPACTIVE
about: <p><b id="SCI_CALLTIPACTIVE">SCI_CALLTIPACTIVE</b><br />
     This returns 1 if a call tip is active and 0 if it is not active.</p>
End Rem
	Method Calltipactive()
		SendEditor(SCI_CALLTIPACTIVE)
	End Method
	

Rem
bbdoc: CALLTIPPOSSTART
about: <p><b id="SCI_CALLTIPPOSSTART">SCI_CALLTIPPOSSTART</b><br />
     This message returns the value of the current position when <code>SCI_CALLTIPSHOW</code>
    started to display the tip.</p>
End Rem
	Method Calltipposstart()
		SendEditor(SCI_CALLTIPPOSSTART)
	End Method
	

Rem
bbdoc: CALLTIPSETHLT
about: <p><b id="SCI_CALLTIPSETHLT">SCI_CALLTIPSETHLT(int hlStart, int hlEnd)</b><br />
     This sets the region of the call tips text to display in a highlighted style.
    <code>hlStart</code> is the zero-based index into the string of the first character to
    highlight and <code>hlEnd</code> is the index of the first character after the highlight.
    <code>hlEnd</code> must be greater than <code>hlStart</code>; <code>hlEnd-hlStart</code> is the
    number of characters to highlight. Highlights can extend over line ends if this is
    required.</p>
End Rem
	Method Calltipsethlt()
		SendEditor(SCI_CALLTIPSETHLT)
	End Method
	

Rem
bbdoc: CALLTIPSETBACK
about: <p><b id="SCI_CALLTIPSETBACK">SCI_CALLTIPSETBACK(int colour)</b><br />
     The background colour of call tips can be set with this message; the default colour is white.
    It is not a good idea to set a dark colour as the background as the default colour for normal
    calltip text is mid gray and the defaultcolour for highlighted text is dark blue. This also
    sets the background colour of <code>STYLE_CALLTIP</code>.</p>
End Rem
	Method Calltipsetback()
		SendEditor(SCI_CALLTIPSETBACK)
	End Method
	

Rem
bbdoc: CALLTIPSETFORE
about: <p><b id="SCI_CALLTIPSETFORE">SCI_CALLTIPSETFORE(int colour)</b><br />
     The colour of call tip text can be set with this message; the default colour is mid gray.
    This also sets the foreground colour of <code>STYLE_CALLTIP</code>.</p>
End Rem
	Method Calltipsetfore()
		SendEditor(SCI_CALLTIPSETFORE)
	End Method
	

Rem
bbdoc: CALLTIPSETFOREHLT
about: <p><b id="SCI_CALLTIPSETFOREHLT">SCI_CALLTIPSETFOREHLT(int colour)</b><br />
     The colour of highlighted call tip text can be set with this message; the default colour
    is dark blue.</p>
End Rem
	Method Calltipsetforehlt()
		SendEditor(SCI_CALLTIPSETFOREHLT)
	End Method
	

Rem
bbdoc: CALLTIPUSESTYLE
about: <p><b id="SCI_CALLTIPUSESTYLE">SCI_CALLTIPUSESTYLE(int tabsize)</b><br />
     This message changes the style used for call tips from <code>STYLE_DEFAULT</code> to
    <code>STYLE_CALLTIP</code> and sets a tab size in screen pixels. If <code>tabsize</code> is
    less than 1, Tab characters are not treated specially. Once this call has been used, the
    call tip foreground and background colours are also taken from the style.</p>
End Rem
	Method Calltipusestyle()
		SendEditor(SCI_CALLTIPUSESTYLE)
	End Method
	

Rem
bbdoc: VISIBLEFROMDOCLINE
about: <p><b id="SCI_VISIBLEFROMDOCLINE">SCI_VISIBLEFROMDOCLINE(int docLine)</b><br />
     When some lines are folded, then a particular line in the document may be displayed at a
    different position to its document position. If no lines are folded, this message returns
    <code>docLine</code>. Otherwise, this returns the display line (counting the very first visible
    line as 0). The display line of an invisible line is the same as the previous visible line. The
    display line number of the first line in the document is 0. If there is folding and
    <code>docLine</code> is outside the range of lines in the document, the return value is -1.
    Lines can occupy more than one display line if they wrap.</p>
End Rem
	Method Visiblefromdocline()
		SendEditor(SCI_VISIBLEFROMDOCLINE)
	End Method
	

Rem
bbdoc: DOCLINEFROMVISIBLE
about: <p><b id="SCI_DOCLINEFROMVISIBLE">SCI_DOCLINEFROMVISIBLE(int displayLine)</b><br />
     When some lines are hidden, then a particular line in the document may be displayed at a
    different position to its document position. This message returns the document line number that
    corresponds to a display line (counting the display line of the first line in the document as
    0). If <code>displayLine</code> is less than or equal to 0, the result is 0. If
    <code>displayLine</code> is greater than or equal to the number of displayed lines, the result
    is the number of lines in the document.</p>
End Rem
	Method Doclinefromvisible()
		SendEditor(SCI_DOCLINEFROMVISIBLE)
	End Method
	

Rem
bbdoc: WRAPCOUNT
about: <p><b id="SCI_WRAPCOUNT">SCI_WRAPCOUNT(int docLine)</b><br />
    Document lines can occupy more than one display line if they wrap and this
    returns the number of display lines needed to wrap a document line.</p>
End Rem
	Method Wrapcount()
		SendEditor(SCI_WRAPCOUNT)
	End Method
	

Rem
bbdoc: SETFOLDLEVEL
about: <p><b id="SCI_SETFOLDLEVEL">SCI_SETFOLDLEVEL(int line, int level)</b><br />
     <b id="SCI_GETFOLDLEVEL">SCI_GETFOLDLEVEL(int line)</b><br />
     These two messages set and get a 32-bit value that contains the fold level of a line and some
    flags associated with folding. The fold level is a number in the range 0 to
    <code>SC_FOLDLEVELNUMBERMASK</code> (4095). However, the initial fold level is set to
    <code>SC_FOLDLEVELBASE</code> (1024) to allow unsigned arithmetic on folding levels. There are
    two addition flag bits. <code>SC_FOLDLEVELWHITEFLAG</code> indicates that the line is blank and
    allows it to be treated slightly different then its level may indicate. For example, blank
    lines should generally not be fold points and will be considered part of the preceding section even though
    they may have a lesser fold level.
    <code>SC_FOLDLEVELHEADERFLAG</code> indicates that
    the line is a header (fold point).</p>
End Rem
	Method Setfoldlevel()
		SendEditor(SCI_SETFOLDLEVEL)
	End Method
	

Rem
bbdoc: GETFOLDLEVEL
End Rem
	Method Getfoldlevel()
		SendEditor(SCI_GETFOLDLEVEL)
	End Method
	

Rem
bbdoc: GETLASTCHILD
about: <p><b id="SCI_GETLASTCHILD">SCI_GETLASTCHILD(int startLine, int level)</b><br />
     This message searches for the next line after <code>startLine</code>, that has a folding level
    that is less than or equal to <code>level</code> and then returns the previous line number. If
    you set <code>level</code> to -1, <code>level</code> is set to the folding level of line
    <code>startLine</code>. If <code>from</code> is a fold point, <code>SCI_GETLASTCHILD(from,
    -1)</code> returns the last line that would be in made visible or hidden by toggling the fold
    state.</p>
End Rem
	Method Getlastchild()
		SendEditor(SCI_GETLASTCHILD)
	End Method
	

Rem
bbdoc: GETFOLDPARENT
about: <p><b id="SCI_GETFOLDPARENT">SCI_GETFOLDPARENT(int startLine)</b><br />
     This message returns the line number of the first line before <code>startLine</code> that is
    marked as a fold point with <code>SC_FOLDLEVELHEADERFLAG</code> and has a fold level less than
    the <code>startLine</code>. If no line is found, or if the header flags and fold levels are
    inconsistent, the return value is -1.</p>
End Rem
	Method Getfoldparent()
		SendEditor(SCI_GETFOLDPARENT)
	End Method
	

Rem
bbdoc: SHOWLINES
about: <p><b id="SCI_SHOWLINES">SCI_SHOWLINES(int lineStart, int lineEnd)</b><br />
     <b id="SCI_HIDELINES">SCI_HIDELINES(int lineStart, int lineEnd)</b><br />
     <b id="SCI_GETLINEVISIBLE">SCI_GETLINEVISIBLE(int line)</b><br />
     The first two messages mark a range of lines as visible or invisible and then redraw the
    display. The third message reports on the visible state of a line and returns 1 if it is
    visible and 0 if it is not visible. These messages have no effect on fold levels or fold
    flags. The first line can not be hidden.</p>
End Rem
	Method Showlines()
		SendEditor(SCI_SHOWLINES)
	End Method
	

Rem
bbdoc: HIDELINES
End Rem
	Method Hidelines()
		SendEditor(SCI_HIDELINES)
	End Method
	

Rem
bbdoc: GETLINEVISIBLE
End Rem
	Method Getlinevisible()
		SendEditor(SCI_GETLINEVISIBLE)
	End Method
	

Rem
bbdoc: SETFOLDEXPANDED
about: <p><b id="SCI_SETFOLDEXPANDED">SCI_SETFOLDEXPANDED(int line, bool expanded)</b><br />
     <b id="SCI_GETFOLDEXPANDED">SCI_GETFOLDEXPANDED(int line)</b><br />
     These messages set and get the expanded state of a single line. The set message has no effect
    on the visible state of the line or any lines that depend on it. It does change the markers in
    the folding margin. If you ask for the expansion state of a line that is outside the document,
    the result is <code>false</code> (0).</p>
End Rem
	Method Setfoldexpanded()
		SendEditor(SCI_SETFOLDEXPANDED)
	End Method
	

Rem
bbdoc: GETFOLDEXPANDED
End Rem
	Method Getfoldexpanded()
		SendEditor(SCI_GETFOLDEXPANDED)
	End Method
	

Rem
bbdoc: TOGGLEFOLD
about: <p><b id="SCI_TOGGLEFOLD">SCI_TOGGLEFOLD(int line)</b><br />
     Each fold point may be either expanded, displaying all its child lines, or contracted, hiding
    all the child lines. This message toggles the folding state of the given line as long as it has
    the <code>SC_FOLDLEVELHEADERFLAG</code> set. This message takes care of folding or expanding
    all the lines that depend on the line. The display updates after this message.</p>
End Rem
	Method Togglefold()
		SendEditor(SCI_TOGGLEFOLD)
	End Method
	

Rem
bbdoc: ENSUREVISIBLE
about: <p><b id="SCI_ENSUREVISIBLE">SCI_ENSUREVISIBLE(int line)</b><br />
     <b id="SCI_ENSUREVISIBLEENFORCEPOLICY">SCI_ENSUREVISIBLEENFORCEPOLICY(int line)</b><br />
     A line may be hidden because more than one of its parent lines is contracted. Both these
    message travels up the fold hierarchy, expanding any contracted folds until they reach the top
    level. The line will then be visible. If you use <code>SCI_ENSUREVISIBLEENFORCEPOLICY</code>,
    the vertical caret policy set by <a class="message"
    href="#SCI_SETVISIBLEPOLICY"><code>SCI_SETVISIBLEPOLICY</code></a> is then applied.</p>
End Rem
	Method Ensurevisible()
		SendEditor(SCI_ENSUREVISIBLE)
	End Method
	

Rem
bbdoc: SETFOLDFLAGS
about: <p><b id="SCI_SETFOLDFLAGS">SCI_SETFOLDFLAGS(int flags)</b><br />
     In addition to showing markers in the folding margin, you can indicate folds to the user by
    drawing lines in the text area. The lines are drawn in the foreground colour set for <a
    class="message" href="#StyleDefinition"><code>STYLE_DEFAULT</code></a>. Bits set in
    <code>flags</code> determine where folding lines are drawn:<br />
    </p>
End Rem
	Method Setfoldflags()
		SendEditor(SCI_SETFOLDFLAGS)
	End Method
	

Rem
bbdoc: ENSUREVISIBLEENFORCEPOLICY
End Rem
	Method Ensurevisibleenforcepolicy()
		SendEditor(SCI_ENSUREVISIBLEENFORCEPOLICY)
	End Method
	

Rem
bbdoc: SETTABINDENTS
about: <p><b id="SCI_SETTABINDENTS">SCI_SETTABINDENTS(bool tabIndents)</b><br />
     <b id="SCI_GETTABINDENTS">SCI_GETTABINDENTS</b><br />
     <b id="SCI_SETBACKSPACEUNINDENTS">SCI_SETBACKSPACEUNINDENTS(bool bsUnIndents)</b><br />
     <b id="SCI_GETBACKSPACEUNINDENTS">SCI_GETBACKSPACEUNINDENTS</b><br />
    </p>
End Rem
	Method Settabindents()
		SendEditor(SCI_SETTABINDENTS)
	End Method
	

Rem
bbdoc: GETTABINDENTS
End Rem
	Method Gettabindents()
		SendEditor(SCI_GETTABINDENTS)
	End Method
	

Rem
bbdoc: SETBACKSPACEUNINDENTS
End Rem
	Method Setbackspaceunindents()
		SendEditor(SCI_SETBACKSPACEUNINDENTS)
	End Method
	

Rem
bbdoc: GETBACKSPACEUNINDENTS
End Rem
	Method Getbackspaceunindents()
		SendEditor(SCI_GETBACKSPACEUNINDENTS)
	End Method
	

Rem
bbdoc: SETMOUSEDWELLTIME
about: <p><b id="SCI_SETMOUSEDWELLTIME">SCI_SETMOUSEDWELLTIME</b><br />
     <b id="SCI_GETMOUSEDWELLTIME">SCI_GETMOUSEDWELLTIME</b><br />
     These two messages set and get the time the mouse must sit still, in milliseconds, to generate
    a <code><a class="message" href="#SCN_DWELLSTART">SCN_DWELLSTART</a></code> notification. If
    set to <code>SC_TIME_FOREVER</code>, the default, no dwell events are generated.</p>
End Rem
	Method Setmousedwelltime()
		SendEditor(SCI_SETMOUSEDWELLTIME)
	End Method
	

Rem
bbdoc: GETMOUSEDWELLTIME
End Rem
	Method Getmousedwelltime()
		SendEditor(SCI_GETMOUSEDWELLTIME)
	End Method
	

Rem
bbdoc: WORDSTARTPOSITION
End Rem
	Method Wordstartposition()
		SendEditor(SCI_WORDSTARTPOSITION)
	End Method
	

Rem
bbdoc: WORDENDPOSITION
about: <p><b id="SCI_WORDENDPOSITION">SCI_WORDENDPOSITION(int position, bool
    onlyWordCharacters)</b><br />
     <b id="SCI_WORDSTARTPOSITION">SCI_WORDSTARTPOSITION(int position, bool
    onlyWordCharacters)</b><br />
     These messages return the start and end of words using the same definition of words as used
    internally within Scintilla. You can set your own list of characters that count as words with
    <a class="message" href="#SCI_SETWORDCHARS"><code>SCI_SETWORDCHARS</code></a>. The position
    sets the start or the search, which is forwards when searching for the end and backwards when
    searching for the start.</p>
End Rem
	Method Wordendposition()
		SendEditor(SCI_WORDENDPOSITION)
	End Method
	

Rem
bbdoc: SETWRAPMODE
about: <p><b id="SCI_SETWRAPMODE">SCI_SETWRAPMODE(int wrapMode)</b><br />
     <b id="SCI_GETWRAPMODE">SCI_GETWRAPMODE</b><br />
     Set wrapMode to <code>SC_WRAP_WORD</code> (1) to enable wrapping
     on word boundaries, <code>SC_WRAP_CHAR</code> (2) to enable wrapping
     between any characters, and to <code>SC_WRAP_NONE</code> (0) to disable line
     wrapping. <code>SC_WRAP_CHAR</code> is preferred to
     <code>SC_WRAP_WORD</code> for Asian languages where there is no white space
     between words.</p>
End Rem
	Method Setwrapmode()
		SendEditor(SCI_SETWRAPMODE)
	End Method
	

Rem
bbdoc: GETWRAPMODE
End Rem
	Method Getwrapmode()
		SendEditor(SCI_GETWRAPMODE)
	End Method
	

Rem
bbdoc: SETWRAPVISUALFLAGS
about: <p><b id="SCI_SETWRAPVISUALFLAGS">SCI_SETWRAPVISUALFLAGS(int wrapVisualFlags)</b><br />
     <b id="SCI_GETWRAPVISUALFLAGS">SCI_GETWRAPVISUALFLAGS</b><br />
                You can enable the drawing of visual flags to indicate a line is wrapped. Bits set in
                wrapVisualFlags determine which visual flags are drawn.

    <table cellpadding="1" cellspacing="2" border="0" summary="Wrap visual flags">
      <tbody>
        <tr>
          <th align="left">Symbol</th>
          <th>Value</th>
          <th align="left">Effect</th>
        </tr>
      </tbody>

      <tbody valign="top">
        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAG_NONE</code></td>
          <td align="center">0</td>
          <td>No visual flags</td>
        </tr>

        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAG_END</code></td>
          <td align="center">1</td>
          <td>Visual flag at end of subline of a wrapped line.</td>
        </tr>

        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAG_START</code></td>
          <td align="center">2</td>
          <td>Visual flag at begin of subline of a wrapped line.<br />
                                             Subline is indented by at least 1 to make room for the flag.<br />
                                </td>
        </tr>
      </tbody>
    </table>

    <p><b id="SCI_SETWRAPVISUALFLAGSLOCATION">SCI_SETWRAPVISUALFLAGSLOCATION(int wrapVisualFlagsLocation)</b><br />
     <b id="SCI_GETWRAPVISUALFLAGSLOCATION">SCI_GETWRAPVISUALFLAGSLOCATION</b><br />
                You can set whether the visual flags to indicate a line is wrapped are drawn near the border or near the text.
                Bits set in wrapVisualFlagsLocation set the location to near the text for the corresponding visual flag.

    <table cellpadding="1" cellspacing="2" border="0" summary="Wrap visual flags locations">
      <tbody>
        <tr>
          <th align="left">Symbol</th>
          <th>Value</th>
          <th align="left">Effect</th>
        </tr>
      </tbody>

      <tbody valign="top">
        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAGLOC_DEFAULT</code></td>
          <td align="center">0</td>
          <td>Visual flags drawn near border</td>
        </tr>

        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAGLOC_END_BY_TEXT</code></td>
          <td align="center">1</td>
          <td>Visual flag at end of subline drawn near text</td>
        </tr>

        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAGLOC_START_BY_TEXT</code></td>
          <td align="center">2</td>
          <td>Visual flag at beginning of subline drawn near text</td>
        </tr>
      </tbody>
    </table>
    </p>
End Rem
	Method Setwrapvisualflags()
		SendEditor(SCI_SETWRAPVISUALFLAGS)
	End Method
	

Rem
bbdoc: GETWRAPVISUALFLAGS
End Rem
	Method Getwrapvisualflags()
		SendEditor(SCI_GETWRAPVISUALFLAGS)
	End Method
	

Rem
bbdoc: SETWRAPVISUALFLAGSLOCATION
about: <p><b id="SCI_SETWRAPVISUALFLAGSLOCATION">SCI_SETWRAPVISUALFLAGSLOCATION(int wrapVisualFlagsLocation)</b><br />
     <b id="SCI_GETWRAPVISUALFLAGSLOCATION">SCI_GETWRAPVISUALFLAGSLOCATION</b><br />
                You can set whether the visual flags to indicate a line is wrapped are drawn near the border or near the text.
                Bits set in wrapVisualFlagsLocation set the location to near the text for the corresponding visual flag.

    <table cellpadding="1" cellspacing="2" border="0" summary="Wrap visual flags locations">
      <tbody>
        <tr>
          <th align="left">Symbol</th>
          <th>Value</th>
          <th align="left">Effect</th>
        </tr>
      </tbody>

      <tbody valign="top">
        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAGLOC_DEFAULT</code></td>
          <td align="center">0</td>
          <td>Visual flags drawn near border</td>
        </tr>

        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAGLOC_END_BY_TEXT</code></td>
          <td align="center">1</td>
          <td>Visual flag at end of subline drawn near text</td>
        </tr>

        <tr>
          <td align="left"><code>SC_WRAPVISUALFLAGLOC_START_BY_TEXT</code></td>
          <td align="center">2</td>
          <td>Visual flag at beginning of subline drawn near text</td>
        </tr>
      </tbody>
    </table>
    </p>
End Rem
	Method Setwrapvisualflagslocation()
		SendEditor(SCI_SETWRAPVISUALFLAGSLOCATION)
	End Method
	

Rem
bbdoc: GETWRAPVISUALFLAGSLOCATION
End Rem
	Method Getwrapvisualflagslocation()
		SendEditor(SCI_GETWRAPVISUALFLAGSLOCATION)
	End Method
	

Rem
bbdoc: SETWRAPSTARTINDENT
about: <p><b id="SCI_SETWRAPSTARTINDENT">SCI_SETWRAPSTARTINDENT(int indent)</b><br />
     <b id="SCI_GETWRAPSTARTINDENT">SCI_GETWRAPSTARTINDENT</b><br />
     <code>SCI_SETWRAPSTARTINDENT</code> sets the size of indentation of sublines for
                 wrapped lines in terms of the average character width in
                <a class="message" href="#StyleDefinition"><code>STYLE_DEFAULT</code></a>.
                There are no limits on indent sizes, but values        less than 0 or large values may have
                undesirable effects.<br />
                The indention of sublines is independent of visual flags, but if
                <code>SC_WRAPVISUALFLAG_START</code> is set an indent of at least 1 is used.
     </p>
End Rem
	Method Setwrapstartindent()
		SendEditor(SCI_SETWRAPSTARTINDENT)
	End Method
	

Rem
bbdoc: GETWRAPSTARTINDENT
End Rem
	Method Getwrapstartindent()
		SendEditor(SCI_GETWRAPSTARTINDENT)
	End Method
	

Rem
bbdoc: SETWRAPINDENTMODE
about: <p><b id="SCI_SETWRAPINDENTMODE">SCI_SETWRAPINDENTMODE(int indentMode)</b><br />
     <b id="SCI_GETWRAPINDENTMODE">SCI_GETWRAPINDENTMODE</b><br />
                Wrapped sublines can be indented to the position of their first subline or one more indent level.
	  The default is <code>SC_WRAPINDENT_FIXED</code>.
                The modes are:

    <table cellpadding="1" cellspacing="2" border="0" summary="Wrap visual flags locations">
      <tbody>
        <tr>
          <th align="left">Symbol</th>
          <th>Value</th>
          <th align="left">Effect</th>
        </tr>
      </tbody>

      <tbody valign="top">
        <tr>
          <td align="left"><code>SC_WRAPINDENT_FIXED</code></td>
          <td align="center">0</td>
          <td>Wrapped sublines aligned to left of window plus amount set by  
	  <a class="message" href="#SCI_SETWRAPSTARTINDENT">SCI_SETWRAPSTARTINDENT</a></td>
        </tr>

        <tr>
          <td align="left"><code>SC_WRAPINDENT_SAME</code></td>
          <td align="center">1</td>
          <td>Wrapped sublines are aligned to first subline indent</td>
        </tr>

        <tr>
          <td align="left"><code>SC_WRAPINDENT_INDENT</code></td>
          <td align="center">2</td>
          <td>Wrapped sublines are aligned to first subline indent plus one more level of indentation</td>
        </tr>
      </tbody>
    </table>
    </p>
End Rem
	Method Setwrapindentmode()
		SendEditor(SCI_SETWRAPINDENTMODE)
	End Method
	

Rem
bbdoc: GETWRAPINDENTMODE
End Rem
	Method Getwrapindentmode()
		SendEditor(SCI_GETWRAPINDENTMODE)
	End Method
	

Rem
bbdoc: SETLAYOUTCACHE
about: <p><b id="SCI_SETLAYOUTCACHE">SCI_SETLAYOUTCACHE(int cacheMode)</b><br />
     <b id="SCI_GETLAYOUTCACHE">SCI_GETLAYOUTCACHE</b><br />
     You can set <code>cacheMode</code> to one of the symbols in the table:</p>
End Rem
	Method Setlayoutcache()
		SendEditor(SCI_SETLAYOUTCACHE)
	End Method
	

Rem
bbdoc: GETLAYOUTCACHE
End Rem
	Method Getlayoutcache()
		SendEditor(SCI_GETLAYOUTCACHE)
	End Method
	

Rem
bbdoc: SETSCROLLWIDTH
about: <p><b id="SCI_SETSCROLLWIDTH">SCI_SETSCROLLWIDTH(int pixelWidth)</b><br />
     <b id="SCI_GETSCROLLWIDTH">SCI_GETSCROLLWIDTH</b><br />
     For performance, Scintilla does not measure the display width of the document to determine
     the properties of the horizontal scroll bar. Instead, an assumed width is used.
     These messages set and get the document width in pixels assumed by Scintilla.
     The default value is 2000.
     To ensure the width of the currently visible lines can be scrolled use
     <a class="message" href="#SCI_SETSCROLLWIDTHTRACKING"><code>SCI_SETSCROLLWIDTHTRACKING</code></a></p>
End Rem
	Method Setscrollwidth()
		SendEditor(SCI_SETSCROLLWIDTH)
	End Method
	

Rem
bbdoc: GETSCROLLWIDTH
End Rem
	Method Getscrollwidth()
		SendEditor(SCI_GETSCROLLWIDTH)
	End Method
	

Rem
bbdoc: SETSCROLLWIDTHTRACKING
about: <p><b id="SCI_SETSCROLLWIDTHTRACKING">SCI_SETSCROLLWIDTHTRACKING(bool tracking)</b><br />
     <b id="SCI_GETSCROLLWIDTHTRACKING">SCI_GETSCROLLWIDTHTRACKING</b><br />
     If scroll width tracking is enabled then the scroll width is adjusted to ensure that all of the lines currently
     displayed can be completely scrolled. This mode never adjusts the scroll width to be narrower.</p>
End Rem
	Method Setscrollwidthtracking()
		SendEditor(SCI_SETSCROLLWIDTHTRACKING)
	End Method
	

Rem
bbdoc: GETSCROLLWIDTHTRACKING
End Rem
	Method Getscrollwidthtracking()
		SendEditor(SCI_GETSCROLLWIDTHTRACKING)
	End Method
	

Rem
bbdoc: TEXTWIDTH
about: <p><b id="SCI_TEXTWIDTH">SCI_TEXTWIDTH(int styleNumber, const char *text)</b><br />
     This returns the pixel width of a string drawn in the given <code>styleNumber</code> which can
    be used, for example, to decide how wide to make the line number margin in order to display a
    given number of numerals.</p>
End Rem
	Method TextWidth()
		SendEditor(SCI_TEXTWIDTH)
	End Method
	

Rem
bbdoc: SETENDATLASTLINE
about: <p><b id="SCI_SETENDATLASTLINE">SCI_SETENDATLASTLINE(bool endAtLastLine)</b><br />
     <b id="SCI_GETENDATLASTLINE">SCI_GETENDATLASTLINE</b><br />
     <code>SCI_SETENDATLASTLINE</code> sets the scroll range so that maximum scroll position has
    the last line at the bottom of the view (default). Setting this to <code>false</code> allows
    scrolling one page below the last line.</p>
End Rem
	Method Setendatlastline()
		SendEditor(SCI_SETENDATLASTLINE)
	End Method
	

Rem
bbdoc: GETENDATLASTLINE
End Rem
	Method Getendatlastline()
		SendEditor(SCI_GETENDATLASTLINE)
	End Method
	

Rem
bbdoc: TEXTHEIGHT
about: <p><b id="SCI_TEXTHEIGHT">SCI_TEXTHEIGHT(int line)</b><br />
     This returns the height in pixels of a particular line. Currently all lines are the same
    height.</p>
End Rem
	Method TextHeight()
		SendEditor(SCI_TEXTHEIGHT)
	End Method
	

Rem
bbdoc: SETVSCROLLBAR
about: <p><b id="SCI_SETVSCROLLBAR">SCI_SETVSCROLLBAR(bool visible)</b><br />
     <b id="SCI_GETVSCROLLBAR">SCI_GETVSCROLLBAR</b><br />
     By default, the vertical scroll bar is always displayed when required. You can choose to hide
    or show it with <code>SCI_SETVSCROLLBAR</code> and get the current state with
    <code>SCI_GETVSCROLLBAR</code>.</p>
End Rem
	Method Setvscrollbar()
		SendEditor(SCI_SETVSCROLLBAR)
	End Method
	

Rem
bbdoc: GETVSCROLLBAR
End Rem
	Method Getvscrollbar()
		SendEditor(SCI_GETVSCROLLBAR)
	End Method
	

Rem
bbdoc: APPENDTEXT
about: <p><b id="SCI_APPENDTEXT">SCI_APPENDTEXT(int length, const char *s)</b><br />
     This adds the first <code>length</code> characters from the string <code>s</code> to the end
    of the document. This will include any 0's in the string that you might have expected to stop
    the operation. The current selection is not changed and the new text is not scrolled into
    view.</p>
End Rem
	Method Appendtext()
		SendEditor(SCI_APPENDTEXT)
	End Method
	

Rem
bbdoc: GETTWOPHASEDRAW
End Rem
	Method Gettwophasedraw()
		SendEditor(SCI_GETTWOPHASEDRAW)
	End Method
	

Rem
bbdoc: SETTWOPHASEDRAW
about: <p><b id="SCI_SETTWOPHASEDRAW">SCI_SETTWOPHASEDRAW(bool twoPhase)</b><br />
     <b id="SCI_GETTWOPHASEDRAW">SCI_GETTWOPHASEDRAW</b><br />
     Two phase drawing is a better but slower way of drawing text.
     In single phase drawing each run of characters in one style is drawn along with its background.
     If a character overhangs the end of a run, such as in "<i>V</i>_" where the
     "<i>V</i>" is in a different style from the "_", then this can cause the right hand
     side of the "<i>V</i>" to be overdrawn by the background of the "_" which
     cuts it off. Two phase drawing
     fixes this by drawing all the backgrounds first and then drawing the text in
     transparent mode. Two phase drawing may flicker more than single phase
     unless buffered drawing is on. The default is for drawing to be two phase.</p>
End Rem
	Method Settwophasedraw()
		SendEditor(SCI_SETTWOPHASEDRAW)
	End Method
	

Rem
bbdoc: TARGETFROMSELECTION
about: <p><b id="SCI_TARGETFROMSELECTION">SCI_TARGETFROMSELECTION</b><br />
     Set the target start and end to the start and end positions of the selection.</p>
End Rem
	Method Targetfromselection()
		SendEditor(SCI_TARGETFROMSELECTION)
	End Method
	

Rem
bbdoc: LINESJOIN
about: <p><b id="SCI_LINESJOIN">SCI_LINESJOIN</b><br />
     Join a range of lines indicated by the target into one line by
     removing line end characters.
     Where this would lead to no space between words, an extra space is inserted.
     </p>
End Rem
	Method Linesjoin()
		SendEditor(SCI_LINESJOIN)
	End Method
	

Rem
bbdoc: LINESSPLIT
about: <p><b id="SCI_LINESSPLIT">SCI_LINESSPLIT(int pixelWidth)</b><br />
     Split a range of lines indicated by the target into lines that are at most pixelWidth wide.
     Splitting occurs on word boundaries wherever possible in a similar manner to line wrapping.
     When <code>pixelWidth</code> is 0 then the width of the window is used.
     </p>
End Rem
	Method Linessplit()
		SendEditor(SCI_LINESSPLIT)
	End Method
	

Rem
bbdoc: SETFOLDMARGINCOLOUR
about: <p><b id="SCI_SETFOLDMARGINCOLOUR">SCI_SETFOLDMARGINCOLOUR(bool useSetting, int colour)</b><br />
     <b id="SCI_SETFOLDMARGINHICOLOUR">SCI_SETFOLDMARGINHICOLOUR(bool useSetting, int colour)</b><br />
     These messages allow changing the colour of the fold margin and fold margin highlight.
     On Windows the fold margin colour defaults to ::GetSysColor(COLOR_3DFACE) and the fold margin highlight
     colour to ::GetSysColor(COLOR_3DHIGHLIGHT).</p>
End Rem
	Method Setfoldmargincolour()
		SendEditor(SCI_SETFOLDMARGINCOLOUR)
	End Method
	

Rem
bbdoc: SETFOLDMARGINHICOLOUR
End Rem
	Method Setfoldmarginhicolour()
		SendEditor(SCI_SETFOLDMARGINHICOLOUR)
	End Method
	

Rem
bbdoc: LINEDOWN
End Rem
	Method Linedown()
		SendEditor(SCI_LINEDOWN)
	End Method
	

Rem
bbdoc: LINEDOWNEXTEND
End Rem
	Method Linedownextend()
		SendEditor(SCI_LINEDOWNEXTEND)
	End Method
	

Rem
bbdoc: LINEUP
End Rem
	Method Lineup()
		SendEditor(SCI_LINEUP)
	End Method
	

Rem
bbdoc: LINEUPEXTEND
End Rem
	Method Lineupextend()
		SendEditor(SCI_LINEUPEXTEND)
	End Method
	

Rem
bbdoc: CHARLEFT
End Rem
	Method Charleft()
		SendEditor(SCI_CHARLEFT)
	End Method
	

Rem
bbdoc: CHARLEFTEXTEND
End Rem
	Method Charleftextend()
		SendEditor(SCI_CHARLEFTEXTEND)
	End Method
	

Rem
bbdoc: CHARRIGHT
End Rem
	Method Charright()
		SendEditor(SCI_CHARRIGHT)
	End Method
	

Rem
bbdoc: CHARRIGHTEXTEND
End Rem
	Method Charrightextend()
		SendEditor(SCI_CHARRIGHTEXTEND)
	End Method
	

Rem
bbdoc: WORDLEFT
End Rem
	Method Wordleft()
		SendEditor(SCI_WORDLEFT)
	End Method
	

Rem
bbdoc: WORDLEFTEXTEND
End Rem
	Method Wordleftextend()
		SendEditor(SCI_WORDLEFTEXTEND)
	End Method
	

Rem
bbdoc: WORDRIGHT
End Rem
	Method Wordright()
		SendEditor(SCI_WORDRIGHT)
	End Method
	

Rem
bbdoc: WORDRIGHTEXTEND
End Rem
	Method Wordrightextend()
		SendEditor(SCI_WORDRIGHTEXTEND)
	End Method
	

Rem
bbdoc: HOME
End Rem
	Method Home()
		SendEditor(SCI_HOME)
	End Method
	

Rem
bbdoc: HOMEEXTEND
End Rem
	Method Homeextend()
		SendEditor(SCI_HOMEEXTEND)
	End Method
	

Rem
bbdoc: LINEEND
End Rem
	Method Lineend()
		SendEditor(SCI_LINEEND)
	End Method
	

Rem
bbdoc: LINEENDEXTEND
End Rem
	Method Lineendextend()
		SendEditor(SCI_LINEENDEXTEND)
	End Method
	

Rem
bbdoc: DOCUMENTSTART
End Rem
	Method Documentstart()
		SendEditor(SCI_DOCUMENTSTART)
	End Method
	

Rem
bbdoc: DOCUMENTSTARTEXTEND
End Rem
	Method Documentstartextend()
		SendEditor(SCI_DOCUMENTSTARTEXTEND)
	End Method
	

Rem
bbdoc: DOCUMENTEND
End Rem
	Method Documentend()
		SendEditor(SCI_DOCUMENTEND)
	End Method
	

Rem
bbdoc: DOCUMENTENDEXTEND
End Rem
	Method Documentendextend()
		SendEditor(SCI_DOCUMENTENDEXTEND)
	End Method
	

Rem
bbdoc: PAGEUP
End Rem
	Method Pageup()
		SendEditor(SCI_PAGEUP)
	End Method
	

Rem
bbdoc: PAGEUPEXTEND
End Rem
	Method Pageupextend()
		SendEditor(SCI_PAGEUPEXTEND)
	End Method
	

Rem
bbdoc: PAGEDOWN
End Rem
	Method Pagedown()
		SendEditor(SCI_PAGEDOWN)
	End Method
	

Rem
bbdoc: PAGEDOWNEXTEND
End Rem
	Method Pagedownextend()
		SendEditor(SCI_PAGEDOWNEXTEND)
	End Method
	

Rem
bbdoc: EDITTOGGLEOVERTYPE
End Rem
	Method Edittoggleovertype()
		SendEditor(SCI_EDITTOGGLEOVERTYPE)
	End Method
	

Rem
bbdoc: CANCEL
End Rem
	Method Cancel()
		SendEditor(SCI_CANCEL)
	End Method
	

Rem
bbdoc: DELETEBACK
End Rem
	Method Deleteback()
		SendEditor(SCI_DELETEBACK)
	End Method
	

Rem
bbdoc: TAB
End Rem
	Method Tab()
		SendEditor(SCI_TAB)
	End Method
	

Rem
bbdoc: BACKTAB
End Rem
	Method Backtab()
		SendEditor(SCI_BACKTAB)
	End Method
	

Rem
bbdoc: NEWLINE
End Rem
	Method Newline()
		SendEditor(SCI_NEWLINE)
	End Method
	

Rem
bbdoc: FORMFEED
End Rem
	Method Formfeed()
		SendEditor(SCI_FORMFEED)
	End Method
	

Rem
bbdoc: VCHOME
End Rem
	Method Vchome()
		SendEditor(SCI_VCHOME)
	End Method
	

Rem
bbdoc: VCHOMEEXTEND
End Rem
	Method Vchomeextend()
		SendEditor(SCI_VCHOMEEXTEND)
	End Method
	

Rem
bbdoc: ZOOMIN
about: <p><b id="SCI_ZOOMIN">SCI_ZOOMIN</b><br />
     <b id="SCI_ZOOMOUT">SCI_ZOOMOUT</b><br />
     <code>SCI_ZOOMIN</code> increases the zoom factor by one point if the current zoom factor is
    less than 20 points. <code>SCI_ZOOMOUT</code> decreases the zoom factor by one point if the
    current zoom factor is greater than -10 points.</p>
End Rem
	Method Zoomin()
		SendEditor(SCI_ZOOMIN)
	End Method
	

Rem
bbdoc: ZOOMOUT
End Rem
	Method Zoomout()
		SendEditor(SCI_ZOOMOUT)
	End Method
	

Rem
bbdoc: DELWORDLEFT
End Rem
	Method Delwordleft()
		SendEditor(SCI_DELWORDLEFT)
	End Method
	

Rem
bbdoc: DELWORDRIGHT
End Rem
	Method Delwordright()
		SendEditor(SCI_DELWORDRIGHT)
	End Method
	

Rem
bbdoc: DELWORDRIGHTEND
End Rem
	Method Delwordrightend()
		SendEditor(SCI_DELWORDRIGHTEND)
	End Method
	

Rem
bbdoc: LINECUT
End Rem
	Method Linecut()
		SendEditor(SCI_LINECUT)
	End Method
	

Rem
bbdoc: LINEDELETE
End Rem
	Method Linedelete()
		SendEditor(SCI_LINEDELETE)
	End Method
	

Rem
bbdoc: LINETRANSPOSE
End Rem
	Method Linetranspose()
		SendEditor(SCI_LINETRANSPOSE)
	End Method
	

Rem
bbdoc: LINEDUPLICATE
End Rem
	Method Lineduplicate()
		SendEditor(SCI_LINEDUPLICATE)
	End Method
	

Rem
bbdoc: LOWERCASE
End Rem
	Method Lowercase()
		SendEditor(SCI_LOWERCASE)
	End Method
	

Rem
bbdoc: UPPERCASE
End Rem
	Method Uppercase()
		SendEditor(SCI_UPPERCASE)
	End Method
	

Rem
bbdoc: LINESCROLLDOWN
End Rem
	Method Linescrolldown()
		SendEditor(SCI_LINESCROLLDOWN)
	End Method
	

Rem
bbdoc: LINESCROLLUP
End Rem
	Method Linescrollup()
		SendEditor(SCI_LINESCROLLUP)
	End Method
	

Rem
bbdoc: DELETEBACKNOTLINE
End Rem
	Method Deletebacknotline()
		SendEditor(SCI_DELETEBACKNOTLINE)
	End Method
	

Rem
bbdoc: HOMEDISPLAY
End Rem
	Method Homedisplay()
		SendEditor(SCI_HOMEDISPLAY)
	End Method
	

Rem
bbdoc: HOMEDISPLAYEXTEND
End Rem
	Method Homedisplayextend()
		SendEditor(SCI_HOMEDISPLAYEXTEND)
	End Method
	

Rem
bbdoc: LINEENDDISPLAY
End Rem
	Method Lineenddisplay()
		SendEditor(SCI_LINEENDDISPLAY)
	End Method
	

Rem
bbdoc: LINEENDDISPLAYEXTEND
End Rem
	Method Lineenddisplayextend()
		SendEditor(SCI_LINEENDDISPLAYEXTEND)
	End Method
	

Rem
bbdoc: HOMEWRAP
End Rem
	Method Homewrap()
		SendEditor(SCI_HOMEWRAP)
	End Method
	

Rem
bbdoc: HOMEWRAPEXTEND
End Rem
	Method Homewrapextend()
		SendEditor(SCI_HOMEWRAPEXTEND)
	End Method
	

Rem
bbdoc: LINEENDWRAP
End Rem
	Method Lineendwrap()
		SendEditor(SCI_LINEENDWRAP)
	End Method
	

Rem
bbdoc: LINEENDWRAPEXTEND
End Rem
	Method Lineendwrapextend()
		SendEditor(SCI_LINEENDWRAPEXTEND)
	End Method
	

Rem
bbdoc: VCHOMEWRAP
End Rem
	Method Vchomewrap()
		SendEditor(SCI_VCHOMEWRAP)
	End Method
	

Rem
bbdoc: VCHOMEWRAPEXTEND
End Rem
	Method Vchomewrapextend()
		SendEditor(SCI_VCHOMEWRAPEXTEND)
	End Method
	

Rem
bbdoc: LINECOPY
End Rem
	Method Linecopy()
		SendEditor(SCI_LINECOPY)
	End Method
	

Rem
bbdoc: MOVECARETINSIDEVIEW
about: <p><b id="SCI_MOVECARETINSIDEVIEW">SCI_MOVECARETINSIDEVIEW</b><br />
     If the caret is off the top or bottom of the view, it is moved to the nearest line that is
    visible to its current position. Any selection is lost.</p>
End Rem
	Method Movecaretinsideview()
		SendEditor(SCI_MOVECARETINSIDEVIEW)
	End Method
	

Rem
bbdoc: LINELENGTH
about: <p><b id="SCI_LINELENGTH">SCI_LINELENGTH(int line)</b><br />
     This returns the length of the line, including any line end characters. If <code>line</code>
    is negative or beyond the last line in the document, the result is 0. If you want the length of
    the line not including any end of line characters, use <a class="message"
    href="#SCI_GETLINEENDPOSITION"><code>SCI_GETLINEENDPOSITION(line)</code></a> - <a class="message"
    href="#SCI_POSITIONFROMLINE"><code>SCI_POSITIONFROMLINE(line)</code></a>.</p>
End Rem
	Method Linelength()
		SendEditor(SCI_LINELENGTH)
	End Method
	

Rem
bbdoc: BRACEHIGHLIGHT
about: <p><b id="SCI_BRACEHIGHLIGHT">SCI_BRACEHIGHLIGHT(int pos1, int pos2)</b><br />
     Up to two characters can be highlighted in a 'brace highlighting style', which is defined as
    style number <a class="message" href="#StyleDefinition"><code>STYLE_BRACELIGHT</code></a> (34).
    If you have enabled indent guides, you may also wish to highlight the indent that corresponds
    with the brace. You can locate the column with <a class="message"
    href="#SCI_GETCOLUMN"><code>SCI_GETCOLUMN</code></a> and highlight the indent with <a
    class="message" href="#SCI_SETHIGHLIGHTGUIDE"><code>SCI_SETHIGHLIGHTGUIDE</code></a>.</p>
End Rem
	Method Bracehighlight()
		SendEditor(SCI_BRACEHIGHLIGHT)
	End Method
	

Rem
bbdoc: BRACEBADLIGHT
about: <p><b id="SCI_BRACEBADLIGHT">SCI_BRACEBADLIGHT(int pos1)</b><br />
     If there is no matching brace then the <a class="jump" href="#StyleDefinition">brace
    badlighting style</a>, style <code>STYLE_BRACEBAD</code> (35), can be used to show the brace
    that is unmatched. Using a position of <code>INVALID_POSITION</code> (-1) removes the
    highlight.</p>
End Rem
	Method Bracebadlight()
		SendEditor(SCI_BRACEBADLIGHT)
	End Method
	

Rem
bbdoc: BRACEMATCH
about: <p><b id="SCI_BRACEMATCH">SCI_BRACEMATCH(int pos, int maxReStyle)</b><br />
     The <code>SCI_BRACEMATCH</code> message finds a corresponding matching brace given
    <code>pos</code>, the position of one brace. The brace characters handled are '(', ')', '[',
    ']', '{', '}', '&lt;', and '&gt;'. The search is forwards from an opening brace and backwards
    from a closing brace. If the character at position is not a brace character, or a matching
    brace cannot be found, the return value is -1. Otherwise, the return value is the position of
    the matching brace.</p>
End Rem
	Method Bracematch()
		SendEditor(SCI_BRACEMATCH)
	End Method
	

Rem
bbdoc: GETVIEWEOL
End Rem
	Method Getvieweol()
		SendEditor(SCI_GETVIEWEOL)
	End Method
	

Rem
bbdoc: SETVIEWEOL
about: <p><b id="SCI_SETVIEWEOL">SCI_SETVIEWEOL(bool visible)</b><br />
     <b id="SCI_GETVIEWEOL">SCI_GETVIEWEOL</b><br />
     Normally, the end of line characters are hidden, but <code>SCI_SETVIEWEOL</code> allows you to
    display (or hide) them by setting <code>visible</code> <code>true</code> (or
    <code>false</code>). The visible rendering of the end of line characters is similar to
    <code>(CR)</code>, <code>(LF)</code>, or <code>(CR)(LF)</code>. <code>SCI_GETVIEWEOL</code>
    returns the current state.</p>
End Rem
	Method Setvieweol()
		SendEditor(SCI_SETVIEWEOL)
	End Method
	

Rem
bbdoc: GETDOCPOINTER
about: <p><b id="SCI_GETDOCPOINTER">SCI_GETDOCPOINTER</b><br />
     This returns a pointer to the document currently in use by the window. It has no other
    effect.</p>
End Rem
	Method Getdocpointer()
		SendEditor(SCI_GETDOCPOINTER)
	End Method
	

Rem
bbdoc: SETDOCPOINTER
about: <p><b id="SCI_SETDOCPOINTER">SCI_SETDOCPOINTER(&lt;unused&gt;, document *pDoc)</b><br />
     This message does the following:<br />
     1. It removes the current window from the list held by the current document.<br />
     2. It reduces the reference count of the current document by 1.<br />
     3. If the reference count reaches 0, the document is deleted.<br />
     4. <code>pDoc</code> is set as the new document for the window.<br />
     5. If <code>pDoc</code> was 0, a new, empty document is created and attached to the
    window.<br />
     6. If <code>pDoc</code> was not 0, its reference count is increased by 1.</p>
End Rem
	Method Setdocpointer()
		SendEditor(SCI_SETDOCPOINTER)
	End Method
	

Rem
bbdoc: SETMODEVENTMASK
about: <p><b id="SCI_SETMODEVENTMASK">SCI_SETMODEVENTMASK(int eventMask)</b><br />
     <b id="SCI_GETMODEVENTMASK">SCI_GETMODEVENTMASK</b><br />
     These messages set and get an event mask that determines which document change events are
    notified to the container with <a class="message"
    href="#SCN_MODIFIED"><code>SCN_MODIFIED</code></a> and <a class="message"
    href="#SCEN_CHANGE"><code>SCEN_CHANGE</code></a>. For example, a container may decide to see
    only notifications about changes to text and not styling changes by calling
    <code>SCI_SETMODEVENTMASK(SC_MOD_INSERTTEXT|SC_MOD_DELETETEXT)</code>.</p>
End Rem
	Method Setmodeventmask()
		SendEditor(SCI_SETMODEVENTMASK)
	End Method
	

Rem
bbdoc: GETEDGECOLUMN
End Rem
	Method Getedgecolumn()
		SendEditor(SCI_GETEDGECOLUMN)
	End Method
	

Rem
bbdoc: SETEDGECOLUMN
about: <p><b id="SCI_SETEDGECOLUMN">SCI_SETEDGECOLUMN(int column)</b><br />
     <b id="SCI_GETEDGECOLUMN">SCI_GETEDGECOLUMN</b><br />
     These messages set and get the column number at which to display the long line marker. When
    drawing lines, the column sets a position in units of the width of a space character in
    <code>STYLE_DEFAULT</code>. When setting the background colour, the column is a character count
    (allowing for tabs) into the line.</p>
End Rem
	Method Setedgecolumn()
		SendEditor(SCI_SETEDGECOLUMN)
	End Method
	

Rem
bbdoc: GETEDGEMODE
End Rem
	Method Getedgemode()
		SendEditor(SCI_GETEDGEMODE)
	End Method
	

Rem
bbdoc: SETEDGEMODE
about: <p><b id="SCI_SETEDGEMODE">SCI_SETEDGEMODE(int edgeMode)</b><br />
     <b id="SCI_GETEDGEMODE">SCI_GETEDGEMODE</b><br />
     These two messages set and get the mode used to display long lines. You can set one of the
    values in the table:</p>
End Rem
	Method Setedgemode()
		SendEditor(SCI_SETEDGEMODE)
	End Method
	

Rem
bbdoc: GETEDGECOLOUR
End Rem
	Method Getedgecolour()
		SendEditor(SCI_GETEDGECOLOUR)
	End Method
	

Rem
bbdoc: SETEDGECOLOUR
about: <p><b id="SCI_SETEDGECOLOUR">SCI_SETEDGECOLOUR(int <a class="jump"
    href="#colour">colour</a>)</b><br />
     <b id="SCI_GETEDGECOLOUR">SCI_GETEDGECOLOUR</b><br />
     These messages set and get the colour of the marker used to show that a line has exceeded the
    length set by <code>SCI_SETEDGECOLUMN</code>.</p>
End Rem
	Method Setedgecolour()
		SendEditor(SCI_SETEDGECOLOUR)
	End Method
	

Rem
bbdoc: SEARCHANCHOR
about: <p><b id="SCI_SEARCHANCHOR">SCI_SEARCHANCHOR</b><br />
     <b id="SCI_SEARCHNEXT">SCI_SEARCHNEXT(int searchFlags, const char *text)</b><br />
     <b id="SCI_SEARCHPREV">SCI_SEARCHPREV(int searchFlags, const char *text)</b><br />
     These messages provide relocatable search support. This allows multiple incremental
    interactive searches to be macro recorded while still setting the selection to found text so
    the find/select operation is self-contained. These three messages send <a class="message"
    href="#SCN_MACRORECORD"><code>SCN_MACRORECORD</code></a> <a class="jump"
    href="#Notifications">notifications</a> if macro recording is enabled.</p>
End Rem
	Method Searchanchor()
		SendEditor(SCI_SEARCHANCHOR)
	End Method
	

Rem
bbdoc: SEARCHNEXT
End Rem
	Method Searchnext()
		SendEditor(SCI_SEARCHNEXT)
	End Method
	

Rem
bbdoc: SEARCHPREV
End Rem
	Method Searchprev()
		SendEditor(SCI_SEARCHPREV)
	End Method
	

Rem
bbdoc: LINESONSCREEN
about: <p><b id="SCI_LINESONSCREEN">SCI_LINESONSCREEN</b><br />
     This returns the number of complete lines visible on the screen. With a constant line height,
    this is the vertical space available divided by the line separation. Unless you arrange to size
    your window to an integral number of lines, there may be a partial line visible at the bottom
    of the view.</p>
End Rem
	Method Linesonscreen()
		SendEditor(SCI_LINESONSCREEN)
	End Method
	

Rem
bbdoc: USEPOPUP
about: <p><b id="SCI_USEPOPUP">SCI_USEPOPUP(bool bEnablePopup)</b><br />
     Clicking the wrong button on the mouse pops up a short default editing menu. This may be
    turned off with <code>SCI_USEPOPUP(0)</code>. If you turn it off, context menu commands (in
    Windows, <code>WM_CONTEXTMENU</code>) will not be handled by Scintilla, so the parent of the
    Scintilla window will have the opportunity to handle the message.</p>
End Rem
	Method Usepopup()
		SendEditor(SCI_USEPOPUP)
	End Method
	

Rem
bbdoc: SELECTIONISRECTANGLE
about: <p><b id="SCI_SELECTIONISRECTANGLE">SCI_SELECTIONISRECTANGLE</b><br />
     This returns 1 if the current selection is in rectangle mode, 0 if not.</p>
End Rem
	Method Selectionisrectangle()
		SendEditor(SCI_SELECTIONISRECTANGLE)
	End Method
	

Rem
bbdoc: SETZOOM
about: <p><b id="SCI_SETZOOM">SCI_SETZOOM(int zoomInPoints)</b><br />
     <b id="SCI_GETZOOM">SCI_GETZOOM</b><br />
     These messages let you set and get the zoom factor directly. There is no limit set on the
    factors you can set, so limiting yourself to -10 to +20 to match the incremental zoom functions
    is a good idea.</p>
End Rem
	Method Setzoom()
		SendEditor(SCI_SETZOOM)
	End Method
	

Rem
bbdoc: GETZOOM
End Rem
	Method Getzoom()
		SendEditor(SCI_GETZOOM)
	End Method
	

Rem
bbdoc: CREATEDOCUMENT
about: <p><b id="SCI_CREATEDOCUMENT">SCI_CREATEDOCUMENT</b><br />
     This message creates a new, empty document and returns a pointer to it. This document is not
    selected into the editor and starts with a reference count of 1. This means that you have
    ownership of it and must either reduce its reference count by 1 after using
    <code>SCI_SETDOCPOINTER</code> so that the Scintilla window owns it or you must make sure that
    you reduce the reference count by 1 with <code>SCI_RELEASEDOCUMENT</code> before you close the
    application to avoid memory leaks.</p>
End Rem
	Method Createdocument()
		SendEditor(SCI_CREATEDOCUMENT)
	End Method
	

Rem
bbdoc: ADDREFDOCUMENT
about: <p><b id="SCI_ADDREFDOCUMENT">SCI_ADDREFDOCUMENT(&lt;unused&gt;, document *pDoc)</b><br />
     This increases the reference count of a document by 1. If you want to replace the current
    document in the Scintilla window and take ownership of the current document, for example if you
    are editing many documents in one window, do the following:<br />
     1. Use <code>SCI_GETDOCPOINTER</code> to get a pointer to the document,
    <code>pDoc</code>.<br />
     2. Use <code>SCI_ADDREFDOCUMENT(0, pDoc)</code> to increment the reference count.<br />
     3. Use <code>SCI_SETDOCPOINTER(0, pNewDoc)</code> to set a different document or
    <code>SCI_SETDOCPOINTER(0, 0)</code> to set a new, empty document.</p>
End Rem
	Method Addrefdocument()
		SendEditor(SCI_ADDREFDOCUMENT)
	End Method
	

Rem
bbdoc: RELEASEDOCUMENT
about: <p><b id="SCI_RELEASEDOCUMENT">SCI_RELEASEDOCUMENT(&lt;unused&gt;, document *pDoc)</b><br />
     This message reduces the reference count of the document identified by <code>pDoc</code>. pDoc
    must be the result of <code>SCI_GETDOCPOINTER</code> or <code>SCI_CREATEDOCUMENT</code> and
    must point at a document that still exists. If you call this on a document with a reference
    count of 1 that is still attached to a Scintilla window, bad things will happen. To keep the
    world spinning in its orbit you must balance each call to <code>SCI_CREATEDOCUMENT</code> or
    <code>SCI_ADDREFDOCUMENT</code> with a call to <code>SCI_RELEASEDOCUMENT</code>.</p>
End Rem
	Method Releasedocument()
		SendEditor(SCI_RELEASEDOCUMENT)
	End Method
	

Rem
bbdoc: GETMODEVENTMASK
End Rem
	Method Getmodeventmask()
		SendEditor(SCI_GETMODEVENTMASK)
	End Method
	

Rem
bbdoc: SETFOCUS
End Rem
	Method Setfocus()
		SendEditor(SCI_SETFOCUS)
	End Method
	

Rem
bbdoc: GETFOCUS
End Rem
	Method Getfocus()
		SendEditor(SCI_GETFOCUS)
	End Method
	

Rem
bbdoc: SETSTATUS
about: <p><b id="SCI_SETSTATUS">SCI_SETSTATUS(int status)</b><br />
     <b id="SCI_GETSTATUS">SCI_GETSTATUS</b><br />
     If an error occurs, Scintilla may set an internal error number that can be retrieved with
    <code>SCI_GETSTATUS</code>. 
    To clear the error status call <code>SCI_SETSTATUS(0)</code>.
    The currently defined statuses are:

    <table cellpadding="1" cellspacing="2" border="0" summary="Status values">
      <tbody valign="top">
        <tr>
          <th align="left">SC_STATUS_OK</th>
          <td>0</td>
          <td>No failures</td>
        </tr>

        <tr>
          <th align="left">SC_STATUS_FAILURE</th>
          <td>1</td>
          <td>Generic failure</td>
        </tr>

        <tr>
          <th align="left">SC_STATUS_BADALLOC</th>
          <td>2</td>
          <td>Memory is exhausted</td>
        </tr>

      </tbody>
    </table>

    </p>
End Rem
	Method Setstatus()
		SendEditor(SCI_SETSTATUS)
	End Method
	

Rem
bbdoc: GETSTATUS
End Rem
	Method Getstatus()
		SendEditor(SCI_GETSTATUS)
	End Method
	

Rem
bbdoc: SETMOUSEDOWNCAPTURES
about: <p><b id="SCI_SETMOUSEDOWNCAPTURES">SCI_SETMOUSEDOWNCAPTURES(bool captures)</b><br />
     <b id="SCI_GETMOUSEDOWNCAPTURES">SCI_GETMOUSEDOWNCAPTURES</b><br />
     When the mouse is pressed inside Scintilla, it is captured so future mouse movement events are
    sent to Scintilla. This behavior may be turned off with
    <code>SCI_SETMOUSEDOWNCAPTURES(0)</code>.</p>
End Rem
	Method Setmousedowncaptures()
		SendEditor(SCI_SETMOUSEDOWNCAPTURES)
	End Method
	

Rem
bbdoc: GETMOUSEDOWNCAPTURES
End Rem
	Method Getmousedowncaptures()
		SendEditor(SCI_GETMOUSEDOWNCAPTURES)
	End Method
	

Rem
bbdoc: SETCURSOR
about: <p><b id="SCI_SETCURSOR">SCI_SETCURSOR(int curType)</b><br />
     <b id="SCI_GETCURSOR">SCI_GETCURSOR</b><br />
     The cursor is normally chosen in a context sensitive way, so it will be different over the
    margin than when over the text. When performing a slow action, you may wish to change to a wait
    cursor. You set the cursor type with <code>SCI_SETCURSOR</code>. The <code>curType</code>
    argument can be:</p>
End Rem
	Method Setcursor()
		SendEditor(SCI_SETCURSOR)
	End Method
	

Rem
bbdoc: GETCURSOR
End Rem
	Method Getcursor()
		SendEditor(SCI_GETCURSOR)
	End Method
	

Rem
bbdoc: SETCONTROLCHARSYMBOL
about: <p><b id="SCI_SETCONTROLCHARSYMBOL">SCI_SETCONTROLCHARSYMBOL(int symbol)</b><br />
     <b id="SCI_GETCONTROLCHARSYMBOL">SCI_GETCONTROLCHARSYMBOL</b><br />
     By default, Scintilla displays control characters (characters with codes less than 32) in a
    rounded rectangle as ASCII mnemonics: "NUL", "SOH", "STX", "ETX", "EOT", "ENQ", "ACK", "BEL",
    "BS", "HT", "LF", "VT", "FF", "CR", "SO", "SI", "DLE", "DC1", "DC2", "DC3", "DC4", "NAK",
    "SYN", "ETB", "CAN", "EM", "SUB", "ESC", "FS", "GS", "RS", "US". These mnemonics come from the
    early days of signaling, though some are still used (LF = Line Feed, BS = Back Space, CR =
    Carriage Return, for example).</p>
End Rem
	Method Setcontrolcharsymbol()
		SendEditor(SCI_SETCONTROLCHARSYMBOL)
	End Method
	

Rem
bbdoc: GETCONTROLCHARSYMBOL
End Rem
	Method Getcontrolcharsymbol()
		SendEditor(SCI_GETCONTROLCHARSYMBOL)
	End Method
	

Rem
bbdoc: WORDPARTLEFT
End Rem
	Method Wordpartleft()
		SendEditor(SCI_WORDPARTLEFT)
	End Method
	

Rem
bbdoc: WORDPARTLEFTEXTEND
End Rem
	Method Wordpartleftextend()
		SendEditor(SCI_WORDPARTLEFTEXTEND)
	End Method
	

Rem
bbdoc: WORDPARTRIGHT
End Rem
	Method Wordpartright()
		SendEditor(SCI_WORDPARTRIGHT)
	End Method
	

Rem
bbdoc: WORDPARTRIGHTEXTEND
End Rem
	Method Wordpartrightextend()
		SendEditor(SCI_WORDPARTRIGHTEXTEND)
	End Method
	

Rem
bbdoc: SETVISIBLEPOLICY
about: <p><b id="SCI_SETVISIBLEPOLICY">SCI_SETVISIBLEPOLICY(int caretPolicy, int caretSlop)</b><br />
     This determines how the vertical positioning is determined when <a class="message"
    href="#SCI_ENSUREVISIBLEENFORCEPOLICY"><code>SCI_ENSUREVISIBLEENFORCEPOLICY</code></a> is
    called. It takes <code>VISIBLE_SLOP</code> and <code>VISIBLE_STRICT</code> flags for the policy
    parameter. It is similar in operation to <a class="message"
    href="#SCI_SETYCARETPOLICY"><code>SCI_SETYCARETPOLICY(int caretPolicy, int
    caretSlop)</code></a>.</p>
End Rem
	Method Setvisiblepolicy()
		SendEditor(SCI_SETVISIBLEPOLICY)
	End Method
	

Rem
bbdoc: DELLINELEFT
End Rem
	Method Dellineleft()
		SendEditor(SCI_DELLINELEFT)
	End Method
	

Rem
bbdoc: DELLINERIGHT
End Rem
	Method Dellineright()
		SendEditor(SCI_DELLINERIGHT)
	End Method
	

Rem
bbdoc: SETXOFFSET
about: <p><b id="SCI_SETXOFFSET">SCI_SETXOFFSET(int xOffset)</b><br />
     <b id="SCI_GETXOFFSET">SCI_GETXOFFSET</b><br />
     The <code>xOffset</code> is the horizontal scroll position in pixels of the start of the text
    view. A value of 0 is the normal position with the first text column visible at the left of the
    view.</p>
See Also: <a class="message" href="#SCI_LINESCROLL"><code>SCI_LINESCROLL</code></a>
End Rem
	Method Setxoffset()
		SendEditor(SCI_SETXOFFSET)
	End Method
	

Rem
bbdoc: GETXOFFSET
End Rem
	Method Getxoffset()
		SendEditor(SCI_GETXOFFSET)
	End Method
	

Rem
bbdoc: CHOOSECARETX
about: <p><b id="SCI_CHOOSECARETX">SCI_CHOOSECARETX</b><br />
     Scintilla remembers the x value of the last position horizontally moved to explicitly by the
    user and this value is then used when moving vertically such as by using the up and down keys.
    This message sets the current x position of the caret as the remembered value.</p>
End Rem
	Method Choosecaretx()
		SendEditor(SCI_CHOOSECARETX)
	End Method
	

Rem
bbdoc: GRABFOCUS
about: <p><b id="SCI_GRABFOCUS">SCI_GRABFOCUS</b><br />
     <b id="SCI_SETFOCUS">SCI_SETFOCUS(bool focus)</b><br />
     <b id="SCI_GETFOCUS">SCI_GETFOCUS</b><br />
     Scintilla can be told to grab the focus with this message. This is needed more on GTK+ where
           focus handling is more complicated than on Windows.</p>
End Rem
	Method Grabfocus()
		SendEditor(SCI_GRABFOCUS)
	End Method
	

Rem
bbdoc: SETXCARETPOLICY
about: <p><b id="SCI_SETXCARETPOLICY">SCI_SETXCARETPOLICY(int caretPolicy, int caretSlop)</b><br />
     <b id="SCI_SETYCARETPOLICY">SCI_SETYCARETPOLICY(int caretPolicy, int caretSlop)</b><br />
     These set the caret policy. The value of <code>caretPolicy</code> is a combination of
    <code>CARET_SLOP</code>, <code>CARET_STRICT</code>, <code>CARET_JUMPS</code> and
    <code>CARET_EVEN</code>.</p>
End Rem
	Method Setxcaretpolicy()
		SendEditor(SCI_SETXCARETPOLICY)
	End Method
	

Rem
bbdoc: SETYCARETPOLICY
End Rem
	Method Setycaretpolicy()
		SendEditor(SCI_SETYCARETPOLICY)
	End Method
	

Rem
bbdoc: SETPRINTWRAPMODE
about: <p><b id="SCI_SETPRINTWRAPMODE">SCI_SETPRINTWRAPMODE(int wrapMode)</b><br />
     <b id="SCI_GETPRINTWRAPMODE">SCI_GETPRINTWRAPMODE</b><br />
     These two functions get and set the printer wrap mode. <code>wrapMode</code> can be
     set to <code>SC_WRAP_NONE</code> (0), <code>SC_WRAP_WORD</code> (1) or
     <code>SC_WRAP_CHAR</code> (2). The default is
     <code>SC_WRAP_WORD</code>, which wraps printed output so that all characters fit
     into the print rectangle. If you set <code>SC_WRAP_NONE</code>, each line of text
     generates one line of output and the line is truncated if it is too long to fit
     into the print area.<br />
     <code>SC_WRAP_WORD</code> tries to wrap only between words as indicated by
     white space or style changes although if a word is longer than a line, it will be wrapped before
     the line end. <code>SC_WRAP_CHAR</code> is preferred to
     <code>SC_WRAP_WORD</code> for Asian languages where there is no white space
     between words.</p>
End Rem
	Method Setprintwrapmode()
		SendEditor(SCI_SETPRINTWRAPMODE)
	End Method
	

Rem
bbdoc: GETPRINTWRAPMODE
End Rem
	Method Getprintwrapmode()
		SendEditor(SCI_GETPRINTWRAPMODE)
	End Method
	

Rem
bbdoc: SETHOTSPOTACTIVEFORE
about: <p><b id="SCI_SETHOTSPOTACTIVEFORE">SCI_SETHOTSPOTACTIVEFORE(bool useHotSpotForeColour, int <a class="jump"
    href="#colour">colour</a>)</b><br />
    <b id="SCI_GETHOTSPOTACTIVEFORE">SCI_GETHOTSPOTACTIVEFORE</b><br />
    <b id="SCI_SETHOTSPOTACTIVEBACK">SCI_SETHOTSPOTACTIVEBACK(bool useHotSpotBackColour, int <a class="jump"
    href="#colour">colour</a>)</b><br />
    <b id="SCI_GETHOTSPOTACTIVEBACK">SCI_GETHOTSPOTACTIVEBACK</b><br />
    <b id="SCI_SETHOTSPOTACTIVEUNDERLINE">SCI_SETHOTSPOTACTIVEUNDERLINE(bool underline)</b><br />
     <b id="SCI_GETHOTSPOTACTIVEUNDERLINE">SCI_GETHOTSPOTACTIVEUNDERLINE</b><br />
    <b id="SCI_SETHOTSPOTSINGLELINE">SCI_SETHOTSPOTSINGLELINE(bool singleLine)</b><br />
     <b id="SCI_GETHOTSPOTSINGLELINE">SCI_GETHOTSPOTSINGLELINE</b><br />
    While the cursor hovers over text in a style with the hotspot attribute set,
    the default colouring can be modified and an underline drawn with these settings.
    Single line mode stops a hotspot from wrapping onto next line.</p>
End Rem
	Method Sethotspotactivefore()
		SendEditor(SCI_SETHOTSPOTACTIVEFORE)
	End Method
	

Rem
bbdoc: GETHOTSPOTACTIVEFORE
End Rem
	Method Gethotspotactivefore()
		SendEditor(SCI_GETHOTSPOTACTIVEFORE)
	End Method
	

Rem
bbdoc: SETHOTSPOTACTIVEBACK
End Rem
	Method Sethotspotactiveback()
		SendEditor(SCI_SETHOTSPOTACTIVEBACK)
	End Method
	

Rem
bbdoc: GETHOTSPOTACTIVEBACK
End Rem
	Method Gethotspotactiveback()
		SendEditor(SCI_GETHOTSPOTACTIVEBACK)
	End Method
	

Rem
bbdoc: SETHOTSPOTACTIVEUNDERLINE
End Rem
	Method Sethotspotactiveunderline()
		SendEditor(SCI_SETHOTSPOTACTIVEUNDERLINE)
	End Method
	

Rem
bbdoc: GETHOTSPOTACTIVEUNDERLINE
End Rem
	Method Gethotspotactiveunderline()
		SendEditor(SCI_GETHOTSPOTACTIVEUNDERLINE)
	End Method
	

Rem
bbdoc: SETHOTSPOTSINGLELINE
End Rem
	Method Sethotspotsingleline()
		SendEditor(SCI_SETHOTSPOTSINGLELINE)
	End Method
	

Rem
bbdoc: GETHOTSPOTSINGLELINE
End Rem
	Method Gethotspotsingleline()
		SendEditor(SCI_GETHOTSPOTSINGLELINE)
	End Method
	

Rem
bbdoc: PARADOWN
End Rem
	Method Paradown()
		SendEditor(SCI_PARADOWN)
	End Method
	

Rem
bbdoc: PARADOWNEXTEND
End Rem
	Method Paradownextend()
		SendEditor(SCI_PARADOWNEXTEND)
	End Method
	

Rem
bbdoc: PARAUP
End Rem
	Method Paraup()
		SendEditor(SCI_PARAUP)
	End Method
	

Rem
bbdoc: PARAUPEXTEND
End Rem
	Method Paraupextend()
		SendEditor(SCI_PARAUPEXTEND)
	End Method
	

Rem
bbdoc: POSITIONBEFORE
about: <p><b id="SCI_POSITIONBEFORE">SCI_POSITIONBEFORE(int position)</b><br />
     <b id="SCI_POSITIONAFTER">SCI_POSITIONAFTER(int position)</b><br />
     These messages return the position before and after another position
     in the document taking into account the current code page. The minimum
     position returned is 0 and the maximum is the last position in the document.
     If called with a position within a multi byte character will return the position
     of the start/end of that character.</p>
End Rem
	Method Positionbefore()
		SendEditor(SCI_POSITIONBEFORE)
	End Method
	

Rem
bbdoc: POSITIONAFTER
End Rem
	Method Positionafter()
		SendEditor(SCI_POSITIONAFTER)
	End Method
	

Rem
bbdoc: COPYRANGE
End Rem
	Method Copyrange()
		SendEditor(SCI_COPYRANGE)
	End Method
	

Rem
bbdoc: COPYTEXT
End Rem
	Method Copytext()
		SendEditor(SCI_COPYTEXT)
	End Method
	

Rem
bbdoc: SETSELECTIONMODE
about: <p><b id="SCI_SETSELECTIONMODE">SCI_SETSELECTIONMODE(int mode)</b><br />
    <b id="SCI_GETSELECTIONMODE">SCI_GETSELECTIONMODE</b><br />
    The two functions set and get the selection mode, which can be
     stream (<code>SC_SEL_STREAM</code>=0) or
     rectangular (<code>SC_SEL_RECTANGLE</code>=1) or
     by lines (<code>SC_SEL_LINES</code>=2)
     or thin rectangular (<code>SC_SEL_THIN</code>=3).
     When set in these modes, regular caret moves will extend or reduce the selection,
     until the mode is cancelled by a call with same value or with <code>SCI_CANCEL</code>.
     The get function returns the current mode even if the selection was made by mouse
     or with regular extended moves.
     <code>SC_SEL_THIN</code> is the mode after a rectangular selection has been typed into and ensures
     that no characters are selected.</p>
End Rem
	Method Setselectionmode()
		SendEditor(SCI_SETSELECTIONMODE)
	End Method
	

Rem
bbdoc: GETSELECTIONMODE
End Rem
	Method Getselectionmode()
		SendEditor(SCI_GETSELECTIONMODE)
	End Method
	

Rem
bbdoc: GETLINESELSTARTPOSITION
about: <p><b id="SCI_GETLINESELSTARTPOSITION">SCI_GETLINESELSTARTPOSITION(int line)</b><br />
    <b id="SCI_GETLINESELENDPOSITION">SCI_GETLINESELENDPOSITION(int line)</b><br />
    Retrieve the position of the start and end of the selection at the given line with
    INVALID_POSITION returned if no selection on this line.</p>
End Rem
	Method Getlineselstartposition()
		SendEditor(SCI_GETLINESELSTARTPOSITION)
	End Method
	

Rem
bbdoc: GETLINESELENDPOSITION
End Rem
	Method Getlineselendposition()
		SendEditor(SCI_GETLINESELENDPOSITION)
	End Method
	

Rem
bbdoc: LINEDOWNRECTEXTEND
End Rem
	Method Linedownrectextend()
		SendEditor(SCI_LINEDOWNRECTEXTEND)
	End Method
	

Rem
bbdoc: LINEUPRECTEXTEND
End Rem
	Method Lineuprectextend()
		SendEditor(SCI_LINEUPRECTEXTEND)
	End Method
	

Rem
bbdoc: CHARLEFTRECTEXTEND
End Rem
	Method Charleftrectextend()
		SendEditor(SCI_CHARLEFTRECTEXTEND)
	End Method
	

Rem
bbdoc: CHARRIGHTRECTEXTEND
End Rem
	Method Charrightrectextend()
		SendEditor(SCI_CHARRIGHTRECTEXTEND)
	End Method
	

Rem
bbdoc: HOMERECTEXTEND
End Rem
	Method Homerectextend()
		SendEditor(SCI_HOMERECTEXTEND)
	End Method
	

Rem
bbdoc: VCHOMERECTEXTEND
End Rem
	Method Vchomerectextend()
		SendEditor(SCI_VCHOMERECTEXTEND)
	End Method
	

Rem
bbdoc: LINEENDRECTEXTEND
End Rem
	Method Lineendrectextend()
		SendEditor(SCI_LINEENDRECTEXTEND)
	End Method
	

Rem
bbdoc: PAGEUPRECTEXTEND
End Rem
	Method Pageuprectextend()
		SendEditor(SCI_PAGEUPRECTEXTEND)
	End Method
	

Rem
bbdoc: PAGEDOWNRECTEXTEND
End Rem
	Method Pagedownrectextend()
		SendEditor(SCI_PAGEDOWNRECTEXTEND)
	End Method
	

Rem
bbdoc: STUTTEREDPAGEUP
End Rem
	Method Stutteredpageup()
		SendEditor(SCI_STUTTEREDPAGEUP)
	End Method
	

Rem
bbdoc: STUTTEREDPAGEUPEXTEND
End Rem
	Method Stutteredpageupextend()
		SendEditor(SCI_STUTTEREDPAGEUPEXTEND)
	End Method
	

Rem
bbdoc: STUTTEREDPAGEDOWN
End Rem
	Method Stutteredpagedown()
		SendEditor(SCI_STUTTEREDPAGEDOWN)
	End Method
	

Rem
bbdoc: STUTTEREDPAGEDOWNEXTEND
End Rem
	Method Stutteredpagedownextend()
		SendEditor(SCI_STUTTEREDPAGEDOWNEXTEND)
	End Method
	

Rem
bbdoc: WORDLEFTEND
End Rem
	Method Wordleftend()
		SendEditor(SCI_WORDLEFTEND)
	End Method
	

Rem
bbdoc: WORDLEFTENDEXTEND
End Rem
	Method Wordleftendextend()
		SendEditor(SCI_WORDLEFTENDEXTEND)
	End Method
	

Rem
bbdoc: WORDRIGHTEND
End Rem
	Method Wordrightend()
		SendEditor(SCI_WORDRIGHTEND)
	End Method
	

Rem
bbdoc: WORDRIGHTENDEXTEND
End Rem
	Method Wordrightendextend()
		SendEditor(SCI_WORDRIGHTENDEXTEND)
	End Method
	

Rem
bbdoc: SETWHITESPACECHARS
about: <p><b id="SCI_SETWHITESPACECHARS">SCI_SETWHITESPACECHARS(&lt;unused&gt;, const char *chars)</b><br />
     Similar to <code>SCI_SETWORDCHARS</code>, this message allows the user to define which chars Scintilla considers
          as whitespace.  Setting the whitespace chars allows the user to fine-tune Scintilla's behaviour doing
          such things as moving the cursor to the start or end of a word; for example, by defining punctuation chars
          as whitespace, they will be skipped over when the user presses ctrl+left or ctrl+right.
          This function should be called after <code>SCI_SETWORDCHARS</code> as it will
          reset the whitespace characters to the default set.</p>
End Rem
	Method Setwhitespacechars()
		SendEditor(SCI_SETWHITESPACECHARS)
	End Method
	

Rem
bbdoc: SETCHARSDEFAULT
about: <p><b id="SCI_SETCHARSDEFAULT">SCI_SETCHARSDEFAULT</b><br />
     Use the default sets of word and whitespace characters. This sets whitespace to space, tab and other
     characters with codes less than 0x20, with word characters set to alphanumeric and '_'.
    </p>
End Rem
	Method Setcharsdefault()
		SendEditor(SCI_SETCHARSDEFAULT)
	End Method
	

Rem
bbdoc: AUTOCGETCURRENT
End Rem
	Method Autocgetcurrent()
		SendEditor(SCI_AUTOCGETCURRENT)
	End Method
	
Rem
bbdoc: TARGETASUTF8
about: <p><b id="SCI_TARGETASUTF8">SCI_TARGETASUTF8(&lt;unused&gt;, char *s)</b><br />
     This method retrieves the value of the target encoded as UTF-8 which is the default
     encoding of GTK+ so is useful for retrieving text for use in other parts of the user interface,
     such as find and replace dialogs. The length of the encoded text in bytes is returned.
    </p>
End Rem
	Method Targetasutf8()
		SendEditor(SCI_TARGETASUTF8)
	End Method
	

Rem
bbdoc: SETLENGTHFORENCODE
End Rem
	Method Setlengthforencode()
		SendEditor(SCI_SETLENGTHFORENCODE)
	End Method
	

Rem
bbdoc: ENCODEDFROMUTF8
about: <p><b id="SCI_ENCODEDFROMUTF8">SCI_ENCODEDFROMUTF8(const char *utf8, char *encoded)</b><br />
     <b id="SCI_SETLENGTHFORENCODE">SCI_SETLENGTHFORENCODE(int bytes)</b><br />
     <code>SCI_ENCODEDFROMUTF8</code> converts a UTF-8 string into the document's
     encoding which is useful for taking the results of a find dialog, for example, and receiving
     a string of bytes that can be searched for in the document. Since the text can contain nul bytes,
     the <code>SCI_SETLENGTHFORENCODE</code> method can be used to set the
     length that will be converted. If set to -1, the length is determined by finding a nul byte.
     The length of the converted string is returned.
    </p>
End Rem
	Method Encodedfromutf8()
		SendEditor(SCI_ENCODEDFROMUTF8)
	End Method
	

Rem
bbdoc: FINDCOLUMN
about: <p><b id="SCI_FINDCOLUMN">SCI_FINDCOLUMN(int line, int column)</b><br />
     This message returns the position of a <code>column</code> on a <code>line</code>
    taking the width of tabs into account. It treats a multi-byte character as a single column.
    Column numbers, like lines start at 0.</p>
End Rem
	Method Findcolumn()
		SendEditor(SCI_FINDCOLUMN)
	End Method
	

Rem
bbdoc: GETCARETSTICKY
End Rem
	Method Getcaretsticky()
		SendEditor(SCI_GETCARETSTICKY)
	End Method
	

Rem
bbdoc: SETCARETSTICKY
about: <p><b id="SCI_SETCARETSTICKY">SCI_SETCARETSTICKY(bool useCaretStickyBehaviour)</b><br />
    <b id="SCI_GETCARETSTICKY">SCI_GETCARETSTICKY</b><br />
    <b id="SCI_TOGGLECARETSTICKY">SCI_TOGGLECARETSTICKY</b><br />
    These messages set, get or toggle the caretSticky flag which controls when the last position
     of the caret on the line is saved. When set to true, the position is not saved when you type
     a character, a tab, paste the clipboard content or press backspace.</p>
End Rem
	Method Setcaretsticky()
		SendEditor(SCI_SETCARETSTICKY)
	End Method
	

Rem
bbdoc: TOGGLECARETSTICKY
End Rem
	Method Togglecaretsticky()
		SendEditor(SCI_TOGGLECARETSTICKY)
	End Method
	

Rem
bbdoc: SETPASTECONVERTENDINGS
about: <p><b id="SCI_SETPASTECONVERTENDINGS">SCI_SETPASTECONVERTENDINGS(bool convert)</b><br />
     <b id="SCI_GETPASTECONVERTENDINGS">SCI_GETPASTECONVERTENDINGS</b><br />
     If this property is set then when text is pasted any line ends are converted to match the document's
     end of line mode as set with
     <a class="message" href="#SCI_SETEOLMODE">SCI_SETEOLMODE</a>.
     Currently only changeable on Windows. On GTK+ pasted text is always converted.</p>
End Rem
	Method Setpasteconvertendings()
		SendEditor(SCI_SETPASTECONVERTENDINGS)
	End Method
	

Rem
bbdoc: GETPASTECONVERTENDINGS
End Rem
	Method Getpasteconvertendings()
		SendEditor(SCI_GETPASTECONVERTENDINGS)
	End Method
	

Rem
bbdoc: SELECTIONDUPLICATE
End Rem
	Method Selectionduplicate()
		SendEditor(SCI_SELECTIONDUPLICATE)
	End Method
	

Rem
bbdoc: SETCARETLINEBACKALPHA
End Rem
	Method Setcaretlinebackalpha()
		SendEditor(SCI_SETCARETLINEBACKALPHA)
	End Method
	

Rem
bbdoc: GETCARETLINEBACKALPHA
End Rem
	Method Getcaretlinebackalpha()
		SendEditor(SCI_GETCARETLINEBACKALPHA)
	End Method
	

Rem
bbdoc: SETCARETSTYLE
about: <p><b id="SCI_SETCARETSTYLE">SCI_SETCARETSTYLE(int style)</b><br />
     <b id="SCI_GETCARETSTYLE">SCI_GETCARETSTYLE</b><br />
     The style of the caret can be set with <code>SCI_SETCARETSTYLE</code> to be a line caret
    (CARETSTYLE_LINE=1), a block caret (CARETSTYLE_BLOCK=2) or to not draw at all
    (CARETSTYLE_INVISIBLE=0). The default value is the line caret (CARETSTYLE_LINE=1).
    You can determine the current caret style setting using <code>SCI_GETCARETSTYLE</code>.</p>
End Rem
	Method Setcaretstyle()
		SendEditor(SCI_SETCARETSTYLE)
	End Method
	

Rem
bbdoc: GETCARETSTYLE
End Rem
	Method Getcaretstyle()
		SendEditor(SCI_GETCARETSTYLE)
	End Method
	

Rem
bbdoc: SETINDICATORCURRENT
End Rem
	Method Setindicatorcurrent()
		SendEditor(SCI_SETINDICATORCURRENT)
	End Method
	

Rem
bbdoc: GETINDICATORCURRENT
End Rem
	Method Getindicatorcurrent()
		SendEditor(SCI_GETINDICATORCURRENT)
	End Method
	

Rem
bbdoc: SETINDICATORVALUE
End Rem
	Method Setindicatorvalue()
		SendEditor(SCI_SETINDICATORVALUE)
	End Method
	

Rem
bbdoc: GETINDICATORVALUE
End Rem
	Method Getindicatorvalue()
		SendEditor(SCI_GETINDICATORVALUE)
	End Method
	

Rem
bbdoc: INDICATORFILLRANGE
End Rem
	Method Indicatorfillrange()
		SendEditor(SCI_INDICATORFILLRANGE)
	End Method
	

Rem
bbdoc: INDICATORCLEARRANGE
End Rem
	Method Indicatorclearrange()
		SendEditor(SCI_INDICATORCLEARRANGE)
	End Method
	

Rem
bbdoc: INDICATORALLONFOR
End Rem
	Method Indicatorallonfor()
		SendEditor(SCI_INDICATORALLONFOR)
	End Method
	

Rem
bbdoc: INDICATORVALUEAT
End Rem
	Method Indicatorvalueat()
		SendEditor(SCI_INDICATORVALUEAT)
	End Method
	

Rem
bbdoc: INDICATORSTART
End Rem
	Method Indicatorstart()
		SendEditor(SCI_INDICATORSTART)
	End Method
	

Rem
bbdoc: INDICATOREND
End Rem
	Method Indicatorend()
		SendEditor(SCI_INDICATOREND)
	End Method
	

Rem
bbdoc: SETPOSITIONCACHE
about: <p><b id="SCI_SETPOSITIONCACHE">SCI_SETPOSITIONCACHE(int size)</b><br />
     <b id="SCI_GETPOSITIONCACHE">SCI_GETPOSITIONCACHE</b><br />
     The position cache stores position information for short runs of text
     so that their layout can be determined more quickly if the run recurs.
     The size in entries of this cache can be set with <code>SCI_SETPOSITIONCACHE</code>.</p>
End Rem
	Method Setpositioncache()
		SendEditor(SCI_SETPOSITIONCACHE)
	End Method
	

Rem
bbdoc: GETPOSITIONCACHE
End Rem
	Method Getpositioncache()
		SendEditor(SCI_GETPOSITIONCACHE)
	End Method
	

Rem
bbdoc: COPYALLOWLINE
End Rem
	Method Copyallowline()
		SendEditor(SCI_COPYALLOWLINE)
	End Method
	

Rem
bbdoc: GETCHARACTERPOINTER
about: <p><b id="SCI_GETCHARACTERPOINTER">SCI_GETCHARACTERPOINTER</b><br />
     Move the gap within Scintilla so that the text of the document is stored consecutively
     and ensure there is a NUL character after the text, then return a pointer to the first character.
     Applications may then pass this to a function that accepts a character pointer such as a regular
     expression search or a parser. The pointer should <em>not</em> be written to as that may desynchronize
     the internal state of Scintilla.</p>
End Rem
	Method Getcharacterpointer()
		SendEditor(SCI_GETCHARACTERPOINTER)
	End Method
	

Rem
bbdoc: SETKEYSUNICODE
about: <p><b id="SCI_SETKEYSUNICODE">SCI_SETKEYSUNICODE(bool keysUnicode)</b><br />
     <b id="SCI_GETKEYSUNICODE">SCI_GETKEYSUNICODE</b><br />
     On Windows, character keys are normally handled differently depending on whether Scintilla is a wide
     or narrow character window with character messages treated as Unicode when wide and as 8 bit otherwise.
     Set this property to always treat as Unicode. This option is needed for Delphi.</p>
End Rem
	Method Setkeysunicode()
		SendEditor(SCI_SETKEYSUNICODE)
	End Method
	

Rem
bbdoc: GETKEYSUNICODE
End Rem
	Method Getkeysunicode()
		SendEditor(SCI_GETKEYSUNICODE)
	End Method
	

Rem
bbdoc: INDICSETALPHA
about: <p><b id="SCI_INDICSETALPHA">SCI_INDICSETALPHA(int indicatorNumber, int alpha)</b><br />
     <b id="SCI_INDICGETALPHA">SCI_INDICGETALPHA(int indicatorNumber)</b><br />
     These two messages set and get the alpha transparency used for drawing the
     fill color of the INDIC_ROUNDBOX rectangle. The alpha value can range from
     0 (completely transparent) to 100 (no transparency).
     </p>
End Rem
	Method Indicsetalpha()
		SendEditor(SCI_INDICSETALPHA)
	End Method
	

Rem
bbdoc: INDICGETALPHA
End Rem
	Method Indicgetalpha()
		SendEditor(SCI_INDICGETALPHA)
	End Method
	

Rem
bbdoc: SETEXTRAASCENT
End Rem
	Method Setextraascent()
		SendEditor(SCI_SETEXTRAASCENT)
	End Method
	

Rem
bbdoc: GETEXTRAASCENT
End Rem
	Method Getextraascent()
		SendEditor(SCI_GETEXTRAASCENT)
	End Method
	

Rem
bbdoc: SETEXTRADESCENT
End Rem
	Method Setextradescent()
		SendEditor(SCI_SETEXTRADESCENT)
	End Method
	

Rem
bbdoc: GETEXTRADESCENT
End Rem
	Method Getextradescent()
		SendEditor(SCI_GETEXTRADESCENT)
	End Method
	

Rem
bbdoc: MARKERSYMBOLDEFINED
about: <p><b id="SCI_MARKERSYMBOLDEFINED">SCI_MARKERSYMBOLDEFINED(int markerNumber)</b><br />
     Returns the symbol defined for a markerNumber with <code>SCI_MARKERDEFINE</code> 
     or <code>SC_MARK_PIXMAP</code> if defined with <code>SCI_MARKERDEFINEPIXMAP</code>.</p>
End Rem
	Method Markersymboldefined()
		SendEditor(SCI_MARKERSYMBOLDEFINED)
	End Method
	

Rem
bbdoc: MARGINSETTEXT
End Rem
	Method Marginsettext()
		SendEditor(SCI_MARGINSETTEXT)
	End Method
	

Rem
bbdoc: MARGINGETTEXT
End Rem
	Method Margingettext()
		SendEditor(SCI_MARGINGETTEXT)
	End Method
	

Rem
bbdoc: MARGINSETSTYLE
End Rem
	Method Marginsetstyle()
		SendEditor(SCI_MARGINSETSTYLE)
	End Method
	

Rem
bbdoc: MARGINGETSTYLE
End Rem
	Method Margingetstyle()
		SendEditor(SCI_MARGINGETSTYLE)
	End Method
	

Rem
bbdoc: MARGINSETSTYLES
End Rem
	Method Marginsetstyles()
		SendEditor(SCI_MARGINSETSTYLES)
	End Method
	

Rem
bbdoc: MARGINGETSTYLES
End Rem
	Method Margingetstyles()
		SendEditor(SCI_MARGINGETSTYLES)
	End Method
	

Rem
bbdoc: MARGINTEXTCLEARALL
End Rem
	Method Margintextclearall()
		SendEditor(SCI_MARGINTEXTCLEARALL)
	End Method
	

Rem
bbdoc: MARGINSETSTYLEOFFSET
End Rem
	Method Marginsetstyleoffset()
		SendEditor(SCI_MARGINSETSTYLEOFFSET)
	End Method
	

Rem
bbdoc: MARGINGETSTYLEOFFSET
End Rem
	Method Margingetstyleoffset()
		SendEditor(SCI_MARGINGETSTYLEOFFSET)
	End Method
	

Rem
bbdoc: ANNOTATIONSETTEXT
End Rem
	Method Annotationsettext()
		SendEditor(SCI_ANNOTATIONSETTEXT)
	End Method
	

Rem
bbdoc: ANNOTATIONGETTEXT
End Rem
	Method Annotationgettext()
		SendEditor(SCI_ANNOTATIONGETTEXT)
	End Method
	

Rem
bbdoc: ANNOTATIONSETSTYLE
End Rem
	Method Annotationsetstyle()
		SendEditor(SCI_ANNOTATIONSETSTYLE)
	End Method
	

Rem
bbdoc: ANNOTATIONGETSTYLE
End Rem
	Method Annotationgetstyle()
		SendEditor(SCI_ANNOTATIONGETSTYLE)
	End Method
	

Rem
bbdoc: ANNOTATIONSETSTYLES
End Rem
	Method Annotationsetstyles()
		SendEditor(SCI_ANNOTATIONSETSTYLES)
	End Method
	

Rem
bbdoc: ANNOTATIONGETSTYLES
End Rem
	Method Annotationgetstyles()
		SendEditor(SCI_ANNOTATIONGETSTYLES)
	End Method
	

Rem
bbdoc: ANNOTATIONGETLINES
End Rem
	Method Annotationgetlines()
		SendEditor(SCI_ANNOTATIONGETLINES)
	End Method
	

Rem
bbdoc: ANNOTATIONCLEARALL
End Rem
	Method Annotationclearall()
		SendEditor(SCI_ANNOTATIONCLEARALL)
	End Method
	

Rem
bbdoc: ANNOTATIONSETVISIBLE
End Rem
	Method Annotationsetvisible()
		SendEditor(SCI_ANNOTATIONSETVISIBLE)
	End Method
	

Rem
bbdoc: ANNOTATIONGETVISIBLE
End Rem
	Method Annotationgetvisible()
		SendEditor(SCI_ANNOTATIONGETVISIBLE)
	End Method
	

Rem
bbdoc: ANNOTATIONSETSTYLEOFFSET
End Rem
	Method Annotationsetstyleoffset()
		SendEditor(SCI_ANNOTATIONSETSTYLEOFFSET)
	End Method
	

Rem
bbdoc: ANNOTATIONGETSTYLEOFFSET
End Rem
	Method Annotationgetstyleoffset()
		SendEditor(SCI_ANNOTATIONGETSTYLEOFFSET)
	End Method
	

Rem
bbdoc: ADDUNDOACTION
about: <p><b id="SCI_ADDUNDOACTION">SCI_ADDUNDOACTION(int token, int flags)</b><br />
     The container can add its own actions into the undo stack by calling 
     <code>SCI_ADDUNDOACTION</code> and an <code>SCN_MODIFIED</code> 
     notification will be sent to the container with the 
     <a class="message" href="#SC_MOD_CONTAINER"><code>SC_MOD_CONTAINER</code></a>
     flag when it is time to undo (<code>SC_PERFORMED_UNDO</code>) or 
     redo (<code>SC_PERFORMED_REDO</code>) the action. The token argument supplied is 
     returned in the <code>token</code> field of the notification.</p>
End Rem
	Method Addundoaction()
		SendEditor(SCI_ADDUNDOACTION)
	End Method
	

Rem
bbdoc: CHARPOSITIONFROMPOINT
about: <p><b id="SCI_CHARPOSITIONFROMPOINT">SCI_CHARPOSITIONFROMPOINT(int x, int y)</b><br />
     <b id="SCI_CHARPOSITIONFROMPOINTCLOSE">SCI_CHARPOSITIONFROMPOINTCLOSE(int x, int y)</b><br />
     <code>SCI_CHARPOSITIONFROMPOINT</code> finds the closest character to a point and
    <code>SCI_CHARPOSITIONFROMPOINTCLOSE</code> is similar but returns -1 if the point is outside the
    window or not close to any characters. This is similar to the previous methods but finds characters rather than 
    inter-character positions.</p>
End Rem
	Method Charpositionfrompoint()
		SendEditor(SCI_CHARPOSITIONFROMPOINT)
	End Method
	

Rem
bbdoc: CHARPOSITIONFROMPOINTCLOSE
End Rem
	Method Charpositionfrompointclose()
		SendEditor(SCI_CHARPOSITIONFROMPOINTCLOSE)
	End Method
	

Rem
bbdoc: STARTRECORD
about: <p><b id="SCI_STARTRECORD">SCI_STARTRECORD</b><br />
     <b id="SCI_STOPRECORD">SCI_STOPRECORD</b><br />
     These two messages turn macro recording on and off.</p>
End Rem
	Method Startrecord()
		SendEditor(SCI_STARTRECORD)
	End Method
	

Rem
bbdoc: STOPRECORD
End Rem
	Method Stoprecord()
		SendEditor(SCI_STOPRECORD)
	End Method
	

Rem
bbdoc: SETLEXER
about: <p><b id="SCI_SETLEXER">SCI_SETLEXER(int lexer)</b><br />
     <b id="SCI_GETLEXER">SCI_GETLEXER</b><br />
     You can select the lexer to use with an integer code from the <code>SCLEX_*</code> enumeration
    in <code>Scintilla.h</code>. There are two codes in this sequence that do not use lexers:
    <code>SCLEX_NULL</code> to select no lexing action and <code>SCLEX_CONTAINER</code> which sends
    the <code><a class="message" href="#SCN_STYLENEEDED">SCN_STYLENEEDED</a></code> notification to
    the container whenever a range of text needs to be styled. You cannot use the
    <code>SCLEX_AUTOMATIC</code> value; this identifies additional external lexers that Scintilla
    assigns unused lexer numbers to.</p>
End Rem
	Method Setlexer()
		SendEditor(SCI_SETLEXER)
	End Method
	

Rem
bbdoc: GETLEXER
End Rem
	Method Getlexer()
		SendEditor(SCI_GETLEXER)
	End Method
	

Rem
bbdoc: COLOURISE
about: <p><b id="SCI_COLOURISE">SCI_COLOURISE(int startPos, int endPos)</b><br />
     This requests the current lexer or the container (if the lexer is set to
    <code>SCLEX_CONTAINER</code>) to style the document between <code>startPos</code> and
    <code>endPos</code>. If <code>endPos</code> is -1, the document is styled from
    <code>startPos</code> to the end. If the <code>"fold"</code> property is set to
    <code>"1"</code> and your lexer or container supports folding, fold levels are also set. This
    message causes a redraw.</p>
End Rem
	Method Colourise()
		SendEditor(SCI_COLOURISE)
	End Method
	

Rem
bbdoc: SETPROPERTY
about: <p><b id="SCI_SETPROPERTY">SCI_SETPROPERTY(const char *key, const char *value)</b><br />
     You can communicate settings to lexers with keyword:value string pairs. There is no limit to
    the number of keyword pairs you can set, other than available memory. <code>key</code> is a
    case sensitive keyword, <code>value</code> is a string that is associated with the keyword. If
    there is already a value string associated with the keyword, it is replaced. If you pass a zero
    length string, the message does nothing. Both <code>key</code> and <code>value</code> are used
    without modification; extra spaces at the beginning or end of <code>key</code> are
    significant.</p>
End Rem
	Method Setproperty()
		SendEditor(SCI_SETPROPERTY)
	End Method
	

Rem
bbdoc: SETKEYWORDS
about: <p><b id="SCI_SETKEYWORDS">SCI_SETKEYWORDS(int keyWordSet, const char *keyWordList)</b><br />
     You can set up to 9 lists of keywords for use by the current lexer. This was increased from 6
    at revision 1.50. <code>keyWordSet</code> can be 0 to 8 (actually 0 to <code>KEYWORDSET_MAX</code>)
    and selects which keyword list to replace. <code>keyWordList</code> is a list of keywords
    separated by spaces, tabs, <code>"\n"</code> or <code>"\r"</code> or any combination of these.
    It is expected that the keywords will be composed of standard ASCII printing characters,
    but there is nothing to stop you using any non-separator character codes from 1 to 255
    (except common sense).</p>
End Rem
	Method Setkeywords()
		SendEditor(SCI_SETKEYWORDS)
	End Method
	

Rem
bbdoc: SETLEXERLANGUAGE
about: <p><b id="SCI_SETLEXERLANGUAGE">SCI_SETLEXERLANGUAGE(&lt;unused&gt;, const char *name)</b><br />
     This message lets you select a lexer by name, and is the only method if you are using an
    external lexer or if you have written a lexer module for a language of your own and do not wish
    to assign it an explicit lexer number. To select an existing lexer, set <code>name</code> to
    match the (case sensitive) name given to the module, for example "ada" or "python", not "Ada"
    or "Python". To locate the name for the built-in lexers, open the relevant
    <code>Lex*.cxx</code> file and search for <code>LexerModule</code>. The third argument in the
    <code>LexerModule</code> constructor is the name to use.</p>
End Rem
	Method Setlexerlanguage()
		SendEditor(SCI_SETLEXERLANGUAGE)
	End Method
	

Rem
bbdoc: LOADLEXERLIBRARY
about: <p><b id="SCI_LOADLEXERLIBRARY">SCI_LOADLEXERLIBRARY(&lt;unused&gt;, const char *path)</b><br />
     Load a lexer implemented in a shared library. This is a .so file on GTK+/Linux or a .DLL file on Windows.
     </p>
End Rem
	Method Loadlexerlibrary()
		SendEditor(SCI_LOADLEXERLIBRARY)
	End Method
	

Rem
bbdoc: GETPROPERTY
about: <p><b id="SCI_GETPROPERTY">SCI_GETPROPERTY(const char *key, char *value)</b><br />
    Lookup a keyword:value pair using the specified key; if found, copy the value to the user-supplied
    buffer and return the length (not including the terminating 0).  If not found, copy an empty string
    to the buffer and return 0.</p>
End Rem
	Method Getproperty()
		SendEditor(SCI_GETPROPERTY)
	End Method
	

Rem
bbdoc: GETPROPERTYEXPANDED
about: <p><b id="SCI_GETPROPERTYEXPANDED">SCI_GETPROPERTYEXPANDED(const char *key, char *value)</b><br />
    Lookup a keyword:value pair using the specified key; if found, copy the value to the user-supplied
    buffer and return the length (not including the terminating 0).  If not found, copy an empty string
    to the buffer and return 0.</p>
End Rem
	Method Getpropertyexpanded()
		SendEditor(SCI_GETPROPERTYEXPANDED)
	End Method
	

Rem
bbdoc: GETPROPERTYINT
about: <p><b id="SCI_GETPROPERTYINT">SCI_GETPROPERTYINT(const char *key, int default)</b><br />
    Lookup a keyword:value pair using the specified key; if found, interpret the value as an integer and return it.
    If not found (or the value is an empty string) then return the supplied default.  If the keyword:value pair is found but is not
    a number, then return 0.</p>
End Rem
	Method Getpropertyint()
		SendEditor(SCI_GETPROPERTYINT)
	End Method
	

Rem
bbdoc: GETSTYLEBITSNEEDED
about: <p><b id="SCI_GETSTYLEBITSNEEDED">SCI_GETSTYLEBITSNEEDED</b><br />
     Retrieve the number of bits the current lexer needs for styling. This should normally be the argument
     to <a class="message" href="#SCI_SETSTYLEBITS">SCI_SETSTYLEBITS</a>.
     </p>
End Rem
	Method Getstylebitsneeded()
		SendEditor(SCI_GETSTYLEBITSNEEDED)
	End Method

End Type


Function EncodeColor:Int(ColorR:Byte , ColorG:Byte , ColorB:Byte)	
	Return ColorR + (ColorG Shl 8) + (ColorB Shl 16)
End Function