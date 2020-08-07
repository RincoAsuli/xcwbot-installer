$ErrorActionPreference = "Inquire"

$host.ui.RawUI.WindowTitle = "小仓唯bot一键安装脚本"

# 欢迎
Write-Output '欢迎使用小仓唯bot一键安装脚本！小仓唯bot是基于 hoshino 与 yobot 的一个综合性公主连结机器人，功能繁多，操作简单，安装便捷。
安装过程马上开始，全程耗时较长，预计需要30分钟，请耐心等待...'

# 检查运行环境
if ($Host.Version.Major -lt 5) {
    Write-Output 'Powershell 版本过低，请升级之后再试...'
    exit
}
if ((Get-ChildItem -Path Env:OS).Value -ine 'Windows_NT') {
    Write-Output '当前操作系统不支持一键安装...'
    exit
}
if ([Environment]::Is64BitProcess) {
}
else {
    Write-Output '本bot不支持32位系统安装...'
    exit
}

if (Test-Path .\xcwbot) {
    Write-Output '发现重复，是否删除旧文件并重新安装？'
    $reinstall = Read-Host '请输入 y 或 n (y/n)'
    Switch ($reinstall) { 
        Y { Remove-Item .\xcwbot -Recurse -Force } 
        N { exit } 
        Default { exit } 
    } 
}

$loop = $true
while ($loop) {
    $loop = $false
    Write-Output '是否需要安装 Python 3.8?'
    Write-Output 'y：我没有安装，请帮我安装'
    Write-Output 'n：我已经安装，不用了'
    $user_in = Read-Host '请输入 y 或 n (y/n)'
    Switch ($user_in) {
        Y { $install_python = $true }
        N { $install_python = $false }
        Default { $loop = $true }
    }
}

$loop = $true
while ($loop) {
    $loop = $false
    Write-Output '是否需要安装 git?'
    Write-Output 'y：我没有安装，请帮我安装'
    Write-Output 'n：我已经安装，不用了'
    $user_in = Read-Host '请输入 y 或 n (y/n)'
    Switch ($user_in) {
        Y { $install_git = $true }
        N { $install_git = $false }
        Default { $loop = $true }
    }
}

# 用户输入
$qqid = Read-Host '请输入作为机器人的QQ号'
$qqpassword = Read-Host '请输入作为机器人的QQ密码'
$hostqqid = Read-Host '请输入作为主人的QQ号'
$port = Read-Host '请输入要监听的端口号(建议使用8080)'

# 提示
write-Output "您机器人的QQ号为${qqid},密码为${qqpassword},主人QQ号为${hostqqid},端口号为${port}。
下面即将进行依赖安装和配置设置，如确认无误，请按任意键继续。"
[void][System.Console]::ReadKey($true)
write-Output "提示：只要报错之后还能继续执行下去，那就可以暂时忽略，若最后还不能正常运行，再考虑排错，运行bot时同理。
另外，安装python和git时需要管理员权限，若没有自动弹出授权窗口，请看看任务栏。
如您还遇到了其他问题，请查看同目录下的常见问题解答.txt
了解后请按任意键继续。"
[void][System.Console]::ReadKey($true)

# 创建文件夹
New-Item -Path .\xcwbot -ItemType Directory
Set-Location xcwbot
New-Item -ItemType Directory -Path .\mirai\plugins, .\mirai\plugins\CQHTTPMirai, .\HoshinoBot\hoshino\modules\yobot

# 下载帮助
Invoke-WebRequest http://ftp.pcrbotlink.top/QA.txt -OutFile .\常见问题解答.txt

# 下载安装程序
Write-Output "正在下载安装程序，体积较大，耗时会较长，请耐心等待..."
Invoke-WebRequest https://oscarlongsslz.yobot.win/one-key-xcw.zip -OutFile one-key-xcw.zip
Expand-Archive one-key-xcw.zip -DestinationPath .\
Invoke-WebRequest http://ftp.pcrbotlink.top/miraiOK_windows_386.exe -OutFile .\mirai\miraiOK.exe

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($install_python) {
    Write-Output "正在安装 python，请耐心等待..."
    Invoke-WebRequest https://mirrors.huaweicloud.com/python/3.8.5/python-3.8.5-amd64.exe -OutFile .\python-3.8.5.exe
    Start-Process -Wait -FilePath .\python-3.8.5.exe -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
    Write-Output "python 安装成功"
}
if ($install_git) {
    Write-Output "正在安装 git，请耐心等待..."
    Invoke-WebRequest https://mirrors.huaweicloud.com/git-for-windows/v2.28.0.windows.1/Git-2.28.0-64-bit.exe -OutFile .\git-2.28.0.exe
    Start-Process -Wait -FilePath .\git-2.28.0.exe -ArgumentList "/SILENT /SP-"
    $env:Path += ";C:\Program Files\Git\bin"  # 添加 git 环境变量
    Write-Output "git 安装成功"
}

# 拷贝插件
Copy-Item .\插件\*.jar .\mirai\plugins
Set-Location .\HoshinoBot\hoshino\modules\yobot

# 从 github 拉取 yobot
git init
git submodule add https://gitee.com/yobot/yobot.git

# 安装 python 依赖
Write-Output "正在安装依赖，预计需要5~15分钟，请耐心等待..."
Set-Location ..\..\..\..\
py -3.8 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r HoshinoBot/requirements.txt
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r HoshinoBot/hoshino/modules/yobot/yobot/src/client/requirements.txt
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r HoshinoBot/hoshino/modules/eqa/requirements.txt

# 写入 miraiOK 配置文件
if (Test-Path .\mirai\config.txt) {
    Set-Content -Path .\mirai\config.txt -Value "----------`nlogin ${qqid} ${qqpassword}`n"
}
else {
    New-Item -Path .\mirai\config.txt -ItemType File -Value "----------`nlogin ${qqid} ${qqpassword}`n"
}

# 写入 cqmiraihttp 配置文件
if (Test-Path .\mirai\plugins\CQHTTPMirai\setting.yml) {
    Set-Content -Path .\mirai\plugins\CQHTTPMirai\setting.yml -Value @"
"${qqid}":
  ws_reverse:
    - enable: true
      postMessageFormat: string
      reverseHost: 127.0.0.1
      reversePort: ${port}
      reversePath: /ws/
      reconnectInterval: 3000
  http:
    enable: false   
    host: 0.0.0.0   
    port: 5700   
    accessToken: ""   
    postUrl: ""
    postMessageFormat: string
    secret: ""
  ws:
    enable: false
    postMessageFormat: string
    accessToken: ""
    wsHost: "0.0.0.0"
    wsPort: 6700
"@
}
else {
    New-Item -Path .\mirai\plugins\CQHTTPMirai\setting.yml -ItemType File -Value @"
"${qqid}":
  ws_reverse:
  -  enable: true
     postMessageFormat: string
     reverseHost: 127.0.0.1
     reversePort: ${port}
     reversePath: /ws/
     reconnectInterval: 3000
  http:
    enable: false   
    host: 0.0.0.0   
    port: 5700   
    accessToken: ""   
    postUrl: ""
    postMessageFormat: string
    secret: ""
  ws:
    enable: false
    postMessageFormat: string
    accessToken: ""
    wsHost: "0.0.0.0"
    wsPort: 6700
"@
}


# 创建文件夹(二度)
New-Item -ItemType Directory -Path .\HoshinoBot\hoshino\modules\yobot\yobot\src\client\yobot_data

# 写入 yobot 配置文件
New-Item -Path .\HoshinoBot\hoshino\modules\yobot\yobot\src\client\yobot_data\yobot_config.json -ItemType File -Value @"
{
    "port": "${port}",
    "super-admin": [
        ${hostqqid}
    ]
}
"@

# 替换 yobot 帮助文件
Copy-Item .\res\help.html .\HoshinoBot\hoshino\modules\yobot\yobot\src\client\public\template

# 写入 hoshino 配置文件
Add-Content .\HoshinoBot\hoshino\config\__bot__.py "`r`nPORT =$port`r`nSUPERUSERS = [$hostqqid]`r`nRES_DIR = r'$PSScriptRoot\res'`r`n"

# 结束流程
write-host "即将启动小仓唯bot，感谢您的使用。如有问题请阅读参考文档或者询问他人..."

# 启动程序
Start-Process -FilePath .\HoshinoBot\start.bat -WorkingDirectory .\HoshinoBot
Start-Process -FilePath .\mirai\miraiOK.exe -WorkingDirectory .\mirai

# 创建快捷方式
$desktop = [Environment]::GetFolderPath("Desktop")

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("${desktop}\mirai-请先打开这个.lnk")
$Shortcut.TargetPath = "${pwd}\mirai\miraiOK.exe"
$Shortcut.WorkingDirectory = "${pwd}\mirai\"
$Shortcut.Save()

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("${desktop}\启动小仓唯.lnk")
$Shortcut.TargetPath = "${pwd}\HoshinoBot\start.bat"
$Shortcut.WorkingDirectory = "${pwd}\HoshinoBot\"
$Shortcut.Save()