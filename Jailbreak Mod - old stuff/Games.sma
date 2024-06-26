/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <fun>

#define CD_TASK 101
#define FAIL_TASK 102
#define EVENT_TASK 103
#define RING_TASK 104

#define TAG "eTs"
#define Chat_TAG "eTs"
#define s_IP "31.168.169.42:40800"

#define Year_Expired 2018
#define Month_Expired 1

#define fw_nums 1000,999999999
#define math_nums 0,1000
#define randomnum 1,30
#define MaxWords 116
#define PASS "GamesMenuPassword"

native set_client_cash(index,amount)
native get_client_cash(index)
native get_run_day()
native get_run_vote()
native get_lr_run()

new const Games [] [] = {"First Write","Guess The Number","Math","Translate"};

new const TS_Words [MaxWords][][] =
{
	{"mother","אמא"},
	{"father","אבא"},
	{"food","לכוא"},
	{"tower","לדגמ"},
	{"rabbit","בנרא"},
	{"grass","אשד"},
	{"window","ןולח"},
	{"book","רפס"},
	{"computer","בשחמ"},
	{"teacher","הרומ"},
	{"shop","תונח"},
	{"play","קחשל"},
	{"game","קחשמ"},
	{"use","שמתשהל"},
	{"keyboard","תדלקמ"},
	{"mouse","רבכע"},
	{"horse","סוס"},
	{"screen","ךסמ"},
	{"chair","אסכ"},
	{"table","הלבט"},
	{"change","תונשל"},
	{"steal","בונגל"},
	{"hit","תוכהל"},
	{"damage","קזנ"},
	{"hand","די"},
	{"nose","ףא"},
	{"bottle","קובקב"},
	{"drink","הקשמ"},
	{"juice","ץימ"},
	{"talk","חחושל"},
	{"sound","דנואס"},
	{"orange","זופת"},
	{"apple","חופת"},
	{"name","םש"},
	{"nick","יוניכ"},
	{"cook","תופאל"},
	{"salad","טלס"},
	{"color","עבצ"},
	{"pistol","חדקא"},
	{"gun","הבור"},
	{"weapon","קשנ"},
	{"kiss","הקישנ"},
	{"die","תומל"},
	{"passive","ליבס"},
	{"active","ליעפ"},
	{"owner","םילעב"},
	{"manager","להנמ"},
	{"page","דומע"},
	{"clock","ןועש"},
	{"lamp","הרונ"},
	{"shirt","הצלוח"},
	{"short","רצק"},
	{"long","ךורא"},
	{"eat","לוכאל"},
	{"angry","ינבצע"},
	{"hungry","בער"},
	{"sad","בוצע"},
	{"bad","ער"},
	{"good","בוט"},
	{"okay","רדסב"},
	{"now","וישכע"},
	{"new","שדח"},
	{"old","ןשי"},
	{"press","ץוחלל"},
	{"key","שקמ"},
	{"right","ןימי"},
	{"left","לאמש"},
	{"up","הלעמל"},
	{"down","הטמל"},
	{"behind","ירוחאמ"},
	{"with","םע"},
	{"share","ףתשל"},
	{"wash","ףותשל"},
	{"clean","תוקנל"},
	{"picture","הנומת"},
	{"jewish","ידוהי"},
	{"category","הירוגטק"},
	{"job","עוצקמ"},
	{"score","דוקינ"},
	{"point","הדוקנ"},
	{"cable","לבכ"},
	{"closet","ןורא"},
	{"push","ףוחדל"},
	{"open","חותפל"},
	{"close","רוגסל"},
	{"work","דובעל"},
	{"week","עובש"},
	{"day","םוי"},
	{"year","הנש"},
	{"hour","העש"},
	{"minute","הקד"},
	{"seconds","הינש"},
	{"time","ןמז"},
	{"place","םוקמ"},
	{"date","ךיראת"},
	{"add","ףיסוהל"},
	{"build","תונבל"},
	{"type","גוס"},
	{"file","ץבוק"},
	{"edit","ךורעל"},
	{"eti","ףחש לש אמא"},
	{"gargamel","למגרג"},
	{"smurfs","םיסדרד"},
	{"box","אספוק"},
	{"phone","ןופלט"},
	{"pencil","טע"},
	{"batia","היתב"},
	{"morfix","סקיפרומ"},
	{"door","תלד"},
	{"knife","ןיכס"},
	{"strodel","לדורטש"},
	{"done","רומגל"},
	{"prices","םיריחמ"},
	{"ammo","תשומחת"},
	{"verison","אסרג"},
	{"sensations","תושוחת"}
}

new bool:CheckPrize[33],bool:CheckPass[33],PrizeAmount[33],PrizeEvent,bool:Running,bool:GameRun,Game[33],TheGame,Answer,TS_Answer[20],bool:EventRun,bool:pGameRun,CountTsay,bool:aAdmin,cGames;

//Winner beam
new SpriteIndex,Float:Until;

public plugin_init() {
	
	new Year[6],Month[3],year,month,serverIP[20];
	format_time(Year,charsmax(Year),"%Y",get_systime())
	format_time(Month,charsmax(Month),"%m",get_systime())
	year = str_to_num(Year);
	month = str_to_num(Month);
	get_user_ip(0,serverIP,charsmax(serverIP),0);
	if((year > Year_Expired || (year == Year_Expired && month >= Month_Expired)) || (!equali(s_IP,serverIP)))
		set_fail_state("Mod Time has been expired or Your Server IP is not allowed");
	register_plugin("Games JB","1.0","MJ")
	register_clcmd("say","SayHandler");
	register_clcmd("prize_amount","PrizeHandler");
	register_clcmd("prize_pass","PassHandler");
	cGames = register_cvar("jb_games","1");
}

public plugin_precache()
{
	 SpriteIndex = precache_model( "sprites/zbeam2.spr" );
}
public Fail()
{
	if(!(get_pcvar_num(cGames))) return 0;
	Running=false;
	GameRun=false;
	EventRun=false;
	pGameRun=false;
	remove_task(CD_TASK);
	remove_task(FAIL_TASK);
	return ColorChat(0,"^1no one ^1has ^3answered ^4correctly^1,the Game Stopped");
}
public SayHandler (id)
{
	new Arg[128];
	read_args(Arg,charsmax(Arg));
	remove_quotes(Arg);
	if(equali(Arg,"/games"))
	{
		if((!(get_pcvar_num(cGames))) || get_run_day() || get_lr_run() || get_run_vote()) return 0;
		formatex(TS_Answer,sizeof TS_Answer-1,"ABASHABEMZONA");
		Game[id]=0;
		mGames(id);
		return 1;
	}
	if(equali(Arg,"/pgames"))
	{
		if(!(get_user_flags(id) & ADMIN_IMMUNITY) || (!(get_pcvar_num(cGames)))) return 1;
		formatex(TS_Answer,sizeof TS_Answer-1,"ABASHABEMZONA");
		LoadpGames(id)
		return 1;
	}
	//client_print(0,print_chat,"Answer: %d, Running: %s GameRun: %s",Answer,Running ? "true" : "false", GameRun ? "true" : "false");
	if((equali(Arg,TS_Answer) || (str_to_num(Arg) == Answer && is_str_num(Arg))) && cs_get_user_team(id) == CS_TEAM_T && is_user_alive(id) && Running && GameRun)
	{
		if((!(get_pcvar_num(cGames))) || get_run_day() || get_lr_run() || get_run_vote())
		{
			Running=false;
			GameRun=false;
			remove_task(CD_TASK);
			remove_task(FAIL_TASK);
		}
		Running=false;
		GameRun=false;
		ColorChat(0,"^4%s ^1has been ^3answer correctly ^1and has won the ^4%s Game.",get_name(id),Games[TheGame]);
		new string [20];
		num_to_str(Answer,string,20);
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0,"%s has wrote first the answer %s^nand has has won the %s Game",get_name(id),TheGame == 3 ? TS_Answer : string,Games[TheGame]);
		Until = get_gametime() + 4.0;
		WinnerBeam(id)
		remove_task(FAIL_TASK);
		remove_task(CD_TASK);
		return 0;
	}
	if((equali(Arg,TS_Answer) || str_to_num(Arg) ==Answer) && EventRun && pGameRun)
	{
		if(!(aAdmin) && get_user_flags(id) & ADMIN_BAN)
			return 0;
		EventRun=false;
		pGameRun=false;
		ColorChat(0,"^4%s ^1has been ^3answer correctly ^1and has won the ^4%s Event.",get_name(id),Games[TheGame]);
		ColorChat(0,"^4%s ^1has ^3won ^4%d ^1Cash!!",get_name(id),PrizeEvent);
		new string [20];
		num_to_str(Answer,string,20);
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0,"%s has wrote first the answer %s^nand has has won the %s Event^n[%d Cash]",get_name(id),TheGame == 3 ? TS_Answer : string,Games[TheGame],PrizeEvent);
		set_client_cash(id,get_client_cash(id) +PrizeEvent);
		remove_task(FAIL_TASK);
		remove_task(CD_TASK);
		return 0;
	}
	return 0;
}
public mGames(id)
{
	if(!(get_pcvar_num(cGames))) return 0;
	if(((cs_get_user_team(id) == CS_TEAM_CT) && (is_user_alive(id))) || (get_user_flags(id) & ADMIN_LEVEL_E))
	{
		if(EventRun) return ColorChat(id,"You cannot start games while Event Running");
		new Text[128];
		formatex(Text,127,"\r[ \w%s \r] \wGames Menu",TAG);
		new gMenu = menu_create(Text,"Games_Handler");
		formatex(Text,127,"\wGame Mode: \d[\y%s\d]",Games[Game[id]]);
		menu_additem(gMenu,Text);
		formatex(Text,127,"\wStatus Mode: \d[\r%s\d]",Running || GameRun ? "Running" : "Disable");
		menu_additem(gMenu,Text);
		
		menu_display(id,gMenu);
		return 1;
	}
	return ColorChat(id,"You have ^4no access ^1to this command!");
}
public Games_Handler (id,gMenu,Item)
{
	if(!(get_pcvar_num(cGames))) return 0;
	if(((cs_get_user_team(id) == CS_TEAM_CT) && (is_user_alive(id))) || (get_user_flags(id) & ADMIN_LEVEL_E))
	{
		if(EventRun) return ColorChat(id,"You cannot start games while Event Running");
		if(Item == MENU_EXIT)
		{
			menu_destroy(gMenu)
			return 1;
		}
		switch (Item)
		{
			case 0:
			{
				if (Running || GameRun) return 1;
				Game[id] ++;
				if (Game[id] > 3) Game[id] = 0;
			}
			case 1:
			{
				if(Running || GameRun)
				{
					Running = false;
					GameRun = false;
					ColorChat(0,"%s ^1has ^3stopped ^1the ^3%s ^1Game",get_name(id),Games[TheGame]);
					remove_task(CD_TASK);
					remove_task(FAIL_TASK);
				}
				else 
				{
					Running=true
					CountTsay = 6;
					TheGame = Game[id];
					ColorChat(0,"%s ^1has ^3started ^1the ^3%s ^1Game",get_name(id),Games[TheGame]);
					CountDown();
				}
			}
		}
		mGames(id)
		return 1;
	}
	return ColorChat(id,"You Have no access");
}
public LoadpGames(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) return 1;
	Answer = 41241;
	CheckPass[id] = true;
	pGames(id);
	//client_cmd(id,"messagemode prize_pass");

	return 1;
}
public PassHandler(id)
{
	if(!CheckPass[id])
		return ColorChat(id,"You ^1cannot ^3use ^1this command!");
		
	CheckPass[id] = false;
	
	new Msg[128];
	read_args(Msg,charsmax(Msg))
	remove_quotes(Msg)
	if(!equal(Msg,PASS))
		return ColorChat(id,"You ^1has written ^3wrong ^4PASS");
		
	ColorChat(id,"You ^1have opened ^3successfully ^1the ^3Prize Games ^1Menu");
	
	formatex(TS_Answer,sizeof TS_Answer-1,"ABASHABEMZONA");
	Answer = 412940214124210491204;
	Game[id]=0;
	PrizeAmount[id] = 0;
	PrizeEvent = 0;
	pGames(id)
	return 1;
}
public pGames(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY))
		return ColorChat(id,"You have ^4no access ^1to this command!");
	new Text[128];
	formatex(Text,127,"\r[ \w%s \r] \wPrize Games Menu",TAG);
	new pgMenu = menu_create(Text,"pGames_Handler");
	formatex(Text,127,"\wGame Mode: \d[\y%s\d]",Games[Game[id]]);
	menu_additem(pgMenu,Text);
	formatex(Text,127,"\wPrize Amount: \d[\r%d\d]",PrizeEvent);
	menu_additem(pgMenu,Text);
	formatex(Text,127,"\wAllow Admins Answer: \d[\r%s\d]",aAdmin ? "Allow" : "Don't Allow");
	menu_additem(pgMenu,Text);
	formatex(Text,127,"\wStatus Mode: \d[\r%s\d]",EventRun ? "Running" : "Disable");
	menu_additem(pgMenu,Text);
	
	menu_display(id,pgMenu);
	return 1;
}
public pGames_Handler(id,pgMenu,Item)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY))
		return ColorChat(id,"You have ^4no access ^1to this command!");
	if(Item == MENU_EXIT)
	{
		menu_destroy(pgMenu)
		return 1;
	}
	switch (Item)
	{
		case 0:
		{
			if (EventRun || pGameRun) return 1;
			Game[id] ++;
			if (Game[id] > 3) Game[id] = 0;
		}
		case 1: 
		{
			CheckPrize[id] = true;
			client_cmd(id,"messagemode prize_amount");
		}
		case 2:
		{
			if (!(EventRun) && !(pGameRun))
			{
				if(aAdmin) aAdmin =false;
				else aAdmin =true;
			}
		}
		case 3:
		{
			if(EventRun)
			{
				remove_task(CD_TASK);
				remove_task(FAIL_TASK);
				EventRun = false;
				pGameRun = false;
				ColorChat(0,"^1Admin: ^4%s ^1has ^3stopped ^1the ^4Secret Event",get_name(id));
			}
			else 
			{
				Running=false
				GameRun=false
				EventRun = true
				CountTsay = 6;
				TheGame = Game[id];
				ColorChat(0,"^1Admin: ^4%s ^1has ^3started ^4Secret Event ^1on ^3%d ^1Cash",get_name(id),PrizeEvent);
				set_task(1.0,"Event",EVENT_TASK);
			}
		}
	}
	pGames(id)
	return 1;
}
public Event()
{
	if(!EventRun)return 1;
	new szVox[10];
	if(CountTsay > 0)
	{
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0,"The Event Will Start In %d Seconds!!!^n^nAllow Admins Answer: %s^nPrize: [%d Cash]",CountTsay-1,aAdmin ? "Yes":"No",PrizeEvent)
		if (CountTsay != 1)
		{
			num_to_word( CountTsay-1, szVox, charsmax( szVox ) );
			client_cmd( 0, "spk ^"vox/%s^"", szVox );
		}
		CountTsay --;
		set_task(1.0,"Event",EVENT_TASK);
	}
	if(CountTsay == 0)
	{
		remove_task(EVENT_TASK);
		CountDown()
	}
	return 1;
}
public PrizeHandler(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY))
		return 1;
	if(!CheckPrize[id])
		return ColorChat(id,"You ^1cannot ^3use ^1this command!");
	new Msg[128];
	read_args(Msg,charsmax(Msg))
	remove_quotes(Msg);
	PrizeAmount[id] = str_to_num(Msg);
	if (PrizeAmount[id] > 99999)
		PrizeAmount[id] = 99999;
	else if(PrizeAmount[id] < 300)
		PrizeAmount[id] = 300;
	PrizeEvent=PrizeAmount[id]
	CheckPrize[id] = false;
	pGames(id)
	return 1;
}
public CountDown()
{
	if(Running)
		if((!(get_pcvar_num(cGames))) || get_run_day() || get_lr_run() || get_run_vote()) return 0;
	if(!(Running) && (!(EventRun))) return 1;
	if(CountTsay > 0) {
		new szVox[10];
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0, "%s will start in %d seconds",Games[TheGame],CountTsay-1);
		if(CountTsay !=1)
		{
			ColorChat(0,"^3%s ^1will start in ^4%d seconds",Games[TheGame],CountTsay-1);
			num_to_word( CountTsay-1, szVox, charsmax( szVox ) );
			client_cmd( 0, "spk ^"vox/%s^"", szVox );
		}
		CountTsay--;
		set_task(1.0,"CountDown",CD_TASK);
	}
	if(CountTsay ==0)
	{
		GameRun=true;
		pGameRun=true;
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 15.0,_,_,4)
		remove_task( CD_TASK );
		switch (TheGame) {
			case 0: {
				Answer = random_num(fw_nums)
				show_hudmessage(0, "The first who write^n[%d]^nWill win the First Writes %s",Answer,EventRun ? "Event" : "Game");
				ColorChat(0,"^1The first who ^4writes ^3%d^1, wins the ^3First Writes ^4%s",Answer,EventRun ? "Event" : "Game");
			}
			case 1: {
				Answer = random_num(randomnum);
				show_hudmessage(0, "The first who guess the lucky number^n[ 1~30 ]^nWill win the Guess The Number %s",EventRun ? "Event" : "Game");
				ColorChat(0,"^1The first who ^4guess the lucky number^3 1~30^1, wins the ^3Guess The Number ^4%s",EventRun ? "Event" : "Game");
			}
			case 2: {
				new Num1 = random_num(math_nums);
				new Num2 = random_num(math_nums);
				new MathMode = random_num(0,1)
				switch (MathMode) {
					case 0: Answer = Num1 + Num2;
					case 1: Answer = Num1 - Num2;
				}
				show_hudmessage(0, "The first who solve the math problem^n[%d%s%d]^nWill win the Math %s",Num1, MathMode == 0 ? "+":"-",Num2,EventRun ? "Event" : "Game");
				ColorChat(0,"^1The first who ^4solve the math problem ^3%d^1%s^3%d^1, wins the ^3Math ^4%s",Num1,MathMode==0 ? "+":"-", Num2,EventRun ? "Event" : "Game");
			}
			case 3: {
				new qTS = random_num(0,MaxWords);
				formatex(TS_Answer,sizeof TS_Answer-1,TS_Words[qTS][0]);
				show_hudmessage(0, "The first who translate the word^n%s^nWill win the Translate %s",TS_Words[qTS][1],EventRun ? "Event" : "Game");
				ColorChat(0,"^1The first who ^4translate the word ^3%s^1, wins the ^3Translate ^4%s",TS_Words[qTS][1],EventRun ? "Event" : "Game");
			}
		}
		set_task(20.0,"Fail",FAIL_TASK);
	}
	return 1;
}
 public WinnerBeam( id )
{
	if( get_gametime( ) > Until )
		return 0;
	new Origin[ 3 ];
	get_user_origin( id, Origin );
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte( TE_BEAMCYLINDER );
	write_coord( Origin[ 0 ] );// start position
	write_coord( Origin[ 1 ] );
	write_coord( Origin[ 2 ] );
	write_coord( Origin[ 0 ] );// end position
	write_coord( Origin[ 1 ] );
	write_coord( Origin[ 2 ] + 80 );
	write_short( SpriteIndex );// sprite index
	write_byte( 0 );// starting frame
	write_byte( 50 ); // frame rate in 0.1's
	write_byte( 20 )// life in 0.1's
	write_byte( 15 )// line width in 0.1's
	write_byte( 60 )// noise amplitude in 0.01's
	write_byte( random_num(0,255) );// Red
	write_byte( random_num(0,255) );// Green
	write_byte( random_num(0,255) );// Blue
	write_byte( 255 );// brightness
	write_byte( 0 );// scroll speed in 0.1's
	message_end( );
	set_task( 0.2, "WinnerBeam", id );
	return 0;
}

stock get_name(id) 
{
	new szName[33];
	get_user_name(id,szName,31);
	return szName;
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
