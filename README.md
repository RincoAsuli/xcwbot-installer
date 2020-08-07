# 小仓唯bot 一键安装脚本

## Windows

**仅限 Windows 10 64位 系统运行**

**推荐在干净的，之前没有装过类似的bot的环境中运行**

在合适的位置(**路径不要有中文**)打开 `powershell` 中执行：

```powershell
Invoke-WebRequest http://ftp.pcrbotlink.top/install.ps1 -OutFile .\install.ps1 ; powershell -File install.ps1
```

**注：提示"无法加载文件 ./install.ps1，因为在此系统中禁止执行脚本。有关详细信息，请参阅 "get-help about_signing"。"？
      解决方法：管理员运行powershell，执行"set-ExecutionPolicy RemoteSigned"，选择"[Y] 是(Y)"。**

## Linux

**没有linux，对不起，我太菜了**
