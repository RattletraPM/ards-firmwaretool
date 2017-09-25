#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon\icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         RattletraPM

 Script Function:
	An all-in-one tool to edit/extract/fix ARDS(i/Media Edition) firmware binaries.

#ce ----------------------------------------------------------------------------

#include <Array.au3>
#include <FileConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <MsgBoxConstants.au3>
#include <InetConstants.au3>
#include <GuiComboBox.au3>
#include "include\_Zip.au3"
#include "include\crc16_modbus.au3"

Opt("TrayIconHide",1)	;We don't need a tray icon

Global $aARFWModels[3]=["Action Replay DS/Media Edition/EZ", "Action Replay DS/EZ (alternative fw)", "Action Replay DSi"]
Global $aARFWModelsHdr[4]=["Action Replay DS/EZ", "Action Replay DS (alternative fw)", $aARFWModels[2], "Action Replay DS Media Edition"]
;Next array contents, respectively: AR2M (Regular ARDS firmware), "FIRM" (Alt. ARDS firmware), "AR09", (ARDSi firmware), "CCAR" (ARDS ME Firmware)
Global $aARFWHeaders[4]=[Binary("0x4152324D"),Binary("0x4649524D"),Binary("0x41523039"),Binary("0x43434152")]
Global $aConsoleType[2]=["Retail","Dev"]
Global $sGUISeparator="|"
Global $sGUIName="ARDS Firmware Tool"
Global $sVer="1.00"
Global $sComboBoxARFWString=$aARFWModels[0]&$sGUISeparator&$aARFWModels[1]&$sGUISeparator&$aARFWModels[2]
Global $sComboBoxARFWHdrString=$aARFWModelsHdr[0]&$sGUISeparator&$aARFWModelsHdr[1]&$sGUISeparator&$aARFWModelsHdr[2]&$sGUISeparator&$aARFWModelsHdr[3]
Global $sB9SZipPath=@TempDir&"\b9s_ntr.zip"
Global $sBlowfishRetailPath=@TempDir&"\blowfish_retail.bin"
Global $sBlowfishDevPath=@TempDir&"\blowfish_dev.bin"
Global $sIconPath=@TempDir&"\icon.gif"

FileInstall("includedfiles\blowfish_retail.bin",$sBlowfishRetailPath,1)
FileInstall("includedfiles\blowfish_dev.bin",$sBlowfishDevPath,1)
FileInstall("includedfiles\icon.gif",$sIconPath,1)

$hGUI = GUICreate($sGUIName, 450, 298, 409, 333)
$hGUITab = GUICtrlCreateTab(8, 0, 433, 289)

; - NTRBOOT EZ SECTION -
GUICtrlCreateTabItem("NTRBoot")
$hLabelQuick = GUICtrlCreateLabel("-Simple NTRBoot firmware generation-" & @CRLF & @CRLF & "This option will create a firmware file for your Action replay DS(i/ME) "& _
"with the latest version of Boot9Strap. An internet connection is required for this operation." & @CRLF & @CRLF & "If you're following the guide at 3ds.guide " & _
"to hack your console or you don't know what to choose, then you're probably looking for this option." & @CRLF & @CRLF & "Choose your Action Replay DS model " & _
'and click on "Generate firmware", then this script will take care of the rest. If you encounter any problems, check the FAQ. (This feature is for '& _
"retail consoles only, use the advanced tab for devkits.)", 16, 32, 410, 150)
$hLabelARDSModel = GUICtrlCreateLabel("Action Replay DS model:", 56, 189, 122, 17)
$hEzComboBox = GUICtrlCreateCombo("", 184, 185, 209, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, $sComboBoxARFWString, $aARFWModels[0])
$hStartBtnEz = GUICtrlCreateButton("Generate firmware", 136, 256, 169, 25)
$hProgressBarEz = GUICtrlCreateProgress(24, 214, 393, 9)
$hStatusLabelEz = GUICtrlCreateLabel("", 24, 230, 396, 17)

; - NTRBOOT ADV SECTION -
GUICtrlCreateTabItem("NTRBoot (advanced)")
$hLabelAdv = GUICtrlCreateLabel("-Advanced NTRBoot firmware generation-" & @CRLF & @CRLF & "With this option you can create NTRBoot compatible firmwares for " & _
"both devkit and retail consoles using your own FIRMs. Most users will not need this, so, unless you know what you're doing, use the Simple NTRBoot firmware " & _
"generation tab."  & @CRLF & @CRLF & "Remember to only use FIRMs that have been signed to work with NTRBoot and that match your console type setting!", 16, 32, 410, 110)
$hAdvARDSModel = GUICtrlCreateLabel("ARDS model:", 24, 196, 68, 17)
$hAdvComboBox = GUICtrlCreateCombo("", 96, 192, 209, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, $sComboBoxARFWString, $aARFWModels[0])
$hAdvBtn = GUICtrlCreateButton("Generate firmware", 136, 256, 169, 25)
$hAdvProgressBar = GUICtrlCreateProgress(24, 224, 393, 9)
$hStatusLabelAdv = GUICtrlCreateLabel("", 24, 240, 396, 17)
$hConsoleLabelAdv = GUICtrlCreateLabel("Console:", 312, 196, 45, 17)
$hComboConsoleAdv = GUICtrlCreateCombo("", 360, 192, 57, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, $aConsoleType[0]&$sGUISeparator&$aConsoleType[1], $aConsoleType[0])
$hFIRMLabelAdv = GUICtrlCreateLabel("FIRM:", 24, 164, 33, 17)
$hFIRMInputAdv = GUICtrlCreateInput("", 105, 160, 312, 21)
$hBrowseBtnAdv = GUICtrlCreateButton("...", 62, 160, 36, 21)

; - EXTRACT FW SECTION -
GUICtrlCreateTabItem("Extract firmware from ROM")
$hLabelExtract = GUICtrlCreateLabel("-Extract firmware from ROM-" & @CRLF & @CRLF & "This function is self-explainatory: choose and Action Replay ROM dump and you'll " & _
"get a firmware file that can be flashed via Code Manager. Use it if you've made a ROM dump before flashing NTRBoot and you wish to restore your Action Replay to its " & _
"previous state if no firmware file can be found online."  & @CRLF & @CRLF & "If you wish to restore an ARDS ME then you NEED to extract its firmware before doing " & _
"anything to it! (Official firmware updates will NOT restore it properly, read the FAQ for more info.)", 16, 32, 410, 150)
$hExtractBtn = GUICtrlCreateButton("Extract firmware", 136, 256, 169, 25)
$hROMLabel = GUICtrlCreateLabel("ROM:", 24, 184, 33, 17)
$hROMInput = GUICtrlCreateInput("", 105, 180, 312, 21)
$hBrowseBtnExtract = GUICtrlCreateButton("...", 62, 180, 36, 21)
$hExtractLabelARDSModel = GUICtrlCreateLabel("Action Replay DS model:", 56, 219, 122, 17)
$hExtractComboBox = GUICtrlCreateCombo("", 184, 215, 209, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, $sComboBoxARFWString, $aARFWModels[0])

; - HEADER TOOLS SECTION -
GUICtrlCreateTabItem("Header tools")
$hLabelHdr = GUICtrlCreateLabel("-Header tools-" & @CRLF & @CRLF & "A collection of functions to view and modify Action Replay firmware headers. Useful if you want to " & _
'fix the checksum of your firmwares, "convert" them to be flashed on other models or even strip the header altogheter and boot them on a flashcart.' & @CRLF & @CRLF & _
"Keep in mind that NDS files created by stripping the header are NOT proper ROM dumps and you CANNOT extract a valid firmware from them using the previous tab. " & _
'If you want to convert one of them back to a firmware file, use the "Rebuild header" function instead!', 16, 32, 410, 150)
$hFWLabel = GUICtrlCreateLabel("File:", 20, 184, 45, 17)
$hFWInput = GUICtrlCreateInput("", 108, 180, 309, 21,$ES_READONLY)
$hBrowseBtnFW = GUICtrlCreateButton("...", 65, 180, 36, 21)
$hHdrLabel = GUICtrlCreateLabel("Header:", 20, 214, 45, 17)
$hHdrInput = GUICtrlCreateInput("", 65, 210, 102, 21,$ES_READONLY)
$hHdrConvertToLabel = GUICtrlCreateLabel("Build as:", 172, 214, 45, 15)
$hHdrComboBox = GUICtrlCreateCombo("", 220, 210, 197, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, $sComboBoxARFWHdrString, $aARFWModelsHdr[0])
$hCrcLabel = GUICtrlCreateLabel("CRC:", 20, 244, 45, 17)
$hCrcInput = GUICtrlCreateInput("", 65, 240, 102, 21,$ES_READONLY)
$hCrcValidLabel = GUICtrlCreateLabel("", 172, 244, 45, 15)
$hFixCrcBtn = GUICtrlCreateButton("Fix CRC", 219, 238, 65, 25)
$hBuildHeaderBtn = GUICtrlCreateButton("Build header", 286, 238, 65, 25)
$hStripHeaderBtn = GUICtrlCreateButton("Strip header", 353, 238, 65, 25)
GUICtrlSetState($hHdrComboBox,$GUI_DISABLE)
GUICtrlSetState($hFixCrcBtn,$GUI_DISABLE)
GUICtrlSetState($hBuildHeaderBtn,$GUI_DISABLE)
GUICtrlSetState($hStripHeaderBtn,$GUI_DISABLE)

; - ABOUT SECTION -
GUICtrlCreateTabItem("About")
GUICtrlCreatePic($sIconPath, 20, 40, 64, 64)
GUICtrlCreateLabel($sGUIName, 97, 50, 500, 33)
GUICtrlSetFont(-1, 27, 780, 0, "MS Sans Serif")
GUICtrlCreateLabel("Version " & $sVer & @CRLF & @CRLF & "Made by RattletraPM" & @CRLF & @CRLF & "Credits:" & @CRLF & "* al3x_10m - for the original NTRBoot on ARDS " & _
"implementation" & @CRLF & "* stuckpixel (on #cakey) - for its tips on how to port NTRBoot" & @CRLF & "* MsbhvnFC(on /r/3dshacks) - for providing me with an official" & @CRLF & _
"Action Replay DS Media Edition firmware file" & @CRLF & "* SciresM - for Boot9Strap" & @CRLF & "* wraithdu - author of _Zip.au3" & @CRLF & _
"* roby - author of the _Crc16() function" & @CRLF & @CRLF & "https://github.com/RattletraPM/ards-firmwaretool", 97, 80, 300, 500)
GUICtrlCreateTabItem("")	;End of tab section
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			FileDelete($sBlowfishRetailPath)	;Cleanup temporary files
			FileDelete($sBlowfishDevPath)
			FileDelete($sIconPath)
			Exit
		Case $hStartBtnEz	;NTRBoot EZ firmware generation
			GUICtrlSetState($hStartBtnEz,$GUI_DISABLE)	;It's pretty horrible that I have to disable and enable the tabs (and other objects)
			GUICtrlSetState($hGUITab,$GUI_DISABLE)		;like this, but AutoIt likes it this way. Oh well... so much for code optimization.
            GUICtrlSetState($hEzComboBox,$GUI_DISABLE)
			Local $iB9SRet=DownloadB9S($sB9SZipPath)
			If $iB9SRet==1 Then Local $iFWRet=CreateFirmware(@TempDir&"\boot9strap_ntr.firm",@ScriptDir&"\ntrboot_ar.bin",GUICtrlRead($hEzComboBox),True,True)
			If $iB9SRet==1 And $iFWRet==1 Then
				GUICtrlSetData($hStatusLabelEz, "All done!")
				GUICtrlSetData($hProgressBarEz, 100)
				MsgBox(64,"Done!","NTRBoot firmware generation succesful!" & @CRLF & @CRLF & "The generated firmware file is called ntrboot_ar.bin "& _
				"and is in the same directory as this script. See the readme for info on how to flash it to your Action Replay.")
			Else
				GUICtrlSetData($hStatusLabelEz, "An error occurred")
				GUICtrlSetData($hProgressBarEz, 0)
			EndIf
			FileDelete(@TempDir&"\boot9strap_ntr.firm")
			GUICtrlSetState($hStartBtnEz,$GUI_ENABLE)
			GUICtrlSetState($hGUITab,$GUI_ENABLE)
			GUICtrlSetState($hEzComboBox,$GUI_ENABLE)
		Case $hBrowseBtnAdv
			GUICtrlSetState($hBrowseBtnAdv,$GUI_DISABLE)
			Local $sBrowse = FileOpenDialog("Choose FIRM file",@ScriptDir,"FIRM files (*.firm)",1)
			GUICtrlSetState($hBrowseBtnAdv,$GUI_ENABLE)
			GUICtrlSetData($hFIRMInputAdv, $sBrowse)
		Case $hAdvBtn	;Advanced NTRBoot firmware generation
			GUICtrlSetState($hAdvBtn,$GUI_DISABLE)
			GUICtrlSetState($hGUITab,$GUI_DISABLE)
            GUICtrlSetState($hAdvComboBox,$GUI_DISABLE)
			GUICtrlSetState($hComboConsoleAdv,$GUI_DISABLE)
			GUICtrlSetState($hBrowseBtnAdv,$GUI_DISABLE)
			GUICtrlSetState($hFIRMInputAdv,$GUI_DISABLE)
			Local $sFIRMPathRead=GUICtrlRead($hFIRMInputAdv)
			If $sFIRMPathRead=="" Then
				ErrorMsg("No FIRM file was chosen.",0)
			ElseIf FileExists($sFIRMPathRead)==0 Then
				ErrorMsg("The specified FIRM file doesn't exist.",0)
			Else
				Local $sSavePath=FileSaveDialog("Save as",@ScriptDir,"ARDS firmware files (*.bin)",16,"ntrboot_ar_custom.bin")
				If @error<>0 Then
					ErrorMsg("Aborted by user.",0)
				Else
					If GUICtrlRead($hComboConsoleAdv)==$aConsoleType[0] Then
						Local $iAdvRet=CreateFirmware($sFIRMPathRead,$sSavePath,GUICtrlRead($hAdvComboBox),True,False)
					Else
						Local $iAdvRet=CreateFirmware($sFIRMPathRead,$sSavePath,GUICtrlRead($hAdvComboBox),False,False)
					EndIf
				EndIf
				If  $iAdvRet==1 Then
					GUICtrlSetData($hStatusLabelAdv, "All done!")
					GUICtrlSetData($hAdvProgressBar, 100)
					MsgBox(64,"Done!","Custom NTRBoot firmware generation succesful!")
				Else
					GUICtrlSetData($hStatusLabelAdv, "An error occurred")
					GUICtrlSetData($hAdvProgressBar, 0)
				EndIf
			EndIf
			GUICtrlSetState($hAdvBtn,$GUI_ENABLE)
			GUICtrlSetState($hGUITab,$GUI_ENABLE)
            GUICtrlSetState($hAdvComboBox,$GUI_ENABLE)
			GUICtrlSetState($hComboConsoleAdv,$GUI_ENABLE)
			GUICtrlSetState($hBrowseBtnAdv,$GUI_ENABLE)
			GUICtrlSetState($hFIRMInputAdv,$GUI_ENABLE)
		Case $hBrowseBtnExtract
			GUICtrlSetState($hBrowseBtnExtract,$GUI_DISABLE)
			Local $sBrowseExtract = FileOpenDialog("Choose ROM file",@ScriptDir,"NDS ROM files (*.nds)",1)
			GUICtrlSetState($hBrowseBtnExtract,$GUI_ENABLE)
			GUICtrlSetData($hROMInput, $sBrowseExtract)
		Case $hExtractBtn	;Firmware extraction button
			GUICtrlSetState($hExtractBtn,$GUI_DISABLE)
			GUICtrlSetState($hGUITab,$GUI_DISABLE)
            GUICtrlSetState($hROMInput,$GUI_DISABLE)
			GUICtrlSetState($hBrowseBtnExtract,$GUI_DISABLE)
			GUICtrlSetState($hExtractComboBox,$GUI_DISABLE)
			Local $sROMPathRead=GUICtrlRead($hROMInput)
			If $sROMPathRead=="" Then
				ErrorMsg("No ROM file was chosen.",0)
			ElseIf FileExists($sROMPathRead)==0 Then
				ErrorMsg("The specified ROM file doesn't exist.",0)
			Else
				Local $sExtractSavePath=FileSaveDialog("Save as",@ScriptDir,"ARDS firmware files (*.bin)",16,"fw_extracted.bin")
				If @error<>0 Then
					ErrorMsg("Aborted by user.",0)
				Else
					ExtractFirmware($sROMPathRead,$sExtractSavePath,GUICtrlRead($hExtractComboBox))
				EndIf
			EndIf
			GUICtrlSetState($hExtractBtn,$GUI_ENABLE)
			GUICtrlSetState($hGUITab,$GUI_ENABLE)
            GUICtrlSetState($hROMInput,$GUI_ENABLE)
			GUICtrlSetState($hBrowseBtnExtract,$GUI_ENABLE)
			GUICtrlSetState($hExtractComboBox,$GUI_ENABLE)
		Case $hBrowseBtnFW	;Header tools browse button
			GUICtrlSetState($hGUITab,$GUI_DISABLE)
			GUICtrlSetState($hHdrComboBox,$GUI_DISABLE)
			GUICtrlSetState($hFixCrcBtn,$GUI_DISABLE)
			GUICtrlSetState($hBuildHeaderBtn,$GUI_DISABLE)
			GUICtrlSetState($hStripHeaderBtn,$GUI_DISABLE)
			GUICtrlSetState($hBrowseBtnFW,$GUI_DISABLE)
			Global $sHdrBrowse = FileOpenDialog("Choose firmware file",@ScriptDir,"Any file (*.*)",1)
			GUICtrlSetData($sHdrBrowse, $hFWLabel)
			If $sHdrBrowse<>"" Then
				GUICtrlSetData($hFWInput,$sHdrBrowse)
				Global $bIsFirmware=ReadHeader($sHdrBrowse)
				If $bIsFirmware==True Then
					Local $dFWChecksum=FWChecksumRead($sHdrBrowse)

					Local $hFileHdrRead=FileOpen($sHdrBrowse,$FO_BINARY)
					If $hFileHdrRead==-1 Then
						ErrorMsg("There was an error while trying to read the file.",2)
					Else
						FileSetPos($hFileHdrRead,8,$FILE_BEGIN)
						Global $dFWRealChecksum=_Crc16(FileRead($hFileHdrRead))
						FileClose($hFileHdrRead)
						If $dFWChecksum==$dFWRealChecksum Then
							GUICtrlSetData($hCrcValidLabel,"Valid!")
						Else
							GUICtrlSetData($hCrcValidLabel,"Invalid")
							GUICtrlSetState($hFixCrcBtn,$GUI_ENABLE)
						EndIf
					EndIf

					GUICtrlSetState($hHdrComboBox,$GUI_ENABLE)
					GUICtrlSetState($hBuildHeaderBtn,$GUI_ENABLE)
					GUICtrlSetData($hHdrConvertToLabel,"Rewrite:")
					GUICtrlSetData($hBuildHeaderBtn,"Write header")
					GUICtrlSetState($hStripHeaderBtn,$GUI_ENABLE)
					GUICtrlSetData($hCrcInput,$dFWChecksum)
					GUICtrlSetState($hBrowseBtnFW,$GUI_ENABLE)
					GUICtrlSetState($hGUITab,$GUI_ENABLE)
				Else
					GUICtrlSetState($hHdrComboBox,$GUI_DISABLE)
					GUICtrlSetState($hFixCrcBtn,$GUI_DISABLE)
					GUICtrlSetState($hBuildHeaderBtn,$GUI_ENABLE)
					GUICtrlSetState($hStripHeaderBtn,$GUI_DISABLE)
					GUICtrlSetData($hHdrConvertToLabel,"Build as:")
					GUICtrlSetData($hBuildHeaderBtn,"Build header")
					GUICtrlSetData($hCrcInput,"")
					GUICtrlSetState($hBrowseBtnFW,$GUI_ENABLE)
					GUICtrlSetState($hGUITab,$GUI_ENABLE)
				EndIf
			EndIf
		Case $hFixCrcBtn
			Local $hFileWriteCRC=FileOpen($sHdrBrowse,$FO_BINARY+$FO_APPEND)
			If $hFileWriteCRC==-1 Then
				ErrorMsg("There was an error while trying to write the new CRC to the firmware file.",2)
			Else
				FileSetPos($hFileWriteCRC,4,$FILE_BEGIN)
				FileWrite($hFileWriteCRC,_SwapCRCEndian($dFWRealChecksum))
				FileClose($hFileWriteCRC)
				GUICtrlSetData($hCrcValidLabel,"Valid!")
				GUICtrlSetData($hCrcInput,$dFWRealChecksum)
				GUICtrlSetState($hFixCrcBtn,$GUI_DISABLE)
			EndIf
		Case $hBuildHeaderBtn
			If $bIsFirmware==True Then
				Local $hFirmHdrWrite=FileOpen($sHdrBrowse,$FO_BINARY+$FO_APPEND)
				If $hFirmHdrWrite==-1 Then
					ErrorMsg("There was an error while trying to write the new header to the firmware file.",2)
				Else
					Local $iCurComboSel=_GUICtrlComboBox_GetCurSel($hHdrComboBox)
					Local $bWrite=True
					If $iCurComboSel==3 Then
						Local $iMsgBoxAnswer = MsgBox(52,"Warning","If you set the header to Action Replay DS ME and try to flash the firmware via Code Manager, you will probably "& _
						"PARTIALLY BRICK your ARDS! (Check the FAQ for more info)" & @CRLF & @CRLF & "Do you REALLY want to do this?")
						If $iMsgBoxAnswer == 7 Then
							ErrorMsg("Aborted.",0)
							$bWrite=False
						EndIf
					EndIf
					If $bWrite==True Then
						FileSetPos($hFirmHdrWrite,0,$FILE_BEGIN)
						FileWrite($hFirmHdrWrite,$aARFWHeaders[$iCurComboSel])
					EndIf
					FileClose($hFirmHdrWrite)
					ReadHeader($sHdrBrowse)
				EndIf
			Else
				Local $hFileBuildHdrRead=FileOpen($sHdrBrowse,$FO_BINARY)
				If $hFileBuildHdrRead==-1 Then
					ErrorMsg("There was an error while trying to read the selected file.",2)
				Else
					$dFileRead=FileRead($hFileBuildHdrRead)
					FileClose($hFileBuildHdrRead)
					Local $hFileBuildHdrWrite=FileOpen($sHdrBrowse,$FO_OVERWRITE)
					If $hFileBuildHdrWrite==-1 Then
						ErrorMsg("There was an error while trying to write the header to the selected file.",2)
					Else
						FileWrite($hFileBuildHdrWrite,$aARFWHeaders[_GUICtrlComboBox_GetCurSel($hHdrComboBox)])
						FileWrite($hFileBuildHdrWrite,_SwapCRCEndian(_Crc16($dFileRead)))
						FileSetPos($hFileBuildHdrWrite,2,$FILE_CURRENT)
						FileWrite($hFileBuildHdrWrite,$dFileRead)
						FileClose($hFileBuildHdrWrite)
						GUICtrlSetState($hBuildHeaderBtn,$GUI_DISABLE)
						MsgBox(64,"Done!","Header succesfully built!" & @CRLF & "Please reload the file to see the changes.")
					EndIf
				EndIf
			EndIf
		Case $hStripHeaderBtn
			Local $hFileReadFirmware=FileOpen($sHdrBrowse,$FO_BINARY)
			If $hFileReadFirmware==-1 Then
				ErrorMsg("There was an error while trying to read the firmware file.",2)
			Else
				Local $sNDSSavePath=FileSaveDialog("Save as",@ScriptDir,"NDS File (*.nds)",16,"fw_bootable.nds")
				If @error<>0 Then
					ErrorMsg("Aborted by user.",0)
				Else
					Local $hNDSOut=FileOpen($sNDSSavePath,$FO_BINARY+$FO_OVERWRITE)
					If $hNDSOut==-1 Then
						ErrorMsg("There was an error while trying to write the NDS file.",2)
					Else
						FileSetPos($hFileReadFirmware,8,$FILE_BEGIN)
						FileWrite($hNDSOut,FileRead($hFileReadFirmware))
						FileClose($hFileReadFirmware)
						FileClose($sNDSSavePath)
						MsgBox(64,"Done!","All done!")
					EndIf
				EndIf
			EndIf
	EndSwitch
WEnd

Func DownloadB9S($sZipFname)
	Local $sExtractFname="boot9strap_ntr.firm"
	GUICtrlSetData($hStatusLabelEz, "Fetching latest boot9strap release info")
	GUICtrlSetData($hProgressBarEz, 12)
    Local $sData=BinaryToString(InetRead("https://api.github.com/repos/SciresM/boot9strap/releases/latest", $INET_FORCERELOAD))

	Local $aDlFirmUrls = _SRE_Between($sData,'"browser_download_url":"','"',1)	;AutoIt doesn't have a JSON parser, so we'll use this instead
	If IsArray($aDlFirmUrls)<>1 Then
		ErrorMsg("There was an error while getting the download URL for the latest version of B9S.",3)
		Return -1
	EndIf

	Local $iIndex=_ArraySearch($aDlFirmUrls,"ntr.zip",0,0,0,1)
	If $iIndex==-1 Then
		ErrorMsg("Couldn't find a valid download URL for the latest version of B9S (ntrboot,retail).",3)
		Return -2
	EndIf

	GUICtrlSetData($hStatusLabelEz, "Downloading boot9strap for NTRBoot")
	GUICtrlSetData($hProgressBarEz, 24)
	InetGet($aDlFirmUrls[$iIndex], $sZipFname, $INET_FORCERELOAD)
	If FileExists($sZipFname)==0 Then
		ErrorMsg("There was an error while trying to download the latest version of B9S.",3)
		Return -3
	EndIf

	GUICtrlSetData($hStatusLabelEz, "Unzipping boot9strap")
	GUICtrlSetData($hProgressBarEz, 36)
	_Zip_Unzip($sZipFname,$sExtractFname,@TempDir)
	If FileExists(@TempDir&"\"&$sExtractFname)==0 Then
		ErrorMsg("There was an error while extracting B9S from the downloaded zip archive.",2)
		Return -4
	EndIf
	FileDelete(@TempDir&"\b9s_ntr.zip")

	Return 1
EndFunc

Func CreateFirmware($sFirmPath,$sDestination,$sARType,$bConsoleRetail,$bEzMode)
	Local $sHeader="0x4E5452424F4F54"	;"NTRBOOT"
	Local $sTempFileDir=@TempDir&"\"&"temppayload.bin"

	If $bEzMode==True Then
		GUICtrlSetData($hStatusLabelEz, "Creating payload")
		GUICtrlSetData($hProgressBarEz, 48)
	Else
		GUICtrlSetData($hStatusLabelAdv, "Creating payload")
		GUICtrlSetData($hAdvProgressBar, 16)
	EndIf

	Local $hTempFile=FileOpen($sTempFileDir,$FO_BINARY+$FO_OVERWRITE)	;It's actually faster and easier to create a temp file and then read it
	If $hTempFile==-1 Then
		ErrorMsg("There was an error while trying to create a temporary payload file.",2)
		Return -1
	EndIf
	FileWrite($hTempFile,Binary("0x4E5452424F4F54"))	;Write "NTRBOOT" to the header, just because we can and it's cool k

	If $bConsoleRetail==True Then	;Console is retail
		Local $hBlowfishRead=FileOpen($sBlowfishRetailPath,$FO_BINARY)
	Else							;Console is devkit
		Local $hBlowfishRead=FileOpen($sBlowfishDevPath,$FO_BINARY)
	EndIf
	If $hBlowfishRead==-1 Then
		ErrorMsg("There was an error while trying to read the blowfish key file.",2)
		Return -2
	EndIf

	If $bEzMode==True Then
		GUICtrlSetData($hProgressBarEz, 60)
	Else
		GUICtrlSetData($hAdvProgressBar, 32)
	EndIf

	FileSetPos($hTempFile,8192,$FILE_BEGIN)
	FileWrite($hTempFile,FileRead($hBlowfishRead,72))	;Read first 72 bytes of the blowfish key and write them to the correct offset
	FileSetPos($hTempFile,9216,$FILE_BEGIN)
	FileWrite($hTempFile,FileRead($hBlowfishRead))		;Read the rest of the blowfish key and write it to the correct offset
	FileClose($hBlowfishRead)

	If $bEzMode==True Then
		GUICtrlSetData($hProgressBarEz, 72)
	Else
		GUICtrlSetData($hAdvProgressBar, 48)
	EndIf

	If FileGetSize($sFirmPath)>1016321 Then
		ErrorMsg("The FIRM file's size is greater than 1016321 bytes.",1)
		Return -6
	EndIf

	Local $hFIRMRead=FileOpen($sFirmPath,$FO_BINARY)
	If $hFIRMRead==-1 Then
		ErrorMsg("There was an error while trying to read the FIRM file.",2)
		Return -3
	EndIf
	FileSetPos($hTempFile,32256,$FILE_BEGIN)
	FileWrite($hTempFile,FileRead($hFIRMRead))			;Read the FIRM and write it to the correct offset
	FileClose($hFIRMRead)
	FileClose($hTempFile)

	If $bEzMode==True Then
		GUICtrlSetData($hStatusLabelEz, "Calculating checksum")
		GUICtrlSetData($hProgressBarEz, 84)
	Else
		GUICtrlSetData($hStatusLabelAdv, "Calculating checksum")
		GUICtrlSetData($hAdvProgressBar, 64)
	EndIf

	Local $hReadPayload=FileOpen($sTempFileDir,$FO_BINARY)
	If $hReadPayload==-1 Then
		ErrorMsg("There was an error while trying to read the temporary file.",2)
		Return -4
	EndIf

	Local $dPayload=FileRead($hReadPayload)
	Local $dChecksum=_SwapCRCEndian(_Crc16($dPayload))
	FileClose($hReadPayload)

	If $bEzMode==True Then
		GUICtrlSetData($hStatusLabelEz, "Writing firmware file")
		GUICtrlSetData($hProgressBarEz, 95)
	Else
		GUICtrlSetData($hStatusLabelAdv, "Writing firmware file")
		GUICtrlSetData($hAdvProgressBar, 80)
	EndIf

	Local $hWriteFirmware=FileOpen($sDestination,$FO_BINARY+$FO_OVERWRITE)
	If $hWriteFirmware==-1 Then
		ErrorMsg("There was an error while trying to write the firmware file.",2)
		Return -5
	EndIf

	Switch $sARType
		Case $aARFWModels[1]	;Alt ARDS
			FileWrite($hWriteFirmware,$aARFWHeaders[1])
		Case $aARFWModels[2]	;ARDSi
			FileWrite($hWriteFirmware,$aARFWHeaders[2])
		Case Else				;Regular ARDS (put here as Case Else to avoid errors)
			FileWrite($hWriteFirmware,$aARFWHeaders[0])
	EndSwitch
	FileWrite($hWriteFirmware,$dChecksum)
	FileSetPos($hWriteFirmware,2,$FILE_CURRENT)
	FileWrite($hWriteFirmware,$dPayload)
	FileClose($hWriteFirmware)
	FileDelete($sTempFileDir)

	Return 1
EndFunc

Func ExtractFirmware($sNDSPath,$sDestFw,$sARDSModel)
	Local $sTempRebuildDir=@TempDir&"\"&"temprebuild.bin"

	If FileGetSize($sNDSPath)<1294336 Then
		ErrorMsg("The ROM is smaller than 1294336 bytes.",1)
		Return -1
	EndIf

	Local $hReadROM=FileOpen($sNDSPath,$FO_BINARY)
	If $hReadROM==-1 Then
		ErrorMsg("There was an error while trying to read the ROM.",2)
		Return -2
	EndIf

	Local $hWriteTemp=FileOpen($sTempRebuildDir,$FO_BINARY+$FO_OVERWRITE)
	If $hWriteTemp==-1 Then
		ErrorMsg("There was an error while trying to write a temporary file.",2)
		Return -3
	EndIf

	FileWrite($hWriteTemp,FileRead($hReadROM,8192))
	FileSetPos($hReadROM,1056768,$FILE_BEGIN)
	FileWrite($hWriteTemp,FileRead($hReadROM,237568))
	FileClose($hReadROM)
	FileClose($hWriteTemp)

	Local $hReadTemp=FileOpen($sTempRebuildDir,$FO_BINARY)
	If $hReadTemp==-1 Then
		ErrorMsg("There was an error while trying to read the temporary file.",2)
		Return -4
	EndIf

	Local $dHeaderlessFW=FileRead($hReadTemp)
	Local $dChecksum=_SwapCRCEndian(_Crc16($dHeaderlessFW))
	FileClose($hReadTemp)

	Local $hWriteFirmware=FileOpen($sDestFw,$FO_BINARY+$FO_OVERWRITE)
	If $hWriteFirmware==-1 Then
		ErrorMsg("There was an error while trying to write the firmware file.",2)
		Return -5
	EndIf

	Switch $sARDSModel
		Case $aARFWModels[1]	;Alt ARDS
			FileWrite($hWriteFirmware,$aARFWHeaders[1])
		Case $aARFWModels[2]	;ARDSi
			FileWrite($hWriteFirmware,$aARFWHeaders[2])
		Case Else				;Regular ARDS (put here as Case Else to avoid errors)
			FileWrite($hWriteFirmware,$aARFWHeaders[0])
	EndSwitch
	FileWrite($hWriteFirmware,$dChecksum)
	FileSetPos($hWriteFirmware,2,$FILE_CURRENT)
	FileWrite($hWriteFirmware,$dHeaderlessFW)
	FileClose($hWriteFirmware)
	FileDelete($sTempRebuildDir)

	MsgBox(64,"Done!","Firmware extraction succesful!")
EndFunc

Func FWChecksumRead($sFname)	;Modes: 0=Read only, 1=Fix
	Local $hFileReadOpen=FileOpen($sFname,$FO_BINARY)
	If $hFileReadOpen==-1 Then
		ErrorMsg("There was an error while trying to read the firmware file.",2)
		Return -1
	EndIf
	FileSetPos($hFileReadOpen,4,$FILE_CURRENT)
	Local $dChecksum=_SwapCRCEndian(FileRead($hFileReadOpen,2))
	FileClose($hFileReadOpen)
	Return $dChecksum
EndFunc

Func ReadHeader($sFname)
	Local $hFileReadOpen=FileOpen($sFname,$FO_BINARY)
	If $hFileReadOpen==-1 Then
		ErrorMsg("There was an error while trying to read the firmware file.",2)
		Return -1
	EndIf

	Local $dHeader=FileRead($hFileReadOpen,4)

	Switch	$dHeader
		Case "0x4152324D"
			GUICtrlSetData($hHdrInput,"AR2M (ARDS/EZ)")
			Return True
		Case "0x4649524D"
			GUICtrlSetData($hHdrInput,"FIRM (ARDS alt. fw)")
			Return True
		Case "0x43434152"
			GUICtrlSetData($hHdrInput,"CCAR (ARDS ME)")
			Return True
		Case "0x41523039"
			GUICtrlSetData($hHdrInput,"AR09 (ARDSi)")
			Return True
		Case Else
			GUICtrlSetData($hHdrInput,"Not a firmware file")
			Return False
	EndSwitch
EndFunc

Func _SRE_Between($s_String, $s_Start, $s_End, $i_ReturnArray = 0); $i_ReturnArray returns an array of all found if it = 1, otherwise default returns first found
    $a_Array = StringRegExp($s_String, '(?:' & $s_Start & ')(.*?)(?:' & $s_End & ')', 3)
    If Not @error And Not $i_ReturnArray And IsArray($a_Array) Then Return $a_Array[0]
    If IsArray($a_Array) Then Return $a_Array
EndFunc

Func _SwapCRCEndian($dBin)
	Return Binary("0x"&StringRight($dBin,2)&StringLeft(StringTrimLeft($dBin,2),2))
EndFunc

Func ErrorMsg($sMsg,$iType)	;Type 1 = Easily fixable error, type 2 = Read/Write/Permission error, type 3 = Inet error, else = Generic error
	Switch $iType
		Case 1
			$sFinalMsg=$sMsg&@CRLF&@CRLF&"Check the FAQ for a possible fix."
		Case 2
			$sFinalMsg=$sMsg&@CRLF&@CRLF&"This program might not have permissions to access the file/directory, try running it as administrator."
		Case 3
			$sFinalMsg=$sMsg&@CRLF&@CRLF&"You might get this error if your computer is having trouble connecting to the internet" & _
			"or if it's offline. Please go online and try again."
		Case Else
			$sFinalMsg=$sMsg
	EndSwitch
	MsgBox(16,"Error",$sFinalMsg)
EndFunc
