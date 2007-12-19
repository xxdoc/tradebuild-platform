VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Processor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

''
' Description here
'
'@/

'@================================================================================
' Interfaces
'@================================================================================

Implements CollectionChangeListener

'@================================================================================
' Events
'@================================================================================

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' Constants
'@================================================================================

Private Const ProjectName                   As String = "gbd"
Private Const ModuleName                    As String = "Processor"

'@================================================================================
' Member variables
'@================================================================================

Private WithEvents mTB As TradeBuildAPI
Attribute mTB.VB_VarHelpID = -1

Private WithEvents mTicker As Ticker
Attribute mTicker.VB_VarHelpID = -1

Private WithEvents mTimeframe As Timeframe
Attribute mTimeframe.VB_VarHelpID = -1

Private mPriceFormatString As String

Private mFromDate As Date
Private mToDate As Date
Private mNumber As Long
Private mBarLength As Long
Private mBarUnits As TimePeriodUnits
Private mSessionOnly As Boolean

Private mBarStudy As Study
Private mBars As Bars

Private mBar As Bar

'@================================================================================
' Class Event Handlers
'@================================================================================

Private Sub Class_Initialize()
Set mTB = TradeBuildAPI
End Sub

'@================================================================================
' CollectionChangeListener Interface Members
'@================================================================================

Private Sub CollectionChangeListener_Change(ev As TWUtilities30.CollectionChangeEvent)

outputBar
Set mBar = ev.affectedObject

End Sub

'@================================================================================
' mTicker Event Handlers
'@================================================================================

Private Sub mTicker_Notification(ev As TWUtilities30.NotificationEvent)
gCon.writeLineToConsole "Notification " & ev.eventCode & _
                        ": " & ev.eventMessage
End Sub

Private Sub mTicker_stateChange(ev As TWUtilities30.StateChangeEvent)
If ev.state = TickerStates.TickerStateReady Then
    loaddata
End If
End Sub

'@================================================================================
' mTimeframe Event Handlers
'@================================================================================

Private Sub mTimeframe_BarsLoaded()
outputBar
Set gProcessor = Nothing
gCon.writeLineToConsole "Completed"
End Sub

'@================================================================================
' mTB Event Handlers
'@================================================================================

Private Sub mTB_Error(ev As TWUtilities30.ErrorEvent)
gCon.writeLineToConsole "Error " & ev.errorCode & _
                        ": " & ev.errorMsg
End Sub

Private Sub mTB_Notification(ev As TWUtilities30.NotificationEvent)
If ev.eventCode = ApiNotifyCodes.ApiNotifyServiceProviderError Then
    Dim spe As ServiceProviderError
    Set spe = mTB.GetServiceProviderError
    gCon.writeLineToConsole "Service provider error " & spe.errorCode & _
                            ": " & spe.message & _
                            " (" & spe.serviceProviderName & ")"
Else
    gCon.writeLineToConsole "Notification " & ev.eventCode & _
                            ": " & ev.eventMessage
End If
End Sub

'@================================================================================
' Properties
'@================================================================================

'@================================================================================
' Methods
'@================================================================================

Friend Sub startData( _
                ByVal spec As contractSpecifier, _
                ByVal fromDate As Date, _
                ByVal toDate As Date, _
                ByVal number As Long, _
                ByVal barLength As Long, _
                ByVal barUnits As TimePeriodUnits, _
                ByVal sessionOnly As Boolean)
                
Set mTicker = TradeBuildAPI.Tickers.Add(TickerOptions.TickerOptUseExchangeTimeZone)
mTicker.loadTicker spec

mFromDate = fromDate
mToDate = toDate
mNumber = number
mBarLength = barLength
mBarUnits = barUnits
mSessionOnly = sessionOnly
                
End Sub

Friend Sub stopData()
mTicker.StopTicker
End Sub


'@================================================================================
' Helper Functions
'@================================================================================

Private Sub loaddata()

mPriceFormatString = mTicker.Contract.priceFormatString

Set mTimeframe = mTicker.Timeframes.addHistorical(mBarLength, _
                                        mBarUnits, _
                                        "", _
                                        mNumber, _
                                        mFromDate, _
                                        mToDate, _
                                        Not mSessionOnly)
Set mBarStudy = mTimeframe.tradeStudy
Set mBars = mTimeframe.tradeStudy.Bars
mBars.addCollectionChangeListener Me

End Sub

Private Sub outputBar()
Dim sv As StudyValue

If mBar Is Nothing Then Exit Sub

gCon.writeString FormatTimestamp(mBar.DateTime, TimestampDateAndTimeISO8601)
gCon.writeString ","
gCon.writeString Format(mBar.openValue, mPriceFormatString)
gCon.writeString ","
gCon.writeString Format(mBar.highValue, mPriceFormatString)
gCon.writeString ","
gCon.writeString Format(mBar.lowValue, mPriceFormatString)
gCon.writeString ","
gCon.writeString Format(mBar.closeValue, mPriceFormatString)
gCon.writeString ","
sv = mBarStudy.getStudyValue("Volume", 0)
gCon.writeString CStr(sv.Value)
gCon.writeString ","
gCon.writeLine mBar.tickVolume
End Sub

Private Sub outputPrice( _
        ByRef ev As QuoteEvent, _
        ByVal tickType As String)
gCon.writeString FormatTimestamp(mTicker.TimeStamp, TimestampDateAndTimeISO8601)
gCon.writeString ","
gCon.writeString tickType
gCon.writeString ","
gCon.writeString ev.priceString
gCon.writeString ","

Select Case ev.priceChange
Case ValueChanges.ValueChangeDown
    gCon.writeString "PRICEDOWN"
Case ValueChanges.ValueChangeUp
    gCon.writeString "PRICEUP"
Case ValueChanges.ValueChangeNone
    gCon.writeString "PRICESAME"
End Select

gCon.writeLine ""
End Sub

Private Sub outputPriceAndSize( _
        ByRef ev As QuoteEvent, _
        ByVal tickType As String)
gCon.writeString FormatTimestamp(mTicker.TimeStamp, TimestampDateAndTimeISO8601)
gCon.writeString ","
gCon.writeString tickType
gCon.writeString ","
gCon.writeString ev.priceString
gCon.writeString ","
gCon.writeString CStr(ev.Size)
gCon.writeString ","

Select Case ev.priceChange
Case ValueChanges.ValueChangeDown
    gCon.writeString "PRICEDOWN"
Case ValueChanges.ValueChangeUp
    gCon.writeString "PRICEUP"
Case ValueChanges.ValueChangeNone
    gCon.writeString "PRICESAME"
End Select

gCon.writeString ","

Select Case ev.sizeChange
Case ValueChanges.ValueChangeDown
    gCon.writeString "SIZEDOWN"
Case ValueChanges.ValueChangeUp
    gCon.writeString "SIZEUP"
Case ValueChanges.ValueChangeNone
    gCon.writeString "SIZESAME"
End Select

gCon.writeLine ""
End Sub

Private Sub outputSize( _
        ByRef ev As QuoteEvent, _
        ByVal tickType As String)
gCon.writeString FormatTimestamp(mTicker.TimeStamp, TimestampDateAndTimeISO8601)
gCon.writeString ","
gCon.writeString tickType
gCon.writeString ","
gCon.writeString CStr(ev.Size)
gCon.writeString ","

Select Case ev.sizeChange
Case ValueChanges.ValueChangeDown
    gCon.writeString "SIZEDOWN"
Case ValueChanges.ValueChangeUp
    gCon.writeString "SIZEUP"
Case ValueChanges.ValueChangeNone
    gCon.writeString "SIZESAME"
End Select

gCon.writeLine ""
End Sub

