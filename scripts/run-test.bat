@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ========================================
:: 配置区（根据你的环境修改）
:: ========================================
set JMETER_HOME=D:\JMeter\apache-jmeter-5.6.3
set PROJECT_DIR=D:\JMeterProjects\Project-three
set TEST_PLAN=%PROJECT_DIR%\test-plans\03-quick-pay.jmx

:: 生成时间戳目录
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set REPORT_DIR=%PROJECT_DIR%\reports\%TIMESTAMP%

:: ========================================
:: 预检查
:: ========================================
if not exist %JMETER_HOME%\bin\jmeter.bat (
    echo [错误] JMeter 未找到：%JMETER_HOME%
    pause
    exit /b 1
)

if not exist %TEST_PLAN% (
    echo [错误] 测试计划不存在：%TEST_PLAN%
    pause
    exit /b 1
)

:: 创建报告目录
if not exist %REPORT_DIR% mkdir %REPORT_DIR%

echo ========================================
echo   支付网关压力测试
echo ========================================
echo 项目目录: %PROJECT_DIR%
echo 测试计划: %TEST_PLAN%
echo 报告目录: %REPORT_DIR%
echo 启动时间: %date% %time%
echo.

:: ========================================
:: 执行 JMeter（非 GUI 模式）
:: ========================================
%JMETER_HOME%\bin\jmeter.bat ^
  -n ^
  -t %TEST_PLAN% ^
  -l %REPORT_DIR%\result.jtl ^
  -j %REPORT_DIR%\jmeter.log ^
  -e ^
  -o %REPORT_DIR%\dashboard ^
  -Jthreads=500 ^
  -Jrampup=60 ^
  -Jduration=1800

echo.
echo ========================================
echo   测试完成
echo ========================================
echo 原始数据: %REPORT_DIR%\result.jtl
echo HTML报告: %REPORT_DIR%\dashboard\index.html
echo JMeter日志: %REPORT_DIR%\jmeter.log

:: 自动打开报告
if exist %REPORT_DIR%\dashboard\index.html (
    start %REPORT_DIR%\dashboard\index.html
)

pause