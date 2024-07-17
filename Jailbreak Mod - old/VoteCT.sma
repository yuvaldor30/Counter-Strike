#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>

#define FLAG ADMIN_CHAT

#define Items 4

#define fw_nums 1000,99999
#define math_nums 0,1000
#define randomnum 1,30

#define MaxWords 116
#define VOTE_TASK 101
#define CD_TASK 102
#define FAIL_TASK 103
#define GET_TASK 104

#define TAG "eTs"
#define Chat_TAG "eTs"
#define s_IP "31.168.169.42:40800"

#define Year_Expired 2018
#define Month_Expired 1

native set_user_rounds(id,Amount)
native get_run_day();
native get_lr_run();
native is_user_bannedct(index)
native get_run_vote()
native get_votemaps_run()

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
new const names[][] = 
{ 
	"Attack", 	
	"Jump", 
	"Duck", 
	"Forward", 
	"Back", 
	"Use", 
	"MoveLeft", 
	"MoveRight", 
	"Attack2", 
	"Reload", 
	"Tab",
	"-> Attack <-", 
	"-> Jump <-", 
	"-> Duck <-", 
	"-> Forward <-", 
	"-> Back <-", 
	"-> Use <-", 
	"-> MoveLeft <-", 
	"-> MoveRight <-", 
	"-> Attack2 <-", 
	"-> Reload <-", 
	"-> Tab <-"
}
new const css[][] =
{
	"",
	"",
	"",
	"",
	"",
	"%s^n%s^n%s^n%s^n%s^n",
	"%s^n%s^n%s^n%s^n%s^n%s^n",
	"%s^n%s^n%s^n%s^n%s^n%s^n%s^n",
	"%s^n%s^n%s^n%s^n%s^n%s^n%s^n%s^n",
	"%s^n%s^n%s^n%s^n%s^n%s^n%s^n%s^n%s^n",
	"%s^n%s^n%s^n%s^n%s^n%s^n%s^n%s^n%s^n%s^n"
}
enum _:Vote_Info
{
	v_Name[64],
	v_Votes,
}
new const Votes[Items][Vote_Info] =
{
	{"First Writes Contest",0},
	{"Combo Contest",0},
	{"Math Contest",0},
	{"Translate Contest",0}
	//{"Guess The Number Until Has Found",0},
	//{"Random Guard",0}
}
new bool:Voted[33],bool:Running,bool:TsayRun,Text[128],CountTsay,CountVote,Answer,TS_Answer[15],szVox[10],cVoteCT,g_Combo[12],g_Count[33],g_Buttons[12],g_synchud,MAX=10,TotalVotes,bool:ShowUP[33] = true;

public plugin_init() {
	
	new Year[6],Month[3],year,month,serverIP[20];
	format_time(Year,charsmax(Year),"%Y",get_systime())
	format_time(Month,charsmax(Month),"%m",get_systime())
	year = str_to_num(Year);
	month = str_to_num(Month);
	get_user_ip(0,serverIP,charsmax(serverIP),0);
	if((year > Year_Expired || (year == Year_Expired && month >= Month_Expired)) || (!equali(s_IP,serverIP)))
		set_fail_state("Mod Time has been expired or Your Server IP is not allowed");
	register_plugin("VoteCT","1.1","MJ")
	cVoteCT = register_cvar("jb_votect","1");
	register_clcmd("say","say_handler");
	register_forward( FM_PlayerPreThink, "fw_Player_PreThink" ); 
	g_synchud = CreateHudSyncObj(); 
	set_task(10.0,"CheckPnum2", _, _, _, "b");
}

public plugin_natives()
	register_native("get_votect_run","_get_votect_run");

public _get_votect_run(plugin,param)
	return Running;

public CheckPnum2()
{
	if( get_pcvar_num( cVoteCT ) )
	{
		CheckPnum();
	}
}
public CheckPnum()
{
	if(get_run_day() || Running || get_lr_run())
		return;
	new tnum,ctnum;
	for (new i; i< get_maxplayers(); i++)
	{
		if (!is_user_connected(i)) continue;
		if (cs_get_user_team(i) == CS_TEAM_T)
			tnum ++;
		else if (cs_get_user_team(i) == CS_TEAM_CT)
			ctnum ++;
	}
	if((tnum >= 2 && ctnum <1)||(tnum >= 9 && ctnum <2)||(tnum >= 15 && ctnum <3)||(tnum >= 21 && ctnum <4)||(tnum >= 26 && ctnum <5))
	{
		if(get_run_vote() || get_votemaps_run())
			return;
		
		ColorChat(0,"^4Vote CT ^1has started ^3automatically");
		LoadVoteCT();
	}
	if((tnum <= 6 && ctnum >1)||(tnum <= 12 && ctnum >2)||(tnum <= 18 && ctnum >3)||(tnum <= 23 && ctnum >4))
	{
		new pnum,players[32];
		get_players(players,pnum,"che","CT");
		new rnd = random_num(0,pnum-1);
		new player = players[rnd];
		ColorChat(0,"^3%s ^1has been moved to the ^3terrorist team^1 automatically to balance the teams",get_name(player));
		get_players(players,pnum,"ache","TERRORIST");
		cs_set_user_team(player,CS_TEAM_T);
		fm_DispatchSpawn(player);
		if(pnum <= 1)
			user_kill(player);
	}
	return;
}
public say_handler(id) {
	if(!(get_pcvar_num(cVoteCT))) return cvar_do();
	new szMsg[128];
	read_args(szMsg,128);
	remove_quotes(szMsg);
	if (equali(szMsg,"/ct")) {
		if(!(get_user_flags(id) & FLAG)) 
			return ColorChat(id,"^3you ^1have ^4no access ^1to this ^4command!");
		else if(Running)
			return ColorChat(id,"^3Vote CT ^1is already ^4activated");
		else if(get_run_vote() || get_votemaps_run())
			return ColorChat(id,"^3Another Vote ^1is already running.");
		ColorChat(0,"^4%s ^1has ^3started ^1the ^4Vote CT ^1mode",get_name(id));
		LoadVoteCT();
		return 1;
	}
	else if(equali(szMsg,"/stopct")) {
		if(!(get_user_flags(id) & FLAG)) 
			return ColorChat(id,"^3you ^1have ^4no access ^1to this ^4command!");
		else if(Running== false) 
			return ColorChat(id,"^3Vote CT ^1is not ^4activated");
		StopVoteCT(id)
		return 1;
	}
	if (get_run_day())
		return cvar_do();
	if((equali(szMsg,TS_Answer) || str_to_num(szMsg) ==Answer) && cs_get_user_team(id) == CS_TEAM_T && Running && TsayRun && !is_user_bannedct(id))
	{
		set_user_rounds(id,0);
		Running=false;
		TsayRun=false;
		cs_set_user_team(id,CS_TEAM_CT);
		fm_DispatchSpawn(id);
		ColorChat(0,"^4%s ^1has been ^3answer correctly ^1and has became a ^4guard",get_name(id));
		new string [20];
		new Style = iWinner();
		num_to_str(Answer,string,20);
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0,"%s has wrote first the answer %s^n of %s ^nand has became a guard",get_name(id),Style == 3 ? TS_Answer : string,Votes[Style][v_Name]);
		remove_task(FAIL_TASK);
		remove_task(CD_TASK);
		return 0;
	}
	return 0;
}
public iWinner()
{
	new Winner;
	for( new i=0; i< Items; i++ )
	{
		if(Votes[i][v_Votes]>Votes[Winner][v_Votes])
			Winner = i;
	}
	return Winner;
}

public LoadVoteCT()
{
	if(!(get_pcvar_num(cVoteCT))) return cvar_do();
	Running=true;
	CountVote=10;
	CountTsay = 5;
	formatex(TS_Answer,sizeof TS_Answer-1,"ABASHABEMZONA");
	Answer = 412940214124210491204;
	TotalVotes = 0;
	arrayset(Voted,false,sizeof Voted);
	arrayset(ShowUP,true,sizeof ShowUP);
	VoteCT()
	for (new i; i < Items; i++) Votes[i][v_Votes] =0;
	return 1;
}
public StopVoteCT (id)
{
	if(!(get_pcvar_num(cVoteCT))) return cvar_do();
	Running=false;
	TsayRun=false;
	remove_task(CD_TASK);
	remove_task(FAIL_TASK);
	return ColorChat(0,"^4%s ^1has ^3stopped ^1the ^4Vote CT ^1mode",get_name(id));
}
public Fail()
{
	if(!(get_pcvar_num(cVoteCT))) return cvar_do();
	Running=false;
	TsayRun=false;
	remove_task(CD_TASK);
	remove_task(FAIL_TASK);
	ColorChat(0,"^1no one ^1has ^3answered ^4correctly, ^1the ^4Vote CT ^1will start ^3automatically^1, ^4if ^1still need ct");
	CheckPnum2()
	return 1;
}

public VoteCB(id,menu,Item)
{
	if(Item >= 0 && Item < Items && Voted[id])
		return ITEM_DISABLED;
	if((Item == Items) && !(get_user_flags(id) & FLAG))
		return ITEM_DISABLED;
	if((Item == Items +1) && !(get_user_flags(id) & ADMIN_CVAR))
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public VoteCT()
{
	if(!(get_pcvar_num(cVoteCT))) 
		return cvar_do();
	if (!Running) 
		return 1;
	if (CountVote >= 0) 
	{
		new cb = menu_makecallback("VoteCB");
		for (new i = 1; i <= get_maxplayers(); i++) 
		{
			if(!is_user_connected(i) || !ShowUP[i]) continue;
			formatex(Text,127,"\r[ \w%s \r] \wChoose your favorite \yVote CT \wOption:^n^n\y- \dStatus: \r%s\w.^n\y- \dTime Left: \r%i\w.",TAG,Voted[i] ? "Already Voted":"Haven't Voted",CountVote)
			new vMenu = menu_create(Text,"VoteCT_Handler");
			for (new j; j< Items; j++) 
			{
				new Float:Ahuz = 100.0/TotalVotes*Votes[j][v_Votes];
				formatex(Text,127,"\w%s \r- \d[\r%d \yVotes \w- \r%.2f\w%%\d]",Votes[j][v_Name],Votes[j][v_Votes],Ahuz);
				if(j == Items-1)
					format(Text,127,"%s ^n^n\d- \yAdmin Options:",Text);
				menu_additem(vMenu,Text,.callback=cb);
			}
			menu_additem(vMenu,"\dStop \wVoteCT",.callback = cb);
			menu_additem(vMenu,"\dDisable \wVoteCT Mod^n",.callback = cb);
			menu_additem(vMenu,"\yStop Show UP");
			menu_setprop(vMenu,MPROP_EXITNAME,"Exit");
			menu_display(i,vMenu);
		}
		CountVote --;
		set_task(1.0,"VoteCT",VOTE_TASK)
	}
	if (CountVote < 0)
	{
		show_menu(0, 0, "^n", 1);
		remove_task(VOTE_TASK);
		iWinner();
		LoadCD();
	}
	return 1;
}

public VoteCT_Handler (id,vMenu,Item)
{
	if(!(get_pcvar_num(cVoteCT))) 
	{
		cvar_do();
		return;
	}
	if (!Running || CountVote<0 || Item == MENU_EXIT)
	{
		menu_destroy(vMenu)
		return;
	}
	else if(Item < Items && Item >= 0)
	{
		if(Voted[id]) 
		{
			ColorChat(id,"You ^1have already voted");
			return;
		}
		Votes[Item][v_Votes] ++;
		Voted[id] = true;
		TotalVotes ++;
		ColorChat(id,"You ^1have voted for ^3%s!",Votes[Item][v_Name]);
		menu_display(id,vMenu);
	}
	else if(Item == Items)
		client_cmd(id,"say /stopct");
	else if(Item == Items + 1)
		client_cmd(id,"amx_cvar jb_votect 0");
	else if(Item == Items + 2)
		ShowUP[id] = false;
}
public LoadCD()
{
	if(!(get_pcvar_num(cVoteCT))) return cvar_do();
	new Style = iWinner();
	if(!Running) return 1;
	if(CountTsay ==0)
	{
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 5.0,_,_,4)
		remove_task( CD_TASK );
		switch (Style) {
			case 0: {	
				Answer = random_num(fw_nums)
				show_hudmessage(0, "The first who write^n[%d]^nWill become a guard",Answer);
				ColorChat(0,"^1The first who ^4writes ^3%d^1, wins the ^3First Writes.",Answer);
			}
			case 1: {
				new iNumbers[ 14 ];
				for( new i; i < sizeof( iNumbers )-1; i++ )
					iNumbers[ i ] = i;
				SortCustom1D( iNumbers, 11, "fnSortFunc" ); 
				for( new i; i < MAX; i++ )
				{
					if( i > 0 && iNumbers[ i ] == g_Combo[ i-1 ] ) continue;
					g_Combo[ i ] = iNumbers[ i ];
				}
				new iPlayers[ 32 ] , iNum; 
				get_players( iPlayers, iNum ); 
			     
				for( new i; i < iNum; i++ ) g_Count[ iPlayers[ i ] ] = 0; 
			     
				g_Buttons[ 0 ] = IN_ATTACK; 
				g_Buttons[ 1 ] = IN_JUMP; 
				g_Buttons[ 2 ] = IN_DUCK; 
				g_Buttons[ 3 ] = IN_FORWARD; 
				g_Buttons[ 4 ] = IN_BACK; 
				g_Buttons[ 5 ] = IN_USE; 
				g_Buttons[ 6 ] = IN_MOVELEFT; 
				g_Buttons[ 7 ] = IN_MOVERIGHT; 
				g_Buttons[ 8 ] = IN_ATTACK2; 
				g_Buttons[ 9 ] = IN_RELOAD;
				g_Buttons[ 10 ] = IN_SCORE;
			}
			case 2: {
				new Num1 = random_num(math_nums);
				new Num2 = random_num(math_nums);
				new MathMode = random_num(0,1)
				switch (MathMode) {
					case 0: Answer = Num1 + Num2;
					case 1: Answer = Num1 - Num2;
				}
				show_hudmessage(0, "The first who solve the math problem^n[%d%s%d]^nWill become a guard",Num1, MathMode == 0 ? "+":"-",Num2);
				ColorChat(0,"^1The first who ^4solve the math problem ^3%d^1%s^3%d^1, wins the ^3Math Question.",Num1,MathMode==0 ? "+":"-", Num2);
			}
			case 3: {
				new qTS = random_num(0,MaxWords);
				formatex(TS_Answer,sizeof TS_Answer-1,TS_Words[qTS][0]);
				show_hudmessage(0, "The first who translate the word^n%s^nWill become a guard",TS_Words[qTS][1]);
				ColorChat(0,"^1The first who ^4translate the word ^3%s^1, wins the ^3Translate Question.",TS_Words[qTS][1]);
			}
			case 4: {
				Answer = random_num(randomnum);
				show_hudmessage(0, "The first who guess the lucky number^n[ 1~30 ]^nWill become a guard");
				ColorChat(0,"^1The first who ^4guess the lucky number^3 1~30^1, wins the ^3Guess The Number.");
			}
			case 5: RandomGuard()
		}
		TsayRun=true;
		set_task(20.0,"Fail",FAIL_TASK);
	}
	if(CountTsay > 0) {
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0, "%s will start in %d seconds",Votes[Style][v_Name],CountTsay);
		ColorChat(0,"^3%s ^1will start in ^4%d seconds",Votes[Style][v_Name],CountTsay);
		num_to_word( CountTsay, szVox, charsmax( szVox ) );
		client_cmd( 0, "spk ^"vox/%s^"", szVox );
		CountTsay--;
		set_task(1.0,"LoadCD",CD_TASK);
	}
	return 1;
}
public RandomGuard()
{
	new players[32],pnum;
	get_players(players, pnum,"ach");
	new pGuard = GetRandomPlayer(players,pnum);
	set_user_rounds(pGuard,0);
	Running=false;
	TsayRun=false;
	cs_set_user_team(pGuard,CS_TEAM_CT);
	fm_DispatchSpawn(pGuard);
	ColorChat(0,"^4%s ^1has been chosen in the ^3%s ^1and has became a ^4guard",get_name(pGuard),Votes[iWinner()][v_Name]);
	new string [20];
	num_to_str(Answer,string,20);
	set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
	show_hudmessage(0,"%s has been chosen in the ^n%s ^nand has became a guard",get_name(pGuard),Votes[iWinner()][v_Name]);
	remove_task(FAIL_TASK);
	remove_task(CD_TASK);
	return 1;
}
GetRandomPlayer(players[32],&maximum)
{
	static index;
	new i = random(maximum);
	while (!is_user_connected(players[i]) || cs_get_user_team(players[i]) == CS_TEAM_CT)
	i = random(maximum);
	index = players[i];
	return index;
}
public fnSortFunc( elem1, elem2, const array[], const data[], data_size )  
{ 
	new iNum = random_num( 0, 60 );
	if( iNum < 30 )
		return -1;
	else if( iNum == 30 )
		return 0;
	return 1;
} 
showcombo(id)
{
	set_hudmessage(21, 157, 144, _, 0.25, 0, 0.1, 0.1, 0.1, 0.1, 1 );
	new name[ 11 ][ 33 ];
	for( new i; i<MAX; i++ )
	{
		copy( name[ i ], 32, names[ g_Combo[ i ] ] );
		if( i == g_Count[ id ] )
			copy( name[ i ], 32, names[ g_Combo[ i ] +11 ] );
	}
	switch( MAX )
	{
		case 5:  ShowSyncHudMsg( id, g_synchud, css[ MAX ], name[ 0 ], name[ 1 ], name[ 2 ], name[ 3 ], name[ 4 ] );
		case 6:  ShowSyncHudMsg( id, g_synchud, css[ MAX ], name[ 0 ], name[ 1 ], name[ 2 ], name[ 3 ], name[ 4 ], name[ 5 ] );
		case 7:  ShowSyncHudMsg( id, g_synchud, css[ MAX ], name[ 0 ], name[ 1 ], name[ 2 ], name[ 3 ], name[ 4 ], name[ 5 ], name[ 6 ] );
		case 8:  ShowSyncHudMsg( id, g_synchud, css[ MAX ], name[ 0 ], name[ 1 ], name[ 2 ], name[ 3 ], name[ 4 ], name[ 5 ], name[ 6 ], name[ 7 ] );
		case 9:  ShowSyncHudMsg( id, g_synchud, css[ MAX ], name[ 0 ], name[ 1 ], name[ 2 ], name[ 3 ], name[ 4 ], name[ 5 ], name[ 6 ], name[ 7 ], name[ 8 ] ); 
		case 10: ShowSyncHudMsg( id, g_synchud, css[ MAX ], name[ 0 ], name[ 1 ], name[ 2 ], name[ 3 ], name[ 4 ], name[ 5 ], name[ 6 ], name[ 7 ], name[ 8 ], name[ 9 ] );
	}
}
public fw_Player_PreThink( id ) 
{ 
	if( !TsayRun || iWinner() != 1 || cs_get_user_team(id) != CS_TEAM_T || is_user_bannedct(id)) return FMRES_IGNORED; 
	static iButton;
	iButton = pev( id, pev_button ); 

	if( g_Count[ id ] >= MAX )
	{ 
		g_Count[ id ] = 0 ;
		set_user_rounds(id,0);
		Running=false;
		TsayRun=false;
		cs_set_user_team(id,CS_TEAM_CT);
		fm_DispatchSpawn(id);
		ColorChat(0,"^4%s ^1has completed the ^3combo actions correctly ^1and has became a ^4guard",get_name(id));
		new string [20];
		num_to_str(Answer,string,20);
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0,"%s has completed first the ^ncombo actions^nand has became a guard",get_name(id));
		remove_task(FAIL_TASK);
		remove_task(CD_TASK);
	} 
	if( g_Count[ id ] != 0 && iButton & g_Buttons[ g_Combo[ g_Count[ id ]-1 ] ] )
		return FMRES_IGNORED;

	if( iButton & g_Buttons[ g_Combo[ g_Count[ id ] ] ] )
		g_Count[ id ] ++;
	else if( iButton )
		g_Count[ id ] = 0;
	showcombo( id );
	return FMRES_IGNORED; 
}

stock cvar_do()
{
	Running=false
	TsayRun=false;
	remove_task(CD_TASK);
	remove_task(FAIL_TASK);
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
