#include < amxmodx >
#include < amxmisc >

#define TAG "eTs"
#define Chat_TAG "eTs"
#define WinSounds 30

enum _:g_mMusicArray
{
	g_mName[ 64 ],
	g_mAuthor[ 64 ],
	g_mPath[ 64 ]
}

new g_szMusicFile[ 64 ], g_iSong[ 33 ], Float:g_fVolume[ 33 ];

new Array:g_aSongs;

native get_run_day()
native get_run_fd()

public plugin_init( )
{
	register_plugin( "Music Menu", "v1.0", "XControlX" );
	
	register_clcmd("say /music", "CmdMusicMenu");
	register_clcmd("say /stop","CmdStopMusic");
	register_event("HLTV","RoundStart","a", "1=0", "2=0");
}

new szFileLocation[] = "eTs/JailBreak/days/"
new szFileLocation2[] = "eTs/JailBreak/vote_lr/"
new szFileWinName[] = "winsound"
new szFileWinEnd[] = ".mp3"


public plugin_precache( )
{
	g_aSongs = ArrayCreate( g_mMusicArray );
	
	loadMusics( );
	
	new music[ g_mMusicArray ];
	new Text[128];
	for ( new i = 0; i <= ArraySize( g_aSongs ) - 1; i++ )
	{
		ArrayGetArray( g_aSongs, i, music );
		formatex(Text,charsmax(Text),"%s%s",szFileLocation,music[ g_mPath ]);
		precache_sound( Text );
	}
	for(new i=1; i <= WinSounds;i++)
	{	
		formatex(Text,charsmax(Text),"%s%s%d%s",szFileLocation2,szFileWinName,i,szFileWinEnd);
		precache_sound( Text );
	}
}

public RoundStart()
	client_cmd(0,"mp3 stop");

public plugin_natives()
{
	register_native("start_random_song","_start_rs");
	register_native("start_random_winningsound","_start_rwn");
}


public _start_rs(plugin,param)
{
	new music[ g_mMusicArray ];
	if(ArraySize(g_aSongs) <= 0)
		ColorChat(0,"The server hasn't loaded ^3songs^1, so the day will be started ^3without music^1.");
	else
	{
		ArrayGetArray( g_aSongs, random_num(0,ArraySize(g_aSongs)-1), music );
		client_cmd( 0, "mp3 play ^"sound/%s%s^"",szFileLocation, music[ g_mPath ] );
		client_cmd( 0,"say /music");
	}
}

public _start_rwn(plugin,param)
{
	set_task(1.0,"XXX");
}

public XXX()
	client_cmd( 0, ";mp3 play ^"sound/%s%s%d%s^"",szFileLocation2,szFileWinName,random_num(1,WinSounds),szFileWinEnd);

public plugin_end( )
	ArrayDestroy( g_aSongs );

public client_connect( client )
{
	g_iSong[ client ] = 0;
	
	g_fVolume[ client ] = 0.5;
	if(get_run_day())
	{		
		new music[ g_mMusicArray ];
		ArrayGetArray( g_aSongs, random_num(0,ArraySize(g_aSongs)-1), music );
		client_cmd( client, "mp3 play ^"sound/%s%s^"",szFileLocation, music[ g_mPath ] );
		client_cmd( client,"say /music");
	}
}

public CmdMusicMenu( client )
{
	if ( ! is_user_connected( client ) )	return 1;
	
	if ( ArraySize( g_aSongs ) <= 1 )	
		return ColorChat( client, "The server didn't load any song." );
	if( !get_run_day() && !get_run_fd())
		return ColorChat( client, "The music can be used in ^3special days." );
	
	
	new music[ g_mMusicArray ], item[ 128 ];
	
	ArrayGetArray( g_aSongs, g_iSong[ client ], music );
	
	formatex(item,charsmax(item),"\r[ \w%s \r] \wMusic Menu^n\wChoose your options:",TAG);
	
	new menu = menu_create(item, "CmdMusicHandler" );
	
	formatex( item, charsmax( item ), "\wSong \r- \d[\y%s\d]", music[ g_mName ] );
	
	
	format( item, charsmax( item ), "%s^n\d- \wAuthor \r- \d[\y%s\d]",item, music[ g_mAuthor ] );
	menu_additem( menu, item );
	
	formatex( item, charsmax( item ), "\wVolume \r- \d[\y%.1f\d]", g_fVolume[ client ] );
	
	menu_additem( menu, item );
	
	
	menu_additem( menu, "\wStart The Music" );
	
	menu_additem( menu, "\yStop The Music" );
	
	menu_display( client, menu );
	
	return 1;
}

public CmdMusicHandler( client, menu, item )
{
	if ( item != MENU_EXIT )
	{
		if( !get_run_day() && !get_run_fd())
			return ColorChat( client, "The music can be used in ^3special days." );
		switch ( item )
		{
			case 0:
			{
				( g_iSong[ client ] >= ( ArraySize( g_aSongs )  - 1 ) ) ? ( 

g_iSong[ client ] = 0 ) : ( g_iSong[ client ] += 1 );
				
				return CmdMusicMenu( client );
			}
			
			case 1:
			{
				( g_fVolume[ client ] > 1.0 ) ? ( g_fVolume[ client ] = 0.1 ) : ( 

g_fVolume[ client ] += 0.1 );
				
				return CmdMusicMenu( client );
			}
			
			
			case 2:
			{				
				new music[ g_mMusicArray ];
				
				ArrayGetArray( g_aSongs, g_iSong[ client ], music );

				client_cmd( client,"mp3 stop");
				
				client_cmd( client, "mp3 play ^"sound/%s%s^"",szFileLocation, music[ g_mPath ] );
				
				client_cmd( client, "MP3Volume %.1f", g_fVolume[ client ] );
				
				ColorChat( client, "You have started the song^4 ^"%s^"^3, by^4 ^"%s^"^3. (^1Volume:^4 %.1f^3)", music[ g_mName ], music[ g_mAuthor ], g_fVolume[ client ] );
				return CmdMusicMenu( client );
			}
			case 3:
				client_cmd(client,"mp3 stop");
		}
	}
	
	menu_destroy( menu );
	
	return 1;
}

public CmdStopMusic( client )
{
	if ( ! is_user_connected( client ) )	return 1;
	
	client_cmd( client, "mp3 stop" );
	
	ColorChat( client, "You have stopped the music." );
	
	return 1;
}

stock GetUserName( const index )
{
	static name[ 32 ];
	
	get_user_name( index, name, charsmax( name ) );
	
	return name;
}

stock loadMusics( )
{
	get_configsdir( g_szMusicFile, charsmax( g_szMusicFile ) );
	
	add( g_szMusicFile, charsmax( g_szMusicFile ), "/MusicMenu.ini" );
	
	if ( ! file_exists( g_szMusicFile ) )
	{
		
		write_file( g_szMusicFile, "; How to add a song to the menu:" );
		
		write_file( g_szMusicFile, "; ^"music name^" ^"music author^" ^"music path^"" );
		
		write_file( g_szMusicFile, "; ==================================================" );
	}
	
	new buffer[ 128 ], args[ g_mMusicArray ];
	
	new file = fopen( g_szMusicFile, "rt" );
	
	while ( ! feof( file ) )
	{
		fgets( file, buffer, charsmax( buffer ) );
		
		remove_quotes( buffer );
		
		if ( buffer[ 0 ] == ';' || equali( buffer, "//", 2 ) || strlen( buffer ) < 5 )	continue;
		
		parse( buffer, args[ g_mName ], charsmax( args[ g_mName ] ), args[ 

g_mAuthor ], charsmax( args[ g_mAuthor ] ), args[ g_mPath ], charsmax( args[ g_mPath ] ) );
		
		new song[ 128 ];
		
		formatex( song, charsmax( song ), "sound/%s%s",szFileLocation, args[ g_mPath ] );
		
		if ( ! file_exists( song ) )
		{
			log_amx( "Can't load song %s by %s (%s)", args[ g_mName ], 

args[ g_mAuthor ], song );
			
			continue;
		}
		
		ArrayPushArray( g_aSongs, args );
	}
	
	fclose( file );
	
	( ArraySize( g_aSongs ) < 1 ) ? log_amx( "Can't load any song from file." ) : log_amx( 

"Successfuly loaded %i songs from file.", ArraySize( g_aSongs ) );
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
