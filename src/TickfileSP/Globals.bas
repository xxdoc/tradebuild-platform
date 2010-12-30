Attribute VB_Name = "Globals"
Option Explicit

'================================================================================
' Constants
'================================================================================

Public Const ProjectName               As String = "TickfileSP26"

Public Const ServiceProviderName As String = "TickfileSP"
Public Const ProviderKey As String = "TickfileSP"

Public Const ParamNameAccessMode As String = "Access Mode"
Public Const ParamNameTickfilePath As String = "Tickfile Path"
Public Const ParamNameTickfileGranularity = "Tickfile Granularity"

Public Const TRADEBUILD_TICKFILE_CURR_VERSION As Integer = 5

Public Const TICKFILE_DECLARER As String = "tickfile"
Public Const CONTRACT_DETAILS_MARKER As String = "contractdetails="

Public Const TICK_BID As String = "B"
Public Const TICK_ASK As String = "A"
Public Const TICK_TRADE As String = "T"
Public Const TICK_HIGH As String = "H"
Public Const TICK_LOW As String = "L"
Public Const TICK_CLOSE As String = "C"
Public Const TICK_VOLUME As String = "V"
Public Const TICK_OPEN As String = "O"
Public Const TICK_OPEN_INTEREST As String = "I"
Public Const TICK_MARKET_DEPTH As String = "D"
Public Const TICK_MARKET_DEPTH_RESET As String = "R"

Public Const ESIGNAL_TICK_QUOTE As String = "Q"
Public Const ESIGNAL_TICK_TRADE As String = "T"

Public Const TickfileFormatTradeBuildV3 As String = "urn:tradewright.com:names.tickfileformats.TradeBuildV3"
Public Const TickfileFormatTradeBuildV4 As String = "urn:tradewright.com:names.tickfileformats.TradeBuildV4"
Public Const TickfileFormatTradeBuildV5 As String = "urn:tradewright.com:names.tickfileformats.TradeBuildV5"
Public Const TickfileFormatCrescendoV1 As String = "urn:tradewright.com:names.tickfileformats.CrescendoV1"
Public Const TickfileFormatCrescendoV2 As String = "urn:tradewright.com:names.tickfileformats.CrescendoV2"
Public Const TickfileFormatESignal As String = "urn:tradewright.com:names.tickfileformats.ESignal"

'================================================================================
' Enums
'================================================================================

Public Enum AccessModes
    ReadOnly
    WriteOnly
    ReadWrite
End Enum

Public Enum TickfileFormats
    TickfileUnknown
    TickfileESignal
    TickfileTradeBuild
    TickfileCrescendo
End Enum

Public Enum TickfileGranularities
    TickfileGranularityDay
    TickfileGranularityWeek
    TickfileGranularitySession
    TickfileGranularityExecution
End Enum

Public Enum TickfileFieldsV1
    TimestampString
    Exchange
    Symbol
    Expiry
    tickType
    tickPrice
    TickSize
    Volume = tickPrice
End Enum

Public Enum TickfileFieldsV2
    timestamp
    TimestampString
    tickType
    tickPrice
    TickSize
    Volume = tickPrice
End Enum

Public Enum TickfileFieldsV3
    timestamp
    ReadableTimestamp
    tickType
    tickPrice
    TickSize
    Volume = tickPrice
    OpenInterest = tickPrice
    MDposition = tickPrice
    MDMarketMaker
    MDOperation
    MDSide
    MDPrice
    MDSize
End Enum

Public Enum TickfileHeaderFieldsV2
    ContentDeclarer
    version
    Exchange
    Symbol
    Expiry
    startTime
End Enum

Public Enum TickfileHeaderFieldsV3
    ContentDeclarer
    version
    Exchange
    Symbol
    Expiry
    startTime
End Enum

Public Enum TickFileVersions
    UnknownVersion
    TradeBuildV3
    TradeBuildV4
    CrescendoV1
    CrescendoV2
    ESignal
    TradeBuildV5
    DefaultVersion = TradeBuildV5
End Enum

Public Enum FileTickTypes
    bid = 1
    bidSize
    ask
    AskSize
    Last
    lastSize
    High
    Low
    PrevClose
    Volume
    LastSizeCorrection
    marketDepth
    MarketDepthReset
    OpenInterest
    SessionOpen
    Unknown = -1
End Enum

Public Enum ESignalTickFileFields
    tickType
    TimestampDate
    TimestampTime
    lastPrice
    lastSize
    bidPrice = lastPrice
    AskPrice
    bidSize
    AskSize
End Enum

'================================================================================
' Global variables
'================================================================================

'================================================================================
' Private variables
'================================================================================

Private mLogger As Logger
Private mTracer As Tracer

'================================================================================
' Properties
'================================================================================

Public Property Get gLogger() As Logger
If mLogger Is Nothing Then Set mLogger = GetLogger("log.serviceprovider.tickfilesp")
Set gLogger = mLogger
End Property

Public Property Get gTracer() As Tracer
If mTracer Is Nothing Then Set mTracer = GetTracer("tickfilesp")
Set gTracer = mTracer
End Property

'================================================================================
' Methods
'================================================================================

Public Function gCapabilitiesCrescendoV1(ByVal mode As AccessModes) As Long
Select Case mode
Case ReadOnly
    gCapabilitiesCrescendoV1 = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress
Case WriteOnly
    gCapabilitiesCrescendoV1 = 0
Case ReadWrite
    gCapabilitiesCrescendoV1 = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress
End Select
End Function

Public Function gCapabilitiesCrescendoV2(ByVal mode As AccessModes) As Long
Select Case mode
Case ReadOnly
    gCapabilitiesCrescendoV2 = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress
Case WriteOnly
    gCapabilitiesCrescendoV2 = 0
Case ReadWrite
    gCapabilitiesCrescendoV2 = _
                TickfileServiceProviderCapabilities.Record Or _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress
End Select
End Function

Public Function gCapabilitiesESignal(ByVal mode As AccessModes) As Long
Select Case mode
Case ReadOnly
    gCapabilitiesESignal = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress
Case WriteOnly
    gCapabilitiesESignal = 0
Case ReadWrite
    gCapabilitiesESignal = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress
End Select
End Function

Public Function gCapabilitiesTradeBuildV3(ByVal mode As AccessModes) As Long
Select Case mode
Case ReadOnly
    gCapabilitiesTradeBuildV3 = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReplayMarketDepth Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress
Case WriteOnly
    gCapabilitiesTradeBuildV3 = 0
Case ReadWrite
    gCapabilitiesTradeBuildV3 = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReplayMarketDepth Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress
End Select
End Function

Public Function gCapabilitiesTradeBuildV4(ByVal mode As AccessModes) As Long
Select Case mode
Case ReadOnly
    gCapabilitiesTradeBuildV4 = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReplayMarketDepth Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress Or _
                TickfileServiceProviderCapabilities.SaveContractInformation
Case WriteOnly
    gCapabilitiesTradeBuildV4 = 0
Case ReadWrite
    gCapabilitiesTradeBuildV4 = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReplayMarketDepth Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress Or _
                TickfileServiceProviderCapabilities.SaveContractInformation
End Select
End Function

Public Function gCapabilitiesTradeBuildV5(ByVal mode As AccessModes) As Long
Select Case mode
Case ReadOnly
    gCapabilitiesTradeBuildV5 = _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReplayMarketDepth Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress Or _
                TickfileServiceProviderCapabilities.SaveContractInformation
Case WriteOnly
    gCapabilitiesTradeBuildV5 = _
                TickfileServiceProviderCapabilities.Record Or _
                TickfileServiceProviderCapabilities.RecordMarketDepth Or _
                TickfileServiceProviderCapabilities.SaveContractInformation
Case ReadWrite
    gCapabilitiesTradeBuildV5 = _
                TickfileServiceProviderCapabilities.Record Or _
                TickfileServiceProviderCapabilities.RecordMarketDepth Or _
                TickfileServiceProviderCapabilities.Replay Or _
                TickfileServiceProviderCapabilities.ReplayMarketDepth Or _
                TickfileServiceProviderCapabilities.ReportReplayProgress Or _
                TickfileServiceProviderCapabilities.SaveContractInformation
End Select
End Function

Public Function gFormatSpecifiersToString( _
                                ByVal formatId As TickfileFormats, _
                                ByVal version As TickFileVersions) As String
Select Case formatId
Case TickfileFormats.TickfileESignal
    Select Case version
    Case TickFileVersions.ESignal
        gFormatSpecifiersToString = TickfileFormatESignal
    End Select
Case TickfileFormats.TickfileTradeBuild
    Select Case version
    Case TickFileVersions.TradeBuildV3
        gFormatSpecifiersToString = TickfileFormatTradeBuildV3
    Case TickFileVersions.TradeBuildV4
        gFormatSpecifiersToString = TickfileFormatTradeBuildV4
    Case TickFileVersions.TradeBuildV5
        gFormatSpecifiersToString = TickfileFormatTradeBuildV5
    End Select
Case TickfileFormats.TickfileCrescendo
    Select Case version
    Case TickFileVersions.CrescendoV1
        gFormatSpecifiersToString = TickfileFormatCrescendoV1
    Case TickFileVersions.CrescendoV2
        gFormatSpecifiersToString = TickfileFormatCrescendoV2
    End Select
End Select

End Function

Public Sub gFormatSpecifiersFromString(ByVal value As String, _
                                ByRef formatId As TickfileFormats, _
                                ByRef version As TickFileVersions)
Select Case value
Case TickfileFormatTradeBuildV3
    formatId = TickfileFormats.TickfileTradeBuild
    version = TickFileVersions.TradeBuildV3
Case TickfileFormatTradeBuildV4
    formatId = TickfileFormats.TickfileTradeBuild
    version = TickFileVersions.TradeBuildV4
Case TickfileFormatTradeBuildV5
    formatId = TickfileFormats.TickfileTradeBuild
    version = TickFileVersions.TradeBuildV5
Case TickfileFormatCrescendoV1
    formatId = TickfileFormats.TickfileCrescendo
    version = TickFileVersions.CrescendoV1
Case TickfileFormatCrescendoV2
    formatId = TickfileFormats.TickfileCrescendo
    version = TickFileVersions.CrescendoV2
Case TickfileFormatESignal
    formatId = TickfileFormats.TickfileESignal
    version = TickFileVersions.ESignal
Case ""
    formatId = TickfileFormats.TickfileTradeBuild
    version = TickFileVersions.DefaultVersion
Case Else
    formatId = TickfileFormats.TickfileUnknown
    version = TickFileVersions.UnknownVersion
End Select
End Sub

Public Sub gHandleUnexpectedError( _
                ByRef pProcedureName As String, _
                ByRef pProjectName As String, _
                ByRef pModuleName As String, _
                Optional ByRef pFailpoint As String, _
                Optional ByVal pReRaise As Boolean = True, _
                Optional ByVal pLog As Boolean = False, _
                Optional ByVal pErrorNumber As Long, _
                Optional ByRef pErrorDesc As String, _
                Optional ByRef pErrorSource As String)
Dim errSource As String: errSource = IIf(pErrorSource <> "", pErrorSource, Err.Source)
Dim errDesc As String: errDesc = IIf(pErrorDesc <> "", pErrorDesc, Err.Description)
Dim errNum As Long: errNum = IIf(pErrorNumber <> 0, pErrorNumber, Err.Number)

HandleUnexpectedError pProcedureName, pProjectName, pModuleName, pFailpoint, pReRaise, pLog, errNum, errDesc, errSource
End Sub

Public Sub gNotifyUnhandledError( _
                ByRef pProcedureName As String, _
                ByRef pProjectName As String, _
                ByRef pModuleName As String, _
                Optional ByRef pFailpoint As String, _
                Optional ByVal pErrorNumber As Long, _
                Optional ByRef pErrorDesc As String, _
                Optional ByRef pErrorSource As String)
Dim errSource As String: errSource = IIf(pErrorSource <> "", pErrorSource, Err.Source)
Dim errDesc As String: errDesc = IIf(pErrorDesc <> "", pErrorDesc, Err.Description)
Dim errNum As Long: errNum = IIf(pErrorNumber <> 0, pErrorNumber, Err.Number)

UnhandledErrorHandler.Notify pProcedureName, pModuleName, pProjectName, pFailpoint, errNum, errDesc, errSource
End Sub

Public Function gSupports( _
                            ByVal Capabilities As Long, _
                            ByVal mode As AccessModes, _
                            Optional ByVal FormatIdentifier As String) As Boolean
Dim formatId As TickfileFormats
Dim formatVersion As TickFileVersions
Dim capMask As Long

gFormatSpecifiersFromString FormatIdentifier, formatId, formatVersion
If formatId = TickfileFormats.TickfileUnknown Then Exit Function

Select Case formatVersion
Case TradeBuildV3
    capMask = gCapabilitiesTradeBuildV3(mode)
Case TradeBuildV4
    capMask = gCapabilitiesTradeBuildV4(mode)
Case TradeBuildV5
    capMask = gCapabilitiesTradeBuildV5(mode)
Case CrescendoV1
    capMask = gCapabilitiesCrescendoV1(mode)
Case CrescendoV2
    capMask = gCapabilitiesCrescendoV2(mode)
Case ESignal
    capMask = gCapabilitiesESignal(mode)
End Select

gSupports = (capMask And Capabilities)

End Function



