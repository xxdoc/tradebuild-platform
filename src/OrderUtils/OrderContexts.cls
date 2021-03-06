VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "OrderContexts"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
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

Implements IEnumerable
Implements IStateChangeListener

'@================================================================================
' Events
'@================================================================================

Event CollectionChanged( _
                ev As CollectionChangeEventData)
                
Event PositionsClosed()

'@================================================================================
' Constants
'@================================================================================

Private Const ModuleName                        As String = "OrderContexts"

Private Const DefaultOrderContextName           As String = "$default"
Private Const BalancingOrderContextName         As String = "$balancing"

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' Member variables
'@================================================================================

Private mOrderManager                           As OrderManager

Private mContractFuture                         As IFuture
Private mDataSource                             As IMarketDataSource
Private mOrderSubmitter                         As IOrderSubmitter
Private mOrderAuthoriser                        As IOrderAuthoriser
Private mAccumulatedBracketOrders               As BracketOrders
Private mAccumulatedOrders                      As Orders

Private mName                                   As String
Private mGroupName                              As String

Private WithEvents mOrderContexts               As EnumerableCollection
Attribute mOrderContexts.VB_VarHelpID = -1

Private mEnabled                                As Boolean

Private mIsSimulated                            As Boolean

Private mProviderIsReady                        As Boolean

Private mSimulatedClockFuture                   As IFuture

Private mPermittedOrderProperties               As IPermittedOrderProperties

Private mCollectionChangeListeners              As New Listeners

Private WithEvents mFutureWaiter                As FutureWaiter
Attribute mFutureWaiter.VB_VarHelpID = -1

'@================================================================================
' Class Event Handlers
'@================================================================================

Private Sub Class_Initialize()
Set mOrderContexts = New EnumerableCollection
Set mFutureWaiter = New FutureWaiter
mEnabled = True
End Sub

Private Sub Class_Terminate()
Debug.Print "OrderContexts terminated"
End Sub

'@================================================================================
' IEnumerable Interface Members
'@================================================================================

Private Property Get IEnumerable_Enumerator() As Enumerator
Const ProcName As String = "IEnumerable_Enumerator"
On Error GoTo Err

Set IEnumerable_Enumerator = Enumerator

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Private Function IEnumerable_NextItem(Item As Variant, pCookie As Variant) As Boolean
End Function

Private Sub IEnumerable_Remove(pCookie As Variant)
End Sub

Private Function IEnumerable_Skip(ByVal numToSkip As Long, pCookie As Variant) As Boolean
End Function

Private Property Get IEnumerable_UpdateSequence() As Long
End Property

'@================================================================================
' IStateChangeListener Interface Members
'@================================================================================

Private Sub IStateChangeListener_Change(ev As StateChangeEventData)
Const ProcName As String = "IStateChangeListener_Change"
On Error GoTo Err

Select Case ev.State
Case OrderSubmitterStateNotReady
    mProviderIsReady = False
Case OrderSubmitterStateReady
    mProviderIsReady = True
End Select

checkGotPermittedOrderProperties

Dim lOrderContext As OrderContext
For Each lOrderContext In mOrderContexts
    lOrderContext.ProviderIsReady = IsReady
Next

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' mFutureWaiter Event Handlers
'@================================================================================

Private Sub mFutureWaiter_WaitCompleted(ev As FutureWaitCompletedEventData)
Const ProcName As String = "mFutureWaiter_WaitCompleted"
On Error GoTo Err

If Not ev.Future.IsAvailable Then Exit Sub

Set mPermittedOrderProperties = ev.Future.Value

Dim lOrderContext As OrderContext
For Each lOrderContext In mOrderContexts
    lOrderContext.PermittedOrderProperties = mPermittedOrderProperties
    lOrderContext.ProviderIsReady = IsReady
Next

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

'@================================================================================
' mOrderContexts Event Handlers
'@================================================================================

Private Sub mOrderContexts_CollectionChanged(ev As CollectionChangeEventData)
Const ProcName As String = "mOrderContexts_CollectionChanged"
On Error GoTo Err

Set ev.Source = Me
fireCollectionChanged ev

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

'@================================================================================
' Properties
'@================================================================================

Friend Property Get BalancingOrderContext() As OrderContext
Const ProcName As String = "BalancingOrderContext"
On Error GoTo Err

Dim lBalancingOrderContext As OrderContext
If Not mOrderContexts.Contains(BalancingOrderContextName) Then
    ' use a local variable here to avoid catching the ReadyStateChanged event
    Set lBalancingOrderContext = Add(BalancingOrderContextName)
    lBalancingOrderContext.Enabled = True
    If lBalancingOrderContext.IsOrderTifSupported(OrderTIFs.OrderTIFDay) Then lBalancingOrderContext.TemplateOrder.TimeInForce = OrderTIFs.OrderTIFDay
End If

Set lBalancingOrderContext = mOrderContexts.Item(BalancingOrderContextName)
lBalancingOrderContext.Enabled = True
Set BalancingOrderContext = lBalancingOrderContext

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get ContractFuture() As IFuture
Set ContractFuture = mContractFuture
End Property

Public Property Get Count() As Long
Const ProcName As String = "Count"

On Error GoTo Err

Count = mOrderContexts.Count

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get DataSource() As IMarketDataSource
Set DataSource = mDataSource
End Property

Public Property Get DefaultOrderContext() As OrderContext
If Not Contains(DefaultOrderContextName) Then
    Set DefaultOrderContext = Add(DefaultOrderContextName)
Else
    Set DefaultOrderContext = Item(DefaultOrderContextName)
End If
End Property

Friend Property Let Enabled(ByVal Value As Boolean)
Const ProcName As String = "Enabled"
On Error GoTo Err

If mEnabled = Value Then Exit Property

mEnabled = Value

Dim oc As OrderContext
For Each oc In mOrderContexts
    oc.Enabled = mEnabled
Next

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get Enabled() As Boolean
Enabled = mEnabled
End Property

Public Property Get Enumerator() As Enumerator
Const ProcName As String = "Enumerator"
On Error GoTo Err

Set Enumerator = mOrderContexts.Enumerator

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get IsReady() As Boolean
IsReady = mProviderIsReady And (Not mPermittedOrderProperties Is Nothing)
End Property

Public Property Get IsSimulated() As Boolean
IsSimulated = mIsSimulated
End Property

Public Property Get Name() As String
Name = mName
End Property

Public Property Get OrderSubmitter() As IOrderSubmitter
Set OrderSubmitter = mOrderSubmitter
End Property

'@================================================================================
' Methods
'@================================================================================

Public Function Add(ByVal pName As String) As OrderContext
Const ProcName As String = "Add"
On Error GoTo Err

Set Add = New OrderContext
Add.Initialise pName, mOrderManager.SessionName, mName, mGroupName, mIsSimulated, mContractFuture, mDataSource, mOrderSubmitter, mOrderAuthoriser, mAccumulatedBracketOrders, mAccumulatedOrders, mSimulatedClockFuture
 
mOrderContexts.Add Add, pName
Add.PermittedOrderProperties = mPermittedOrderProperties
Add.Enabled = mEnabled
Add.ProviderIsReady = IsReady

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Sub AddCollectionChangeListener( _
                ByVal pListener As ICollectionChangeListener)
Const ProcName As String = "AddCollectionChangeListener"
On Error GoTo Err

mCollectionChangeListeners.Add pListener

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Function Contains(ByVal pName As String) As Boolean
Const ProcName As String = "Contains"
On Error GoTo Err

Contains = mOrderContexts.Contains(pName)

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Friend Sub Finish()
Const ProcName As String = "Finish"
On Error GoTo Err

Set mDataSource = Nothing

mOrderSubmitter.Finish
Set mOrderSubmitter = Nothing

Dim OrderContext As OrderContext
For Each OrderContext In mOrderContexts
    OrderContext.Finish
Next

mOrderManager.RemoveOrderContexts Me
Set mOrderManager = Nothing

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub Initialise( _
                ByVal pName As String, _
                ByVal pOrderManager As OrderManager, _
                ByVal pGroupName As String, _
                ByVal pIsSimulated As Boolean, _
                ByVal pContractFuture As IFuture, _
                ByVal pDataSource As IMarketDataSource, _
                ByVal pOrderSubmitter As IOrderSubmitter, _
                ByVal pOrderAuthoriser As IOrderAuthoriser, _
                ByVal pAccumulatedBracketOrders As BracketOrders, _
                ByVal pAccumulatedOrders As Orders, _
                ByVal pSimulatedClockFuture As IFuture)
Const ProcName As String = "Initialise"
On Error GoTo Err

mName = pName
Set mOrderManager = pOrderManager
mGroupName = pGroupName

mIsSimulated = pIsSimulated
Set mContractFuture = pContractFuture
Set mDataSource = pDataSource
Set mOrderSubmitter = pOrderSubmitter
Set pOrderAuthoriser = pOrderAuthoriser
Set mAccumulatedBracketOrders = pAccumulatedBracketOrders
Set mAccumulatedOrders = pAccumulatedOrders
Set mSimulatedClockFuture = pSimulatedClockFuture

mOrderSubmitter.AddStateChangeListener Me
mProviderIsReady = (mOrderSubmitter.State = OrderSubmitterStateReady)

checkGotPermittedOrderProperties

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Function Item(index As Variant) As OrderContext
Attribute Item.VB_UserMemId = 0
Const ProcName As String = "Item"
On Error GoTo Err

Set Item = mOrderContexts(index)

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
Const ProcName As String = "NewEnum"

On Error GoTo Err

Set NewEnum = getEnumerator
Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Sub NotifyChange(pOrderContext As OrderContext)
Const ProcName As String = "NotifyChange"
On Error GoTo Err

mOrderContexts.NotifyChange pOrderContext.Name

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub NotifyPositionsClosed()
Const ProcName As String = "NotifyPositionsClosed"
On Error GoTo Err

RaiseEvent PositionsClosed

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Sub Remove( _
                ByVal pOrderContext As OrderContext)
Const ProcName As String = "Remove"
On Error GoTo Err

mOrderContexts.Remove pOrderContext.Name

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Sub RemoveCollectionChangeListener(ByVal pListener As ICollectionChangeListener)
Const ProcName As String = "RemoveCollectionChangeListener"
On Error GoTo Err

mCollectionChangeListeners.Remove pListener

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Sub checkGotPermittedOrderProperties()
Const ProcName As String = "checkGotPermittedOrderProperties"
On Error GoTo Err

If mProviderIsReady And mPermittedOrderProperties Is Nothing Then
    Dim lContractString As String
    lContractString = "(contract details not yet available)"
    If mContractFuture.IsAvailable Then
        Dim lContract As IContract
        Set lContract = mContractFuture.Value
        lContractString = lContract.Specifier.ToString
    End If
    gLog "Fetching permitted order properties for", ProcName, ModuleName, lContractString, LogLevelDetail
    mFutureWaiter.Add mOrderSubmitter.FetchPermittedOrderProperties(mContractFuture)
End If

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub fireCollectionChanged(ev As CollectionChangeEventData)
Const ProcName As String = "fireCollectionChanged"
On Error GoTo Err

Static sInit As Boolean
Static sCurrentListeners() As Object
Static sSomeListeners As Boolean

If Not sInit Or Not mCollectionChangeListeners.Valid Then
    sInit = True
    sSomeListeners = mCollectionChangeListeners.GetCurrentListeners(sCurrentListeners)
End If
If sSomeListeners Then
    Dim lListener As ICollectionChangeListener
    Dim i As Long
    For i = 0 To UBound(sCurrentListeners)
        Set lListener = sCurrentListeners(i)
        lListener.Change ev
    Next
End If

RaiseEvent CollectionChanged(ev)

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Function getEnumerator() As Enumerator
Const ProcName As String = "getEnumerator"
On Error GoTo Err

Set getEnumerator = mOrderContexts.Enumerator

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function


