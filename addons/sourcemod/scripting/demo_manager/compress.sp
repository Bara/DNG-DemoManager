void CompressDemo(const char[] filename)
{
    char sDemo[PLATFORM_MAX_PATH];
    strcopy(sDemo, sizeof(sDemo), filename);

    char sBZip[PLATFORM_MAX_PATH];
    Format(sBZip, sizeof(sBZip), "%s.bz2", sDemo);

    DataPack pack = new DataPack();
    BZ2_CompressFile(sDemo, sBZip, 9, CompressionComplete, pack);
    pack.WriteString(sDemo);
}

public int CompressionComplete(BZ_Error iError, char[] inFile, char[] outFile, DataPack pack)
{
    pack.Reset();

    char sDemo[PLATFORM_MAX_PATH];
    pack.ReadString(sDemo, sizeof(sDemo));

    delete pack;

    if(iError == BZ_OK)
    {
        LogToFileEx(g_sLogFile, "[COMPRESS] %s compressed to %s", sDemo, outFile);
        
        if(g_cDelete.BoolValue)
        {
            DeleteFile(sDemo);
        }
        
        UploadDemo(outFile, sDemo);
    }
    else
    {
        LogBZ2Error(iError);
    }
}
