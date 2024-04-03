#include "amxmodx.inc"
#include "fakemeta.inc"

new const g_szPrefix[ ] = "Alliance System";

enum _:glowStruct
{
	gGlowName[ 8 ], 
	gGlowRGB[ 3 ]
};

new const g_aColors[ ][ glowStruct ] =
{
	{ "White",	{ 255, 255, 255 } },
	{ "Blue",	{ 000, 000, 255 } },
	{ "Aqua",	{ 000, 255, 255 } },
	{ "Orange",	{ 255, 114, 000 } },
	{ "Brown",	{ 180, 103, 077 } },
	{ "Green",	{ 000, 255, 000 } },
	{ "Yellow",	{ 255, 255, 000 } },
	{ "Red",	{ 255, 000, 000 } },
	{ "Pink",	{ 255, 000, 255 } }
};

new g_iAlliances;
new g_iAlliance[ MAX_PLAYERS + 1 ];
new g_iColor[ MAX_PLAYERS + 1 ];
new bool:g_bBlock[ MAX_PLAYERS + 1 ];

new g_iInfected;

new g_hFwdAddToFullPack;

public plugin_init( )
{
	register_plugin( "HitAndRun Alliance", "-1.0", "niko" ) //afek gay +rep
	
	register_clcmd( "say /brit", "showAllianceMenu" );
	register_clcmd( "say /ally", "showAllianceMenu" );
	register_clcmd( "say /alliance", "showAllianceMenu" );
}

public client_connect( id )
{
	g_iAlliance[ id ] = 0;
	g_iColor[ id ] = random( sizeof g_aColors );
	g_bBlock[ id ] = false;
}

public client_disconnected( id )
{
	if( g_iAlliance[ id ] )
	{
		new name[ MAX_NAME_LENGTH ];
		get_user_name( id, name, charsmax( name ) );
		
		client_print_color( g_iAlliance[ id ], print_team_default, "^4[%s] ^3%s^1 has left the server. Your alliance has been cancelled.",g_szPrefix , name );
		
		g_iAlliance[ g_iAlliance[ id ] ] = 0;
		g_iAlliance[ id ] = 0;
		
		g_iAlliances --;
		
		if( !g_iAlliances )
			disableFwds( );
	}
}

public fwd_PlayerWon( )
{
	g_iInfected = 0;
}

public fwd_PrePlayerInfected( victim, attacker )
{
	if( !g_iAlliance[ victim ] || g_iAlliance[ victim ] != attacker )
		return PLUGIN_CONTINUE;
	
	if( !is_user_alive( attacker ) )
		return PLUGIN_CONTINUE;
	
	new players[ MAX_PLAYERS ], pnum;
	get_players( players, pnum, "ae", "TERRORIST" );
	
	if( pnum <= 2 )
		return PLUGIN_CONTINUE;
	
	return PLUGIN_HANDLED;
}

public fwd_PlayerInfected( id )
{
	g_iInfected = id;
}


/* ===================================================================================== */

public showAllianceMenu( const id )
{
	new str[ 128 ];
	formatex( str, charsmax( str ), "\r[ \w%s \r]\w Alliance Menu:^n\
	^n\y- \dCurrent alliance: \r%s.\
	^n\y- \dAlliances: \r%d.", g_szPrefix, getAlliance( id ), g_iAlliances );
	
	new menu = menu_create( str, "allianceMenuHandler" );
	
	menu_additem( menu, "Create Alliance" );
	menu_additem( menu, "Leave Alliance^n" );
	
	formatex( str, charsmax( str ), "Alliance Glow: \d%s", g_aColors[ g_iColor[ id ] ][ gGlowName ] );
	menu_additem( menu, str );
	
	formatex( str, charsmax( str ), "Block Requests: \d%s", g_bBlock[ id ] ? "On" : "Off" );
	menu_additem( menu, str );
	
	menu_display( id, menu );
	return PLUGIN_HANDLED;
}

public allianceMenuHandler( const id, const menu, const item )
{
	menu_destroy( menu );
	
	if( item == MENU_EXIT )
		return PLUGIN_HANDLED;
	
	switch( item )
	{
		case 0: showPlayers( id );
		case 1: attemptLeave( id ), showAllianceMenu( id );
		case 2:
		{
			g_iColor[ id ] ++;
			
			if( g_iColor[ id ] >= sizeof g_aColors )
				g_iColor[ id ] = 0;
			
			showAllianceMenu( id );
		}
		case 3:
		{
			g_bBlock[ id ] = !g_bBlock[ id ];
			showAllianceMenu( id );
		}
	}
	
	return PLUGIN_HANDLED;
}

public showPlayers( id )
{
	if( g_iAlliance[ id ] )
	{
		client_print_color( id, print_team_default, "^4[%s] ^3Error:^1 You are already in an alliance.",g_szPrefix );
		showAllianceMenu( id );
		
		return PLUGIN_HANDLED;
	}
		
	new str[ 64 ];
	formatex( str, charsmax( str ), "\r[%s]\w Alliance Menu - Select Player:", g_szPrefix );
	
	new menu = menu_create( str, "playersHandler" );
	
	new players[ MAX_PLAYERS ], pnum;
	get_players( players, pnum, "e", "TERRORIST" );
	
	for( new i = 0, data[ 3 ]; i < pnum; i++ )
	{
		if( players[ i ] == id || !is_user_connected( players[ i ] ) || g_iAlliance[ players[ i ] ] || g_bBlock[ players[ i ] ] )
			continue;
		
		get_user_name( players[ i ], str, MAX_NAME_LENGTH - 1 );
		num_to_str( players[ i ], data, charsmax( data ) );
		
		menu_additem( menu, str, data );
	}
	
	if( !menu_items( menu ) )
	{
		menu_destroy( menu );
		
		client_print_color( id, print_team_default, "^4[%s] ^1There are no connected players without an alliance.",g_szPrefix  );
		showAllianceMenu( id );
		
		return PLUGIN_HANDLED;
	}
	
	menu_display( id, menu );
	return PLUGIN_HANDLED;
}

public playersHandler( const id, const menu, const item )
{
	if( item == MENU_EXIT || g_iAlliance[ id ] )
	{
		menu_destroy( menu );
		showAllianceMenu( id );
		
		return PLUGIN_HANDLED;
	}
	
	new info[ 3 ], _dump[ 1 ];
	menu_item_getinfo( menu, item, _dump[ 0 ], info, charsmax( info ), _dump, 0, _dump[ 0 ] );
	
	menu_destroy( menu );
	
	new player = str_to_num( info );
	
	if( !is_user_connected( player ) )
		return client_print_color( id, print_team_default, "^4[%s] ^3Error:^1 Your target is no longer connected.",g_szPrefix );
	
	if( g_iAlliance[ player ] )
		return client_print_color( id, print_team_default, "^4[%s] ^3Error:^1 Your target is already in an alliance.",g_szPrefix );
	
	if( g_bBlock[ player ] )
		return client_print_color( id, print_team_default, "^4[%s] ^3Error:^1 Your target has blocked alliance requests.",g_szPrefix );
	
	askForAlliance( id, player );
	showAllianceMenu( id );
	
	return PLUGIN_HANDLED;
}

public askForAlliance( const sender, const receiver )
{
	if( g_iAlliance[ sender ] || g_iAlliance[ receiver ] )
		return PLUGIN_HANDLED;
	
	new str[ 128 ], name[ MAX_NAME_LENGTH ], data[ 3 ];
	
	get_user_name( sender, name, charsmax( name ) );
	num_to_str( sender, data, charsmax( data ) );
	
	formatex( str, charsmax( str ), "\r[%s]\w Alliance Menu^n\
	^n\y%s \whas asked you for an alliance. \rAccept?", g_szPrefix, name );
	
	new menu = menu_create( str, "menuAskHandler" );
	
	menu_additem( menu, "Accept", data );
	menu_additem( menu, "Reject", data );
	
	menu_display( receiver, menu );
	return PLUGIN_HANDLED;
}

public menuAskHandler( const receiver, const menu, const item )
{
	if( item == MENU_EXIT || g_iAlliance[ receiver ] )
	{
		menu_destroy( menu );
		return PLUGIN_HANDLED;
	}
	
	new info[ 3 ], _dump[ 1 ];
	menu_item_getinfo( menu, item, _dump[ 0 ], info, charsmax( info ), _dump, 0, _dump[ 0 ] );
	
	menu_destroy( menu );
	
	new sender = str_to_num( info );
	
	if( !is_user_connected( sender ) )
		return client_print_color( receiver, print_team_default, "^4[%s] ^3Error:^1 The player who sent you the request is no longer connected.",g_szPrefix );
	
	new receiver_name[ MAX_NAME_LENGTH ];
	get_user_name( receiver, receiver_name, charsmax( receiver_name ) );
	
	if( !item )
	{
		if( g_iAlliance[ sender ] )
			return client_print_color( receiver, print_team_default, "^4[%s] ^3Error:^1 The player who sent you the reqeust is already in an alliance.",g_szPrefix );
		
		new sender_name[ MAX_NAME_LENGTH ];
		get_user_name( sender, sender_name, charsmax( sender_name ) );
		
		client_print_color( sender, print_team_default, "^4[%s] ^3%s^1 has accepeted your alliance offer.",g_szPrefix , receiver_name );
		client_print_color( receiver, print_team_default, "^4[%s] ^1You are now in an alliance with ^3%s^1.",g_szPrefix , sender_name );
		
		g_iAlliance[ sender ] = receiver;
		g_iAlliance[ receiver ] = sender;
		
		if( !g_iAlliances )
			enableFwds( );
			
		g_iAlliances ++;
		
		showAllianceMenu( sender );
	}
	else
	{
		client_print_color( sender, print_team_default, "^4[%s] ^3%s^1 has rejected your alliance offer.",g_szPrefix, receiver_name );
	}

	return PLUGIN_HANDLED;
}

public attemptLeave( const id )
{
	if( !g_iAlliance[ id ] )
	{
		client_print_color( id, print_team_default, "^4[%s] ^1You are not in an alliance.",g_szPrefix );
	}
	else
	{
		new name[ MAX_NAME_LENGTH ];
		get_user_name( g_iAlliance[ id ], name, charsmax( name ) );
		
		client_print_color( id, print_team_default, "^4[%s] ^1You have left your alliance with ^3%s^1.",g_szPrefix , name );
		
		g_iAlliance[ g_iAlliance[ id ] ] = 0;
		g_iAlliance[ id ] = 0;
		
		g_iAlliances --;
		
		if( !g_iAlliances )
			disableFwds( );
	}
	
	showAllianceMenu( id );
	return PLUGIN_HANDLED;
}

getAlliance( const id )
{
	new str[ 48 ];
	
	if( !g_iAlliance[ id ] )
	{
		copy( str, charsmax( str ), "None" );
	}
	else
	{
		get_user_name( g_iAlliance[ id ], str, MAX_NAME_LENGTH - 1 );
		format( str, charsmax( str ), "Alliance with %s", str );
	}
	
	return str;
}

/* ===================================================================================== */

public fwdAddToFullPack( es, e, ent, host, hostflags, player, pSet ) 
{ 
	if( player )
	{
		if ( host != ent && g_iAlliance[ host ] && g_iAlliance[ host ] == ent && g_iInfected != ent && is_user_alive( ent ) ) 
		{ 
			set_es( es, ES_RenderFx, kRenderFxGlowShell );
			set_es( es, ES_RenderColor, g_aColors[ g_iColor[ host ] ][ gGlowRGB ] );
			set_es( es, ES_RenderMode, kRenderNormal );
			set_es( es, ES_RenderAmt, 85 );
		}
	}
	
	return FMRES_IGNORED;
}

disableFwds( )
{
	if( g_hFwdAddToFullPack )
	{
		unregister_forward( FM_AddToFullPack, g_hFwdAddToFullPack, true );
		g_hFwdAddToFullPack = 0;
	}
}

enableFwds( )
{
	if( !g_hFwdAddToFullPack )
		g_hFwdAddToFullPack	= register_forward( FM_AddToFullPack, "fwdAddToFullPack", true );
}


