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

title RDPWarp主程序安装
echo 本程序基于使用Apache-2.0许可证的开源项目制作，并以同样形式分发。
echo 本软件仓库：https://github.com/yige-yigeren/rdpwrap_AutoUpdate_CN
echo 没有从GitHub直接下载的安装包可能包含恶意行为，为了你的设备安全，建议从Github或可信的Github镜像源下载。
echo 请确认解压压缩包内所有文件，且目录不含特殊字符
echo 如果觉得本软件好用请去Github点个star吧（跪求）
timeout /NOBREAK /t 3 >nul
start https://github.com/yige-yigeren/rdpwrap_AutoUpdate_CN
timeout /NOBREAK /t 5 >nul
cls
echo .
if not exist "%~dp0RDPWInst.exe" goto :error
"%~dp0RDPWInst" -i -o
echo ______________________________________________________________
echo.
echo RDPWarp主程序安装完成
echo 您可以使用RDPCheck程序检查RDP功能。
echo 还可以使用RDPConf程序配置高级设置。
echo 上述程序均可在压缩包及"系统盘:\Program Files\RDP Wrapper"中找到
echo.
goto :anykey

:error
echo [-] ERROR：没有找到安装程序可执行文件。
echo 请解压所有文件或检查你的杀毒软件是否拦截了部分文件。

:anykey
echo 请勿关闭该窗口，将在5秒后安装自动更新组件
timeout /NOBREAK /t 5 >nul
cls
echo 安装自动更新组件中...
set spath=%windir:~0,3%Program Files\RDP Wrapper
Xcopy "%~dp0autoupdate.bat" "%spath%"
Xcopy "%~dp0install.bat" "%spath%"
Xcopy "%~dp0LICENSE" "%spath%"
Xcopy "%~dp0RDPCheck.exe" "%spath%"
Xcopy "%~dp0RDPConf.exe" "%spath%"
Xcopy "%~dp0RDPWInst.exe" "%spath%"
Xcopy "%~dp0README.md" "%spath%"
Xcopy "%~dp0Setting.bat" "%spath%"
Xcopy "%~dp0subscription.bat" "%spath%"
Xcopy "%~dp0uninstall.bat" "%spath%"
Xcopy "%~dp0update.bat" "%spath%"
cls
echo ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
echo ┃ 〓 请选择自动更新渠道 〓         ┃
echo ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
echo ┃ 1.GitHub镜像（默认为FastGit）    ┃
echo ┃ 2.GitHub直连                     ┃
::echo ┃ 3.GitHub直连（DNS Fix） ┃
echo ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
echo 你可以稍后在"系统盘:\Program Files\RDP Wrapper"中右键"subscription.bat"编辑更新源
echo 如果你并不清楚以上功能区别，在中国请按1，不在中国请按2.
set/p "cho=[选择]"
if %cho%==1 set sub=GFW
if %cho%==2 set sub=Nor
if %cho%==3 goto menu
if %sub%==GFW (
    echo set rdpwrap_ini_update_github_1="https://raw.fastgit.org/asmtron/rdpwrap/master/res/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_2="https://raw.fastgit.org/sebaxakerhtc/rdpwrap.ini/master/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_3="https://raw.fastgit.org/affinityv/INI-RDPWRAP/master/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_4="https://raw.fastgit.org/DrDrrae/rdpwrap/master/res/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_5="https://raw.fastgit.org/saurav-biswas/rdpwrap-1/master/res/rdpwrap.ini">>"%spath%"\subscription.bat
)
if %sub%==Nor (
    echo set rdpwrap_ini_update_github_1="https://raw.githubusercontent.com/asmtron/rdpwrap/master/res/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_2="https://raw.githubusercontent.com/sebaxakerhtc/rdpwrap.ini/master/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_3="https://raw.githubusercontent.com/affinityv/INI-RDPWRAP/master/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_4="https://raw.githubusercontent.com/DrDrrae/rdpwrap/master/res/rdpwrap.ini">>"%spath%\subscription.bat"
    echo set rdpwrap_ini_update_github_5="https://raw.githubusercontent.com/saurav-biswas/rdpwrap-1/master/res/rdpwrap.ini">>"%spath%\subscription.bat"
)
echo [*] 安装已完成
explorer "%spath%"
echo 请点击autoupdate.bat以更新版本支持。
echo 在更新完配置文件后请点击RDPConf.exe中的Apply以启动。
echo 如果能在RDPCheck.exe中登陆，则已成功。
echo 你可以在Setting.bat中配置自动更新选项和修复选项