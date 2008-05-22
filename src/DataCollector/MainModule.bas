Attribute VB_Name = "MainModule"
Option Explicit

''
' Description here
'
' @remarks
' @see
'
'@/

'@================================================================================
' Interfaces
'@================================================================================

'@================================================================================
' Events
'@================================================================================

'@================================================================================
' Constants
'@================================================================================

Public Const AppName                        As String = "TradeBuild Data Collector"

Public Const AttributeNameAppConfigDefault As String = "Default"
Public Const AttributeNameAppConfigName    As String = "Name"
Public Const AttributeNameBidAskBars       As String = "WriteBidAndAskBars"
Public Const AttributeNameCurrency         As String = "Currency"
Public Const AttributeNameEnabled          As String = "Enabled"
Public Const AttributeNameExpiry           As String = "Expiry"
Public Const AttributeNameExchange         As String = "Exchange"
Public Const AttributeNameIncludeMktDepth  As String = "IncludeMarketDepth"
Public Const AttributeNameLocalSYmbol      As String = "LocalSymbol"
Public Const AttributeNameRight            As String = "Right"
Public Const AttributeNameSecType          As String = "SecType"
Public Const AttributeNameStrikePrice      As String = "StrikePrice"
Public Const AttributeNameSymbol           As String = "Symbol"

Public Const AttributeNameWriteTickData    As String = "WriteTickData"
Public Const AttributeNameWriteBarData     As String = "WriteBarData"


Public Const ConfigFileVersion             As String = "1.0"

Public Const ConfigNameAppConfig           As String = "AppConfig"
Public Const ConfigNameAppConfigs          As String = "AppConfigs"
Public Const ConfigNameTradeBuild          As String = "TradeBuild"
Public Const ConfigNameCollectionControl   As String = "CollectionControl"
Public Const ConfigNameContract            As String = "Contract"
Public Const ConfigNameContracts           As String = "Contracts"
Public Const ConfigNameContractSpecifier   As String = "ContractSpecifier"

Public Const ConfigNodeContractSpecs       As String = "Contract Specifications"
Public Const ConfigNodeServiceProviders    As String = "Service Providers"
Public Const ConfigNodeParameters          As String = "Parameters"

' command line switch indicating which configuration to load
' when the programs starts (if not specified, the default configuration
' is loaded)
Public Const SwitchConfig                   As String = "config"

Public Const SwitchSetup                    As String = "setup"

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================


'@================================================================================
' Member variables
'@================================================================================

Public gStop As Boolean

Public gLogger As Logger

Private mCLParser As CommandLineParser
Private mForm As fDataCollectorUI

Private mConfig As ConfigItem

Private mNoAutoStart As Boolean
Private mNoUI As Boolean
Private mLeftOffset As Long
Private mRightOffset As Long
Private mPosX As Single
Private mPosY As Single

Private mDataCollector As dataCollector

Private mStartTimeDescriptor As String
Private mEndTimeDescriptor As String
Private mExitTimeDescriptor As String

Private mConfigManager As ConfigManager

'@================================================================================
' Class Event Handlers
'@================================================================================

'@================================================================================
' XXXX Interface Members
'@================================================================================

'@================================================================================
' XXXX Event Handlers
'@================================================================================

'@================================================================================
' Properties
'@================================================================================

'@================================================================================
' Methods
'@================================================================================

Public Sub Main()

On Error GoTo Err

InitialiseTWUtilities

mLeftOffset = -1
mRightOffset = -1

Set mCLParser = CreateCommandLineParser(Command, " ")

If showHelp Then
    TerminateTWUtilities
    Exit Sub
End If

getLog

If setup Then
    TerminateTWUtilities
    Exit Sub
End If

mNoUI = getNoUi

If Not configure Then
    If Not mNoUI Then showConfig
    TerminateTWUtilities
    Exit Sub
End If

mStartTimeDescriptor = getStartTimeDescriptor
mEndTimeDescriptor = getEndTimeDescriptor
mExitTimeDescriptor = getExitTimeDescriptor

mNoAutoStart = getNoAutostart

If mNoUI Then
    
    gLogger.Log LogLevelNormal, "Creating data collector object"
    Set mDataCollector = CreateDataCollector(mConfig, _
                                            mStartTimeDescriptor, _
                                            mEndTimeDescriptor, _
                                            mExitTimeDescriptor)
    
    If mStartTimeDescriptor = "" Then
        gLogger.Log LogLevelNormal, "Starting data collection"
        mDataCollector.startCollection
    End If
    
    Do While Not gStop
        Wait 1000
    Loop
    
    gLogger.Log LogLevelNormal, "Data Collector program exiting"
    
    TerminateTWUtilities
    
Else
    gLogger.Log LogLevelNormal, "Creating data collector object"
    Set mDataCollector = CreateDataCollector(mConfig, _
                                            IIf(mNoAutoStart, "", mStartTimeDescriptor), _
                                            mEndTimeDescriptor, _
                                            mExitTimeDescriptor)
    
    gLogger.Log LogLevelNormal, "Creating form"
    Set mForm = createForm
End If


Exit Sub

Err:
MsgBox "Error " & Err.Number & ": " & Err.description & vbCrLf & _
        "At " & "TBQuoteServerUI" & "." & "MainModule" & "::" & "Main" & _
        IIf(Err.Source <> "", vbCrLf & Err.Source, ""), _
        , _
        "Error"


End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Function configure() As Boolean
Dim f As fConfig

On Error GoTo Err

If getConfigToLoad() Is Nothing Then
    notifyError "No configuration is available"
Else
    Set mConfig = getConfigToLoad
    configure = True
End If

Exit Function

Err:
configure = False
End Function

Private Function createForm() As fDataCollectorUI
Dim posnValue As String

Set createForm = New fDataCollectorUI

If mCLParser.Switch("posn") Then
    posnValue = mCLParser.SwitchValue("posn")
    
    If InStr(1, posnValue, ",") = 0 Then
        MsgBox "Error - posn value must be 'n,m'"
        Set createForm = Nothing
        Exit Function
    End If
    
    If Not IsNumeric(Left$(posnValue, InStr(1, posnValue, ",") - 1)) Then
        MsgBox "Error - offset from left is not numeric"
        Set createForm = Nothing
        Exit Function
    End If
    
    mPosX = Left$(posnValue, InStr(1, posnValue, ",") - 1)
    
    If Not IsNumeric(Right$(posnValue, Len(posnValue) - InStr(1, posnValue, ","))) Then
        MsgBox "Error - offset from top is not numeric"
        Set createForm = Nothing
        Exit Function
    End If
    
    mPosY = Right$(posnValue, Len(posnValue) - InStr(1, posnValue, ","))
Else
    mPosX = Int(Int(Screen.Width / createForm.Width) * Rnd)
    mPosY = Int(Int(Screen.Height / createForm.Height) * Rnd)
End If

gLogger.Log LogLevelNormal, "Form position: " & mPosX & "," & mPosY

createForm.initialise mDataCollector, _
                getConfigFilename, _
                getConfigName, _
                getNoAutostart, _
                CBool(mCLParser.Switch("showMonitor"))

createForm.Left = mPosX * createForm.Width
createForm.Top = mPosY * createForm.Height

createForm.Visible = True
End Function

Private Function getConfigFilename() As String
Static fn As String

If fn = "" Then
    
    fn = mCLParser.Arg(0)
    If fn = "" Then
        fn = GetSpecialFolderPath(FolderIdLocalAppdata) & _
                                "\TradeWright\" & _
                                AppName & _
                                "\v" & _
                                App.Major & "." & App.Minor & _
                                "\settings.xml"
    End If
End If
getConfigFilename = fn
End Function

Private Function getConfigName() As String
If mCLParser.Switch(SwitchConfig) Then
    getConfigName = mCLParser.SwitchValue(SwitchConfig)
End If
End Function

Private Function getConfigToLoad() As ConfigItem
Static configToLoad As ConfigItem

If configToLoad Is Nothing Then
    Set mConfigManager = New ConfigManager
    If Not mConfigManager.initialise(getConfigFilename) Then
        notifyError "The configuration file (" & _
                        getConfigFilename & _
                        ") is not the correct format for this program"
        Err.Raise ErrorCodes.ErrIllegalArgumentException
    End If
    
    gLogger.Log twutilities30.LogLevels.LogLevelSevere, "Configuration file: " & getConfigFilename
    
    On Error Resume Next
    Set configToLoad = getNamedConfig()
    If Err.Number <> 0 Then Exit Function
    On Error GoTo 0

End If

Set getConfigToLoad = configToLoad

End Function

Private Function getEndTimeDescriptor() As String
If mCLParser.Switch("endAt") Then
    getEndTimeDescriptor = mCLParser.SwitchValue("endAt")
End If
gLogger.Log LogLevelNormal, "End at: " & getEndTimeDescriptor
End Function

Private Function getExitTimeDescriptor() As String
If mCLParser.Switch("exitAt") Then
    getExitTimeDescriptor = mCLParser.SwitchValue("exitAt")
End If
gLogger.Log LogLevelNormal, "Exit at: " & getExitTimeDescriptor
End Function

Private Sub getLog()
Dim logFile As String

If mCLParser.Switch("Log") Then logFile = mCLParser.SwitchValue("log")

If mCLParser.Switch("LogLevel") Then DefaultLogLevel = LogLevelFromString(mCLParser.SwitchValue("LogLevel"))


If logFile = "" Then
    logFile = GetSpecialFolderPath(FolderIdLocalAppdata) & _
                        "\TradeWright\" & _
                        App.EXEName & _
                        "\v" & _
                        App.Major & "." & App.Minor & _
                        "\log.log"
End If

Set gLogger = GetLogger("")
gLogger.addLogListener CreateFileLogListener(logFile, _
                                        CreateBasicLogFormatter, _
                                        True, _
                                        False)
gLogger.Log LogLevelNormal, "Log file: " & logFile
gLogger.Log LogLevelNormal, "Log level: " & LogLevelToString(DefaultLogLevel)
End Sub

Private Function getNamedConfig() As ConfigItem
If getConfigName <> "" Then
    Set getNamedConfig = mConfigManager.appConfig(getConfigName)
    If getNamedConfig Is Nothing Then
        notifyError "The required configuration does not exist: " & getConfigName
        Err.Raise ErrorCodes.ErrIllegalArgumentException
    End If
Else
    Set getNamedConfig = mConfigManager.defaultAppConfig
End If
End Function

Private Function getNoAutostart() As Boolean
If mCLParser.Switch("noAutoStart") Then
    getNoAutostart = True
End If
gLogger.Log LogLevelNormal, "Auto start: " & Not getNoAutostart
End Function

Private Function getNoUi() As Boolean
If mCLParser.Switch("noui") Then
    getNoUi = True
End If
gLogger.Log LogLevelNormal, "Run with UI: " & Not getNoUi
End Function

Private Function getStartTimeDescriptor() As String
If mCLParser.Switch("startAt") Then
    getStartTimeDescriptor = mCLParser.SwitchValue("startAt")
End If
gLogger.Log LogLevelNormal, "Start at: " & getStartTimeDescriptor
End Function

Private Sub notifyError( _
                ByVal message As String)
gLogger.Log twutilities30.LogLevels.LogLevelSevere, message
If Not mNoUI Then MsgBox message & vbCrLf & vbCrLf & "The program will close.", vbCritical, "Attention!"
End Sub

Private Function setup() As Boolean
If Not mCLParser.Switch(SwitchSetup) Then Exit Function
showConfig
setup = True
End Function

Private Sub showConfig()
Dim f As fConfig
Set f = New fConfig
f.initialise getConfigFilename, False
f.Show vbModal
End Sub

Private Function showHelp() As Boolean
Dim s As String
If mCLParser.Switch("?") Or mCLParser.NumberOfSwitches = 0 Then
    s = vbCrLf & _
            "datacollector26 [configfilename]" & vbCrLf & _
            "                /setup " & vbCrLf & _
            "   or " & vbCrLf & _
            "datacollector26 [configfilename] " & vbCrLf & _
            "                [/config:configtoload] " & vbCrLf & _
            "                [/log:filename] " & vbCrLf & _
            "                [/posn:offsetfromleft,offsetfromtop]" & vbCrLf & _
            "                [/noAutoStart" & vbCrLf & _
            "                [/noUI]" & vbCrLf & _
            "                [/showMonitor]" & vbCrLf & _
            "                [/exitAt:[day]hh:mm]" & vbCrLf & _
            "                [/startAt:[day]hh:mm]" & vbCrLf & _
            "                [/endAt:[day]hh:mm]" & vbCrLf & _
            "                [/loglevel:levelName]" & vbCrLf
    s = s & vbCrLf & _
            "  where" & vbCrLf & _
            vbCrLf & _
            "    levelname is one of:" & vbCrLf & _
            "       None    or 0" & vbCrLf & _
            "       Severe  or S" & vbCrLf & _
            "       Warning or W" & vbCrLf & _
            "       Info    or I" & vbCrLf & _
            "       Normal  or N" & vbCrLf & _
            "       Detail  or D" & vbCrLf & _
            "       Medium  or M" & vbCrLf & _
            "       High    or H" & vbCrLf & _
            "       All     or A"
    s = s & vbCrLf & _
            "Example 1:" & vbCrLf & _
            "   datacollector26 /setup" & vbCrLf & _
            "       runs the data collector configurator, which enables you to define " & vbCrLf & _
            "       various configurations for use with different data collector " & vbCrLf & _
            "       instances. The default configuration file is used to store this" & vbCrLf & _
            "       information." & vbCrLf & _
            "Example 2:" & vbCrLf & _
            "   datacollector26 mysettings.xml /config:""US Futures""" & vbCrLf & _
            "       runs the data collector in accordance with the configuration" & vbCrLf & _
            "       called ""US Futures"" defined in the mysettings.xml file."
    MsgBox s, , "Usage"
    showHelp = True
End If
End Function

