public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(convar == g_cDemoPath)
	{
		if(!DirExists(newValue))
		{
			InitDirectory(newValue);
		}
	}
	else
	{
		CheckStatus();
	}
	
	if (convar == g_cTVName)
	{
		g_cTVName.GetString(g_sTVName, sizeof(g_sTVName));
		SetTVName(FindGOTV());
	}
}
