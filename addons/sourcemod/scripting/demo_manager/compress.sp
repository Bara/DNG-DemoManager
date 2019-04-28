void CompressDemo(const char[] filename)
{
	char sDemo[PLATFORM_MAX_PATH], sBZip[PLATFORM_MAX_PATH];
	strcopy(sDemo, sizeof(sDemo), filename);
	Format(sBZip, sizeof(sBZip), "%s.bz2", sDemo);
	Handle pack = CreateDataPack();
	BZ2_CompressFile(sDemo, sBZip, 9, CompressionComplete, pack);
	WritePackString(pack, sDemo);
}

public int CompressionComplete(BZ_Error iError, char[] inFile, char[] outFile, any pack)
{
	ResetPack(pack);
	char sDemo[PLATFORM_MAX_PATH];
	ReadPackString(pack, sDemo, sizeof(sDemo));
	if(iError == BZ_OK)
	{
		LogToFileEx(g_sLogFile, "[COMPRESS] %s compressed to %s", sDemo, outFile);
		
		if(g_cDelete.BoolValue)
			DeleteFile(sDemo);
		
		UploadDemo(outFile, sDemo);
	}
	else
		LogBZ2Error(iError);
}