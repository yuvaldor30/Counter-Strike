/* Plugin generated by AMXX-Studio */

#include "amxmodx.inc"
#include "hitandrun.inc"
#include "missions_api.inc"

#define PLUGIN "Missions System API"
#define VERSION "NeverTested"
#define AUTHOR "MJ"

#define MISSIONS_CHANGE_MISSION_RPICE 15000

#define MISSIONS_ONE_STEP_NAME "One Time Mission"

#define MISSIONS_MIN_PLAYER_TO_CMPLETE_MISSION 1

#pragma semicolon 1

enum _:eForwards
{
	FWD_LOADMISSIONS,
}

new const g_szTypes[eMissionTypes][] =
{
	"Easy",
	"Normal",
	"Medium",
	"Hard",
	"Expert"
};

enum _: ePlayerData
{
	pd_iMissionID,
	pd_iLevel,
	pd_iCurrently,
	Array:pd_aMissionsDone
}

new const g_szFile[] = "addons/amxmodx/data/missions_PlayersData.txt";

new Array:g_aMissionIDs = Invalid_Array;
new Trie:g_tMissions = Invalid_Trie;

new Array:g_aDataIDs = Invalid_Array;
new Trie:g_tData = Invalid_Trie;

new g_hForwards[eForwards];

// NPC Load
new g_iItemID;

new Float:g_fNpcOrigin[MAX_PLAYERS + 1][3];

new g_iData[MAX_PLAYERS + 1][ePlayerData];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	while(g_aMissionIDs == Invalid_Array)
		g_aMissionIDs = ArrayCreate();
		
	while(g_tMissions == Invalid_Trie)
		g_tMissions = TrieCreate();
		
	while(g_aDataIDs == Invalid_Array)
		g_aDataIDs = ArrayCreate(25);
		
	while(g_tData == Invalid_Trie)
		g_tData = TrieCreate();
		
	g_hForwards[FWD_LOADMISSIONS] = CreateMultiForward("fwd_LoadMissions",ET_IGNORE);
	
	set_task(0.1,"cmd_LoadMissions");
	
	cmd_LoadFile();
	
	//register_clcmd("test","test");
	
	//register_clcmd("say /missiontest","cmd_MissionsList");
	//register_clcmd("say /missions","menu_MissionMain");
}
/*
public test(iIndex)
{
	ArrayPushCell(g_iData[iIndex][pd_aMissionsDone],4141);
}
*/

public client_authorized(iIndex)
{
	cmd_LoadData(iIndex);
}

public client_disconnected(iIndex)
{
	cmd_SaveData(iIndex);
	
	g_iData[iIndex][pd_iMissionID] = 0;
	g_iData[iIndex][pd_iLevel] = 0;
	g_iData[iIndex][pd_iCurrently] = 0;
	//ArrayDestroy(g_iData[iIndex][pd_aMissionsDone]);
}


public plugin_natives()
{	
	register_native("mission_AddMission","native_AddMission");
	register_native("mission_UpdateUserData","native_UpdateUserData");
	register_native("mission_GetUserMissionID","native_GetUserMissionID");
}

public cmd_LoadMissions()
{
	new iReturn;
	ExecuteForward(g_hForwards[FWD_LOADMISSIONS],iReturn);
	
	//for(new i; i < sizeof g_szFiles; i++)
	//	cmd_LoadFile(i);
}

public plugin_end()
{
	cmd_SaveFile();
	
	ArrayDestroy(g_aMissionIDs);
	TrieDestroy(g_tMissions);
}

public native_AddMission(const iPluginID, const iParams)
{
	new iRequiredParams = 2;
	
	if(iParams < iRequiredParams)
	{
		log_error(AMX_ERR_NATIVE,"[%s] cannot find enough parameters. %i/%i",PLUGIN ,iParams, iRequiredParams);
		return PLUGIN_CONTINUE;
	}
	
	new aData[eMissionData],szMissionID[10];
	
	get_array(1,aData,sizeof aData);
	new iMissionID = get_param(2);
	
	num_to_str(iMissionID,szMissionID,charsmax(szMissionID));
	
	ArrayPushCell(g_aMissionIDs,iMissionID);
	TrieSetArray(g_tMissions,szMissionID,aData,sizeof aData);
	
	return iMissionID;
}

public native_UpdateUserData(const iPluginID, const iParams)
{
	new iRequiredParams = 1;
	
	if(iParams < iRequiredParams)
	{
		log_error(AMX_ERR_NATIVE,"[%s] cannot find enough parameters. %i/%i",PLUGIN ,iParams, iRequiredParams);
		return;
	}
	
	new iIndex = get_param(1);
	
	static iNum,players[MAX_PLAYERS];
	
	get_players(players,iNum,"ch");
	
	if(iNum >= MISSIONS_MIN_PLAYER_TO_CMPLETE_MISSION)
	{
		g_iData[iIndex][pd_iCurrently] ++;
		cmd_SaveData(iIndex);
	}
}

public native_GetUserMissionID(const iPluginID, const iParams)
{
	new iRequiredParams = 1;
	
	if(iParams < iRequiredParams)
	{
		log_error(AMX_ERR_NATIVE,"[%s] cannot find enough parameters. %i/%i",PLUGIN ,iParams, iRequiredParams);
		return PLUGIN_CONTINUE;
	}
	
	new iIndex = get_param(1);
	
	return g_iData[iIndex][pd_iMissionID];
}

public menu_MissionsMain(const iIndex)
{
	new szText[512],iLen,iKeys;
	
	static iSize[2];
	
	iSize[0] = ArraySize(g_iData[iIndex][pd_aMissionsDone]);
	iSize[1] = ArraySize(g_aMissionIDs);
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\r[ \w%s \r] \wDaily Missions Main Menu^n\dChoose you favorite option:^n^n",PREFIX);

	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\r1. \wWhat are they the daily missions?^n^n");
	
	iKeys |= (1 << 0);
	
	if(g_iData[iIndex][pd_iMissionID])
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d2. You cannot take a new mission due to: \rYou have already had a mission\d.^n");
		
	else if(iSize[0] >= iSize[1])
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d2. You cannot take a new mission due to: \rYou have already done all of the missions today\d.^n");
		
	else
	{
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\r2. \wTake a new mission\d.^n");
		iKeys |= (1 << 1);
	}
	
	if(!g_iData[iIndex][pd_iMissionID])
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d3. You cannot change your mission due to: \rYou have not taken mission yet\d.^n");
		
	else if(iSize[0] == iSize[1] - 1)
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d3. You cannot change your mission due to: \rYou have already done all of the another missions today\d.^n");
		
	else if(shop_GetUserData(iIndex,SHOP_DATA_CASH) < MISSIONS_CHANGE_MISSION_RPICE)
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d3. You cannot change your mission due to: \rYou don't have enough money\d.^n");
		
	else
	{
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\r3. \wChange my mission\d(\r%d Cash\d).^n",MISSIONS_CHANGE_MISSION_RPICE);
		iKeys |= (1 << 2);
	}
	
	if(!g_iData[iIndex][pd_iMissionID])
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d4. You cannot change view your mission information due to: \rYou have not taken mission yet\d.^n");
		
	else
	{
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\r4. \wView my mission information\d.^n");
		iKeys |= (1 << 3);
	}
	
	if(!iSize[0])
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d5. You cannot view your missions history due to: \rYou have not done any mission yet\d.^n");
	
	else
	{
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"^n\r5. \wView my daily missions history\d(\y%d Mission%s\d).^n",iSize[0],iSize[0] == 1 ? "" : "s");
		iKeys |= (1 << 4);
	}
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"^n\r0. \wExit \yDaily Missions Main Menu");
	
	iKeys |= (1 << 9);
	
	display_menu(iIndex,iKeys,szText,"handler_MissionsMain");
}

public handler_MissionsMain(const iIndex, const iKey)
{
	if((iKey + 1) % 10 == 0)
		return;
		
	static Float:fOrigin[3];
	
	entity_get_vector(iIndex,EV_VEC_origin,fOrigin);
	
	if(get_distance_f(fOrigin,g_fNpcOrigin[iIndex]) > NPC_NPC_MAX_DISTANCE)
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You are too far from the ^3NPC^1.",PREFIX);
		
		return;
	}
	
	static iSize[2];
	
	iSize[0] = ArraySize(g_iData[iIndex][pd_aMissionsDone]);
	iSize[1] = ArraySize(g_aMissionIDs);
	
	switch((iKey + 1) % 10)
	{
		case 1:
			menu_MissionsInfo(iIndex);
		
		case 2:
		{
			if(g_iData[iIndex][pd_iMissionID])
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You cannot take a new mission due to you have already ^3had a mission^1.",PREFIX);
				
			else if(iSize[0] >= iSize[1])
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You cannot take a new mission due to you have already ^3done all of the missions ^1today.",PREFIX);
				
			else
			{
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully got new mission.",PREFIX);
				
				cmd_RandomMission(iIndex);
				menu_ViewMyMission(iIndex);
			}
		}
		
		case 3:
		{
			if(!g_iData[iIndex][pd_iMissionID])
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You cannot change your mission due to you have ^3not taken mission ^1yet.",PREFIX);
				
			else if(iSize[0] == iSize[1] - 1)
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You cannot change your mission due to you have already ^3done all of the another missions ^1today.",PREFIX);
				
			else if(shop_GetUserData(iIndex,SHOP_DATA_CASH) < MISSIONS_CHANGE_MISSION_RPICE)
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You cannot change your mission due to you ^3don't have enough money^1.",PREFIX);
				
			else
			{
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully changed your mission for ^4%d ^1cash.",PREFIX,MISSIONS_CHANGE_MISSION_RPICE);
				
				shop_AddUserData(iIndex,SHOP_DATA_CASH, - MISSIONS_CHANGE_MISSION_RPICE);
				
				cmd_RandomMission(iIndex);
				menu_ViewMyMission(iIndex);
			}
		}
		
		case 4:
		{
			if(!g_iData[iIndex][pd_iMissionID])
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You cannot change view your mission information due to you have ^3not taken mission ^1yet.",PREFIX);
				
			else
				menu_ViewMyMission(iIndex);
		}
		
		case 5:
		{
			if(!iSize[0])
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You cannot view your missions history due to you have ^3not done any mission ^1yet.",PREFIX);
			
			else
				menu_ViewHistory(iIndex);
		}
	}
}

public menu_MissionsInfo(const iIndex)
{
	new szText[512],iLen;
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\r[ \w%s \r] \wDaily Missions Information Menu^n^n",PREFIX);
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\yWhat are they the daily missions?^n^n");
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\wEvery day at \y00:00 \wo'clock all of daily missions history will be reset\d.^n");
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\wYou can \rtake a new mission \wif you don't have \ycurrently now \wa mission,^n");
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\wand you have not done all of the daily mission \ytoday \wyet\d.^n");
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"^n\wNeed at least \r%d players \wto complete the missions targets\d.^n",MISSIONS_MIN_PLAYER_TO_CMPLETE_MISSION);
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"^n\r0. \wBack to \yDaily Missions Main Menu");
	
	display_menu(iIndex,(1 << 9), szText,"handler_MissionsInfo");
}

public handler_MissionsInfo(const iIndex, const iKey)
{
	static Float:fOrigin[3];
	
	entity_get_vector(iIndex,EV_VEC_origin,fOrigin);
	
	if(get_distance_f(fOrigin,g_fNpcOrigin[iIndex]) > NPC_NPC_MAX_DISTANCE)
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You are too far from the ^3NPC^1.",PREFIX);
		
		return;
	}
	
	menu_MissionsMain(iIndex);
}

public menu_ViewMyMission(const iIndex)
{
	new szText[512],iLen,iKeys,szMissionID[10];

	num_to_str(g_iData[iIndex][pd_iMissionID],szMissionID,charsmax(szMissionID));
	
	new tData[eMissionData];
	TrieGetArray(g_tMissions,szMissionID,tData, sizeof tData);
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\r[ \w%s \r] \wDaily Missions Menu^n\wYou are viewing \y%s\w's mission:^n^n",PREFIX,tData[md_szName]);
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d- \wMission Introduction: \y%s ^n",tData[md_szSummary]);
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d- \wMission Difficulty: \y%s ^n",g_szTypes[tData[md_iType]]);
	
	if(tData[md_iLevels] > 1)
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d- \wMission Steps: \r%d\d/\r%d ^n",g_iData[iIndex][pd_iLevel] + 1,tData[md_iLevels]);
	
	else
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d- \wMission Steps: \y%s ^n",MISSIONS_ONE_STEP_NAME);
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"^n\yMission Step Reward:^n");
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d- \wCash: \r%d^n",ArrayGetCell(tData[md_aMissionCash],g_iData[iIndex][pd_iLevel]));
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d- \wExperience: \r%d^n",ArrayGetCell(tData[md_aMissionExperience],g_iData[iIndex][pd_iLevel]));
	
	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"^n\d- \wCurrently Status: \r%d\d/\r%d \y%s^n^n",g_iData[iIndex][pd_iCurrently],ArrayGetCell(tData[md_aMissionTargets],g_iData[iIndex][pd_iLevel]),tData[md_szTargetName]);
	
	if(g_iData[iIndex][pd_iCurrently] < ArrayGetCell(tData[md_aMissionTargets],g_iData[iIndex][pd_iLevel]))
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\d1. You cannot take mission's prize due to: \rYou have not done the mission yet\d.^n");
		
	else
	{
		iLen += formatex(szText[iLen], charsmax(szText) - iLen,"\r1. \wTake Mission's Prize\d.^n");
		iKeys |= (1 << 0);
	}

	iLen += formatex(szText[iLen], charsmax(szText) - iLen,"^n\r0. \wBack to \yDaily Missions Main Menu");
	
	iKeys |= (1 << 9);
	
	display_menu(iIndex,iKeys,szText,"handler_ViewMyMission");
}

public handler_ViewMyMission(const iIndex, const iKey)
{
		
	static Float:fOrigin[3];
	
	entity_get_vector(iIndex,EV_VEC_origin,fOrigin);
	
	if(get_distance_f(fOrigin,g_fNpcOrigin[iIndex]) > NPC_NPC_MAX_DISTANCE)
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You are too far from the ^3NPC^1.",PREFIX);
		
		return;
	}
	
	if((iKey + 1) % 10 == 0)
	{
		menu_MissionsMain(iIndex);
		
		return;
	}
	
	new szMissionID[10],tData[eMissionData];

	num_to_str(g_iData[iIndex][pd_iMissionID],szMissionID,charsmax(szMissionID));
	
	TrieGetArray(g_tMissions,szMissionID,tData,sizeof tData);
	
	shop_AddUserData(iIndex,SHOP_DATA_CASH,ArrayGetCell(tData[md_aMissionCash],g_iData[iIndex][pd_iLevel]));
	exp_AddUserData(iIndex,EXPERIENCE_DATA_EXPERIENCE,ArrayGetCell(tData[md_aMissionExperience],g_iData[iIndex][pd_iLevel]));
	
	g_iData[iIndex][pd_iLevel] ++;
	
	if(g_iData[iIndex][pd_iLevel] >= tData[md_iLevels])
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully done the mission ^3%s^1.",PREFIX,tData[md_szName]);
		ArrayPushCell(g_iData[iIndex][pd_aMissionsDone],g_iData[iIndex][pd_iMissionID]);
		
		g_iData[iIndex][pd_iMissionID] = 0;
		g_iData[iIndex][pd_iLevel] = 0;
		g_iData[iIndex][pd_iCurrently] = 0;
	}
	
	else
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully done step ^4%d^1/^4%d ^1of the mission ^3%s^1.",PREFIX,g_iData[iIndex][pd_iLevel],tData[md_iLevels],tData[md_szName]);
	
	menu_MissionsMain(iIndex);
}

public menu_ViewHistory(const iIndex)
{
	new iSize = ArraySize(g_iData[iIndex][pd_aMissionsDone]);
	
	if(!iSize)
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have not done any mission yet.",PREFIX);
		
		menu_MissionsMain(iIndex);
		return;
	}
	
	new szText[128],szMissionID[10],tData[eMissionData];
	
	formatex(szText,charsmax(szText),"\r[ \w%s \r] \wDaily Missions Menu^n\wYour daily missions history:",PREFIX);
	new iMenu = menu_create(szText,"handler_ViewHistory");
	
	for(new i; i < iSize; i++)
	{
		num_to_str(ArrayGetCell(g_iData[iIndex][pd_aMissionsDone],i),szMissionID,charsmax(szMissionID));
		
		TrieGetArray(g_tMissions,szMissionID,tData,sizeof tData);
		
		if(tData[md_iLevels] > 1)
			formatex(szText,charsmax(szText),"\w%s \d(\y%d Steps\d)",tData[md_szName],tData[md_iLevels]);
			
		else
			formatex(szText,charsmax(szText),"\w%s \d(\y%s\d)",tData[md_szName],MISSIONS_ONE_STEP_NAME);
			
		menu_additem(iMenu,szText,.callback = 1);
	}
	
	menu_setprop(iMenu,MPROP_EXITNAME,"Back to \yMissions Main Menu");
	
	menu_display(iIndex,iMenu);
}

public handler_ViewHistory(const iIndex, const iMenu, const iItem)
{
	static Float:fOrigin[3];
	
	entity_get_vector(iIndex,EV_VEC_origin,fOrigin);
	
	if(get_distance_f(fOrigin,g_fNpcOrigin[iIndex]) > NPC_NPC_MAX_DISTANCE)
	{
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You are too far from the ^3NPC^1.",PREFIX);
		
		return;
	}
	
	menu_destroy(iMenu);
	
	if(iItem == MENU_EXIT)
		menu_MissionsMain(iIndex);
}
/*
public cmd_MissionsList(const iIndex)
{
	//new szMissions[128],iLen;
	
	new szTargets[128],iLen,iMissionLevel[3],szID[10];
	
	new iSize = ArraySize(g_aMissionIDs);
	
	new aData[eMissionData];
	
	for(new i,j; i < iSize; i++)
	{
		num_to_str(ArrayGetCell(g_aMissionIDs,i),szID,charsmax(szID));
		TrieGetArray(g_tMissions,szID,aData, sizeof aData);
		
		szTargets[0] = EOS;
		iLen = 0;
		
		for(j = 0; j < aData[md_iLevels]; j++)
		{
			iMissionLevel[0] = ArrayGetCell(aData[md_aMissionTargets],j);
			iMissionLevel[1] = ArrayGetCell(aData[md_aMissionExperience],j);
			iMissionLevel[2] = ArrayGetCell(aData[md_aMissionCash],j);
			
			iLen += formatex(szTargets[iLen], charsmax(szTargets) - iLen,"%s^3(^4%d^1, ^4%d^1, ^4%d^1^3)",j ? "^1, " : "", iMissionLevel[0], iMissionLevel[1], iMissionLevel[2]);
		}
		
		client_print_color(iIndex,print_team_default,"^4[%s] ^1Mission: ^3%s^1, Mission Levels: ^3%d^1, Mission Targets: ^3%s^1.",PREFIX,aData[md_szName],aData[md_iLevels],szTargets);
		
		//iLen += formatex(szMissions[iLen],charsmax(szMissions) - iLen,"%s ",aData[md_szName]);
		
	}
	
	client_print_color(iIndex,print_team_default,"^4[%s] ^1Missions amount: ^3%d",PREFIX,iSize);
}*/

// Forwards

public fwd_NpcLoadItems()
{
	g_iItemID = cmd_NpcAddItem("I would like to talk about the \rmissions\d.");
}
	
public fwd_NpcTocuhed(const iIndex, const iEntity)
{
	entity_get_vector(iEntity,EV_VEC_origin,g_fNpcOrigin[iIndex]);
}
	
public fwd_NpcItemChosen(const iIndex, const iItemID)
{
	if(iItemID == g_iItemID)
	{
		static Float:fOrigin[3];
		
		entity_get_vector(iIndex,EV_VEC_origin,fOrigin);
		
		if(get_distance_f(fOrigin,g_fNpcOrigin[iIndex]) > NPC_NPC_MAX_DISTANCE)
		{
			client_print_color(iIndex,print_team_default,"^4[%s] ^1You are too far from the ^3NPC^1.",PREFIX);
			
			return;
		}
		
		// Here you add the item effect
		menu_MissionsMain(iIndex);
	}
}

stock cmd_RandomMission(const iIndex)
{
	static iSize,iMissionID;
	
	iSize = ArraySize(g_aMissionIDs);
	
	do
	{
		iMissionID = ArrayGetCell(g_aMissionIDs,random_num(0,iSize - 1));
		
	}
	while(cmd_IsMissionDone(iIndex,iMissionID));
	
	g_iData[iIndex][pd_iMissionID] = iMissionID;
	g_iData[iIndex][pd_iCurrently] = 0;
	
	
	new tData[eMissionData],szMissionID[10];
	
	num_to_str(iMissionID,szMissionID,charsmax(szMissionID));
	
	TrieGetArray(g_tMissions,szMissionID,tData,sizeof tData);
	
	client_print_color(iIndex,print_team_default,"^4[%s] ^1Your new mission is ^3%s^1.",PREFIX,tData[md_szName]);
}

stock cmd_IsMissionDone(const iIndex, const iMissionID)
{
	static i,iSize;
	
	iSize = ArraySize(g_iData[iIndex][pd_aMissionsDone]);
	
	for(i = 0; i < iSize; i++)
	{
		if(iMissionID == ArrayGetCell(g_iData[iIndex][pd_aMissionsDone],i))
			return true;
	}
	
	
	return false;
}

stock cmd_LoadData(const iIndex)
{
	static szKey[25];
	get_user_authid(iIndex,szKey,charsmax(szKey));
		
	while(g_iData[iIndex][pd_aMissionsDone] == Invalid_Array)
		g_iData[iIndex][pd_aMissionsDone] = ArrayCreate();
	
	if(!TrieKeyExists(g_tData,szKey))
	{	
		ArrayPushString(g_aDataIDs,szKey);
		TrieSetArray(g_tData,szKey,g_iData[iIndex],sizeof g_iData[]);
		
		return;
	}
	
	//log_amx("Debug #2");
	
	TrieGetArray(g_tData,szKey,g_iData[iIndex],sizeof g_iData[]);
}

stock cmd_SaveData(const iIndex)
{
	static szKey[25];
	get_user_authid(iIndex,szKey,charsmax(szKey));
	
	TrieSetArray(g_tData,szKey,g_iData[iIndex],sizeof g_iData[]);
	
	cmd_SaveFile();
}

stock cmd_LoadFile()
{
	if(!file_exists(g_szFile))
		return;
		
	new f = fopen(g_szFile,"rt");
	
	static szBuffer[512],szKey[25],szMissionID[10],szLevel[10],szCurrently[10],szTempID[10],iTempID;
	
	while(fgets(f,szBuffer,charsmax(szBuffer)))
	{
		replace(szBuffer,charsmax(szBuffer),"^n","");
		trim(szBuffer);
		
		if(szBuffer[0] == EOS)
			continue;
			
		new tData[ePlayerData];
		
		argbreak(szBuffer,szKey,charsmax(szKey),szBuffer,charsmax(szBuffer));
		ArrayPushString(g_aDataIDs,szKey);
		
		//log_amx("Key: %s, Buffer: %s",szKey,szBuffer);
		
		argbreak(szBuffer,szMissionID,charsmax(szMissionID),szBuffer,charsmax(szBuffer));
		tData[pd_iMissionID] = str_to_num(szMissionID);
		
		argbreak(szBuffer,szLevel,charsmax(szLevel),szBuffer,charsmax(szBuffer));
		tData[pd_iLevel] = str_to_num(szLevel);
		
		argbreak(szBuffer,szCurrently,charsmax(szCurrently),szBuffer,charsmax(szBuffer));
		tData[pd_iCurrently] = str_to_num(szCurrently);
		
		while(tData[pd_aMissionsDone] == Invalid_Array)
			tData[pd_aMissionsDone] = ArrayCreate();
		
		ArrayClear(tData[pd_aMissionsDone]);
		
		while(szBuffer[0] != EOS)
		{
			argbreak(szBuffer,szTempID,charsmax(szTempID),szBuffer,charsmax(szBuffer));
			iTempID = str_to_num(szTempID);
			ArrayPushCell(tData[pd_aMissionsDone],iTempID);
		}
		
		//log_amx("Key: %s, Missions Done: %d",szKey,ArraySize(tData[pd_aMissionsDone]));
		
		TrieSetArray(g_tData,szKey,tData,sizeof tData);
		
		//ArrayDestroy(tData[pd_aMissionsDone]);
	}
	
	fclose(f);
}

stock cmd_SaveFile()
{
	new f = fopen(g_szFile,"wt");
	
	static szBuffer[512],szKey[25],tData[ePlayerData],iSize,iSize2,iLen,i,j;
	
	iSize = ArraySize(g_aDataIDs);
	
	for(i = 0; i < iSize; i++)
	{
		ArrayGetString(g_aDataIDs,i,szKey,sizeof szKey);
		TrieGetArray(g_tData,szKey,tData,sizeof tData);
	
		iLen = formatex(szBuffer,charsmax(szBuffer),"^"%s^" %d %d %d",szKey,tData[pd_iMissionID], tData[pd_iLevel], tData[pd_iCurrently]);
		
		//log_amx("iSize: %i, key: %s, ID %d",iSize,szKey,i);
		
		iSize2 = ArraySize(tData[pd_aMissionsDone]);
		
		for(j = 0; j < iSize2; j++)
			iLen += formatex(szBuffer[iLen], charsmax(szBuffer) - iLen," %d",ArrayGetCell(tData[pd_aMissionsDone],j));
			
		add(szBuffer,charsmax(szBuffer)," ^n");
		
		fputs(f,szBuffer);
	}
	
	fclose(f);
}
