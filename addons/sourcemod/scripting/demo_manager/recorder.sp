void Recorder_OnPluginStart()
{
	g_cMinPlayersStart = AutoExecConfig_CreateConVar("demo_manager_recorder_minplayers", "2", "Minimum players on server to start recording", _, true, 0.0);
	g_cIgnoreBots = AutoExecConfig_CreateConVar("demo_manager_recorder_ignorebots", "1", "Ignore bots in the player count", _, true, 0.0, true, 1.0);
	g_cDemoPath = AutoExecConfig_CreateConVar("demo_manager_recorder_path", ".", "Path to store recorded demos");
	
	char sPath[PLATFORM_MAX_PATH];
	g_cDemoPath.GetString(sPath, sizeof(sPath));
	if(!DirExists(sPath))
	{
		InitDirectory(sPath);
	}
	
	g_cDemoPath.AddChangeHook(OnConVarChanged);
	
	CreateTimer(10.0, Timer_CheckStatus, _, TIMER_REPEAT);
	
	StopRecord();
	CheckStatus();
}

void Recorder_OnMapStart()
{
	if(SourceTV_IsRecording())
	{
		StopRecord();
	}
}

void Recorder_OnMapEnd()
{
	if(SourceTV_IsRecording())
	{
		StopRecord();
	}
}

void Recorder_OnClientPutInServer()
{
	CheckStatus();
}

void Recorder_OnClientDisconnect_Post()
{
	CheckStatus();
}

public Action Timer_CheckStatus(Handle timer)
{
	CheckStatus();
}

void CheckStatus()
{
	int iMinClients = g_cMinPlayersStart.IntValue;
	
	if(g_dDatabase != null && !SourceTV_IsRecording() && GetPlayerCount() >= iMinClients)
	{
		StartRecord();
	}
	else if(SourceTV_IsRecording() && GetPlayerCount() < iMinClients)
	{
		StopRecord();
	}
}

void StartRecord()
{
	if(!SourceTV_IsRecording())
	{
		char sPath[PLATFORM_MAX_PATH], sTime[16], sMap[32], sFile[PLATFORM_MAX_PATH];
		
		g_cDemoPath.GetString(sPath, sizeof(sPath));
		FormatTime(sTime, sizeof(sTime), "%Y%m%d-%H%M%S", GetTime());
		GetCurrentMap(sMap, sizeof(sMap));
		
		ReplaceString(sMap, sizeof(sMap), "/", "-", false);		
		
		Format(sFile, sizeof(sFile), "%s/auto-%d-%s-%s", sPath, FindConVar("hostport").IntValue, sTime, sMap);
		StripQuotes(sFile);
		
		if (!SourceTV_StartRecording(sFile))
		{
			LogToFileEx(g_sLogFile, "[RECORDER] GOTV failed to start recording to: %s", sFile);
		}
	}
}

void StopRecord()
{
	if(SourceTV_IsRecording())
	{
		SourceTV_StopRecording();
	}
}

public void SourceTV_OnStartRecording(int instance, const char[] filename)
{
	LogToFileEx(g_sLogFile, "[RECORDER] Started recording gotv #%d demo to %s", instance, filename);
	
	if(g_dDatabase != null)
	{
		SQL_InsertDemo(filename);
	}
}

public void SourceTV_OnStopRecording(int instance, const char[] filename, int recordingtick)
{
	int iSize = FileSize(filename);
	
	if(iSize > 10000)
	{
		LogToFileEx(g_sLogFile, "[RECORDER] Stopped recording gotv #%d demo to %s (%d ticks, %d kb)", instance, filename, recordingtick, iSize);
		
		CompressDemo(filename);
		
		if(g_dDatabase != null)
		{
			SQL_UpdateDemo(filename, recordingtick);
		}
	}
	else
	{
		DeleteFile(filename);
	}
}

void InitDirectory(const char[] sDir)
{
	char sPieces[32][PLATFORM_MAX_PATH];
	char sPath[PLATFORM_MAX_PATH];
	int iNumPieces = ExplodeString(sDir, "/", sPieces, sizeof(sPieces), sizeof(sPieces[]));
	
	for(int i = 0; i < iNumPieces; i++)
	{
		Format(sPath, sizeof(sPath), "%s/%s", sPath, sPieces[i]);
		if(!DirExists(sPath))
		{
			CreateDirectory(sPath, 509);
		}
	}
}
