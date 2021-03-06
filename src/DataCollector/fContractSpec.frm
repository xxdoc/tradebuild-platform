VERSION 5.00
Object = "{6C945B95-5FA7-4850-AAF3-2D2AA0476EE1}#307.0#0"; "TradingUI27.ocx"
Object = "{99CC0176-59AF-4A52-B7C0-192026D3FE5D}#31.0#0"; "TWControls40.ocx"
Begin VB.Form fContractSpec 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Contract specifier"
   ClientHeight    =   5445
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   4200
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5445
   ScaleWidth      =   4200
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin TWControls40.TWButton CancelButton 
      Height          =   375
      Left            =   2880
      TabIndex        =   5
      Top             =   600
      Width           =   1215
      _ExtentX        =   2143
      _ExtentY        =   661
      Caption         =   "Cancel"
      DefaultBorderColor=   15793920
      DisabledBackColor=   0
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      MouseOverBackColor=   0
      PushedBackColor =   0
   End
   Begin TWControls40.TWButton SaveButton 
      Default         =   -1  'True
      Height          =   375
      Left            =   2880
      TabIndex        =   4
      Top             =   120
      Width           =   1215
      _ExtentX        =   2143
      _ExtentY        =   661
      Caption         =   "Save"
      DefaultBorderColor=   15793920
      DisabledBackColor=   0
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      MouseOverBackColor=   0
      PushedBackColor =   0
   End
   Begin VB.CheckBox IncludeMarketDepthCheck 
      Caption         =   "Include market depth in tick data"
      Height          =   375
      Left            =   960
      TabIndex        =   3
      Top             =   4920
      Width           =   2055
   End
   Begin VB.CheckBox WriteBidAskBarsCheck 
      Caption         =   "Write bid/ask bar data"
      Height          =   375
      Left            =   960
      TabIndex        =   2
      Top             =   4560
      Width           =   2055
   End
   Begin VB.CheckBox EnabledCheck 
      Caption         =   "Collect data for this contract(s)"
      Height          =   495
      Left            =   960
      TabIndex        =   0
      Top             =   0
      Value           =   1  'Checked
      Width           =   1695
   End
   Begin TradingUI27.ContractSpecBuilder ContractSpecBuilder1 
      Height          =   3690
      Left            =   120
      TabIndex        =   1
      Top             =   600
      Width           =   2535
      _ExtentX        =   4471
      _ExtentY        =   5556
      ForeColor       =   -2147483640
      ModeAdvanced    =   -1  'True
   End
End
Attribute VB_Name = "fContractSpec"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'@================================================================================
' Interfaces
'@================================================================================

Implements IThemeable

'@================================================================================
' Events
'@================================================================================

Event ContractSpecReady( _
                ByVal contractSpec As ContractSpecifier, _
                ByVal enabled As Boolean, _
                ByVal writeBidAskBars As Boolean, _
                ByVal includeMktDepth As Boolean)

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' Constants
'@================================================================================

Private Const ModuleName                            As String = "fContractSpec"

'@================================================================================
' Member variables
'@================================================================================

Private mTheme                                      As ITheme

'@================================================================================
' Class Event Handlers
'@================================================================================

'@================================================================================
' IThemeable Interface Members
'@================================================================================

Private Property Get IThemeable_Theme() As ITheme
Set IThemeable_Theme = Theme
End Property

Private Property Let IThemeable_Theme(ByVal Value As ITheme)
Const ProcName As String = "IThemeable_Theme"
On Error GoTo Err

Theme = Value

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

'@================================================================================
' Control Event Handlers
'@================================================================================

Private Sub CancelButton_Click()
Const ProcName As String = "CancelButton_Click"
On Error GoTo Err

Unload Me

Exit Sub

Err:
UnhandledErrorHandler.Notify ProcName, ModuleName, ProjectName
End Sub

Private Sub ContractSpecBuilder1_NotReady()
Const ProcName As String = "ContractSpecBuilder1_NotReady"
On Error GoTo Err

SaveButton.enabled = False

Exit Sub

Err:
UnhandledErrorHandler.Notify ProcName, ModuleName, ProjectName
End Sub

Private Sub ContractSpecBuilder1_ready()
Const ProcName As String = "ContractSpecBuilder1_ready"
On Error GoTo Err

SaveButton.enabled = True

Exit Sub

Err:
UnhandledErrorHandler.Notify ProcName, ModuleName, ProjectName
End Sub

Private Sub SaveButton_Click()
Const ProcName As String = "SaveButton_Click"
On Error GoTo Err

RaiseEvent ContractSpecReady(ContractSpecBuilder1.ContractSpecifier, _
                            IIf(EnabledCheck.Value = vbChecked, True, False), _
                            IIf(WriteBidAskBarsCheck.Value = vbChecked, True, False), _
                            IIf(IncludeMarketDepthCheck.Value = vbChecked, True, False))

Exit Sub

Err:
UnhandledErrorHandler.Notify ProcName, ModuleName, ProjectName
End Sub

'@================================================================================
' XXXX Event Handlers
'@================================================================================

'@================================================================================
' Properties
'@================================================================================

Public Property Get contractSpec() As ContractSpecifier
Const ProcName As String = "contractSpec"
On Error GoTo Err

Set contractSpec = ContractSpecBuilder1.ContractSpecifier

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get Theme() As ITheme
Set Theme = mTheme
End Property

Public Property Let Theme(ByVal Value As ITheme)
Const ProcName As String = "Theme"
On Error GoTo Err

Set mTheme = Value
If mTheme Is Nothing Then Exit Property

Me.BackColor = mTheme.BackColor
gApplyTheme mTheme, Me.Controls

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

'@================================================================================
' Methods
'@================================================================================

Public Sub Initialise( _
                ByVal contractSpec As ContractSpecifier, _
                ByVal enabled As Boolean, _
                ByVal writeBidAskBars As Boolean, _
                ByVal includeMktDepth As Boolean)
Const ProcName As String = "Initialise"
On Error GoTo Err

If contractSpec Is Nothing Then
    ContractSpecBuilder1.Clear
Else
    ContractSpecBuilder1.ContractSpecifier = contractSpec
End If
EnabledCheck.Value = IIf(enabled, vbChecked, vbUnchecked)
WriteBidAskBarsCheck.Value = IIf(writeBidAskBars, vbChecked, vbUnchecked)
IncludeMarketDepthCheck.Value = IIf(includeMktDepth, vbChecked, vbUnchecked)

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' Helper Functions
'@================================================================================


