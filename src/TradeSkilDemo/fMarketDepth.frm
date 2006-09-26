VERSION 5.00
Object = "{0AA335E1-8A4A-48F4-ADFF-D2FBF7CBB54B}#35.0#0"; "TradeBuildUI.ocx"
Begin VB.Form fMarketDepth 
   Caption         =   "Market Depth"
   ClientHeight    =   5505
   ClientLeft      =   375
   ClientTop       =   510
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   5505
   ScaleWidth      =   4680
   Begin TradeBuildUI.DOMDisplay DOMDisplay1 
      Height          =   3135
      Left            =   120
      TabIndex        =   0
      Top             =   240
      Width           =   4215
      _ExtentX        =   7435
      _ExtentY        =   5530
   End
End
Attribute VB_Name = "fMarketDepth"
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

'================================================================================
' Enums
'================================================================================

'================================================================================
' Types
'================================================================================

'================================================================================
' Member variables
'================================================================================

Private WithEvents mTicker As TradeBuild.Ticker
Attribute mTicker.VB_VarHelpID = -1
Private mCaption As String

'================================================================================
' Form Event Handlers
'================================================================================

Private Sub Form_Initialize()
InitCommonControls
End Sub

Private Sub Form_Load()

Me.Left = Screen.Width - Me.Width
Me.Top = Screen.Height - Me.Height

End Sub

Private Sub Form_Resize()
DOMDisplay1.Left = 0
DOMDisplay1.Top = 0
DOMDisplay1.Width = Me.ScaleWidth
DOMDisplay1.Height = Me.ScaleHeight
End Sub

Private Sub Form_Terminate()
Debug.Print "Market depth form terminated"
End Sub

Private Sub Form_Unload(cancel As Integer)
DOMDisplay1.finish
Set mTicker = Nothing
End Sub

'================================================================================
' Form Control Event Handlers
'================================================================================

Private Sub DOMDisplay1_Halted()
Me.caption = "Market depth data halted"
End Sub

Private Sub DOMDisplay1_Resumed()
Me.caption = mCaption
End Sub

'================================================================================
' mTicker Event Handlers
'================================================================================

Private Sub mTicker_Error(ev As TradeBuild.ErrorEvent)
If ev.errorCode = ApiErrorCodes.ApiErrMarketDepthNotAvailable Then
    Unload Me
End If
End Sub

'================================================================================
' Properties
'================================================================================

Public Property Let numberOfRows(ByVal value As Long)
DOMDisplay1.numberOfRows = value
End Property

Public Property Let Ticker(ByVal value As Ticker)
Set mTicker = value
mCaption = "Market depth for " & _
            mTicker.Contract.specifier.localSymbol & _
            " on " & _
            mTicker.Contract.specifier.exchange
Me.caption = mCaption
DOMDisplay1.Ticker = mTicker
End Property

'================================================================================
' Methods
'================================================================================

'================================================================================
' Helper Functions
'================================================================================

