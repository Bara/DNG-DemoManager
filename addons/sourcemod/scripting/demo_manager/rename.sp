void Rename_OnPluginStart()
{
	if((g_cTVName = FindConVar("tv_name")) == null)
	{
		SetFailState("Couldn't find cvar 'tv_name'");
	}
	
	GetConVarString(g_cTVName, g_sTVName, sizeof(g_sTVName));
	HookConVarChange(g_cTVName, OnConVarChanged);
	
	SetTVName(FindSourceTv());
}

void Rename_OnClientPostAdminCheck(int client)
{
	if(IsClientSourceTV(client))
	{
		SetTVName(client);
	}
}

void SetTVName(int client)
{
	if(IsClientValid(client))
	{
		SetClientInfo(client, "name", g_sTVName);
		SetClientName(client, g_sTVName);
		SourceTV_SetClientTVTitle(SourceTV_GetBotIndex(), g_sTVName);
	}
}

int FindSourceTv()
{
	for(int i; i <= MaxClients; i++)
	{
		if(IsClientValid(i) && IsClientSourceTV(i))
		{
			return i;
		}
	}
	
	return -1;
}
