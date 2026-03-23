#Requires AutoHotkey v2+
#SingleInstance Force

;@Ahk2Exe-SetMainIcon Kimmy_WL_Logo_icofx.ico
;@Ahk2Exe-SetName Kimmy WoW Launcher
;@Ahk2Exe-SetDescription Лаунчер для разных версий игры World of Warcraft
;@Ahk2Exe-SetVersion 1.2

scriptVer := "v1.2"
iniPath := A_ScriptDir "\KimmyWoWLauncher.ini"
MyGuiTitle := "Kimmy WoW Launcher"

;@Ahk2Exe-IgnoreBegin
; --- УСТАНОВКА ИКОНКИ ---
IconFile := "Kimmy_WL_Logo_icofx.ico"
if FileExist(IconFile) {
    TraySetIcon(IconFile)
    try {
        if (hIcon := LoadPicture(IconFile, "w32 h32", &imgType)) {
            SendMessage(0x0080, 1, hIcon, myGui.Hwnd) ; ICON_BIG
            SendMessage(0x0080, 0, hIcon, myGui.Hwnd) ; ICON_SMALL
        }
    }
}
;@Ahk2Exe-IgnoreEnd

; Проверка существования ini-файла или его создание
if !FileExist(iniPath) {
    defaultIni := "
    (
; ==========================================================
; KimmyWoWLauncher.ini
; ==========================================================
; Настройки и пути к играм сохраняются здесь автоматически
; через интерфейс лаунчера.
; ==========================================================
    )"

    FileAppend(defaultIni, iniPath, "UTF-8")
}

gamesExist := false
gameName   := []
password   := []
scriptName := []
game       := []
script     := []

Loop 5 {
    i := A_Index
    gName := IniRead(iniPath, "Games", "gameName" i, "")
    gameName.Push(gName)
    if (gName != "")
        gamesExist := true
    
    password.Push(IniRead(iniPath, "Passwords", "password" i, ""))
    
    sName := IniRead(iniPath, "Scripts", "scriptName" i, "")
    scriptName.Push(sName)

    ; Умное чтение путей: если абсолютный путь не задан, используем старый формат ярлыков на рабочем столе
    gPath := IniRead(iniPath, "GamePaths", "path" i, "")
    if (gPath == "" && gName != "")
        gPath := A_Desktop "\" gName ".lnk"
    game.Push(gPath)

    sPath := IniRead(iniPath, "ScriptPaths", "path" i, "")
    if (sPath == "" && sName != "")
        sPath := A_Desktop "\" sName ".lnk"
    script.Push(sPath)
}

; Читаем настройку AlwaysOnTop
alwaysOnTopVal := IniRead(iniPath, "Settings", "AlwaysOnTop", "0")
onTop := (alwaysOnTopVal = "1") ? "+AlwaysOnTop" : ""

; === Интерфейс ===
myGui := Gui(onTop, MyGuiTitle)
myGui.SetFont("s10", "Segoe UI")

; --- Вводим вкладки ---
; --- Начинаем с первой вкладки 
Tab := MyGui.AddTab3("xm", ["Игры", "Настройки", "Инфо"])
gameBtn   := Map()
cancelBtn := Map()
editBtn   := Map() ; Новая карта для кнопок настроек

addedCount := 0

; Отрисовка существующих игр
for i, name in gameName {
    if (name != "") {
        gameBtn[i] := myGui.AddButton("xm+10 y+m w190 h30", name)
        editBtn[i] := myGui.AddButton("x+10 yp w30 h30", "⚙")
        cancelBtn[i] := myGui.AddButton("x+10 yp w70 h30", "Отмена")
        cancelBtn[i].Visible := false

        gameBtn[i].OnEvent("Click", LaunchWoW.Bind(i))
        gameBtn[i].OnEvent("ContextMenu", OpenGameFolder.Bind(i))
        cancelBtn[i].OnEvent("Click", CancelWoW.Bind(i))
        editBtn[i].OnEvent("Click", OpenSettingsMenu.Bind(i, false))
        addedCount++
    }
}

; Кнопка добавления новой игры, если есть свободные слоты
if (addedCount < 5) {
    emptyIndex := 0
    for i, name in gameName {
        if (name == "") {
            emptyIndex := i
            break
        }
    }
    if (emptyIndex > 0) {
        gameBtn[emptyIndex] := myGui.AddButton("xm+10 y+m w190 h30", "+ Добавить игру...")
        gameBtn[emptyIndex].OnEvent("Click", OpenSettingsMenu.Bind(emptyIndex, true))
    }
}

if (gamesExist) {
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
        myGui.AddText("xm+10 y+m", "Скрипты:")
        
        scriptChk := Map()
        scriptInfoBtn := Map()
        scriptDesc := Map()

        for i, name in scriptName {
            if (name != "") {
                scriptChk[i] := myGui.AddCheckbox("xm+10 y+m", name)
                scriptChk[i].Value := 1

                real := ResolveShortcut(script[i])
                scriptDesc[i] := GetScriptDescription(real)

                scriptInfoBtn[i] := myGui.AddPicture("yp x+m-10 w16 h16 Icon2", "pics.dll")
                scriptInfoBtn[i].OnEvent("Click", ShowScriptTooltip.Bind(i))
            }
        }
    }

    myGui.AddText("xm+10 y+m", "Твики:")
    chkClearCache := myGui.AddCheckbox("xm+10 y+m", "Очистить кэш")
    ClearCacheinfoBtn := myGui.AddPicture("yp x+m-10 w16 h16 Icon2", "pics.dll")
    ClearCacheinfoBtn.OnEvent("Click", ShowClearCacheTooltip)
    OnMessage(0x0200, OnMouseMove) ; Отслеживание наведения мыши
    
    ShowClearCacheTooltip(*) {
        ToolTip("При запуске игры удалятся папки Cache и Data\Cache")
        SetTimer(() => ToolTip(""), -5000)
    }

    TooltipHide_OnClick(wParam, lParam, msg, hwnd) {
        global myGui
        try cls := WinGetClass("ahk_id " hwnd)
        catch
            cls := ""
        if (cls = "tooltips_class32") {
            ToolTip("")
            return
        }
        try gui := GuiFromHwnd(hwnd)
        catch
            gui := ""
        if (gui && myGui && gui.Hwnd = myGui.Hwnd) {
            ToolTip("")
        }
    }

    progress := myGui.AddProgress("xm+10 y+m w310 h20 -Smooth")
    progress.Value := 0
    progress.Visible := false
}

Tab.UseTab(2) ; Вкладка "Настройки"
btnOpenIni := myGui.AddButton("xm+10 y+m Section w200 h30", "Открыть INI-файл").OnEvent("Click", (*) => Run(iniPath))
btnReload := myGui.AddButton("x+10 yp w100 h30", "Перезапустить").OnEvent("Click", (*) => ReloadFunc())
ReloadFunc() {
	SaveWindowPosition
	Reload
}
; Чекбокс с сохранением состояния
onTopCB := myGui.AddCheckBox("xs vOnTop", "Поверх всех окон (требуется перезагрузка)")
onTopCB.Value := alwaysOnTopVal   ; восстанавливаем последнее значение

; Обработчик клика по чекбоксу
onTopCB.OnEvent("Click", (*) => SaveAlwaysOnTop())

SaveAlwaysOnTop() {
    global onTopCB, iniPath
    newVal := onTopCB.Value ? "1" : "0"
    IniWrite(newVal, iniPath, "Settings", "AlwaysOnTop")
}

; Чекбокс "Сохранять положение окна"
savePosVal := IniRead(iniPath, "Settings", "SaveWindowPos", "0")
savePosCB := myGui.AddCheckBox("xs vSavePos", "Сохранять положение окна при его закрытии")
savePosCB.Value := savePosVal

savePosCB.OnEvent("Click", (*) => SaveWindowPosSetting())

SaveWindowPosSetting() {
    global savePosCB, iniPath
    newVal := savePosCB.Value ? "1" : "0"
    IniWrite(newVal, iniPath, "Settings", "SaveWindowPos")
}

Tab.UseTab(3) ; Вкладка "Инфо"

MyGui.AddPicture("Section w64 h-1 Icon1", "pics.dll") ; Лого
myGui.AddText("x+m yp+22", MyGuiTitle " " scriptVer)
MyGui.AddPicture("xs w64 h-1 Icon3", "pics.dll") ; Гитхаб
MyGui.AddLink("x+m yp+22", '<a href="https://github.com/KiM38RuS/Kimmy-WoW-Launcher">Страница проекта на GitHub</a>')
MyGui.AddPicture("xs w64 h-1 Icon4", "pics.dll") ; Ава
MyGui.AddLink("x+m yp+22", 'Автор - <a href="https://github.com/KiM38RuS">KiM38RuS</a>')
;BannerPic := MyGui.AddPicture("xs w150 h-1 Icon5", "pics.dll") ; Баннер

Tab.UseTab() ; Интерфейс, заданный после этой строки будет размещён вне вкладок

; Восстановление позиции окна при запуске лаунчера
WinPosX := IniRead(iniPath, "Settings", "WinPosX", "")
WinPosY := IniRead(iniPath, "Settings", "WinPosY", "")

showParams := ""
if (WinPosX != "" && WinPosY != "") {
    showParams := "x" WinPosX " y" WinPosY
}

myGui.Show(showParams)

; Добавление пункта в трей-меню
A_TrayMenu.Insert("1&", "Показать окно", ShowMainWindow)
A_TrayMenu.Default := "Показать окно"

ShowMainWindow(*) {
	myGui.Show(showParams)
}

/* ; Выравнивание баннера
MyGui.GetPos(,, &MyGuiWidth)
BannerPic.GetPos(, &BannerPicY, &BannerPicWidth)
BannerPic.Move((MyGuiWidth - BannerPicWidth) // 2, BannerPicY) */

; Сохранение позиции окна при закрытии лаунчера
myGui.OnEvent("Close", SaveWindowPosition)
SaveWindowPosition(*) {
    global savePosCB, myGui, iniPath
    if (savePosCB.Value) {
        WinGetPos(&x, &y, &w, &h, "ahk_id " myGui.Hwnd)
        IniWrite(x, iniPath, "Settings", "WinPosX")
        IniWrite(y, iniPath, "Settings", "WinPosY")
    }
}

; === Глобальные переменные ===
wowPID := 0
memoryTimerRunning := false
currentTracker := ""  ; BoundFunc активного трекера

; === Основная логика ===
LaunchWoW(index, *) {
    global game, gameBtn, cancelBtn, script, password, progress
    global wowPID, memoryTimerRunning, currentTracker

    if !FileExist(game[index]) {
        GuiError("Ошибка: не найден файл игры`n" game[index])
        return
    }
    
    target := game[index]
    ; Если путь всё-таки остался ярлыком, извлекаем цель
    if (StrLower(SubStr(target, -3)) = "lnk") {
        target := GetShortcutTarget(target)
        if (target = "" || !FileExist(target)) {
            GuiError("Ошибка: ярлык не содержит целевого пути или файл отсутствует`n" game[index])
            return
        }
    }
    
    SplitPath(target, &exeName, &gamePath)
    ; Если процесс уже запущен — просто запустить скрипты и переключиться
    if ProcessExist(exeName) {
        wowPID := ProcessExist(exeName)
        RunSelectedScripts()
        A_Clipboard := password[index]
        WinActivate("ahk_pid " wowPID)
        WinMinimize(MyGuiTitle) ; Сворачиваем лаунчер
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
        WinMinimize(MyGuiTitle) ; Сворачиваем лаунчер
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

; === Меню настройки слота ===
OpenSettingsMenu(index, isNew, *) {
    global iniPath, myGui, gameName, password, game, script, scriptName

    editGui := Gui("+Owner" myGui.Hwnd " +ToolWindow", "Настройка слота " index)
    editGui.OnEvent("Escape", (*) => (myGui.Opt("-Disabled"), editGui.Destroy()))
    editGui.OnEvent("Close", (*) => (myGui.Opt("-Disabled"), editGui.Destroy()))
    
    editGui.AddText("xm ym+5 w60", "Название:")
    editName := editGui.AddEdit("x+5 yp w240", gameName[index])
    
    editGui.AddText("xm y+5 w60", "Файл игры:")
    editPath := editGui.AddEdit("r3 x+5 yp w190", game[index])
    btnBrowseGame := editGui.AddButton("x+5 yp w45", "Обзор")
    btnBrowseGame.OnEvent("Click", (*) => BrowseFile(editPath, editName, "Исполняемые файлы и Ярлыки (*.exe; *.lnk)"))
    
    editGui.AddText("xm y+29 w60", "Пароль:")
    editPass := editGui.AddEdit("x+5 yp w240 Password", password[index])
    
    ; Кнопки управления
    if (isNew) {
        ; Если слот новый, делаем кнопку "Сохранить" на всю ширину
        btnSave := editGui.AddButton("xm y+5 w306 h30", "Добавить игру")
    } else {
        ; Если слот редактируется, рисуем две кнопки в ряд
        btnSave := editGui.AddButton("xm y+5 w148 h30", "Сохранить")
        
        btnDelete := editGui.AddButton("x+10 yp w148 h30", "Удалить")
        btnDelete.OnEvent("Click", ClearSlotSettings.Bind(index, editGui))
    }
    
    btnSave.OnEvent("Click", SaveSlotSettings.Bind(index, editGui, editName, editPath, editPass))
    
    myGui.Opt("+Disabled") ; Блокируем главное окно, пока открыты настройки
    editGui.Show()
}

BrowseFile(editCtrl, nameCtrl, filter) {
    ; Определяем начальную папку
    startDir := A_Desktop ; По умолчанию Рабочий стол
    
    if DirExist("D:\Games")
        startDir := "D:\Games"
    else if DirExist("C:\Games")
        startDir := "C:\Games"

    ; Вызываем окно выбора файла    
    filePath := FileSelect(3, startDir, "Выберите файл", filter)
    if (filePath != "") {
        ; Если выбран ярлык, сразу разворачиваем его в .exe
        if (StrLower(SubStr(filePath, -3)) = "lnk") {
            try {
                tgt := GetShortcutTarget(filePath)
                if (tgt != "" && FileExist(tgt))
                    filePath := tgt
            }
        }
        
        editCtrl.Value := filePath
        
        ; Умный парсинг названия для WoW
        if (nameCtrl != "") {
            SplitPath(filePath, , , &fileExt, &outNameNoExt)
            
            if (StrLower(fileExt) = "exe") {
                if GetWowVersionInfo(filePath, &smartName) {
                    nameCtrl.Value := smartName
                    return
                }
            }
            
            ; Если не удалось получить инфу о WoW, используем стандартное имя
            if (nameCtrl.Value == "")
                nameCtrl.Value := outNameNoExt
        }
    }
}

; Функция для чтения версии и описания WoW-файла напрямую из свойств Windows
GetWowVersionInfo(filePath, &outName) {
    outName := ""
    try {
        fileVer := FileGetVersion(filePath)
        if !fileVer
            return false
        
        size := DllCall("version.dll\GetFileVersionInfoSize", "Str", filePath, "Ptr", 0, "UInt")
        if !size
            return false
            
        buf := Buffer(size)
        if !DllCall("version.dll\GetFileVersionInfo", "Str", filePath, "UInt", 0, "UInt", size, "Ptr", buf)
            return false
            
        if !DllCall("version.dll\VerQueryValue", "Ptr", buf, "Str", "\VarFileInfo\Translation", "Ptr*", &lpTranslate:=0, "UInt*", &cbTranslate:=0)
            return false
            
        langCp := Format("{:04X}{:04X}", NumGet(lpTranslate, 0, "UShort"), NumGet(lpTranslate, 2, "UShort"))
        
        if DllCall("version.dll\VerQueryValue", "Ptr", buf, "Str", "\StringFileInfo\" langCp "\FileDescription", "Ptr*", &lpData:=0, "UInt*", &cbData:=0) {
            fileDesc := StrGet(lpData, cbData, "UTF-16")
            if InStr(fileDesc, "World of Warcraft") {
                if RegExMatch(fileVer, "^(\d+\.\d+\.\d+)", &match) {
                    outName := "WoW " match[1]
                    return true
                }
            }
        }
    }
    return false
}

SaveSlotSettings(index, editGui, editName, editPath, editPass, *) {
    global iniPath
    
    if (editName.Value == "" || editPath.Value == "") {
        MsgBox("Поля 'Название' и 'Файл игры' обязательны для заполнения!", "Ошибка", "Iconx")
        return
    }
    
    IniWrite(editName.Value, iniPath, "Games", "gameName" index)
    IniWrite(editPass.Value, iniPath, "Passwords", "password" index)
    IniWrite(editPath.Value, iniPath, "GamePaths", "path" index)
    
    editGui.Destroy()
    myGui.Opt("-Disabled")
    SaveWindowPosition()
    Reload
}

ClearSlotSettings(index, editGui, *) {
    global iniPath
    result := MsgBox("Ты уверен, что хочешь полностью очистить этот слот?", "Подтверждение", "YesNo Icon?")
    if (result == "Yes") {
        IniWrite("", iniPath, "Games", "gameName" index)
        IniWrite("", iniPath, "Passwords", "password" index)
        IniWrite("", iniPath, "GamePaths", "path" index)
        
        editGui.Destroy()
        myGui.Opt("-Disabled")
        SaveWindowPosition()
        Reload
    }
}

; === Функция отображения тултипов при наведении ===
OnMouseMove(wParam, lParam, msg, hwnd) {
    static PrevHwnd := 0
    if (hwnd == PrevHwnd)
        return
    PrevHwnd := hwnd
    
    try ctrl := GuiCtrlFromHwnd(hwnd)
    catch {
        ToolTip()
        return
    }
    
    if (!ctrl) {
        ToolTip()
        return
    }

    text := ""
    ; Проверяем, что это наша основная форма
    if (ctrl.Gui.Title = MyGuiTitle) {
        if (InStr(ctrl.Text, "+ Добавить")) { ; Подсказка для кнопки добавления новой игры
            text := "...или любую другую программу =)"
        } else if (ctrl.Text = "⚙") { ; Подсказка для кнопки настройки (шестерёнки)
            text := "Настроить параметры запуска и пароль для этого слота"
        } else if (ctrl.Type = "Button" && ctrl.Text != "" && ctrl.Text != "Отмена" && ctrl.Text != "⚙" && !InStr(ctrl.Text, "+ Добавить") && !InStr(ctrl.Text, "Открыть INI") && !InStr(ctrl.Text, "Перезапустить")) {
            text := "Нажми правой кнопкой мышки, чтобы открыть папку игры"
        } else if (ctrl.Type = "CheckBox") {
            if (ctrl.Text = "Очистить кэш") {
                text := "При запуске игры удалятся папки Cache и Data\Cache"
            } else if (ctrl.Text != "Поверх всех окон (требуется перезагрузка)" && ctrl.Text != "Сохранять положение окна при его закрытии") {
                text := "Нажми на кнопку справа для дополнительной информации"
            }
        }
    }
    
    if (text != "") {
        ToolTip(text)
    } else {
        ToolTip()
    }
}
