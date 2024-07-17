#include <amxmodx>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <engine>

#define set_user_ammo(%1,%2,%3) ( set_pdata_int( find_ent_by_owner( -1, %2, %1 ), 51, %3, 4 ) )
#define CD_TASK 102
#define MaxWords 116
#define fw_nums 1000,999999
#define math_nums 0,1000
#define	FL_WATERJUMP	(1<<11)	// player jumping out of water
#define	FL_ONGROUND	(1<<9)	// At rest / on the ground

#define TAG "eTs"
#define Chat_TAG "eTs"
#define s_IP "31.168.169.42:40800"

#define Year_Expired 2018
#define Month_Expired 1

#define WinnerBeam_Task 1024
#define TeamBeam_Task 1025


native get_run_day()
native get_trun_day()
native create_user_box(index)
native get_user_xp(index)
native set_user_xp(index,xp)
native start_random_winningsound()
native make_user_dance(index)
native get_user_showinfo(index)

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

enum _: GamesNames
{
	// Shot4Shot Games // FIX
	S4S_DGL, // DONE
	S4S_USP, // DONE
	S4S_GLOCK, // DONE
	S4S_57, // DONE
	S4S_ELITE, // DONE
	S4S_UZI, // DONE
	S4S_AWP_NOZOOM, // DONE
	//Write Games // FIX
	WRITE_FW, // DONE
	WRITE_MATH, // DONE
	WRITE_TS, // DONE
	WRITE_FL, // DONE
	//Special Games //
	SPEC_DODGEBALL, // DONE
	SPEC_LASER,
	SPEC_DGLPOWER, // DONE
	SPEC_COMBO, // DONE
	SPEC_SURVIVAL, // DONE
	SPEC_STRIP, // DONE
	SPEC_GHOST, // DONE
	// CUSTOM WAR FIX
	CUSTOM_WAR // DONE
}

new const LastRequestsList [GamesNames][] =
{
	"Shot 4 Shot - Deagle Duel",
	"Shot 4 Shot - USP Duel",
	"Shot 4 Shot - Glock Duel",
	"Shot 4 Shot - FiveSeven Duel",
	"Shot 4 Shot - Elite Duel",
	"Shot 4 Shot - UZI Duel",
	"Shot 4 Shot - Awp Duel",
	"First Writes Duel",
	"Math Duel",
	"Translate Duel",
	"First Listen Duel",
	"Dodgeball Duel",
	"Laser Duel [Soon]",
	"Deagle Power Duel",
	"Combo Actions Duel",
	"Survival Duel",
	"Strip Duel",
	"Ghost Duel",
	"Custom War"
}

enum _: GunsData
{
	GunName[20],
	GunWeapon[20],
	GunAmmo
}

new const WeaponList[][GunsData] =
{	
	{ "Knife",	"weapon_knife",		CSW_KNIFE	},
	{ "M4a1",	"weapon_m4a1",		CSW_M4A1	},
	{ "Ak47",	"weapon_ak47",		CSW_AK47	},
	{ "Hegrenade",	"weapon_hegrenade",	CSW_HEGRENADE	},
	{ "M249",	"weapon_m249",		CSW_M249	},
	{ "AWP",	"weapon_awp",		CSW_AWP		},
	{ "Deagle",	"weapon_deagle",	CSW_DEAGLE	},
	{ "Scout",	"weapon_scout",		CSW_SCOUT	},
	{ "USP",	"weapon_usp",		CSW_USP		},
	{ "Glock",	"weapon_glock18",	CSW_GLOCK18	},
	{ "Elite",	"weapon_elite",		CSW_ELITE	},
	{ "Fiveseven",	"weapon_fiveseven",	CSW_FIVESEVEN	},
	{ "Galil",	"weapon_galil",		CSW_GALIL	},
	{ "Famas",	"weapon_famas",		CSW_FAMAS	},
	{ "AUG",	"weapon_aug",		CSW_AUG,	},
	{ "SG552",	"weapon_sg552",		CSW_SG552	},
	{ "MP5",	"weapon_mp5navy",	CSW_MP5NAVY	},
	{ "UZI",	"weapon_mac10",		CSW_MAC10	},
	{ "TMP",	"weapon_tmp",		CSW_TMP		},
	{ "XM1014",	"weapon_xm1014",	CSW_XM1014	},
	{ "M3",		"weapon_m3",		CSW_M3		}
}
new const S4S_WeaponList[][GunsData] =
{	
	
	{ "Deagle",	"weapon_deagle",	CSW_DEAGLE	},
	{ "USP",	"weapon_usp",		CSW_USP		},
	{ "Glock",	"weapon_glock18",	CSW_GLOCK18	},
	{ "Fiveseven",	"weapon_fiveseven",	CSW_FIVESEVEN	},
	{ "Elite",	"weapon_elite",		CSW_ELITE	},
	{ "UZI",	"weapon_mac10",		CSW_MAC10	},
	{ "AWP",	"weapon_awp",		CSW_AWP		}
}

enum _: RulesNames
{
	ENEMY,
	bool:BHOP,
	bool:DUCK,
	bool:JUMP
}

enum _: WarsRulesNames
{
	WEAPON,
	HEALTH,
	bool:HEADSHOT,
	bool:ZOOM,
	bool:KNIFE
}

new g_mSound[ ] = "weapons/g_bounce1.wav";


new iRule[33][RulesNames],wRule[33][WarsRulesNames];
new bool:LR_Running,LR_RUN,LR_CT,LR_T,QuestionRun,g_synchud,Answer,TS_Answer[15],g_Combo[12];
new g_Count[33],g_Buttons[12],MAX=10,CountTsay,STRIP_TIME,gTouched[33],m_iTrail,tBalls[33],iHudMessage,MaxPlayers;

new szLocation [] = "eTs/JailBreak"
new v_szDodgeball[] = "v_dodgeball.mdl"
new p_szDodgeball[] = "p_dodgeball.mdl"
new w_szDodgeball[] = "w_dodgeball.mdl"

// Winner Beam
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
	register_plugin("JailBreak LR","1.0","niko & MJ")
	
	register_clcmd("say","say_handler");
	
	register_forward( FM_PlayerPreThink, "fw_Player_PreThink" ); 
	
	g_synchud = CreateHudSyncObj( );
	iHudMessage = CreateHudSyncObj( );
	
	RegisterHam(Ham_Weapon_SecondaryAttack,"weapon_awp","CheckBlockZoom",0);
	RegisterHam(Ham_Weapon_SecondaryAttack,"weapon_scout","CheckBlockZoom",0);
	RegisterHam(Ham_Player_Jump,"player","BlockJump");
	RegisterHam(Ham_Player_Duck,"player","BlockDuck");
	RegisterHam( Ham_Use , "func_button" , "Fwd_UseButton")
	
	for(new i; i < sizeof(S4S_WeaponList); i++)
		RegisterHam(Ham_Weapon_PrimaryAttack,S4S_WeaponList[i][GunWeapon],"CheckBullets",1);	
	RegisterHam( Ham_Touch, "armoury_entity", "FwdHamPlayerPickup" ); 
	RegisterHam( Ham_Touch, "weaponbox", "FwdHamPlayerPickup" );
	RegisterHam( Ham_TraceAttack, "player", "CheckHS");
	RegisterHam(Ham_Killed,"player","PlayerKilled",1);
	RegisterHam(Ham_TakeDamage,"player","TakeDamage",1);
	RegisterHam(Ham_Touch,"grenade","Ham_Touch_Grenade_Pre",1);
	register_think("grenade", "think_grenade");
	register_forward(FM_SetModel, "fwdSetModel");
	
	register_forward( FM_EmitSound, "FwdEmitSound", 0 );
	
	register_logevent("RoundStart", 2, "1=Round_Start")
	register_clcmd("drop","BlockDrop");
	register_event("CurWeapon","evCurWeapon","be","1=1");
	MaxPlayers = get_maxplayers();
}

public plugin_precache() {
	new temp[ 100 ];
	formatex( temp, charsmax( temp ), "models/%s/days_lr/Dodgeball/%s", szLocation,v_szDodgeball);
	precache_model(temp)
	formatex( temp, charsmax( temp ), "models/%s/days_lr/Dodgeball/%s", szLocation,p_szDodgeball);
	precache_model(temp)
	formatex( temp, charsmax( temp ), "models/%s/days_lr/Dodgeball/%s", szLocation,w_szDodgeball);
	precache_model(temp)
	m_iTrail = precache_model("sprites/smoke.spr");
	SpriteIndex = precache_model( "sprites/zbeam2.spr" );
	precache_sound(g_mSound);
}

public plugin_natives()
	register_native("get_lr_run","_get_lr_run");

public _get_lr_run(plugin,param)
	return LR_Running;
	
public RoundStart()
{
	LR_Running=false;
	QuestionRun=false;
	LR_CT = 0;
	LR_T = 0;
	remove_task(CD_TASK);
	for(new i = 1; i <MaxPlayers; i++)
	{
		BaseRules(i)
		BaseWarRules(i)
	}
	
}

public say_handler(id) {
	new szMsg[128];
	read_args(szMsg,128);
	remove_quotes(szMsg);
	if (equali(szMsg,"/lr"))
		return LastRequest_Menu(id)
	if((equali(szMsg,TS_Answer) || str_to_num(szMsg) ==Answer) && LR_Running && QuestionRun && (id == LR_T || id == LR_CT) && LR_RUN >= WRITE_FW && LR_RUN <= WRITE_FL && is_user_alive(id))
	{
		new Loser;
		if (id == LR_T)
			Loser = LR_CT;
		else
			Loser = LR_T;
		QuestionRun=false;
		user_kill(Loser,1);
		new pnumber,players[32];
		get_players(players,pnumber,"ch");
		ColorChat(0,"^3%s ^1has won ^3%s ^1at ^4%s ^1LastRequest %s",get_name(id),get_name(Loser),LastRequestsList[LR_RUN], pnumber < 5 ? "" : "and has gotten^3 5 ^1XP!");
		Until = get_gametime() + 7.0;
		WinnerBeam( id + WinnerBeam_Task );
		
		if(pnumber < 5)
			ColorChat(0,"^3%s ^1cannot get ^4XP^1, there are not ^3enough players ^1to get XP",get_name(id));
		else
			set_user_xp(id,get_user_xp(id)+5);
		//ColorChat(0,"^3%s ^1has ^4won ^1the ^3%s",get_name(id),LastRequestsList[LR_RUN]);
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0,"%s has won the %s",get_name(id),LastRequestsList[LR_RUN]);
		create_user_box(id)
		make_user_dance(id);
		start_random_winningsound();
		remove_task(CD_TASK);
		LR_Running=false;
		return 0;
	}
	return 0;
}

public LastRequest_Menu(id)
{
	new pnum,players[32];
	get_players(players,pnum,"ae","TERRORIST");	
	if(pnum != 1 || players[0] !=id)
		return ColorChat(id,"you must to be ^3alive ^1and the ^3last terrorist ^1to open ^4LastRequest Menu^1.");
	get_players(players,pnum,"ae","CT");
	if(pnum < 1)
		return ColorChat(id,"there are ^3no alive ^4guards^1.");
	if(LR_Running)
		return ColorChat(id,"you cannot open ^4LastRequest Menu ^1if LR is ^3running^1.");
	
	new Text[64];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLast Request \rMain Menu",TAG);
	new Menu = menu_create(Text,"LastRequest_Handler");
	
	menu_additem(Menu,"\wCustom Wars");
	menu_additem(Menu,"Shot4Shot Duels");
	menu_additem(Menu,"Write Duels");
	menu_additem(Menu,"Special Duels");
	
	menu_display(id,Menu);
	return 1;
}

public LastRequest_Handler(id,menu,Item)
{
	switch(Item)
	{
		case 0:
		{
			BaseWarRules(id)
			CustomWar_Menu(id)
		}
		case 1: S4S_Menu(id)
		case 2: Write_Menu(id)
		case 3: Spec_Menu(id)
	}
	BaseRules(id);
	menu_destroy(menu);
	return 1;
}

public CustomWar_Menu(id)
{
	new Text[64];
	
	new cb = menu_makecallback("CheckZoom")
	new cb2 = menu_makecallback("CheckKnife")
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLastRequest \rCustom Wars Menu\w",TAG);
	new Menu = menu_create(Text,"CustomWar_Handler");
	
	formatex(Text,charsmax(Text),"\wWeapon \r[\d%s\r]",WeaponList[wRule[id][WEAPON]][GunName]);
	menu_additem(Menu,Text);
	
	formatex(Text,charsmax(Text),"\wHealth \r[\d%d\r]", wRule[id][HEALTH]);
	menu_additem(Menu,Text);
	
	formatex(Text,charsmax(Text),"\wHeadShot \r[\d%s\r]", wRule[id][HEADSHOT] ? "Enable" : "Disable");
	menu_additem(Menu,Text);

	formatex(Text,charsmax(Text),"\wZoom \r[\d%s\r]", wRule[id][ZOOM] ? "Enable" : "Disable");
	menu_additem(Menu,Text,.callback = cb);
	
	formatex(Text,charsmax(Text),"\wKnife \r[\d%s\r]^n", wRule[id][KNIFE] ? "Enable" : "Disable");
	menu_additem(Menu,Text,.callback = cb2);
	
	menu_additem(Menu,"Next");
	
	menu_display(id,Menu)
	return 1;
}

public CustomWar_Handler(id,menu,Item)
{	
	menu_destroy(menu)
	
	new players[32],pnum;
	get_players(players,pnum,"ace","TERRORIST");
	if(pnum > 1)
		return 1;
	
	LR_RUN = CUSTOM_WAR;
	switch(Item)
	{
		case MENU_EXIT:
		{
			LastRequest_Menu(id);
			return 1;
		}
		case 0:
		{
			WeaponList_Menu(id)
			return 1;
		}
		case 1:
		{
			wRule[id][HEALTH] += 100;
			if(wRule[id][HEALTH] > 1500)
				wRule[id][HEALTH] = 100;
		}
		case 2:
			wRule[id][HEADSHOT] = !wRule[id][HEADSHOT]
		case 3:
			wRule[id][ZOOM] = !wRule[id][ZOOM]
		case 4:
			wRule[id][KNIFE] = !wRule[id][KNIFE]
		case 5:
		{
			Rules_Menu(id);
			return 1;
		}
	}
	CustomWar_Menu(id)
	return 1;
}

public WeaponList_Menu(id)
{
	new Text[64];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLastRequest \yCustom War ^n \rWeapons Menu\w",TAG);
	new Menu = menu_create(Text,"WeaponList_Handler");
	
	for(new i; i < sizeof(WeaponList); i++)
		menu_additem(Menu,WeaponList[i][GunName]);
		
	menu_setprop(Menu,MPROP_EXITNAME,"Back");
	
	menu_display(id,Menu);
	return 1;
}

public WeaponList_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu)
		return CustomWar_Menu(id)
	}
	wRule[id][WEAPON] = Item;
	
	if(Item == 0)
		wRule[id][KNIFE] = false;
	
	return CustomWar_Menu(id)
}

public S4S_Menu(id)
{
	new Text[64];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLastRequest \rS4S Menu\w",TAG);
	new Menu = menu_create(Text,"S4S_Handler");
	
	for(new i = S4S_DGL; i < WRITE_FW; i++)
		menu_additem(Menu,LastRequestsList[i]);
		
	menu_setprop(Menu,MPROP_EXITNAME,"Back");
	
	menu_display(id,Menu);
	return 1;
}

public S4S_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu)
		return LastRequest_Menu(id)
	}
	
	LR_RUN = Item + S4S_DGL;
	return Rules_Menu(id)
}

public Write_Menu(id)
{
	new Text[64];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLastRequest \rWrite Menu\w",TAG);
	new Menu = menu_create(Text,"Write_Handler");
	
	for(new i = WRITE_FW; i < SPEC_DODGEBALL; i++)
		menu_additem(Menu,LastRequestsList[i]);
		
	menu_setprop(Menu,MPROP_EXITNAME,"Back");
	
	menu_display(id,Menu);
	return 1;
}

public Write_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu)
		return LastRequest_Menu(id)
	}
	
	LR_RUN = Item + WRITE_FW;
	return Rules_Menu(id)
}

public Spec_Menu(id)
{
	new Text[64];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLastRequest \rSpecial Menu\w",TAG);
	new Menu = menu_create(Text,"Spec_Handler");
	
	new cb = menu_makecallback("ReturnDisabled");
	
	for(new i = SPEC_DODGEBALL; i < CUSTOM_WAR; i++)
		if(i == SPEC_LASER)
			menu_additem(Menu,LastRequestsList[i],.callback = cb);
		else
			menu_additem(Menu,LastRequestsList[i]);
		
	menu_setprop(Menu,MPROP_EXITNAME,"Back");
	
	menu_display(id,Menu);
	return 1;
}

public Spec_Handler(id,menu,Item)
{	
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu)
		return LastRequest_Menu(id)
	}
	
	LR_RUN = Item + SPEC_DODGEBALL;
	return Rules_Menu(id)	
}

public Rules_Menu(id)
{
	new Text[64];
	new cb = menu_makecallback("CheckRules")
	new cb2 = menu_makecallback("CheckGames")
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLastRequest \y%s ^n\rRules Menu",TAG,LastRequestsList[LR_RUN]);
	if(LR_RUN == CUSTOM_WAR)
		formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLastRequest \y%s \d- \w%s ^n\rRules Menu",TAG,LastRequestsList[LR_RUN],WeaponList[wRule[id][WEAPON]][GunName]);
	new Menu = menu_create(Text,"Rules_Handler");
	
	if(iRule[id][ENEMY] == 0)
		formatex(Text,charsmax(Text),"\wEnemy \r[\d%s\r]","None");
	else
		formatex(Text,charsmax(Text),"\wEnemy \r[\d%s\r]",get_name(iRule[id][ENEMY]));
	menu_additem(Menu,Text);
	
	formatex(Text,charsmax(Text),"\wAllow BunnyHop \r[\d%s\r]", iRule[id][BHOP] ? "Enable" : "Disable");
	menu_additem(Menu,Text,.callback = cb2);

	formatex(Text,charsmax(Text),"\wAllow Duck \r[\d%s\r]", iRule[id][DUCK] ? "Enable" : "Disable");
	menu_additem(Menu,Text,.callback = cb2);
	
	formatex(Text,charsmax(Text),"\wAllow Jump \r[\d%s\r]^n", iRule[id][JUMP] ? "Enable" : "Disable");
	menu_additem(Menu,Text,.callback = cb2);
	
	menu_additem(Menu,"Start",.callback = cb);
	
	menu_setprop(Menu,MPROP_EXITNAME,"Back")
	menu_display(id,Menu);
	return 1;
}

public Rules_Handler(id,menu,Item)
{
	menu_destroy(menu)
	
	switch(Item)
	{
		case MENU_EXIT:
			return LastRequest_Menu(id);
		case 0:
			return CTList_Menu(id)
		case 1:
			iRule[id][BHOP] = !iRule[id][BHOP]
		case 2:
			iRule[id][DUCK] = !iRule[id][DUCK]
		case 3:
		{
			iRule[id][JUMP] = !iRule[id][JUMP]
			if(iRule[id][JUMP] == false)
				iRule[id][BHOP] = false;
		}
		case 4:
			return StartLR();
	}
	return Rules_Menu(id)
}

public CTList_Menu(id)
{
	new Text[128],pnum,players[32],Info[2];
	get_players(players,pnum,"ae","CT");
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wLastRequest \y%s ^n\rChoose Enemy Menu",TAG,LastRequestsList[LR_RUN]);
	new Menu = menu_create(Text,"CTList_Handler");
	
	for(new i; i < pnum; i++)
	{
		new Player = players[i];
		Info[0] = Player;
		menu_additem(Menu,get_name(Player),Info);
	}
	
	menu_setprop(Menu,MPROP_EXITNAME,"Back");
	menu_display(id,Menu)
	return 1;
}
public CTList_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu)
		return Rules_Menu(id)
	}
	new szData[2],Empty;
	menu_item_getinfo(menu,Item,Empty,szData,charsmax(szData),_,_,Empty);
	LR_CT = szData[0];
	LR_T = id;
	iRule[id][ENEMY] = LR_CT;
	menu_destroy(menu)
	return Rules_Menu(id);
}

public StartLR()
{
	new ent = -1  
	while((ent = find_ent_by_class(ent, "func_button")))  
		dllfunc(DLLFunc_Use, ent, 0);
	new pnum,players[32];
	get_players(players,pnum,"ae","TERRORIST")
	if(!is_user_alive(LR_T) || !is_user_alive(LR_CT) || pnum > 1)
		return 1;
	set_user_health(LR_T,100);
	set_user_health(LR_CT,100);
	st_strip_user_weapons(LR_T);
	st_strip_user_weapons(LR_CT);
	LR_Running = true;
	LR_Info()
	CountTsay = 5;
	QuestionRun=false;
	formatex(TS_Answer,sizeof TS_Answer-1,"ABASHABEMZONA");
	remove_task(CD_TASK);
	Answer = 412940214124210491204;
	
	TeamBeam(LR_T + TeamBeam_Task );
	TeamBeam(LR_CT + TeamBeam_Task );
	
	set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 8.0,_,_,4)
	if(LR_RUN != CUSTOM_WAR)
	{
		ColorChat(0,"^3%s ^1has challenged ^3%s ^1at ^4%s ^1^1^1LastRequest!",get_name(LR_T),get_name(LR_CT),LastRequestsList[LR_RUN]);
		show_hudmessage(0,"%s has challenged %s at %s LastRequest",get_name(LR_T),get_name(LR_CT),LastRequestsList[LR_RUN]);
	}
	else
	{
		ColorChat(0,"^3%s ^1has challenged ^3%s ^1with ^4%s^4 (^1%s Duel^4) ^1LastRequest!",get_name(LR_T),get_name(LR_CT),LastRequestsList[LR_RUN],WeaponList[wRule[LR_T][WEAPON]][GunName]);
		show_hudmessage(0,"%s has challenged %s at %s (%s Duel) LastRequest",get_name(LR_T),get_name(LR_CT),LastRequestsList[LR_RUN],WeaponList[wRule[LR_T][WEAPON]][GunName]);
		
	}
	switch(LR_RUN)
	{
		case S4S_DGL..S4S_AWP_NOZOOM:
		{
			give_item(LR_T,S4S_WeaponList[LR_RUN][GunWeapon]);
			set_user_ammo(LR_T,S4S_WeaponList[LR_RUN][GunWeapon], 1 );
			give_item(LR_CT,S4S_WeaponList[LR_RUN][GunWeapon]);
			set_user_ammo(LR_CT,S4S_WeaponList[LR_RUN][GunWeapon], 0 );
			
			
		}
		case WRITE_FW..WRITE_FL,SPEC_COMBO:
			LoadCD()
		case SPEC_DODGEBALL:
		{
			tBalls[LR_T] = 0;
			tBalls[LR_CT] = 0;
			give_item(LR_T,"weapon_hegrenade");
			cs_set_user_bpammo(LR_T,CSW_HEGRENADE,9999);
			give_item(LR_CT,"weapon_hegrenade");
			cs_set_user_bpammo(LR_CT,CSW_HEGRENADE,9999);
			evCurWeapon2(LR_T)
			evCurWeapon2(LR_CT)
		}
		case SPEC_DGLPOWER:
		{
			set_user_health(LR_T,500);
			set_user_health(LR_CT,500);
			give_item(LR_T,"weapon_knife");
			give_item(LR_T,"weapon_deagle");
			cs_set_user_bpammo(LR_T,CSW_DEAGLE,9999);
			give_item(LR_CT,"weapon_knife");
			give_item(LR_CT,"weapon_deagle");
			cs_set_user_bpammo(LR_CT,CSW_DEAGLE,9999);
		}
		case SPEC_SURVIVAL:
		{	
			give_item(LR_T,"weapon_knife");
			give_item(LR_T,"weapon_m4a1");
			cs_set_user_bpammo(LR_T,CSW_M4A1,9999);
			give_item(LR_T,"weapon_ak47");
			cs_set_user_bpammo(LR_T,CSW_AK47,9999);
			give_item(LR_T,"weapon_deagle");
			cs_set_user_bpammo(LR_T,CSW_DEAGLE,9999);
			set_user_health(LR_CT,1500);
			give_item(LR_CT,"weapon_knife");
		}
		case SPEC_STRIP:
		{
			give_item(LR_T,"weapon_knife");
			STRIP_TIME = 60;
			set_task(1.0,"KillTerror");
			
		}
		case SPEC_GHOST:
		{
			give_item(LR_T,"weapon_knife");
			give_item(LR_T,"weapon_m4a1");
			cs_set_user_bpammo(LR_T,CSW_M4A1,9999);
			give_item(LR_T,"weapon_ak47");
			cs_set_user_bpammo(LR_T,CSW_AK47,9999);
			give_item(LR_T,"weapon_deagle");
			cs_set_user_bpammo(LR_T,CSW_DEAGLE,9999);
			set_user_health(LR_CT,500);
			give_item(LR_CT,"weapon_knife");
			set_user_noclip(LR_CT,1);
		}
		case CUSTOM_WAR:
		{
			give_item(LR_T,WeaponList[wRule[LR_T][WEAPON]][GunWeapon]);
			give_item(LR_CT,WeaponList[wRule[LR_T][WEAPON]][GunWeapon]);
			if(WeaponList[wRule[LR_T][WEAPON]][GunAmmo] != CSW_KNIFE)
			{
				cs_set_user_bpammo(LR_T,WeaponList[wRule[LR_T][WEAPON]][GunAmmo],9999);
				cs_set_user_bpammo(LR_CT,WeaponList[wRule[LR_T][WEAPON]][GunAmmo],9999);
				
				if(wRule[LR_T][KNIFE])
				{
					give_item(LR_T,"weapon_knife");
					give_item(LR_CT,"weapon_knife");
				}
			}
			set_user_health(LR_T,wRule[LR_T][HEALTH]);
			set_user_health(LR_CT,wRule[LR_T][HEALTH]);
		}
	}
	return 1;
}

public LoadCD()
{
	if(!LR_Running) return 1;
	if(CountTsay ==0)
	{
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 5.0,_,_,4)
		remove_task( CD_TASK );
		switch (LR_RUN) {
			case WRITE_FW: {	
				Answer = random_num(fw_nums)
				show_hudmessage(0, "The first who writes^n[%d]^nwins the %s",Answer,LastRequestsList[LR_RUN]);
				ColorChat(0,"^1The first who ^4writes ^3%d^1, wins the ^3%s.",Answer,LastRequestsList[LR_RUN]);
			}
			case WRITE_MATH: {
				new Num1 = random_num(math_nums);
				new Num2 = random_num(math_nums);
				new MathMode = random_num(0,1)
				switch (MathMode) {
					case 0: Answer = Num1 + Num2;
					case 1: Answer = Num1 - Num2;
				}
				show_hudmessage(0, "The first who solves the math problem^n[%d%s%d]^nwins the %s",Num1, MathMode == 0 ? "+":"-",Num2,LastRequestsList[LR_RUN]);
				ColorChat(0,"^1The first who ^4solves the math problem ^3%d^1%s^3%d^1, wins the ^3%s.",Num1,MathMode==0 ? "+":"-", Num2,LastRequestsList[LR_RUN]);
			}
			case WRITE_TS: {
				new qTS = random_num(0,MaxWords);
				formatex(TS_Answer,sizeof TS_Answer-1,TS_Words[qTS][0]);
				show_hudmessage(0, "The first who translates the word^n%s^nwins the %s",TS_Words[qTS][1],LastRequestsList[LR_RUN]);
				ColorChat(0,"^1The first who ^4translates the word ^3%s^1, wins the ^3%s.",TS_Words[qTS][1],LastRequestsList[LR_RUN]);
			}
			case WRITE_FL:
			{
				Answer = random_num(0,99);
				new szVox[20];
				num_to_word(Answer,szVox,charsmax(szVox));
				new Arg[2][10];
				parse(szVox,Arg[0],9,Arg[1],9);
				client_cmd(LR_T,"spk ^"vox/%s^"",Arg[0]);
				client_cmd(LR_CT,"spk ^"vox/%s^"",Arg[0]);
				if(Answer > 20)
					set_task(0.7,"second_num");
				show_hudmessage(0, "The first who writes the listen number^nwins the %s",LastRequestsList[LR_RUN]);
				ColorChat(0,"^1The first who ^4writes ^3listen number^1, wins the ^3%s.",LastRequestsList[LR_RUN]);
			}
			case SPEC_COMBO: {
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
		}
		QuestionRun=true;
	}
	if(CountTsay > 0) {
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0, "%s will start in %d seconds",LastRequestsList[LR_RUN],CountTsay);
		new szVox[10];
		num_to_word( CountTsay, szVox, charsmax( szVox ) );
		client_cmd( 0, "spk ^"vox/%s^"", szVox );
		CountTsay--;
		set_task(1.0,"LoadCD",CD_TASK);
	}
	return 1;
}

public second_num()
{
	new szVox[20];
	num_to_word(Answer,szVox,charsmax(szVox));
	new Arg[2][10];
	parse(szVox,Arg[0],9,Arg[1],9);
	client_cmd(LR_T,"spk ^"vox/%s^"",Arg[1]);
	client_cmd(LR_CT,"spk ^"vox/%s^"",Arg[1]);
}

public KillTerror()
{
	if((STRIP_TIME > 0) && is_user_alive(LR_T) && is_user_alive(LR_CT))
	{
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 1.1,_,_,4)
		show_hudmessage(LR_T, "Time Left: %d",STRIP_TIME);
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 1.1,_,_,4)
		show_hudmessage(LR_CT, "Time Left: %d",STRIP_TIME);
		STRIP_TIME --;
		set_task(1.0,"KillTerror");
	}
	else
	{
		if(is_user_alive(LR_CT))
		{
			user_kill(LR_T,1);
			new pnumber,players[32];
			get_players(players,pnumber,"ch");
			ColorChat(0,"^3%s ^1has won ^3%s ^1at ^4%s ^1LastRequest %s",get_name(LR_CT),get_name(LR_T),LastRequestsList[LR_RUN], pnumber < 5 ? "" : "and has gotten^3 5 ^1XP!");
			Until = get_gametime() + 7.0;
			WinnerBeam( LR_CT  + WinnerBeam_Task )
			
			if(pnumber < 5)
				ColorChat(0,"^3%s ^1cannot get ^4XP^1, there are not ^3enough players ^1to get XP",get_name(LR_CT));
			else
				set_user_xp(LR_CT,get_user_xp(LR_CT)+5);
			//ColorChat(0,"^3%s ^1has ^4won ^1the ^3%s",get_name(LR_CT),LastRequestsList[LR_RUN]);
			set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
			show_hudmessage(0,"%s has won the %s",get_name(LR_CT),LastRequestsList[LR_RUN]);
			create_user_box(LR_CT)
			make_user_dance(LR_CT);
			start_random_winningsound();
		}
	}
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
	if((id != LR_T && id != LR_CT ) || !LR_Running || !QuestionRun || !is_user_alive(id))
		return 1;
	set_hudmessage(21, 157, 144, _, 0.25, 0, 0.1, 0.1, 0.1, 0.1, 4 );
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
	return 1;
}

public fw_Player_PreThink( id ) 
{
	if((id != LR_T && id != LR_CT) || !is_user_alive(id)) 
		return FMRES_IGNORED; 
	static iButton;
	iButton = pev( id, pev_button ); 
	
	if(LR_RUN != SPEC_COMBO || !LR_Running)
		return FMRES_IGNORED;
		
	if( g_Count[ id ] >= MAX )
	{
		g_Count[id] = 0;
		new Loser;
		if (id == LR_T)
			Loser = LR_CT;
		else
			Loser = LR_T;
		ExecuteHamB(Ham_Killed, Loser, id, 0);
		new pnumber,players[32];
		get_players(players,pnumber,"ch");
		ColorChat(0,"^3%s ^1has ^4won ^1the ^3%s",get_name(id),LastRequestsList[LR_RUN]);
		ColorChat(0,"^3%s ^1has won ^3%s ^1at ^4%s ^1LastRequest %s",get_name(id),get_name(Loser),LastRequestsList[LR_RUN], pnumber < 5 ? "" : "and has gotten^3 5 ^1XP!");
		Until = get_gametime() + 7.0;
		WinnerBeam( id + WinnerBeam_Task )
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
		show_hudmessage(0,"%s has won the %s",get_name(id),LastRequestsList[LR_RUN]);
		create_user_box(id)
		make_user_dance(id);
		start_random_winningsound();
		if(pnumber < 5)
			ColorChat(0,"^3%s ^1cannot get ^4XP^1, there are not ^3enough players ^1to get XP",get_name(id));
		else
			set_user_xp(id,get_user_xp(id)+5);
		remove_task(CD_TASK);
		LR_Running=false;
		QuestionRun=false;
	} 
	if( g_Count[ id ] != 0 && iButton & g_Buttons[ g_Combo[ g_Count[ id ]-1 ] ] )
		return FMRES_IGNORED;

	if( iButton & g_Buttons[ g_Combo[ g_Count[ id ] ] ] )
		g_Count[ id ] ++;
	else if( iButton )
		g_Count[ id ] = 0;
	showcombo( id );
	return FMRES_SUPERCEDE
}
 
public PlayerKilled(killed,killer)
{	
	set_user_rendering(killed)
	if(!LR_Running && cs_get_user_team(killed) == CS_TEAM_CT)
		if(killer != 0)
			create_user_box(killer);
	
	if(!LR_Running)
		return 1;
	
	if(killed == LR_CT || killed == LR_T)
		LR_Running = false;
	
	if(killer != LR_CT && killed == LR_T && is_user_connected(killer) && killer != killed && killer != 0)
	{	
		ColorChat(0,"^3%s ^1has killed ^3%s ^1while ^4%s ^1LastRequest against ^3%s^1!",get_name(killer),get_name(killed),LastRequestsList[LR_RUN],get_name(LR_CT));
		return 1;
	}
	if(killed == LR_CT && LR_RUN == SPEC_STRIP && STRIP_TIME > 0)
	{
		new pnumber,players[32];
		get_players(players,pnumber,"ch");
		ColorChat(0,"^3%s ^1has won ^3%s ^1at ^4%s ^1LastRequest %s",get_name(LR_T),get_name(killed),LastRequestsList[LR_RUN], pnumber < 5 ? "" : "and has gotten^3 5 ^1XP!");
		create_user_box(LR_T)
		make_user_dance(LR_T);
		start_random_winningsound();
		Until = get_gametime() + 7.0;
		WinnerBeam( LR_T + WinnerBeam_Task )
		
		if(pnumber < 5)
			ColorChat(0,"^3%s ^1cannot get ^4XP^1, there are not ^3enough players ^1to get XP",get_name(LR_T));
		else
			set_user_xp(LR_T,get_user_xp(LR_T)+5);
		return 1;
	}
	if((LR_RUN >= WRITE_FW && LR_RUN <= WRITE_FL) || LR_RUN == SPEC_COMBO)
		return 1;
	
	if(killed == killer || !is_user_connected( killer ) && LR_RUN != SPEC_STRIP)
	{
		ColorChat(0,"^3%s ^1 committed suicide while playing ^3%s ^1LastRequest against ^3%s^1!",get_name(killed),LastRequestsList[LR_RUN],get_name(killed == LR_T ? LR_CT : LR_T));
		return 1;
	}
	if(cs_get_user_team(killed) == CS_TEAM_CT && killed != LR_CT && killer == LR_T)
	{
		ColorChat(0,"^3%s ^1has killed ^3%s ^1while ^4%s ^1LastRequest against ^3%s^1!",get_name(killer),get_name(killed),LastRequestsList[LR_RUN],get_name(LR_CT));
		return 1;
	}
	new pnumber,players[32];
	get_players(players,pnumber,"ch");
	ColorChat(0,"^3%s ^1has won ^3%s ^1at ^4%s ^1LastRequest %s",get_name(killer),get_name(killed),LastRequestsList[LR_RUN], pnumber < 5 ? "" : "and has gotten^3 5 ^1XP!");
	create_user_box(killer)
	Until = get_gametime() + 7.0;
	WinnerBeam( killer + WinnerBeam_Task )
	if(pnumber < 5)
		ColorChat(0,"^3%s ^1cannot get ^4XP^1, there are not ^3enough players ^1to get XP",get_name(killer));
	else
		set_user_xp(killer,get_user_xp(killer)+5);
	make_user_dance(killer);
	start_random_winningsound();
	return 1;
}

public TakeDamage( victim, inf, attacker, Float:dmg,dmgtype)
{
	if(victim != attacker )
	{
		if(LR_Running && (victim == LR_T || victim == LR_CT) && (attacker == LR_CT || attacker == LR_T) && LR_RUN == SPEC_DGLPOWER && is_user_alive(victim))
		{
			new Float:velocity[ 3 ];
			entity_get_vector(victim,EV_VEC_velocity,velocity);
			for( new i; i < 3; i++ )
				velocity[ i ] += random_float( ( dmg * 50.0 ) - 100, ( dmg * 50.0 ) + 100);
		
			entity_set_vector( victim, EV_VEC_velocity, velocity );
		}
	}
}


public CheckHS (id, attacker, Float:dmg, Float:dir[3], tr, dmgbit)
{
	if(wRule[LR_T][HEADSHOT] && LR_RUN == CUSTOM_WAR && (attacker == LR_T || attacker == LR_CT) && get_tr2(tr, TR_iHitgroup) != HIT_HEAD && LR_Running) 
		return HAM_SUPERCEDE;
	return 0;
}

public client_disconnect(id)
{
	if(!LR_Running)
		return 1;
	if(id != LR_T && id != LR_CT)
		return 1;
	if(id == LR_T)
		ColorChat(0,"^3%s ^1has left while LastRequest ^4%s ^1against ^3%s",get_name(LR_T),LastRequestsList[LR_RUN],get_name(LR_CT))
	else if(id == LR_CT)
		ColorChat(0,"^3%s ^1has left while LastRequest ^4%s ^1against ^3%s",get_name(LR_CT),LastRequestsList[LR_RUN],get_name(LR_T))
	LR_Running = false;
	return 1;
}
public LR_Info()
{
	if(LR_Running)
	{
		new TS[512];
		static Info;
		Info = 0;
		
		if(LR_RUN == SPEC_DODGEBALL)
		{
			Info += formatex(TS[Info],511-Info,"Terrorist Info:^nNick: %s ^nThrow Balls: %d^nCounter-Terrorist Info:^nNick: %s ^nThrow Balls: %d^n",get_name(LR_T),tBalls[LR_T],get_name(LR_CT),tBalls[LR_CT])
		}
		else if(LR_RUN == SPEC_COMBO)
		{
			Info += formatex(TS[Info],511-Info,"Terrorist Info:^nNick: %s ^nCompleted Actions (%d/10)^nCounter-Terrorist Info:^nNick: %s ^nCompleted Actions (%d/10)^n",get_name(LR_T),g_Count[LR_T],get_name(LR_CT),g_Count[LR_CT])
		}
		else
			Info += formatex(TS[Info],511-Info,"Terrorist Info:^nNick: %s ^nHealth: %d^nCounter-Terrorist Info:^nNick: %s ^nHealth: %d^n",get_name(LR_T),get_user_health(LR_T),get_name(LR_CT),get_user_health(LR_CT))
		
		if((LR_RUN < WRITE_FW || LR_RUN > WRITE_FL && LR_RUN != SPEC_COMBO))
			Info += formatex(TS[Info],511-Info,"-------------------------------^nLastRequest Rules:^nAllow Jump: %s ^nAllow Duck: %s ^nAllow Bunnyhop: %s^n",iRule[LR_T][JUMP] ? "Yes" : "No",iRule[LR_T][DUCK] ? "Yes" : "No",iRule[LR_T][BHOP] ? "Yes" : "No");
		
		if(LR_RUN == CUSTOM_WAR)
		{
			Info += formatex(TS[Info],511-Info,"-------------------------------^nCustom War Rules:^nHealth: %d ^nHeadshot Only: %s^n",wRule[LR_T][HEALTH],wRule[LR_T][HEADSHOT] ? "Yes" : "No");
			if(WeaponList[wRule[LR_T][WEAPON]][GunAmmo] != CSW_KNIFE)
				Info += formatex(TS[Info],511-Info,"Allow Knife: %s^n",wRule[LR_T][KNIFE] ? "Yes" : "No");
			if(WeaponList[wRule[LR_T][WEAPON]][GunAmmo] == CSW_AWP || WeaponList[wRule[LR_T][WEAPON]][GunAmmo] == CSW_SCOUT)
				Info += formatex(TS[Info],511-Info,"Allow Zoom: %s^n",wRule[LR_T][ZOOM] ? "Yes" : "No");
		}
		format(TS,charsmax(TS),"%s^n^n To disable this information write /infomsg",TS);
		set_hudmessage(0, 170, 255, 0.08, 0.13, 0, 6.0, 0.6)
		for(new i = 1; i <= MaxPlayers; i++)
			if(!is_user_connected(i) || !get_user_showinfo(i))
				continue;
			else
				ShowSyncHudMsg(i, iHudMessage,"%s %s LastReqeust^n-------------------------------^n%s",TAG,LastRequestsList[LR_RUN],TS);
		set_task(0.2,"LR_Info");
	}
	else
		return 1;
	return 1;
}

public BlockJump(id)
{
	if((id == LR_T || id == LR_CT) && !iRule[LR_T][JUMP] && LR_Running)
		set_pev( id, pev_oldbuttons, pev( id, pev_oldbuttons ) | IN_JUMP );
}
public BlockDuck(id)
{
	if((id == LR_T || id == LR_CT) && !iRule[LR_T][DUCK] && LR_Running)
		set_pev( id, pev_oldbuttons, pev( id, pev_oldbuttons ) | IN_DUCK );
}

public FwdHamPlayerPickup( iEntity, id ) 
{
	if(LR_Running && (id == LR_T || id == LR_CT))
		return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

//Callbacks

public ReturnDisabled(id,menu,Item)
	return ITEM_DISABLED;

public CheckRules(id,menu,Item)
{
	if(iRule[id][ENEMY] == 0)
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public CheckGames(id,menu,Item)
{
	if(!iRule[id][JUMP] && Item == 1)
	{
		iRule[id][BHOP] = false;
		return ITEM_DISABLED;
	}
	if((LR_RUN >= WRITE_FW && LR_RUN <= WRITE_FL) || LR_RUN == SPEC_COMBO)
	{
		iRule[id][BHOP] = true;
		iRule[id][DUCK] = true;
		iRule[id][JUMP] = true;
		return ITEM_DISABLED;
	}
	return ITEM_ENABLED;
}

public CheckZoom(id,menu,Item)
{
	if(WeaponList[wRule[id][WEAPON]][GunAmmo] == CSW_AWP || WeaponList[wRule[id][WEAPON]][GunAmmo] == CSW_SCOUT)
		return ITEM_ENABLED;
	return ITEM_DISABLED;
}

public CheckKnife(id,menu,Item)
{
	if(WeaponList[wRule[id][WEAPON]][GunAmmo] == CSW_KNIFE)
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}


// Fowards

public evCurWeapon2(id)
	evCurWeapon(id)
public evCurWeapon(id)
{
	if(get_user_weapon(id) == CSW_HEGRENADE && LR_RUN == SPEC_DODGEBALL && LR_Running && (id == LR_T || id == LR_CT))
	{
		new temp[ 100 ];
		formatex( temp, charsmax( temp ), "models/%s/days_lr/Dodgeball/%s", szLocation,v_szDodgeball);
		set_pev(id, pev_viewmodel2,temp);
		formatex( temp, charsmax( temp ), "models/%s/days_lr/Dodgeball/%s", szLocation,p_szDodgeball);
		set_pev(id, pev_weaponmodel2,temp );
	}
}
public fwdSetModel(ent,const model[])
{
        if(!pev_valid(ent) || !equal(model,"models/w_hegrenade.mdl"))
                return FMRES_IGNORED
	new temp[ 100 ];
	formatex( temp, charsmax( temp ), "models/%s/days_lr/Dodgeball/%s", szLocation,w_szDodgeball);
	if(LR_RUN == SPEC_DODGEBALL && LR_Running && (pev(ent, pev_owner) == LR_T || pev(ent, pev_owner) == LR_CT))
	{
		engfunc(EngFunc_SetModel,ent,temp)
		TrailMessage(ent,pev(ent,pev_owner));
	}
	return FMRES_SUPERCEDE;
}	
public Ham_Touch_Grenade_Pre(iEntity,id)
{
	if(!LR_Running || LR_RUN != SPEC_DODGEBALL) return 1;
	new player = pev(iEntity, pev_owner);
	
	if(is_user_alive(id) && (id == LR_CT || id == LR_T) && (pev(iEntity, pev_owner) == LR_CT || pev(iEntity, pev_owner) == LR_T) && pev(iEntity, pev_owner) != id)
	{
		ExecuteHamB(Ham_Killed, id, pev(iEntity, pev_owner), 0)
		gTouched[player] = 0;
		remove_entity(iEntity)
	}
	if(gTouched[player] > 3)
	{
		remove_entity(iEntity)
		gTouched[player] = 0;
	}
	else
		gTouched[player] ++;
	return 1;
	/*
	if(is_user_alive(id) && (id == LR_CT || id == LR_T))
	{
		ExecuteHamB(Ham_Killed, id, pev(iEntity, pev_owner), 0)
		gTouched[id] = 0;
		remove_entity(iEntity)
	}
	if(gTouched[id] > 3)
	{
		remove_entity(iEntity)
		gTouched[id] = 0;
	}
	else
		gTouched[id] ++;
	return 1;*/
}
public think_grenade(ent) 
{
	if(LR_RUN != SPEC_DODGEBALL || !LR_Running) 
		return PLUGIN_CONTINUE;
	new model[32];
	entity_get_string(ent, EV_SZ_model, model, 31)
	if(equali(model,"models/w_hegrenade.mdl")) 
		return PLUGIN_CONTINUE;
	new killer = pev(ent, pev_owner)
	tBalls[killer] ++;
	return PLUGIN_HANDLED;
}



public FwdEmitSound( ent, channel, sample[], Float:volume, Float:atten, flags, pitch )
{
	if ( LR_Running && LR_RUN == SPEC_DODGEBALL )
	{
		if( containi( sample, "he_bounce" ) != -1 )
		{
			if ( pev( ent, pev_fuser1 ) + 0.3 < get_gametime( ) )
			{
				set_pev( ent, pev_fuser1, get_gametime() );
				
				emit_sound( ent, CHAN_ITEM, g_mSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
			}
			return 4;
		}
	}
	
	return 1;
}

stock  TrailMessage(ent,id)
{
	if(LR_Running && (id == LR_T || id == LR_CT) && LR_RUN == SPEC_DODGEBALL && is_user_connected(id))
	{
		if (ent) {
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
			write_byte( TE_BEAMFOLLOW )
			write_short(ent) // entity
			write_short(m_iTrail)  // model
			write_byte( 10 )       // life
			write_byte( 10 )        // width
			new r,b;
			if(cs_get_user_team(id) == CS_TEAM_CT)
				b = 255;
			else
				r = 255;
			write_byte( r )
			write_byte( 0 )
			write_byte( b )
			write_byte( 192 )
			message_end()
		}
	}
}

public BlockDrop(id)
{
	if(LR_Running && (id == LR_T || id == LR_CT))
		return 1;
	return 0;
}

public Fwd_UseButton(iEnt,id)
{
	new szInfo[ 32 ]
	pev( iEnt, pev_target, szInfo, charsmax( szInfo ) );
	
	new iTarget = engfunc( EngFunc_FindEntityByString, -1, "targetname", szInfo );
	
	if( iTarget )
		pev( iTarget, pev_classname, szInfo, charsmax( szInfo ) );
	if((equal( szInfo, "multi_manager" ) || equal( szInfo, "game_player_equip" )) && LR_Running  && (id == LR_T || id == LR_CT))
		return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public CheckBlockZoom(wep)
{
	if(!LR_Running)
		return HAM_IGNORED;
	new id = get_pdata_cbase(wep,41,4);
	if(id != LR_CT && id != LR_T)
		return HAM_IGNORED;
	if ((LR_RUN == CUSTOM_WAR && !wRule[LR_T][ZOOM]) || LR_RUN == S4S_AWP_NOZOOM)
		return HAM_SUPERCEDE;
	return HAM_IGNORED;
}

public CheckBullets(wep)
{
	if(!LR_Running)
		return HAM_IGNORED;
	new id = get_pdata_cbase(wep,41,4);
	if(LR_RUN > S4S_AWP_NOZOOM)
		return HAM_IGNORED;
	if(id == LR_CT)
		set_user_ammo(LR_T,S4S_WeaponList[LR_RUN][GunWeapon],1);
	if(id == LR_T)
		set_user_ammo(LR_CT,S4S_WeaponList[LR_RUN][GunWeapon],1);
	return HAM_IGNORED;
}

public client_PreThink(id)
{
	//if((get_run_day() && cs_get_user_team(id) == CS_TEAM_T) || (!get_trun_day() && get_run_day() &&  cs_get_user_team(id) == CS_TEAM_CT) || (LR_Running && (id == LR_T || id == LR_CT) && !iRule[LR_T][BHOP]))
	//	return 1;
	switch(cs_get_user_team(id))
	{
		case CS_TEAM_T:
		{
			if(get_run_day())
				return 1;
			else if(LR_Running && id == LR_T && !iRule[LR_T][BHOP])
				return 1;
		}
		case CS_TEAM_CT:
		{
			if(get_run_day() && !get_trun_day())
				return 1;
			else if(LR_Running && id == LR_CT && !iRule[LR_T][BHOP])
				return 1;
		}
	}
	entity_set_float(id, EV_FL_fuser2, 0.0)
	if (entity_get_int(id, EV_INT_button) & 2) 
	{
		new flags = entity_get_int(id, EV_INT_flags)
		if (flags & FL_WATERJUMP)
			return PLUGIN_CONTINUE
		if ( entity_get_int(id, EV_INT_waterlevel) >= 2 )
			return PLUGIN_CONTINUE
		if ( !(flags & FL_ONGROUND) )
			return PLUGIN_CONTINUE
		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		velocity[2] += 250.0
		entity_set_vector(id, EV_VEC_velocity, velocity)
		entity_set_int(id, EV_INT_gaitsequence, 6)
	}
	return PLUGIN_CONTINUE
}


public WinnerBeam( Task )
{
	new id = Task - WinnerBeam_Task;
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
	set_task( 0.2, "WinnerBeam", id + WinnerBeam_Task );
	return 0;
}

public TeamBeam( Task )
{
	new id = Task - TeamBeam_Task;
	if(!LR_Running || !is_user_alive(id))
		return 0;
	if(id != LR_CT && id != LR_T)
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
	write_coord( Origin[ 2 ] + 40 );
	write_short( SpriteIndex );// sprite index
	write_byte( 0 );// starting frame
	write_byte( 50 ); // frame rate in 0.1's
	write_byte( 15 )// life in 0.1's
	write_byte( 5 )// line width in 0.1's
	write_byte( 60 )// noise amplitude in 0.01's
	new r,b;
	if(cs_get_user_team(id) == CS_TEAM_CT)
		b = 255;
	else if(cs_get_user_team(id) == CS_TEAM_T)
		r = 255;
	write_byte( r );// Red
	write_byte(0 );// Green
	write_byte( b );// Blue
	write_byte( 255 );// brightness
	write_byte( 0 );// scroll speed in 0.1's
	message_end( );
	set_task( 1.5, "TeamBeam", id + TeamBeam_Task );
	return 0;
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


stock st_strip_user_weapons(client)
{
        new ent = create_entity( "player_weaponstrip" );       
        if ( !pev_valid( ent ) )
                return;
 
        dllfunc( DLLFunc_Spawn, ent );
        dllfunc( DLLFunc_Use, ent, client );
        engfunc( EngFunc_RemoveEntity, ent );
 
        return;
} 

stock get_name(index)
{
	new szName[33];
	get_user_name(index,szName,charsmax(szName));
	return szName;
}

stock BaseRules(index)
{
	iRule[index][ENEMY] = 0;
	iRule[index][BHOP] = true;
	iRule[index][DUCK] = true;
	iRule[index][JUMP] = true;
	
	return 1;
}
stock BaseWarRules(index)
{
	wRule[index][WEAPON] = 0;
	wRule[index][HEALTH] = 100;
	wRule[index][HEADSHOT] = false;
	wRule[index][ZOOM] = true;
	wRule[index][KNIFE] = false;
	
	return 1;
}
