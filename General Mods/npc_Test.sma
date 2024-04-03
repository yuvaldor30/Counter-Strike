/* Plugin generated by AMXX-Studio */

#include "amxmodx.inc"
#include "npc_api.inc"

#define PLUGIN "NPC Test"
#define VERSION "1.0"
#define AUTHOR "MJ"

#define PREFIX "NPC Test"

new g_iItemID;

new Float:g_fNpcOrigin[MAX_PLAYERS + 1][3];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);
}

public fwd_NpcLoadItems()
{
	g_iItemID = cmd_NpcAddItem("I would like to talk about my \rbank status\d.");
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
		client_print_color(iIndex,print_team_default,"HII");
	}
}