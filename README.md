# rdpwrap_AutoUpdate_CN
RDP Wrapper Autoupdate 中文汉化版（包含GitHub国内支持）

## 本项目用到了以下开源项目项目
[RDPwrap](https://github.com/stascorp/rdpwrap/) [RDPwarpAutoupdate](https://github.com/asmtron/rdpwrap)

## 修改

首先对于功能进行了汉化，以及整合到了一个安装包内，以及内置提供了绕过GFW的方法。（请注意RDPConf.exe并没有进行汉化，不会有人连Apply都不会点吧~~才不是我懒了~~）

主要分为使用FastGit国内镜像及~~直接修改hosts~~(暂时没写，因为仅适用于没有SNI阻断的情况)

如果你的地区可以稳定直连也可以选择不启用

如果Fastgit你觉得不好用也可以替换为你喜欢的Github镜像网站

另外对于原软件进行了功能添加和补全（比如请求管理员权限）

注意：本项目仅提供汉化及更新支持

且因为手头上只有win10/win11的x64电脑，所以部分安装逻辑只支持win10及以后的
x64电脑（理论上兼容win7），需要x86支持可以提。

暂不对日志进行翻译，反正是给开发者看的＞﹏＜

有功能性问题去原仓库提

## RDPwarp和自动更新

信息:

autopdater首先会尝试官方的rdpwrap.ini。如果正式的rdpwrapper .ini中不支持新的termsrv.dll（远程桌面连接所需dll，该dll可能因为更新而令旧版本失效）, autoupdater首先会尝试asmtron rdpwrapper .ini。autopdater还将使用其他贡献者的rdpwrap.ini文件。

你也可以自定义自己的rdpwarp更新源

### autoupdate.bat可用的参数:

-log =将显示输出重定向到文件autoupdate.log

-taskadd =在计划任务程序中添加自启动

-taskremove =在计划任务程序中删除自启动