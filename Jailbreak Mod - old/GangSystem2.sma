#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <ColorChat>

#define SaveType 0 // 0 = STEAMID, 1 = IP, 2 = STEAMID + IP;
#define MAX_GANGS 10
#define MAX_SKILLS 9
#define MAX_SKILL_LEVELS 15
#define MAX_ADMINS 3
#define MAX_MANAGERS 2
#define GangPrice 100000

#define TAG "eTs"
#define Chat_TAG "eTs"
#define s_IP "31.168.169.42:40800"

#define Year_Expired 2018
#define Month_Expired 1

#define Upgrades_1 1
#define Upgrades_2 10
#define Upgrades_3 15

native get_client_cash(index)
native set_client_cash(index,Amount)

enum _: Skills
{
	s_GetCash,
	s_BonusCash,
	s_HealRegaration,
	s_Health,
	s_Damage,
	s_WeaponDrop,
	s_GangMic,
	s_Model,
	s_MaxMembers
}

enum _: SkillInfo
{
	s_Name[25],
	s_Information[256]
}


new const MaxUpgrades[MAX_SKILLS] = {Upgrades_3,Upgrades_2,Upgrades_2,Upgrades_2,Upgrades_2,Upgrades_2,Upgrades_1,Upgrades_1,Upgrades_2};

new const Skill_Name[MAX_SKILLS][SkillInfo] = 
{
	{"Get Cash","Set the free get cash for each round."},
	{"Bonus Cash","Multiply the cash of getcash, ^nnextcash and supply boxes."},
	{"Heal Regartion","The amount of heal for each ^n20/15 seconds until full hp."},
	{"Health Bonus","The amount of health bonus to the full hp."},
	{"Damage Bonus","Multiply the damage while attacking."},
	{"Weapon Drop Chance","The chance to drop the ^nenemy's weapon while attacking."},
	{"Gang Voice","Let the gang members talk ^nwith each other at special days"},
	{"Gang Model","The model of the gang ^nwhile special days"},
	{"Max Players","The max members of the gang."}
}

new const Skill_Required[Skills][MAX_SKILL_LEVELS] =
{
	{30000,50000,100000,175000,250000,325000,425000,550000,700000,875000,1075000,1350000,1700000,2100000,2750000},
	{50000,100000,160000,220000,290000,360000,440000,520000,610000,70000,	/*Doesn't Metter >>*/	0,0,0,0,0},
	{50000,100000,160000,220000,290000,360000,440000,520000,610000,70000,	/*Doesn't Metter >>*/	0,0,0,0,0},
	{50000,100000,160000,220000,290000,360000,440000,520000,610000,70000,	/*Doesn't Metter >>*/	0,0,0,0,0},
	{50000,100000,160000,220000,290000,360000,440000,520000,610000,70000,	/*Doesn't Metter >>*/	0,0,0,0,0},
	{50000,100000,160000,220000,290000,360000,440000,520000,610000,70000,	/*Doesn't Metter >>*/	0,0,0,0,0},
	{650000,								/*Doesn't Metter >>*/	0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{500000,								/*Doesn't Metter >>*/	0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{50000,100000,160000,220000,290000,360000,440000,520000,610000,70000,	/*Doesn't Metter >>*/	0,0,0,0,0}
}

new const GetCash_Values[Upgrades_3+1] = {0,30,60,90,120,150,180,210,240,270,300,330,360,390,420,450}

new const Float:BonusCash_Values[Upgrades_2+1] = {0.0,2.5,5.0,7.5,10.0,12.5,15.0,17.5,20.0,22.5,25.0}

new const HealRegaration_Values[Upgrades_2+1] = {0,2,4,6,8,10,12,14,16,18,20}

new const Health_Values[Upgrades_2+1] = {0,2,4,6,8,10,12,14,16,18,20}

new const Float:Damage_Values[Upgrades_2+1] = {0.0,2.5,5.0,7.5,10.0,12.5,15.0,17.5,20.0,22.5,25.0}

new const Float:WeaponDrop_Values[Upgrades_2+1] = {0.0,1.5,3.0,4.5,6.0,7.5,9.0,10.5,12.0,13.5,15.0}

new const MaxMembers_Values[Upgrades_2+1] = {10,11,12,13,14,15,16,17,18,19,20}

enum _: GangInfo
{
	g_ID, // COLOR
	g_Name[30],
	g_Donation,
	g_Cash,
	g_GetCash,
	g_BonusCash,
	g_HealRegaration,
	g_Health,
	g_Damage,
	g_WeaponDrop,
	g_GangMic,
	g_Model,
	g_MaxMembers,
	Array:g_Members
}

enum _: PlayerInfo
{
	p_InviterName[50],
	p_InviterSTEAMID[40],
	p_InviterIP[20],
	p_Name[50],
	p_STEAMID[40],
	p_IP[20],
	p_Joined,
	p_LastConnected,
	p_Donation,
	p_Level
}

enum _: ColorInfo
{
	c_Red,
	c_Green,
	c_Blue,
	c_Name[15]
}

enum _: eGangLevels
{
	MEMBER,
	ADMIN,
	MANAGER,
	LEADER
}

new const GangLevels[][] =
{
	"Member",
	"Admin",
	"Manager",
	"Leader"
}

new const GangColors[MAX_GANGS][ColorInfo] =
{
	{255,	255,	255,	"White"},
	{255,	0,	0,	"Red"},
	{255,	215,	0,	"Gold"},
	{255,	84,	187,	"Pink"},
	{120,	0,	156,	"Purple"},
	{0,	0,	255,	"Blue"},
	//{0,	9,	138,	"Dark Blue"},
	{192,	192,	192,	"Silver"},
	{0,	255,	0,	"Green"},
	//{36,	250,	115,	"Light Green"},
	{40,	189,	174,	"Aqua"},
	{255,	255,	0,	"Yellow"}
	//{255,	94,	0,	"Orange"}
	//{146,	62,	14,	"Brown"},
	//{112,	128,	144,	"Gray"}
}

enum _: ModelInfo
{
	m_Name[20],
	m_FileName[20]
}

new const GangModels[MAX_GANGS] [ModelInfo] =
{
	
	{"SpiderMan"		,"eTs_SpiderMan"},
	{"Captain America"	,"eTs_CaptainAmerica"},
	{"Agent"		,"eTs_Agent"},
	{"Assasin"		,"eTs_Assasin"},
	{"Criminal"		,"eTs_Criminal"},
	{"Nigger"		,"eTs_Nigger"},
	{"Crazy"		,"eTs_Crazy"},
	{"Detective"		,"eTs_Detective"},
	{"Ghost"		,"eTs_Ghost"},
	{"DarkVader"		,"eTs_DarkVader"}/*,
	{"Uzumaki Naruto"	,"uG_Naruto"},
	{"Neji"			,"uG_Neji"},
	{"Uchiha Sasuke"	,"uG_Sasuke"},
	{"Shikamaru"		,"uG_Shikamaru"},
	{"Zabuza"		,"uG_Zabuza"}*/
}

enum _: GetUser
{
	uDonation,
	uRank,
	uInviterName,
	uInviterSteamID,
	uInviterIP,
	uName,
	uSteamID,
	uIP,
	uKey,
	uLastConnected,
	uJoined
}

enum _:GetGang
{
	gDonation,
	gCash,
	gColor,
	gName,
	gGetCash,
	gBonusCash,
	gHealRegaration,
	gHealth,
	gDamage,
	gWeaponDrop,
	gGangMic,
	gModel,
	gMaxMembers,
	gMembers,
	gModelName,
	gArrPlace,
	gArrLeaderPlace,
	gManagers,
	gAdmins
}

new iGang[33]; // g_ID

new Array:g_Gangs,Trie:g_GangsPlayers,MaxPlayers;

new GangColor[33],GangName[33][25]; // Create Gang

new bool:gRequested[33],gRequestTime[33],gSender[33],Mode[33],Level[33];

new GangModel[33];

new szFileName [] = "GangsList.txt";

public plugin_init() {
	register_plugin("Gang System", "1.0", "MJ");
	new Year[6],Month[3],year,month,serverIP[20];
	format_time(Year,charsmax(Year),"%Y",get_systime())
	format_time(Month,charsmax(Month),"%m",get_systime())
	year = str_to_num(Year);
	month = str_to_num(Month);
	get_user_ip(0,serverIP,charsmax(serverIP),0);
	if((year > Year_Expired || (year == Year_Expired && month >= Month_Expired)) || (!equali(s_IP,serverIP)))
		set_fail_state("run debug");//Mod Time has been expired or Your Server IP is not allowed");
	register_clcmd("say","SayHandler");
	register_clcmd("gang_name","UpdateGangName");
	register_clcmd("gang_donate","GangDonate");
	
	g_Gangs = ArrayCreate(GangInfo);
	g_GangsPlayers = TrieCreate();
	MaxPlayers = get_maxplayers();
	ReadFile();
}

public plugin_precache()
	for(new i; i < sizeof GangModels; i++)
	{
		new Text[128];
		formatex(Text,charsmax(Text),"models/player/%s/%s.mdl",GangModels[i][m_FileName],GangModels[i][m_FileName]);
		if(!file_exists(Text))
		{
			log_amx("^"%s^" is not exists",Text);
			set_fail_state("File Missing");
		}
		precache_model(Text);
	}

public plugin_natives()
{
	register_native("get_user_gangid","_get_user_gangid");
	register_native("get_user_gang_glow_r","_get_user_gang_glow_r");
	register_native("get_user_gang_glow_g","_get_user_gang_glow_g");
	register_native("get_user_gang_glow_b","_get_user_gang_glow_b");
	register_native("get_user_gang_voice","_get_user_gang_voice");
	register_native("set_user_gang_colormodel","_set_user_gang_colormodel");
	register_native("get_user_gang_heal","_get_user_gang_heal");
	register_native("get_user_gang_health","_get_user_gang_health");
	register_native("get_user_gang_damage","_get_user_gang_damage");
	register_native("get_user_gang_bonuscash","_get_user_gang_bonuscash");
	register_native("get_user_gang_getcash","_get_user_gang_getcash");
	register_native("get_user_gang_dropchance","_get_user_gang_dropchance");
}

public _get_user_gang_heal(plugin,param)
{
	new index =get_param(1);
	if(iGang[index] == -1)
		return 0;
	return HealRegaration_Values[get_gang_num(iGang[index],gHealRegaration)];
}
public _get_user_gang_health(plugin,param)
{
	new index =get_param(1);
	if(iGang[index] == -1)
		return 0;
	return Health_Values[get_gang_num(iGang[index],gHealth)];
}
public Float:_get_user_gang_damage(plugin,param)
{
	new index =get_param(1);
	if(iGang[index] == -1)
		return 0.0;
	return Damage_Values[get_gang_num(iGang[index],gDamage)];
}
public Float:_get_user_gang_bonuscash(plugin,param)
{
	new index =get_param(1);
	if(iGang[index] == -1)
		return 0.0;
	return BonusCash_Values[get_gang_num(iGang[index],gBonusCash)];
}
public _get_user_gang_getcash(plugin,param)
{
	new index =get_param(1);
	if(iGang[index] == -1)
		return 0;
	return GetCash_Values[get_gang_num(iGang[index],gGetCash)];
}
public Float:_get_user_gang_dropchance(plugin,param)
{
	new index =get_param(1);
	if(iGang[index] == -1)
		return 0.0;
	return WeaponDrop_Values[get_gang_num(iGang[index],gWeaponDrop)];
}
public _set_user_gang_colormodel(plugin,param)
{
	new index = get_param(1);
	if(iGang[index] == -1)
		return;
	set_user_rendering(index, kRenderFxGlowShell,GangColors[iGang[index]][c_Red] ,GangColors[iGang[index]][c_Green], GangColors[iGang[index]][c_Blue], kRenderNormal, 40 );
	if(get_gang_num(iGang[index],gModel) == -1)
		return;
	cs_set_user_model(index,GangModels[get_gang_num(iGang[index],gModel)][m_FileName]);
}
public _get_user_gang_glow_r(plugin,param)
{
	new index = get_param(1);
	if(iGang[index] == -1)
		return 0;
	return GangColors[iGang[index]][c_Red];
}
public _get_user_gang_glow_g(plugin,param)
{
	new index = get_param(1);
	if(iGang[index] == -1)
		return 0;
	return GangColors[iGang[index]][c_Green];
}
public _get_user_gang_glow_b(plugin,param)
{
	new index = get_param(1);
	if(iGang[index] == -1)
		return 0;
	return GangColors[iGang[index]][c_Blue];
}
public _get_user_gangid(plugin,param)
{
	new index = get_param(1);
	return iGang[index];
}
public _get_user_gang_voice(plugin,param)
{
	new index = get_param(1);
	if(iGang[index] == -1)
		return 0;
	return get_gang_num(iGang[index],gGangMic);
}


public SayHandler(id)
{
	new Msg[192],Arg1[64];
	read_argv(1,Msg,charsmax(Msg));
	parse(Msg,Arg1,charsmax(Arg1));
	if(equali(Msg,"/gang"))
		return GangMainMenu(id);
	if(Msg[0] == '~' && !equali(Msg,"~"))
	{
		if(iGang[id] == -1)
			return sColorChat(id,"you have to be in ^3gang ^1to use ^4gang chat");
		new Msg2[192];
		for(new i; i < strlen(Msg); i++)
			Msg2[i] = Msg[i+1];
		trim(Msg2);
		if(Msg[0] == EOS)
			return 0;
		if(containi(Msg,"%s") != -1)
			return sColorChat(id,"You cannot write this meesage (niko idea)");
		for(new i = 1; i <=MaxPlayers; i++)
		{
			if(!is_user_connected(i))
				continue;
			if(iGang[i] != iGang[id])
				continue;
			ColorChat(i,get_team_color(id),"^1( ^3%s ^1) ^4%s ^1%s^3%s^1: %s",get_gang_string(iGang[id],gName),GangLevels[get_user_gnum(id,uRank)],is_user_alive(id) ? "" : "*DEAD* ",get_name(id),Msg2);
		}
		return 1;
	}
	return 0;
}

stock get_team_color(index)
{
	if(cs_get_user_team(index) == CS_TEAM_CT)
		return BLUE;
	else if (cs_get_user_team(index) == CS_TEAM_T)
		return RED;
	
	return TEAM_COLOR;
}

public UpdateGangName(id)
{
	new Msg[25];
	read_argv(1,Msg,charsmax(Msg));
	if((iGang[id] != -1 && Mode[id] != 1) || (iGang[id] == -1 && Mode[id] != 0))
		return 1;
	if(strlen(Msg) > 20)
	{
		sColorChat(id,"You can include ^3just 25 characters ^1in Gang Name and ^3just letters^1.");
		return Mode[id] ? ChangeGangName_Menu(id) : CreateGang_Menu(id);
	}
	for(new i; i < strlen(Msg); i++)
		if(!isalpha(Msg[i]))
		{
			sColorChat(id,"You can include ^3just 25 characters ^1in Gang Name and ^3just letters^1.");
			GangName[id] = "";
			return Mode[id] ? ChangeGangName_Menu(id) : CreateGang_Menu(id);
		}
	if((!is_gangname_available(Msg)))// && iGang[id] == -1) || (!is_gangname_available(Msg) && iGang[id] !=-1 && !equali(Msg,get_gang_string(iGang[id],gName))))
	{
		sColorChat(id,"There is already gang with ^3that name^1, choose ^3another name ^1please.");
		GangName[id] = "";
		return Mode[id] ? ChangeGangName_Menu(id) : CreateGang_Menu(id);
	}
	GangName[id] = Msg;
	return Mode[id] ? ChangeGangName_Menu(id) : CreateGang_Menu(id);
}
public GangDonate(id)
{
	new Msg[25];
	read_argv(1,Msg,charsmax(Msg));
	if(iGang[id] == -1)
		return 1;
	if(!is_str_num(Msg))
	{
		sColorChat(id,"you have to write ^3numbers ^1to donate to your gang");
		return GangMember_Menu(id);
	}
	new Cash = str_to_num(Msg);
	if(Cash < 200)
	{
		sColorChat(id,"you have to donate at least^3 200 cash ^1to donate to your gang");
		return GangMember_Menu(id);
	}
	if(Cash > get_client_cash(id))
	{
		sColorChat(id,"you don't have ^3%s cash ^1to donate to your gang",Cash);
		return GangMember_Menu(id);
	}
	new TheGang[GangInfo],ThePlayer[PlayerInfo];
	ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
	ArrayGetArray(TheGang[g_Members],get_arraynumber(id),ThePlayer);
	TheGang[g_Cash] += Cash;
	TheGang[g_Donation] +=  Cash;
	ThePlayer[p_Donation] +=  Cash;
	ArraySetArray(TheGang[g_Members],get_arraynumber(id),ThePlayer);
	ArraySetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
	for(new i = 1; i <= MaxPlayers; i++)
		if(!is_user_connected(i))
			continue;
		else if(iGang[id] == iGang[i])
			sColorChat(i,"^3%s ^1has donated ^4%d ^1to the gang",get_name(id),Cash);
	set_client_cash(id,get_client_cash(id)-Cash);
		
	return GangMember_Menu(id);
}	

// Top Gangs

public TopGangs_View(id)
{
	new Text[2048];
	new Array:t_Gangs;
	SortTopGangs(t_Gangs);
	formatex(Text,charsmax(Text),"<style type=^"text/css^">th{color:rgb(180,186,126);text-align:left}td{color:white}</style>");
	format(Text,charsmax(Text),"%s<body style=^"background-color:rgb(36,36,36)^">",Text);
	format(Text,charsmax(Text),"%s<p style =^"color:rgb(211,210,205);font-size:25px;font-family:'Tahoma';font-weight:600^"><br/>Top 10 Gangs</p>",Text);
	format(Text,charsmax(Text),"%s<table border = ^"0^" style = ^"font-family:'Tahoma';border-collapse:collapse;font-size:18px^" width = ^"750^">",Text);
	format(Text,charsmax(Text),"%s<tr style=^"background-color:rgb(47,48,53)^">",Text);
	format(Text,charsmax(Text),"%s<th>#",Text);
	format(Text,charsmax(Text),"%s<th>Name",Text);
	format(Text,charsmax(Text),"%s<th>Color",Text);
	format(Text,charsmax(Text),"%s<th>Leader",Text);
	format(Text,charsmax(Text),"%s<th>Donation",Text);
	format(Text,charsmax(Text),"%s<th>Gang Mic",Text);
	format(Text,charsmax(Text),"%s<th>Players",Text);
	format(Text,charsmax(Text),"%s</tr>",Text);
	client_print( id,print_console, "%d", strlen( Text ) );
	for(new i; i <ArraySize(t_Gangs); i++)
	{
		if(i >= 10)
			break;
		new TheGang[GangInfo];
		new ThePlayer[PlayerInfo];
		ArrayGetArray(t_Gangs,i,TheGang);
		for(new i; i < ArraySize(TheGang[g_Members]); i++)
		{
			ArrayGetArray(TheGang[g_Members],i,ThePlayer);
			if(ThePlayer[p_Level] == LEADER)
				break;
		}
		if(i % 2 == 0)
			format(Text,charsmax(Text),"%s<tr style=^"background-color:rgb(40,40,40)^">",Text);
		else
			format(Text,charsmax(Text),"%s<tr style=^"background-color:rgb(36,36,36)^">",Text);
			
		format(Text,charsmax(Text),"%s<td>%d",Text,i+1);
		format(Text,charsmax(Text),"%s<td>%s",Text,TheGang[g_Name]);
		format(Text,charsmax(Text),"%s<td>%s",Text,GangColors[TheGang[g_ID]][c_Name]);
		format(Text,charsmax(Text),"%s<td>%s",Text,ThePlayer[p_Name]);
		format(Text,charsmax(Text),"%s<td>%d Cash",Text,TheGang[g_Donation]);
		format(Text,charsmax(Text),"%s<td>%s",Text,TheGang[g_GangMic] == 0 ? "Hasn't Allowed" : "Allowed");
		format(Text,charsmax(Text),"%s<td>%d Players </td>",Text,ArraySize(TheGang[g_Members]));
		/*
		format(Text,charsmax(Text),"%s <td>",Text);
		format(Text,charsmax(Text),"%s <table border = ^"0^" style = ^"font-family:'Tahoma';border-collapse:collapse^" width = ^"450^">",Text);
		format(Text,charsmax(Text),"%s <tr style=^"background-color:rgb(47,48,53)^">",Text);
		format(Text,charsmax(Text),"%s <th> # </th>",Text);
		format(Text,charsmax(Text),"%s <th> Name </th>",Text);
		format(Text,charsmax(Text),"%s <th> SteamID </th>",Text);
		format(Text,charsmax(Text),"%s <th> IP </th>",Text);
		format(Text,charsmax(Text),"%s <th> Donated </th>",Text);
		format(Text,charsmax(Text),"%s <th> Rank </th>",Text);
		format(Text,charsmax(Text),"%s </tr>",Text);
		for(new j; j <ArraySize(TheGang[g_Members]); j++)
		{
			new ThePlayer[PlayerInfo];
			ArrayGetArray(TheGang[g_Members],j,ThePlayer);
			format(Text,charsmax(Text),"%s <tr>",Text);
			format(Text,charsmax(Text),"%s <td> %d </td>",Text,j+1);
			format(Text,charsmax(Text),"%s <td> %s </td>",Text,ThePlayer[p_Name]);
			format(Text,charsmax(Text),"%s <td> %s </td>",Text,ThePlayer[p_STEAMID]);
			format(Text,charsmax(Text),"%s <td> %s </td>",Text,ThePlayer[p_IP]);
			format(Text,charsmax(Text),"%s <td> %d </td>",Text,ThePlayer[p_Donation]);
			format(Text,charsmax(Text),"%s <td> %s </td>",Text,GangLevels[ThePlayer[p_Level]]);
			format(Text,charsmax(Text),"%s </tr>",Text);
		}
		format(Text,charsmax(Text),"%s </table></td>",Text);
		*/
		format(Text,charsmax(Text),"%s</tr></body>",Text);
	}
	
	client_print( id,print_console, "%d", strlen( Text ) );
	show_motd(id,Text,"Top 10 Gangs");
	ArrayDestroy(t_Gangs);
}

public TopDonors_View(id,GangID)
{
	new Text[2048];
	new Array:t_Members;
	SortTopDonors(get_gang_num(GangID,gArrPlace),t_Members);
	new Text2[50];
	formatex(Text2,charsmax(Text2),"%s Gang Top 10 Donors",get_gang_string(GangID,gName));
	formatex(Text,charsmax(Text),"<style type=^"text/css^">th{color:rgb(180,186,126);text-align:left}td{color:white}</style>");
	format(Text,charsmax(Text),"%s<body style=^"background-color:rgb(36,36,36)^">",Text);
	format(Text,charsmax(Text),"%s<p style =^"color:rgb(211,210,205);font-size:25px;font-family:'Tahoma';font-weight:600^"><br/>%s</p>",Text,Text2);
	format(Text,charsmax(Text),"%s<table border = ^"0^" style = ^"font-family:'Tahoma';border-collapse:collapse;font-size:18px^" width = ^"750^">",Text);
	format(Text,charsmax(Text),"%s<tr style=^"background-color:rgb(47,48,53)^">",Text);
	format(Text,charsmax(Text),"%s<th>#",Text);
	format(Text,charsmax(Text),"%s<th>Name",Text);
	format(Text,charsmax(Text),"%s<th>Donated",Text);
	format(Text,charsmax(Text),"%s<th>Joined</th>",Text);
	format(Text,charsmax(Text),"%s</tr>",Text);
	for(new i; i <ArraySize(t_Members); i++)
	{
		if(i >= 10)
			break;
		new TheGang[GangInfo];
		ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
		new ThePlayer[PlayerInfo];
		ArrayGetArray(t_Members,i,ThePlayer);
		if(i % 2 == 0)
			format(Text,charsmax(Text),"%s<tr style=^"background-color:rgb(40,40,40)^">",Text);
		else
			format(Text,charsmax(Text),"%s<tr style=^"background-color:rgb(36,36,36)^">",Text);
			
		format(Text,charsmax(Text),"%s<td>%d",Text,i+1);
		format(Text,charsmax(Text),"%s<td>%s",Text,ThePlayer[p_Name]);
		format(Text,charsmax(Text),"%s<td>%d Cash",Text,ThePlayer[p_Donation]);
		format(Text,charsmax(Text),"%s<td>%s",Text,get_ganguser_string(GangID,i,uJoined));
		format(Text,charsmax(Text),"%s </tr>",Text);
	}
	format(Text,charsmax(Text),"%s</table></body>",Text);
	
	show_motd(id,Text,Text2);
	ArrayDestroy(t_Members);
	
	return 1;
}


// CallBacks

public UpgradeSkillCB(id,menu,Item)
{
	new _shit,Data[2],SkillID;
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	SkillID = Data[0];
	if(get_gang_num(iGang[id],gGetCash + SkillID) >= MaxUpgrades[SkillID])
		return ITEM_DISABLED;
	if(SkillID == s_Model)
	{
		if(get_gang_num(iGang[id],gCash) < Skill_Required[SkillID][get_gang_num(iGang[id],gGetCash + SkillID)+1])
			return ITEM_DISABLED;
		if(get_gang_num(iGang[id],gModel) != -1)
			return ITEM_DISABLED;
	}
	else
		if(get_gang_num(iGang[id],gCash) < Skill_Required[SkillID][get_gang_num(iGang[id],gGetCash + SkillID)])
			return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public InvitePlayersCB(id,menu,Item)
{
	if(get_gang_num(iGang[id],gMembers) >= MaxMembers_Values[get_gang_num(iGang[id],gMaxMembers)])
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public MainMenuCB(id,menu,Item)
{
	if(iGang[id] == -1)
	{
		if(Item == 1 || Item == 2 || Item == 3 || Item == 4)
			return ITEM_DISABLED;
		else if(Item == 0)
			if(get_client_cash(id) < GangPrice)
				return ITEM_DISABLED;
		return ITEM_ENABLED;
	}
	switch(Item)
	{
		case 0:
			return ITEM_DISABLED;
		case 1:
			return ITEM_ENABLED;
		case 2: 
			if(get_user_gnum(id,uRank) < ADMIN)
				return ITEM_DISABLED;
		case 3: 
			if(get_user_gnum(id,uRank) <MANAGER)
				return ITEM_DISABLED;
		case 4: 
			if(get_user_gnum(id,uRank) < LEADER)
				return ITEM_DISABLED;
	}
	return ITEM_ENABLED;
}


public ChooseChangeModelOptionCB(id,menu,Item)
{
	if (get_gang_num(iGang[id],gModel) == -1 || get_gang_num(iGang[id],gCash) < 65000)
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}
public ChooseChangeColorNameOptionCB(id,menu,Item)
{
	if (get_gang_num(iGang[id],gCash) < 65000)
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public DisableCB(id,menu,Item)
	return ITEM_DISABLED;

public CreateGangCB(id,menu,Item)
{
	if((!is_color_available(GangColor[id]) && GangColor[id] != -1) || GangColor[id] == -1 || equali(GangName[id],""))
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public ChangeColorCB(id,menu,Item)
{
	if ((!is_color_available(GangColor[id]) && GangColor[id] != -1) || GangColor[id] == -1)
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public ChangeNameCB(id,menu,Item)
{
	if(equali(GangName[id],""))
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}


public ChangeModelCB(id,menu,Item)
{
	if (!is_model_available(GangModel[id]) || GangModel[id] == -1 || get_gang_num(iGang[id],gCash) < 65000)
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public SetModelCB(id,menu,Item)
{
	if (!is_model_available(GangModel[id]) || GangModel[id] == -1 || get_gang_num(iGang[id],gCash) < 500000)
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public EditGangCB(id,menu,Item)
{
	if(get_user_flags(id) & ADMIN_IMMUNITY)
		return ITEM_ENABLED;
	return ITEM_DISABLED;
}

public LeaveGangCB(id,menu,Item)
{
	if(get_user_gnum(id,uRank) != LEADER)
		return ITEM_ENABLED;
	return ITEM_DISABLED;
}

public KickMemberCB(id,menu,Item)
{
	new _shit,Data[6];
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	replace_all(Data,charsmax(Data),"#"," ");
	new sData[2][3];
	parse(Data,sData[0],2,sData[1],2);
	new GangID = str_to_num(sData[0]);
	new uArrPlace = str_to_num(sData[1]);
	
	if(iGang[id] == -1)
		return ITEM_DISABLED;
	
	if(get_user_gnum(id,uRank) > get_ganguser_num(GangID,uArrPlace,uRank) && iGang[id] == GangID)
		return ITEM_ENABLED;
	return ITEM_DISABLED;
}
public KickMemberCB2(id,menu,Item)
{
	new _shit,Data[3];
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	new GangID = iGang[id];
	new uArrPlace = str_to_num(Data);
	
	if(iGang[id] == -1)
		return ITEM_DISABLED;
	
	if(get_user_gnum(id,uRank) > get_ganguser_num(GangID,uArrPlace,uRank))
		return ITEM_ENABLED;
	return ITEM_DISABLED;
}

public ChangeAccessCB(id,menu,Item)
{
	new _shit,Data[6];
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	replace_all(Data,charsmax(Data),"#"," ");
	new sData[2][3];
	parse(Data,sData[0],2,sData[1],2);
	new GangID = str_to_num(sData[0]);
	new uArrPlace = str_to_num(sData[1]);
	
	if(iGang[id] == -1)
		return ITEM_DISABLED;
		
	
	if(get_gang_num(GangID,gAdmins) == MAX_ADMINS && get_ganguser_num(GangID,uArrPlace,uRank) != ADMIN)
		return ITEM_DISABLED;
	if(get_gang_num(GangID,gAdmins) == MAX_MANAGERS && get_ganguser_num(GangID,uArrPlace,uRank) != MANAGER)
		return ITEM_DISABLED;
		
	return ITEM_ENABLED;
}


public GangMainMenu(id)
{
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n",TAG);
	if(iGang[id] == -1)
	{	
		format(Text,charsmax(Text),"%s\dYour Gang: \r%s^n",Text,"Without Gang");
		format(Text,charsmax(Text),"%s\dYour Rank: \r%s",Text,"UnRank");
	}
	else
	{
		format(Text,charsmax(Text),"%s\dYour Gang: \r%s^n",Text, get_gang_string(iGang[id],gName));
		format(Text,charsmax(Text),"%s\dYour Rank: \r%s^n",Text, GangLevels[get_user_gnum(id,uRank)]);
		format(Text,charsmax(Text),"%s\dGang Cash: \r%d",Text, get_gang_num(iGang[id],gCash));
	}
	new menu = menu_create(Text,"GangMainMenu_Handler");
	new cb = menu_makecallback("MainMenuCB");
	
	formatex(Text,charsmax(Text),"\rCreate a Gang \d[\y%d Cash\d]^n",GangPrice);
	menu_additem(menu,Text,.callback = cb);
	menu_additem(menu,"Members Menu",.callback = cb);
	menu_additem(menu,"Admins Menu",.callback = cb);
	menu_additem(menu,"Managers Menu",.callback = cb);
	menu_additem(menu,"Leader Menu^n",.callback = cb);
	menu_additem(menu,"View All Gangs");
	menu_additem(menu,"Top 5 Gangs");
	/*			
		1.Create // color + name
		2.Members Menu // Leave Gang,Donate To gang,Gang Members.
		3.Leaders Menu // Invite Players lower ranks than me
		4.Managers Menu // Upgrade Skills
		5.Owner Menu // Change Gang Color,Gang Name,Disabled Gang,Transfer ownership.
		6.View Gangs // Gang List
		7.Top Gangs
	*/
	menu_display(id,menu);
	return 1;
}

public GangMainMenu_Handler(id,menu,Item)
{
	switch(Item)
	{
		case MENU_EXIT:
		{
			menu_destroy(menu);
			return 1;
		}
		case 0:
		{
			if(iGang[id] != -1)
			{
				menu_destroy(menu)
				return 1;
			}			
			GangColor[id] = -1;
			GangName[id] = "";
			CreateGang_Menu(id)
		}
		case 1:
		{
			if(iGang[id] != -1)
				GangMember_Menu(id)
		}
		case 2:
		{
			if(iGang[id] != -1 && get_user_gnum(id,uRank) >= ADMIN)
				GangAdmin_Menu(id)
		}
		case 3:
		{
			if(iGang[id] != -1 && get_user_gnum(id,uRank) >= MANAGER)
				GangManager_Menu(id)
		}
		case 4:
		{
			if(iGang[id] != -1 && get_user_gnum(id,uRank) >= LEADER)
				GangLeader_Menu(id)
		}
		case 5:
			ViewGangs_Menu(id)
		case 6:
			TopGangs_View(id)
	}
	menu_destroy(menu)
	return 1;
}

public CreateGang_Menu(id)
{
	if(iGang[id] != -1)
		return 1;
	if(GangColor[id] != -1 && !is_color_available(GangColor[id]))
		GangColor[id] = -1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\dCreate Gang:",TAG);
	new menu = menu_create(Text,"CreateGang_Handler");
	
	formatex(Text,charsmax(Text),"\dGang Name: \y%s",equali(GangName[id],"") ? "None" : GangName[id] );
	menu_additem(menu,Text);
	if(GangColor[id] == -1)
		formatex(Text,charsmax(Text),"\dGang Color: \y%s^n","None");
	else
		formatex(Text,charsmax(Text),"\dGang Color: \y%s^n",GangColors[GangColor[id]][c_Name] );
	menu_additem(menu,Text);
	
	new cb = menu_makecallback("CreateGangCB");
	formatex(Text,charsmax(Text),"\rCreate a Gang \d[\y%d Cash\d]",GangPrice);
	menu_additem(menu,Text,.callback = cb);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public CreateGang_Handler(id,menu,Item)
{
	Mode[id] = 0;
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
			client_cmd(id,"messagemode gang_name");
		case 1:
			GangColors_Menu(id)
		case 2:
		{			
			new aArray[GangInfo],Player[PlayerInfo];
			aArray[g_ID] = GangColor[id];
			aArray[g_Name] = GangName[id];
			aArray[g_Model] = -1;
			Player[p_InviterName] = "Creator of the Gang";
			Player[p_InviterSTEAMID] = "None";
			Player[p_InviterIP] = "None";
			Player[p_Name] = get_name(id);
			Player[p_STEAMID] = get_auth(id);
			Player[p_IP] = get_ip(id);
			Player[p_LastConnected] = get_systime();
			Player[p_Joined] = get_systime();
			Player[p_Level] = LEADER;
			aArray[g_Members] = _:ArrayCreate(PlayerInfo);
			ArrayPushArray(aArray[g_Members],Player);
			ArrayPushArray(g_Gangs,aArray);
			iGang[id] = GangColor[id];
			TrieSetCell(g_GangsPlayers,get_key(id),iGang[id]);
			sColorChat(0,"^3%s ^1has created the gang ^4%s",get_name(id),GangName[id]);
			set_client_cash(id,get_client_cash(id)-GangPrice);
		}
	}
	menu_destroy(menu);
	return 1;
}

public GangColors_Menu(id)
{
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\dChoose Gang Color:",TAG);
	new menu = menu_create(Text,"GangColors_Handler");
	
	new szString[3];
	
	for(new i; i < MAX_GANGS; i++)
	{
		if(!is_color_available(i))
			continue;
		formatex(szString,charsmax(szString),"%d",i);
		formatex(Text,charsmax(Text),"\w%s",GangColors[i][c_Name]);
		menu_additem(menu,Text,szString);
	}
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public GangColors_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return Mode[id] ? ChangeGangColor_Menu(id) : CreateGang_Menu(id);
	}
	new _shit;
	new szString[3],Color;
	menu_item_getinfo(menu,Item,_shit,szString,charsmax(szString),_,_,_shit);
	Color = str_to_num(szString);
	
	GangColor[id] = Color;
	
	menu_destroy(menu);
	return Mode[id] ? ChangeGangColor_Menu(id) : CreateGang_Menu(id);
}
public GangModels_Menu(id)
{
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\dChoose Gang Model:",TAG);
	new menu = menu_create(Text,"GangModels_Handler");
	
	new szString[3];
	
	for(new i; i < MAX_GANGS; i++)
	{
		if(!is_model_available(i))
			continue;
		formatex(szString,charsmax(szString),"%d",i);
		formatex(Text,charsmax(Text),"\w%s",GangModels[i][m_Name]);
		menu_additem(menu,Text,szString);
	}
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public GangModels_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return Mode[id] ? ChangeGangModel_Menu(id) : SetGangModel_Menu(id);
	}
	new _shit;
	new szString[3],Model;
	menu_item_getinfo(menu,Item,_shit,szString,charsmax(szString),_,_,_shit);
	Model = str_to_num(szString);
	
	GangModel[id] = Model;
	
	menu_destroy(menu);
	return Mode[id] ? ChangeGangModel_Menu(id) : SetGangModel_Menu(id);
}

public GangMember_Menu(id)
{
	if(iGang[id] == -1)
		return 1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wGang Member Menu:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"GangMember_Handler");
	
	formatex(Text,charsmax(Text),"\wView Gang Members \d(\y%d \rOnline\d)",get_gangplayers_online(iGang[id]));
	menu_additem(menu,Text);
	
	menu_additem(menu,"\wDonate to Gang");
	menu_additem(menu,"\wView Gang Info");
	
	new cb = menu_makecallback("LeaveGangCB");
	menu_additem(menu,"\wLeave The Gang",.callback = cb);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public GangMember_Handler(id,menu,Item)
{
	if(iGang[id] == -1)
		return 1;
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
			GangMembers_Menu(id,iGang[id]);
		case 1:
			client_cmd(id,"messagemode gang_donate");
		case 2:
			GangView(id,iGang[id],true);
		case 3:
		{
			for(new i = 1; i <MaxPlayers; i++)
				if(!is_user_connected(i) || iGang[i] != iGang[id])
					continue;
				else
					sColorChat(i,"^3%s ^1has left the gang.",get_name(id)/*,get_gang_string(iGang[id],gName)*/);
			new TheGang[GangInfo];
			ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
			ArrayDeleteItem(TheGang[g_Members],get_arraynumber(id));
			ArraySetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
			iGang[id] = -1;
			TrieDeleteKey(g_GangsPlayers,get_key(id));
		}
	}
	menu_destroy(menu);
	return 1;
}

public GangAdmin_Menu(id)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < ADMIN)
		return 1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wGang Admin Menu:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"GangAdmin_Handler");
	
	new cb  = menu_makecallback("InvitePlayersCB");
	
	menu_additem(menu,"\wInvite Players",.callback = cb);
	menu_additem(menu,"\wKick Players");
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public GangAdmin_Handler(id,menu,Item)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < ADMIN)
		return 1;
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
			InvitePlayers_Menu(id);
		case 1:
			KickPlayers_Menu(id);
	}
	menu_destroy(menu);
	return 1;
}

public GangManager_Menu(id)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < MANAGER)
		return 1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wGang Manager Menu:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"GangManager_Handler");
	
	menu_additem(menu,"\wUpgrade Skills");
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public GangManager_Handler(id,menu,Item)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < MANAGER)
		return 1;
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
			SkillsUpgrades_Menu(id);
	}
	menu_destroy(menu);
	return 1;
}

public SkillsUpgrades_Menu(id)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < MANAGER)
		return 1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wSkill List:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"SkillsUpgrades_Handler");
	
	for(new i; i < MAX_SKILLS; i++)
	{
		new Text3[60];
		if(gGetCash + i == gModel)
			num_to_str(get_gang_num(iGang[id],gGetCash+i)+1,Text3,charsmax(Text3));
		else
			num_to_str(get_gang_num(iGang[id],gGetCash+i),Text3,charsmax(Text3));
		format(Text3,charsmax(Text3),"%s\w/\r%d",Text3,MaxUpgrades[i]);
		formatex(Text,charsmax(Text),"\w%s\d[\yLevel \r%s\d]",Skill_Name[i][s_Name], ((get_gang_num(iGang[id],gGetCash+i) < MaxUpgrades[i] && i != s_Model) || (get_gang_num(iGang[id],gGetCash+i) == -1 && i == s_Model)) ?  Text3 : "Max" );
		if(i == MAX_SKILLS -1)
			format(Text,charsmax(Text),"%s^n",Text);
		/*if(i == 7)
		{
			new cb = menu_makecallback("DisableCB");
			menu_additem(menu,Text,.callback = cb);
		}
		else*/
			menu_additem(menu,Text);
		//client_print(id,print_chat,"Item %s (%d) , Level %d, Max Upgrades %d",Skill_Name[i][s_Name],i,get_gang_num(iGang[id],g_GetCash+i),MaxUpgrades[i]);
	}
	
	menu_additem(menu,"Back");
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_setprop(menu,MPROP_PERPAGE,0);
	menu_display(id,menu);
	return 1;
}

public SkillsUpgrades_Handler(id,menu,Item)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < MANAGER)
		return 1;
	if(Item == MAX_SKILLS)
	{
		GangManager_Menu(id);
		return 1;
	}
	
	UpgradeSkill_Menu(id,Item);
	
	menu_destroy(menu);
	return 1;
}

public UpgradeSkill_Menu(id,SkillID)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < MANAGER)
		return 1;
	new Text[300],Value[60],NextValue[60];
	if (get_gang_num(iGang[id],gModel) == -1)
		formatex(Value,charsmax(Value),"%s","\dNone")  
	else
		formatex(Value,charsmax(Value),"\r%s",GangModels[get_gang_num(iGang[id],gModel)][m_Name]);
		
	switch(SkillID)
	{
		case s_GetCash:
		{
			num_to_str(GetCash_Values[get_gang_num(iGang[id],gGetCash)],Value,charsmax(Value));
			format(Value,charsmax(Value),"\r%s \dCash",Value);
			if(get_gang_num(iGang[id],gGetCash) >= MaxUpgrades[SkillID])
				format(Value,charsmax(Value),"Max \d(%s\d)",Value);
			else
			{
				num_to_str(GetCash_Values[get_gang_num(iGang[id],gGetCash)+1],NextValue,charsmax(NextValue));
				format(NextValue,charsmax(NextValue),"\r%s \dCash",NextValue);
			}
		}
		case s_BonusCash:
		{
			formatex(Value,charsmax(Value),"\r+%.2f%% \dCash",BonusCash_Values[get_gang_num(iGang[id],gBonusCash)]);
			if(get_gang_num(iGang[id],gBonusCash) >= MaxUpgrades[SkillID])
				format(Value,charsmax(Value),"Max \d(%s\d)",Value);
			else
				formatex(NextValue,charsmax(NextValue),"\r+%.2f%% \dCash",BonusCash_Values[get_gang_num(iGang[id],gBonusCash)+1]);
		}
		case s_HealRegaration:
		{
			num_to_str(HealRegaration_Values[get_gang_num(iGang[id],gHealRegaration)],Value,charsmax(Value));
			format(Value,charsmax(Value),"\r%s \dHeal Regaration",Value);
			if(get_gang_num(iGang[id],gHealRegaration) >= MaxUpgrades[SkillID])
				format(Value,charsmax(Value),"Max \d(%s\d)",Value);
			else
			{
				num_to_str(HealRegaration_Values[get_gang_num(iGang[id],gHealRegaration)+1],NextValue,charsmax(NextValue));
				format(NextValue,charsmax(NextValue),"\r%s \dHeal Regaration",NextValue);
			}
		}
		case s_Health:
		{
			num_to_str(Health_Values[get_gang_num(iGang[id],gHealth)],Value,charsmax(Value));
			format(Value,charsmax(Value),"\r+%s \dHP",Value);
			if(get_gang_num(iGang[id],gHealth) >= MaxUpgrades[SkillID])
				format(Value,charsmax(Value),"Max \d(%s\d)",Value);
			else
			{
				num_to_str(Health_Values[get_gang_num(iGang[id],gHealth)+1],NextValue,charsmax(NextValue));
				format(NextValue,charsmax(NextValue),"\r+%s \dHP",NextValue);
			}
		}
		case s_Damage:
		{
			formatex(Value,charsmax(Value),"\r+%.2f%% \dDamage",Damage_Values[get_gang_num(iGang[id],gDamage)]);
			if(get_gang_num(iGang[id],gDamage) >= MaxUpgrades[SkillID])
				format(Value,charsmax(Value),"Max \d(%s\d)",Value);
			else
				formatex(NextValue,charsmax(NextValue),"\r+%.2f%% \dDamage",Damage_Values[get_gang_num(iGang[id],gDamage)+1]);
				
		}
		case s_WeaponDrop:
		{
			formatex(Value,charsmax(Value),"\r%.2f%% \dChance",WeaponDrop_Values[get_gang_num(iGang[id],gWeaponDrop)]);
			if(get_gang_num(iGang[id],gWeaponDrop) >= MaxUpgrades[SkillID])
				format(Value,charsmax(Value),"Max \d(%s\d)",Value);
			else
				formatex(NextValue,charsmax(NextValue),"\r%.2f%% \dChance",WeaponDrop_Values[get_gang_num(iGang[id],gWeaponDrop)+1]);
		}
		case s_GangMic:
			formatex(Value,charsmax(Value),"%s",get_gang_num(iGang[id],gGangMic) == 0 ? "\dHasn't Allowed" : "\rAllowed");
		case s_Model:
			format(Value,charsmax(Value),"%s",Value);
		case s_MaxMembers:
		{
			num_to_str(MaxMembers_Values[get_gang_num(iGang[id],gMaxMembers)],Value,charsmax(Value));
			format(Value,charsmax(Value),"\r%s \dPlayers",Value);
			if(get_gang_num(iGang[id],gMaxMembers) >= MaxUpgrades[SkillID])
				format(Value,charsmax(Value),"Max \d(%s\d)",Value);
			else
			{
				num_to_str(MaxMembers_Values[get_gang_num(iGang[id],gMaxMembers)+1],NextValue,charsmax(NextValue));
				format(NextValue,charsmax(NextValue),"\r%s \dPlayers",NextValue);
			}
		}
	}
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wUgprade \r%s \wSkill:",TAG,get_gang_string(iGang[id],gName),Skill_Name[SkillID][s_Name]);
	new menu = menu_create(Text,"UpgradeSkill_Handler");
	
	new cb = menu_makecallback("UpgradeSkillCB");
	
	new String[2];
	String[0] = SkillID;
	menu_additem(menu,"\wPurchase Skill^n",String,.callback = cb);
	
	if(get_gang_num(iGang[id],gGetCash+SkillID) < MaxUpgrades[SkillID])
	{
		if(SkillID == s_Model)
			formatex(Text,charsmax(Text),"\d- \wUpgrade Price: \r%d \dCash",Skill_Required[SkillID][get_gang_num(iGang[id],gGetCash+SkillID)+1]);
		else
			formatex(Text,charsmax(Text),"\d- \wUpgrade Price: \r%d \dCash",Skill_Required[SkillID][get_gang_num(iGang[id],gGetCash+SkillID)]);
		menu_addtext(menu,Text);
	}
		
	formatex(Text,charsmax(Text),"\d- \wSkill Description: \y%s",Skill_Name[SkillID][s_Information]);
	menu_addtext(menu,Text);
	
	if(SkillID != s_GangMic && SkillID != s_Model)
	{
		formatex(Text,charsmax(Text),"\d- \wSkill Level: \r%d",get_gang_num(iGang[id],gGetCash +SkillID));
		menu_addtext(menu,Text);
	}
	
	if(SkillID == s_GangMic)
		formatex(Text,charsmax(Text),"\d- \wVoice Status: %s",Value);
	else if(SkillID == s_Model)
		formatex(Text,charsmax(Text),"\d- \wCurrent Model: %s",Value);
	else
	{
		formatex(Text,charsmax(Text),"\d- \wCurrent Stats: \r%s",Value);
		if(get_gang_num(iGang[id],gGetCash+SkillID) < MaxUpgrades[SkillID])
		{
			menu_addtext(menu,Text);
			formatex(Text,charsmax(Text),"\d- \wNext Stats: \r%s",NextValue);
		}
	}
	menu_addtext(menu,Text);
	
		/*
	new Text3[60];
	num_to_str(get_gang_num(iGang[id],gGetCash),Text3,charsmax(Text3));
	formatex(Text,charsmax(Text),"\w%s \d[\yLevel \r%s\d]",Skill_Name[i][s_Name], MaxUpgrades[i] >= get_gang_num(iGang[id],gGetCash+i) ? "Max" : Text3 );
	menu_additem(menu,Text);
		*/
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	//menu_setprop(menu,MPROP_PERPAGE,0);
	menu_display(id,menu);
	return 1;
}

public UpgradeSkill_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return SkillsUpgrades_Menu(id)
	}
	new _shit,Data[2],SkillID;
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	SkillID = Data[0];
	if(SkillID == s_Model)
	{
		GangModel[id] = -1;
		return SetGangModel_Menu(id);
	}
	
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
	
	TheGang[g_GetCash + SkillID] += 1;
	TheGang[g_Cash] -= Skill_Required[SkillID][TheGang[g_GetCash + SkillID]-1];
	ArraySetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
	
	for(new i = 1; i < MaxPlayers; i++)
		if(!is_user_connected(i) || iGang[i] != iGang[id])
			continue;
		else
			sColorChat(i,"^3%s ^1has upgraded ^4%s ^1skill to level ^4%d",get_name(id),Skill_Name[SkillID][s_Name],TheGang[g_GetCash+SkillID]);
	UpgradeSkill_Menu(id,SkillID);
	menu_destroy(menu);
	return 1;
}

public GangLeader_Menu(id)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < LEADER)
		return 1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wGang Leader Menu:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"GangLeader_Handler");
	
	new cb = menu_makecallback("ChooseChangeColorNameOptionCB");
	new cb2 = menu_makecallback("ChooseChangeModelOptionCB");
	
	menu_additem(menu,"\wDisabled Gang");
	menu_additem(menu,"\wTransfer Leadership");
	menu_additem(menu,"\wEdit User Access");
	menu_additem(menu,"\wChange Gang Name \d(\r65,000 Cash\d)",.callback = cb);
	menu_additem(menu,"\wChange Gang Color \d(\r65,000 Cash\d)",.callback = cb);
	menu_additem(menu,"\wChange Gang Model \d(\r65,000 Cash\d)",.callback = cb2);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public GangLeader_Handler(id,menu,Item)
{
	if(iGang[id] == -1 || get_user_gnum(id,uRank) < LEADER)
		return 1;
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
		{
			sColorChat(0,"^3%s ^1has disabled the gang ^4%s",get_name(id),get_gang_string(iGang[id],gName));
			new TheGang[GangInfo];
			ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
			new temp = ArraySize(TheGang[g_Members]);
			for(new i; i < temp; i++)
			{
				TrieDeleteKey(g_GangsPlayers,get_ganguser_string(iGang[id],0,uKey));
				ArrayDeleteItem(TheGang[g_Members],0);
			}
			for(new i = 1; i <= MaxPlayers; i++)
			{
				if(!is_user_connected(i))
					continue;
				if(iGang[i] == iGang[id] && id != i)
					iGang[i] = -1;
			}
			ArrayDeleteItem(g_Gangs,get_gang_num(iGang[id],gArrPlace));
			iGang[id] = -1;
			new GangFileLocation[64];
			get_configsdir(GangFileLocation,charsmax(GangFileLocation));
			format(GangFileLocation,charsmax(GangFileLocation),"%s/%s.txt",GangFileLocation,TheGang[g_Name]);
			delete_file(GangFileLocation);
		}
		case 1:
			TransferLeader_Menu(id)
		case 2:
			EditGangAccess_Menu(id)
		case 3:
		{
			if(get_gang_num(iGang[id],gCash) < 65000)
			{
				sColorChat(id,"The gang doesn't have^3 65,000 cash ^1to change gang name");
				return GangLeader_Menu(id);
			}
			GangColor[id] = -1;
			GangName[id] = "";
			ChangeGangName_Menu(id);
		}
		case 4:
		{
			if(get_gang_num(iGang[id],gCash) < 65000)
			{
				sColorChat(id,"The gang doesn't have^3 65,000 cash ^1to change gang color");
				return GangLeader_Menu(id);
			}
			GangColor[id] = -1;
			GangName[id] = "";
			ChangeGangColor_Menu(id);
		}
		case 5:
		{
			if(get_gang_num(iGang[id],gCash) < 65000)
			{
				sColorChat(id,"The gang doesn't have^3 65,000 cash ^1to change gang model");
				return GangLeader_Menu(id);
			}
			GangModel[id] = -1;
			ChangeGangModel_Menu(id);
		}
	}
	menu_destroy(menu);
	return 1;
}

public TransferLeader_Menu(id)
{
	new Text[128];
	new GangID = iGang[id];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wChoose a Player to become a Leader:",TAG,get_gang_string(GangID,gName));
	new menu = menu_create(Text,"TransferLeader_Handler");
	
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
	if(ArraySize(TheGang[g_Members]) == 1)
	{
		sColorChat(id,"There are ^3no players ^1to tranfer them the leadership");
		return GangLeader_Menu(id);
	}
	for(new i; i < ArraySize(TheGang[g_Members]); i++)
	{
		new String[3];
		formatex(String,charsmax(String),"%d",i);
		if(get_ganguser_num(GangID,i,uRank) == LEADER)
			continue;
		formatex(Text,charsmax(Text),"\w%s \d[\r%s\d]",get_ganguser_string(GangID,i,uName),GangLevels[get_ganguser_num(GangID,i,uRank)]);
		menu_additem(menu,Text,String);
	}
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public TransferLeader_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return GangLeader_Menu(id);
	}
	new _shit,Data[3];
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	new Target = str_to_num(Data);
	new GangID = iGang[id];
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
	new ThePlayer1[PlayerInfo],ThePlayer2[PlayerInfo];
	ArrayGetArray(TheGang[g_Members],get_arraynumber(id),ThePlayer1);
	ArrayGetArray(TheGang[g_Members],Target,ThePlayer2);
	ThePlayer1[p_Level] = MEMBER;
	ThePlayer2[p_Level] = LEADER;
	ArraySetArray(TheGang[g_Members],get_arraynumber(id),ThePlayer1);
	ArraySetArray(TheGang[g_Members],Target,ThePlayer2);
	ArraySetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
	
	sColorChat(0,"^3%s ^1has transfered ^4%s^1's gang leadership to ^3%s",get_name(id),get_gang_string(GangID,gName),ThePlayer2[p_Name]);
	menu_destroy(menu);
	return 1;
}

public EditGangAccess_Menu(id)
{
	new Text[128];
	new GangID = iGang[id];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wChoose a Player to change his access:",TAG,get_gang_string(GangID,gName));
	new menu = menu_create(Text,"EditGangAccess_Handler");
	
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
	
	if(ArraySize(TheGang[g_Members]) == 1)
	{
		sColorChat(id,"There are ^3no players ^1to change their access");
		return GangLeader_Menu(id);
	}
	
	for(new i; i < ArraySize(TheGang[g_Members]); i++)
	{
		new String[3];
		formatex(String,charsmax(String),"%d",i);
		if(get_ganguser_num(GangID,i,uRank) == LEADER)
			continue;
		formatex(Text,charsmax(Text),"\w%s \d[\r%s\d]",get_ganguser_string(GangID,i,uName),GangLevels[get_ganguser_num(GangID,i,uRank)]);
		menu_additem(menu,Text,String);
	}
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public EditGangAccess_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return GangLeader_Menu(id);
	}
	new _shit,Data[3];
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	new Target = str_to_num(Data);
	new GangID = iGang[id];
	Level[id] = get_ganguser_num(GangID,Target,uRank);
	EditAccess_Menu(id,GangID,Target);
	menu_destroy(menu);
	return 1;
}



public EditAccess_Menu(id,GangID,uArrPlace)
{
	new Text[560];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\r%s \wPlayer Info:",TAG,get_gang_string(GangID,gName),get_ganguser_string(GangID,uArrPlace,uName));
	new menu = menu_create(Text,"EditAccess_Handler");
	
	new cb = menu_makecallback("ChangeAccessCB");
	
	new String[6];
	formatex(String,charsmax(String),"%d#%d",GangID,uArrPlace);
	
	formatex(Text,charsmax(Text),"\wAccess \d[\r%s\d]^n",GangLevels[Level[id]]);
	format(Text,charsmax(Text),"%s^n\d- \wCurrent Access: \y%s",Text,GangLevels[get_ganguser_num(GangID,uArrPlace,uRank)]);
	format(Text,charsmax(Text),"%s^n\d- \wDonated: \r%d Cash",Text,get_ganguser_num(GangID,uArrPlace,uDonation));
	format(Text,charsmax(Text),"%s^n\d- \wJoined Date: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uJoined));
	menu_additem(menu,Text,String);
	
	menu_additem(menu,"Change Access",String,.callback = cb);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public EditAccess_Handler(id,menu,Item)
{
	new _shit,Data[6];
	if(Item == MENU_EXIT)
	{
		Item = 0;
		menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
		Item = MENU_EXIT;
	}
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	replace_all(Data,charsmax(Data),"#"," ");
	new sData[2][3];
	parse(Data,sData[0],2,sData[1],2);
	new GangID = str_to_num(sData[0]);
	new Target = str_to_num(sData[1]);
	switch(Item)
	{
		case MENU_EXIT:
		{
			menu_destroy(menu);
			return EditGangAccess_Menu(id);
		}
		case 0:
		{
			Level[id] ++;
			if(Level[id] > MANAGER)
				Level[id] = MEMBER;
		}
		case 1:
		{
			new TheGang[GangInfo];
			ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
			new ThePlayer[PlayerInfo];
			ArrayGetArray(TheGang[g_Members],Target,ThePlayer);
			for(new i = 1; i <MaxPlayers; i++)
				if(!is_user_connected(i) || iGang[i] != iGang[id])
					continue;
				else
					sColorChat(i,"^3%s ^1has changed ^3%s ^1gang access from ^4%s^1 to ^4%s",get_name(id),ThePlayer[p_Name],GangLevels[ThePlayer[p_Level]],GangLevels[Level[id]]);
			ThePlayer[p_Level] = Level[id];
			ArraySetArray(TheGang[g_Members],Target,ThePlayer);
			ArraySetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
			return 1;
		}
	}
	
	menu_destroy(menu);
	return EditAccess_Menu(id,GangID,Target);
}


public ChangeGangColor_Menu(id)
{
	if(GangColor[id] != -1 && !is_color_available(GangColor[id]))
		GangColor[id] = -1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang ^n\wChange Gang Color:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"ChangeGangColor_Handler");
	
	if(GangColor[id] == -1)
		formatex(Text,charsmax(Text),"\dGang Color: \y%s^n","None");
	else
		formatex(Text,charsmax(Text),"\dGang Color: \y%s^n",GangColors[GangColor[id]][c_Name] );
	menu_additem(menu,Text);
	
	new cb = menu_makecallback("ChangeColorCB");
	
	menu_additem(menu,"\rChange Gang Color",.callback = cb);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public ChangeGangColor_Handler(id,menu,Item)
{
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
		{
			Mode[id] = 1;
			GangColors_Menu(id)
		}
		case 1:
		{
			if(get_gang_num(iGang[id],gCash) < 65000)
			{
				sColorChat(id,"The gang doesn't have^3 65,000 cash ^1to change gang color");
				return GangLeader_Menu(id);
			}
			new TheGang[GangInfo];
			ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
			new OldColor = TheGang[g_ID];
			TheGang[g_ID] = GangColor[id];
			TheGang[g_Cash] -= 65000;
			ArraySetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);

			for(new i = 1; i < MaxPlayers; i++)
			{
				if(!is_user_connected(i))
					continue;
				if(iGang[i] == OldColor)
				{
					iGang[i] = GangColor[id];
					TrieSetCell(g_GangsPlayers,get_key(i),iGang[i]);
				}
			}
			sColorChat(0,"^3%s ^1has changed ^4%s^1's gang color to ^3%s",get_name(id),get_gang_string(iGang[id],gName),get_gang_string(iGang[id],gColor));
		}
	}
	menu_destroy(menu);
	return 1;
}

public ChangeGangName_Menu(id)
{
	if(GangColor[id] == -1 && !is_color_available(GangColor[id]))
		GangColor[id] = -1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang ^n\wChange Gang Name:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"ChangeGangName_Handler");
	
	formatex(Text,charsmax(Text),"\dGang Name: \y%s",equali(GangName[id],"") ? "None" : GangName[id] );
	menu_additem(menu,Text);
	
	new cb = menu_makecallback("ChangeNameCB");
	
	menu_additem(menu,"\rChange Gang Name",.callback = cb);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public ChangeGangName_Handler(id,menu,Item)
{
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
		{
			Mode[id] = 1;
			client_cmd(id,"messagemode gang_name");
		}
		case 1:
		{	
			if(get_gang_num(iGang[id],gCash) < 65000)
			{
				sColorChat(id,"The gang doesn't have^3 65,000 cash ^1to change gang name");
				return GangLeader_Menu(id);
			}
			new TheGang[GangInfo];
			ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
			TheGang[g_Name] = GangName[id];
			TheGang[g_Cash] -= 65000;
			sColorChat(0,"^3%s ^1has changed ^4%s^1's gang name to ^3%s",get_name(id),get_gang_string(iGang[id],gName),GangName[id]);
			ArraySetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
		}
	}
	menu_destroy(menu);
	return 1;
}

public ChangeGangModel_Menu(id)
{
	if(iGang[id] == -1)
		return 1;
	if(!is_model_available(GangModel[id]))
		GangModel[id] = -1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang ^n\wChange Gang Model:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"ChangeGangModel_Handler");
	if(GangModel[id] == -1)
		formatex(Text,charsmax(Text),"\dGang Model: \y%s^n","None");
	else
		formatex(Text,charsmax(Text),"\dGang Model: \y%s^n",GangModels[GangModel[id]][m_Name] );
	menu_additem(menu,Text);
	
	new cb = menu_makecallback("ChangeModelCB");
	
	menu_additem(menu,"\rChange Gang Model",.callback = cb);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public ChangeGangModel_Handler(id,menu,Item)
{
	if(iGang[id] == -1)
		return 1;
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
		{
			Mode[id] = 1;
			GangModels_Menu(id)
		}
		case 1:
		{
			if(get_gang_num(iGang[id],gCash) < 65000)
			{
				sColorChat(id,"The gang doesn't have^3 65,000 cash ^1to change gang model");
				return GangLeader_Menu(id);
			}
			new TheGang[GangInfo];
			ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
			TheGang[g_Model] = GangModel[id];
			TheGang[g_Cash] -= 65000;
			ArraySetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);

			sColorChat(0,"^3%s ^1has changed ^4%s^1's gang model to ^3%s",get_name(id),get_gang_string(iGang[id],gName),get_gang_string(iGang[id],gModelName));
		}
	}
	menu_destroy(menu);
	return 1;
}

public SetGangModel_Menu(id)
{
	if(iGang[id] == -1)
		return 1;
	if(!is_model_available(GangModel[id]))
		GangModel[id] = -1;
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang ^n\wSet Gang Model:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"SetGangModel_Handler");
	if(GangModel[id] == -1)
		formatex(Text,charsmax(Text),"\dGang Model: \y%s^n","None");
	else
		formatex(Text,charsmax(Text),"\dGang Model: \y%s^n",GangModels[GangModel[id]][m_Name] );
	menu_additem(menu,Text);
	
	new cb = menu_makecallback("SetModelCB");
	
	menu_additem(menu,"\rSet Gang Model",.callback = cb);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back");
	menu_display(id,menu);
	return 1;
}

public SetGangModel_Handler(id,menu,Item)
{
	if(iGang[id] == -1)
		return 1;
	
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
	if(TheGang[g_Cash] < 500000)
		return sColorChat(id,"The gang doesn't have enough cash");
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
		{
			Mode[id] = 0;
			GangModels_Menu(id)
		}
		case 1:
		{
			if(get_gang_num(iGang[id],gCash) < 500000)
			{
				sColorChat(id,"The gang doesn't have^3 500,000 cash ^1to purchase gang model");
				return GangLeader_Menu(id);
			}
			TheGang[g_Model] = GangModel[id];
			TheGang[g_Cash] -= 500000;
			ArraySetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);

			sColorChat(0,"^3%s ^1has upgraded ^4Gang Model ^1Skill and has choosed the model ^3%s",get_name(id),get_gang_string(iGang[id],gModelName));
		}
	}
	menu_destroy(menu);
	return 1;
}

public GangMembers_Menu(id,GangID)
{
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang ^n\wGang Members:",TAG,get_gang_string(GangID,gName));
	new menu = menu_create(Text,"GangMembers_Handler");
	
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
	
	for(new i; i < ArraySize(TheGang[g_Members]); i++)
	{
		new String[3];
		formatex(String,charsmax(String),"%d",GangID);
		formatex(Text,charsmax(Text),"\w%s \d[%s\d]",get_ganguser_string(GangID,i,uName),is_ganguser_online(GangID,i) ? "\rOnline" : "\yOffline");
		menu_additem(menu,Text,String);
	}
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public GangMembers_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return ViewGangs_Menu(id);
	}
	new _shit,Data[3];
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	new GangID = str_to_num(Data);
	ViewMember_Menu(id,GangID,Item);
	
	menu_destroy(menu);
	return 1;
}


public ViewMember_Menu(id,GangID,uArrPlace)
{
	new Text[560];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\r%s \wMember Info:",TAG,get_gang_string(GangID,gName),get_ganguser_string(GangID,uArrPlace,uName));
	new menu = menu_create(Text,"ViewMember_Handler");
	
	new cb = menu_makecallback("KickMemberCB");
	
	new String[6];
	formatex(String,charsmax(String),"%d#%d",GangID,uArrPlace);
	
	menu_additem(menu,"Kick Member",String,.callback = cb);
	
	formatex(Text,charsmax(Text),"\d- \wInvited By: \y%s",get_ganguser_string(GangID,uArrPlace,uInviterName));
	format(Text,charsmax(Text),"%s^n\d- \wInviter SteamID: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uInviterSteamID));
	
	if((iGang[id] == GangID && get_user_gnum(id,uRank) == LEADER) || get_user_flags(id) & ADMIN_IMMUNITY)
	{
		format(Text,charsmax(Text),"%s^n\d- \wInviter IP: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uInviterIP));
	}
	format(Text,charsmax(Text),"%s^n",Text);
	
	format(Text,charsmax(Text),"%s^n\d- \wName: \y%s",Text,get_ganguser_string(GangID,uArrPlace,uName));
	format(Text,charsmax(Text),"%s^n\d- \wSteamID: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uSteamID));
	
	if((iGang[id] == GangID && get_user_gnum(id,uRank) == LEADER) || get_user_flags(id) & ADMIN_IMMUNITY)
	{
		format(Text,charsmax(Text),"%s^n\d- \wIP: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uIP));
	}
	format(Text,charsmax(Text),"%s^n\d- \wRank: \r%s",Text,GangLevels[get_ganguser_num(GangID,uArrPlace,uRank)]);
	format(Text,charsmax(Text),"%s^n\d- \wDonated: \r%d Cash",Text,get_ganguser_num(GangID,uArrPlace,uDonation));
	format(Text,charsmax(Text),"%s^n\d- \wLast Connected: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uLastConnected));
	format(Text,charsmax(Text),"%s^n\d- \wJoined Date: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uJoined));
	
	menu_addtext(menu,Text);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public ViewMember_Handler(id,menu,Item)
{
	new _shit,Data[6];
	if(Item == MENU_EXIT)
	{
		Item = 0;
		menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
		Item = MENU_EXIT;
	}
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	replace_all(Data,charsmax(Data),"#"," ");
	new sData[2][3];
	parse(Data,sData[0],2,sData[1],2);
	new GangID = str_to_num(sData[0]);
	new uArrPlace = str_to_num(sData[1]);
	switch(Item)
	{
		case MENU_EXIT:
		{
			menu_destroy(menu);
			return GangMembers_Menu(id,GangID);
		}
		case 0:
		{
			for(new i = 1; i <MaxPlayers; i++)
				if(!is_user_connected(i) || iGang[i] != iGang[id])
					continue;
				else
					sColorChat(i,"^3%s ^1has kicked the player ^3%s ^1from the gang.",get_name(id),get_ganguser_string(GangID,uArrPlace,uName)/*,get_gang_string(GangID,gName)*/);
			if(is_ganguser_online(GangID,uArrPlace))
				iGang[is_ganguser_online(GangID,uArrPlace)] = -1;
			new TheGang[GangInfo];
			ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
			TrieDeleteKey(g_GangsPlayers,get_ganguser_string(GangID,uArrPlace,uKey));
			ArrayDeleteItem(TheGang[g_Members],uArrPlace);
			ArraySetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
		}
	}
	
	menu_destroy(menu);
	return GangMembers_Menu(id,GangID);
}

public InvitePlayers_Menu(id)
{
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wInvite Players Menu:",TAG,get_gang_string(iGang[id],gName));
	new menu = menu_create(Text,"InvitePlayers_Handler");
	
	new counter;
	new cb = menu_makecallback("InvitePlayersCB");
	for(new i; i < MaxPlayers; i++)
	{
		if(!is_user_connected(i) || gRequested[i] || iGang[i] != -1)
			continue;
		new String[3];
		formatex(String,charsmax(String),"%d",i);
		formatex(Text,charsmax(Text),"\w%s \d[\r%s\d]",get_name(i),get_key(i));
		menu_additem(menu,Text,String,.callback = cb);
		counter ++;
	}
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	if(counter > 0)
		menu_display(id,menu);
	else
	{
		sColorChat(id,"there are ^3no players ^1to invite to your gang");
		return GangAdmin_Menu(id);
	}
	return 1;
}



public InvitePlayers_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return GangMember_Menu(id);
	}
	new _shit,Data[3];
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	new iPlayer = str_to_num(Data);
	
	gRequested[iPlayer] = true;
	gRequestTime[iPlayer] = 15;
	gSender[iPlayer] = id;
	GangRequest_Menu(iPlayer);
	
	menu_destroy(menu);
	return 1;
}


public GangRequest_Menu(id)
{
	if(gRequestTime[id] < 1)
	{
		gRequested[id] = false;
		show_menu(id,1,"^n",1);
		remove_task(id);
		return 1;
	}
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\y%s \wis Inviting you to \r%s \wGang^n\yTime Left: \r%d^n\dAre you agree?",TAG,get_name(gSender[id]),get_gang_string(iGang[gSender[id]],gName),gRequestTime[id]);
	new menu = menu_create(Text,"GangRequest_Handler");
	
	new String[3];
	formatex(String,charsmax(String),"%d",gSender[id]);
	
	menu_additem(menu,"\wYes, I am",String);
	menu_additem(menu,"\wNo, I am not",String);
	
	menu_setprop(menu,MPROP_EXITNAME,"Exit");
	menu_display(id,menu);
	
	gRequestTime[id] --;
	set_task(1.0,"GangRequest_Menu",id);
	return 1;
}



public GangRequest_Handler(id,menu,Item)
{
	if(gRequestTime[id] < 1 || !gRequested[id])
	{
		remove_task(id);
		return 1;
	}
	new sender;
	if(Item != MENU_EXIT)
	{
		new _shit,Data[3];
		menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
		sender = str_to_num(Data);
	}
	if(Item == 0 && get_gang_num(iGang[sender],gMembers) >= MaxMembers_Values[get_gang_num(iGang[sender],gMaxMembers)])
	{
		sColorChat(sender,"^3%s ^1cannot join to the gang, ^4gang members full",get_name(id));
		sColorChat(id,"You cannot join to the gang, ^4gang members full",get_name(id));
		return 1;
	}
	if(Item == 0 && iGang[sender] == -1)
	{
		sColorChat(id,"You cannot join to the gang, ^3%s ^1is not in the gang anymore",get_name(sender));
		return 1;
	}
	switch(Item)
	{
		case MENU_EXIT:
		{
			GangMainMenu(id);
			return 1;
		}
		case 0:
		{
			gRequested[id] = false;
			gRequestTime[id] = 0;
			iGang[id] = iGang[sender];
			new TheGang[GangInfo],ThePlayer[PlayerInfo];
			ArrayGetArray(g_Gangs,get_gang_num(iGang[id],gArrPlace),TheGang);
			ThePlayer[p_InviterName] = get_name(sender);
			ThePlayer[p_InviterSTEAMID] = get_auth(sender);
			ThePlayer[p_InviterIP] = get_ip(sender);
			ThePlayer[p_Name] = get_name(id);
			ThePlayer[p_STEAMID] = get_auth(id);
			ThePlayer[p_IP] = get_ip(id);
			ThePlayer[p_LastConnected] = get_systime();
			ThePlayer[p_Joined] = get_systime();
			ThePlayer[p_Level] = MEMBER;
			ArrayPushArray(TheGang[g_Members],ThePlayer);
			TrieSetCell(g_GangsPlayers,get_key(id),iGang[id]);
			sColorChat(sender,"^3%s ^1has agreed your gang request",get_name(id));
			for(new i = 1; i <MaxPlayers; i++)
				if(!is_user_connected(i) || iGang[i] != iGang[id])
					continue;
				else
					sColorChat(i,"^3%s ^1has been joined to the gang",get_name(id)/*,get_gang_string(iGang[id],gName)*/);
		}
		case 1:
		{
			gRequested[id] = false;
			gRequestTime[id] = 0;
			sColorChat(sender,"^3%s ^1has disagreed your gang request",get_name(id));
		}
			
	}
	menu_destroy(menu);
	return 1;
}


public KickPlayers_Menu(id)
{
	new Text[128];
	new GangID = iGang[id];
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang ^n\dKick Members Menu:",TAG,get_gang_string(GangID,gName));
	new menu = menu_create(Text,"KickPlayers_Handler");
	
	new TheGang[GangInfo], counter;
	ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
	
	for(new i; i < ArraySize(TheGang[g_Members]); i++)
	{
		if(get_ganguser_num(iGang[id],i,uRank) >= get_user_gnum(id,uRank))
			continue;
		new String[3];
		formatex(String,charsmax(String),"%d",i);
		formatex(Text,charsmax(Text),"\w%s \d[%s\d]",get_ganguser_string(GangID,i,uName),is_ganguser_online(GangID,i) ? "\rOnline" : "\yOffline");
		menu_additem(menu,Text,String);
		counter ++;
	}
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	if(counter == 0)
	{
		sColorChat(id,"there are ^3no players to kick ^1from your gang");
		return GangAdmin_Menu(id);
	}
	menu_display(id,menu);
	return 1;
}

public KickPlayers_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return GangAdmin_Menu(id);
	}
	new Data[3],_shit;
	menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	new ArrPlace = str_to_num(Data);
	ViewKickMember_Menu(id,ArrPlace);
	
	menu_destroy(menu);
	return 1;
}


public ViewKickMember_Menu(id,uArrPlace)
{
	new Text[560];
	new GangID = iGang[id];
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\r%s \wPlayer Info:",TAG,get_gang_string(GangID,gName),get_ganguser_string(GangID,uArrPlace,uName));
	new menu = menu_create(Text,"ViewKickMember_Handler");
	
	new cb = menu_makecallback("KickMemberCB2");
	
	new String[3];
	formatex(String,charsmax(String),"%d",uArrPlace);
	
	menu_additem(menu,"Kick Member",String,.callback = cb);

	formatex(Text,charsmax(Text),"^n\d- \wName: \y%s",get_ganguser_string(GangID,uArrPlace,uName));
	format(Text,charsmax(Text),"%s^n\d- \wSteamID: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uSteamID));
	
	if((iGang[id] == GangID && get_user_gnum(id,uRank) == LEADER) || get_user_flags(id) & ADMIN_IMMUNITY)
	{
		format(Text,charsmax(Text),"%s^n\d- \wIP: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uIP));
	}
	format(Text,charsmax(Text),"%s^n\d- \wDonated: \r%d Cash",Text,get_ganguser_num(GangID,uArrPlace,uDonation));
	format(Text,charsmax(Text),"%s^n\d- \wLast Connected: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uLastConnected));
	format(Text,charsmax(Text),"%s^n\d- \wJoined Date: \r%s",Text,get_ganguser_string(GangID,uArrPlace,uJoined));
	
	menu_addtext(menu,Text);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public ViewKickMember_Handler(id,menu,Item)
{
	switch(Item)
	{
		case MENU_EXIT:
		{
			menu_destroy(menu);
			return KickPlayers_Menu(id);
		}
		case 0:
		{			
			new _shit,Data[3];
			menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
			new uArrPlace = str_to_num(Data);
			new GangID = iGang[id];
			sColorChat(0,"^3%s ^1has kicked the player ^3%s ^1from the gang ^4%s",get_name(id),get_ganguser_string(GangID,uArrPlace,uName),get_gang_string(GangID,gName));
			if(is_ganguser_online(GangID,uArrPlace))
				iGang[is_ganguser_online(GangID,uArrPlace)] = -1;
			new TheGang[GangInfo];
			ArrayGetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
			TrieDeleteKey(g_GangsPlayers,get_ganguser_string(GangID,uArrPlace,uKey));
			ArrayDeleteItem(TheGang[g_Members],uArrPlace);
			ArraySetArray(g_Gangs,get_gang_num(GangID,gArrPlace),TheGang);
		}
	}
	
	menu_destroy(menu);
	return KickPlayers_Menu(id);
}

public ViewGangs_Menu(id)
{
	if(ArraySize(g_Gangs) == 0)
	{
		sColorChat(id,"The server has not ^3gangs ^1yet");
		return GangMainMenu(id);
	}
	new Text[128];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\dGang List:",TAG);
	new menu = menu_create(Text,"ViewGangs_Handler");
	
	for(new i; i < ArraySize(g_Gangs); i++)
	{
		formatex(Text,charsmax(Text),"\w%s",get_gang_string(get_gangid(i),gName));
		menu_additem(menu,Text);
	}
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public ViewGangs_Handler(id,menu,Item)
{
	if(Item == MENU_EXIT)
	{
		menu_destroy(menu);
		return GangMainMenu(id);
	}
	if(get_gangid(Item) != iGang[id])
		GangView(id,get_gangid(Item),false);
	else
		GangView(id,get_gangid(Item),true);
	
	menu_destroy(menu);
	return 1;
}

public GangView(id,GangID,bool:MyGang)
{
	new Text[560];
	
	formatex(Text,charsmax(Text),"\r[ \w%s \r] \wJailBreak Gang Menu^n\r%s \dGang^n\wGang Info",TAG,get_gang_string(GangID,gName));
	new menu = menu_create(Text,"GangView_Handler");
	
	new cb = menu_makecallback("EditGangCB");
	
	new String[3];
	formatex(String,charsmax(String),"%d",GangID);
	
	menu_additem(menu,"Edit Gang Info",String,.callback = cb);
	if(!MyGang)
		menu_additem(menu,"Gang Members",String);
	menu_additem(menu,"Top Donors",String);
	
	formatex(Text,charsmax(Text),"\d- \wLeader: \r%s",get_ganguser_string(GangID,get_gang_num(GangID,gArrLeaderPlace),uName));
	format(Text,charsmax(Text),"%s^n\d- \wColor: \r%s",Text,get_gang_string(GangID,gColor));
	format(Text,charsmax(Text),"%s^n\d- \wMembers: \y%d \rPlayers",Text,get_gang_num(GangID,gMembers));
	format(Text,charsmax(Text),"%s^n\d- \wTotal Donations: \y%d \rCash",Text,get_gang_num(GangID,gDonation));
	format(Text,charsmax(Text),"%s^n\d- \wCash: \y%d \rCash",Text,get_gang_num(GangID,gCash));
	format(Text,charsmax(Text),"%s^n\d- \wGet Cash: \y%d",Text,GetCash_Values[get_gang_num(GangID,gGetCash)]);
	format(Text,charsmax(Text),"%s^n\d- \wBonus Cash: \y%.2f%%",Text,BonusCash_Values[get_gang_num(GangID,gBonusCash)]);
	format(Text,charsmax(Text),"%s^n\d- \wHealth: \y%d HP",Text,Health_Values[get_gang_num(GangID,gHealth)]);
	format(Text,charsmax(Text),"%s^n\d- \wHeal Regaration: \y%d HP",Text,HealRegaration_Values[get_gang_num(GangID,gHealRegaration)]);
	format(Text,charsmax(Text),"%s^n\d- \wDamage: \y%.2f%%",Text,Damage_Values[get_gang_num(GangID,gDamage)]);
	format(Text,charsmax(Text),"%s^n\d- \wWeapon Drop: \y%.2f%%",Text,WeaponDrop_Values[get_gang_num(GangID,gWeaponDrop)]);
	format(Text,charsmax(Text),"%s^n\d- \wGang Mic: %s",Text,get_gang_num(GangID,gGangMic) == 0 ? "\dHasn't Allowed" : "\rAllowed");
	if(get_gang_num(GangID,gModel) == -1)
		format(Text,charsmax(Text),"%s^n\d- \wGang Model: \d%s",Text,"None");
	else
		format(Text,charsmax(Text),"%s^n\d- \wGang Model: \r%s",Text,get_gang_string(GangID,gModelName));
	format(Text,charsmax(Text),"%s^n\d- \wMax Members: \y%d \rPlayers",Text,MaxMembers_Values[get_gang_num(GangID,gMaxMembers)]);
	menu_addtext(menu,Text);
	
	menu_setprop(menu,MPROP_EXITNAME,"Back")
	menu_display(id,menu);
	return 1;
}

public GangView_Handler(id,menu,Item)
{
	new _shit,Data[3];
	if(Item == MENU_EXIT)
	{
		Item = 0;
		menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
		Item = MENU_EXIT;
	}
	else
		menu_item_getinfo(menu,Item,_shit,Data,charsmax(Data),_,_,_shit);
	new GangID = str_to_num(Data);
	switch(Item)
	{
		case MENU_EXIT:
		{
			menu_destroy(menu);
			if(iGang[id] == GangID)
				return GangMember_Menu(id);
			return ViewGangs_Menu(id);
		}
		//case 0:
			//EditGang_Menu(id,GangID);
		case 1:
			return iGang[id] == GangID ? TopDonors_View(id,GangID) : GangMembers_Menu(id,GangID);
		case 2:
			return TopDonors_View(id,GangID);
	}
	
	menu_destroy(menu)
	if(iGang[id] == GangID)
		return GangMember_Menu(id);
	return ViewGangs_Menu(id);
}


public ReadFile()
{
	new FileLocation[128];
	
	get_configsdir(FileLocation,charsmax(FileLocation));
	format(FileLocation,charsmax(FileLocation),"%s/%s",FileLocation,szFileName);
	
	if(!file_exists(FileLocation))
		return 1;
		
	new f = fopen(FileLocation,"rt");
	new LineText[192];
	
	while(fgets(f,LineText,charsmax(LineText)))
	{
		new TheGang[GangInfo];
		
		if(LineText[0] == ';' || LineText[0] == EOS || (LineText[0] == '/' && LineText[1] == '/'))
			continue;
			
		new ID[5],Donation[10],Cash[10],GetCash[5],BonusCash[5],HealRegaration[5],Damage[5],MaxMembers[5],Health[5],WeaponDrop[5],GangMic[5],Model[5];
		
		parse(LineText,ID,charsmax(ID),TheGang[g_Name],charsmax(TheGang[g_Name]),Donation,charsmax(Donation),Cash,charsmax(Cash),
		GetCash,charsmax(GetCash),BonusCash,charsmax(BonusCash),HealRegaration,charsmax(HealRegaration),Health,charsmax(Health),Damage,
		charsmax(Damage),WeaponDrop,charsmax(WeaponDrop),GangMic,charsmax(GangMic),Model,charsmax(Model),MaxMembers,charsmax(MaxMembers));
		TheGang[g_ID] = str_to_num(ID);
		TheGang[g_Donation] = str_to_num(Donation);
		TheGang[g_Cash] = str_to_num(Cash);
		TheGang[g_GetCash] = str_to_num(GetCash);
		TheGang[g_BonusCash] = str_to_num(BonusCash);
		TheGang[g_HealRegaration] = str_to_num(HealRegaration);
		TheGang[g_Health] = str_to_num(Health);
		TheGang[g_Damage] = str_to_num(Damage);
		TheGang[g_WeaponDrop] = str_to_num(WeaponDrop);
		TheGang[g_GangMic] = str_to_num(GangMic);
		TheGang[g_Model] = str_to_num(Model);
		TheGang[g_MaxMembers] = str_to_num(MaxMembers);
		TheGang[g_Members] = _:ArrayCreate(PlayerInfo);
		new GangFileLocation[128];
		get_configsdir(GangFileLocation,charsmax(GangFileLocation));
		format(GangFileLocation,charsmax(GangFileLocation),"%s/%s.txt",GangFileLocation,TheGang[g_Name]);
		if(!file_exists(GangFileLocation))
			continue;
			
		new gf = fopen(GangFileLocation,"rt");
		
		while(fgets(gf,LineText,charsmax(LineText)))
		{
			new ThePlayer[PlayerInfo];
			
			if(LineText[0] == ';' || LineText[0] == EOS || (LineText[0] == '/' && LineText[1] == '/'))
				continue;
				
			new pDonation[10],pLevel[5],pJoined[15],pLastConnected[15];
			parse(LineText,ThePlayer[p_InviterName],charsmax(ThePlayer[p_InviterName]),ThePlayer[p_InviterSTEAMID],charsmax(ThePlayer[p_InviterSTEAMID]),
			ThePlayer[p_InviterIP],charsmax(ThePlayer[p_InviterIP]),ThePlayer[p_Name],charsmax(ThePlayer[p_Name]),ThePlayer[p_STEAMID],charsmax(ThePlayer[p_STEAMID]),
			ThePlayer[p_IP],charsmax(ThePlayer[p_IP]),pJoined,charsmax(pJoined),pLastConnected,charsmax(pLastConnected),pDonation,charsmax(pDonation),pLevel,charsmax(pLevel));
			
			ThePlayer[p_Joined] = str_to_num(pJoined);
			ThePlayer[p_LastConnected] = str_to_num(pLastConnected);
			ThePlayer[p_Donation] = str_to_num(pDonation);
			ThePlayer[p_Level] = str_to_num(pLevel);
			ArrayPushArray(TheGang[g_Members],ThePlayer);
			
			switch(SaveType)
			{
				case 0: // STEAMID
					TrieSetCell(g_GangsPlayers,ThePlayer[p_STEAMID],TheGang[g_ID]);
				case 1: // IP
					TrieSetCell(g_GangsPlayers,ThePlayer[p_IP],TheGang[g_ID]);
				case 2: // IP+STEAMID
				{
					new p_STEAM_IP[70];
					formatex(p_STEAM_IP,charsmax(p_STEAM_IP),"%s%s",ThePlayer[p_IP],ThePlayer[p_STEAMID]);
					TrieSetCell(g_GangsPlayers,p_STEAM_IP,TheGang[g_ID]);
				}
			}
		}
		fclose(gf);
		ArrayPushArray(g_Gangs,TheGang);
	}
	fclose(f);
	return 1;
}

public plugin_end()
{
	new FileLocation[128];
	
	get_configsdir(FileLocation,charsmax(FileLocation));
	format(FileLocation,charsmax(FileLocation),"%s/%s",FileLocation,szFileName);
	
	delete_file(FileLocation);
	
	new f = fopen(FileLocation,"wt");
	
	for(new i; i < ArraySize(g_Gangs); i++)
	{
		new TheGang[GangInfo],LineText[192];
		
		ArrayGetArray(g_Gangs,i,TheGang);
		formatex(LineText,charsmax(LineText),"^"%d^" ^"%s^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^" ^"%d^"^n",
		TheGang[g_ID],TheGang[g_Name],TheGang[g_Donation],TheGang[g_Cash],TheGang[g_GetCash],TheGang[g_BonusCash],TheGang[g_HealRegaration],
		TheGang[g_Health],TheGang[g_Damage],TheGang[g_WeaponDrop],TheGang[g_GangMic],TheGang[g_Model],TheGang[g_MaxMembers]);
		fputs(f,LineText);
		
		new GangFileLocation[128];
			
		get_configsdir(GangFileLocation,charsmax(GangFileLocation));
		format(GangFileLocation,charsmax(GangFileLocation),"%s/%s.txt",GangFileLocation,TheGang[g_Name])
		
		delete_file(GangFileLocation);
		
		new gf = fopen(GangFileLocation,"wt");
		
		for(new j; j < ArraySize(TheGang[g_Members]); j++)
		{
			new ThePlayer[PlayerInfo];
			ArrayGetArray(TheGang[g_Members],j,ThePlayer);
			formatex(LineText,charsmax(LineText),"^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%s^" ^"%d^" ^"%d^" ^"%d^" ^"%d^"^n",
			ThePlayer[p_InviterName],ThePlayer[p_InviterSTEAMID],ThePlayer[p_InviterIP],ThePlayer[p_Name],ThePlayer[p_STEAMID],
			ThePlayer[p_IP],ThePlayer[p_Joined],ThePlayer[p_LastConnected],ThePlayer[p_Donation],ThePlayer[p_Level]);
			fputs(gf,LineText);
		}
		fclose(gf);
	}
	fclose(f);
}

public client_authorized(id)
{
	if(contain(get_name(id),"^"")!=-1)
		server_cmd("kick ^"#%d^" ^"You cannot connect with that name^"",get_user_userid(id));
}
		

public client_putinserver(id)
	CheckPlayerInfo(id);

public client_disconnect(id)
{
	if(iGang[id] != -1)
		UpdateDetails(id)
}
	
stock CheckPlayerInfo(index)
{
	iGang[index] = -1;
	gRequested[index] = false;

	if(TrieKeyExists(g_GangsPlayers,get_key(index)))
	{
		TrieGetCell(g_GangsPlayers,get_key(index),iGang[index])
		UpdateDetails(index);
	}
}

stock UpdateDetails(index)
{
	if(iGang[index] == -1)
		return;
	new TheGang[GangInfo],ThePlayer[PlayerInfo];
	log_amx("%s Crashed with iGang %d",get_name(index),iGang[index]);
	ArrayGetArray(g_Gangs,get_gang_num(iGang[index],gArrPlace),TheGang);
	ArrayGetArray(TheGang[g_Members],get_arraynumber(index),ThePlayer);
	ThePlayer[p_Name] = get_name(index)
	ThePlayer[p_STEAMID] = get_auth(index)
	ThePlayer[p_IP] = get_ip(index)
	ThePlayer[p_LastConnected] = get_systime();
	ArraySetArray(TheGang[g_Members],get_arraynumber(index),ThePlayer);
	ArraySetArray(g_Gangs,get_gang_num(iGang[index],gArrPlace),TheGang);
}	

stock get_auth(index)
{
	new szAuth[40];
	get_user_authid(index,szAuth,charsmax(szAuth));
	if(contain(szAuth,"VALVE_")!=-1||contain(szAuth,"ID_LAN")!=-1)
		get_user_ip(index,szAuth,charsmax(szAuth),1);
	return szAuth;
}
stock get_ip(index)
{
	new szAuth[20];
	get_user_ip(index,szAuth,charsmax(szAuth),1);
	return szAuth;
}
stock get_name(index)
{
	new szName[33];
	get_user_name(index,szName,charsmax(szName));
	return szName;
}

stock get_arraynumber(index)
{
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,get_gang_num(iGang[index],gArrPlace),TheGang);
	for(new i; i < ArraySize(TheGang[g_Members]); i++)
	{
		new ThePlayer[PlayerInfo];
		ArrayGetArray(TheGang[g_Members],i,ThePlayer);
		switch(SaveType)
		{
			case 0:
			{
				if(equali(ThePlayer[p_STEAMID],get_auth(index)))
					return i;
			}
			case 1:
			{
				if(equali(ThePlayer[p_IP],get_ip(index)))
					return i;
			}
			case 2:
			{
				new p_STEAM_IP[2][70];
				formatex(p_STEAM_IP[0],69,"%s%s",get_ip(index),get_auth(index));
				formatex(p_STEAM_IP[1],69,"%s%s",ThePlayer[p_IP],ThePlayer[p_STEAMID]);
				if(equali(p_STEAM_IP[0],p_STEAM_IP[1]))
					return i;
			}
		}
	}
	return -1;
}

stock get_key(index)
{
	new szKey[70];
	switch(SaveType)
	{
		case 0: // STEAMID
			szKey = get_auth(index);
		case 1: // IP
			szKey = get_ip(index);
		case 2: // IP+STEAMID
			formatex(szKey,charsmax(szKey),"%s%s",get_ip(index),get_auth(index));
	}
	return szKey;
}

stock SortTopGangs(&Array:ArrayName)
{
	ArrayName = ArrayCreate(GangInfo);
	for(new i; i < ArraySize(g_Gangs); i++)
	{
		new Data[GangInfo];
		ArrayGetArray(g_Gangs,i,Data);
		ArrayPushArray(ArrayName,Data);
	}
	ArraySort( ArrayName, "SortGangsData" );
}

stock SortTopDonors(ArrPlace,&Array:ArrayName)
{
	ArrayName = ArrayCreate(PlayerInfo);
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,ArrPlace,TheGang);
	for(new i; i <ArraySize(TheGang[g_Members]) ; i++)
	{
		new Data[PlayerInfo];
		ArrayGetArray(TheGang[g_Members],i,Data);
		ArrayPushArray(ArrayName,Data);
	}
	ArraySort( ArrayName, "SortDonorsData" );
}

stock get_user_gnum(index,GetIndex)
{
	new TheGang[GangInfo],ThePlayer[PlayerInfo];
	ArrayGetArray(g_Gangs,get_gang_num(iGang[index],gArrPlace),TheGang);
	ArrayGetArray(TheGang[g_Members],get_arraynumber(index),ThePlayer);
	
	switch(GetIndex)
	{
		case uDonation:
			return ThePlayer[p_Donation];
		case uRank:
			return ThePlayer[p_Level];
	}
	
	return 1;
}

stock get_user_gstring(index,GetIndex)
{
	new TheGang[GangInfo],ThePlayer[PlayerInfo];
	ArrayGetArray(g_Gangs,get_gang_num(iGang[index],gArrPlace),TheGang);
	ArrayGetArray(TheGang[g_Members],get_arraynumber(index),ThePlayer);
	
	new Text[30];
	
	switch(GetIndex)
	{
		case uName:
			formatex(Text,charsmax(Text),"%s",ThePlayer[p_Name]);
	}
	
	return Text;
}

stock get_ganguser_num(GangIndex,ArrIndex,GetIndex)
{
	new TheGang[GangInfo],ThePlayer[PlayerInfo];
	ArrayGetArray(g_Gangs,get_gang_num(GangIndex,gArrPlace),TheGang);
	ArrayGetArray(TheGang[g_Members],ArrIndex,ThePlayer);
	
	switch(GetIndex)
	{
		case uDonation:
			return ThePlayer[p_Donation];
		case uRank:
			return ThePlayer[p_Level];
	}
	
	return 1;
}

stock get_ganguser_string(GangIndex,ArrIndex,GetIndex)
{
	new TheGang[GangInfo],ThePlayer[PlayerInfo];
	ArrayGetArray(g_Gangs,get_gang_num(GangIndex,gArrPlace),TheGang);
	ArrayGetArray(TheGang[g_Members],ArrIndex,ThePlayer);
	
	new Text[70];
	
	switch(GetIndex)
	{
		case uInviterName:
			formatex(Text,charsmax(Text),"%s",ThePlayer[p_InviterName]);
		case uInviterSteamID:
			formatex(Text,charsmax(Text),"%s",ThePlayer[p_InviterSTEAMID]);
		case uInviterIP:
			formatex(Text,charsmax(Text),"%s",ThePlayer[p_InviterIP]);
		case uName:
			formatex(Text,charsmax(Text),"%s",ThePlayer[p_Name]);
		case uSteamID:
			formatex(Text,charsmax(Text),"%s",ThePlayer[p_STEAMID]);
		case uIP:
			formatex(Text,charsmax(Text),"%s",ThePlayer[p_IP]);
		case uJoined:
			format_time(Text,charsmax(Text),"%d/%m/%Y - %H:%M:%S",ThePlayer[p_Joined]);
		case uLastConnected:
		{
			if(is_ganguser_online(GangIndex,ArrIndex))
				formatex(Text,charsmax(Text),"Currently Online");
			else
				format_time(Text,charsmax(Text),"%d/%m/%Y - %H:%M:%S",ThePlayer[p_LastConnected]);
		}
		case uKey:
		{
			switch(SaveType)
			{
				case 0:
					formatex(Text,charsmax(Text),"%s",ThePlayer[p_STEAMID]);
				case 1:
					formatex(Text,charsmax(Text),"%s",ThePlayer[p_IP]);
				case 2:
					formatex(Text,charsmax(Text),"%s%s",ThePlayer[p_IP],ThePlayer[p_STEAMID]);
			}
		}
	}
	
	return Text;
}

stock get_gangid(ArrayPlace)
{
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,ArrayPlace,TheGang);
	return TheGang[g_ID];
}

stock get_gang_num(GangIndex,GetIndex)
{
	new TheGang[GangInfo],ArrayPlace;
	for(new i; i < ArraySize(g_Gangs); i++)
	{
		ArrayGetArray(g_Gangs,i,TheGang);
		if(TheGang[g_ID] == GangIndex)
		{
			ArrayPlace = i;
			break;
		}
	}
	new Text[30];
	Text = TheGang[g_Name];
	
	switch(GetIndex)
	{
		case gDonation:
			return TheGang[g_Donation];
		case gCash:
			return TheGang[g_Cash];
		case gGetCash:
			return TheGang[g_GetCash];
		case gBonusCash:
			return TheGang[g_BonusCash];
		case gHealth:
			return TheGang[g_Health];
		case gHealRegaration:
			return TheGang[g_HealRegaration];
		case gDamage:
			return TheGang[g_Damage];
		case gMembers:
			return ArraySize(TheGang[g_Members]);
		case gMaxMembers:
			return TheGang[g_MaxMembers];
		case gWeaponDrop:
			return TheGang[g_WeaponDrop];
		case gGangMic:
			return TheGang[g_GangMic];
		case gModel:
			return TheGang[g_Model];
		case gArrPlace:
			return ArrayPlace;
		case gArrLeaderPlace:
		{
			new Player[PlayerInfo];
			for(new i; i < ArraySize(TheGang[g_Members]); i++)
			{
				ArrayGetArray(TheGang[g_Members],i,Player);
				if(Player[p_Level] == LEADER)
					return i;
			}
		}
		case gManagers:
		{
			new count;
			for(new i; i < ArraySize(TheGang[g_Members]); i++)
				if(get_ganguser_num(GangIndex,i,uRank) == MANAGER)
					count ++;
		}
		case gAdmins:
		{
			new count;
			for(new i; i < ArraySize(TheGang[g_Members]); i++)
				if(get_ganguser_num(GangIndex,i,uRank) == ADMIN)
					count ++;
		}
	}
	return 0;
	/*
	gBonusCash,
	gHealth,
	gHealRegaration,
	gDamage,
	gMembers,
	gMaxMembers,
	gWeaponDrop,
	gGangMic,
	*/
}


stock get_gang_string(GangIndex,GetIndex)
{
	new TheGang[GangInfo];
	ArrayGetArray(g_Gangs,get_gang_num(GangIndex,gArrPlace),TheGang);
	new Text[30];
	
	switch(GetIndex)
	{
		case gName:
			formatex(Text,charsmax(Text),"%s",TheGang[g_Name]);
		case gColor:
			formatex(Text,charsmax(Text),"%s",GangColors[TheGang[g_ID]][c_Name]);
		case gModelName:
			formatex(Text,charsmax(Text),"%s",GangModels[TheGang[g_Model]][m_Name]);
	}
	return Text;
}

stock is_color_available(ColorNum)
{
	new bool:Available = true;
	for(new i; i < ArraySize(g_Gangs);i++)
	{
		if(get_gangid(i) == ColorNum)
			Available = false;
	}
	return Available;
}

stock is_model_available(ModelNum)
{
	new bool:Available = true;
	for(new i; i < ArraySize(g_Gangs);i++)
	{
		if(get_gang_num(get_gangid(i),gModel) == ModelNum)
			Available = false;
	}
	return Available;
}

stock is_gangname_available(const String[])
{
	new bool:Available = true;
	for(new i; i < ArraySize(g_Gangs);i++)
	{
		if(equali(get_gang_string(get_gangid(i),gName),String))
			Available = false;
	}
	return Available;
}

stock is_ganguser_online(GangIndex,ArrIndex)
{
	new Key[70];
	formatex(Key,charsmax(Key),"%s",get_ganguser_string(GangIndex,ArrIndex,uKey));
	for(new i=1; i <= MaxPlayers; i++)
	{
		if(!is_user_connected(i))
			continue;
		if(equali(get_key(i),Key))
			return i;
	}
	return false;
}

stock get_gangplayers_online(GangIndex)
{
	new count;
	for(new i=1; i <= MaxPlayers; i++)
	{
		if(!is_user_connected(i))
			continue;
		if(iGang[i] == GangIndex)
			count ++;
	}
	return count;
	
}

public SortGangsData( Array:aData, iIndex1, iIndex2, const iSortData[ ], iSortDataSize )
{
	new eData1[ GangInfo ], eData2[ GangInfo ];
	ArrayGetArray( aData, iIndex1, eData1 );
	ArrayGetArray( aData, iIndex2, eData2 );
	
	if( eData1[ g_Donation ] < eData2[ g_Donation ])
		return 1;
		
	return -1;
}


public SortDonorsData( Array:aData, iIndex1, iIndex2, const iSortData[ ], iSortDataSize )
{
	new eData1[ PlayerInfo ], eData2[ PlayerInfo ];
	ArrayGetArray( aData, iIndex1, eData1 );
	ArrayGetArray( aData, iIndex2, eData2 );
	
	if( eData1[ p_Donation ] < eData2[ p_Donation ])
		return 1;
		
	return -1;
}

/* Old Saving & Loading
public ReadFile()
{
	new FileLocation[128];
	get_configsdir(FileLocation,charsmax(FileLocation));
	format(FileLocation,charsmax(FileLocation),"%s/%s",FileLocation,szFileName);
	new Lines = file_size(FileLocation,1)-1;
	for(new i; i < Lines; i++)
	{
		new LineText[192],TheGang[GangInfo],_shit;
		read_file(FileLocation,i,LineText,charsmax(FileLocation),_shit);
		if(equali(LineText[0],";") || equali(LineText[0],"") || (equali(LineText[0],"/") && equali(LineText[1],"/")))
			continue;
		new ID[5],Donation[10],NextCash[5],GetCash[5],HealRegaration[5],Damage[5],MaxMembers[5];
		parse(LineText,ID,charsmax(ID),TheGang[g_Name],charsmax(TheGang[g_Name]),Donation,charsmax(Donation),NextCash,charsmax(NextCash),
		GetCash,charsmax(GetCash),HealRegaration,charsmax(HealRegaration),Damage,charsmax(Damage),MaxMembers,charsmax(MaxMembers));
		TheGang[g_ID] = str_to_num(ID);
		TheGang[g_Donation] = str_to_num(Donation);
		TheGang[g_NextCash] = str_to_num(NextCash);
		TheGang[g_GetCash] = str_to_num(GetCash);
		TheGang[g_HealRegaration] = str_to_num(HealRegaration);
		TheGang[g_Damage] = str_to_num(Damage);
		TheGang[g_MaxMembers] = str_to_num(MaxMembers);
		TheGang[g_Members] = ArrayCreate(PlayerInfo);
		TheGang[g_Line] = i;
		new GangFileLocation[128];
		get_configsdir(GangFileLocation,charsmax(GangFileLocation));
		format(GangFileLocation,charsmax(GangFileLocation),"%s/%s",GangFileLocation,TheGang[g_Name]);
		new g_Lines = file_size(GangFileLocation,1) -1;
		for(new j; j < g_Lines; j++)
		{
			new g_LineText[192],ThePlayer[PlayerInfo];
			read_file(GangFileLocation,j,g_LineText,charsmax(g_LineText),_shit);
			if(equali(g_LineText[0],";") || equali(g_LineText[0],"") || (equali(g_LineText[0],"/") && equali(g_LineText[1],"/")))
				continue;
			new pDonation[10],pLevel[5],pLastConnected[15];
			parse(g_LineText,ThePlayer[p_Name],charsmax(ThePlayer[p_Name]),ThePlayer[p_STEAMID],charsmax(ThePlayer[p_STEAMID]),ThePlayer[p_IP],charsmax(ThePlayer[p_IP]),
			pLastConnected,charsmax(pLastConnected),pDonation,charsmax(pDonation),pLevel,charsmax(pLevel));
			replace_all(ThePlayer[p_Name],charsmax(ThePlayer[p_Name]),"#$"," ");
			ThePlayer[p_LastConnected] = str_to_num(pLastConnected);
			ThePlayer[p_Donation] = str_to_num(pDonation);
			ThePlayer[p_Level] = str_to_num(pLevel);
			ThePlayer[p_Line] = j;
			ArrayPushArray(TheGang[g_Members],ThePlayer);
			switch(SaveType)
			{
				case 0: // STEAMID
					TrieSetCell(g_GangsPlayers,ThePlayer[p_STEAMID],TheGang[g_ID]);
				case 1: // IP
					TrieSetCell(g_GangsPlayers,ThePlayer[p_IP],TheGang[g_ID]);
				case 2: // IP+STEAMID
				{
					new p_STEAM_IP[70];
					formatex(p_STEAM_IP,charsmax(p_STEAM_IP),"%s%s",ThePlayer[p_IP],ThePlayer[p_STEAMID]);
					TrieSetCell(g_GangsPlayers,p_STEAM_IP,TheGang[g_ID]);
				}
			}
		}
		ArrayPushArray(g_Gangs,TheGang);
	}
}

public plugin_end()
{
	new FileLocation[128];
	get_configsdir(FileLocation,charsmax(FileLocation));
	format(FileLocation,charsmax(FileLocation),"%s/%s",FileLocation,szFileName);
	new TheGang[GangInfo],ThePlayer[PlayerInfo];
	for(new i; i < ArraySize(g_Gangs); i++)
	{
		ArrayGetArray(g_Gangs,i,TheGang);
		new LineText[192];
		formatex(LineText,charsmax(LineText),"%d %s %d %d %d %d %d %d",TheGang[g_ID],TheGang[g_Name],TheGang[g_Donation],TheGang[g_NextCash],TheGang[g_GetCash],TheGang[g_HealRegaration],TheGang[g_Damage],TheGang[g_MaxMembers]);
		write_file(FileLocation,LineText,TheGang[g_Line]);
		for(new j; j < ArraySize(TheGang[g_Members]); j++)
		{					
			new GangFileLocation[128];
			get_configsdir(GangFileLocation,charsmax(GangFileLocation));
			format(GangFileLocation,charsmax(GangFileLocation),"%s/%s",GangFileLocation,TheGang[g_Name]);
			ArrayGetArray(TheGang[g_Members],j,ThePlayer);
			replace_all(ThePlayer[p_Name],charsmax(ThePlayer[p_Name])," ","#$");
			new LineText[192];
			formatex(LineText,charsmax(LineText),"%s %s %s %d %d %d",ThePlayer[p_Name],ThePlayer[p_STEAMID],ThePlayer[p_IP],ThePlayer[p_LastConnected],ThePlayer[p_Donation],ThePlayer[p_Level]);
			write_file(FileLocation,LineText,TheGang[g_Line]);
		}
	}
}
*/


stock sColorChat( const iPlayer, const szMsg[ ], { Float, Sql, Resul, _ } : ... )        
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
