@echo off
setlocal

:: unregisters the TradeBuild Platform dlls

path %CD%;%PATH%

call setTradeBuildVersion

pushd Bin\TradeWright.TradeBuild.Platform

call unregisterComponent.bat SessionUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat ContractUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat BarUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat TickUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat StudyUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat TickfileUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat HistDataUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat TimeframeUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat MarketDataUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat OrderUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat TickerUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat WorkspaceUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat ChartSkil ocx 
if errorlevel 1 goto :err

call unregisterComponent.bat BarFormatters dll 
if errorlevel 1 goto :err

call unregisterComponent.bat ChartUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat ChartTools dll 
if errorlevel 1 goto :err

call unregisterComponent.bat StudiesUI ocx 
if errorlevel 1 goto :err

call unregisterComponent.bat TradingUI ocx 
if errorlevel 1 goto :err

call unregisterComponent.bat CommonStudiesLib dll 
if errorlevel 1 goto :err

call unregisterComponent.bat StrategyUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat Strategies dll 
if errorlevel 1 goto :err

call unregisterComponent.bat TradeBuild dll 
if errorlevel 1 goto :err

call unregisterComponent.bat ConfigUtils dll 
if errorlevel 1 goto :err

call unregisterComponent.bat TradeBuildUI ocx 
if errorlevel 1 goto :err

call unregisterComponent.bat TBDataCollector dll 
if errorlevel 1 goto :err

popd


pushd Bin\TradeWright.TradeBuild.ServiceProviders

call unregisterComponent.bat TradingDO dll 
if errorlevel 1 goto :err

call unregisterComponent.bat TradingDBApi dll 
if errorlevel 1 goto :err

call unregisterComponent.bat IBAPI dll
if errorlevel 1 goto :err

call unregisterComponent.bat IBEnhAPI dll
if errorlevel 1 goto :err

call unregisterComponent.bat IBTwsSP dll
if errorlevel 1 goto :err

call unregisterComponent.bat TBInfoBase dll
if errorlevel 1 goto :err

call unregisterComponent.bat TickfileSP dll
if errorlevel 1 goto :err

rem call unregisterComponent.bat QuoteTrackerSP dll
rem if errorlevel 1 goto :err

popd

call setTradeWrightCommonVersion

pushd Bin\TradeWright.Common

call unregisterComponent.bat TWUtilities dll
if errorlevel 1 goto :err

call unregisterComponent.bat ExtProps dll
if errorlevel 1 goto :err

call unregisterComponent.bat ExtEvents dll
if errorlevel 1 goto :err

call unregisterComponent.bat BusObjUtils dll
if errorlevel 1 goto :err

call unregisterComponent.bat TWControls ocx
if errorlevel 1 goto :err

call unregisterComponent.bat GraphicsUtils dll
if errorlevel 1 goto :err

call unregisterComponent.bat LayeredGraphics dll
if errorlevel 1 goto :err

call unregisterComponent.bat GraphObjUtils dll
if errorlevel 1 goto :err

call unregisterComponent.bat GraphObj dll
if errorlevel 1 goto :err

call unregisterComponent.bat SpriteControlLib dll
if errorlevel 1 goto :err

popd

pushd Bin\TradeWright.TradeBuild.ExternalComponents

call unregisterComponent.bat ComCt332 ocx EXT
if errorlevel 1 goto :err

call unregisterComponent.bat ComDlg32 OCX EXT
if errorlevel 1 goto :err

call unregisterComponent.bat dbadapt dll EXT
if errorlevel 1 goto :err

call unregisterComponent.bat mscomct2 ocx EXT
if errorlevel 1 goto :err

call unregisterComponent.bat mscomctl OCX EXT
if errorlevel 1 goto :err

call unregisterComponent.bat MSDatGrd ocx EXT
if errorlevel 1 goto :err

call unregisterComponent.bat MSFlxGrd ocx EXT
if errorlevel 1 goto :err

call unregisterComponent.bat msstdfmt dll EXT
if errorlevel 1 goto :err

call unregisterComponent.bat MSWINSCK ocx EXT
if errorlevel 1 goto :err

call unregisterComponent.bat TabCtl32 Ocx EXT
if errorlevel 1 goto :err

call unregisterComponent.bat TLBINF32 DLL EXT
if errorlevel 1 goto :err

popd

exit /B

:err
popd
pause
exit /B 1
