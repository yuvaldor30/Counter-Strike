/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <users>

#pragma semicolon 1

#define PLUGIN "Users API System"
#define VERSION "1.0"
#define AUTHOR "MJ"

new g_szFile[] = "addons/amxmodx/configs/Users.txt";

new g_szLogFile[] = "UsersLog.txt";

enum _:PlayerData
{
	pd_szIP[16],
	pd_szName[32],
	pd_iLastConnected
}

new Array:g_aKeyList;

new Trie:g_tKeyData;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	g_aKeyList = ArrayCreate(25);
	g_tKeyData = TrieCreate();	
	
	LoadFile();
	
	set_task(300.0,"SaveFile",_,_,_,"b");
}


public plugin_natives()
{
	register_native("get_key_name_pointer","cmd_KeyName");
	// register_native("is_key_online","cmd_KeyOnline");
	register_native("get_key_last_connected","cmd_KeyConnected");
}

public plugin_end()
	SaveFile();

public cmd_KeyName(iPluginID, iParams)
{
	if(iParams < 1)
	{
		log_error(AMX_ERR_NATIVE,"[%s] cannot find enough parameters. %i/%i",PLUGIN,iParams,1);
		return PLUGIN_CONTINUE;
	}
	
	new szKey[25];
	get_string(1,szKey,charsmax(szKey));
	
	new iLength = get_param(3);
	
	if(!isValidKey(szKey))
	{
		log_amx("[%s] invalid key has been entered. (%s)",PLUGIN,szKey);
		set_string(2, szKey, charsmax(szKey));
		return PLUGIN_HANDLED;
	}
	
	
	new iPlayer = find_player("c",szKey);
	
	if(iPlayer)
		set_string(2, get_name(iPlayer), iLength);
		
	else
	{
		if(TrieKeyExists(g_tKeyData,szKey))
		{
			new pdData[PlayerData];
			TrieGetArray(g_tKeyData,szKey,pdData,PlayerData);
			set_string(2, pdData[pd_szName], iLength);
		}
		else	
			set_string(2, "Unregistered Name", MAX_NAME_LENGTH);
	}
	
	if(equali(szKey,"loopback"))
		set_string(2, "The System", iLength);
	
	return PLUGIN_HANDLED;
}

public cmd_KeyConnected(iPluginID, iParams)
{
	new szKey[25];
	get_string(1,szKey,charsmax(szKey));
	
	if(!TrieKeyExists(g_tKeyData,szKey))
		return NEVER_SEEN; // Never Connected
	
	new iPlayer = find_player("ch",szKey);
	if(iPlayer)
		return CURRENTLY_ONLINE; // Currently Online
		
	new pdData[PlayerData];
	
	TrieGetArray(g_tKeyData,szKey,pdData,PlayerData);
	
	return pdData[pd_iLastConnected];
}

public client_authorized(iIndex)
	UpdateData(iIndex);
	
public client_disconnected(iIndex)
	UpdateData(iIndex);

public LoadFile()
{
	if(!file_exists(g_szFile))
	{
		log_to_file(g_szLogFile,"Data file doesn't exist. (%s)",g_szFile);
		return;
	}
	
	new f = fopen(g_szFile,"rt");

	new szLine[128],pdData[PlayerData],szKey[25],iCounter,szTemp[15];
	
	while(fgets(f,szLine,charsmax(szLine)))
	{
		if(!szLine[0])
			continue;
		
		replace_all(szLine,charsmax(szLine),"^n","");
		argbreak(szLine,szKey,charsmax(szKey),szLine,charsmax(szLine));
		ArrayPushString(g_aKeyList,szKey);
		
		argbreak(szLine,pdData[pd_szIP],charsmax(pdData[pd_szIP]),szLine,charsmax(szLine));
		argbreak(szLine,pdData[pd_szName],charsmax(pdData[pd_szName]),szTemp,charsmax(szTemp));

		pdData[pd_iLastConnected] = str_to_num(szTemp);
		
		TrieSetArray(g_tKeyData,szKey,pdData,PlayerData);
		
		iCounter ++;
	}
	
	log_to_file(g_szLogFile,"[%s] Data file has been successfully uploaded. (%d users)",PLUGIN,iCounter);
	
	fclose(f);
}

public SaveFile()
{
	delete_file(g_szFile);
	
	for(new i = 0,szKey[25],szLine[128],pdData[PlayerData]; i < ArraySize(g_aKeyList); i++)
	{
		ArrayGetString(g_aKeyList,i,szKey,charsmax(szKey));
		
		TrieGetArray(g_tKeyData,szKey,pdData,PlayerData);
		
		//log_to_file(g_szLogFile,"[%s] Data last connected: %d",PLUGIN,pdData[pd_iLastConnected]);

		formatex(szLine,charsmax(szLine),"^"%s^" ^"%s^" ^"%s^" %d",szKey,pdData[pd_szIP],pdData[pd_szName],pdData[pd_iLastConnected]);
		//log_to_file(g_szLogFile,"[%s] Data successfully saved. (%s)",PLUGIN,szLine);
		
		write_file(g_szFile, szLine);
	}
	
}

// Stocks

stock UpdateData(iIndex)
{
	if(!iIndex) {
		return;
	}
	
	new pdData[PlayerData];
	
	formatex(pdData[pd_szIP],charsmax(pdData[pd_szIP]),get_ip(iIndex));
	formatex(pdData[pd_szName],charsmax(pdData[pd_szName]),get_name(iIndex));
	pdData[pd_iLastConnected] = get_systime();
	
	if(!TrieKeyExists(g_tKeyData,get_key(iIndex)))
		ArrayPushString(g_aKeyList,get_key(iIndex));
	
	TrieSetArray(g_tKeyData,get_key(iIndex),pdData,PlayerData);
	SaveFile();
	
	//log_to_file(g_szLogFile,"[%s] Data successfully updated. (%s - %s - %s - %d)",PLUGIN,get_key(iIndex),pdData[pd_szIP],pdData[pd_szName],pdData[pd_iLastConnected]);
}

stock get_name(const index)
{
	new szName[32];
	get_user_name(index,szName,charsmax(szName));
	
	return szName;
}

stock get_key(const index)
{
	new szKey[25];
	get_user_authid(index,szKey,charsmax(szKey));
	
	if(containi(szKey,"VALVE") != -1 || containi(szKey,"ID_LAN") != -1)
		get_user_ip(index,szKey,charsmax(szKey),1);
	
	return szKey;
}

stock get_ip(const index)
{
	new szIP[16];
	get_user_ip(index,szIP,charsmax(szIP),1);
	
	return szIP;
}

stock isValidKey(const Key[])
{
	if(strlen(Key) < 8)
		return false;
	
	if(containi(Key,"STEAM_") != -1 || containi(Key,"VALVE_") != -1 || containi(Key,".") != -1 || containi(Key,"loopback") != -1)
			return true;
			
	return false;
}
