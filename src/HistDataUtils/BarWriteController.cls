VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "BarWriter"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
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

Implements DeferredAction

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

Private Const ModuleName                            As String = "BarWriter"

Private Const OneMillisec                           As Date = 1# / (86400000#)

'@================================================================================
' Member variables
'@================================================================================

Private WithEvents mBar                             As Bar
Attribute mBar.VB_VarHelpID = -1
Private mBarType                                    As BarTypes

Private mTimePeriod                                 As TimePeriod

Private mSaveIntervalSeconds                        As Long

Private mDeferredWriteInProgress                    As Boolean

Private mLastWriteTime                              As Date

Private mSelfRef                                    As Object

Private mLocalSymbol                                As String

Private mBarWriter                                  As IBarWriter

'@================================================================================
' Class Event Handlers
'@================================================================================

'@================================================================================
' DeferredAction Interface Members
'@================================================================================

Private Sub DeferredAction_Run(ByVal Data As Variant)
Const ProcName As String = "DeferredAction_Run"
On Error GoTo Err

mDeferredWriteInProgress = False
WriteBar
mLastWriteTime = GetTimestamp
Set mSelfRef = Nothing

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' mBar Event Handlers
'@================================================================================

Private Sub mBar_Changed(ev As ChangeEventData)
Const ProcName As String = "mBar_Changed"
On Error GoTo Err

If mDeferredWriteInProgress Then Exit Sub

Dim lDeferInterval As Long
lDeferInterval = calculateDeferralTime

If lDeferInterval = 0 Then
    WriteBar
Else
    DeferAction Me, , lDeferInterval
    mDeferredWriteInProgress = True
End If

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

'@================================================================================
' Properties
'@================================================================================

'@================================================================================
' Methods
'@================================================================================

Friend Sub Finish()
Const ProcName As String = "Finish"
On Error GoTo Err

If mDeferredWriteInProgress Then Set mSelfRef = Me

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub Initialise( _
                ByVal pBar As Bar, _
                ByVal pBarType As BarTypes, _
                ByVal pTimePeriod As TimePeriod, _
                ByVal pLocalSymbol As String, _
                ByVal pSaveIntervalSeconds As Long, _
                ByVal pBarWriter As IBarWriter)
Const ProcName As String = "Initialise"
On Error GoTo Err

Set mBar = pBar
mBarType = pBarType
Set mTimePeriod = pTimePeriod
mLocalSymbol = pLocalSymbol
mSaveIntervalSeconds = pSaveIntervalSeconds
Set mBarWriter = pBarWriter

If Not mBar.Blank Then
    DeferAction Me, , 10 + Int(Rnd * 20)
    mDeferredWriteInProgress = True
End If

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Function calculateDeferralTime() As Long
Const ProcName As String = "calculateDeferralTime"
On Error GoTo Err

Dim lNextWriteTime As Date
lNextWriteTime = mLastWriteTime + OneMillisec * IIf(mSaveIntervalSeconds = 0, 10 + Int(Rnd * 20), mSaveIntervalSeconds * 1000 + Int(Rnd * 20))

Dim lTimestamp As Date
lTimestamp = GetTimestamp
If lNextWriteTime > lTimestamp Then
    calculateDeferralTime = Int((lNextWriteTime - lTimestamp) / OneMillisec)
Else
    calculateDeferralTime = 0
End If

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Sub WriteBar()
Const ProcName As String = "WriteBar"
On Error GoTo Err

' because of the delayed writes, the TimeframeHandler may have been Finished between
' initiating the write timer and getting here, so check for this
If mBarWriter Is Nothing Then Exit Sub

If gLogger.IsLoggable(LogLevelHighDetail) Then
    gLogger.Log "Write bar for  " & mLocalSymbol & _
                    ": " & mTimePeriod.ToString & _
                    " type " & mBarType & " bar " & mBar.BarNumber & _
                    mBar.ToString, _
                ProcName, ModuleName
End If

mBarWriter.WriteBar mBar, mBarType, mTimePeriod

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub
