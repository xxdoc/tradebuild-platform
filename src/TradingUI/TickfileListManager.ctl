VERSION 5.00
Object = "{99CC0176-59AF-4A52-B7C0-192026D3FE5D}#32.0#0"; "TWControls40.ocx"
Begin VB.UserControl TickfileListManager 
   BackStyle       =   0  'Transparent
   ClientHeight    =   2805
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   6555
   ScaleHeight     =   2805
   ScaleWidth      =   6555
   Begin VB.PictureBox MeasurePicture 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   735
      Left            =   5520
      ScaleHeight     =   705
      ScaleWidth      =   825
      TabIndex        =   4
      Top             =   120
      Visible         =   0   'False
      Width           =   855
   End
   Begin TWControls40.TWButton DownButton 
      Height          =   495
      Left            =   6240
      TabIndex        =   3
      Top             =   1800
      Width           =   315
      _ExtentX        =   556
      _ExtentY        =   873
      Caption         =   "�"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Wingdings"
         Size            =   18
         Charset         =   2
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin TWControls40.TWButton RemoveButton 
      Height          =   615
      Left            =   6240
      TabIndex        =   2
      Top             =   1080
      Width           =   315
      _ExtentX        =   556
      _ExtentY        =   1085
      Caption         =   "X"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin TWControls40.TWButton UpButton 
      Height          =   495
      Left            =   6240
      TabIndex        =   1
      Top             =   480
      Width           =   315
      _ExtentX        =   556
      _ExtentY        =   873
      Caption         =   "�"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Wingdings"
         Size            =   18
         Charset         =   2
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin VB.ListBox TickFileList 
      Appearance      =   0  'Flat
      Height          =   2760
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   6255
   End
End
Attribute VB_Name = "TickfileListManager"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'@================================================================================
' Description
'@================================================================================
'
'
'@================================================================================
' Amendment history
'@================================================================================
'
'
'
'

'@================================================================================
' Interfaces
'@================================================================================

Implements IThemeable

'@================================================================================
' Events
'@================================================================================

Event TickfileCountChanged()

'@================================================================================
' Constants
'@================================================================================

Private Const ModuleName                                    As String = "TickfileListManager"

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' Member variables
'@================================================================================

Private mTickfileStore                                      As ITickfileStore

Private mTickfileSpecifiers                                 As TickfileSpecifiers

Private mSupportedTickfileFormats()                         As TickfileFormatSpecifier

Private mSupportsTickFiles                                  As Boolean
Private mSupportsTickStreams                                As Boolean

Private mMinHeight                                          As Long

Private mTheme                                              As ITheme

Private mScrollSizeNeedsSetting                             As Boolean
Private mScrollWidth                                        As Long

'@================================================================================
' Class Event Handlers
'@================================================================================

Private Sub UserControl_Initialize()
Const ProcName As String = "UserControl_Initialize"
On Error GoTo Err

mMinHeight = 8 * Screen.TwipsPerPixelY * Int((UpButton.Height + _
                        8 * Screen.TwipsPerPixelY + _
                        DownButton.Height + _
                        8 * Screen.TwipsPerPixelY + _
                        RemoveButton.Height _
                        + 8 * Screen.TwipsPerPixelY - 1) / (8 * Screen.TwipsPerPixelY))
                        

Set mTickfileSpecifiers = New TickfileSpecifiers

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

Private Sub UserControl_InitProperties()
Const ProcName As String = "UserControl_InitProperties"
On Error GoTo Err

Enabled = True

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

Private Sub UserControl_ReadProperties(PropBag As PropertyBag)
Const ProcName As String = "UserControl_ReadProperties"
On Error GoTo Err

Enabled = PropBag.ReadProperty("Enabled", True)

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

Private Sub UserControl_Resize()
Const ProcName As String = "UserControl_Resize"
On Error GoTo Err

If UserControl.Height < mMinHeight Then UserControl.Height = mMinHeight

TickFileList.Width = UserControl.Width - UpButton.Width - 8 * Screen.TwipsPerPixelX
TickFileList.Height = UserControl.Height

UpButton.Left = UserControl.Width - UpButton.Width
DownButton.Left = UserControl.Width - DownButton.Width
RemoveButton.Left = UserControl.Width - RemoveButton.Width

RemoveButton.Top = TickFileList.Height / 2 - RemoveButton.Height / 2
UpButton.Top = RemoveButton.Top - UpButton.Height - 8 * Screen.TwipsPerPixelY
DownButton.Top = RemoveButton.Top + RemoveButton.Height + 8 * Screen.TwipsPerPixelY

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

Private Sub UserControl_WriteProperties(PropBag As PropertyBag)
Const ProcName As String = "UserControl_WriteProperties"
On Error GoTo Err

Call PropBag.WriteProperty("Enabled", UserControl.Enabled, True)
    
Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

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

Private Sub DownButton_Click()
Const ProcName As String = "DownButton_Click"
On Error GoTo Err

Dim s As String
Dim d As Long
Dim i As Long

For i = TickFileList.ListCount - 2 To 0 Step -1
    If TickFileList.Selected(i) And Not TickFileList.Selected(i + 1) Then
        s = TickFileList.List(i)
        d = TickFileList.ItemData(i)
        TickFileList.RemoveItem i
        TickFileList.AddItem s, i + 1
        TickFileList.ItemData(i + 1) = d
        TickFileList.Selected(i + 1) = True
    End If
Next

setDownButton

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

Private Sub RemoveButton_Click()
Const ProcName As String = "RemoveButton_Click"
On Error GoTo Err

Dim i As Long
For i = TickFileList.ListCount - 1 To 0 Step -1
    If TickFileList.Selected(i) Then TickFileList.RemoveItem i
Next
DownButton.Enabled = False
UpButton.Enabled = False
RemoveButton.Enabled = False

mScrollWidth = 0
For i = 0 To TickFileList.ListCount - 1
    adjustScrollSize TickFileList.List(i)
Next
setScrollSize

RaiseEvent TickfileCountChanged

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

Private Sub TickFileList_Click()
Const ProcName As String = "TickFileList_Click"
On Error GoTo Err

setDownButton
setUpButton
setRemoveButton

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

Private Sub UpButton_Click()
Const ProcName As String = "UpButton_Click"
On Error GoTo Err

Dim s As String
Dim d As Long
Dim i As Long

For i = 1 To TickFileList.ListCount - 1
    If TickFileList.Selected(i) And Not TickFileList.Selected(i - 1) Then
        s = TickFileList.List(i)
        d = TickFileList.ItemData(i)
        TickFileList.RemoveItem i
        TickFileList.AddItem s, i - 1
        TickFileList.ItemData(i - 1) = d
        TickFileList.Selected(i - 1) = True
    End If
Next

setUpButton

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

'@================================================================================
' Properties
'@================================================================================

Public Property Let ListIndex(ByVal Value As Long)
Const ProcName As String = "ListIndex"
On Error GoTo Err

TickFileList.ListIndex = Value

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get ListIndex() As Long
Const ProcName As String = "ListIndex"
On Error GoTo Err

ListIndex = TickFileList.ListIndex

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Let Enabled(ByVal Value As Boolean)
Const ProcName As String = "Enabled"
On Error GoTo Err

UserControl.Enabled = Value
TickFileList.Enabled = Enabled
setUpButton
setDownButton
setRemoveButton

PropertyChanged "Enabled"

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get Enabled() As Boolean
Attribute Enabled.VB_ProcData.VB_Invoke_Property = ";Behavior"
Attribute Enabled.VB_UserMemId = -514
Enabled = UserControl.Enabled
End Property

Public Property Get MinimumHeight() As Long
MinimumHeight = mMinHeight
End Property

Public Property Get Parent() As Object
Set Parent = UserControl.Parent
End Property

Public Property Get SupportsTickFiles() As Boolean
SupportsTickFiles = mSupportsTickFiles
End Property

Public Property Get SupportsTickStreams() As Boolean
SupportsTickStreams = mSupportsTickStreams
End Property

Public Property Let Theme(ByVal Value As ITheme)
Const ProcName As String = "Theme"
On Error GoTo Err

Set mTheme = Value
If mTheme Is Nothing Then Exit Property

Dim lFont1 As StdFont
Set lFont1 = DownButton.Font

Dim lFont2 As StdFont
Set lFont2 = RemoveButton.Font

gApplyTheme mTheme, UserControl.Controls

Set DownButton.Font = lFont1
Set RemoveButton.Font = lFont2
Set UpButton.Font = lFont1

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get Theme() As ITheme
Set Theme = mTheme
End Property

Public Property Get TickfileCount() As Long
Const ProcName As String = "TickfileCount"
On Error GoTo Err

TickfileCount = TickFileList.ListCount

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get TickfileSpecifiers() As TickfileSpecifiers
Const ProcName As String = "TickfileSpecifiers"
On Error GoTo Err

If TickFileList.ListCount = 0 Then Exit Property

Dim tfs As New TickfileSpecifiers

Dim i As Long
For i = 0 To TickFileList.ListCount - 1
    tfs.Add mTickfileSpecifiers.Item(TickFileList.ItemData(i))
Next

Set TickfileSpecifiers = tfs

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

'@================================================================================
' Methods
'@================================================================================

Public Sub AddTickfileNames( _
                ByRef fileNames() As String)
Const ProcName As String = "AddTickfileNames"
On Error GoTo Err

Dim i As Long
For i = 0 To UBound(fileNames)
    Dim lfilename As String: lfilename = fileNames(i)
    
    Dim lFileExt As String: lFileExt = getFileExtension(lfilename)
                    
    If lFileExt <> TickfileListExtension Then
        Dim tfs As TickfileSpecifier
        Set tfs = New TickfileSpecifier
        tfs.FileName = lfilename
        
        addTickfileSpecifier tfs
    
        setFormatId tfs, lFileExt
    Else
        processTickfileListFile lfilename
    End If
Next

setScrollSize

RaiseEvent TickfileCountChanged

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Sub AddTickfileSpecifiers( _
                ByVal pTickfileSpecifiers As TickfileSpecifiers)
Const ProcName As String = "AddTickfileSpecifiers"
On Error GoTo Err

Dim lTfs As TickfileSpecifier
For Each lTfs In pTickfileSpecifiers
    addTickfileSpecifier lTfs
Next

setScrollSize

RaiseEvent TickfileCountChanged

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Sub Clear()
Const ProcName As String = "Clear"
On Error GoTo Err

Set mTickfileSpecifiers = New TickfileSpecifiers ' ensure any 'deleted' specifiers have gone

If TickFileList.ListCount = 0 Then Exit Sub

TickFileList.Clear

RaiseEvent TickfileCountChanged

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Sub Initialise(ByVal pTickfileStore As ITickfileStore)
Const ProcName As String = "Initialise"
On Error GoTo Err

If pTickfileStore Is Nothing Then Exit Sub

Set mTickfileStore = pTickfileStore
getSupportedTickfileFormats

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Sub addTickfileSpecifier(ByVal pTfs As TickfileSpecifier)
Const ProcName As String = "addTickfileSpecifier"
On Error GoTo Err

mTickfileSpecifiers.Add pTfs

Dim s As String: s = pTfs.FileName
TickFileList.AddItem s
adjustScrollSize s
TickFileList.ItemData(TickFileList.ListCount - 1) = mTickfileSpecifiers.Count

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub adjustScrollSize(ByVal pText As String)
Const ProcName As String = "adjustScrollSize"
On Error GoTo Err

Dim lWidth As Long
lWidth = MeasurePicture.TextWidth(pText) + 4 * Screen.TwipsPerPixelX
If lWidth > mScrollWidth Then
    mScrollSizeNeedsSetting = True
    mScrollWidth = lWidth
End If

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Function getFileExtension(ByVal pFilename As String) As String
getFileExtension = Right$(pFilename, Len(pFilename) - InStrRev(pFilename, "."))
End Function

Private Sub getSupportedTickfileFormats()
On Error GoTo Err

mSupportedTickfileFormats = mTickfileStore.SupportedFormats

ReDim mSupportedTickStreamFormats(9) As TickfileFormatSpecifier

Dim j As Long
j = -1

Dim i As Long
For i = 0 To UBound(mSupportedTickfileFormats)
    If mSupportedTickfileFormats(i).FormatType = TickfileModeFileBased Then
        mSupportsTickFiles = True
    Else
        j = j + 1
        If j > UBound(mSupportedTickStreamFormats) Then
            ReDim Preserve mSupportedTickStreamFormats(UBound(mSupportedTickStreamFormats) + 9) As TickfileFormatSpecifier
        End If
        mSupportedTickStreamFormats(j) = mSupportedTickfileFormats(i)
        mSupportsTickStreams = True
    End If
Next

If j = -1 Then
    Erase mSupportedTickStreamFormats
Else
    ReDim Preserve mSupportedTickStreamFormats(j) As TickfileFormatSpecifier
End If

Exit Sub

Err:

End Sub

Private Sub processTickfileListFile(ByVal pFilename As String)
Const ProcName As String = "processTickfileListFile"
On Error GoTo Err

Dim lTfs As TickfileSpecifier
For Each lTfs In GenerateTickfileSpecifiersFromFile(pFilename)
    addTickfileSpecifier lTfs
    setFormatId lTfs, getFileExtension(lTfs.FileName)
Next

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub setDownButton()
Const ProcName As String = "setDownButton"
On Error GoTo Err

Dim i As Long

For i = 0 To TickFileList.ListCount - 2
    If TickFileList.Selected(i) And Not TickFileList.Selected(i + 1) Then
        DownButton.Enabled = Enabled
        Exit Sub
    End If
Next
DownButton.Enabled = False

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub setFormatId(ByVal pTfs As TickfileSpecifier, ByVal pFileExt As String)
Const ProcName As String = "setFormatId"
On Error GoTo Err

' set up the FormatID - we set it to the first one that matches
' the file extension

Dim k As Long
For k = 0 To UBound(mSupportedTickfileFormats)
    If mSupportedTickfileFormats(k).FormatType = TickfileModeFileBased Then
        If UCase$(pFileExt) = UCase$(mSupportedTickfileFormats(k).FileExtension) Then
            pTfs.TickfileFormatID = mSupportedTickfileFormats(k).FormalID
            Exit For
        End If
    End If
Next

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub setRemoveButton()
Const ProcName As String = "setRemoveButton"
On Error GoTo Err

If TickFileList.SelCount <> 0 Then
    RemoveButton.Enabled = Enabled
Else
    RemoveButton.Enabled = False
End If

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub setScrollSize()
Const ProcName As String = "setScrollSize"
On Error GoTo Err

If Not mScrollSizeNeedsSetting Then Exit Sub
mScrollSizeNeedsSetting = False
SendMessage TickFileList.hWnd, LB_SETHORIZONTALEXTENT, mScrollWidth / Screen.TwipsPerPixelX, 0

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub setUpButton()
Const ProcName As String = "setUpButton"
On Error GoTo Err

Dim i As Long

For i = 1 To TickFileList.ListCount - 1
    If TickFileList.Selected(i) And Not TickFileList.Selected(i - 1) Then
        UpButton.Enabled = Enabled
        Exit Sub
    End If
Next
UpButton.Enabled = False

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub


