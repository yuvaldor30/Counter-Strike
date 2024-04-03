/* Plugin generated by AMXX-Studio */

#include "amxmodx.inc"
#include "cstrike.inc"
#include "hitandrun.inc"

#define PLUGIN "Help & Blocks Mod"
#define VERSION "1.0"
#define AUTHOR "MJ"

#define PREFIX "Misc System"

#pragma semicolon 1

enum _: eItemData
{
	iIndex_szName[30],
	iIndex_szCommand[30],
	iIndex_iMenu // 0 - All, 1 - T, 2 - CT, 3 - Admin, 4 - Owner
};

enum _: eTypes
{
	TYPE_GLOBALY,
	//TYPE_TERRORISTS,
	//TYPE_CTS,
	TYPE_ADMINISTRATORS,
	TYPE_SERVERMANAGERS
};

new const aCommands[] [eItemData] =
{
	{"Shop","/shop",TYPE_GLOBALY},
	{"Knives Shop","/knives",TYPE_GLOBALY},
	{"Scout Shop","/scouts",TYPE_GLOBALY},
	{"Skills Upgrades","/skills",TYPE_GLOBALY},
	{"My Exprience Data","/xp",TYPE_GLOBALY},
	{"My Shop Data","/cash",TYPE_GLOBALY},
	{"My Stats Data","/stats",TYPE_GLOBALY}
};

new aMenus[] [] =
{
	"Globaly",
	//"Terrorists",
	//"Counter-Terrorists",
	"Adminisrators",
	"Server Managers"
};

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	new const szAutoCvars[][][] =
	{
		{"mp_autoteambalance","0"},
		{"mp_autokick","0"},
		{"sv_alltalk","1"},
		{"sv_downloadurl", ""},
		{"sv_allowdownload", "1"},
		{"sv_allowupload", "1"},
		{"sv_airaccelerate ","10000"},
		{"mp_freezetime","0"}
	};

	
	for(new i; i < sizeof szAutoCvars; i++)
		server_cmd("%s ^"%s^"",szAutoCvars[i][0],szAutoCvars[i][1]);
	
	register_clcmd("chooseteam","menu_Main");
	register_clcmd("say /help","menu_Main");
}

public menu_Main(const iIndex)
{
	new szText[128];
	
	formatex(szText,charsmax(szText),"\r[ \w%s \r] \wHelp Main Menu",PREFIX);
	new iMenu = menu_create(szText,"handler_Main");

	new cb = menu_makecallback("Menus_Callback");
	
	for(new i = 0; i < sizeof aMenus; i++)
	{
		formatex(szText,charsmax(szText),"%s Menu",aMenus[i]);	
		menu_additem(iMenu,szText,.callback = cb);
	}
	
	menu_display(iIndex,iMenu);
	return 1;
}

public handler_Main(const iIndex,const iMenu,const iItem)
{
	menu_destroy(iMenu);
	
	if(iItem == MENU_EXIT)
		return;
		
	menu_Secondary(iIndex,iItem);
}

public Menus_Callback(const iIndex,const iMenu,const iItem)
	return cmd_Allowed(iIndex,iItem) ? ITEM_ENABLED : ITEM_DISABLED;

public menu_Secondary(const iIndex,const iType)
{
	new szText[128];
	
	formatex(szText,charsmax(szText),"\r[ \w%s \r] \wHelp y%s \wMenu",PREFIX,aMenus[iType]);
	new iMenu = menu_create(szText,"handler_Secondary");
	
	for(new i = 0; i < sizeof aCommands; i++)
		if(aCommands[i][iIndex_iMenu] == iType)
			menu_additem(iMenu,aCommands[i][iIndex_szName],aCommands[i][iIndex_szCommand]);
			
	menu_display(iIndex,iMenu);
}

public handler_Secondary(const iIndex,const iMenu,const iItem)
{
	if(iItem == MENU_EXIT)
	{
		menu_destroy(iMenu);
		return;
	}
		
	new iShit,szCommand[30];
	
	menu_item_getinfo(iMenu,iItem,iShit,szCommand,charsmax(szCommand),_,_,iShit);
	menu_destroy(iMenu);
	
	client_cmd(iIndex,"say %s",szCommand);
}


stock cmd_Allowed(const iIndex, const iMenu)
{
	switch(iMenu)
	{
		//case 1:
		//	return cs_get_user_team(iIndex) == CS_TEAM_T;
		case TYPE_ADMINISTRATORS:
			return get_user_access(iIndex) >= Administrator;
		case TYPE_SERVERMANAGERS:
			return get_user_access(iIndex) >= ServerManager;
	}
	
	return true;
}
