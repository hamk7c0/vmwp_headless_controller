# vmwp_headless_controller

VMware Workstation Player を Headless で起動/停止/リセット/サスペンドするためのスクリプト

![demo](https://user-images.githubusercontent.com/37047035/215318011-4aaa1825-fe69-468f-b16f-c59657b6e1cb.png)

## 特徴

VMware Workstation Player 上の仮想マシンを、GUIの画面を表示せずに起動/停止/サスペンドします

## テスト環境

* Windows 10 Pro 22H2
* VMWare Workstation 17 Player


## 使い方
### 前提
VMWare Workstation Player をインストールした環境でスクリプト内の以下の変数を設定してください
* \$INIFILE : preferences.ini のパス (デフォルト値 : \$env:USERPROFILE\Application Data\VMware\preferences.ini )
* \$EXEFILE : vmrun.exe のパス (デフォルト値 : c:\Program Files (x86)\VMware\VMware Player\vmrun.exe )
### コマンド

```powershell
List a virtual machine with Workstation on a Windows host
  .\vmwp_headless_controller.ps1 list

Resetting a virtual machine with Workstation on a Windows host
  .\vmwp_headless_controller.ps1 reset [<VirtualMachineName>]

Starting a virtual machine with Workstation on a Windows host
  .\vmwp_headless_controller.ps1 start [<VirtualMachineName>]

Stopping a virtual machine with Workstation on a Windows host
  .\vmwp_headless_controller.ps1 stop [<VirtualMachineName>]

Suspending a virtual machine with Workstation on a Windows host
  .\vmwp_headless_controller.ps1 suspend [<VirtualMachineName>]

```

## 注意点

スクリプトを実行するため、実行ポリシーは `RemoteSigned` 等に変更してください。  
https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.3

## ライセンス
Apache License 2.0