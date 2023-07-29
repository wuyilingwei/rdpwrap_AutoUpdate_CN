# rdpwrap_AutoUpdate_CN

RDP Wrapper Autoupdate 中文汉化版（包含GitHub国内支持）

破解Windows RDP对于连接数量与不能同时在线的问题

## 本项目发行包中已内置了以下开源仓库的发行版
[RDPwrap](https://github.com/stascorp/rdpwrap/) v1.6.2；[RDPwarpAutoupdate](https://github.com/asmtron/rdpwrap)2022-01-01（有修改）

## 主要功能

破解Windows RDP（远程桌面连接）的相关限制，使其可多个用户同时在线

整合了RDPWarp与更新配置文件

Windows Vista及以上受RDPWarp支持，但本项目及RDPwarpAutoupdate部分内容仅做了Windows 10 x64及以上支持（理论兼容Windows 7）

## 安装

[下载整合包](https://github.com/yige-yigeren/rdpwrap_AutoUpdate_CN/releases)

~~直接下载Source code(zip)压缩包即可~~ 为什么直接下载源码有问题（骂骂咧咧）

运行install.bat，它会自动完成安装过程并打开安装文件夹

在打开的文件夹中运行autoupdate.bat，直到RDPConf.exe打开后右侧显示[full support]。

尝试运行RDPCheck.exe，如果能登录即为成功。

使用Setting.bat配置程序行为。

## 一些进阶配置的简单教学

**配置Windows更新延后 （推荐）**

打开组策略 - 计算机配置 - 管理模板 - Windows组件 - Windows更新 - 管理从Windows更新提供的更新 - 功能和质量更新推荐配置为14天（避免出现windows更新了但破解更新源没更新的尴尬问题）

家庭版请先启用组策略，本项目不提供相关教程，请自行[搜索](https://www.bing.com/search?q=%E5%AE%B6%E5%BA%AD%E7%89%88%E6%B7%BB%E5%8A%A0%E7%BB%84%E7%AD%96%E7%95%A5)。

**配置公网访问**

推荐[Sakura Frp](https://www.natfrp.com/) (推荐理由：免费可用，易操作)

根据你的需求和地理位置/网络环境选择节点，选择TCP隧道，隧道名称随意，本地端口选远程桌面3389，地址选127.0.0.1，接下来在用户处获取访问密钥，下载客户端用密钥登录开启端口和服务即可。

手机/电脑/平板均可以找到微软官方的远程桌面软件，填入节点:选节点时填的端口（不是3389那个，找不到打开配置文件remote_port = 那个）即可登录。客户端日志中有怎么连接的提示。

月度流量是5G+每日签到，日均近3个G，按理来说是够的，速度（10 Mibps）也算够，不够的话建议买流量包或会员[支持](https://www.natfrp.com/purchase/buy)一下，一个月10块真不贵，买完流量（71G+每日签到）和速率（24 Mibps）怎么算都够了。

另：推荐选择两个节点，避免节点出现问题导致无法登录又线下没法去的尴尬情况。

广告费结一下（bushi）

有其他推荐的内网穿透建议可以提issue

**DNS和加速**

Sakura Frp部分节点和github均有可能被阻断，推荐使用安全DNS（1.1.1.1或8.8.8.8），采取加速措施（steam++/cloudflare等），避免因特殊网络情况导致的更新/连接节点失败。

**多用户均衡负载+避免高负载情况下远程桌面中断**

推荐使用[Process Lasso](https://bitsum.com/)，有助于控制CPU和RAM均衡负载，确保稳定多用户体验，同时建议将Sakura Frp和本程序相关进程优先级设置为高于标准/高，确保高负载情况下远程桌面不会中断并且始终有足够的资源。

## 关于本程序

首先对于RDP Wrapper Autoupdate功能进行了汉化，以及整合到了一个安装包内，并内置提供了绕过GFW获取配置文件更新（GFW可能导致github部分内容获取不正常）的方法。（请注意RDPConf.exe并没有进行汉化，不会有人连Apply都不会点吧~~才不是我懒了~~）

主要方式分为使用FastGit国内镜像及~~直接修改hosts~~(暂时没写，因为仅适用于没有SNI阻断的情况)

如果你的地区可以稳定直连也可以选择不启用，Fastgit你觉得不好用也可以替换为你喜欢的Github镜像网站。反正你要确保更新源是有效的

另外对于原软件进行了功能添加和补全（比如主动请求管理员权限）

注意：本项目提供汉化支持，作者自己脑洞大开的又增加了一些功能和分块，仅提供这些方面的技术支持。

且因为手头上只有win10/win11的x64电脑，所以部分安装逻辑只支持win10及以后的
x64电脑（理论上兼容win7x64），需要x86支持可以提。

暂不对命令行参数进行汉化以确保兼容性

有功能性问题去原仓库提

## RDPwarp和自动更新

信息:

autopdater首先会尝试官方的rdpwrap.ini。如果正式的rdpwrapper .ini中不支持新的termsrv.dll（远程桌面连接所需dll，该dll可能因为更新而令旧版本失效）, autoupdater首先会尝试asmtron rdpwrapper .ini。autopdater还将使用其他贡献者的rdpwrap.ini文件。

你也可以自定义自己的rdpwarp更新源

### autoupdate.bat可用的参数:

-log =将显示输出重定向到文件autoupdate.log

-reset =清除subscription文件中所有已有订阅源并提供示例(new)

-taskadd =在计划任务程序中添加自启动

-taskremove =在计划任务程序中删除自启动

<p align="center">
  <a href="https://star-history.com/#yige-yigeren/rdpwrap_AutoUpdate_CN&Date">
    <img src="https://api.star-history.com/svg?repos=yige-yigeren/rdpwrap_AutoUpdate_CN&type=Date" alt="Star History Chart">
  </a>
</p>

---

Copyright (C) 2023 Yige-Yigeren

使用本项目需同时遵守[反劳动压迫许可证](https://github.com/yige-yigeren/rdpwrap_AutoUpdate_CN/blob/main/Additional_LICENSE_CN)
