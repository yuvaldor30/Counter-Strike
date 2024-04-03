#include "amxmodx.inc"
#include "hamsandwich.inc"
#include "fvault.inc"
#include "users.inc"
#include "accounts.inc"

// #include "hitandrun.inc"

#define PLUGIN "Experience System API"
#define VERSION "1.0"
#define AUTHOR "MJ"

#define MIN_PLAYERS_TO_GET_EXP 6
#define EXP_PER_KILL 500

#define PREFIX "Experience System"

#pragma semicolon 1

new const Float:g_fPremiumExperienceMultiply[] =
{
	0.0,
	0.2,
	0.3,
	0.5
};

enum _: ePlayerData
{
	pd_iExp,
	pd_iLevel,
	pd_iRebirth
}

new const g_iExperienceRequired[] = 
{
	0,
	900,
	2400,
	7000
};

enum _: eOldMenu
{
	om_szMenu[20],
	om_szHandler[30]
}

enum _: OLD_MENUS
{
	OLDMENU_MAINMANAGEDATA,
	OLDMENU_MANAGEDATA
}

new g_szOldMenus[OLD_MENUS][eOldMenu] =
{
	{"Main_Manage_Data","handler_ManageDataMain"},
	{"ManageData","handler_ManageData"}
};

enum _: MODES
{
	MODE_ONLINE,
	MODE_OFFLINE
}

enum _: TYPES
{
	TYPE_EXPERIENCE,
	TYPE_LEVEL,
	TYPE_REBIRTH
}

enum _: eManageData
{
	md_szKey[25],
	md_iModeData,
	md_iEditType
};

new const g_szFileVault[] = "ExperienceData";

new g_iData[MAX_PLAYERS + 1][ePlayerData];

new g_aManageData[MAX_PLAYERS + 1][eManageData];

new g_iTargetData[MAX_PLAYERS + 1][ePlayerData];

new g_hForward;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for(new i; i < OLD_MENUS; i++)
		register_menucmd(register_menuid(g_szOldMenus[i][om_szMenu]),1023,g_szOldMenus[i][om_szHandler]);
	
	RegisterHam(Ham_Killed,"player","fwd_Killed",1);
	
	register_clcmd("say","cmd_SayHandler");
	register_clcmd("exp_managedata_key","cmd_KeyDataHandler");
	register_clcmd("exp_managedata_data","cmd_DataHandler");
	
	g_hForward = CreateMultiForward("fwd_PlayerLeveledUP", ET_IGNORE, FP_CELL, FP_CELL);
}

public plugin_natives()
{	
	register_native("exp_GetUserData","cmd_GetUserData");
	register_native("exp_GetUserFloatData","cmd_GetUserFloatData");
	register_native("exp_SetUserData","cmd_SetUserData");
	register_native("exp_GetMaxLevel","cmd_GetMaxLevel");
}

public cmd_GetUserData(const iParams,const iPluginID)
{
	new iRequiredParams = 2;
	
	if(iParams < iRequiredParams)
	{
		log_error(AMX_ERR_NATIVE,"[%s] cannot find enought parameters. %i/%i",PLUGIN ,iParams, iRequiredParams);
		return 0;
	}
	
	new iIndex = get_param(1);
	new iData = get_param(2);
	
	return g_iData[iIndex][iData];
}

public Float:cmd_GetUserFloatData(const iParams,const iPluginID)
{
	new iRequiredParams = 2;
	
	if(iParams < iRequiredParams)
	{
		log_error(AMX_ERR_NATIVE,"[%s] cannot find enought parameters. %i/%i",PLUGIN ,iParams, iRequiredParams);
		return 0.0;
	}
	
	new iIndex = get_param(1);
	new iData = get_param(2);
	
	if(iData == ePlayerData)
		return g_fPremiumExperienceMultiply[get_user_premium(iIndex)];
	
	return float(g_iData[iIndex][iData]);
}

public cmd_SetUserData(const iParams,const iPluginID)
{
	new iRequiredParams = 3;
	
	if(iParams < iRequiredParams)
	{
		log_error(AMX_ERR_NATIVE,"[%s] cannot find enought parameters. %i/%i",PLUGIN ,iParams, iRequiredParams);
		return 0;
	}
	
	new iIndex = get_param(1);
	new iData = get_param(2);
	new iAmount = get_param(3);
	
	g_iData[iIndex][iData] = iAmount;
	
	cmd_CheckLevelUP(iIndex);
	
	return 1;
}

public cmd_GetMaxLevel(const iParams,const iPluginID)
{
	return sizeof g_iExperienceRequired - 1;
}

public client_authorized(iIndex)
{
	arrayset(g_iData[iIndex],0,sizeof g_iData[]);
	
	cmd_LoadData(iIndex);
}

public client_disconnected(iIndex)
{
	cmd_SaveData(iIndex);
}

public cmd_SayHandler(const iIndex)
{
	new szMessage[192];
	read_args(szMessage,charsmax(szMessage));
	remove_quotes(szMessage);
	
	if(szMessage[0] == '/')
	{
		new szArgument[32];
		argbreak(szMessage,szArgument,charsmax(szArgument),szMessage,charsmax(szMessage));
		
		if(equali(szArgument[1],"xp") || equali(szArgument[1],"exp") || equali(szArgument[1],"level") || equali(szArgument[1],"rebirth") || equali(szArgument[1],"rebirths"))
		{
				
			new iTarget = iIndex;
			
			if(szMessage[0] != EOS)
			{
				new iPlayer[2];
		
				iPlayer[0] = find_player("bl",szMessage);
				iPlayer[1] = find_player("blj",szMessage);
				
				if(iPlayer[0] != iPlayer[1])
				{
					client_print_color(iIndex,print_team_default,"^4[%s] ^1There are more than ^41 ^1player with that name.",PREFIX);
					
					return PLUGIN_HANDLED;
				}
				
				else if(iPlayer[0] == iPlayer[1] && !iPlayer[0])
				{
					client_print_color(iIndex,print_team_default,"^4[%s] ^1The target ^3%s ^1cannot be found.",PREFIX,szMessage);
					
					return PLUGIN_HANDLED;
				}
					
				iTarget = iPlayer[0];
			}
				
			if(iTarget == iIndex)
			{
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have ^4%i^1/^4%i ^1experience, you are level ^4%i^1 and have ^4%i ^1rebirth%s.", PREFIX, g_iData[iTarget][pd_iExp]
				, g_iExperienceRequired[g_iData[iTarget][pd_iLevel] +1], g_iData[iTarget][pd_iLevel], g_iData[iTarget][pd_iRebirth], g_iData[iTarget][pd_iRebirth] == 1 ? "" : "s");
			}
			
			else
			{
				new szName[MAX_NAME_LENGTH];
				get_user_name(iTarget,szName,charsmax(szName));
				
				client_print_color(iIndex,print_team_default,"^4[%s] ^3%s ^1has ^4%i^1/^4%i ^1experience, he is level ^4%i^1 and has ^4%i ^1rebirth%s.", PREFIX, szName, g_iData[iTarget][pd_iExp]
				, g_iExperienceRequired[g_iData[iTarget][pd_iLevel] +1], g_iData[iTarget][pd_iLevel], g_iData[iTarget][pd_iRebirth], g_iData[iTarget][pd_iRebirth] == 1 ? "" : "s");
			}
			
			return PLUGIN_HANDLED;
		}
		
		if(equali(szArgument[1],"managexp"))
		{
			menu_ManageDataMain(iIndex);
			
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_CONTINUE;
}


public cmd_KeyDataHandler(const iIndex)
{
	new szMessage[192];
	read_args(szMessage,charsmax(szMessage));
	remove_quotes(szMessage);
	
	new szTemp[16];
	
	if(fvault_get_data(g_szFileVault,szMessage,szTemp,charsmax(szTemp)))
	{
		copy(g_aManageData[iIndex][md_szKey],charsmax(g_aManageData[][md_szKey]),szMessage);
		
		g_aManageData[iIndex][md_iModeData] = MODE_OFFLINE;
		
		new iPlayer = find_player("c",g_aManageData[iIndex][md_szKey]);
		
		if(iPlayer)
		{
			client_print_color(iIndex,print_team_default,"^4[%s] ^1The key ^4%s ^1is already connected as ^3%s^1.",PREFIX,g_aManageData[iIndex][md_szKey],get_key_name(g_aManageData[iIndex][md_szKey]));
			g_aManageData[iIndex][md_iModeData] = MODE_ONLINE;
		}
		
		cmd_LoadTargetData(iIndex,szMessage);
		menu_ManageData(iIndex);
	}
	else
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have enter unknown key.",PREFIX);
		client_cmd(iIndex,"messagemode exp_managedata_key");
	}
}

public cmd_DataHandler(const iIndex)
{
	new const szData[ePlayerData][] = {"Experience", "Level", "Rebirths"};
	new const iMax[ePlayerData] = {2147483647, sizeof g_iExperienceRequired - 1, 2147483647};
	
	new szMessage[192];
	read_args(szMessage,charsmax(szMessage));
	remove_quotes(szMessage);
	
	new iValue = str_to_num(szMessage);
	
	if(is_str_num(szMessage) && iValue < iMax[g_aManageData[iIndex][md_iEditType]] && iValue >= 0)
	{
		g_iTargetData[iIndex][g_aManageData[iIndex][md_iEditType]] = iValue;
		
		menu_ManageData(iIndex);
		
		client_print_color(iIndex,print_team_default,"^4[%s] ^3%s ^1data has been successfuly updated to ^4%d^1.",PREFIX,szData[g_aManageData[iIndex][md_iEditType]],iValue);
	}
	else
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have entered invalid number.",PREFIX);
		client_cmd(iIndex,"messagemode exp_managedata_data");
	}

}

public menu_ManageDataMain(const iIndex)
{
	if(get_user_access(iIndex) < ServerManager)
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have no access to this command.",PREFIX);
		
		return PLUGIN_HANDLED;
	}
	
	new szText[512],iLen;
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r[ \w%s \r] \wManage Data Main Menu^n\dChoose your favorite option:^n^n",PREFIX);
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r1. \yOnline \wPlayers Data^n");
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r2. \dOffline \wPlayers Data^n");
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r3. \rKey \wData^n");
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"^n\r4. \dReset Server Data^n");
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"^n\r0. \wExit \yManage Data Main Menu");
	
	new iKeys = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 9);
	
	show_menu(iIndex, iKeys, szText, -1, g_szOldMenus[OLDMENU_MAINMANAGEDATA][om_szMenu]);
	
	return PLUGIN_HANDLED;
}

public handler_ManageDataMain(const iIndex, const iKey)
{
	switch((iKey + 1) % 10)
	{
		case 1..2:
		{
			g_aManageData[iIndex][md_iModeData] = iKey;
			menu_ManageTarget(iIndex);
		}
		
		case 3:
		{
			client_cmd(iIndex,"messagemode exp_managedata_key");
		}
		
		case 4:
		{
			fvault_clear(g_szFileVault);
			
			new szName[MAX_NAME_LENGTH];
			get_user_name(iIndex,szName,charsmax(szName));
			
			for(new i = 1; i <= MAX_PLAYERS; i++)
			{
				if(!is_user_connected(i))
					continue;
				arrayset(g_iData[i],0,sizeof g_iData[]);
					
				if(i == iIndex)
					client_print_color(i,print_team_default,"^4[%s] ^1You have successfully reset ^4experience data^1's server",PREFIX);
				else
					client_print_color(i,print_team_default,"^4[%s] ^3%s ^1has reset ^4experience data^1's server",szName,PREFIX);
			}
		}
	}
	
	return PLUGIN_HANDLED;
}

public menu_ManageTarget(const iIndex)
{
	new szText[128],i,szKey[25];
	
	formatex(szText,charsmax(szText),"\r[ \w%s \r] \wManage Data \y%s Mode \wPlayers Menu^n\dChoose a player to edit data:",PREFIX, g_aManageData[iIndex][md_iModeData] == MODE_OFFLINE ? "Offline" : "Online");
	new iMenu = menu_create(szText,"handler_ManageTarget");
	
	if(g_aManageData[iIndex][md_iModeData] == MODE_OFFLINE)
	{
		new iSize = fvault_size(g_szFileVault);
		
		new iPlayer;
		
		for(i = 0; i < iSize; i++)
		{
			fvault_get_keyname(g_szFileVault,i,szKey,charsmax(szKey));
			
			iPlayer = find_player("c",szKey);
			
			if(!iPlayer)
				menu_additem(iMenu,get_key_name(szKey),szKey);
		}
	}
	
	else
	{
		new iNum,players[MAX_PLAYERS],szName[MAX_NAME_LENGTH];
		
		get_players(players,iNum,"ch");
		
		for(i = 0; i < iNum; i++)
		{
			get_user_name(players[i],szName,charsmax(szName));
			get_user_authid(players[i],szKey,charsmax(szKey));
			
			menu_additem(iMenu,szName,szKey);
		}
	}
	
	if(menu_items(iMenu))
	{
		menu_setprop(iMenu,MPROP_EXITNAME,"Back to \yManage Data Main Menu");

		menu_display(iIndex,iMenu);
	}
	
	else
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1There are no players data at ^3%s mode^1.",PREFIX,g_aManageData[iIndex][md_iModeData] == MODE_OFFLINE ? "offline" : "online");
		menu_ManageDataMain(iIndex);
	}
}

public handler_ManageTarget(const iIndex, const iMenu, const iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu);
		menu_ManageDataMain(iIndex);
		
		return PLUGIN_HANDLED;
	}
	
	new szKey[25],_shit;
	
	menu_item_getinfo(iMenu,iItem,_shit,szKey,charsmax(szKey),_,_,_shit);
	menu_destroy(iMenu);
	
	copy(g_aManageData[iIndex][md_szKey],charsmax(g_aManageData[][md_szKey]),szKey);
	
	cmd_LoadTargetData(iIndex,szKey);
	menu_ManageData(iIndex);
	
	return PLUGIN_HANDLED;
}


public menu_ManageData(const iIndex)
{
	if(get_user_access(iIndex) < ServerManager)
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have no access to this command.",PREFIX);
		
		return PLUGIN_HANDLED;
	}
	
	new szData[32];
	
	if(!fvault_get_data(g_szFileVault,g_aManageData[iIndex][md_szKey],szData,charsmax(szData)))
	{
		menu_ManageTarget(iIndex);
		
		return PLUGIN_HANDLED;
	}
	
	new szText[512],iLen;
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r[ \w%s \r] \wManage \y%s \wData Menu^n\dEdit data as you want:^n^n",PREFIX,g_aManageData[iIndex][md_iModeData] == MODE_OFFLINE ? "Key" : "Player");
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \wTarget Key: \y%s^n",g_aManageData[iIndex][md_szKey]);
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \wTarget Name: \y%s^n",get_key_name(g_aManageData[iIndex][md_szKey]));
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"^n\r1. \wExperience Data: \r%d Exp^n",g_iTargetData[iIndex][pd_iExp]);
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r2. \wLevel Data: \rLevel %d^n",g_iTargetData[iIndex][pd_iLevel]);
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r3. \wRebirths Data: \r%d Rebirth%s^n",g_iTargetData[iIndex][pd_iRebirth],g_iTargetData[iIndex][pd_iRebirth] == 1 ? "" : "s");
	
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"^n\r6. \wChange Target \d(\r%s\d)^n",g_aManageData[iIndex][md_iModeData] == MODE_OFFLINE ? "Key" : "Player");

	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"^n\r7. \dDelete \wData^n");
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r9. \ySave \wData^n");
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"^n\r0. \wBack to \y%s Mode Players Menu",g_aManageData[iIndex][md_iModeData] == MODE_OFFLINE ? "Key" : "Player");

	new iKeys = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 5) | (1 << 6) | (1 << 8) | (1 << 9);
	
	show_menu(iIndex, iKeys, szText, -1, g_szOldMenus[OLDMENU_MANAGEDATA][om_szMenu]);
	
	return PLUGIN_HANDLED;
}

public handler_ManageData(const iIndex, const iKey)
{
	if(get_user_access(iIndex) < ServerManager)
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have no access to this command.",PREFIX);
		
		return PLUGIN_HANDLED;
	}
	
	switch((iKey + 1) % 10)
	{
		case 0:
		{
			menu_ManageTarget(iIndex);
		}
		
		case 1..3:
		{
			g_aManageData[iIndex][md_iEditType] = iKey;
			client_cmd(iIndex,"messagemode exp_managedata_data");
		}
		
		case 6:
		{
			menu_ManageTarget(iIndex);
		}
		
		case 7:
		{
			new iTarget = find_player("c",g_aManageData[iIndex][md_szKey]);
			
			if(iTarget)
			{
				arrayset(g_iData[iTarget],0,sizeof g_iData[]);
				cmd_SaveData(iTarget);
				
				client_print_color(iTarget,print_team_default,"^4[%s] ^1Your ^4experience data ^1has been delete.",PREFIX);
			}
			
			else
			{		
				fvault_remove_key(g_szFileVault,g_aManageData[iIndex][md_szKey]);
			}
			
			client_print_color(iIndex,print_team_default,"^4[%s] ^1You have succesfully deleted ^3%s^1's ^4experience data^1.",PREFIX,get_key_name(g_aManageData[iIndex][md_szKey]));
		}
		
		case 9:
		{
			new iTarget = find_player("c",g_aManageData[iIndex][md_szKey]);
			
			if(iTarget)
			{
				for(new i; i < ePlayerData; i++)
					g_iData[iTarget][i] = g_iTargetData[iIndex][i];
				
				cmd_SaveData(iTarget);
				
				cmd_PrintData(iTarget,iTarget);
				client_print_color(iTarget,print_team_default,"^4[%s] ^1Your ^4experience data ^1has been edited, check your data at console.",PREFIX);
			}
			
			else
			{
				new szData[16],iLen;
				
				for(new i; i < ePlayerData; i++)
					iLen += formatex(szData[iLen],charsmax(szData) - iLen,"#%i",g_iTargetData[iIndex][i]);
					
				fvault_set_data(g_szFileVault,g_aManageData[iIndex][md_szKey],szData);
			}
			
			client_print_color(iIndex,print_team_default,"^4[%s] ^1You have succesfully edited ^3%s^1's ^4experience data^1.",PREFIX,get_key_name(g_aManageData[iIndex][md_szKey]));
		}
	}
	
	return PLUGIN_HANDLED;
}

public fwd_Killed(const iKilled, const iKiller)
{
	if(iKiller && iKiller <= MaxClients && is_user_connected(iKiller) && iKiller != iKilled)
	{	
		new iNum,players[MAX_PLAYERS];
		get_players(players,iNum,"ch");
		
		if(iNum >= MIN_PLAYERS_TO_GET_EXP)
		{
			new szName[MAX_NAME_LENGTH];
			get_user_name(iKilled,szName,charsmax(szName));
			
			new iExperience = EXP_PER_KILL;
			
			g_iData[iKiller][pd_iExp] += iExperience;
			cmd_CheckLevelUP(iKiller);
			
			client_print_color(iKiller,print_team_default,"^4[%s] ^1You have got ^4%d ^1experience points by killing ^3%s^1.",PREFIX, iExperience,szName);
		}
		else
			client_print_color(iKiller,print_team_default,"^4[%s] ^1There are not enough players to get experience by killing.",PREFIX);
	}
}

stock cmd_CheckLevelUP(const iIndex)
{
	static i,szName[MAX_NAME_LENGTH];
	get_user_name(iIndex,szName,charsmax(szName));
	
	new iReturn;
	
	while(g_iData[iIndex][pd_iExp] >= g_iExperienceRequired[g_iData[iIndex][pd_iLevel] + 1])
	{
		g_iData[iIndex][pd_iLevel] ++;
		g_iData[iIndex][pd_iExp] -= g_iExperienceRequired[g_iData[iIndex][pd_iLevel]];
		
		ExecuteForward(g_hForward, iReturn, iIndex, g_iData[iIndex][pd_iLevel]);
		
		for(i = 1; i <= MaxClients; i++)
		{
			if(!is_user_connected(i))
				continue;
				
			if(i == iIndex)
				client_print_color(i,print_team_default,"^4[%s] ^1You have leveled up and have become level ^4%i^1.",PREFIX,g_iData[iIndex][pd_iLevel]);
			else
				client_print_color(i,print_team_default,"^4[%s] ^3%s ^1has leveled up and has become level ^4%i^1.",PREFIX,szName,g_iData[iIndex][pd_iLevel]);
		}
		
		if(g_iData[iIndex][pd_iLevel] >= sizeof g_iExperienceRequired - 1)
		{
			g_iData[iIndex][pd_iLevel] = 0;
			g_iData[iIndex][pd_iRebirth] ++;
			
			for(i = 1; i <= MaxClients; i++)
			{
				if(!is_user_connected(i))
					continue;
					
				if(i == iIndex)
					client_print_color(i,print_team_default,"^4[%s] ^1Congratulations, You have been reborn as level^4 0^1, with^4 1 ^1more rebirth.",PREFIX);
				else
					client_print_color(i,print_team_default,"^4[%s] ^1Congratulations, ^3%s ^1has been reborn as level^4 0^1, with^4 1 ^1more rebirth.",PREFIX,szName);
			}
		}
	}
	
	cmd_SaveData(iIndex);
}

stock cmd_PrintData(const iIndex, const iPlayerData)
{
	static const szData[ePlayerData][] = {"Experience","Level","Rebirths"};
	
	static szKey[25],szName[MAX_NAME_LENGTH],i;
	
	get_user_name(iPlayerData,szName,charsmax(szName));
	get_user_name(iPlayerData,szKey,charsmax(szKey));
	
	console_print(iIndex,"******** Your experience data has been edited recently ********");
	console_print(iIndex,"Player Name: %s",szName);
	console_print(iIndex,"Player Key: %s",szKey);
	
	for(i = 0; i < ePlayerData; i++)
		console_print(iIndex,"%s Data: %d.",szData[i],g_iData[iPlayerData][i]);
	
	console_print(iIndex,"******** DONE ********");
}

stock cmd_LoadTargetData(const iIndex,const szKey[])
{
	static szData[16];
	
	if(fvault_get_data(g_szFileVault,szKey,szData,charsmax(szData)))
	{
		replace_all(szData,charsmax(szData),"#"," ");
		trim(szData);
		
		static szTemp[16];
		
		static i,iPlayer;
		
		iPlayer = find_player("c",szKey);
		
		if(iPlayer)		
			for(i = 0; i < ePlayerData; i++)
			{
				argbreak(szData,szTemp,charsmax(szTemp),szData,charsmax(szData));
				
				g_iTargetData[iIndex][i] = g_iData[iPlayer][i];
			}
		else
			for(i = 0; i < ePlayerData; i++)
			{
				argbreak(szData,szTemp,charsmax(szTemp),szData,charsmax(szData));
				
				g_iTargetData[iIndex][i] = str_to_num(szTemp);
			}
	}
	
	client_print_color(iIndex,print_team_default,"^4[%s] ^3%s^1's ^4experience data ^1has been successfully loaded.",PREFIX,get_key_name(szKey));
}

stock cmd_LoadData(const iIndex)
{
	new szData[16],szKey[25];
	get_user_authid(iIndex,szKey,charsmax(szKey));
	
	if(fvault_get_data(g_szFileVault,szKey,szData,charsmax(szData)))
	{
		replace_all(szData,charsmax(szData),"#"," ");
		trim(szData);
		
		new szTemp[8],iTemp;
		
		for(new i; i < ePlayerData; i++)
		{
			argbreak(szData,szTemp,charsmax(szTemp),szData,charsmax(szData));
			iTemp = str_to_num(szTemp);
			
			g_iData[iIndex][i] = iTemp;
		}
	}
}	

stock cmd_SaveData(const iIndex)
{
	static szKey[25];
	get_user_authid(iIndex,szKey,charsmax(szKey));
	
	new szData[16],iLen;
	
	for(new i; i < ePlayerData; i++)
		iLen += formatex(szData[iLen],charsmax(szData) - iLen,"#%i",g_iData[iIndex][i]);
	
	fvault_set_data(g_szFileVault,szKey,szData);
}
