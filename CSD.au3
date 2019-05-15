;~ Consolidate Data v0.9
;~ Find, combine and display all occurrences of years, publishers(manufacturers) and categories(genres)
;~ on your Attract Mode romlists, showing which systems and games are using them. It will also allow you
;~ to change and standardize the data across the emulators and games.
;~
;~ Copyright (C) 2018 - Fred Rique (farique) https://github.com/farique1

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=CSD.ico
#AutoIt3Wrapper_Outfile_x64=..\Consolidate Data\CSD.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Math.au3>
#include <Misc.au3>
#include <String.au3>
#include <ArrayUnique.au3>
#include <GuiListView.au3>
#include <GuiComboBox.au3>

#Region Variables
Local $_ifReplGui = 9999, $_ibRCancel = 9999, $_icWarn = 9999, $_icRefL = 9999, $_icClse = 9999
Local $_ibRGo = 9999, $_icRFind= 9999, $_icRRepl = 9999, $hDLL = DllOpen("user32.dll")
Local $aSysCfg[0], $aRomLists, $aTemp, $nData = 0
Local $aList[0][0], $aDYar[0][3], $aDCat[0][3], $aDPub[0][3], $aSearchA[0]
;~ Local $hColor1 = 0xededff, $hColor2 = 0xe6e6ff
Local $hColor1 = 0xedf3ff, $hColor2 = 0xe6edff
;~ Local $hColor1 = 0x2f6fba, $hColor2 = 0xe40a598
;~ Local $hColor1 = 0xe1efff, $hColor2 = 0xee5fffc
Local $sIndex = "All Syatems"
Local $bSaved = True, $bGetAmount = True, $bDidChange = False, $bShowSums = False
Local $bNoWarn = False,  $bRNoClose = False,  $bRNoRefresh = False, $nScanQty = 1
Local $aRet
Local $bDEBUG = false
Local $sSystem = ""

$amPath = IniRead ( "Data\CSD.ini", "Paths", "Attract Mode", "") ; "F:\FrontEnd\attract-v2.3.0-win64" )
if not FileExists($amPath) Then $amPath = ""
#EndRegion

#Region GUI
$_ifMainGui = GUICreate("Consolidate Data", 330, 600,-1,-1, BitOR($GUI_SS_DEFAULT_GUI,$WS_MAXIMIZEBOX,$WS_SIZEBOX,$WS_THICKFRAME,$WS_TABSTOP,$WS_EX_MDICHILD))
$_icSystem = GUICtrlCreateCombo("All Systems", 8, 12, 120, 17)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT)
GUICtrlSetTip(-1, "The system to show")
$_icDataTyp = GUICtrlCreateCombo("", 138, 12, 110, 21)
GUICtrlSetData(-1, "Year|Publisher|Category", "Year")
GUICtrlSetResizing(-1, $GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT)
GUICtrlSetTip(-1, "The data type to show")
$_ilItens = GUICtrlCreateLabel("No items", 258, 16, 60, 15, $SS_RIGHT)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT)
GUICtrlSetTip(-1, "The amount of items on this list")
$_ilList = GUICtrlCreateListView("Data|System|Qty", 8, 38, 314, 424, BitOR($LBS_NOTIFY,$WS_VSCROLL))
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKTOP+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_LV_ALTERNATE)
GUICtrlSetBkColor(-1, $hColor1)
;~ _GUICtrlListView_SetExtendedListViewStyle(-1, BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT))
_GUICtrlListView_SetColumnWidth(-1, 0, 170)
_GUICtrlListView_SetColumnWidth(-1, 1, 85)
$_ilTotal = GUICtrlCreateLabel("No total", 260, 472, 60, 15, $SS_RIGHT)
GUICtrlSetResizing(-1, $GUI_DOCKRIGHT+$GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKWIDTH)
GUICtrlSetTip(-1, "The sum of the items on this list")
GUICtrlCreateLabel("", 4, 467, 15, 30, $SS_RIGHT) ;  < Alt lupa
GUICtrlSetFont(-1, 12, 00, "", "Segoe UI Symbol")
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKWIDTH+$GUI_DOCKLEFT)
$_ibClrSrch = GUICtrlCreateButton("X", 230, 467, 23, 23)
;~ GUICtrlSetFont(-1, 20, 00, "", "Segoe UI Symbol")
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKWIDTH+$GUI_DOCKRIGHT)
$_ieSearch = GUICtrlCreateInput("", 24, 468, 202, 21)
GUICtrlSetResizing(-1, $GUI_DOCKLEFT+$GUI_DOCKBOTTOM+$GUI_DOCKRIGHT+$GUI_DOCKHEIGHT)
GUICtrlSetTip(-1, "Refine search on this list (press enter to search)")
if $bDEBUG Then
	$_ilDEBUG = GUICtrlCreateLabel(StringLeft($amPath, StringLen($amPath)/2)&@CRLF&StringRight($amPath, StringLen($amPath)/2+1), 88, 510, 153, 66)
	GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKWIDTH+$GUI_DOCKHEIGHT)
	GUICtrlSetColor (-1, 0xff0000)
EndIf
GUICtrlCreatePic("Data\Logo.gif", 169, 500, 153, 34)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKWIDTH+$GUI_DOCKRIGHT+$GUI_DOCKHEIGHT)
$_ibAMPath = GUICtrlCreateButton("AM Path", 8, 510, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKLEFT)
GUICtrlSetTip(-1, "Point to the Attract Mode folder"&@CRLF&"Current: "&$amPath)
$_ibRescan = GUICtrlCreateButton("Rescan", 8, 540, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKLEFT)
GUICtrlSetTip(-1, "Rescan the data using the current path")
GUICtrlSetState(-1,$GUI_DISABLE)
;~ $_ibSave = GUICtrlCreateButton("Save", 8, 570, 75, 25)
;~ GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKLEFT)
;~ GUICtrlSetState(-1,$GUI_DISABLE)
;~ GUICtrlSetTip(-1, "Save the data currently on memory")
$_icQty = GUICtrlCreateCheckbox("No Qty", 10, 569, 75, 25)
GUICtrlSetState(-1, $GUI_UNCHECKED)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKLEFT)
GUICtrlSetTip(-1, "Scan data without quantities. Faster.")
$_ibShowSum = GUICtrlCreateButton("Show Sums", 88, 510, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT)
GUICtrlSetState(-1,$GUI_DISABLE)
GUICtrlSetTip(-1, "Show the items quantity sum across the systems")
$_ibShowGames = GUICtrlCreateButton("Show Games", 88, 540, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT)
GUICtrlSetState(-1,$GUI_DISABLE)
GUICtrlSetTip(-1, "Show the games using the selected data")
$_ibReplace = GUICtrlCreateButton("Change", 88, 570, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT)
GUICtrlSetState(-1,$GUI_DISABLE)
GUICtrlSetTip(-1, "Change the selected data on all system on this list"&@CRLF&"CAUTION: WILL edit your AM romlists")
$_ibCopyList = GUICtrlCreateButton("Copy", 168, 540, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT)
GUICtrlSetTip(-1, "Copy this list to the clipboard")
$_ibExportList = GUICtrlCreateButton("Export", 168, 570, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT)
GUICtrlSetTip(-1, "Save this list")
$_ibCLists = GUICtrlCreateButton("Backup Lists", 248, 540, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKRIGHT)
GUICtrlSetState(-1,$GUI_DISABLE)
GUICtrlSetTip(-1, "Make a local copy of the AM romlists")
$_ibHelp = GUICtrlCreateButton("Help", 248, 570, 75, 25)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKRIGHT)
GUICtrlCreateLabel("v1.0", 10, 494, -1, 12,$SS_left)
GUICtrlSetColor(-1, 0xbbbbbb)
GUICtrlSetResizing(-1, $GUI_DOCKBOTTOM+$GUI_DOCKHCENTER+$GUI_DOCKVCENTER+$GUI_DOCKHEIGHT+$GUI_DOCKWIDTH+$GUI_DOCKLEFT)
GUISetState(@SW_SHOW)

GUIRegisterMsg($WM_SIZING, "_WM_SIZING")
#EndRegion

#Region Initialize
$nScanQty = IniRead ( "Data\CSD.ini", "Checks", "Scan Quantities", 1)
if $nScanQty = 0 then GUICtrlSetState($_icQty, $GUI_CHECKED)

if $amPath <> "" Then
	GetSave()
	FillList()
	GUICtrlSetState($_ibRescan, $GUI_ENABLE)
	GUICtrlSetState($_ibCLists, $GUI_ENABLE)
	GUICtrlSetState($_ibShowSum, $GUI_ENABLE)
	GUICtrlSetState($_ibShowGames, $GUI_ENABLE)
	GUICtrlSetState($_ibReplace, $GUI_ENABLE)
EndIf

_GUICtrlListView_RegisterSortCallBack($_ilList, 1)
#EndRegion

#Region Main
While 1
	$nMsg = GUIGetMsg(1)
	Switch $nMsg[1]
		Case $_ifMainGui
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE
					Quit()
				Case $_ilList
					_GUICtrlListView_SortItems($_ilList, GUICtrlGetState($_ilList))
					$nCount = _GUICtrlListView_GetItemCount($_ilList)
				Case $_icDataTyp
					FillList()
				Case $_icSystem
					FillList()
				Case $_ibAMPath
					AMPath()
				Case $_ibRescan
;~ 					$nScanQty = (_IsPressed("10", $hDLL)) ? (False) : (True)
					$nScanQty = (_IsChecked($_icQty)) ? (0) : (1)
					Rescan()
				Case $_icQty
					$nScanQty = (_IsChecked($_icQty)) ? (0) : (1)
					ConsoleWrite($nScanQty&@CRLF)
;~ 				Case $_ibSave
;~ 					Save()
				Case $_ibShowSum
					ShowSum()
				Case $_ibShowGames
					ShowGames()
				Case $_ibReplace
					ReplaceReqester()
				Case $_ieSearch
					FillList()
				Case $_ibClrSrch
					GUICtrlSetData($_ieSearch, "")
					FillList()
				Case $_ibCLists
					BackupLists()
				Case $_ibHelp
					If FileExists("Readme.txt") Then
						Run("notepad.exe " & "Readme.txt")
					Else
						MsgBox($MB_SYSTEMMODAL, "File not found", "Readme.txt was not found.")
					EndIf
				Case $_ibCopyList
					dim $aTemp[0][2]
					$aTemp = _GUICtrlListView_CreateArray($_ilList)
					_ArrayDelete($aTemp,0)
					_ArrayToClip($aTemp,"|")
					ToolTip("Copied")
					Sleep(500)
					ToolTip("")
				Case $_ibExportList
					$aTemp = _GUICtrlListView_CreateArray($_ilList)
					_ArrayDelete($aTemp,0)
					$sData = GetDataName($nData)
					$sFile = FileSaveDialog("Save "&$sIndex&" "&$sData&" data", _
											"", "Text (*.txt)", 0, $sIndex&" "&$sData&" data"&".txt")
					_FileWriteFromArray($sFile, $aTemp)
			EndSwitch
		Case $_ifReplGui
			Switch $nMsg[0]
				Case $GUI_EVENT_CLOSE, $_ibRCancel
					GUIDelete($_ifReplGui)
					DisabeMainInterface($GUI_ENABLE)
					if $bDidChange Then
						if $bRNoRefresh = false Then Rescan()
					Else
						ControlFocus("", "", $_ilList)
					EndIf
				Case $_icClse
					if GUICtrlread($_icClse) = $GUI_CHECKED Then
						if $bNoWarn = false Then MsgBox(48, "Warinig","This is potentially dangerous, be careful."&@CRLF& _
																	  "The data will be outdated and different from your romlists."&@CRLF& _
																	  "Only do this if you know what you are doing. (cuz I don't)")
						$bRNoClose = True
					Else
						$bRNoClose = False
					EndIf
				Case $_icRefL
					if GUICtrlread($_icRefL) = $GUI_CHECKED Then
						if $bNoWarn = false Then MsgBox(48, "Warinig","This is potentially dangerous, be careful."&@CRLF& _
																	  "The data will be outdated and different from your romlists."&@CRLF& _
																	  "Only do this if you know what you are doing. (cuz I don't)")
						$bRNoRefresh = True
					Else
						$bRNoRefresh = False
					EndIf
				Case $_icWarn
					if GUICtrlread($_icWarn) = $GUI_CHECKED Then
						MsgBox(48, "One last warinig", "Why would you do that?"&@CRLF&"Warnings are good. Warnings are safe")
						$bNoWarn = True
					Else
						$bNoWarn = False
					EndIf
;~ 					$bNoWarn = (GUICtrlread($_icWarn) = $GUI_CHECKED) ? (True):(False)
				Case $_ibRGo
					if 	GUICtrlRead($_icRFind) = "" Then
						ToolTip("Field blank")
						Sleep(500)
						ToolTip("")
					Else
						ReplaceActual()
					EndIf
			EndSwitch
	EndSwitch
wend
#EndRegion

Func GetSave()
;~ 	if FileExists("Data\Year.dat") and FileExists("Data\Category.dat") and FileExists("Data\Publisher.dat") and FileExists("Data\Systems.dat") Then
;~ 		_FileReadToArray("Data\Systems.dat", $aSysCfg)
;~ 		_FileReadToArray("Data\Year.dat", $aDYar, 0,"|")
;~ 		_FileReadToArray("Data\Category.dat", $aDCat, 0,"|")
;~ 		_FileReadToArray("Data\Publisher.dat", $aDPub, 0,"|")
;~ 		_ArrayDelete($aSysCfg,0)
;~ 		for $f = 0 to UBound($aSysCfg)-1
;~ 			GUICtrlSetData($_icSystem, $aSysCfg[$f])
;~ 		Next
;~ 	Else
		$sExists = IniRead("Data\CSD.ini", "Paths", "Attract Mode", "")
		if FileExists($sExists & "\attract.exe") Then
			GetSystems()
			ReadData()
		endif
;~ 	EndIf
EndFunc

Func GetSystems()
	Dim $aSysCfg[0]
	$aRomLists = _FileListToArray ($amPath&"\romlists", "*.txt", 1)
	for $f=1 to UBound($aRomLists)-1
		_ArrayAdd($aSysCfg, StringTrimRight($aRomLists[$f],4))
	next
;~ 	_FileWriteFromArray("Data\Systems.dat", $aSysCfg)
EndFunc

Func ReadData() ; Pegar a Lista como uma array 2D (como no AMLS) para ver qual mais rápido

	$t = TimerInit()
	$nSize = 0
	$nSysQty = UBound($aSysCfg)
	for $f = 0 to $nSysQty-1 ; lê romlist de todos os sistemas
		_FileReadToArray( $amPath&"\romlists\"&$aSysCfg[$f]&".txt", $aTemp)
		$nSize += UBound($aTemp)-2 ; soma os tamanhos (-2 por conta da primeira linha com tamanho da array e segunda com o cabeçalho da lista)
	Next

	Dim $aDYar[0][3]
	Dim $aDCat[0][3]
	Dim $aDPub[0][3]

	$nProgress = 0
	ProgressOn("Reading data", "System", "0%", -1, -1, BitOR($DLG_NOTONTOP, $DLG_MOVEABLE))

	for $f = 0 to $nSysQty-1 ; faz todos os sistemas

		$sSystem = $aSysCfg[$f]
		GUICtrlSetData($_icSystem, $sSystem) ; coloca no combo box o nome do sistema atual
		ConsoleWrite("--- "&$sSystem&@CRLF)

;~ 		_FileReadToArray($amPath & "\romlists\" & $sSystem & ".txt", $aList,0,";") ; le a romlist do sistema atual
		_FileReadToArray($amPath & "\romlists\" & $sSystem & ".txt", $aList)
		Dim $aDYarTmp[UBound($aList)-2][3]
		Dim $aDCatTmp[UBound($aList)-2][3]
		Dim $aDPubTmp[UBound($aList)-2][3]

		ConsoleWrite("Size "&UBound($aList)-1&@CRLF)

		#cs - usando $aList 2D
		for $c = 2 to UBound($aList)-1
;~ 			$aTemp = _StringBetween($aList[$c], ";", ";")
			$aDYarTmp[$c-2][0]=$aList[$c][3]
			$aDYarTmp[$c-2][1]=$sSystem
			$aDPubTmp[$c-2][0]=$aList[$c][4]
			$aDPubTmp[$c-2][1]=$sSystem
			$aDCatTmp[$c-2][0]=$aList[$c][5]
			$aDCatTmp[$c-2][1]=$sSystem
			$nProgress += 1
			ProgressSet($nProgress/$nSize*100, Int($nProgress/$nSize*100)&" %", $sSystem)
		Next
		#ce

		$nProgress = Int(($f+1)/($nSysQty)*100)
		ProgressSet($nProgress, $f+1&" of "&$nSysQty, "Reading "&$sSystem)
		for $c = 2 to UBound($aList)-1
			$aTemp = _StringBetween($aList[$c], ";", ";")
			$aDYarTmp[$c-2][0]=$aTemp[3]
			$aDYarTmp[$c-2][1]=$sSystem
			$aDPubTmp[$c-2][0]=$aTemp[4]
			$aDPubTmp[$c-2][1]=$sSystem
			$aDCatTmp[$c-2][0]=$aTemp[5]
			$aDCatTmp[$c-2][1]=$sSystem
		Next

		if $nScanQty = 1 Then
			ProgressSet($nProgress, $f+1&" of "&$nSysQty, "Counting "&$sSystem)
			GetAmount($aDYarTmp)
			GetAmount($aDPubTmp)
			GetAmount($aDCatTmp)
		EndIf

		_ArrayConcatenate($aDYar, $aDYarTmp)
		_ArrayConcatenate($aDPub, $aDPubTmp)
		_ArrayConcatenate($aDCat, $aDCatTmp)

		ConsoleWrite("Year "&UBound($aDYarTmp)&" - "&UBound($aDYar)&@CRLF)
		ConsoleWrite("Pblr "&UBound($aDPubTmp)&" - "&UBound($aDPub)&@CRLF)
		ConsoleWrite("Ctgr "&UBound($aDCatTmp)&" - "&UBound($aDCat)&@CRLF)
	Next

	ProgressSet(100, "", "Sorting")

	$aDYar = ArrayUnique($aDYar)
	$aDCat = ArrayUnique($aDCat)
	$aDPub = ArrayUnique($aDPub)

	_ArraySort($aDYar)
	_ArraySort($aDCat)
	_ArraySort($aDPub)

	ConsoleWrite(@CRLF&"Time - "&TimerDiff($t)&@CRLF)

	ProgressOff()
;~ 	GUICtrlSetState($_ibSave,$GUI_ENABLE)
;~ 	$bSaved = False
EndFunc

Func FillList()
	$bShowSums = False

	GuiSetState(@SW_LOCK)

	_GUICtrlListView_DeleteAllItems ( $_ilList )

	$nItens = 0
	$nData = _GUICtrlComboBox_GetCurSel($_icDataTyp)

	if $nData = 0 Then PopulateList($aDYar, 0, $nItens)
	if $nData = 1 Then PopulateList($aDPub, 1, $nItens)
	if $nData = 2 Then PopulateList($aDCat, 2, $nItens)

;~ 	GUICtrlSetData($_ilItens, $nItens&" items")

	GuiSetState(@SW_UNLOCK)
EndFunc

Func PopulateList($aInput, $nData, ByRef $nItens)

	$sData = GetDataName($nData)
	$sSearchBox = GUICtrlRead($_ieSearch)
	$sIndex = GUICtrlRead($_icSystem)
	$nSum = 0

	GUICtrlSetData($_ilList, $sData&"|System")
	for $f = 0 to UBound($aInput)-1
		if $sSearchBox = "" or StringInStr($aInput[$f][0], $sSearchBox) > 0 Then
			if $sIndex = "All Systems" Then
				GUICtrlCreateListViewItem( $aInput[$f][0]&"|"&$aInput[$f][1]&"|"&$aInput[$f][2], $_ilList)
				GUICtrlSetBkColor(-1, $hColor2)
				$nItens += 1
				$nSum += $aInput[$f][2]
			Else
				if $aInput[$f][1] = $sIndex Then
					GUICtrlCreateListViewItem( $aInput[$f][0]&"|"&$aInput[$f][1]&"|"&$aInput[$f][2], $_ilList)
					GUICtrlSetBkColor(-1, $hColor2)
					$nItens += 1
					$nSum += $aInput[$f][2]
				EndIf
			EndIf
		EndIf
	next
	if $nSum > 0 Then
		GUICtrlSetData($_ilTotal, "Total "&$nSum)
	Else
		GUICtrlSetData($_ilTotal, "No total")
	EndIf
	if $nItens > 0 Then
		GUICtrlSetData($_ilItens, $nItens&" items")
	Else
		GUICtrlSetData($_ilItens, "No items")
	EndIf
EndFunc

Func AMPath()
	$sPath = FileSelectFolder("Attact Mode Path", $amPath)
	if $sPath <> "" Then
		if FileExists($sPath&"\attract.exe") Then
			$amPath = $sPath
			GUICtrlSetTip($_ibAMPath, "Point to the Attract Mode folder"&@CRLF&"Current: "&$amPath)
			Rescan()
			GUICtrlSetState($_ibRescan, $GUI_ENABLE)
			GUICtrlSetState($_ibCLists, $GUI_ENABLE)
			GUICtrlSetState($_ibShowSum, $GUI_ENABLE)
			GUICtrlSetState($_ibShowGames, $GUI_ENABLE)
			GUICtrlSetState($_ibReplace, $GUI_ENABLE)
		Else
;~ 			$amPath = ""
;~ 			GUICtrlSetTip($_ibAMPath, $amPath)
			MsgBox(0, "Error", "Attract Mode not found")
;~ 			GUICtrlSetState($_ibRescan, $GUI_DISABLE)
;~ 			GUICtrlSetState($_ibCLists, $GUI_DISABLE)
;~ 			GUICtrlSetState($_ibShowSum, $GUI_DISABLE)
;~ 			GUICtrlSetState($_ibShowGames, $GUI_DISABLE)
;~ 			GUICtrlSetState($_ibReplace, $GUI_DISABLE)
		EndIf
	EndIf
	if $bDEBUG Then
		GUICtrlSetData ($_ilDEBUG, StringLeft($amPath, StringLen($amPath)/2)&@CRLF&StringRight($amPath, StringLen($amPath)/2+1))
	EndIf
EndFunc

Func Rescan()

	if FileExists($amPath&"\attract.exe") Then

		$sTmpSys = GUICtrlRead($_icSystem)
		$sTmpDat = GUICtrlRead($_icDataTyp)

		GetSystems()
		ReadData()

		_GUICtrlComboBox_SelectString($_icSystem, $sTmpSys)
		_GUICtrlComboBox_SelectString($_icDataTyp, $sTmpDat)
		FillList()
	Else
		MsgBox(0, "Error", "Attract Mode not found")
	EndIf

EndFunc

;~ Func Save()
;~ 	_FileWriteFromArray("Data\Systems.dat", $aSysCfg)
;~ 	_FileWriteFromArray("Data\Year.dat", $aDYar)
;~ 	_FileWriteFromArray("Data\Category.dat", $aDCat)
;~ 	_FileWriteFromArray("Data\Publisher.dat", $aDPub)
;~ 	$bSaved = True
;~ 	GUICtrlSetState($_ibSave,$GUI_DISABLE)
;~ EndFunc

Func Quit()
;~ 	if $bSaved = false Then
;~ 		$nButton = MsgBox(3,"Save Data", "There seems to be unsaved data"&@CRLF&"Do you wish to save?")
;~ 		if $nButton = 6 then
;~ 			Save()
;~ 			_GUICtrlListView_UnRegisterSortCallBack($_ilList)
;~ 			Exit
;~ 		ElseIf $nButton = 2 then
;~ 			Return
;~ 		Else
;~ 			_GUICtrlListView_UnRegisterSortCallBack($_ilList)
;~ 			Exit
;~ 		EndIf
;~ 	Else
		_GUICtrlListView_UnRegisterSortCallBack($_ilList)
		IniWrite("Data\CSD.ini", "Paths", "Attract Mode", $amPath)
		IniWrite("Data\CSD.ini", "Checks", "Scan Quantities", $nScanQty)
		Exit
;~ 	EndIf
EndFunc

Func ShowGames(); Pegar a Lista como uma array 2D (como no AMLS) para ver qual mais rápido

;~ 	if $bShowSums Then
;~ 		ToolTip("Cannot do on sums list")
;~ 		Sleep(500)
;~ 		ToolTip("")
;~ 		Return
;~ 	EndIf

	Dim $aSearchA[0]
	Dim $aFound[0][3]
	$aItemIdx = _GUICtrlListView_GetSelectedIndices($_ilList, True)

	if UBound($aItemIdx) > 1 Then

		$aItemDat = _GUICtrlListView_GetItem($_ilList, $aItemIdx[1], 0)
		$aItemSys = _GUICtrlListView_GetItem($_ilList, $aItemIdx[1], 1)
		$aTemp = _GUICtrlListView_CreateArray($_ilList)
		$sSearchDat = $aItemDat[3]
		_ArrayDelete($aTemp,0)
		_ArrayColDelete($aTemp, 2)

		$aResult = _ArrayFindAll($aTemp, $sSearchDat, 0, 0, 1)
		for $f = 0 to UBound($aResult)-1
			ConsoleWrite($aResult[$f]&" - "& $aTemp[$aResult[$f]][1]&@CRLF)
			_ArrayAdd($aSearchA, $aTemp[$aResult[$f]][1])
		Next

		if $bShowSums Then
			$aSearchA = $aSysCfg
		EndIf

		ConsoleWrite(@CRLF)
		for $f = 0 to UBound($aSearchA)-1
			_FileReadToArray($amPath&"\romlists\"&$aSearchA[$f]&".txt", $aList)
			for $c = 2 to UBound($aList)-1
				$aEntry = StringSplit($aList[$c], ";")
				if $aEntry[$nData+5] == $sSearchDat Then
					ConsoleWrite($aEntry[$nData+5]&" - "&$aEntry[1]&" - "&$aEntry[2]&" - "&$aEntry[3]&" - "&$aSearchA[$f]&@CRLF)
					_ArrayAdd($aFound, $aEntry[1]&"|"&$aEntry[2]&"|"&$aSearchA[$f])
				EndIf
			Next
		Next

		$sData = GetDataName($nData)
		_ArrayDisplay($aFound, $sData&" "&$sSearchDat, "", 64, Default, "Name|Title|System")
		ControlFocus("", "", $_ilList)

	Else
		ToolTip("No selection")
		Sleep(500)
		ToolTip("")
	EndIf
EndFunc

Func GetAmount(ByRef $aInput) ; Estudar essa forma de contar (comentada) - mais rrápida mas está errada.

	$aInput1D = _ArrayExtract($aInput, -1, -1, 0, 0)
	$aInputUnique1D = _ArrayUnique($aInput1D)

	_ArraySort($aInput1D)

	Dim $aInput[UBound($aInputUnique1D)][3]
	$nCountA = 1
	$nCountB = 0
	_ArrayAdd($aInput1D, "")
	for $f = 0 to UBound($aInput1D)-2
		if $aInput1D[$f] =  $aInput1D[$f+1] Then
			$nCountA += 1
		Else
			$aInput[$nCountB][0] = $aInput1D[$f]
			$aInput[$nCountB][1] = $sSystem
			$aInput[$nCountB][2] = $nCountA
			$nCountA = 1
			$nCountB += 1
		EndIf
	Next
EndFunc

Func ShowSum()

	if $aDYar[0][2] = "" or $aDPub[0][2] = "" or $aDCat[0][2] = "" Then
		ToolTip("No quantities to show")
		Sleep(500)
		ToolTip("")
		Return
	EndIf

	$bShowSums = True
	$nData = _GUICtrlComboBox_GetCurSel($_icDataTyp)

	if $nData = 0 Then $aInput = $aDYar
	if $nData = 1 Then $aInput = $aDPub
	if $nData = 2 Then $aInput = $aDCat

	_ArraySort($aInput)

	$aInput1D = _ArrayExtract($aInput, -1, -1, 0, 0)
	$aInputUnique1D = _ArrayUnique($aInput1D)

	Dim $aOutput[UBound($aInputUnique1D)-1][3]
	$nCountA = 0
	$nCountB = 0
	_ArrayAdd($aInput1D, "")
	for $f = 0 to UBound($aInput1D)-2
		if $aInput1D[$f] =  $aInput1D[$f+1] Then
			$nCountA += $aInput[$f][2]
		Else
			$aOutput[$nCountB][0] = $aInput[$f][0]
			$aOutput[$nCountB][1] = "All Systems"
			$aOutput[$nCountB][2] = $nCountA + $aInput[$f][2]
			$nCountA = 0
			$nCountB += 1
		EndIf
	Next

	GuiSetState(@SW_LOCK)
	GUICtrlSetData($_icSystem, "All Systems")
	_GUICtrlListView_DeleteAllItems ( $_ilList )
	$nItens = 0
	PopulateList($aOutput, $nData, $nItens)
;~ 	GUICtrlSetData($_ilItens, $nItens&" items")
	GuiSetState(@SW_UNLOCK)

;~ 	$sData = GetDataName($nData)
;~ 	_ArrayDisplay($aOutput, $sData&" All Systems", "", 64, Default, $sData&"|Qt")
EndFunc

Func ReplaceReqester()

	if $bShowSums Then
		ToolTip("Cannot do on sums list")
		Sleep(500)
		ToolTip("")
		Return
	EndIf

	DisabeMainInterface($GUI_DISABLE)

	$bDidChange = False
	$sIndex = GUICtrlRead($_icSystem)
	$sData = GetDataName($nData)

	$aItemIdx = _GUICtrlListView_GetSelectedIndices($_ilList, True)
	if UBound($aItemIdx) > 1 Then
		$aItemDat = _GUICtrlListView_GetItem($_ilList, $aItemIdx[1], 0)
		$sSearchDat = $aItemDat[3]
	Else
		$sSearchDat = ""
	EndIf

	$aTemp = _GUICtrlListView_CreateArray($_ilList)
	_ArrayDelete($aTemp, 0)
	$aRCList = _ArrayExtract($aTemp, 0, -1, 0, 0)
	$aRCList = _ArrayUnique($aRCList, 0, 0, 1, 0)
	_ArraySort($aRCList)

	$_ifReplGui = GUICreate("Change "&$sData, 330, 220,-1,-1)
	GUICtrlCreateLabel("Change the "&$sData, 8, 10, 200, 15, $SS_LEFT)
	$_icRFind = GUICtrlCreateCombo("", 8,28,314,21)
	GUICtrlCreateLabel("to the "&$sData, 8, 58, 200, 15, $SS_LEFT)
	$_icRRepl = GUICtrlCreateCombo("", 8,76,314,21)
	GUICtrlCreateLabel("on "&$sIndex&".", 8, 104, 140, 40)
	$_ibRGo = GUICtrlCreateButton("Go", 247, 137, 75, 25)
	$_ibRCancel = GUICtrlCreateButton("Cancel", 247, 187, 75, 25)

	GUICtrlCreateGroup("Caution with these",  8,132, 157,80)
	$_icClse = GUICtrlCreateCheckbox("Do not close afterwards.", 16, 150, 140, 15)
	GUICtrlSetTip(-1, "Will not close this dialog after the change"&@CRLF&"CAUTION: this can have unpredictable results")
	$_icRefL = GUICtrlCreateCheckbox("Do not refresh afterwards.", 16, 170, 140, 15)
	GUICtrlSetTip(-1, "Will not refresh the data after you close this requester"&@CRLF&"CAUTION: this can have unpredictable results")
	$_icWarn = GUICtrlCreateCheckbox("Do not show warnings.", 16, 190, 140, 15)
	GUICtrlSetTip(-1, "Will not show warnings anymore"&@CRLF&"Warnings are good. Warnings are safe")
	if $bRNoClose Then GUICtrlSetState($_icClse, $GUI_CHECKED)
	if $bRNoRefresh Then GUICtrlSetState($_icRefL, $GUI_CHECKED)
	if $bNoWarn Then GUICtrlSetState($_icWarn, $GUI_CHECKED)

	GuiCtrlSetData($_icRFind, _ArrayToString($aRCList, "|", -1, -1, "|"))
	GuiCtrlSetData($_icRRepl, _ArrayToString($aRCList, "|", -1, -1, "|"))
	_GUICtrlComboBox_SelectString($_icRFind, $sSearchDat)

	if $sSearchDat <> "" Then
		ControlFocus($_ifReplGui, "", $_icRRepl)
	Else
		ControlFocus($_ifReplGui, "", $_icRFind)
	EndIf

	GUISetState(@SW_SHOW)
EndFunc

Func ReplaceActual(); Pegar a Lista como uma array 2D (como no AMLS) para ver qual mais rápido
	if $bNoWarn = False Then
		$nButton = MsgBox(52,"Warning", "You are about to edit your Attract Mode rom lists. This action cannot be undone. Have you made a backup of them?" _
							&@CRLF&"This is a good time to back them up. Go, now!"&@CRLF&@CRLF&"Do you want to proceed anyway?")

		if $nButton = 7 Then Return

;~ 		MsgBox(64,"Note", "To speed things up after the change, the data list will be refreshed without the quantities"&@CRLF&"Press the Rescan button if you want a full scan.")
	EndIf

	$sSearchDat = GUICtrlRead($_icRFind)
	$sReplacDat = GUICtrlRead($_icRRepl)
	$sIndex = GUICtrlRead($_icSystem)
	$sData = GetDataName($nData)
	Dim $aSearchA[0]
	$nEdited = 0

	ConsoleWrite(@CRLF)
	$aResult = _ArrayFindAll($aTemp, $sSearchDat, 0, 0, 1)
	for $f = 0 to UBound($aResult)-1
		ConsoleWrite($aResult[$f]&" - "& $aTemp[$aResult[$f]][1]&@CRLF)
		_ArrayAdd($aSearchA, $aTemp[$aResult[$f]][1])
	Next

	ConsoleWrite(@CRLF)
	for $f = 0 to UBound($aSearchA)-1
;~ 		_FileReadToArray("K:\SkyDrive\Desktop\Teste\"&$aSearchA[$f]&".txt", $aList)
		_FileReadToArray($amPath&"\romlists\"&$aSearchA[$f]&".txt", $aList)
		for $c = 2 to UBound($aList)-1
			$aEntry = StringSplit($aList[$c], ";")
			if $aEntry[$nData+5] == $sSearchDat Then
;~ 				ConsoleWrite($aEntry[$nData+5]&" - "&$aEntry[1]&" - "&$aEntry[2]&" - "&$aEntry[3]&" - "&$aSearchA[$f]&@CRLF)
				ConsoleWrite(@CRLF)
				ConsoleWrite($aList[$c]&@CRLF)
				$nEdited += 1
				$aEntry[$nData+5] = $sReplacDat
				$sRReplaced = _ArrayToString($aEntry, ";", 1)
				$aList[$c] = $sRReplaced
				ConsoleWrite($aList[$c]&@CRLF)
			EndIf
		Next
;~ 		_FileWriteFromArray("K:\SkyDrive\Desktop\Teste\"&$aSearchA[$f]&".txt", $aList, 1)
		_FileWriteFromArray($amPath&"\romlists\"&$aSearchA[$f]&".txt", $aList, 1)
	Next

	if $nEdited = 0 Then
		MsgBox(48,"Error", "No instance of the "&$sData&@CRLF&$sSearchDat&@CRLF&"Was found.")
		Return
	Else
		$sSystemNamesTemp = _ArrayToString($aSearchA, @CRLF)
		MsgBox(64,"Done", $nEdited&" instances of the "&$sData&@CRLF&$sSearchDat&@CRLF&"were changed to"&@CRLF&$sReplacDat&@CRLF&"on "&@CRLF&$sSystemNamesTemp)
		$bDidChange = True
	EndIf

	if $bRNoClose = True then return

	GUIDelete($_ifReplGui)
	DisabeMainInterface($GUI_ENABLE)

	if $bRNoRefresh = False Then Rescan()


EndFunc

Func BackupLists()

	if not FileExists($amPath&"\attract.exe") Then
		ToolTip("Path not found")
		Sleep(500)
		ToolTip("")
		Return
	EndIf

	$sTempFileList = _FileListToArray("ListsBackup", "*.txt")
	for $f = 1 to UBound($sTempFileList)-1
		 FileDelete("ListsBackup\"&$sTempFileList[$f])
	next

	for $f = 0 to UBound($aSysCfg)-1
		 FileCopy($amPath&"\romlists\"&$aSysCfg[$f]&".txt", "ListsBackup\"&$aSysCfg[$f]&".txt", 1)
	next

	ToolTip("Done")
	Sleep(500)
	ToolTip("")
EndFunc

Func DisabeMainInterface($bIntStatus)
	GUICtrlSetState($_ieSearch, $bIntStatus)
	GUICtrlSetState($_icSystem, $bIntStatus)
	GUICtrlSetState($_ibAMPath, $bIntStatus)
	GUICtrlSetState($_ibRescan, $bIntStatus)
;~ 	if $bSaved = false Then
;~ 		GUICtrlSetState($_ibSave, $bIntStatus)
;~ 	Else
;~ 		GUICtrlSetState($_ibSave, $GUI_DISABLE)
;~ 	EndIf
	GUICtrlSetState($_ibCLists, $bIntStatus)
	GUICtrlSetState($_ibCopyList, $bIntStatus)
	GUICtrlSetState($_ibExportList, $bIntStatus)
	GUICtrlSetState($_ibShowSum, $bIntStatus)
	GUICtrlSetState($_ibShowGames, $bIntStatus)
	GUICtrlSetState($_ibReplace, $bIntStatus)
	GUICtrlSetState($_icDataTyp, $bIntStatus)
EndFunc

Func GetDataName($nData)
		$sData = "Year"
		if $nData = 1 Then $sData = "Publisher"
		if $nData = 2 Then $sData = "Category"
		Return $sData
EndFunc

Func _GUICtrlListView_CreateArray($hListView, $sDelimeter = '|')
    Local $iColumnCount = _GUICtrlListView_GetColumnCount($hListView), $iDim = 0, $iItemCount = _GUICtrlListView_GetItemCount($hListView)
    If $iColumnCount < 3 Then
        $iDim = 3 - $iColumnCount
    EndIf
    If $sDelimeter = Default Then
        $sDelimeter = '|'
    EndIf

    Local $aColumns = 0, $aReturn[$iItemCount + 1][$iColumnCount + $iDim] = [[$iItemCount, $iColumnCount, '']]
    For $i = 0 To $iColumnCount - 1
        $aColumns = _GUICtrlListView_GetColumn($hListView, $i)
        $aReturn[0][2] &= $aColumns[5] & $sDelimeter
    Next
    $aReturn[0][2] = StringTrimRight($aReturn[0][2], StringLen($sDelimeter))

    For $i = 0 To $iItemCount - 1
        For $j = 0 To $iColumnCount - 1
            $aReturn[$i + 1][$j] = _GUICtrlListView_GetItemText($hListView, $i, $j)
        Next
    Next
    Return SetError(Number($aReturn[0][0] = 0), 0, $aReturn)
EndFunc

Func _WM_SIZING($hWnd, $iMsg, $wParam, $lParam)
	    #forceref $iMsg, $wParam, $lParam
    If $hWnd = $_ifMainGui Then
        $aRet = ControlGetPos($_ifMainGui, "", $_ilList)
		$nPart = $aRet[2] / 3
        _GUICtrlListView_SetColumnWidth($_ilList, 0, ($nPart*2) - 40)
        _GUICtrlListView_SetColumnWidth($_ilList, 1, $nPart - 20)
    EndIf

EndFunc

Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked