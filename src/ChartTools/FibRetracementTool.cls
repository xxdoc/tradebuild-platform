VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "FibRetracementTool"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

''
' Description here
'
'@/

'@================================================================================
' Interfaces
'@================================================================================

Implements IChartTool

'@================================================================================
' Events
'@================================================================================

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

Public Type FibLineSpecifier
    Percentage          As Single
    Style               As lineStyle
End Type

'@================================================================================
' Constants
'@================================================================================

Private Const ProjectName                   As String = "ChartTools26"
Private Const ModuleName                    As String = "FibRetracementTool"

'@================================================================================
' Member variables
'@================================================================================

Private mAbstractTool                       As AbstractChartTool

Private mRegion                             As ChartRegion

Private mLineSpecs()                        As FibLineSpecifier

Private mLineSeries                         As LineSeries

Private WithEvents mLine1                   As ChartSkil26.Line
Attribute mLine1.VB_VarHelpID = -1
Private WithEvents mLine2                   As ChartSkil26.Line
Attribute mLine2.VB_VarHelpID = -1
Private WithEvents mLine3                   As ChartSkil26.Line
Attribute mLine3.VB_VarHelpID = -1
Private WithEvents mLine4                   As ChartSkil26.Line
Attribute mLine4.VB_VarHelpID = -1
Private WithEvents mLine5                   As ChartSkil26.Line
Attribute mLine5.VB_VarHelpID = -1
Private WithEvents mLine6                   As ChartSkil26.Line
Attribute mLine6.VB_VarHelpID = -1
Private WithEvents mLine7                   As ChartSkil26.Line
Attribute mLine7.VB_VarHelpID = -1
Private WithEvents mLine8                   As ChartSkil26.Line
Attribute mLine8.VB_VarHelpID = -1

Private mTextSeries                         As TextSeries

Private mControlPoint1                      As Point
Private mControlPoint2                      As Point

Private mLineStyle                          As lineStyle

Private mStartPoint1                        As ChartSkil26.Point
Private mStartPoint2                        As ChartSkil26.Point

Private mLayer                              As LayerNumbers

Private mPrevX                              As Double
Private mPrevY                              As Double

'@================================================================================
' Class Event Handlers
'@================================================================================

'@================================================================================
' IChartTool Interface Members
'@================================================================================

Private Sub IChartTool_Create(ByVal X As Double, ByVal Y As Double)
Dim aFont As StdFont
Dim tStyle As textStyle

Set mControlPoint1 = mRegion.newPoint(X, Y)
Set mControlPoint2 = mRegion.newPoint(X, Y)

Set mLineSeries = mRegion.AddGraphicObjectSeries(New LineSeries, mLayer)
If mLayer = -1 Then
    mLayer = mLineSeries.layer    ' get the layer allocated
End If

Set mTextSeries = mRegion.AddGraphicObjectSeries(New TextSeries, mLayer)
Set tStyle = mRegion.DefaultTextStyle
Set aFont = tStyle.Font
aFont.Size = 8
tStyle.Font = aFont
tStyle.box = False
tStyle.Align = AlignBoxCentreLeft
mTextSeries.Style = tStyle

Set mLine1 = addRetracementLine(0, X, Y)

If UBound(mLineSpecs) >= 1 Then Set mLine2 = addRetracementLine(1, X, Y)

If UBound(mLineSpecs) >= 2 Then Set mLine3 = addRetracementLine(2, X, Y)

If UBound(mLineSpecs) >= 3 Then Set mLine4 = addRetracementLine(3, X, Y)

If UBound(mLineSpecs) >= 4 Then Set mLine5 = addRetracementLine(4, X, Y)

If UBound(mLineSpecs) >= 5 Then Set mLine6 = addRetracementLine(5, X, Y)

If UBound(mLineSpecs) >= 6 Then Set mLine7 = addRetracementLine(6, X, Y)

If UBound(mLineSpecs) >= 7 Then Set mLine8 = addRetracementLine(7, X, Y)

End Sub

Private Sub IChartTool_Delete()
Dim ln As ChartSkil26.Line
For Each ln In mLineSeries
    mRegion.RemoveGraphicObject ln
Next
mRegion.RemoveGraphicObjectSeries mLineSeries
Dim txt As ChartSkil26.Text
For Each txt In mTextSeries
    mRegion.RemoveGraphicObject txt
Next
mRegion.RemoveGraphicObjectSeries mTextSeries
End Sub

Private Sub IChartTool_Deselected()

End Sub

Private Sub IChartTool_EndResize()
Dim ln As ChartSkil26.Line
For Each ln In mLineSeries
    ln.layer = mLayer
Next
Dim txt As ChartSkil26.Text
For Each txt In mTextSeries
    txt.layer = mLayer
Next
Set mStartPoint1 = Nothing
Set mStartPoint2 = Nothing
End Sub

Private Sub IChartTool_Move(ByVal X As Double, ByVal Y As Double)
Dim ln As ChartSkil26.Line

Set mControlPoint1 = mRegion.newPoint(mControlPoint1.X + X - mPrevX, mControlPoint1.Y + Y - mPrevY)
Set mControlPoint2 = mRegion.newPoint(mControlPoint2.X + X - mPrevX, mControlPoint2.Y + Y - mPrevY)

For Each ln In mLineSeries
    ln.Point1 = mRegion.newPoint(ln.Point1.X + X - mPrevX, ln.Point1.Y + Y - mPrevY)
    ln.Point2 = mRegion.newPoint(ln.Point2.X + X - mPrevX, ln.Point2.Y + Y - mPrevY)
Next
Dim txt As ChartSkil26.Text
Dim i As Long
For i = 1 To mTextSeries.Count
    Set txt = mTextSeries(i)
    txt.position = mRegion.newPoint(txt.position.X + X - mPrevX, txt.position.Y + Y - mPrevY)
    SetText txt, i
Next
mPrevX = X
mPrevY = Y
End Sub

Private Sub IChartTool_MoveResize(ByVal selHandleIndex As Long, ByVal X As Double, ByVal Y As Double)
Dim ln As ChartSkil26.Line
Dim txt As Text
Dim i As Long
Dim retr As Double

If selHandleIndex = 1 Then
    Set mControlPoint1 = mRegion.newPoint(X, Y)
    For i = 1 To mLineSeries.Count
        Set ln = mLineSeries(i)
        retr = mControlPoint2.Y - (mControlPoint2.Y - mControlPoint1.Y) * mLineSpecs(i - 1).Percentage / 100
        ln.Point1 = mRegion.newPoint(X, retr)
        ln.Point2 = mRegion.newPoint(mControlPoint2.X, retr)
        Set txt = mTextSeries(i)
        txt.position = ln.Point2
        SetText txt, i
    Next
Else
    Set mControlPoint2 = mRegion.newPoint(X, Y)
    For i = 1 To mLineSeries.Count
        Set ln = mLineSeries(i)
        retr = mControlPoint2.Y - (mControlPoint2.Y - mControlPoint1.Y) * mLineSpecs(i - 1).Percentage / 100
        ln.Point1 = mRegion.newPoint(mControlPoint1.X, retr)
        ln.Point2 = mRegion.newPoint(X, retr)
        Set txt = mTextSeries(i)
        txt.position = ln.Point2
        SetText txt, i
    Next
End If

End Sub

Private Property Let IChartTool_Region(ByVal RHS As ChartSkil26.ChartRegion)
Dim i As Long
Set mRegion = RHS
For i = 0 To UBound(mLineSpecs)
    If mLineSpecs(i).Style Is Nothing Then
        Set mLineSpecs(i).Style = mRegion.DefaultLineStyle
        mLineSpecs(i).Style.extended = True
        mLineSpecs(i).Style.includeInAutoscale = False
    End If
Next
End Property

Private Sub IChartTool_ResizeCreate(ByVal X As Double, ByVal Y As Double)
Dim ln As ChartSkil26.Line
Dim txt As Text
Dim i As Long
Dim retr As Double

Set mControlPoint2 = mRegion.newPoint(X, Y)

For i = 1 To mLineSeries.Count
    Set ln = mLineSeries(i)
    retr = mControlPoint2.Y - (mControlPoint2.Y - mControlPoint1.Y) * mLineSpecs(i - 1).Percentage / 100
    ln.Point1 = mRegion.newPoint(mControlPoint1.X, retr)
    ln.Point2 = mRegion.newPoint(X, retr)
    Set txt = mTextSeries(i)
    txt.position = ln.Point2
    SetText txt, i
Next

End Sub

Private Sub IChartTool_StartResize(ByVal selHandle As SelectionHandle, ByVal X As Single, ByVal Y As Single)
mPrevX = X
mPrevY = Y

Set mStartPoint1 = mControlPoint1
Set mStartPoint2 = mControlPoint2

Dim ln As ChartSkil26.Line
For Each ln In mLineSeries
    ln.layer = LayerNumbers.LayerMax
Next
Dim txt As ChartSkil26.Text
For Each txt In mTextSeries
    txt.layer = LayerNumbers.LayerMax
Next
End Sub

Private Sub IChartTool_Undo()
Dim ln As ChartSkil26.Line
Dim txt As Text
Dim i As Long
Dim retr As Double

Set mControlPoint1 = mStartPoint1
Set mControlPoint2 = mStartPoint2

For i = 1 To mLineSeries.Count
    Set ln = mLineSeries(i)
    retr = mControlPoint2.Y - (mControlPoint2.Y - mControlPoint1.Y) * mLineSpecs(i - 1).Percentage / 100
    ln.Point1 = mRegion.newPoint(mControlPoint1.X, retr)
    ln.Point2 = mRegion.newPoint(mControlPoint2.X, retr)
    ln.layer = mLayer
    Set txt = mTextSeries(i)
    txt.position = ln.Point2
    SetText txt, i
    txt.layer = mLayer
Next

Set mStartPoint1 = Nothing
Set mStartPoint2 = Nothing
End Sub

'@================================================================================
' mLine Event Handlers
'@================================================================================

Private Sub mLine1_SelectionStateChanged()
If mLine1.IsSelected Then notifySelected
End Sub

Private Sub mLine2_SelectionStateChanged()
If mLine2.IsSelected Then notifySelected
End Sub

Private Sub mLine3_SelectionStateChanged()
If mLine3.IsSelected Then notifySelected
End Sub

Private Sub mLine4_SelectionStateChanged()
If mLine4.IsSelected Then notifySelected
End Sub

Private Sub mLine5_SelectionStateChanged()
If mLine5.IsSelected Then notifySelected
End Sub

Private Sub mLine6_SelectionStateChanged()
If mLine6.IsSelected Then notifySelected
End Sub

Private Sub mLine7_SelectionStateChanged()
If mLine7.IsSelected Then notifySelected
End Sub

Private Sub mLine8_SelectionStateChanged()
If mLine8.IsSelected Then notifySelected
End Sub

'@================================================================================
' Properties
'@================================================================================

'@================================================================================
' Methods
'@================================================================================

Friend Sub Initialise( _
                ByVal controller As chartController, _
                ByRef pLineSpecs() As FibLineSpecifier, _
                ByVal layer As Long)
mLineSpecs = pLineSpecs
mLayer = layer
Set mAbstractTool = CreateAbstractChartTool(controller, Me)
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Function addRetracementLine( _
                ByVal index As Long, _
                ByVal X As Double, _
                ByVal Y As Double)
Dim ln As ChartSkil26.Line
Dim txt As ChartSkil26.Text

Set ln = mLineSeries.Add(, mLineSpecs(index).Style, True)
ln.layer = LayerNumbers.LayerMax
ln.SetPosition mRegion.newPoint(X, Y), mRegion.newPoint(X, Y)
mAbstractTool.AddSelectableObject ln

Set txt = mTextSeries.Add
txt.Color = mLineSpecs(index).Style.Color
txt.position = mRegion.newPoint(X, Y)
txt.offset = mRegion.newDimension(0.2, 0)
txt.Text = mLineSpecs(index).Percentage & "%"

Set addRetracementLine = ln
End Function

Private Sub notifySelected()
If Not mAbstractTool.IsSelected Then
    mAbstractTool.SetSelected
    mAbstractTool.AddSelectionHandle mControlPoint1.X, mControlPoint1.Y
    mAbstractTool.AddSelectionHandle mControlPoint2.X, mControlPoint2.Y
End If
End Sub

Private Sub SetText( _
                ByVal txt As Text, _
                ByVal index As Long)
txt.Text = mLineSpecs(index - 1).Percentage & "% (" & mRegion.FormatYValue(txt.position.Y) & ")"
End Sub
