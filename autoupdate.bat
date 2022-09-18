<!-- : Begin batch script
@echo off
setLocal EnableExtensions
setlocal EnableDelayedExpansion
::                                        _                   _                
::              _                        | |      _          | |          _    
::   ____ _   _| |_  ___  _   _ ____   _ | | ____| |_  ____  | | _   ____| |_  
::  / _  | | | |  _)/ _ \| | | |  _ \ / || |/ _  |  _)/ _  ) | || \ / _  |  _) 
:: ( ( | | |_| | |_| |_| | |_| | | | ( (_| ( ( | | |_( (/ / _| |_) ( ( | | |__ 
::  \_||_|\____|\___\___/ \____| ||_/ \____|\_||_|\___\____(_|____/ \_||_|\___)
::                             |_|                                             
::
::自动RDP包装器安装和更新程序asmtron (2022-01-01) 
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::选项:
:: -log =将显示输出重定向到文件autoupdate.log
:: -taskadd =在计划任务中添加启动时autoupdate.bat的autorun
:: -taskremove =在调度任务中删除启动时autoupdate.bat的自动运行
::
::信息:
:: autopdater首先使用并检查官方的rdpwrap.ini。
:: 如果正式的rdpwrap.ini不支持新的termsrv.dll，
:: autopdater首先尝试asmtron rdpwrap.ini(已拆卸和
:: 经asmtron测试)。autopdater也将使用rdpwrap.ini文件
:: *其他贡献者，如“sebaxakerhtc, affinityv, DrDrrae, saurav-biswas”。
::额外的rdpwrap.ini源也可以被定义…
::
::{特别感谢binarymaster和所有其他贡献者}
::
:: -----------------------------------------
:: 翻译 by Yige-Yigeren
:: -----------------------------------------
:: 为了方便更改与设定更新源，已将更新源部分单独独立为文件subscription.bat
:: -----------------------------------------

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

set autoupdate_bat="%~dp0autoupdate.bat"
set subscription_bat="%~dp0subscription.bat"
set autoupdate_log="%~dp0autoupdate.log"
set RDPWInst_exe="%~dp0RDPWInst.exe"
set rdpwrap_dll="%~dp0rdpwrap.dll"
set rdpwrap_ini="%~dp0rdpwrap.ini"
set rdpwrap_ini_check=%rdpwrap_ini%
set rdpwrap_new_ini="%~dp0rdpwrap_new.ini"
set github_location=1
set retry_network_check=0
::
echo ___________________________________________
echo AutoRDPWarp安装和更新程序
echo.
echo ^<检查RDPWarp是否最新并且正在工作^>
echo.

:: 检查启动参数
if /i "%~1"=="-reset" (
    echo :: ----------------------------------------- >subscription.bat
    echo :: 更新rdpwrap.ini文件的更新源设置>>subscription.bat
    echo :: ----------------------------------------->>subscription.bat
    echo :: 更新源示例>>subscription.bat
    echo :: set rdpwrap_ini_update_github_{num}="https://raw.githubusercontent.com/{user}/{repository}/(master/main)/res/rdpwrap.ini>>subscription.bat
    echo :: ----------------------------------------->>subscription.bat
    echo [-] All subscriptions has been removed
)
if /i "%~1"=="-log" (
    echo %autoupdate_bat% output from %date% at %time% > %autoupdate_log%
    call %autoupdate_bat% >> %autoupdate_log%
    goto :finish
)
if /i "%~1"=="-taskadd" (
    echo [+] add autorun of %autoupdate_bat% on startup in the schedule task.
    schtasks /create /f /sc ONSTART /tn "RDP Wrapper Autoupdate" /tr "cmd.exe /C \"%~dp0autoupdate.bat\" -log" /ru SYSTEM /delay 0000:10
    powershell "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries; Set-ScheduledTask -TaskName 'RDP Wrapper Autoupdate' -Settings $settings"
    goto :finish
)
if /i "%~1"=="-taskremove" (
    echo [-] remove autorun of %autoupdate_bat% on startup in the schedule task^^!
    schtasks /delete /f /tn "RDP Wrapper Autoupdate"
    goto :finish
)
if /i not "%~1"=="" (
    echo [x] Unknown argument specified: "%~1"
    echo [*] Supported argments/options are:
    echo     -log         =  redirect display output to the file autoupdate.log
    echo     -reset       =  remote all 
    echo     -taskadd     =  add autorun of autoupdate.bat on startup in the schedule task
    echo     -taskremove  =  remove autorun of autoupdate.bat on startup in the schedule task
    goto :finish
)
:: check if file "RDPWInst.exe" exist
if not exist %RDPWInst_exe% goto :error_install
goto :start_check
::
:error_install
echo RDP包装器安装程序主可执行文件(rdpwin .exe)未找到^^!
echo 请从下载的包装包中提取所有文件或检查您的防病毒软件。
echo.
goto :finish
::
:start_check
set rdpwrap_installed="0"
:: ----------------------------------
:: 1) 检查TermService是否正在运行
:: ----------------------------------
sc queryex "TermService"|find "STATE"|find /v "RUNNING" >nul&&(
    echo [-] TermService不在运行^^!
    call :install
)||(
    echo [+] TermService运行中.
)
:: ------------------------------------------
:: 2) 检查监听器会话RDP-TCP是否存在
:: ------------------------------------------
set rdp_tcp_session=""
set rdp_tcp_session_id=0
if exist %windir%\system32\query.exe (
    for /f "tokens=1-2* usebackq" %%a in (
        `query session rdp-tcp`
    ) do (
        set rdp_tcp_session=%%a
        set /a rdp_tcp_session_id=%%b 2>nul
    )
) else (
    for /f "tokens=2* usebackq" %%a in (
        `reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" 2^>nul`
    ) do (
        if "%%a"=="REG_DWORD" (
            set rdp_tcp_session=AllowTSConnection
            if "%%b"=="0x0" (set rdp_tcp_session_id=1)
        )
    )
)
if %rdp_tcp_session_id%==0 (
    echo [-] 没有找到RDP-TCP监听会话^^!
    call :install
) else (
    echo [+] 找到监听会话: %rdp_tcp_session% ^(ID: %rdp_tcp_session_id%^).
)
:: -----------------------------------------
:: 3) 检查注册表中是否存在rdpwrap.dll
:: -----------------------------------------
reg query "HKLM\SYSTEM\CurrentControlSet\Services\TermService\Parameters" /f "rdpwrap.dll" >nul&&(
    echo [+] 找到windows注册表项 "rdpwrap.dll".
)||(
    echo [-] 没有找到windows注册表项 "rdpwrap.dll"^^!
    if %rdpwrap_installed%=="0" (
        call :install
    )
)
:: -----------------------------------
:: 4) 检查rdpwrap.dll文件是否存在
:: -----------------------------------
if exist %rdpwrap_dll% (
    echo [+] 找到文件: %rdpwrap_dll%
) else (
    echo [-] 没有找到文件: %rdpwrap_dll%^^!
    if %rdpwrap_installed%=="0" (
        call :install
    ) 
)
:: ------------------------------
:: 5) 检查rdpwrap.ini是否存在
:: ------------------------------
if exist %rdpwrap_ini% (
    echo [+] 找到文件: %rdpwrap_ini%.
) else (
    echo [-] 没有找到文件: %rdpwrap_ini%^^!
    if %rdpwrap_installed%=="0" (
        call :install
    )
)
:: ------------------------------
:: 6) 检查subscription.bat是否存在
:: ------------------------------
if exist %subscription_bat% (
    echo [+] 找到文件: %subscription_bat%.
    :装入更新源配置文件
    call "%~dp0subscription.bat"
) else (
    echo [-] 没有找到文件: %subscription_bat%^^!
    if %rdpwrap_installed%=="0" (
        call :install
    )
)
:: ----------------------------------------------------
:: 7) 获取termsrv所需版本信息 %windir%\System32\termsrv.dll
:: ----------------------------------------------------
for /f "tokens=* usebackq" %%a in (
    `cscript //nologo "%~f0?.wsf" //job:fileVersion "%windir%\System32\termsrv.dll"`
) do (
    set termsrv_dll_ver=%%a
)
if "%termsrv_dll_ver%"=="" (
    echo [x] 无法获取termsrv信息"%windir%\System32\termsrv.dll"^^!
    goto :finish
) else (
    echo [+] 已安装"termsrv.dll"版本: %termsrv_dll_ver%.
)
:: ----------------------------------------------------------------------------------------
:: 8) 检查已安装的文件版本是否与注册表中最后保存的文件版本不同
:: ----------------------------------------------------------------------------------------
echo [*] 正在读取注册表中的"termsrv.dll"版本信息...
for /f "tokens=2* usebackq" %%a in (
    `reg query "HKEY_LOCAL_MACHINE\SOFTWARE\RDP-Wrapper\Autoupdate" /v "termsrv.dll" 2^>nul`
) do (
    set last_termsrv_dll_ver=%%b
)
if "%last_termsrv_dll_ver%"=="%termsrv_dll_ver%" (
    echo [+] 当前dll版本信息"termsrv.dll v.%termsrv_dll_ver%"与记录中版本信息相符"termsrv.dll v.%last_termsrv_dll_ver%".
) else (
    echo [-] 当前dll版本信息"termsrv.dll v.%termsrv_dll_ver%"与记录中版本信息不符"termsrv.dll v.%last_termsrv_dll_ver%"^^!
    echo [*] 正在更新注册表中的"termsrv.dll"版本信息...
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\RDP-Wrapper\Autoupdate" /v "termsrv.dll" /t REG_SZ /d "%termsrv_dll_ver%" /f
    if %rdpwrap_installed%=="0" (
        call :install
    )
)
:: ---------------------------------------------------------------
:: 9) 检查安装的termsrv.dll版本是否在rdpwrap.ini中存在
:: ---------------------------------------------------------------
:check_update
if exist %rdpwrap_ini_check% (
    echo [*] 正在%rdpwrap_ini_check%中寻找[%termsrv_dll_ver%]版本的支持信息...
    findstr /c:"[%termsrv_dll_ver%]" %rdpwrap_ini_check% >nul&&(
        echo [+] 在文件%rdpwrap_ini_check%中找到受支持的"termsrv.dll"版本信息（[%termsrv_dll_ver%]）.
        echo [*] RDPWarp似乎是最新的，可正常工作...
    )||(
        echo [-] 在文件%rdpwrap_ini_check%中没有找到受支持的"termsrv.dll"版本信息（[%termsrv_dll_ver%]）^^!
        if not "!rdpwrap_ini_update_github_%github_location%!" == "" (
            set rdpwrap_ini_url=!rdpwrap_ini_update_github_%github_location%!
            call :update
            goto :check_update
        )
        goto :finish
    )
) else (
    echo [-] 没有找到文件: %rdpwrap_ini_check%.
    echo [*] 任务结束-请检查防病毒软件/防火墙是否阻止该文件 %rdpwrap_ini_check%^^!
    goto :finish
)
goto :finish
::
:: -----------------------------------------------------
:: 安装RDPWarp(准确地说是卸载和重新安装)
:: -----------------------------------------------------
:install
echo.
echo [*] 卸载和重装RDP Wrapper...
echo.
if exist %rdpwrap_dll% set rdpwrap_force_uninstall=1
if exist %rdpwrap_ini% set rdpwrap_force_uninstall=1
if "%rdpwrap_force_uninstall%"=="1" (
    echo [*] 在Windows注册表中卸载"rdpwrap.dll"...
    reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\TermService\Parameters" /f /v ServiceDll /t REG_EXPAND_SZ /d %rdpwrap_dll%
)
set rdpwrap_installed="1"
%RDPWInst_exe% -u
%RDPWInst_exe% -i -o
call :setNLA
goto :eof
::
:: -------------------
:: 重启RDPWarp
:: -------------------
:restart
echo.
echo [*] 通过新的版本支持文件重启RDPWarp (卸载和重装)...
echo.
%RDPWInst_exe% -u
if exist %rdpwrap_new_ini% (
    echo.
    echo [*] 使用从更新源最新下载的rdpwrap.ini…
    echo     -^> %rdpwrap_ini_url% 
    echo       -^> %rdpwrap_new_ini%
    echo         -^> %rdpwrap_ini%
    echo [+] 复制%rdpwrap_new_ini%到%rdpwrap_ini%...
    copy %rdpwrap_new_ini% %rdpwrap_ini%
    echo.
) else (
    echo [x] ERROR - 文件%rdpwrap_new_ini%丢失^^!
)
%RDPWInst_exe% -i
call :setNLA
goto :eof
::
:: --------------------------------------------------------------------
:: 从更新源下载最新版本的rdpwrap.ini
:: --------------------------------------------------------------------
:update
echo [*] check network connectivity...
:netcheck
ping -n 1 google.com>nul
if errorlevel 1 (
    goto waitnetwork
) else (
    goto download
)
:waitnetwork
echo [.] Wait for network connection is available...
ping 127.0.0.1 -n 11>nul
set /a retry_network_check=retry_network_check+1
:: wait for a maximum of 5 minutes
if %retry_network_check% LSS 30 goto netcheck
:download
set /a github_location=github_location+1
echo.
echo [*] Download latest version of rdpwrap.ini from GitHub...
echo     -^> %rdpwrap_ini_url%
for /f "tokens=* usebackq" %%a in (
    `cscript //nologo "%~f0?.wsf" //job:fileDownload %rdpwrap_ini_url% %rdpwrap_new_ini%`
) do (
    set "download_status=%%a"
)
if "%download_status%"=="-1" (
    echo [+] Successfully download from GitHhub latest version to %rdpwrap_new_ini%.
    set rdpwrap_ini_check=%rdpwrap_new_ini%
    call :restart
) else (
    echo [-] FAILED to download from GitHub latest version to %rdpwrap_new_ini%^^!
    echo [*] Please check you internet connection/firewall and try again^^!
)
goto :eof
::
:: --------------------------------
:: Set Network Level Authentication
:: --------------------------------
:setNLA
echo [*] Set Network Level Authentication in the windows registry...
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t reg_dword /d 0x2 /f
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MinEncryptionLevel /t reg_dword /d 0x2 /f
goto :eof
::
:: -------
:: E X I T
:: -------
:finish
echo.
exit /b
::
--- Begin wsf script --- fileVersion/fileDownload --->
<package>
  <job id="fileVersion"><script language="VBScript">
    set args = WScript.Arguments
    Set fso = CreateObject("Scripting.FileSystemObject")
    WScript.Echo fso.GetFileVersion(args(0))
    Wscript.Quit
  </script></job>
  <job id="fileDownload"><script language="VBScript">
    set args = WScript.Arguments
    WScript.Echo SaveWebBinary(args(0), args(1))
    Wscript.Quit
    Function SaveWebBinary(strUrl, strFile) 'As Boolean
        Const adTypeBinary = 1
        Const adSaveCreateOverWrite = 2
        Const ForWriting = 2
        Dim web, varByteArray, strData, strBuffer, lngCounter, ado
        On Error Resume Next
        'Download the file with any available object
        Err.Clear
        Set web = Nothing
        Set web = CreateObject("WinHttp.WinHttpRequest.5.1")
        If web Is Nothing Then Set web = CreateObject("WinHttp.WinHttpRequest")
        If web Is Nothing Then Set web = CreateObject("MSXML2.ServerXMLHTTP")
        If web Is Nothing Then Set web = CreateObject("Microsoft.XMLHTTP")
        web.Open "GET", strURL, False
        web.Send
        If Err.Number <> 0 Then
            SaveWebBinary = False
            Set web = Nothing
            Exit Function
        End If
        If web.Status <> "200" Then
            SaveWebBinary = False
            Set web = Nothing
            Exit Function
        End If
        varByteArray = web.ResponseBody
        Set web = Nothing
        'Now save the file with any available method
        On Error Resume Next
        Set ado = Nothing
        Set ado = CreateObject("ADODB.Stream")
        If ado Is Nothing Then
            Set fs = CreateObject("Scripting.FileSystemObject")
            Set ts = fs.OpenTextFile(strFile, ForWriting, True)
            strData = ""
            strBuffer = ""
            For lngCounter = 0 to UBound(varByteArray)
                ts.Write Chr(255 And Ascb(Midb(varByteArray,lngCounter + 1, 1)))
            Next
            ts.Close
        Else
            ado.Type = adTypeBinary
            ado.Open
            ado.Write varByteArray
            ado.SaveToFile strFile, adSaveCreateOverWrite
            ado.Close
        End If
        SaveWebBinary = True
    End Function
  </script></job>
</package>
