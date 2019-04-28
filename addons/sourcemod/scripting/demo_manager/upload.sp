void Upload_OnPluginStart()
{
	g_cDelete = AutoExecConfig_CreateConVar("demo_manager_upload_delete", "1", "Delete the demo (and the bz2) if upload was successful.", _, true, 0.0, true, 1.0);
	g_cTarget = AutoExecConfig_CreateConVar("demo_manager_upload_target", "demo_manager", "The ftp target to use for uploads.");
}

void UploadDemo(const char[] outFile, const char[] sDemo)
{
	char sTarget[32];
	g_cTarget.GetString(sTarget, sizeof(sTarget));
	
	DataPack pack = new DataPack();
	EasyFTP_UploadFile(sTarget, outFile, outFile, UploadComplete, pack);
	pack.WriteString(sDemo);
}

public int UploadComplete(const char[] sTarget, const char[] sLocalFile, const char[] sRemoteFile, int iErrorCode, DataPack pack)
{
	pack.Reset();
	char sDemo[PLATFORM_MAX_PATH];
	pack.ReadString(sDemo, sizeof(sDemo));
	delete pack;
	
	if(iErrorCode == 0)
	{
		LogToFileEx(g_sLogFile, "[UPLOAD] %s successfully uploaded!", sDemo);
		
		if(g_cDelete.BoolValue)
		{
			DeleteFile(sLocalFile);
		}
	}
	else
	{
		LogError("[demo_manager] Demo Upload of %s failed! (Error Code: %d)", sLocalFile, iErrorCode);
	}
}
