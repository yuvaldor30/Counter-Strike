/* Plugin generated by AMXX-Studio */

#include "amxmodx.inc"
#include "hamsandwich.inc"
#include "engine.inc"
#include "fun.inc"
#include "cstrike.inc"
#include "hitandrun.inc"

#define PLUGIN "Suplise Box System"
#define VERSION "1.0"
#define AUTHOR "MJ"

#define PREFIX "Supply Box System"

#define TASK_DELAY 12404
#define TASK_UPDATE_PRECENT 21414
#define TASK_TAKE_BOX 3124
#define TASK_MOVE 312421

#define BOX_MENU "SupplyBox_Menu"


#pragma semicolon 1

new const Float:g_fMaxSize[3] = {12.0,12.0,32.0};
new const Float:g_fMinSize[3] = {-12.0,-12.0,-6.0};

new const g_szEntityClassname[] = "entity_supply";

new const g_szEntityModel[] = "models/UniqueGaming/HitAndRun/SupplyBox/w_supplybox.mdl";

enum _: ePlayerData
{
	bool:pd_bTaking,
	pd_iEntity,
	pd_iPrecent
};

enum _: eSupplyData
{
	sd_szSupplyName[30],
	sd_iChance
}

new const g_aSupplies[SUPPLIES][eSupplyData] = 
{
	{"Rotten food",35},
	{"Stocks of cash",50},
	{"Experience points",50},
	{"Ammunition of ammo",50},
	{"USP",10},
	{"Shotgun",10}
};

new g_iData[MAX_PLAYERS + 1][ePlayerData];

new bool:g_bAllowed = true,bool:g_bMode;

new g_hForwardBoxTaken;

new g_iMessageBarTime2;

new g_iTime[MAX_PLAYERS + 1];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_menucmd(register_menuid(BOX_MENU),1023,"handler_BoxTaken");
	
	g_iMessageBarTime2 = get_user_msgid("BarTime2");
	
	register_clcmd("say /test","cmd_Test");
	
	register_event("HLTV","event_OnNewRound", "a", "1=0", "2=0");
	
	RegisterHam(Ham_Touch,"info_target","fwd_TouchBox",1);
	RegisterHam(Ham_Killed,"player","fwd_Killed",1);
	
	g_hForwardBoxTaken = CreateMultiForward("fwd_BoxTaken",ET_IGNORE,FP_CELL);
}

public plugin_precache()
{
	precache_model(g_szEntityModel);
}

public event_OnNewRound()
{
	static iEntity;
	
	iEntity = find_ent_by_class(-1,g_szEntityClassname);
	
	while(is_valid_ent(iEntity))
	{
		remove_entity(iEntity);
		iEntity = find_ent_by_class(-1,g_szEntityClassname);
	}
	
	for(new i = 1; i <= MaxClients; i++)
		if(is_user_connected(i))
			arrayset(g_iData[i],0,sizeof g_iData[]);
}

public cmd_Test(const iIndex)
{
	if(get_user_access(iIndex) >= ServerManager)
	{
		g_bMode = !g_bMode;
	
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have ^3%s ^1create box mod.",PREFIX,g_bMode ? "enabled" : "disabled");
	}
	
	return PLUGIN_HANDLED;
}

public client_PreThink(iIndex)
{
	new iButton = get_user_button(iIndex);
	
	if(is_user_alive(iIndex) && iButton & IN_USE && g_bAllowed && get_user_access(iIndex) >= ServerManager && g_bMode)
	{	
		static Float:fOrigin[3],iOrigin[3];
		
		get_user_origin(iIndex,iOrigin, 3);
		
		IVecFVec(iOrigin,fOrigin);
		
		//fOrigin[2] += 80.0;
		
		cmd_CreateSupply(fOrigin);
	}
	
	if(is_user_alive(iIndex) && iButton & IN_RELOAD && g_bAllowed && get_user_access(iIndex) >= ServerManager && g_bMode)
	{	
		static iEntity,iReturn;
		
		get_user_aiming(iIndex,iEntity,iReturn);
		
		if(!is_valid_ent(iEntity))
			return;
			
		static szClassname[32];
		entity_get_string(iEntity,EV_SZ_classname,szClassname,charsmax(szClassname));
		
		if(!equal(szClassname,g_szEntityClassname))
			return;
			
		remove_entity(iEntity);
		
		g_bAllowed = false;
		
		set_task(DELAY_CREATE_TIME,"cmd_Allow",TASK_DELAY);
	}
	
	if(g_iData[iIndex][pd_bTaking])
	{
		if(is_user_alive(iIndex) && iButton & IN_USE && iButton & IN_DUCK)
		{
			static iEntity,iReturn;
		
			get_user_aiming(iIndex,iEntity,iReturn);
			
			if(!is_valid_ent(iEntity))
			{
				cmd_Stop(iIndex);
				return;
			}
			
			static szClassname[32];
			entity_get_string(iEntity,EV_SZ_classname,szClassname,charsmax(szClassname));
			
			if(!equal(szClassname,g_szEntityClassname))
			{
				cmd_Stop(iIndex);
				
				return;
			}
			
			new Float:fRange = entity_range(iIndex,iEntity);
		
			if(fRange > MIN_RANGE)
			{
				cmd_Stop(iIndex);
				
				return;
			}
		}
		
		else
		{
			cmd_Stop(iIndex);
			
			return;
		}
	
	}
	
	else if(is_user_alive(iIndex) && iButton & IN_USE && iButton & IN_DUCK)
	{
		static iEntity,iReturn;
		
		get_user_aiming(iIndex,iEntity,iReturn);
		
		if(!is_valid_ent(iEntity))
			return;
			
		static szClassname[32];
		entity_get_string(iEntity,EV_SZ_classname,szClassname,charsmax(szClassname));
		
		if(!equal(szClassname,g_szEntityClassname))
			return;
		
		new Float:fRange = entity_range(iIndex,iEntity);
		
		if(fRange > MIN_RANGE)
			return;
			
		if(iEntity != g_iData[iIndex][pd_iEntity])
			g_iData[iIndex][pd_iPrecent] = 0;
			
		g_iData[iIndex][pd_iEntity] = iEntity;
		
		g_iData[iIndex][pd_bTaking] = true;
			
		message_begin(MSG_ONE_UNRELIABLE, g_iMessageBarTime2, _, iIndex);
		write_short(TIME_TO_TAKE);
		write_short(g_iData[iIndex][pd_iPrecent]);
		message_end();
		
		set_task(0.1,"cmd_UpdatePrecent",iIndex + TASK_UPDATE_PRECENT);
		
		set_task((float(TIME_TO_TAKE) / 100.0) * float(100 - g_iData[iIndex][pd_iPrecent]),"cmd_BoxTaken",TASK_TAKE_BOX + iIndex);
		
	}
}

public cmd_CreateSupply(const Float:fOrigin[3])
{
	static iEntity;

	iEntity = create_entity("info_target");
	
	if(!is_valid_ent(iEntity))
		return;
	
	entity_set_string(iEntity,EV_SZ_classname,g_szEntityClassname);
	entity_set_origin(iEntity,fOrigin);
	entity_set_model(iEntity,g_szEntityModel);
	entity_set_int(iEntity,EV_INT_solid,SOLID_BBOX);
	entity_set_size(iEntity,g_fMinSize,g_fMaxSize);
	
	drop_to_floor(iEntity);

	static szClassname[32];
	entity_get_string(iEntity,EV_SZ_classname,szClassname,charsmax(szClassname));
	
	set_rendering(iEntity,kRenderFxGlowShell,0,0,255,kRenderNormal,16);
	g_bAllowed = false;
	
	set_task(DELAY_CREATE_TIME,"cmd_Allow",TASK_DELAY);
	
	set_task(BOX_MOVE_SPEED,"cmd_MoveEntity",TASK_MOVE + iEntity);
}

public cmd_MoveEntity(const iTaskID)
{
	static iEntity;
	
	iEntity = iTaskID - TASK_MOVE;
	
	if(!is_valid_ent(iEntity))
		return;
	
	static szClassname[32];
	entity_get_string(iEntity,EV_SZ_classname,szClassname,charsmax(szClassname));
	
	if(!equal(szClassname,g_szEntityClassname))
		return;
		
	static Float:fAngles[3];
		
	entity_get_vector(iEntity,EV_VEC_angles,fAngles);
	
	fAngles[1] += BOX_MOVE_AMOUNT;
	
	entity_set_vector(iEntity,EV_VEC_angles,fAngles);
	
	set_task(BOX_MOVE_SPEED,"cmd_MoveEntity",iTaskID);
}

public cmd_Allow(const iTaskID)
{
	g_bAllowed = true;
}

public cmd_UpdatePrecent(const iTaskID)
{
	static iIndex;
	
	iIndex = iTaskID - TASK_UPDATE_PRECENT;
	
	if(is_user_alive(iIndex) && g_iData[iIndex][pd_bTaking])
	{
		g_iData[iIndex][pd_iPrecent] +=  floatround(10.0 / float(TIME_TO_TAKE));
		
		set_task(0.1,"cmd_UpdatePrecent",iTaskID);
	}	
}

public cmd_BoxTaken (const iTaskID)
{
	static iIndex,iReturn;
	
	iIndex = iTaskID - TASK_TAKE_BOX;
	
	if(is_user_connected(iIndex))
	{
		if(g_iTime[iIndex] > 0)
		{
			client_print_color(iIndex,print_team_default,"^4[%s] ^1You cannot take that box due to you have not decided to open or not the last ^3Supply Box^1.",PREFIX);
			
			return;
		}
		
		remove_entity(g_iData[iIndex][pd_iEntity]);
		
		arrayset(g_iData[iIndex],0,sizeof g_iData[]);
		
		if(get_user_premium(iIndex))
		{
			ExecuteForward(g_hForwardBoxTaken,iReturn,iIndex);
		}
		else
		{
			g_iTime[iIndex] = TIME_TO_DECIDE + 1;
		
			menu_BoxTaken(iIndex);
		}
	}
}

public menu_BoxTaken(const iIndex)
{
	g_iTime[iIndex] --;
	
	if(g_iTime[iIndex] <= 0)
	{
		show_menu(iIndex,0,"");
		return;
	}
	
	new szText[512],iLen;
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r[ \w%s \r] \wSupply Box Menu^n\wYou have taken \ySupply Box^n",PREFIX);
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\rWould you like to open it?^n");
	//iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\dChoose Your favorite option:^n^n");
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \yTime to choose: \w%d second%s\d.^n^n",g_iTime[iIndex], g_iTime[iIndex] == 1 ? "" : "s");
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r1. \wYes, \rI want to open it!^n");
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\r2. \yNo, \dI am scared from \rSupply Box\d's contents^n");
	
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"^n\yOptiontial Supply Contents:^n");
	
	for(new i; i < sizeof g_aSupplies; i++)
		iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \w%s \d(\y%.2f%%\d)^n",g_aSupplies[i][sd_szSupplyName], float(g_aSupplies[i][sd_iChance]));
	
	/*iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \wExperience points \d(\y50.0%%\d)^n");
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \wAmmunition of ammo \d(\y50.0%%\d)^n");
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \wUSP pistol \d(\y10.0%%\d)^n");
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \wShotgun gun \d(\y10.0%%\d)^n");
	iLen += formatex(szText[iLen],charsmax(szText) - iLen,"\d- \wTerrible virus \d(\y35.0%%\d)^n");*/
	
	new iKeys = (1 << 0) | (1 << 1);
	
	show_menu(iIndex,iKeys,szText,-1,BOX_MENU);
	
	set_task(1.0,"menu_BoxTaken",iIndex);
}

public handler_BoxTaken(const iIndex,const iKey)
{
	switch((iKey + 1) % 10)
	{
		case 1:
		{
			static iReturn;
			
			ExecuteForward(g_hForwardBoxTaken,iReturn,iIndex);
		}
		
		case 2:
		{
			client_print_color(iIndex,print_team_default,"^4[%s] ^1You have chosen not to take the ^3Supply Box^1.",PREFIX);
		}
	}
	
	g_iTime[iIndex] = 0;
	
	return PLUGIN_HANDLED;
}

public fwd_TouchBox(const iEntity, const iIndex)
{
	if(!is_valid_ent(iEntity))
		return;
		
	static szClassname[32];
	entity_get_string(iEntity,EV_SZ_classname,szClassname,charsmax(szClassname));
	
	if(!equal(szClassname,g_szEntityClassname))
		return;
		
	if(get_user_premium(iIndex) < BenefitLv3)
		return;
		
	static iReturn;
		
	remove_entity(iEntity);
	
	ExecuteForward(g_hForwardBoxTaken,iReturn,iIndex);
}

public fwd_Killed(const iKilled, const iKiller)
{
	if(!iKilled || iKilled > MaxClients || iKilled == iKiller)
		return;
	
	new iOrigin[3],Float:fOrigin[3];
	
	get_user_origin(iKilled,iOrigin);
	
	IVecFVec(iOrigin,fOrigin);
	
	cmd_CreateSupply(fOrigin);
}

public fwd_BoxTaken(const iIndex)
{
	if(is_user_alive(iIndex))
		cmd_GiveReward(iIndex);
}

stock cmd_Stop (const iIndex)
{
	g_iData[iIndex][pd_bTaking] = false;
				
	message_begin(MSG_ONE_UNRELIABLE, g_iMessageBarTime2, _, iIndex);
	write_short(0);
	write_short(0);
	message_end();
	
	remove_task(TASK_TAKE_BOX + iIndex);
}

stock cmd_GiveReward(const iIndex)
{
	new szMessage[128],iLen,iAmount,iChance,iRandom;
	
	new iCounter;
	
	new iPremium = get_user_premium(iIndex);
	
	for(new i = 0; i < SUPPLIES; i++)
	{
		iChance = random_num(0,100);
		
		if(iChance > g_aSupplies[i][sd_iChance])
			continue;
		
		if(iPremium && i == SUPPLY_VIRUS)
			continue;
		
		if(iCounter > BOX_MAX_REWARDS)
			break;
		
		log_amx("Item: %s Random: %d, Chance: %d.",g_aSupplies[i][sd_szSupplyName],iChance,g_aSupplies[i][sd_iChance]);
		
		iLen += formatex(szMessage[iLen],charsmax(szMessage) - iLen,"%s%s", iCounter ? "^4, ^1" : "^1", g_aSupplies[i][sd_szSupplyName]);
		
		switch(i)
		{
			case SUPPLY_VIRUS:
			{
				user_silentkill(iIndex);
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have ate rotten food from the ^3supply box ^1and died.",PREFIX);
				
				return;
			}
			
			case SUPPLY_CASH:
			{
				iRandom = random_num(BOX_MIN_CASH_AMOUNT,BOX_MAX_CASH_AMOUNT);
				iAmount = stat_MultiplyCash(iIndex,iRandom);
				shop_AddUserData(iIndex,SHOP_DATA_CASH, iAmount);
				
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully got ^4%d ^1cash from the ^3Supply Box^1.",PREFIX,iAmount);
			}
			
			case SUPPLY_EXPERIENCE:
			{
				iRandom = random_num(BOX_MIN_EXPERIENCE_AMOUNT,BOX_MAX_EXPERIENCE_AMOUNT);
				iAmount = stat_MultiplyCash(iIndex,iRandom);
				exp_AddUserData(iIndex,EXPERIENCE_DATA_EXPERIENCE, iAmount);
				
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully got ^4%d ^1experience points from the ^3Supply Box^1.",PREFIX,iAmount);
			}
			
			case SUPPLY_AMMO:
			{	
				iAmount = random_num(BOX_MIN_SCOUT_AMMO,BOX_MAX_SCOUT_AMMO);
				
				if(user_has_weapon(iIndex,CSW_USP))
				{
					cs_set_user_bpammo(iIndex,CSW_SCOUT,cs_get_user_bpammo(iIndex,CSW_SCOUT) + iAmount);
				}
				else
				{
					give_item(iIndex,"weapon_scout");
					set_user_ammo(iIndex,"weapon_scout",iAmount);
				}
				
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully got ^4%d ^1scout bullets from the ^3Supply Box^1.",PREFIX,iAmount);
			}
			
			case SUPPLY_USP:
			{
				iAmount = BOX_AMOUNT_OF_USP_AMMO;
				
				if(user_has_weapon(iIndex,CSW_USP))
				{
					cs_set_user_bpammo(iIndex,CSW_USP,cs_get_user_bpammo(iIndex,CSW_USP) + iAmount);
				}
				else
				{
					give_item(iIndex,"weapon_usp");
					set_user_ammo(iIndex,"weapon_usp",iAmount);
				}
				
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully got ^3USP ^1with ^4%d ^1bullets from the ^3Supply Box^1.",PREFIX,iAmount);
			}
			
			case SUPPLY_SHOTGUN:
			{
				iAmount = BOX_AMOUNT_OF_SHOTGUN_AMMO;
				
				if(user_has_weapon(iIndex,CSW_M3))
				{
					cs_set_user_bpammo(iIndex,CSW_M3,cs_get_user_bpammo(iIndex,CSW_M3) + iAmount);
				}
				else
				{
					give_item(iIndex,"weapon_m3");
					set_user_ammo(iIndex,"weapon_m3",iAmount);
				}
				
				client_print_color(iIndex,print_team_default,"^4[%s] ^1You have successfully got ^3M3 ^1with ^4%d ^1bullets from the ^3Supply Box^1.",PREFIX,iAmount);
			}
		}
		
		iCounter ++;
	}
	
	if(iCounter)
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have got ^4%d ^1supplies from the ^3Supply Box^1: %s^1.",PREFIX, iCounter, szMessage);
	else
		client_print_color(iIndex,print_team_default,"^4[%s] ^1You have not got anything from the ^3Supply Box^1.",PREFIX);
}
