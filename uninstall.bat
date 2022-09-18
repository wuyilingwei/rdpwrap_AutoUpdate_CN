@echo off
if not exist "%~dp0RDPWInst.exe" goto :error
"%~dp0RDPWInst" -u
echo.
goto :anykey
:error
echo [-] 没有找到卸载程序可执行文件。
echo 请从下载的压缩包中解压所有文件或检查您的杀毒软件。
:anykey
pause
