#Requires AutoHotkey v2+
#SingleInstance Force

;@Ahk2Exe-SetName Kimmy WoW Launcher
;@Ahk2Exe-SetDescription Лаунчер для разных версий игры World of Warcraft
;@Ahk2Exe-SetVersion 1.4.4

scriptVer := "v1.4.4"
iniPath := A_ScriptDir "\KimmyWoWLauncher.ini"
MyGuiTitle := "Kimmy WoW Launcher"

; Переменные с картинками
LOGO_BASE64 := "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"
GITHUB_BASE64 := "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAV2SURBVHhe7dtlqGxVHIbxa2Mn2IWt2CiKgd2oCIogFoKJih9EFMRWVBTF/iIGqCgWdiAqghhYYCd2J3Y+z9UZ5+zz7pm950zsC/eFH9x77o51Znas9V/rTpuZmRlZFsH62BkH4HAcjaNwKPaD/7YRlsVcmKEzGzbH6XgUX+Hvin7Cu7gPJ2MTzDBZA2fiFaRfrl8v4iQsj0ZmY9yI35B+gUH5AVdidTQiK+F6pMYO0884DwthbDkW3yI1cFTexh4YaZbE3UgNGpeLMTuGHp/I7yE1YtwewxIYWnbHj0gnb4o3sRoGnr3wB9JJm+Yj+DoeWLbH70gna6r3MZA+w5r4DukkTWfnaT70HXd+Fengnf4KPxuFX8LPim5B37kW6aCdjoH32zY4C4PuAhe9gFOwJbzED0HarpMDrtrxoZcO1smro5g5sA+eRdqnX49gN8yCYrzf0z4tDq5WRuXMjw+RDtbpZpRlVhyGD+AzxBGhffhT4TDYb25/OAx2eOzfvZr896vwBGy4Pb190S13IbWv072onDOQDlJ0KXplYSz+7x9rx7rAAv/+sWuuQGpfkfWGnrGxjrjSAYocjDQhtiO1r8jbsmcsYKSdk3PRhFyA1L5kJ5RmHnyMtGPipdeE3IDUvqTrs2BvpJ3KPI1xx4ft60jtS+zRroiY25B2KnMPxh1fi9YOU/vKHI9JWRDfIO2QWORsSn3Ob7ROd/1xTMoOSBuXOQhNyolI7Uwc0k96NZ+GtHHyMpoWa4NfI7U32RUTUqU31WJfvIm5Dqm9ifMN7fgkfQ1pw6RSj2oMsWud2ptYwm/Haas6D8B10MSsh9Te5Em0swqqlrt8jzoX0MTU6cZbO2xXkTdA2ihxQmI5NDEWcD5DanfRp2hXizZF2iixCtPU+Tl/IX+x1O4ib3lHqtNT5wPwVvGWaWIWQ9UO0YQPYEOkjcp4yzQxlub+RGpz0edo1xpWRdUdNakT0ZA4cZPam7wDy3fTsyjqTHLGwUQDcg5Se5Nn0I6rOeoMKWvV10aY55Dam9yKCfGXShsmFiuXRpNSpxMkS/gTcjbShmWaUg9s5Wqkdpax+DMh1tzThmVq19qHGL/9OnOXLuOZVBXyQfg90g5lrN2niYpRxjrmS0jtK+OzIsYSV9qhG4eg48q8eBCpXd1Muv9bORBph15cLrMMRpm14asstacXb5kY64JlCxq9x74s/KyTg5DjMOxVW474nLvwGZTa0ctT6JqLUNzpC9hbdLDhrOztKG7T4rzCZbBoYt98ELFesSOcW+z2JVThPGTX+HT8FZ07+dS0l9UZV212bpN4NTkpegm2Qp1sh8vhwie/gHT8ulx+W2kNsidOB3C9QGfOR9oucd1wnfiNp+NMhTPQleJ9VjY28PLujCsw0nadXMPXT65BOl4/XFhh7bNyjkA6kFwA0cqc6DUz4xO7n6yAfh92RXWvwOl5GOlgLp6wA9KKw0pvm9QbuwP9xnMM4v6/EH3FAU9ZAybU1f+LK7idMXINsSXqdTGVWLCwcJHOX5VrAtrj/n6yLdIqMC/NYZfGfO1+guK5q/KVWToTXCdlK7H8dNt1tSHEW6DKWqXEV/kWGFjs5aUTvYGDsRQGnbnRawVY4rPI0e3AcyTSCeWEhK+aB3An7ofdzqkso7HTYuclna+MM7+7YGjZE3Xqh1N5C/jwegvpuIlL8izxDz1rweUxqRFFN6HfWKusOmn7EEY6IrUD5OWdGtNpKh+AcS1COm6Ll/wJGFs2g0tOUuM0YRq6j3Sr9rhStTH/e8wlr8+j2MipfgCpXO8Ddms0Lg42XGTtW8C3gq8jP5ippLUM1h6plV+vuBkidqMtogwidqkHVVyZmf8zbdo/gtc39xlucaUAAAAASUVORK5CYII="
AVATAR_BASE64 := "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"


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
game       := []
memoryThreshold := [] ; Пороговое значение памяти для каждой игры

Loop 5 {
    i := A_Index
    gName := IniRead(iniPath, "Games", "gameName" i, "")
    gameName.Push(gName)
    if (gName != "")
        gamesExist := true

    password.Push(IniRead(iniPath, "Passwords", "password" i, ""))

    ; Умное чтение путей: если абсолютный путь не задан, используем старый формат ярлыков на рабочем столе
    gPath := IniRead(iniPath, "GamePaths", "path" i, "")
    if (gPath == "" && gName != "")
        gPath := A_Desktop "\" gName ".lnk"
    game.Push(gPath)

    ; Читаем пороговое значение памяти для прогресс-бара (по умолчанию 400 МБ)
    memThreshold := IniRead(iniPath, "MemoryThresholds", "threshold" i, "400")
    memoryThreshold.Push(Integer(memThreshold))
}

; Читаем настройки из ini-файла
alwaysOnTopVal := IniRead(iniPath, "Settings", "AlwaysOnTop", "0") ; Поверх всех окон
onTop := (alwaysOnTopVal = "1") ? "+AlwaysOnTop" : ""
isCacheSaved := IniRead(iniPath, "Settings", "SaveCache", "0") ; Чекбокс очистки кэша
minOnLaunch := IniRead(iniPath, "Settings", "MinOnLaunch", 0) ; Сворачивание при запуске игры
minToTray := IniRead(iniPath, "Settings", "MinToTray", 0) ; Сворачивание в трей
restoreOnClose := IniRead(iniPath, "Settings", "RestoreOnClose", 0) ; Разворачивание после закрытия игры
runIndicatorType := IniRead(iniPath, "Settings", "RunIndicatorType", "1") ; Тип индикации запущенной игры (1-жирный, 2-точка, 3-квадрат)

; === Интерфейс ===
myGui := Gui(onTop, MyGuiTitle)
myGui.SetFont("s10", "Segoe UI")

; --- Вводим вкладки ---
; --- Начинаем с первой вкладки
Tab := MyGui.AddTab3("xm", ["Игры", "Настройки", "Инфо"])
gameBtn   := Map()
cancelBtn := Map()
editBtn   := Map() ; Новая карта для кнопок настроек
indicatorSquare := Map() ; Карта для зелёных квадратиков

addedCount := 0
toggleAutoClicker := true

; Отрисовка существующих игр
for i, name in gameName {
    if (name != "") {
        ; Проверяем существование файла игры
        gameExists := FileExist(game[i])

        ; Зелёный кружок (изначально пустой) или красный, если файл не найден
        if (gameExists) {
            indicatorSquare[i] := myGui.AddText("xm+10 y+m w20 h30 c008000 Center 0x200", "○")
        } else {
            indicatorSquare[i] := myGui.AddText("xm+10 y+m w20 h30 c800000 Center 0x200", "●")
        }

        gameBtn[i] := myGui.AddButton("x+0 yp w190 h30 vGameBtn" i , name)
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
        ; Добавляем невидимый символ для выравнивания
        indicatorSquare[emptyIndex] := myGui.AddText("xm+10 y+m w20", "")

        gameBtn[emptyIndex] := myGui.AddButton("x+0 yp w190 h30", "+ Добавить игру...")
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
	SaveWindowPosition()
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
global minOnLaunchCB, minToTrayCB, restoreOnCloseCB
; Основной чекбокс
minOnLaunchCB := myGui.Add("Checkbox", "Checked" minOnLaunch, "Сворачивать лаунчер при запуске игры")
minOnLaunchCB.OnEvent("Click", (cb, *) => (
    IniWrite(cb.Value, iniPath, "Settings", "MinOnLaunch"),
    minToTrayCB.Enabled := restoreOnCloseCB.Enabled := cb.Value
))
; Дочерний: Сворачивать в трей
minToTrayCB := myGui.Add("Checkbox", "xp+20 y+5 Checked" minToTray " Disabled" (!minOnLaunch), "Сворачивать в трей")
minToTrayCB.OnEvent("Click", (cb, *) => IniWrite(cb.Value, iniPath, "Settings", "MinToTray"))
; Дочерний: Разворачивать после закрытия
restoreOnCloseCB := myGui.Add("Checkbox", "xp y+5 Checked" restoreOnClose " Disabled" (!minOnLaunch), "Разворачиваться после закрытия игры")
restoreOnCloseCB.OnEvent("Click", (cb, *) => IniWrite(cb.Value, iniPath, "Settings", "RestoreOnClose"))

; Индикация запущенной игры
myGui.AddText("xs y+10", "Индикация запущенной игры:")
global runIndicatorDD
runIndicatorDD := myGui.AddDropDownList("xs y+5 w310 Choose" (Integer(runIndicatorType) + 1), ["Без индикации", "Жирный текст кнопки", "Жирная точка ● перед именем", "Зелёный кружок слева"])
runIndicatorDD.OnEvent("Change", (*) => SaveRunIndicatorType())
SaveRunIndicatorType() {
    global runIndicatorDD, iniPath
    IniWrite(runIndicatorDD.Value - 1, iniPath, "Settings", "RunIndicatorType")
}

Tab.UseTab(3) ; Вкладка "Инфо"

global g_GdiplusToken := 0
global g_GdiplusReady := false

EnsureGDIPlus() {
    global g_GdiplusToken, g_GdiplusReady
    if g_GdiplusReady
        return

    si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
    NumPut("UInt", 1, si, 0)

    status := DllCall("gdiplus\GdiplusStartup", "ptr*", g_GdiplusToken, "ptr", si, "ptr", 0, "uint")

    if status != 0
        throw Error("GdiplusStartup failed: " status)

    g_GdiplusReady := true
    OnExit(CleanupGDIPlus)
}

LoadImageFromBase64(base64) {
    EnsureGDIPlus()

    ; Убираем переносы строк и возможный data:...;base64,
    base64 := RegExReplace(base64, "\s+")
    base64 := RegExReplace(base64, "^data:image\/[a-zA-Z0-9.+-]+;base64,", "")

    cbData := 0
    if !DllCall("Crypt32\CryptStringToBinaryW", "str", base64, "uint", 0, "uint", 1, "ptr", 0, "uint*", &cbData, "ptr", 0, "ptr", 0, "int")
    {
        throw Error("Не удалось определить размер Base64-данных. WinErr=" A_LastError)
    }

    bin := Buffer(cbData, 0)
    if !DllCall("Crypt32\CryptStringToBinaryW", "str", base64, "uint", 0, "uint", 1, "ptr", bin.Ptr, "uint*", &cbData, "ptr", 0, "ptr", 0, "int")
    {
        throw Error("Не удалось декодировать Base64. WinErr=" A_LastError)
    }

    pStream := DllCall("Shlwapi\SHCreateMemStream", "ptr", bin.Ptr, "uint", cbData, "ptr")
    if !pStream
        throw Error("Не удалось создать поток из изображения.")

    try {
        pBitmap := 0
        status := DllCall("gdiplus\GdipCreateBitmapFromStream", "ptr", pStream, "ptr*", &pBitmap, "uint")
        if status != 0
            throw Error("GdipCreateBitmapFromStream вернула ошибку: " status)

        hBitmap := 0
        status := DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "ptr", pBitmap, "ptr*", &hBitmap, "uint", 0x00FFFFFF, "uint")
        DllCall("gdiplus\GdipDisposeImage", "ptr", pBitmap)

        if status != 0
            throw Error("GdipCreateHBITMAPFromBitmap вернула ошибку: " status)

        return hBitmap
    } finally {
        ObjRelease(pStream)
    }
}

CleanupGDIPlus(*) {
    global g_GdiplusToken, g_GdiplusReady
    if !g_GdiplusReady || !g_GdiplusToken
        return

    token := g_GdiplusToken
    g_GdiplusToken := 0
    g_GdiplusReady := false
    DllCall("gdiplus\GdiplusShutdown", "ptr", token)
}

; Загружаем изображения из Base64
logoPic := LoadImageFromBase64(LOGO_BASE64)
githubPic := LoadImageFromBase64(GITHUB_BASE64)
avatarPic := LoadImageFromBase64(AVATAR_BASE64)

MyGui.AddPicture("Section w64 h64").Value := "HBITMAP:" logoPic ; Лого
myGui.SetFont("s12")
myGui.AddText("x+m yp+22", MyGuiTitle " " scriptVer)
MyGui.AddPicture("xs w64 h64").Value := "HBITMAP:" githubPic ; Гитхаб
MyGui.AddLink("x+m yp+22", '<a href="https://github.com/KiM38RuS/Kimmy-WoW-Launcher">Страница проекта на GitHub</a>')
MyGui.AddPicture("xs w64 h64").Value := "HBITMAP:" avatarPic ; Ава
MyGui.AddLink("x+m yp+22", 'Автор - <a href="https://github.com/KiM38RuS">KiM38RuS</a>')
myGui.SetFont("s10")

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

; Добавление пункта в трей-меню
A_TrayMenu.Insert("1&", "Показать окно", ShowMainWindow)
A_TrayMenu.Default := "Показать окно"

/* ; Выравнивание баннера
MyGui.GetPos(,, &MyGuiWidth)
BannerPic.GetPos(, &BannerPicY, &BannerPicWidth)
BannerPic.Move((MyGuiWidth - BannerPicWidth) // 2, BannerPicY) */

; Обработчик закрытия окна: сохранение позиции и выход
myGui.OnEvent("Close", OnGuiClose)
OnGuiClose(*) {
    SaveWindowPosition()
    ExitApp()
}

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
wmiSink := ""  ; Объект для подписки на WMI события
wmiStartupSink := ""  ; Объект для отслеживания запуска процесса
currentGameIndex := 0  ; Индекс текущей запускаемой игры

; === Основная логика ===
LaunchWoW(index, *) {
    global game, gameBtn, cancelBtn, password, progress
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
    ; Если процесс уже запущен — просто переключиться
    if ProcessExist(exeName) {
        wowPID := ProcessExist(exeName)
        A_Clipboard := password[index]
        ShowRunIndicator(index) ; Показываем индикацию
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

    ; Подписываемся на WMI событие создания процесса
    currentGameIndex := index
    SubscribeToProcessStartup(exeName, index)

    Run game[index] ; Запускаем игру
}

TrackWoWWindow(index) {
    global wowPID, progress, cancelBtn, gameBtn, memoryTimerRunning, password, currentTracker, memoryThreshold, iniPath

    ; Проверяем, существует ли ещё процесс игры
    if !ProcessExist(wowPID) { ; если процесс игры уже закрылся
        ; Останавливаем таймер
        if (currentTracker)
            SetTimer(currentTracker, 0)

        ; Сбрасываем состояние интерфейса
        memoryTimerRunning := false
        gameBtn[index].Enabled := true
        HideRunIndicator(index) ; Скрываем индикацию

        cancelBtn[index].Visible := false
        cancelBtn[index].Text := "Отмена" ; Возвращаем исходный текст

        progress.Visible := false
        wowPID := 0
        return
    }

    mem := GetProcessMemoryMB(wowPID)
    if (mem > 0) {
        progress.Value := Min(100, Round((mem / memoryThreshold[index]) * 100))
    }

    if WinExist("ahk_pid " wowPID) { ; если окно игры существует
        ; Сохраняем текущее значение памяти как порог для этой игры (только один раз)
        if (progress.Visible) {
            currentMem := GetProcessMemoryMB(wowPID)
            if (currentMem > 0) {
                memoryThreshold[index] := currentMem
                IniWrite(currentMem, iniPath, "MemoryThresholds", "threshold" index)
            }

            ; Копируем пароль
            A_Clipboard := password[index]

            ; Скрываем прогресс и кнопку Отмена
            progress.Visible := false
            cancelBtn[index].Visible := false
            gameBtn[index].Enabled := true

            ; Показываем индикацию запущенной игры
            ShowRunIndicator(index)

            WinActivate("ahk_pid " wowPID) ; Переключаемся на игру

            ; Сворачиваем лаунчер сразу
            if (minOnLaunchCB.Value) {
                if (minToTrayCB.Value)
                    myGui.Hide()
                else
                    WinMinimize("ahk_id " myGui.Hwnd)
            }

            ; Останавливаем таймер и подписываемся на WMI события
            if (currentTracker)
                SetTimer(currentTracker, 0)
            memoryTimerRunning := false

            ; Подписываемся на события закрытия процесса
            SubscribeToProcessEvents(index)
        }
    }
}

; Подписка на WMI событие создания процесса
SubscribeToProcessStartup(exeName, index) {
    global wmiStartupSink, wowPID, cancelBtn, memoryTimerRunning, currentTracker

    try {
        ; Создаём объект для получения событий
        wmiStartupSink := ComObject("WbemScripting.SWbemSink")
        ComObjConnect(wmiStartupSink, "WMIStartup_")

        ; Подключаемся к WMI
        wmi := ComObjGet("winmgmts:\\.\root\CIMV2")

        ; Подписываемся на события создания процесса с нужным именем
        query := "SELECT * FROM __InstanceCreationEvent WITHIN 1 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = '" exeName "'"
        wmi.ExecNotificationQueryAsync(wmiStartupSink, query)

        ; Сохраняем индекс игры
        wmiStartupSink.index := index

    } catch as err {
        ; Если WMI недоступен, используем старый метод с циклом
        SetTimer(() => WaitForProcessStartup(exeName, index), 100)
    }
}

; Обработчик WMI события создания процесса
WMIStartup_OnObjectReady(objWbemObject, *) {
    global wowPID, cancelBtn, memoryTimerRunning, currentTracker, wmiStartupSink

    try {
        if (objWbemObject.Path_.Class = "__InstanceCreationEvent") {
            ; Процесс запустился
            targetInstance := objWbemObject.TargetInstance
            wowPID := targetInstance.ProcessId

            if !IsSet(wmiStartupSink)
                return

            index := wmiStartupSink.index

            ; Отписываемся от событий запуска
            try wmiStartupSink.Cancel()
            wmiStartupSink := ""

            ; Делаем кнопку Отмена видимой
            cancelBtn[index].Visible := true

            ; Запускаем таймер отслеживания окна
            if !memoryTimerRunning {
                currentTracker := TrackWoWWindow.Bind(index)
                SetTimer(currentTracker, 500)
                memoryTimerRunning := true
            }
        }
    }
}

; Обработчик завершения асинхронной операции WMI для запуска
WMIStartup_OnCompleted(*) {
    ; Событие завершения запроса (не используется)
}

; Fallback: ожидание запуска процесса через таймер
WaitForProcessStartup(exeName, index) {
    global wowPID, cancelBtn, memoryTimerRunning, currentTracker

    if ProcessExist(exeName) {
        wowPID := ProcessExist(exeName)
        SetTimer(, 0)

        ; Делаем кнопку Отмена видимой
        cancelBtn[index].Visible := true

        ; Запускаем таймер отслеживания окна
        if !memoryTimerRunning {
            currentTracker := TrackWoWWindow.Bind(index)
            SetTimer(currentTracker, 500)
            memoryTimerRunning := true
        }
    }
}

; Подписка на WMI события закрытия процесса
SubscribeToProcessEvents(index) {
    global wowPID, wmiSink

    try {
        ; Создаём объект для получения событий
        wmiSink := ComObject("WbemScripting.SWbemSink")
        ComObjConnect(wmiSink, "WMI_")

        ; Подключаемся к WMI
        wmi := ComObjGet("winmgmts:\\.\root\CIMV2")

        ; Подписываемся на события удаления процесса
        queryDelete := "SELECT * FROM __InstanceDeletionEvent WITHIN 1 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.ProcessId = " wowPID
        wmi.ExecNotificationQueryAsync(wmiSink, queryDelete)

        ; Сохраняем индекс игры для обработчика событий
        wmiSink.index := index

    } catch as err {
        ; Если WMI недоступен, используем таймер как fallback
        SetTimer(() => CheckWindowState(index), 1000)
    }
}

; Обработчик события WMI (получение объекта события)
WMI_OnObjectReady(objWbemObject, *) {
    global wowPID, minOnLaunchCB, minToTrayCB, restoreOnCloseCB, wmiSink

    try {
        ; Проверяем, что это событие удаления процесса
        if (objWbemObject.Path_.Class = "__InstanceDeletionEvent") {
            ; Процесс игры закрылся
            if !IsSet(wmiSink)
                return

            index := wmiSink.index

            ; Скрываем индикацию запущенной игры
            HideRunIndicator(index)

            ; Разворачиваем окно, если включена соответствующая опция
            if (minOnLaunchCB.Value && restoreOnCloseCB.Value) {
                if (minToTrayCB.Value)
                    ShowMainWindow()
                else
                    WinRestore("ahk_id " myGui.Hwnd)
            }

            ; Отписываемся от событий
            try wmiSink.Cancel()
            wmiSink := ""
        }
    }
}

; Обработчик завершения асинхронной операции WMI
WMI_OnCompleted(*) {
    ; Событие завершения запроса (не используется)
}

; Fallback: проверка состояния окна по таймеру (если WMI недоступен)
CheckWindowState(index) {
    global wowPID, minOnLaunchCB, minToTrayCB, restoreOnCloseCB

    if !ProcessExist(wowPID) {
        ; Процесс закрылся
        SetTimer(, 0)

        ; Скрываем индикацию запущенной игры
        HideRunIndicator(index)

        if (minOnLaunchCB.Value && restoreOnCloseCB.Value) {
            if (minToTrayCB.Value)
                ShowMainWindow()
            else
                WinRestore("ahk_id " myGui.Hwnd)
        }
    }
}

CancelWoW(index, *) {
    global wowPID, progress, cancelBtn, gameBtn, memoryTimerRunning, currentTracker, wmiStartupSink, wmiSink

    if wowPID && ProcessExist(wowPID)
        ProcessClose(wowPID)

    if currentTracker
        SetTimer(currentTracker, 0)

    ; Отписываемся от WMI событий, если они активны
    if IsSet(wmiStartupSink) && wmiStartupSink != "" {
        try wmiStartupSink.Cancel()
        wmiStartupSink := ""
    }

    if IsSet(wmiSink) && wmiSink != "" {
        try wmiSink.Cancel()
        wmiSink := ""
    }

    memoryTimerRunning := false
    progress.Visible := false
	cancelBtn[index].Visible := false
    cancelBtn[index].Text := "Отмена"
	gameBtn[index].Enabled := true
    HideRunIndicator(index) ; Скрываем индикацию
}

; === Функция GUI-ошибки ===
GuiError(msg) {
    MsgBox msg, "Ошибка", "Iconx"
}

; === Получение использования памяти в MB ===
GetProcessMemoryMB(pid) {
    try {
        wmi := ComObjGet("winmgmts:")
        if !wmi {
            return 0
        }
        query := wmi.ExecQuery("Select * from Win32_Process where ProcessId=" pid)
        if !query {
            return 0
        }
        for proc in query {
            if (proc.WorkingSetSize) {
                return Round(proc.WorkingSetSize / 1024 / 1024)
            }
        }
    } catch as err {
        ; Если WMI недоступен, возвращаем 0
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

; === Окошко настройки слота (ОНС) ===
OpenSettingsMenu(index, isNew, *) {
    global iniPath, myGui, gameName, password, game

    editGui := Gui("+Owner" myGui.Hwnd " +ToolWindow", "Настройка слота " index)
    editGui.SetFont("s10", "Segoe UI")
    editGui.OnEvent("Escape", (*) => (myGui.Opt("-Disabled"), editGui.Destroy()))
    editGui.OnEvent("Close", (*) => (myGui.Opt("-Disabled"), editGui.Destroy()))

    editGui.AddText("xm ym w70 h22 0x200", "Название:")
    editName := editGui.AddEdit("x+5 yp w240", gameName[index])

    editGui.AddText("xm y+5 w70 h22 0x200", "Файл игры:")
    editPath := editGui.AddEdit("r3 x+5 yp w176", game[index])
    btnBrowseGame := editGui.AddButton("x+5 yp w60", "Обзор")
    btnBrowseGame.OnEvent("Click", (*) => BrowseFile(editPath, editName, "Исполняемые файлы и Ярлыки (*.exe; *.lnk)"))

    editGui.AddText("xm y+34 w70 h22 0x200", "Пароль:")
    editPass := editGui.AddEdit("x+5 yp w206 Password", password[index])
    btnTogglePass := editGui.AddButton("x+5 yp w30 h25", "👁")
    btnTogglePass.OnEvent("Click", (*) => TogglePasswordVisibility(editPass, btnTogglePass))

    ; Кнопки управления
    if (isNew) {
        ; Если слот новый, делаем кнопку добавления на всю ширину
        btnSave := editGui.AddButton("xm y+5 w316 h30", "Добавить игру")
    } else {
        ; Если слот редактируется, рисуем две кнопки в ряд
        btnSave := editGui.AddButton("xm y+5 w153 h30", "Сохранить")
        
        btnDelete := editGui.AddButton("x+10 yp w153 h30", "Удалить")
        btnDelete.OnEvent("Click", ClearSlotSettings.Bind(index, editGui))
    }

    btnSave.OnEvent("Click", SaveSlotSettings.Bind(index, editGui, editName, editPath, editPass))

    ; Обработчик Enter для окна настроек
    saveHandler := SaveSlotSettings.Bind(index, editGui, editName, editPath, editPass)

    ; Устанавливаем контекстно-зависимую горячую клавишу только для этого окна
    HotIfWinActive("ahk_id " editGui.Hwnd)
    HotKey("Enter", saveHandler, "On")
    HotIfWinActive()

    ; Функция очистки при закрытии окна
    CleanupEditGui := (*) => (
        HotIfWinActive("ahk_id " editGui.Hwnd),
        HotKey("Enter", "Off"),
        HotIfWinActive(),
        myGui.Opt("-Disabled"),
        editGui.Destroy()
    )

    editGui.OnEvent("Close", CleanupEditGui)
    editGui.OnEvent("Escape", CleanupEditGui)

    myGui.Opt("+Disabled") ; Блокируем главное окно, пока открыты настройки

    ; Показываем окно, чтобы получить его размеры
    editGui.Show("Hide")

    ; Получаем координаты и размеры главного окна
    myGui.GetPos(&mainX, &mainY, &mainW, &mainH)

    ; Получаем размеры окна настроек
    editGui.GetPos(, , &editW, &editH)

    ; Вычисляем координаты для центрирования
    centerX := mainX + (mainW - editW) // 2
    centerY := mainY + (mainH - editH) // 2

    ; Показываем окно в центре
    editGui.Show("x" centerX " y" centerY)
}

TogglePasswordVisibility(editPass, btnTogglePass) {
    static isVisible := Map()

    ; Используем hwnd как ключ для отслеживания состояния каждого поля
    hwnd := editPass.Hwnd

    if (!isVisible.Has(hwnd))
        isVisible[hwnd] := false

    ; Переключаем состояние
    isVisible[hwnd] := !isVisible[hwnd]

    if (isVisible[hwnd]) {
        ; Показываем пароль
        editPass.Opt("-Password")
        btnTogglePass.Text := "🙈"
    } else {
        ; Скрываем пароль
        editPass.Opt("+Password")
        btnTogglePass.Text := "👁"
    }
}

BrowseFile(editCtrl, nameCtrl, filter) {
    ; Определяем начальную папку
    startDir := A_Desktop ; По умолчанию Рабочий стол

    ; Если в поле уже указан путь, пытаемся открыть его папку
    currentPath := editCtrl.Value
    if (currentPath != "") {
        SplitPath(currentPath, , &currentDir)
        if (currentDir != "" && DirExist(currentDir)) {
            startDir := currentDir
        }
    }

    ; Если папка не определена из текущего пути, используем стандартные
    if (startDir == A_Desktop) {
        if DirExist("D:\Games")
            startDir := "D:\Games"
        else if DirExist("C:\Games")
            startDir := "C:\Games"
    }

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
    global iniPath, gameName, password, game

    ; Проверяем, что окно и контролы ещё существуют
    try {
        if (!IsObject(editGui) || !IsObject(editName) || !IsObject(editPath) || !IsObject(editPass))
            return
        if (!editGui.Hwnd)
            return
    } catch {
        return
    }

    if (editName.Value == "" || editPath.Value == "") {
        MsgBox("Поля 'Название' и 'Файл игры' обязательны для заполнения!", "Ошибка", "Iconx")
        return
    }

    ; Проверяем, изменились ли данные
    oldName := gameName[index]
    oldPath := game[index]
    oldPass := password[index]

    if (editName.Value == oldName && editPath.Value == oldPath && editPass.Value == oldPass) {
        ; Данные не изменились - просто закрываем окно
        editGui.Destroy()
        myGui.Opt("-Disabled")
        return
    }

    ; Данные изменились - сохраняем и перезагружаем
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

    ; Проверяем, активно ли окно, которому принадлежит элемент
    try {
        ctrl := GuiCtrlFromHwnd(hwnd)
        if (ctrl && ctrl.Gui.Hwnd != WinExist("A")) {
            ; Окно неактивно - скрываем подсказку и сбрасываем состояние
            ToolTip()
            PrevHwnd := 0
            return
        }
    }

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
    } else if (InStr(ctrl.Gui.Title, "Настройка слота")) {
        ; Подсказки для окна настройки слота
        if (ctrl.Type = "Button") {
            if (ctrl.Text = "👁" || ctrl.Text = "🙈") {
                text := "Показать/скрыть пароль"
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
indicatorGui := unset
suspendIndicatorGui := unset
statusIndicatorGui := unset
wowTitles := ["World of Warcraft", "Turtle WoW", "WoWCircle"]

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

; === Функции индикации запущенной игры ===
ShowRunIndicator(index) {
    global iniPath, gameBtn, gameName, indicatorSquare

    ; Читаем актуальное значение из INI
    indicatorType := IniRead(iniPath, "Settings", "RunIndicatorType", "1")

    if (indicatorType = "0") {
        ; Без индикации
        return
    } else if (indicatorType = "1") {
        ; Жирный текст
        gameBtn[index].SetFont("bold")
    } else if (indicatorType = "2") {
        ; Точка перед именем
        gameBtn[index].SetFont("bold")
        gameBtn[index].Text := "● " gameName[index]
    } else if (indicatorType = "3") {
        ; Зелёный кружок (эмодзи без изменения цвета)
        if indicatorSquare.Has(index) {
            indicatorSquare[index].Opt("c")  ; Сбрасываем цвет на дефолтный
            indicatorSquare[index].Text := "🟢"
        }
    }
}

HideRunIndicator(index) {
    global iniPath, gameBtn, gameName, indicatorSquare

    ; Читаем актуальное значение из INI
    indicatorType := IniRead(iniPath, "Settings", "RunIndicatorType", "1")

    if (indicatorType = "0") {
        ; Без индикации
        return
    } else if (indicatorType = "1") {
        ; Жирный текст
        gameBtn[index].SetFont("norm")
    } else if (indicatorType = "2") {
        ; Точка перед именем
        gameBtn[index].SetFont("norm")
        gameBtn[index].Text := gameName[index]
    } else if (indicatorType = "3") {
        ; Зелёный кружок (возвращаем тёмно-зелёный цвет для пустого кружка)
        if indicatorSquare.Has(index) {
            indicatorSquare[index].Opt("c008000")  ; Тёмно-зелёный для ○
            indicatorSquare[index].Text := "○"
        }
    }
}

; === Горячие клавиши для перезапуска скрипта ===
F5::ReloadFunc()
^r::ReloadFunc()
