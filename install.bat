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
timeout /NOBREAK /t 3>nul
start https://github.com/yige-yigeren/rdpwrap_AutoUpdate_CN
echo 如果觉得本软件好用请去点个star吧（跪求）
timeout /NOBREAK /t 5>nul
cls
echo .
if not exist "%~dp0RDPWInst.exe" goto :error
"%~dp0RDPWInst" -i -o
echo ______________________________________________________________
echo.
echo RDPWarp主程序安装完成
echo 您可以使用RDPCheck程序检查RDP功能。
echo 还可以使用RDPConf程序配置高级设置。
echo.
goto :anykey

:error
echo [-] ERROR：没有找到安装程序可执行文件。
echo 请解压所有文件或检查你的杀毒软件是否拦截了部分文件。

:anykey
echo 请勿关闭该窗口，将在5秒后自动安装
timeout /NOBREAK /t 5>nul
cls
echo 安装自动更新组件中...
Xcopy *.* "%windir:~0,3%\Program Files\RDP Wrapper" /Q /Y
set path="%windir:~0,3%\Program Files\RDP Wrapper"
cls
echo ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
echo ┃ 〓 请选择自动更新渠道 〓         ┃
echo ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫
echo ┃ 1.GitHub镜像（默认为FastGit）    ┃
echo ┃ 2.GitHub直连                     ┃
::echo ┃ 3.GitHub直连（DNS Fix） ┃
echo ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
echo 如果你并不清楚以上功能区别，在中国请按1，不在中国请按2.
set/p "cho=[选择]"
if %cho%==1 set sub=GFW
if %cho%==2 set sub=Nor
if %cho%==3 goto menu
echo [ 错误，无此选项 ]
goto menu

if %sub%=GFW (

)
if %sub%=Nor (
    echo set rdpwrap_ini_update_github_1="https://raw.githubusercontent.com/asmtron/rdpwrap/master/res/rdpwrap.ini">>%path%/subscription.bat
    echo set rdpwrap_ini_update_github_2="https://raw.githubusercontent.com/sebaxakerhtc/rdpwrap.ini/master/rdpwrap.ini"
    echo set rdpwrap_ini_update_github_3="https://raw.githubusercontent.com/affinityv/INI-RDPWRAP/master/rdpwrap.ini"
    echo set rdpwrap_ini_update_github_4="https://raw.githubusercontent.com/DrDrrae/rdpwrap/master/res/rdpwrap.ini"
    echo set rdpwrap_ini_update_github_5="https://raw.githubusercontent.com/saurav-biswas/rdpwrap-1/master/res/rdpwrap.ini"
)