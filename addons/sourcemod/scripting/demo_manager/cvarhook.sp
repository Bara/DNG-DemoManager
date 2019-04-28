public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] intValue)
{
	if(convar == g_cDemoPath)
	{
		if(!DirExists(intValue))
		{
			InitDirectory(intValue);
		}
	}
	else
	{
		CheckStatus();
	}
	
	if (convar == g_cTVName)
	{
		GetConVarString(g_cTVName, g_sTVName, sizeof(g_sTVName));
		SetTVName(FindSourceTv());
	}
}
