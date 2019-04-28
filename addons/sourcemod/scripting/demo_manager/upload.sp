void Upload_OnPluginStart()
{
	g_cDelete = CreateConVar("demo_manager_upload_delete", "1", "Delete the demo (and the bz2) if upload was successful.", _, true, 0.0, true, 1.0);
	g_cTarget = CreateConVar("demo_manager_upload_target", "demoManager", "The ftp target to use for uploads.");
}

void UploadDemo(const char[] outFile, const char[] sDemo)
{
	char sTarget[32];
	g_cTarget.GetString(sTarget, sizeof(sTarget));
	
	Handle pack = CreateDataPack();
	EasyFTP_UploadFile(sTarget, outFile, outFile, UploadComplete, pack);
	WritePackString(pack, sDemo);
}

public int UploadComplete(const char[] sTarget, const char[] sLocalFile, const char[] sRemoteFile, int iErrorCode, any pack)
{
	ResetPack(pack);
	char sDemo[PLATFORM_MAX_PATH];
	ReadPackString(pack, sDemo, sizeof(sDemo));
	
	if(iErrorCode == 0)
	{
		LogToFileEx(g_sLogFile, "[UPLOAD] %s successfully uploaded!", sDemo);
		
		if(g_cDelete.BoolValue)
			DeleteFile(sLocalFile);
	}
	else
		LogError("[demoManager] Demo Upload of %s failed! (Error Code: %d)", sLocalFile, iErrorCode);
}