#Requires AutoHotkey v2+
#SingleInstance Force

;@Ahk2Exe-SetMainIcon Kimmy_WL_Logo_icofx.ico
;@Ahk2Exe-SetName Kimmy WoW Launcher
;@Ahk2Exe-SetDescription Лаунчер для разных версий игры World of Warcraft
;@Ahk2Exe-SetVersion 1.2.1

scriptVer := "v1.2.1"
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

; Читаем настройки из ini-файла
alwaysOnTopVal := IniRead(iniPath, "Settings", "AlwaysOnTop", "0") ; Поверх всех окон
onTop := (alwaysOnTopVal = "1") ? "+AlwaysOnTop" : ""
isCacheSaved := IniRead(iniPath, "Settings", "SaveCache", "0") ; Чекбокс очистки кэша
minOnLaunch := IniRead(iniPath, "Settings", "MinOnLaunch", 0) ; Сворачивание при запуске игры
minToTray := IniRead(iniPath, "Settings", "MinToTray", 0) ; Сворачивание в трей
restoreOnClose := IniRead(iniPath, "Settings", "RestoreOnClose", 0) ; Разворачивание после закрытия игры

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
        gameBtn[i] := myGui.AddButton("xm+10 y+m w190 h30 vGameBtn" i , name)
        editBtn[i] := myGui.AddButton("x+10 yp w30 h30", "⚙")
        cancelBtn[i] := myGui.AddButton("x+10 yp w70 h30", "Отмена")
        cancelBtn[i].Visible := false

        gameBtn[i].OnEvent("Click", LaunchWoW.Bind(i))
        gameBtn[i].OnEvent("ContextMenu", OpenGameFolder.Bind(i))
        editBtn[i].OnEvent("Click", OpenSettingsMenu.Bind(i, false))
        cancelBtn[i].OnEvent("Click", CancelWoW.Bind(i))
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
    myGui.AddText("xm+10 y+m", "Скрипты:")
    
    ; --- Встроенный модуль WoW alt+Tab fix ---
    global chkAltTabFix := myGui.AddCheckbox("xm+10 y+m", "Автокликер, анти-альттаб")
    
    ; Восстанавливаем состояние чекбокса из INI
    altTabFixVal := IniRead(iniPath, "Settings", "AltTabFix", "0")
    chkAltTabFix.Value := altTabFixVal
    chkAltTabFix.OnEvent("Click", (*) => IniWrite(chkAltTabFix.Value ? "1" : "0", iniPath, "Settings", "AltTabFix"))
    
    SetTimer(WatchWindow, 500) ; Запускаем таймер слежения за окном WoW
    
    myGui.AddText("xm+10 y+m", "Твики:")
    global chkClearCache := myGui.AddCheckbox("xm+10 y+m", "Очистить кэш")
    ; Если режим сохранения включен, восстанавливаем значение из INI
    if (isCacheSaved = "1") {
        chkClearCache.Value := IniRead(iniPath, "Settings", "CacheValue", "0")
    }
    ; Вешаем обработчик клика на чекбокс
    chkClearCache.OnEvent("Click", OnCacheClick)
    OnMessage(0x0200, OnMouseMove) ; Отслеживание наведения мыши
    OnMessage(0x0006, OnWindowDeactivate) ; Отслеживаем деактивацию окна (сворачивание, Alt+TAB)
    
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
; Кнопка открытия ini-файла
btnOpenIni := myGui.AddButton("xm+10 y+m Section w200 h30", "Открыть INI-файл").OnEvent("Click", (*) => Run(iniPath))
; Кнопка перезапуска скрипта
btnReload := myGui.AddButton("x+10 yp w100 h30", "Перезапустить").OnEvent("Click", (*) => ReloadFunc())
ReloadFunc() {
	SaveWindowPosition
	Reload
}
; Чекбокс с сохранением состояния окна лаунчера
onTopCB := myGui.AddCheckBox("xs vOnTop", "Поверх всех окон (требуется перезагрузка)")
onTopCB.Value := alwaysOnTopVal   ; восстанавливаем последнее значение
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
; Чекбоксы сворачивания/разворачивания окна лаунчера
global minOnLaunchCB, minToTrayCB, ;restoreOnCloseCB
; Основной чекбокс
minOnLaunchCB := myGui.Add("Checkbox", "Checked" minOnLaunch, "Сворачивать лаунчер при запуске игры")
minOnLaunchCB.OnEvent("Click", (cb, *) => (
    IniWrite(cb.Value, iniPath, "Settings", "MinOnLaunch"),
    /* minToTrayCB.Enabled := restoreOnCloseCB.Enabled := cb.Value */
    minToTrayCB.Enabled := cb.Value
))
; Дочерний: Сворачивать в трей
minToTrayCB := myGui.Add("Checkbox", "xp+20 y+5 Checked" minToTray " Disabled" (!minOnLaunch), "Сворачивать в трей")
minToTrayCB.OnEvent("Click", (cb, *) => IniWrite(cb.Value, iniPath, "Settings", "MinToTray"))
/* ; Дочерний: Разворачивать после закрытия
restoreOnCloseCB := myGui.Add("Checkbox", "xp y+5 Checked" restoreOnClose " Disabled" (!minOnLaunch), "Разворачиваться после закрытия игры")
restoreOnCloseCB.OnEvent("Click", (cb, *) => IniWrite(cb.Value, iniPath, "Settings", "RestoreOnClose")) */

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

ShowMainWindow(*) {
	myGui.Show(showParams)
}

ShowMainWindow

; Добавление пункта в трей-меню
A_TrayMenu.Insert("1&", "Показать окно", ShowMainWindow)
A_TrayMenu.Default := "Показать окно"

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
        if (minOnLaunchCB.Value) {
            if (minToTrayCB.Value)
                myGui.Hide()
            else
            WinMinimize("ahk_id " myGui.Hwnd)
        }
        return
    }
    ; Если процесс не запущен — запуск с отслеживанием
    gameBtn[index].Enabled := false ; Делаем кнопку игры неактивной
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

    ; Проверяем, существует ли ещё процесс игры
    if !ProcessExist(wowPID) { ; если процесс игры уже закрылся
		MsgBox("Игра закрылась", "Дебаг", )
        ; Останавливаем таймер
        if (currentTracker)
            SetTimer(currentTracker, 0)
        
        ; Сбрасываем состояние интерфейса
        memoryTimerRunning := false
        gameBtn[index].Enabled := true
        gameBtn[index].SetFont("norm") ; Возвращаем обычный шрифт
        
        cancelBtn[index].Visible := false
        cancelBtn[index].Text := "Отмена" ; Возвращаем исходный текст
        
        progress.Visible := false
        wowPID := 0
        ShowMainWindow
		/* if (restoreOnCloseCB.Value) {
            if (minToTrayCB.Value)
                ShowMainWindow
            else
                WinRestore("ahk_id " myGui.Hwnd)
        } */
    }

    mem := GetProcessMemoryMB(wowPID)
    progress.Value := Min(100, Round((mem / 355) * 100))

    if WinExist("ahk_pid " wowPID) { ; если окно игры существует
        SetTimer(currentTracker, 0)
        memoryTimerRunning := false

        ; Запуск выбранных скриптов
        RunSelectedScripts()

        ; Копируем пароль
        A_Clipboard := password[index]
		
        ; Скрываем прогресс и кнопку Отмена
        progress.Visible := false
		cancelBtn[index].Visible := false
        ;cancelBtn[index].Text := "Закрыть"
        gameBtn[index].Enabled := true
        ;gameBtn[index].SetFont("bold")

        WinActivate("ahk_pid " wowPID) ; Переключаемся на игру
        if (minOnLaunchCB.Value) {
            if (minToTrayCB.Value)
                myGui.Hide()
            else
                WinMinimize("ahk_id " myGui.Hwnd)
        }
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
    cancelBtn[index].Text := "Отмена"
	gameBtn[index].Enabled := true
    gameBtn[index].SetFont("norm")
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
    target := game[index]
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

OnCacheClick(ctrl, info) {
    global isCacheSaved, iniPath
    
    ; Если клик был с зажатым Shift
    if GetKeyState("Shift", "P") {
        isCacheSaved := (isCacheSaved = "1") ? "0" : "1" ; Переключаем режим
        IniWrite(isCacheSaved, iniPath, "Settings", "SaveCache")
    }
    
    ; Если режим сохранения включен, записываем текущее состояние чекбокса (галочка стоит или нет)
    if (isCacheSaved = "1") {
        IniWrite(ctrl.Value, iniPath, "Settings", "CacheValue")
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
        if (ctrl.Type = "Button") {
            if InStr(ctrl.Name, "GameBtn") {
                text := "Нажми правой кнопкой мышки,`nчтобы открыть папку игры"
            } else if (InStr(ctrl.Text, "+ Добавить")) {
                text := "...или любую другую программу =)"
            } else if (ctrl.Text = "⚙") {
                text := "Настроить параметры запуска`nи пароль для этого слота"
            }
        } else if (ctrl.Type = "CheckBox") {
            if (ctrl.Text = "Очистить кэш") {
                global isCacheSaved
                stateTxt := (isCacheSaved = "1") ? "вкл." : "выкл."
                text := "При запуске игры удалятся папки Cache и Data\Cache.`nУдерживай Shift при клике, чтобы запомнить выбор.`n(Сохранение состояния: Сейчас – " stateTxt ")"
            } else if (ctrl.Text = "Автокликер, анти-альттаб") {
                text := "● Заменяет нажатие Alt+TAB в окне WoW на просто TAB`n● Включает встроенные горячие клавиши для WoW:`n  • F: Автокликер (-) | F3: Пауза хоткеев`n  • G: Автоудаление предметов высокого качества`n  • Ctrl+F - снять с паузы хоткеи и запустить автокликер"
            } else if (ctrl.Text = "Сворачивать в трей") {
                text := "Развернуть окно можно двойным кликом по иконке"
            }
        }
    }
    
    if (text != "") {
        ToolTip(text)
    } else {
        ToolTip()
    }
}

OnWindowDeactivate(wParam, lParam, msg, hwnd) {
    ; Если младшее слово wParam равно 0 (WA_INACTIVE), значит окно потеряло активность
    if ((wParam & 0xFFFF) = 0) {
        ToolTip() ; Скрываем тултип
    }
}

; ==============================================================================
; === ВСТРОЕННЫЙ МОДУЛЬ: WoW alt+Tab fix ===
; ==============================================================================

; === Переменные для WoW alt+Tab fix ===
toggleAutoClicker := false
indicatorGui := unset
suspendIndicatorGui := unset
statusIndicatorGui := unset
wowTitles := ["World of Warcraft", "Turtle WoW", "WoWCircle"]
scriptChk := Map()

#HotIf (chkAltTabFix.Value = 1 && IsWoWActive())

*F:: {
    global toggleAutoClicker
    if !toggleAutoClicker {
        toggleAutoClicker := true
        SetTimer(PressMinus, 100)
        ShowIndicator("green")
    } else {
        StopAutoClicker()
    }
}

*Enter:: {
    Send("{Enter}")
    StopAutoClicker()
    ShowIndicator("red")
    Suspend(1) ; Приостанавливаем скрипт
}

*.:: {
    Send(".")
    StopAutoClicker()
    ShowIndicator("red")
    Suspend(1)
}

*/:: {
    Send("/")
    StopAutoClicker()
    ShowIndicator("red")
    Suspend(1)
}

!Tab::Send("{Tab}")

g:: {
    Send("Удалить")
    Send("{Enter}")
}

#SuspendExempt
F3:: {
    if (!chkAltTabFix.Value || !IsWoWActive())
        return
        
    Suspend(-1) ; Переключаем Suspend
    if A_IsSuspended {
        StopAutoClicker()
        ShowIndicator("red")
    } else {
        HideIndicator("red")
    }
}

^*f:: {
    if (!chkAltTabFix.Value || !IsWoWActive())
        return

    if A_IsSuspended {
        Suspend(0) ; Возобновляем
    }
    
    global toggleAutoClicker
    if !toggleAutoClicker {
        toggleAutoClicker := true
        SetTimer(PressMinus, 100)
        HideIndicator("red")
        ShowIndicator("green")
    }
}
#SuspendExempt False

#HotIf

; === Функции модуля WoW alt+Tab fix ===

PressMinus() {
    Send("{Blind}-")
}

WatchWindow() {
    global toggleAutoClicker, chkAltTabFix
    
    ; Если чекбокс выключен — ничего не делаем, скрываем индикаторы
    if (!chkAltTabFix.Value) {
        if toggleAutoClicker
            StopAutoClicker()
        HideIndicator("greenring")
        HideIndicator("green")
        HideIndicator("red")
        return
    }

    if !(IsWoWActive()) && toggleAutoClicker {
        StopAutoClicker()
    }

    if IsWoWActive()
        ShowIndicator("greenring")
    else
        HideIndicator("greenring")
}

StopAutoClicker() {
    global toggleAutoClicker
    toggleAutoClicker := false
    SetTimer(PressMinus, 0)
    HideIndicator("green")
}

ShowIndicator(color) {
    global indicatorGui, suspendIndicatorGui, statusIndicatorGui

    width := 24
    height := 24
    x := 0
    y := A_ScreenHeight - height

    if (color = "green") {
        if !IsSet(indicatorGui) {
            indicatorGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound")
            indicatorGui.BackColor := "Lime"
            indicatorGui.AddText("w" width " h" height " BackgroundLime")
            region := DllCall("gdi32\CreateEllipticRgn", "int", 0, "int", 0, "int", width, "int", height, "ptr")
            DllCall("user32\SetWindowRgn", "ptr", indicatorGui.Hwnd, "ptr", region, "int", true)
        }
        indicatorGui.Show("x" x " y" y " w" width " h" height " NoActivate")

    } else if (color = "red") {
        if !IsSet(suspendIndicatorGui) {
            suspendIndicatorGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound")
            suspendIndicatorGui.BackColor := "Red"
            suspendIndicatorGui.AddText("w" width " h" height " BackgroundRed")
            region := DllCall("gdi32\CreateEllipticRgn", "int", 0, "int", 0, "int", width, "int", height, "ptr")
            DllCall("user32\SetWindowRgn", "ptr", suspendIndicatorGui.Hwnd, "ptr", region, "int", true)
        }
        suspendIndicatorGui.Show("x" x " y" y " w" width " h" height " NoActivate")

    } else if (color = "greenring") {
        if !IsSet(statusIndicatorGui) {
            statusIndicatorGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound")
            statusIndicatorGui.BackColor := "Lime"
            statusIndicatorGui.AddText("w" width " h" height " BackgroundLime")
            
            outer := DllCall("gdi32\CreateEllipticRgn", "int", 0, "int", 0, "int", width, "int", height, "ptr")
            margin := 2
            inner := DllCall("gdi32\CreateEllipticRgn", "int", margin, "int", margin, "int", width - margin, "int", height - margin, "ptr")
            
            ring := DllCall("gdi32\CreateRectRgn", "int", 0, "int", 0, "int", 0, "int", 0, "ptr")
            DllCall("gdi32\CombineRgn", "ptr", ring, "ptr", outer, "ptr", inner, "int", 4)

            DllCall("user32\SetWindowRgn", "ptr", statusIndicatorGui.Hwnd, "ptr", ring, "int", true)

            DllCall("gdi32\DeleteObject", "ptr", outer)
            DllCall("gdi32\DeleteObject", "ptr", inner)
        }
        statusIndicatorGui.Show("x" . x . " y" . y . " w" . width . " h" . height . " NoActivate")
    }
}

HideIndicator(color) {
    global indicatorGui, suspendIndicatorGui, statusIndicatorGui
    if (color = "green" && IsSet(indicatorGui))
        indicatorGui.Hide()
    else if (color = "red" && IsSet(suspendIndicatorGui))
        suspendIndicatorGui.Hide()
    else if (color = "greenring" && IsSet(statusIndicatorGui))
        statusIndicatorGui.Hide()
}

IsWoWActive() {
    global wowTitles
    hwnd := WinExist("A")
    if !hwnd
        return false

    class := WinGetClass(hwnd)
    if !InStr(class, "GxWindowClass")
        return false

    winTitle := WinGetTitle(hwnd)
    for t in wowTitles {
        if InStr(winTitle, t)
            return true
    }
    return false
}
