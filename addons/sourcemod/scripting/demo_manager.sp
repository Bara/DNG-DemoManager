#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <autoexecconfig>
#include <sourcetvmanager>
#include <bzip2>
#include <tEasyFTP>

#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsClientValid(%1))

ConVar g_cMinPlayersStart = null;
ConVar g_cIgnoreBots = null;
ConVar g_cDemoPath = null;
ConVar g_cTVName = null;
ConVar g_cDelete = null;
ConVar g_cTarget = null;

Database g_dDatabase = null;

char g_sTVName[MAX_NAME_LENGTH] = "";
char g_sLogFile[PLATFORM_MAX_PATH + 1] = "";

#include "demo_manager/cvarhook.sp"
#include "demo_manager/mysql.sp"
#include "demo_manager/rename.sp"
#include "demo_manager/recorder.sp"
#include "demo_manager/compress.sp"
#include "demo_manager/upload.sp"

public Plugin myinfo = 
{
    name = "Demo Manager - All in One package (Record, Compress, Upload and MySQL)",
    author = "Bara (based on Stevo.TVR's demo plugin)",
    description = "",
    version = "1.0.0",
    url = ""
}

public void OnPluginStart()
{
    char sDate[32];
    FormatTime(sDate, sizeof(sDate), "%y-%m-%d");
    BuildPath(Path_SM, g_sLogFile, sizeof(g_sLogFile), "logs/gotv_%s.log", sDate);
    
    AutoExecConfig_SetCreateDirectory(true);
    AutoExecConfig_SetCreateFile(true);
    AutoExecConfig_SetFile("demo_manager");
    MySQL_OnPluginStart();
    Recorder_OnPluginStart();
    Rename_OnPluginStart();
    Upload_OnPluginStart();
    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();
    
    RegConsoleCmd("sm_tick", Command_Tick);
}

public void OnPluginEnd()
{
    Recorder_OnMapEnd();
}

public void OnClientPostAdminCheck(int client)
{
    Rename_OnClientPostAdminCheck(client);
}

public Action Command_Tick(int client, int args)
{
    if(SourceTV_IsRecording())
    {
        ReplyToCommand(client, "Der aktuelle Tick ist %d.", SourceTV_GetRecordingTick());
    }
    else
    {
        ReplyToCommand(client, "Es läuft keine Aufnahme.");
    }
    return Plugin_Handled;
}

public void OnMapStart()
{
    Recorder_OnMapStart();
}

public void OnMapEnd()
{
    Recorder_OnMapEnd();
}

public void OnClientPutInServer(int client)
{
    Recorder_OnClientPutInServer();
}

public void OnClientDisconnect_Post(int client)
{
    Recorder_OnClientDisconnect_Post();
}

int GetPlayerCount()
{
    if(!g_cIgnoreBots.BoolValue)
    {
        return GetClientCount(false) - 1;
    }

    int iCount = 0;
    LoopClients(i)
    {
        iCount++;
    }

    return iCount;
}

stock bool IsClientValid(int client, bool bots = false)
{
    if (client > 0 && client <= MaxClients)
    {
        if(IsClientInGame(client) && (bots || !IsFakeClient(client)) && !IsClientSourceTV(client))
        {
            return true;
        }
    }
    
    return false;
}
