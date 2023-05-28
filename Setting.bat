@echo off
:通用管理员权限检查模块
title 检查进程权限中…
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
title 等待管理员授权中…
echo 请求管理员权限...
mode con cols=20 lines=1
goto UACPrompt
) else ( goto start )
:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:start
:通用管理员权限检查模块-结束
title RDPWarp设置程序
:menu
cls
echo ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
echo ┃ 〓 RDPWarp设置      〓           ┃
echo ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
echo ┃ 1.开机时自动更新版本             ┃
echo ┃ 2.开机时不自动更新版本           ┃
echo ┃ 3.手动更新版本                   ┃
echo ┃ 4.重新安装所有组件以修复错误     ┃
echo ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
set/p "cho=[选择]"
if %cho%==1 call "%~dp0autoupdate.bat" -taskadd
if %cho%==2 call "%~dp0autoupdate.bat"  -taskremove
if %cho%==3 call "%~dp0autoupdate.bat"
if %cho%==4 call "%~dp0install.bat"
goto menu
pause