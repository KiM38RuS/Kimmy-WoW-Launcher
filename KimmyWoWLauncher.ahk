#Requires AutoHotkey v2.0

#SingleInstance Force ; Пропуск диалогового окна при запуске скрипта в случае если скрипт уже запущен. Аналогично функции Reload.

; Закрытие других версий того же скрипта
CloseOtherVersions("KimmyWoWLauncher")

; === Настройка игр и скриптов (Чтение настроек из INI, ЗАДАЁТ ПОЛЬЗОВАТЕЛЬ) ===
iniPath := A_ScriptDir "\KimmyWoWLauncher.ini"
scriptVer := "v1.0"

if !FileExist(iniPath) { ; Проверяем, существует ли ini
    defaultIni := "
    (
; ==========================================================
; KimmyWoWLauncher.ini
; ==========================================================
; Привет! 👋
; Чтобы всё работало, сделай так:
; 1) Выведи на рабочий стол ярлыки запуска WoW или лаунчеров WoW
; 2) Впиши в переменные gameName1..5 соответствующие имена ярлыков
;    Например:
;    gameName1=WoW Circle 8.3.7
;    gameName2=Firestorm Launcher
;
; Пароли связаны с играми по номерам. Например, пароль password1
; будет скопирован при запуске gameName1
; 
; Когда закончишь редактирование этого файла, сохрани его
; и перезапусти Kimmy WoW Launcher (ПКМ по кнопке настроек ⚙)
; ==========================================================

[Games]
gameName1=
gameName2=
gameName3=
gameName4=
gameName5=

[Passwords]
password1=
password2=
password3=
password4=
password5=

[Scripts]
scriptName1=
scriptName2=
scriptName3=
scriptName4=
scriptName5=
    )"

    FileAppend(defaultIni, iniPath, "UTF-8")
	
    ; показываем сообщение
    MsgBox("Здравствуй, путник.`nПрисядь у костра и заполни ini-файл, который сейчас откроется.", "Первый запуск")

    ; открываем ini
    Run(iniPath)
}

gamesExist := false
Loop 5 {
    val := IniRead(iniPath, "Games", "gameName" A_Index, "")
    if (val != "") {
        gamesExist := true
        break
    }
}

gameName   := []
password   := []
scriptName := []

Loop 5 {
    i := A_Index
    gameName.Push(IniRead(iniPath, "Games", "gameName" i, ""))
    password.Push(IniRead(iniPath, "Passwords", "password" i, ""))
    scriptName.Push(IniRead(iniPath, "Scripts", "scriptName" i, ""))
}

; Задание пути к файлам игр и скриптов
game := []
for i, name in gameName {
    if (name != "") {
        game.Push(A_Desktop "\" name ".lnk")
    } else {
        game.Push("")
    }
}
script := []
for i, name in scriptName {
    if (name != "") {
        script.Push(A_Desktop "\" name ".lnk")
    } else {
        script.Push("")
    }
}

; === Интерфейс ===
myGui := Gui("", "Kimmy WoW Launcher")
myGui.SetFont("s10", "Segoe UI")
; Верхняя строка: Игры:, версия, Настройки
if (gamesExist) {
	myGui.AddText("xm", "Игры:")
} else {
    ; === если игр нет ===
	myGui.SetFont("s10 bold")  ; ставим жирный шрифт (s10 = размер)
    myGui.AddText("xm", "Игры не заданы.`nОтредактируй ini-файл и перезапусти лаунчер`n(ПКМ по кнопке настроек ⚙)")
}
settingsBtn := myGui.Add("Button", "xs+285 yp-4 w25 h25", "⚙")
myGui.SetFont("s10 norm")  ; возвращаем обычный шрифт, чтобы остальные элементы были нормальными
myGui.Add("Text", "xp-35 ys", scriptVer)
settingsBtn.OnEvent("Click", (*) => OpenSettingsLeft())
settingsBtn.OnEvent("ContextMenu", (*) => OpenSettingsRight())

OpenSettingsLeft() {
	Run(iniPath)
}

OpenSettingsRight() {
    Reload
}

; Карты вместо массивов, чтобы спокойно иметь «дыры» по индексам
gameBtn   := Map()
cancelBtn := Map()

if (gamesExist) {
	; Создаём кнопки запуска игр и отмены
	for i, name in gameName {
		if (name != "") {
			gameBtn[i] := myGui.AddButton("xm w200 h30", name)
			cancelBtn[i] := myGui.AddButton("x+10 yp w100 h30", "Отмена")
			cancelBtn[i].Visible := false

			gameBtn[i].OnEvent("Click", LaunchWoW.Bind(i))
			gameBtn[i].OnEvent("ContextMenu", OpenGameFolder.Bind(i))
			cancelBtn[i].OnEvent("Click", CancelWoW.Bind(i))
		}
	}
}

; Проверяем скрипты
scriptsExist := false
Loop 5 {
    val := IniRead(iniPath, "Scripts", "scriptName" A_Index, "")
    if (val != "") {
        scriptsExist := true
        break
    }
}

; Если нашли хоть одно значение — добавляем заголовок
if (scriptsExist) {
    myGui.AddText("xm", "Скрипты:")
	
	scriptChk := Map()
	scriptInfoBtn := Map()
	scriptDesc := Map()

	for i, name in scriptName {
		if (name != "") {
			; Чекбокс
			scriptChk[i] := myGui.AddCheckbox("xm", name)
			scriptChk[i].Value := 1

			; Берём реальный путь (если это .lnk — разворачиваем ярлык)
			real := ResolveShortcut(script[i])

			; Читаем «шапку» из комментариев в начале файла
			scriptDesc[i] := GetScriptDescription(real)

			; Кнопка-инфо справа от чекбокса (иконка как у «Очистить кэш»)
			scriptInfoBtn[i] := myGui.AddPicture("yp x+m-10 w16 h16", "Help.png")
			scriptInfoBtn[i].OnEvent("Click", ShowScriptTooltip.Bind(i))
		}
	}
}

if (gamesExist) {
	myGui.AddText("xm", "Твики:")
	chkClearCache := myGui.AddCheckbox("xm", "Очистить кэш")
	ClearCacheinfoBtn := myGui.AddPicture("yp x+m-10 w16 h16", "Help.png")
	ClearCacheinfoBtn.OnEvent("Click", ShowClearCacheTooltip)
	OnMessage(0x201, TooltipHide_OnClick) ; WM_LBUTTONDOWN
	OnMessage(0x204, TooltipHide_OnClick) ; WM_RBUTTONDOWN
	OnMessage(0x207, TooltipHide_OnClick) ; WM_MBUTTONDOWN
	ShowClearCacheTooltip(*) {
		ToolTip("При запуске игры удалятся папки Cache и Data\Cache")
		SetTimer(() => ToolTip(""), -5000) ; Убираем подсказку через 3 секунды
	}
}

TooltipHide_OnClick(wParam, lParam, msg, hwnd) {
    global myGui
    ; Если кликнули по самому тултипу — скрываем
    try
		cls := WinGetClass("ahk_id " hwnd)
    catch
		cls := ""
    if (cls = "tooltips_class32") {
        ToolTip("")
        return
    }
    ; Если клик внутри нашего GUI — тоже скрываем
    try
		gui := GuiFromHwnd(hwnd)
    catch
		gui := ""
    if (gui && myGui && gui.Hwnd = myGui.Hwnd) {
        ToolTip("")
    }
}

progress := myGui.AddProgress("xm w310 h20 -Smooth")
progress.Value := 0
progress.Visible := false
myGui.Show()

; === Глобальные переменные ===
wowPID := 0
memoryTimerRunning := false
currentTracker := ""  ; BoundFunc активного трекера

; === Основная логика ===
LaunchWoW(index, *) {
    global game, gameBtn, cancelBtn, script, password, progress
    global wowPID, memoryTimerRunning, currentTracker

    ; Проверяем ярлык прежде чем получать exeName
    if !FileExist(game[index]) {
        GuiError("Ошибка: не найден ярлык`n" game[index])
        return
    }
    target := GetShortcutTarget(game[index])
    if (target = "") {
        GuiError("Ошибка: ярлык не содержит целевого пути`n" game[index])
        return
    }
    exeName := StrSplit(target, "\").Pop()
    ; Если процесс уже запущен — просто запустить скрипты и переключиться
    if ProcessExist(exeName) {
        wowPID := ProcessExist(exeName)
        RunSelectedScripts()
        A_Clipboard := password[index]
        WinActivate("ahk_pid " wowPID)
        WinMinimize("Kimmy WoW Launcher") ; Сворачиваем лаунчер
        return
    }
    ; Если процесс не запущен — запуск с отслеживанием
    gameBtn[index].Enabled := false ; Делаем кнопку иргы неактивной
	gamePath := StrReplace(target, "\" exeName)
	cache1 := gamePath "\Cache"
	cache2 := gamePath "\Data\Cache"
	if (chkClearCache.Value) { ; Очищаем кэш, если активен соответствующий чекбокс и если целевые папки существуют
		if DirExist(cache1)
			DirDelete(cache1, true)
		if DirExist(cache2)
			DirDelete(cache2, true)
	}
    progress.Value := 0 ; Устанавливаем полоску прогресс-бара в начальное положение
    progress.Visible := true ; Делаем прогресс-бар видимым
    Run game[index] ; Запускаем игру
    while !ProcessExist(exeName) ; Ждём, пока процесс игры не запустится
        Sleep 100
    wowPID := ProcessExist(exeName)
    cancelBtn[index].Visible := true ; Делаем кнопку Отмена видимой
    if !memoryTimerRunning {
        currentTracker := TrackWoWWindow.Bind(index)
        SetTimer(currentTracker, 500)
        memoryTimerRunning := true
    }
}

TrackWoWWindow(index) {
    global wowPID, progress, cancelBtn, gameBtn, memoryTimerRunning, script, password, currentTracker

    if !ProcessExist(wowPID) {
        SetTimer(currentTracker, 0)
        memoryTimerRunning := false
        progress.Visible := false
		cancelBtn[index].Visible := false
		gameBtn[index].Enabled := true
        return
    }

    mem := GetProcessMemoryMB(wowPID)
    progress.Value := Min(100, Round((mem / 355) * 100))

    if WinExist("ahk_pid " wowPID) {
        SetTimer(currentTracker, 0)
        memoryTimerRunning := false

        ; Запуск выбранных скриптов
        RunSelectedScripts()

        ; Копируем пароль
        A_Clipboard := password[index]
		
        ; Скрываем прогресс и кнопку Отмена
        progress.Visible := false
        cancelBtn[index].Visible := false
        gameBtn[index].Enabled := true

        WinActivate("ahk_pid " wowPID) ; Переключаемся на игру
        WinMinimize("Kimmy WoW Launcher") ; Сворачиваем лаунчер
    }
}

RunSelectedScripts() {
    global scriptName, script, scriptChk
    for i, name in scriptName {
        if (name != "" && scriptChk.Has(i) && scriptChk[i].Value = 1) {
            if FileExist(script[i]) {
                Run script[i]
            } else {
                GuiError("Ошибка: не найден ярлык`n" script[i])
                return
            }
        }
    }
}

CancelWoW(index, *) {
    global wowPID, progress, cancelBtn, gameBtn, memoryTimerRunning, currentTracker

    if wowPID && ProcessExist(wowPID)
        ProcessClose(wowPID)

    if currentTracker
        SetTimer(currentTracker, 0)

    memoryTimerRunning := false
    progress.Visible := false
	cancelBtn[index].Visible := false
	gameBtn[index].Enabled := true
}

; === Функция GUI-ошибки ===
GuiError(msg) {
    MsgBox msg, "Ошибка", "Iconx"
}

; === Получение использования памяти в MB ===
GetProcessMemoryMB(pid) {
    try {
        for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId=" pid)
            return Round(proc.WorkingSetSize / 1024 / 1024)
    } catch {
        return 0
    }
    return 0
}

; === Функция получения целевого пути ярлыка ===
GetShortcutTarget(path) {
    shell := ComObject("WScript.Shell")
    sc := shell.CreateShortcut(path)
    return sc.TargetPath
}

CloseOtherVersions(prefix) {
    current := A_ScriptName  ; имя текущего скрипта

    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name='AutoHotkey64.exe' or Name='AutoHotkey.exe'") {
        if InStr(process.CommandLine, prefix) && !InStr(process.CommandLine, current) {
            try ProcessClose(process.ProcessId)
        }
    }
}

; Функция открытия папки игры
OpenGameFolder(index, *) {
    target := GetShortcutTarget(game[index])
    if (target = "") {
        GuiError("Ошибка: ярлык не содержит целевого пути`n" game[index])
        return
    }
    exeName := StrSplit(target, "\").Pop()
    gamePath := StrReplace(target, "\" exeName)
    Run(gamePath)
}

; Разворачиваем .lnk в реальный путь, иначе возвращаем как есть
ResolveShortcut(path) {
    if (StrLower(SubStr(path, -3)) = "lnk") {
        try {
            tgt := GetShortcutTarget(path)
            return (tgt != "") ? tgt : path
        } catch {
            return path
        }
    }
    return path
}

; --- Читаем описание из .ahk как UTF-8, даже если файл без BOM ---
GetScriptDescription(path) {
    if !FileExist(path)
        return "Описание недоступно (файл не найден)."

    ; если это .lnk — разворачиваем в целевой путь
    if (StrLower(SubStr(path, -3)) = "lnk") {
        try {
            tgt := GetShortcutTarget(path)
            if (tgt != "")
                path := tgt
        }
    }

    ; читаем именно как UTF-8 (для файлов без BOM это критично)
    try {
        text := FileRead(path, "UTF-8")
    } catch {
        ; редкий fallback: читаем «сырьём» и декодируем как UTF-8
        raw := FileRead(path, "RAW")
        text := StrGet(raw, "UTF-8")
    }

    ; нормализуем переводы строк
    text := StrReplace(text, "`r", "")

    ; берём только верхние комментарии, начинающиеся с ';'
    started := false
    desc := ""
    for line in StrSplit(text, "`n") {
        t := Trim(line)
        if (!started && t = "")
            continue
        if (SubStr(t, 1, 1) = ";") {
            started := true
            desc .= LTrim(SubStr(t, 2), " ") "`n"
        } else {
            break
        }
    }
    return (desc != "") ? RTrim(desc, "`n") : "Описание отсутствует."
}

; Показ тултипа по клику на иконку
ShowScriptTooltip(index, *) {
    global scriptDesc
    txt := WrapText(scriptDesc[index], 70) ; ← ограничение ширины
    ToolTip(txt)
}

; --- Перенос текста по словам ---
WrapText(text, maxLen := 70) {
    result := ""
    for line in StrSplit(text, "`n") {
        cur := ""
        for word in StrSplit(line, " ") {
            if (StrLen(cur) + StrLen(word) + 1 > maxLen) {
                result .= RTrim(cur) "`n"
                cur := word " "
            } else {
                cur .= word " "
            }
        }
        if (cur != "")
            result .= RTrim(cur)
        result .= "`n"   ; ← сохраняем исходный перенос
    }
    return RTrim(result, "`n") ; убираем последний пустой
}
