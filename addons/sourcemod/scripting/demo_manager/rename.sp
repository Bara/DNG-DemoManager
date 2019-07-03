void Rename_OnPluginStart()
{
    if((g_cTVName = FindConVar("tv_name")) == null)
    {
        SetFailState("Couldn't find cvar 'tv_name'");
    }
    
    g_cTVName.GetString(g_sTVName, sizeof(g_sTVName));
    g_cTVName.AddChangeHook(OnConVarChanged);
    
    SetTVName(FindGOTV());
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

int FindGOTV()
{
    for(int i; i <= MaxClients; i++)
    {
        if(i != 0 && IsClientInGame(i) && IsClientSourceTV(i))
        {
            return i;
        }
    }
    
    return -1;
}
