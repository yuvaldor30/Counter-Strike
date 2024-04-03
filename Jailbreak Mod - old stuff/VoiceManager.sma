#include <amxmodx>
#include <fakemeta>
#include <cstrike>

#define ADMIN_FLAG ADMIN_RCON
#define VOICE_FLAG ADMIN_BAN

#define TAG "eTs"
#define Chat_TAG "eTs"
#define s_IP "31.168.169.42:40800"

#define Year_Expired 2018
#define Month_Expired 1

new bool:AllowedVoice[33];

native get_user_gangid(index)
native get_run_day()
native get_user_gang_voice(index)

public plugin_init()
{
	
	new Year[6],Month[3],year,month,serverIP[20];
	format_time(Year,charsmax(Year),"%Y",get_systime())
	format_time(Month,charsmax(Month),"%m",get_systime())
	year = str_to_num(Year);
	month = str_to_num(Month);
	get_user_ip(0,serverIP,charsmax(serverIP),0);
	if((year > Year_Expired || (year == Year_Expired && month >= Month_Expired)) || (!equali(s_IP,serverIP)))
		set_fail_state("Mod Time has been expired or Your Server IP is not allowed");
	register_plugin("Voice Manager","1.0","MJ");
	register_clcmd("say /voice","Voice_Menu");
	register_forward(FM_Voice_SetClientListening,"FwdVoiceSetClientListening");
}
public Voice_Menu(id)
{
	if(!(get_user_flags(id) & ADMIN_FLAG))
		return ColorChat(id,"You have ^4no access ^1to this command.");
	new Text[128];
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wVoice Manager Menu",TAG);
	new Menu = menu_create(Text,"Voice_Handler");
	
	new pnum,players[32],string[2];
	get_players(players,pnum,"c");
	new counter;
	for(new i; i < pnum; i++)
	{
		if(get_user_flags(players[i]) & VOICE_FLAG)
			continue;
		string[0] = players[i];
		formatex(Text,charsmax(Text),"\w%s \d%s",get_name(players[i]),AllowedVoice[players[i]] ? "[Voice]" : "");
		menu_additem(Menu,Text,string);
		counter++;
	}
	if(counter == 0)
		return ColorChat(id,"there are no players to set them voice access");
	menu_display(id,Menu);
	return 1;
}

public Voice_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return 1;
	}
	
	new Empty,Data[2];
	menu_item_getinfo(menu,Item,Empty,Data,charsmax(Data),_,_,Empty);
	new iPlayer = Data[0];
	if(cs_get_user_team(iPlayer) != CS_TEAM_T)
		return 1;
	AllowedVoice[iPlayer] = !AllowedVoice[iPlayer];
	ColorChat(0,"^3%s ^1has %s ^3%s ^4Voice Access",get_name(id),AllowedVoice[iPlayer] ? "given to" : "taken from",get_name(iPlayer)) 
	
	menu_destroy(menu);
	return Voice_Menu(id);
}
	
public FwdVoiceSetClientListening( Rec, Talker, bool:bListen ) 
{
	if(!is_user_connected(Rec) || !is_user_connected(Talker))
		return 1;
	new pnum,players[32];
	get_players(players,pnum,"ace","TERRORIST");
	switch(get_run_day())
	{
		case 0:
		{
			if(is_user_alive(Talker) && cs_get_user_team(Talker) == CS_TEAM_CT)
				return 1;
			else if(AllowedVoice[Talker])
				return 1;
			else if(get_user_flags(Talker) & VOICE_FLAG)
				return 1;
			else if(pnum == 1 && players[0] == Talker)
				return 1;
		}
		case 1:
		{
			if(get_user_gangid(Talker) == get_user_gangid(Rec) && cs_get_user_team(Talker) == CS_TEAM_T && cs_get_user_team(Rec) == CS_TEAM_T && get_user_gangid(Talker) != -1 && get_user_gang_voice(Talker))
				return 1;
			else if(cs_get_user_team(Talker) == cs_get_user_team(Rec) && cs_get_user_team(Talker) == CS_TEAM_CT && is_user_alive(Talker) && is_user_alive(Rec))
				return 1;
		}
	}
	engfunc(EngFunc_SetClientListening,Rec,Talker,0);
	return FMRES_SUPERCEDE;
}

public client_putinserver(id)
	AllowedVoice[id] = false;


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

stock get_name(index)
{
	new szName[33];
	get_user_name(index,szName,charsmax(szName));
	return szName;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ fbidis\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ ltrpar\\ lang1037\\ f0\\ fs16 \n\\ par }
*/
