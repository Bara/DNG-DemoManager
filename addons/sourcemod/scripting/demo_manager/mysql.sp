void MySQL_OnPluginStart()
{
	if(SQL_CheckConfig("demo_manager"))
		Database.Connect(SQLConnect, "demo_manager");
}

public void SQLConnect(Database db, const char[] error, any data)
{
	if(db == null || strlen(error) > 0)
	{
		LogError("Error connecting to database: %s", error);
		return;
	}
		
	g_dDatabase = db;

	db.SetCharset("utf8mb4");
	
	g_dDatabase.Query(SQL_DoNothing, "CREATE TABLE IF NOT EXISTS `demo_manager`( `id` INT NOT NULL AUTO_INCREMENT, `ip` varchar(18) COLLATE utf8mb4_unicode_ci NOT NULL, `port` int(6) NOT NULL, `map` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL, `filename` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL, `start` int(11) NOT NULL, `end` int(11) NULL, `ticks` int(11) NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");
}

void SQL_InsertDemo(const char[] sDemo2)
{
	char sIP[18], sMap[32], sDemo[PLATFORM_MAX_PATH];
	
	GetCurrentMap(sMap, sizeof(sMap));
	
	strcopy(sDemo, sizeof(sDemo), sDemo2);
	ReplaceString(sDemo, sizeof(sDemo), "./", "");
	
	int iPort = FindConVar("hostport").IntValue;
	int ips[4];
	int iIP = FindConVar("hostip").IntValue;
	ips[0] = (iIP >> 24) & 0x000000FF;
	ips[1] = (iIP >> 16) & 0x000000FF;
	ips[2] = (iIP >> 8) & 0x000000FF;
	ips[3] = iIP & 0x000000FF;
	Format(sIP, sizeof(sIP), "%d.%d.%d.%d", ips[0], ips[1], ips[2], ips[3]);
	
	char sQuery[1024];
	Format(sQuery, sizeof(sQuery), "INSERT INTO demo_manager (ip, port, map, filename, start) VALUES(\"%s\", %d, \"%s\", \"%s\", UNIX_TIMESTAMP());", sIP, iPort, sMap, sDemo);
	
	g_dDatabase.Query(SQL_DoNothing, sQuery);
}

void SQL_UpdateDemo(const char[] sDemo2, int ticks)
{
	char sDemo[PLATFORM_MAX_PATH];
	
	strcopy(sDemo, sizeof(sDemo), sDemo2);
	ReplaceString(sDemo, sizeof(sDemo), "./", "");
	
	char sQuery[1024];
	Format(sQuery, sizeof(sQuery), "UPDATE demo_manager SET end = UNIX_TIMESTAMP(), ticks = %d WHERE filename = \"%s\";", ticks, sDemo);
	
	g_dDatabase.Query(SQL_DoNothing, sQuery);
}

public void SQL_DoNothing(Database db, DBResultSet results, const char[] error, any data)
{
	if(db == null || strlen(error) > 0)
	{
		LogError("SQL query error: %s", error);
		return;
	}
	
	RemoveOldDemos();
}

stock void RemoveOldDemos()
{
	char sQuery[128];
	// 7 Tage = 604800
	// 3 Tage = 259200
	// 1 Tag  = 86400
	Format(sQuery, sizeof(sQuery), "SELECT id FROM demo_manager WHERE start < UNIX_TIMESTAMP()-604800;");
	g_dDatabase.Query(SQL_DeleteDemos, sQuery);
}

public void SQL_DeleteDemos(Database db, DBResultSet results, const char[] error, any data)
{
	if(db == null || strlen(error) > 0)
	{
		LogError("SQL query error: %s", error);
		return;
	}
	
	while (results.MoreRows)
	{
		if (!results.FetchRow())
			continue;
		
		int iID = results.FetchInt(0);
		
		char sQuery[128];
		Format(sQuery, sizeof(sQuery), "DELETE FROM `demo_manager` WHERE `id` = '%d';", iID);
		g_dDatabase.Query(SQL_DoNothing, sQuery);
	}
}
