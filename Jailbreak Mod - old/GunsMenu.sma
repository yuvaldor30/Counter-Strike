/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <engine>

#define Guns_Amount 6
#define Pistols_Amount 5

#define TAG "eTs"
#define Chat_TAG "eTs"
#define s_IP "31.168.169.42:40800"

#define Year_Expired 2018
#define Month_Expired 1

#define MaxPlayers get_maxplayers()

native get_run_day()
native get_run_vote()
native get_lr_run()

enum _: GunsData
{
	GunName[20],
	GunWeapon[20],
	GunAmmo
}

enum _: PlayerData
{
	l_Gun,
	l_Pistol
}

new const GunsList[Guns_Amount][GunsData] =
{	
	{ "M4a1",	"weapon_m4a1",		CSW_M4A1	},
	{ "Ak47",	"weapon_ak47",		CSW_AK47	},
	{ "Famas",	"weapon_famas",		CSW_FAMAS	},
	{ "M249",	"weapon_m249",		CSW_M249	},
	{ "AWP",	"weapon_awp",		CSW_AWP		},
	{ "SG552",	"weapon_sg552",		CSW_SG552	}
}
new const PistolsList[Pistols_Amount][GunsData] =
{
	{ "Deagle",	"weapon_deagle",	CSW_DEAGLE	},
	{ "USP",	"weapon_usp",		CSW_USP		},
	{ "Glock",	"weapon_glock18",	CSW_GLOCK18	},
	{ "Elite",	"weapon_elite",		CSW_ELITE	},
	{ "Fiveseven",	"weapon_fiveseven",	CSW_FIVESEVEN	}
}

//{ "Hegrenade",	"weapon_hegrenade",	CSW_HEGRENADE	},

new bool:AutoGun[33],PlayerGuns[33][PlayerData],Last_PlayerGuns[33][PlayerData],Timer[33];

public plugin_init() {
	
	new Year[6],Month[3],year,month,serverIP[20];
	format_time(Year,charsmax(Year),"%Y",get_systime())
	format_time(Month,charsmax(Month),"%m",get_systime())
	year = str_to_num(Year);
	month = str_to_num(Month);
	get_user_ip(0,serverIP,charsmax(serverIP),0);
	if((year > Year_Expired || (year == Year_Expired && month >= Month_Expired)) || (!equali(s_IP,serverIP)))
		set_fail_state("Mod Time has been expired or Your Server IP is not allowed");
	register_plugin("CT Weapons","1.0","Minato")
	register_clcmd("say /auto","TurnOff");
	RegisterHam(Ham_Spawn,"player","PlayerRespawn",1)
	set_task(5.0,"FixWeaponUp",124512,_,_,"b");
	
}

public FixWeaponUp()
{
	for(new id = 1; id <=MaxPlayers; id++)
		if(is_user_alive(id))
			set_pdata_int( id, 116, 5, 0 )
}

public client_putinserver(id)
	AutoGun[id] = false;
	
public TurnOff(id)
{
	ColorChat(id,"^1you have ^3turned off ^4Auto Guns CT");
	AutoGun[id] = false;
}
public PlayerRespawn(id)
{
	if(!(is_user_alive(id)))
		return 1;
	fm_strip_user_weapons(id)
	give_item(id,"weapon_knife");
	if(cs_get_user_team(id) == CS_TEAM_CT)
	{
		remove_task(id);
		Timer[id] = 16;
		PlayerGuns[id][l_Gun] = 0;
		PlayerGuns[id][l_Pistol] = 0;
		if(!AutoGun[id])
			UpdateTime(id);
		else
		{
			GiveGuns(id);
			ColorChat(id,"^1if you want to ^3turn off ^1auto guns write ^4/auto");
		}
	}
	return 1;
}
public UpdateTime(id)
{
	if(Timer[id] > 0)
	{
		Timer[id] --;
		GunsMenu(id)
		set_task(1.0,"UpdateTime",id);
	}
	else
	{
		show_menu(id, 0, "^n", 1);
		Last_PlayerGuns[id][l_Gun] = PlayerGuns[id][l_Gun];
		Last_PlayerGuns[id][l_Pistol] = PlayerGuns[id][l_Pistol];
		GiveGuns(id);
	}
}
public GunsMenu(id)
{
	if(!is_user_alive(id) || cs_get_user_team(id) != CS_TEAM_CT || get_lr_run() || get_run_day()|| get_run_vote())
		return 1;
	if(Timer[id] <= 0)
		return 1;
	new Text[128];
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wGuns Menu JB^nTimeLeft: \r%d",TAG,Timer[id]);
	new Menu = menu_create(Text,"Guns_Handler");
	formatex(Text,charsmax(Text),"\wFirst Weapon: \d[\r %s \d]",GunsList[PlayerGuns[id][l_Gun]][GunName]);
	menu_additem(Menu,Text);
	formatex(Text,charsmax(Text),"\wSecond Weapon: \d[\r %s \d]",PistolsList[PlayerGuns[id][l_Pistol]][GunName]);
	menu_additem(Menu,Text);
	menu_additem(Menu,"\wTake Guns");
	menu_additem(Menu,"\wTake Last Guns");
	formatex(Text,charsmax(Text),"\wAuto Gun: \d[ %s \d]",AutoGun[id] ? "\wEnable" : "\rDisable");
	menu_additem(Menu,Text);
	
	menu_display(id,Menu);
	return 1;
}

public Guns_Handler(id,Menu,Item)
{
	if(get_lr_run() || get_run_day() || get_run_vote())
		return 1;
	if(Timer[id] <= 0)
	{
		GiveGuns(id);
		menu_destroy(Menu);
		return 1;
	}
	switch(Item)
	{
		case MENU_EXIT:
		{			
			menu_destroy(Menu)
			return 1;
		}
		case 0:
		{
			PlayerGuns[id][l_Gun] ++;
			if(PlayerGuns[id][l_Gun] >= Guns_Amount)
				PlayerGuns[id][l_Gun] = 0;
		}
		case 1:
		{
			
			PlayerGuns[id][l_Pistol] ++;
			if(PlayerGuns[id][l_Pistol] >= Pistols_Amount)
				PlayerGuns[id][l_Pistol] = 0;
		}
		case 2: 
		{
			Last_PlayerGuns[id][l_Gun] = PlayerGuns[id][l_Gun];
			Last_PlayerGuns[id][l_Pistol] = PlayerGuns[id][l_Pistol];
			GiveGuns(id);
		}
		case 3: GiveGuns(id);
		case 4: AutoGun[id] = !AutoGun[id];
	}
	menu_destroy(Menu)
	return GunsMenu(id);
}
stock GiveGuns(index)
{
	remove_task(index);
	Timer[index] = 0;
	if(!is_user_alive(index) || get_lr_run() || get_run_day() || cs_get_user_team(index) != CS_TEAM_CT || get_run_vote())
		return;
	fm_strip_user_weapons(index);
	give_item(index,"weapon_knife");
	give_item(index,GunsList[Last_PlayerGuns[index][l_Gun]][GunWeapon]);
	cs_set_user_bpammo(index,GunsList[Last_PlayerGuns[index][l_Gun]][GunAmmo],9999);
	give_item(index,PistolsList[Last_PlayerGuns[index][l_Pistol]][GunWeapon]);
	cs_set_user_bpammo(index,PistolsList[Last_PlayerGuns[index][l_Pistol]][GunAmmo],9999);
	give_item(index,"weapon_hegrenade");
	give_item(index,"weapon_flashbang");
	give_item(index,"weapon_flashbang");
}


stock fm_strip_user_weapons(client)
{
        new ent = create_entity( "player_weaponstrip" );       
        if ( !pev_valid( ent ) )
                return 0;
 
        dllfunc( DLLFunc_Spawn, ent );
        dllfunc( DLLFunc_Use, ent, client );
        engfunc( EngFunc_RemoveEntity, ent );
 
        return 1;
} 


stock ColorChat( const iPlayer, const szMsg[ ], { Float, Sql, Resul, _ } : ... )        
{
	new iMsg[ 191 ], iPlayers[ 32 ], iCount = 1;
	static iLen;
	iLen = formatex( iMsg, charsmax( iMsg ), "^4[^1 %s ^4] ^1",Chat_TAG );
	vformat( iMsg[ iLen ], charsmax( iMsg ) - iLen, szMsg, 3 );
	if ( iPlayer )
		iPlayers[ 0 ] = iPlayer;
	else    
		get_players( iPlayers, iCount, "ch" );  
	for ( new i = 0; i < iCount; i++ )
	{
		if ( ! is_user_connected( iPlayers[ i ] ) )
			continue;
		message_begin( MSG_ONE_UNRELIABLE, get_user_msgid( "SayText" ), _,iPlayers[ i ] );
		write_byte( iPlayers[ i ] );
		write_string( iMsg );
		message_end( );
	}
	return 1;
}