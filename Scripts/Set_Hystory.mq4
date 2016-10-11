//+------------------------------------------------------------------+
//|                                    Загрузка архива котировок.mq4 |
//|                                                              Spy |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Spy"
#property link      ""
#property version   "1.00"
#property strict
#property show_inputs

// объявления

#define BM_CLICK            0x00F5
#define WM_KEYDOWN          0x0100
#define WM_LBUTTONDBLCLK    0x0203
#define VK_F2               0x71
#define WS_DISABLED         0x08000000
#define TV_FIRST            0x1100        // TreeView messages
#define TVM_EXPAND          (TV_FIRST + 2)
#define TVM_GETNEXTITEM     (TV_FIRST + 10)
#define TVM_SELECTITEM      (TV_FIRST + 11)
#define TVM_GETITEMW        (TV_FIRST + 62)
#define TVGN_ROOT           0x0000
#define TVGN_PARENT         0x0003
#define TVGN_CHILD          0x0004
#define TVGN_NEXTVISIBLE    0x0006
#define TVGN_CARET          0x0009
#define TVE_COLLAPSE        0x0001
#define TVE_EXPAND          0x0002
#define TVIF_TEXT           0x0001

struct HISTDIALOG
{
    uint hWnd;
    uint hTreeView;
    uint hLoadBtn;
    uint hCloseBtn;
};

struct TVITEM
{
    uint    uMask;
    uint    hItem;
    uint    uState;
    uint    uStateMask;
    uint    pBuff;
    int     nBuffLen;
    int     nImage;
    int     nSelectedImage;
    int     nChildren;
    uint    lParam;
};

#import "user32.dll"
    int PostMessageW(uint hWnd, uint uMsg, uint wParam, uint lParam);
    int SendMessageW(uint hWnd, uint uMsg, uint wParam, uint lParam);
    bool SendMessageW(uint hWnd, uint uMsg, uint wParam, TVITEM &tv);
    uint GetParent(uint hWnd);
    uint GetForegroundWindow();
    bool IsWindow(uint hWnd);
    uint FindWindowExW(uint hwndParent, uint hwndChildAfter, string sClass, string sTitle);
    uint SetActiveWindow(uint hWnd);
    uint GetWindowLongW(uint hWnd, int nIndex);
#import "kernel32.dll"
    uint LocalAlloc(uint uFlags, uint uBytes);
    uint LocalFree(uint hMem);
    void RtlMoveMemory(string &pDest, uint pSrc, int bytes);
#import

// inputs
input bool bConfirmMQ = true;          // Разрешить загрузку со стороннего сервера
input bool bConfirmReculc = true;      // Подтверждать пересчёт таймфреймов
input bool bPeriod_M1  = false;        // Загрузить M1
input bool bPeriod_M5  = false;        // Загрузить M5
input bool bPeriod_M15 = false;        // Загрузить M15
input bool bPeriod_M30 = false;        // Загрузить M30
input bool bPeriod_H1  = false;        // Загрузить H1
input bool bPeriod_H4  = false;        // Загрузить H4
input bool bPeriod_D1  = false;        // Загрузить D1
input bool bPeriod_W1  = false;        // Загрузить W1
input bool bPeriod_MN  = false;        // Загрузить MN

// globals
string    g_sLang = "";
int       g_nSymbolsNumber = 0;
string    g_sSymbolsList[1];
string    g_sSymbolGroup[1];
int       g_nPeriod[9] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};

// -----------------------------------------------------------------------------------------------

int OnInit()
{
    // проверка разрешения dll
    if(!IsDllsAllowed())
    {
        printf("Вызов DLL должен быть разрешён.");
        return(INIT_FAILED);
    }

    // только для русского и английского языков терминала
    g_sLang = TerminalInfoString(TERMINAL_LANGUAGE);
    
    if(g_sLang != "English" && g_sLang != "Russian")
    {
        printf("English and russian languages only!");
        return(INIT_FAILED);
    }

    // читаем файлы symbols.sel и symgroups.raw, формируем список символов для закачки
    int hFile = FileOpenHistory("symbols.sel", FILE_BIN|FILE_READ);
    int hFileGroups = FileOpenHistory("symgroups.raw", FILE_BIN|FILE_READ);
    
    if(hFile <= 0)
    {
        printf("Ошибка открытия файла symbols.sel.");
        return(INIT_FAILED);
    }

    if(hFileGroups <= 0)
    {
        printf("Ошибка открытия файла symgroups.raw.");
        return(INIT_FAILED);
    }

    g_nSymbolsNumber = ((int)FileSize(hFile) - 4) / 128;
    
    ArrayResize(g_sSymbolsList, g_nSymbolsNumber);
    ArrayResize(g_sSymbolGroup, g_nSymbolsNumber);
    
    FileSeek(hFile, 4, SEEK_SET);

    for(int i = 0; i < g_nSymbolsNumber; i++)
    {
        g_sSymbolsList[i] = FileReadString(hFile, 12);
        FileSeek(hFile, 116, SEEK_CUR);
            
        // имя
        FileSeek(hFile, 4 + i*128, SEEK_SET);
        g_sSymbolsList[i] = FileReadString(hFile, 12);
        
        // номер группы
        FileSeek(hFile, 4 + i*128 + 24, SEEK_SET);    
        int nGroupNumber = FileReadInteger(hFile);
        
        // название группы из файла symgroups.raw
        FileSeek(hFileGroups, 80 * nGroupNumber, SEEK_SET);
        g_sSymbolGroup[i] = FileReadString(hFileGroups, 16);
    }

    FileClose(hFileGroups);
    FileClose(hFile);

    // формируем список требуемых таймфреймов
    g_nPeriod[0] *= bPeriod_M1;
    g_nPeriod[1] *= bPeriod_M5;
    g_nPeriod[2] *= bPeriod_M15;
    g_nPeriod[3] *= bPeriod_M30;
    g_nPeriod[4] *= bPeriod_H1;
    g_nPeriod[5] *= bPeriod_H4;
    g_nPeriod[6] *= bPeriod_D1;
    g_nPeriod[7] *= bPeriod_W1;
    g_nPeriod[8] *= bPeriod_MN;

    if(g_nPeriod[ArrayMaximum(g_nPeriod)] == 0)
    {
        printf("Не выбрано ни одного таймфрейма.");
        return(INIT_FAILED);
    }

    return(INIT_SUCCEEDED);
}

// -----------------------------------------------------------------------------------------------

void OnStart()
{
    // хэндл чарта
    long hChart = ChartGetInteger(ChartID(), CHART_WINDOW_HANDLE);

    // хэндл главного окна терминала
    uint hMT = (uint) hChart;

    while(GetParent(hMT))
        hMT = GetParent(hMT);

    // шлём окну терминала нажатие клавиши F2
    PostMessageW(hMT, WM_KEYDOWN, VK_F2, 0);

    // окно архива котировок и его элементы
    HISTDIALOG oArch;
    oArch.hWnd = 0;
    oArch.hTreeView = 0;
    oArch.hLoadBtn = 0;
    oArch.hCloseBtn = 0;

    // ищем открывшееся окно архива  и получаем его хэндл и хэндлы его элементов
    // поскольку функция PostMessageW возвращается, не дожидаясь обработки сообщения, ждём окно 1 секунду,
    // до его открытия активным будет окно терминала
    for(int i = 0; i <1000; i += 50)
    {
        if(GetForegroundWindow() == hMT)
        {
            Sleep(50);
            continue;
        }
        else
        {
            oArch.hWnd = GetForegroundWindow();
            break;
        }
    }
    
    if(!oArch.hWnd)
    {
        printf("Не удалось открыть окно архива котировок.");
        return;
    }

    // дерево инструментов
    oArch.hTreeView = FindWindowExW(oArch.hWnd, NULL, "SysTreeView32", "Tree1");

    if (!oArch.hTreeView)
        return;
            
    // кнопка загрузки
    if(g_sLang == "Russian")
        oArch.hLoadBtn = FindWindowExW(oArch.hWnd, NULL, "Button", "За&грузить");
    else
        oArch.hLoadBtn  = FindWindowExW(oArch.hWnd, NULL, "Button", "D&ownload");

    if (!oArch.hLoadBtn)
        return;

    // кнопка закрытия
    if(g_sLang == "Russian")
        oArch.hCloseBtn = FindWindowExW(oArch.hWnd, NULL, "Button", "&Закрыть");
    else
        oArch.hCloseBtn = FindWindowExW(oArch.hWnd, NULL, "Button", "&Close");

    if (!oArch.hCloseBtn)
        return;
    
    // загрузка выбранных данных
    for(int i = 0, nResult = 0; i < g_nSymbolsNumber && nResult == 0; i++)
    {
        for(int j = 0; j < 9; j++)
        {
            if(g_nPeriod[j] == 0)  
                continue;
                
            // закачка
            nResult = LoadArchiveHistory(oArch, g_sSymbolsList[i], g_sSymbolGroup[i], j);
            
            switch(nResult)
            {
            case 0:
                printf("%s%d: Загрузка успешно завершена.", g_sSymbolsList[i], g_nPeriod[j]);
                break;
            case 1:
                printf("Сервер истории отличается от торгового сервера.");
                break;
            case 2:
                printf("%s%d: Нет новых данных.", g_sSymbolsList[i], g_nPeriod[j]);
                nResult = 0;  // продолжаем
                break;
            case 3:
                printf("%s%d: Нет новых данных. Все таймфреймы пересчитаны.", g_sSymbolsList[i], g_nPeriod[j]);
                nResult = 0;  // продолжаем
                break;
            case 4:
                printf("%s%d: Нет новых данных. Пересчёт всех таймфреймов отменён.", g_sSymbolsList[i], g_nPeriod[j]);
                nResult = 0;  // продолжаем
                break;
            default:
                printf("%s%d: Ошибка работы скрипта. Скрипт завершён.", g_sSymbolsList[i], g_nPeriod[j]);
                break;
            }
        }
    }
    
    // закрываем окно архива
    while(IsWindow(oArch.hWnd))
    {
        SetActiveWindow(oArch.hWnd);
        SendMessageW(oArch.hCloseBtn, BM_CLICK, 0, 0);
        Sleep(50);
    }
}

// -----------------------------------------------------------------------------------------------

int LoadArchiveHistory(const HISTDIALOG &oArch, const string sSymbol, const string sGroup, int nPeriodID)
{
    // возвращаемое значение
    int nRetVal = 0;
    
    // для удобства
    uint hArch = oArch.hWnd;
    uint hTree = oArch.hTreeView;
    uint hLoadBtn = oArch.hLoadBtn;
    
    // элементы дерева
    uint hRootItem = 0;
    uint hGroupItem = 0;
    uint hSymbolItem = 0;
    uint hPeriodItem = 0;

    // вспомогательные флаги
    bool bGroupFound = false;
    bool bSymbolFound = false;
    bool bPeriodFound = false;
    
    string sRootItemText;
    
    // выбираем и раскрываем корневой элемент дерева
    hRootItem = SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_ROOT, NULL);

    // ищем нужную группу
    if (hRootItem)
    {
        // текст корневого элемента - понадобится ниже, при поиске диалоговых окон по заголовку
        sRootItemText = GetItemText(hTree, hRootItem);
        
        // раскрываем корневой элемент
        SendMessageW(hTree, TVM_EXPAND, TVE_EXPAND, hRootItem);
        

        hGroupItem = SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_CHILD, hRootItem);
        
        while(SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_PARENT, hGroupItem) == hRootItem)
        {
            string sGroupItemText = GetItemText(hTree, hGroupItem);
            
            if(sGroupItemText != sGroup)    // не та группа
            {
                SendMessageW(hTree, TVM_EXPAND, TVE_COLLAPSE, hGroupItem);
                hGroupItem = SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_NEXTVISIBLE, hGroupItem);
                continue;
            }
            else
            {
                SendMessageW(hTree, TVM_EXPAND, TVE_EXPAND, hGroupItem);
                bGroupFound = true;
                break;
            }
        }
    }
    else    // закрыто окно архива?
        return (-1);
    
    // ищем нужный символ
    if (bGroupFound)
    {
        hSymbolItem = SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_CHILD, hGroupItem);

        while (bGroupFound && SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_PARENT, hSymbolItem) == hGroupItem)
        {
            string sSymbolItemText = GetItemText(hTree, hSymbolItem);
            
            if (sSymbolItemText != sSymbol)   // не тот символ
            {
                SendMessageW(hTree, TVM_EXPAND, TVE_COLLAPSE, hSymbolItem);
                hSymbolItem = SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_NEXTVISIBLE, hSymbolItem);
                continue;
            }
            else
            {
                SendMessageW(hTree, TVM_SELECTITEM, TVGN_CARET, hSymbolItem);
                SendMessageW(hTree, WM_LBUTTONDBLCLK, 0, 0);
                SendMessageW(hTree, TVM_EXPAND, TVE_EXPAND, hSymbolItem);
                bSymbolFound = true;
                break;
            }
        }
    }
    
    // перемещаемся к требуемому таймфрейму
    if (bSymbolFound)
    {
        hPeriodItem = SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_CHILD, hSymbolItem);

        for (int i = 0; i < nPeriodID; i++)
            hPeriodItem = SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_NEXTVISIBLE, hPeriodItem);

        if (SendMessageW(hTree, TVM_GETNEXTITEM, TVGN_PARENT, hPeriodItem) == hSymbolItem)
        {
            SendMessageW(hTree, TVM_SELECTITEM, TVGN_CARET, hPeriodItem);
            SendMessageW(hTree, WM_LBUTTONDBLCLK, 0, 0);
            bPeriodFound = true;
        }
    }

    // закачка
    if (bPeriodFound)
    {
        // жмём кнопку "Загрузить"
        SetActiveWindow(hArch);
        PostMessageW(hLoadBtn, BM_CLICK, 0, 0);
        
        // после нажатия кнопки загрузки нужно дождаться какой-то реакции: либо кнопка должна стать неактивной,
        // либо должно появлиться окно с сообщением об отсутствии новых данных
        
        // циклическая проверка состояния кнопки "Загрузить" каждые 250 мс. Цикл продолжается, пока кнопка неактивна
        for(bool bRepeat = true; (GetWindowLongW(hLoadBtn, -16) & WS_DISABLED) > 0 || bRepeat; )
        {
            Sleep(250);
            
            // кнопка стала неактивной
            if((GetWindowLongW(hLoadBtn, -16) & WS_DISABLED) > 0)
                bRepeat = false;
        
            // проверяем, нет ли окна с предупреждением о загрузке с чужого сервера
            {
                uint hMQ = 0;
                uint hOK = 0;
                uint hCancel = 0;
                
                if(g_sLang == "Russian")
                {
                    hMQ = FindWindowExW(NULL, NULL, "#32770", "Предупреждение перед загрузкой");
                    hOK = FindWindowExW(hMQ, NULL, "Button", "OK");
                    hCancel = FindWindowExW(hMQ, NULL, "Button", "Отмена");
                }
                else
                {
                    hMQ = FindWindowExW(NULL, NULL, "#32770", "Download Warning");
                    hOK = FindWindowExW(hMQ, NULL, "Button", "OK");
                    hCancel = FindWindowExW(hMQ, NULL, "Button", "Cancel");
                }
                
                if(hMQ && hOK && hCancel)
                {
                    if (bConfirmMQ)
                    {
                        while(IsWindow(hMQ))
                        {
                            SetActiveWindow(hMQ);
                            SendMessageW(hOK, BM_CLICK, 0, 0);
                            Sleep(50);
                        }
                        printf("%s%d: Разрешена загрузка с сервера %s", sSymbol, g_nPeriod[nPeriodID], sRootItemText);
                        bRepeat = true;        // возможно появление сообщения об отсутствии новых данных, которое откроется с некоторой задержкой,
                                            // либо может сразу начаться загрузка. Необходимо дождаться какого-то из этих событий
                    }
                    else
                    {
                        while(IsWindow(hMQ))
                        {
                            SetActiveWindow(hMQ);
                            SendMessageW(hCancel, BM_CLICK, 0, 0);
                            Sleep(50);
                        }
                        printf("%s%d: Загрузка с сервера %s отменена.", sSymbol, g_nPeriod[nPeriodID], sRootItemText);
                        nRetVal = 1;        // загрузка с чужого сервера отменена
                        break;                // выходим из цикла
                    }
                }    
            }

            // проверяем, нет ли окна с предложением пересчитать все таймфреймы
            {
                uint hDlg = 0;
                uint hOK = 0;
                uint hCancel = 0;
                
                hDlg = FindWindowExW(NULL, NULL, "#32770", sRootItemText);        // заголовок окна совпадает с текстом коревого элемента дерева (имя сервера истории)

                if(hDlg)
                {
                    hOK = FindWindowExW(hDlg, NULL, "Button", "&Да");
                    hCancel = FindWindowExW(hDlg, NULL, "Button", "&Нет");
    
                    if(!hOK)    // язык системы - английский?
                    {
                        hOK = FindWindowExW(hDlg, NULL, "Button", "&Yes");
                        hCancel = FindWindowExW(hDlg, NULL, "Button", "&No");
                    }
    
                    if(hOK && !hCancel)        // если нет кнопки отмены, то это просто уведомление об осутствии новых данных, жмём ОК и выходим
                    {
                        while(IsWindow(hDlg))
                        {
                            SetActiveWindow(hDlg);
                            SendMessageW(hOK, BM_CLICK, 0, 0);
                            Sleep(50);
                        }
                        nRetVal = 2;        // нет новых данных
                        break;
                    }
                        
                    if(hOK && hCancel)        // диалог с предложением пересчитать все таймфреймы
                    {
                        if(bConfirmReculc)
                        {
                            while(IsWindow(hDlg))
                            {
                                SetActiveWindow(hDlg);
                                SendMessageW(hOK, BM_CLICK, 0, 0);
                                Sleep(50);
                            }
                            nRetVal = 3;    // подтверждён пересчёт таймфреймов
                            
                            // вновь жмём кнопку "Загрузить"
                            SetActiveWindow(hArch);
                            PostMessageW(hLoadBtn, BM_CLICK, 0, 0);
                            bRepeat = true;            // Необходимо дождаться загрузки
                        }
                        else
                        {
                            while(IsWindow(hDlg))
                            {
                                SetActiveWindow(hDlg);
                                SendMessageW(hCancel, BM_CLICK, 0, 0);
                                Sleep(50);
                            }
                            nRetVal = 4;            // отменён пересчёт таймфреймов, выходим из цикла
                            break;
                        }
                    }
                }
            }
        }
    }

    return (nRetVal);
}

// -----------------------------------------------------------------------------------------------

string GetItemText(uint hTreeView, uint hItem)
{
    string sItemText;
    StringInit(sItemText, 256, '.');
    
    TVITEM tv;
    tv.uMask = TVIF_TEXT;
    tv.hItem = hItem;
    tv.nBuffLen = StringBufferLen(sItemText);
    tv.pBuff = LocalAlloc(0, tv.nBuffLen);

    SendMessageW(hTreeView, TVM_GETITEMW, 0, tv);
    
    RtlMoveMemory(sItemText, tv.pBuff, tv.nBuffLen);

    LocalFree(tv.pBuff);
    
    return (sItemText);
}

// -----------------------------------------------------------------------------------------------
