VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{793BAAB8-EDA6-4810-B906-E319136FDF31}#210.0#0"; "TradeBuildUI2-6.ocx"
Object = "{38911DA0-E448-11D0-84A3-00DD01104159}#1.1#0"; "COMCT332.OCX"
Begin VB.Form fChart 
   ClientHeight    =   6780
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   12525
   LinkTopic       =   "Form1"
   ScaleHeight     =   6780
   ScaleWidth      =   12525
   StartUpPosition =   3  'Windows Default
   Begin TradeBuildUI26.MultiChart MultiChart1 
      Height          =   6135
      Left            =   0
      TabIndex        =   2
      Top             =   330
      Width           =   12525
      _ExtentX        =   22093
      _ExtentY        =   10821
   End
   Begin MSComctlLib.ImageList ImageList1 
      Left            =   11400
      Top             =   840
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   16
      ImageHeight     =   16
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   4
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "fChart.frx":0000
            Key             =   ""
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "fChart.frx":015A
            Key             =   ""
         EndProperty
         BeginProperty ListImage3 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "fChart.frx":05AC
            Key             =   ""
         EndProperty
         BeginProperty ListImage4 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "fChart.frx":0706
            Key             =   ""
         EndProperty
      EndProperty
   End
   Begin ComCtl3.CoolBar CoolBar1 
      Align           =   1  'Align Top
      Height          =   330
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   12525
      _ExtentX        =   22093
      _ExtentY        =   582
      BandCount       =   2
      _CBWidth        =   12525
      _CBHeight       =   330
      _Version        =   "6.7.9782"
      Child1          =   "ChartToolsToolbar"
      MinWidth1       =   1710
      MinHeight1      =   330
      Width1          =   1710
      NewRow1         =   0   'False
      Child2          =   "ChartNavToolbar1"
      MinWidth2       =   6585
      MinHeight2      =   330
      Width2          =   6585
      NewRow2         =   0   'False
      Begin TradeBuildUI26.ChartNavToolbar ChartNavToolbar1 
         Height          =   330
         Left            =   2160
         TabIndex        =   3
         Top             =   0
         Width           =   10305
         _ExtentX        =   18177
         _ExtentY        =   582
      End
      Begin MSComctlLib.Toolbar ChartToolsToolbar 
         Height          =   330
         Left            =   180
         TabIndex        =   1
         Top             =   0
         Width           =   1710
         _ExtentX        =   3016
         _ExtentY        =   582
         ButtonWidth     =   609
         ButtonHeight    =   582
         Appearance      =   1
         Style           =   1
         ImageList       =   "ImageList1"
         _Version        =   393216
         BeginProperty Buttons {66833FE8-8583-11D1-B16A-00C0F0283628} 
            NumButtons      =   6
            BeginProperty Button1 {66833FEA-8583-11D1-B16A-00C0F0283628} 
               Key             =   "studies"
               Object.ToolTipText     =   "Manage the studies displayed on the chart"
               ImageIndex      =   1
            EndProperty
            BeginProperty Button2 {66833FEA-8583-11D1-B16A-00C0F0283628} 
               Style           =   3
            EndProperty
            BeginProperty Button3 {66833FEA-8583-11D1-B16A-00C0F0283628} 
               Key             =   "selection"
               Description     =   "Select a chart object"
               ImageIndex      =   2
            EndProperty
            BeginProperty Button4 {66833FEA-8583-11D1-B16A-00C0F0283628} 
               Style           =   3
            EndProperty
            BeginProperty Button5 {66833FEA-8583-11D1-B16A-00C0F0283628} 
               Key             =   "lines"
               Object.ToolTipText     =   "Draw lines"
               ImageIndex      =   3
            EndProperty
            BeginProperty Button6 {66833FEA-8583-11D1-B16A-00C0F0283628} 
               Key             =   "fib"
               Object.ToolTipText     =   "Draw Fibonacci retracement lines"
               ImageIndex      =   4
            EndProperty
         EndProperty
      End
   End
End
Attribute VB_Name = "fChart"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Option Explicit

'================================================================================
' Description
'================================================================================
'
'

'================================================================================
' Interfaces
'================================================================================

'================================================================================
' Events
'================================================================================

'================================================================================
' Constants
'================================================================================

Private Const ModuleName                        As String = "fChart"

Private Const ChartToolsCommandStudies          As String = "studies"
Private Const ChartToolsCommandSelection        As String = "selection"
Private Const ChartToolsCommandLines            As String = "lines"
Private Const ChartToolsCommandFib              As String = "fib"

Private Const ConfigSettingHistorical           As String = "&Historical"

'================================================================================
' Enums
'================================================================================

'================================================================================
' Types
'================================================================================

'================================================================================
' Member variables
'================================================================================

Private WithEvents mTicker As Ticker
Attribute mTicker.VB_VarHelpID = -1

Private mSymbol As String

Private mCurrentBid As String
Private mCurrentAsk As String
Private mCurrentTrade As String
Private mCurrentVolume As Long
Private mCurrentHigh As String
Private mCurrentLow As String
Private mPreviousClose As String

Private mIsHistorical As Boolean

Private WithEvents mChartController As ChartController
Attribute mChartController.VB_VarHelpID = -1

Private mCurrentTool As IChartTool

Private mConfig As ConfigurationSection

'================================================================================
' Class Event Handlers
'================================================================================

Private Sub Form_Activate()
Dim failpoint As Long
On Error GoTo Err

syncStudyPicker

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="Form_Activate", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub Form_Load()
Dim failpoint As Long
On Error GoTo Err

Resize

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="Form_Load", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub Form_QueryUnload(cancel As Integer, UnloadMode As Integer)

Dim failpoint As Long
On Error GoTo Err

MultiChart1.Finish
If mIsHistorical Then
    Dim lTicker As Ticker
    Set lTicker = mTicker
    Set mTicker = Nothing
    lTicker.StopTicker
End If
gUnsyncStudyPicker

Select Case UnloadMode
Case QueryUnloadConstants.vbFormControlMenu
    ' the chart has been closed by the user so remove it from the config
    If Not mConfig Is Nothing Then mConfig.Remove
Case QueryUnloadConstants.vbFormCode, _
        QueryUnloadConstants.vbAppWindows, _
        QueryUnloadConstants.vbAppTaskManager, _
        QueryUnloadConstants.vbFormMDIForm, _
        QueryUnloadConstants.vbFormOwner
    If Not mConfig Is Nothing Then updateSettings
End Select

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="Form_QueryUnload", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub Form_Resize()
Dim failpoint As Long
On Error GoTo Err

Resize

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="Form_Resize", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub Form_Terminate()
gLogger.Log LogLevelDetail, "Chart form terminated"
End Sub

'================================================================================
' Control Event Handlers
'================================================================================

Private Sub ChartToolsToolbar_ButtonClick(ByVal Button As MSComctlLib.Button)

Dim failpoint As Long
On Error GoTo Err

If MultiChart1.Count = 0 Then Exit Sub

Select Case Button.Key
Case ChartToolsCommandStudies
    gShowStudyPicker MultiChart1.ChartManager, _
                    mSymbol & _
                    " (" & MultiChart1.timePeriod.ToString & ")"
Case ChartToolsCommandSelection
    setSelectionMode
Case ChartToolsCommandLines
    createLineChartTool
Case ChartToolsCommandFib
    createFibChartTool
End Select

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="ChartToolsToolbar_ButtonClick", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub CoolBar1_HeightChanged(ByVal NewHeight As Single)
Resize
End Sub

Private Sub MultiChart1_Change(ev As TWUtilities30.ChangeEvent)
Dim changeType As MultiChartChangeTypes
Dim failpoint As Long
On Error GoTo Err

changeType = ev.changeType
Select Case changeType
Case MultiChartSelectionChanged
    If MultiChart1.Count > 0 Then
        ChartToolsToolbar.Enabled = True
        Set mChartController = MultiChart1.BaseChartController
        
        setCaption
        setSelectionButton
        syncStudyPicker
    Else
        setCaption
        ChartToolsToolbar.Enabled = False
        Set mChartController = Nothing
    End If
    Set mCurrentTool = Nothing
Case MultiChartAdd

Case MultiChartRemove
    gUnsyncStudyPicker
Case MultiChartTimeframeChanged
    If MultiChart1.Count > 0 Then Set mChartController = MultiChart1.BaseChartController
    setCaption
    setSelectionButton
    syncStudyPicker
End Select

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="MultiChart1_Change", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub MultiChart1_ChartStateChanged(ByVal index As Long, ev As TWUtilities30.StateChangeEvent)
Dim loadingText As Text

Dim failpoint As Long
On Error GoTo Err

Select Case ev.State
Case ChartStateBlank

Case ChartStateCreated

Case ChartStateInitialised
    Set loadingText = MultiChart1.loadingText(index)
    loadingText.Box = True
    loadingText.BoxFillWithBackgroundColor = True
    loadingText.BoxThickness = 1
    loadingText.BoxStyle = LineInvisible
    loadingText.Color = vbYellow
    loadingText.Font.Size = 16
    loadingText.Font.Italic = True
    loadingText.Align = AlignBottomCentre
    loadingText.position = MultiChart1.PriceRegion(index).NewPoint(50, 0.2, CoordsRelative, CoordsDistance)
    loadingText.Text = "Fetching historical data"
Case ChartStateLoading
    Set loadingText = MultiChart1.loadingText(index)
    loadingText.Color = vbGreen
    loadingText.Text = "Loading historical data"
Case ChartStateLoaded

End Select

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="MultiChart1_ChartStateChanged", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

'================================================================================
' mChartController Event Handlers
'================================================================================

Private Sub mChartController_PointerModeChanged()
Dim failpoint As Long
On Error GoTo Err

setSelectionButton

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mChartController_PointerModeChanged", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

'================================================================================
' mTicker Event Handlers
'================================================================================

Private Sub mTicker_ask(ev As QuoteEvent)
Dim failpoint As Long
On Error GoTo Err

mCurrentAsk = GetFormattedPriceFromQuoteEvent(ev)
setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mTicker_ask", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub mTicker_bid(ev As QuoteEvent)
Dim failpoint As Long
On Error GoTo Err

mCurrentBid = GetFormattedPriceFromQuoteEvent(ev)
setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mTicker_bid", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub mTicker_high(ev As QuoteEvent)
Dim failpoint As Long
On Error GoTo Err

mCurrentHigh = GetFormattedPriceFromQuoteEvent(ev)
setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mTicker_high", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub mTicker_Low(ev As QuoteEvent)
Dim failpoint As Long
On Error GoTo Err

mCurrentLow = GetFormattedPriceFromQuoteEvent(ev)
setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mTicker_Low", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub mTicker_previousClose(ev As QuoteEvent)
Dim failpoint As Long
On Error GoTo Err

mPreviousClose = GetFormattedPriceFromQuoteEvent(ev)
setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mTicker_previousClose", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub mTicker_stateChange( _
                ByRef ev As TWUtilities30.StateChangeEvent)
Dim failpoint As Long
On Error GoTo Err

If ev.State = TickerStates.TickerStateReady Then
    mSymbol = mTicker.Contract.specifier.localSymbol
    setCaption
ElseIf ev.State = TickerStates.TickerStateStopped Then
    ' the ticker has been stopped before the chart has been closed,
    ' so remove the chart from the config and close it
    MultiChart1.Finish
    mConfig.Remove
    Set mConfig = Nothing
    Unload Me
End If

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mTicker_stateChange", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub mTicker_trade(ev As QuoteEvent)
Dim failpoint As Long
On Error GoTo Err

mCurrentTrade = GetFormattedPriceFromQuoteEvent(ev)
setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mTicker_trade", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

Private Sub mTicker_volume(ev As QuoteEvent)
Dim failpoint As Long
On Error GoTo Err

mCurrentVolume = ev.Size
setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=False, pLog:=True, pProcedureName:="mTicker_volume", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
gHandleFatalError
End Sub

'================================================================================
' Properties
'================================================================================

'================================================================================
' Methods
'================================================================================

Friend Function LoadFromConfig( _
                ByVal config As ConfigurationSection) As Boolean
Dim failpoint As Long
On Error GoTo Err

Set mConfig = config
mIsHistorical = CBool(mConfig.GetSetting(ConfigSettingHistorical, "False"))
If Not MultiChart1.LoadFromConfig(mConfig.GetConfigurationSection(ConfigSectionMultiChart)) Then
    LoadFromConfig = False
    Exit Function
End If

ChartNavToolbar1.initialise , MultiChart1

Set mTicker = MultiChart1.Ticker
If Not mIsHistorical Then getInitialTickerValues

setCaption
setWindow

LoadFromConfig = True

Exit Function

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="LoadFromConfig", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Function

Friend Sub showChart( _
                ByVal pTicker As Ticker, _
                ByVal chartspec As ChartSpecifier)

Dim failpoint As Long
On Error GoTo Err

mIsHistorical = False

Set mTicker = pTicker

getInitialTickerValues

If Not mTicker.ReplayingTickfile Then setConfig

MultiChart1.initialise mTicker, chartspec, , , New DunniganFactory
MultiChart1.Add chartspec.Timeframe

ChartNavToolbar1.initialise , MultiChart1

setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="showChart", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Friend Sub showHistoricalChart( _
                ByVal pTicker As Ticker, _
                ByVal chartspec As ChartSpecifier, _
                ByVal fromtime As Date, _
                ByVal totime As Date)

Dim failpoint As Long
On Error GoTo Err

mIsHistorical = True

Set mTicker = pTicker

setConfig

MultiChart1.initialise mTicker, chartspec, fromtime, totime, New DunniganFactory
MultiChart1.Add chartspec.Timeframe

ChartNavToolbar1.initialise , MultiChart1
setCaption

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="showHistoricalChart", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

'================================================================================
' Helper Functions
'================================================================================

Private Sub createFibChartTool()
Dim ls As LineStyle
Dim lineSpecs(4) As FibLineSpecifier

Dim failpoint As Long
On Error GoTo Err

Set ls = New LineStyle
ls.Extended = True
ls.IncludeInAutoscale = False

ls.Color = vbBlack
Set lineSpecs(0).Style = ls.Clone
lineSpecs(0).Percentage = 0

ls.Color = vbRed
Set lineSpecs(1).Style = ls.Clone
lineSpecs(1).Percentage = 100

ls.Color = &H8000&   ' dark green
Set lineSpecs(2).Style = ls.Clone
lineSpecs(2).Percentage = 50

ls.Color = vbBlue
Set lineSpecs(3).Style = ls.Clone
lineSpecs(3).Percentage = 38.2

ls.Color = vbMagenta
Set lineSpecs(4).Style = ls.Clone
lineSpecs(4).Percentage = 61.8

Set mCurrentTool = CreateFibRetracementTool(mChartController, lineSpecs, LayerNumbers.LayerHighestUser)
MultiChart1.SetFocus

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="createFibChartTool", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub createLineChartTool()
Dim ls As LineStyle

Dim failpoint As Long
On Error GoTo Err

Set ls = New LineStyle
ls.Extended = True
ls.ExtendAfter = True
ls.IncludeInAutoscale = False

Set mCurrentTool = CreateLineTool(mChartController, ls, LayerBackground)
MultiChart1.SetFocus

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="createLineChartTool", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub getInitialTickerValues()
Dim failpoint As Long
On Error GoTo Err

If mTicker.State <> TickerStateRunning Then Exit Sub

mSymbol = mTicker.Contract.specifier.localSymbol
mCurrentBid = mTicker.FormatPrice(mTicker.BidPrice)
mCurrentTrade = mTicker.FormatPrice(mTicker.TradePrice)
mCurrentAsk = mTicker.FormatPrice(mTicker.AskPrice)
mCurrentVolume = mTicker.Volume
mCurrentHigh = mTicker.FormatPrice(mTicker.HighPrice)
mCurrentLow = mTicker.FormatPrice(mTicker.LowPrice)
mPreviousClose = mTicker.FormatPrice(mTicker.ClosePrice)

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="getInitialTickerValues", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub Resize()
Dim failpoint As Long
On Error GoTo Err

If Me.WindowState = FormWindowStateConstants.vbMinimized Then Exit Sub

MultiChart1.Width = Me.ScaleWidth
If Me.ScaleHeight >= CoolBar1.Height Then
    MultiChart1.Height = Me.ScaleHeight - CoolBar1.Height
    MultiChart1.Top = CoolBar1.Height
End If

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="Resize", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub setCaption()
Dim s As String

Dim failpoint As Long
On Error GoTo Err

If MultiChart1.Count = 0 Then
    s = mSymbol
Else
    s = mSymbol & " (" & MultiChart1.timePeriod.ToString & ")"
End If
    
If mIsHistorical Then
    s = s & _
        "    (historical)"
Else
    s = s & _
        "    B=" & mCurrentBid & _
        "  T=" & mCurrentTrade & _
        "  A=" & mCurrentAsk & _
        "  V=" & mCurrentVolume & _
        "  H=" & mCurrentHigh & _
        "  L=" & mCurrentLow & _
        "  C=" & mPreviousClose
End If
Me.caption = s

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="setCaption", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub setConfig()
Dim failpoint As Long
On Error GoTo Err

Set mConfig = gAppInstanceConfig.GetConfigurationSection(ConfigSectionCharts).AddConfigurationSection(ConfigSectionChart & "(" & GenerateGUIDString & ")")
mConfig.SetSetting ConfigSettingHistorical, CStr(mIsHistorical)
updateSettings
MultiChart1.ConfigurationSection = mConfig.AddConfigurationSection(ConfigSectionMultiChart)

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="setConfig", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub setSelectionMode()
Dim failpoint As Long
On Error GoTo Err

If mChartController.PointerMode <> PointerModeSelection Then
    mChartController.SetPointerModeSelection
    ChartToolsToolbar.buttons("selection").value = tbrPressed
Else
    mChartController.SetPointerModeDefault
    ChartToolsToolbar.buttons("selection").value = tbrUnpressed
End If

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="setSelectionMode", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub setSelectionButton()
Dim failpoint As Long
On Error GoTo Err

If mChartController.PointerMode = PointerModeSelection Then
    ChartToolsToolbar.buttons("selection").value = tbrPressed
Else
    ChartToolsToolbar.buttons("selection").value = tbrUnpressed
End If

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="setSelectionButton", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub setWindow()
Dim failpoint As Long
On Error GoTo Err

Me.Width = CLng(mConfig.GetSetting(ConfigSettingWidth, Me.Width / Screen.TwipsPerPixelX)) * Screen.TwipsPerPixelX
Me.Height = CLng(mConfig.GetSetting(ConfigSettingHeight, Me.Height / Screen.TwipsPerPixelY)) * Screen.TwipsPerPixelY
Me.left = CLng(mConfig.GetSetting(ConfigSettingLeft, Rnd * (Screen.Width - Me.Width) / Screen.TwipsPerPixelX)) * Screen.TwipsPerPixelX
Me.Top = CLng(mConfig.GetSetting(ConfigSettingTop, Rnd * (Screen.Height - Me.Height) / Screen.TwipsPerPixelY)) * Screen.TwipsPerPixelY

Select Case mConfig.GetSetting(ConfigSettingWindowstate, WindowStateNormal)
Case WindowStateMaximized
    Me.WindowState = FormWindowStateConstants.vbMaximized
Case WindowStateMinimized
    Me.WindowState = FormWindowStateConstants.vbMinimized
Case WindowStateNormal
    Me.WindowState = FormWindowStateConstants.vbNormal
End Select

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="setWindow", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub syncStudyPicker()
Dim failpoint As Long
On Error GoTo Err

If MultiChart1.Count = 0 Then Exit Sub
gSyncStudyPicker MultiChart1.ChartManager, _
                "Study picker for " & mSymbol & _
                " (" & MultiChart1.timePeriod.ToString & ")"

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="syncStudyPicker", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub

Private Sub updateSettings()
Dim failpoint As Long
On Error GoTo Err

Select Case Me.WindowState
Case FormWindowStateConstants.vbMaximized
    mConfig.SetSetting ConfigSettingWindowstate, WindowStateMaximized
Case FormWindowStateConstants.vbMinimized
    mConfig.SetSetting ConfigSettingWindowstate, WindowStateMinimized
Case FormWindowStateConstants.vbNormal
    mConfig.SetSetting ConfigSettingWindowstate, WindowStateNormal
    mConfig.SetSetting ConfigSettingWidth, Me.Width / Screen.TwipsPerPixelX
    mConfig.SetSetting ConfigSettingHeight, Me.Height / Screen.TwipsPerPixelY
    mConfig.SetSetting ConfigSettingLeft, Me.left / Screen.TwipsPerPixelX
    mConfig.SetSetting ConfigSettingTop, Me.Top / Screen.TwipsPerPixelY
End Select

Exit Sub

Err:
HandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:="updateSettings", pNumber:=Err.Number, pSource:=Err.Source, pDescription:=Err.Description, pProjectName:=ProjectName, pModuleName:=ModuleName, pFailpoint:=failpoint
End Sub


