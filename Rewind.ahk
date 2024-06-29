;lastest - v2.0 in 2024/6/29 by NIKI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;variable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;address
global codeAddress := "D:\A_code\Cpp\diy\"
global appAddress := "D:\APP_PATHS\"

global iniFileAddress := codeAddress . "useless.ini"
global hotspotAddress := codeAddress . "wf.bat"
global ahkFileAddress := codeAddress . "Rewind.ahk"

global vscodeAddress := appAddress . "Microsoft VS Code\Code.exe"
global typoraAddress := appAddress . "Typora\Typora.exe"
global listaryAddress := appAddress . "Listary\Listary.exe"

;;strings
global keys := ["idNum", "phoneNum", "studentNum", "QQ", "QQmail", "Gmail", "studentPassword", "generalPassword"]
global idNum := "", phoneNum := "", studentNum := "", QQ := "", QQmail := "", Gmail := "", studentPassword := "", generalPassword := ""

for _, key in keys {
    IniRead, %key%, %iniFileAddress%, default, %key%
}

global urlHead := "http://10.0.3.2:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=%2C0%2C" . studentNum . "&user_password=" . studentPassword . "&wlan_user_ip="
global urlTail := "&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=172.16.254.2&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=8407&lang=zh"

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;hotstrings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
::id\::
    SendInput %idNum%
Return
::nm\::
    SendInput %phoneNum%
Return
::cd\::
    SendInput %generalPassword%
Return
::qm\::
    SendInput %QQmail%
Return
::gm\::
    SendInput %Gmail%
Return
::qq\::
    SendInput %QQ%
Return
::no\::
    SendInput %studentNum%
Return
::rf\::
    RunWait, %ComSpec% /c taskkill /f /im explorer.exe & start explorer.exe,, Hide
Return
::hs\::
    Hotspot()
Return
::sl\::
    DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return
::lk\::
    FastTip(GDUT())
Return
::dc\::
    TryDeconnectWifi()
Return
::ty\::
    Run, %typoraAddress%
Return
::lt\::
    Run, %listaryAddress%
Return
::szk\::
    ; %ComSpec% is for simple commands
    ; % ComSpec is for commands that need transformation
    RunWait, %ComSpec% /c adb devices , , Hide
    RunWait, %ComSpec% /c adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh , , Hide
Return
~Right & /::
    Loop, % 4
    {
        Sleep 10
        SendInput {Right}
    }
Return
~left & /::
    Loop, % 4
    {
        Sleep 10
        SendInput {left}
    }
Return
~Up & /::
    SoundSet +5
Return
~Down & /::
    SoundSet -5
Return
^`::
    Run %vscodeAddress% %ahkFileAddress%
Return
Alt & x::
    SendInput {AppsKey}
Return
::``::
    SendInput {BackSpace}
    Run, %ahkFileAddress%
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Hotspot(){
    Run cmd.exe %hotspotAddress%
}

;fast msgbox
FastMsg(text){
    MsgBox, , FastMsg, %text% ,
}

;fast tip with custom position
FastTip(text){
    text := " " . text . " "

    SysGet, screenWidth, 78
    SysGet, screenHeight, 79
    singleWidth := 9

    textWidth := StrLen(text) * singleWidth

    xPosition := (screenWidth / 2) - (textWidth / 2)
    yPosition := screenHeight * 0.7

    ToolTip, %text%, %xPosition%, %yPosition%
    Sleep, 3000
    ToolTip
}

;full action for campus-wifi connection
GDUT(){
    if(!NetshCommand("netsh wlan show networks mode=bssid", "gdut")){ ;Is wifi nearby?
        Return "wifi not found"
    }

    if(!NetshCommand("netsh wlan show interface | findstr gdut", "gdut")){ ;Is wifi connected?
        if(!NetshCommand("netsh wlan connect name=gdut", "³É¹¦")){ ;Try if is able to connect?
            Return "failed to connect wifi"
        }
    }else{
        if(TryLoginWifi()) ;Try login your account
            Return ""
        Return "already connected"
    }

    num := 1
    While(num != 11){
        if(TryLoginWifi())
            Return ""
        num++
        Sleep, 500
    }

    Return "failed to GET"
}

;commmand-try action - do cmd order and get a response from it
;save text through clipboard
NetshCommand(order, hope){
    Try
    {
        clipSaved := ClipboardAll
        Clipboard := ""
        RunWait, % ComSpec " /c " . order . " | CLIP",, Hide
        ClipWait,2
        cmdInfo := Clipboard
        Clipboard := clipSaved

        if(hope="")
            Return True
        Return InStr(cmdInfo, hope, False, 1, 1) > 0 ;check if str.cmdInfo is including str.hope
    }Catch {
        Return False
    }
}

;deconnect current wifi
TryDeconnectWifi(){
    Return NetshCommand("netsh wlan disconnect","")
}

;network request - true -> login ok
TryLoginWifi(){
    fullUrl := urlHead . GetIPAddress() . urlTail

    Try {
        Connection := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        Connection.Open("GET", fullUrl, true,"","",1500)
        Connection.Send()
        Connection.WaitForResponse()
        FastTip(Connection.responseText)
        Return Connection.responseText != ""
    }Catch {
        Return False
    }
}

;get ipAddress
;might be something about database
GetIPAddress() {
    Try {
        service := ComObjGet("winmgmts:")
        colItems := service.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=TRUE",,48)

        for colItem in colItems
            for address in colItem.IPAddress {
                if (address != "0.0.0.0") {
                    IPAddress := address
                    Break 2
                }
            }
    }

    Return IPAddress
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;the IFs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; #IF GetKeyState("capslock","T")
;     0::Numpad0
;     1::Numpad1
;     2::Numpad2
;     3::Numpad3
;     4::Numpad4
;     5::Numpad5
;     6::Numpad6
;     7::Numpad7
;     8::Numpad8
;     9::Numpad9
;     .::NumpadDot
;     +::NumpadAdd
;     -::NumpadSub
;     *::NumpadMult
;     del::NumpadDel
;     /::NumpadDiv
;     Up::NumpadUp
;     Down::NumpadDown
;     Left::NumpadLeft
;     Right::NumpadRight
;     Enter::NumpadEnter
; #If
; Return