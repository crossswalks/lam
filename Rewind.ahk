;lastest - v2.0 in 2024/6/29 by NIKI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;appAddresses
global codeAdd := A_ScriptDir . "\"
global appAdd := "D:\APP_PATHS\"
global pfAdd := "C:\Program Files\"

global iniFileAdd := codeAdd . "useless.ini"
global hotspotAdd := codeAdd . "wf.bat"
global ahkFileAdd := codeAdd . "Rewind.ahk"

global vscodeAdd := appAdd . "Microsoft VS Code\Code.exe"
global typoraAdd := appAdd . "Typora\Typora.exe"
global listaryAdd := appAdd . "Listary\Listary.exe"
global ccleanerAdd := appAdd . "CCleaner\CCleaner64.exe"
global ocsAdd := appAdd . "OCS Desktop\OCS Desktop.exe"
global steamAdd := appAdd . "Steam\steam.exe"

global xiaomiAdd := pfAdd . "MI\XiaomiPCManager\Launch.exe"

global wattAdd := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Watt Toolkit\Watt Toolkit.lnk"

;;strings
global keys := ["idNum", "phoneNum", "studentNum", "QQ", "QQmail", "Gmail", "studentPassword", "generalPassword"]
global idNum := "", phoneNum := "", studentNum := "", QQ := "", QQmail := "", Gmail := "", studentPassword := "", generalPassword := ""

;way to get read those strings for global keys
for _, key in keys
{
    IniRead, %key%, %iniFileAdd%, default, %key%
}

if(phoneNum = "") ;a warning for initialization failure
    FastMsg("Configuration file not found!`ncheck if you have correctly prepare the file, or contact my mail: 3405233095@qq.com")

global loginHeadUrl := "http://10.0.3.2:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=%2C0%2C" . studentNum . "&user_password=" . studentPassword . "&wlan_user_ip="
global loginTailUrl := "&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=172.16.254.2&wlan_ac_name=&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=8407&lang=zh"
global logoutHeadUrl := "http://10.0.3.6:801/eportal/portal/logout?callback=dr1002&login_method=1&user_account=drcom&user_password=123&ac_logout=1&register_mode=1&wlan_user_ip="
global logoutTailUrl := "&wlan_user_ipv6=&wlan_vlan_id=1&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&v=2468&lang=zh"
global aiUrl := "https://arena.lmsys.org"
global youdaoUrl := "https://fanyi.youdao.com/index.html#/"
global githubUrl := "https://github.com/"

Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;hotstrings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;%ComSpec% is for simple commands
;% ComSpec is for commands that need transformation
::id\::
    SendInput % idNum
Return
::nm\::
    SendInput % phoneNum
Return
::cd\::
    SendInput % generalPassword
Return
::qm\::
    SendInput % QQmail
Return
::gm\::
    SendInput % Gmail
Return
::qq\::
    SendInput % QQ
Return
::ahk\::
    SendInput Autohotkey v1
Return
::no\::
    SendInput % studentNum
Return
::rf\::
    RunWait %ComSpec% /c taskkill /f /im explorer.exe & start explorer.exe, , Hide
Return
::hs\::
    Hotspot()
Return
::sl\::
    DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return
::dl\::
    Run C:\Users\%A_UserName%\Downloads
Return
::lk\::
    FastTip(Gdut())
Return
::dc\::
    TryDeconnectWifi()
Return
::ty\::
    Run % typoraAdd
Return
::lt\::
    Run % listaryAdd
Return
::xm\::
    Run % xiaomiAdd
Return
::ocs\::
    Run % ocsAdd
Return
::cc\::
    Run % ccleanerAdd
Return
::st\::
    Run % steamAdd
::wt\::
    Run % wattAdd
Return
::ai\::
    Run % aiUrl
Return
::yd\::
    Run % youdaoUrl
Return
::gh\::
    Run % githubUrl
Return
::sc\::
    InputBox term, new search, enter your term:, , 330, 130
    if (!ErrorLevel && term != "") ;did not cancel -> search
        Run https://cn.bing.com/search?q=%term%
Return
::szk\::
    RunWait %ComSpec% /c adb devices, , Hide
    RunWait %ComSpec% /c adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh, , Hide
Return
~Right & /::
    Loop % 4
    {
        Sleep 10
        SendInput {Right}
    }
Return
~left & /::
    Loop % 4
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
    Run %vscodeAdd% %ahkFileAdd%
Return
Alt & x::
    SendInput {AppsKey}
Return
::``::
    SendInput {BackSpace}
    Run % ahkFileAdd
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Hotspot()
{
    Run % hotspotAdd
}

;fast msgbox
FastMsg(content)
{
    MsgBox % content
}

;fast tip with custom position
FastTip(content)
{
    content := content = "" ? null : content

    SysGet screenWidth, 78
    SysGet screenHeight, 79

    singleWidth := 9
    contentWidth := StrLen(content) * singleWidth

    xPosition := (screenWidth / 2) - (contentWidth / 2)
    yPosition := screenHeight * 0.7

    ToolTip %content%, %xPosition%, %yPosition%
    Sleep 3000
    ToolTip
}

;complete campus network connection function
Gdut()
{
    if(!IsWifiNearby("gdut")) ;check if it is nearby
        Return "wifi not found"

    if(IsWifiConnected("gdut")) ;check if it is connected
    {
        if(TryLoginGdut())
            Return ""
        Return "already connected"
    }
    else
    {
        if(!TryConnectWifi("gdut"))
            Return "failed to connect wifi"
    }

    num := 1
    While(num != 11)
    {
        if(TryLoginGdut())
            Return ""
        num++
        Sleep 500
    }

    Return "failed to GET"
}

;run a commmand and get response
;save content through clipboard
NetshCommand(order, hope)
{
    Try
    {
        clipSaved := ClipboardAll
        Clipboard := ""
        RunWait % ComSpec " /c " . order . " | CLIP", , Hide
        ClipWait 2
        cmdInfo := Clipboard
        Clipboard := clipSaved

        if(hope="")
            Return True
        Return InStr(cmdInfo, hope, False, 1, 1) > 0 ;check if "cmdInfo" is including "hope"
    }
    Catch
    {
        Return False
    }
}

;return if wifi is nearby
IsWifiNearby(ssid)
{
    Return NetshCommand("netsh wlan show networks mode=bssid", ssid)
}

;return if wifi is connected
IsWifiConnected(ssid)
{
    Return NetshCommand("netsh wlan show interface | findstr " . ssid, ssid)
}

;return if is able to connect
TryConnectWifi(ssid)
{
    v := NetshCommand("netsh wlan connect name=" . ssid, "³É¹¦")
    if(v = 1)
        FastTip("wifi connected")
    Return v = 1
}

;read a specific value from a json string
GdutMsgReader(json)
{
    RegExMatch(json, "i)""msg""\s*:\s*""(.+?)""", data)
    return data1
}

;deconnect current wifi
TryDeconnectWifi()
{
    if(IsWifiConnected("gdut"))
        TryLogoutGdut()
    NetshCommand("netsh wlan disconnect","")

    Sleep 500 ;the system has a delay
    FastTip("wifi deconnected")
}

;get ipAddress
;might be something about database
GetIPv4Add()
{
    Try
    {
        for address in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=TRUE",,48).IPAddress
            if (address != "0.0.0.0")
                Return address
    }
}

;Try login your account
;network request: true -> login ok
TryLoginGdut()
{
    fullUrl := loginHeadUrl . GetIPv4Add() . loginTailUrl

    Try
    {
        Connection := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        Connection.Open("GET", fullUrl, true, "", "", 1500)
        Connection.Send()
        Connection.WaitForResponse()

        FastTip(GdutMsgReader(Connection.responseText))
        Return Connection.responseText != ""
    }
    Catch
    {
        Return False
    }
}

;Try logout your account
TryLogoutGdut()
{
    fullUrl := logoutHeadUrl . GetIPv4Add() . logoutTailUrl

    Try
    {
        Connection := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        Connection.Open("GET", fullUrl, true, "", "", 1500)
        Connection.Send()
        Connection.WaitForResponse()

        FastTip(GdutMsgReader(Connection.responseText))
        Return Connection.responseText != ""
    }
    Catch
    {
        Return False
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;the IFs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; #IF GetKeyState("capslock", "T")
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