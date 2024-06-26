/* Plugin generated by AMXX-Studio */

#include "amxmodx.inc"
#include "missions_api.inc"

#define PLUGIN "Mission #4 - Test"
#define VERSION "1.0"
#define AUTHOR "MJ"

// natives - precache - init - cfg

new g_iMissionID;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_clcmd("say /himan2","secretword");
}

public secretword(iIndex)
{
	if(g_iMissionID == mission_GetUserMissionID(iIndex))
		mission_UpdateUserData(iIndex);
}

public fwd_LoadMissions()
{
	cmd_CreateMission("Secret Word #2","Find the secret word #2","Kills",mTYPE_EASY, 2);
	cmd_AddMissionLevel(1,150,2500);
	g_iMissionID = cmd_AddMission();
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1252\\ deff0{\\ fonttbl{\\ f0\\ fnil\\ fcharset0 Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1037\\ f0\\ fs16 \n\\ par }
*/
