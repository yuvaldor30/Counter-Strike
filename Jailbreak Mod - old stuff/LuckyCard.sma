/* Plugin generated by pG`-Studio */

#include <amxmodx>
#include <amxmisc>
// #include <fvault>

#define Price 7500
#define MaxTickets 150
#define CD_TASK 101

#define TAG "eTs"
#define Chat_TAG "eTs"
#define s_IP "31.168.169.42:40800"

#define Year_Expired 2018
#define Month_Expired 1

new Tickets[33],Running[33],CD[33],PrizeAmount[33],u_Amount[33],bool:PremiumBuy[33],bool:PremiumUse[33];

native get_client_cash(index)
native set_client_cash(index,amount)
native is_user_premium(index)
/*

public client_connect( id )
	CmdLoad(id)
public client_disconnect( id )
	CmdSave(id)
*/
//new szVault[] = "LuckyCard";
	
public plugin_init() {
	register_plugin("Lucky Ticket","1.0","MJ")
	new Year[6],Month[3],year,month,serverIP[20];
	format_time(Year,charsmax(Year),"%Y",get_systime())
	format_time(Month,charsmax(Month),"%m",get_systime())
	year = str_to_num(Year);
	month = str_to_num(Month);
	get_user_ip(0,serverIP,charsmax(serverIP),0);
	if((year > Year_Expired || (year == Year_Expired && month >= Month_Expired)) || (!equali(s_IP,serverIP)))
		set_fail_state("Mod Time has been expired or Your Server IP is not allowed");
	
	register_clcmd("say","SayHandler");
	register_clcmd("buy_tickets","BuyPremium");
	register_clcmd("use_tickets","UsePremium");
	
	register_concmd("amx_add_tickets","AddCmd");
	register_concmd("amx_set_tickets","SetCmd");
	register_concmd("amx_se2t_tickets","SetCmd");
	register_concmd("amx_remove_tickets","RemoveCmd");
	register_concmd("amx_reset_tickets","ResetCmd");
}
		
public plugin_natives()
{
	register_native("get_user_tickets","_get_user_tickets");
	register_native("set_user_tickets","_set_user_tickets");
}

public _get_user_tickets(plugin,param)
{
	new index = get_param(1);
	return Tickets[index];
}

public _set_user_tickets(plugin,param)
{
	new index = get_param(1);
	new Amount = get_param(2);
	Tickets[index] = Amount;
}

public SayHandler(id)
{
	new Msg[192],Arg[3][64];
	read_argv(1,Msg,charsmax(Msg));
	parse(Msg,Arg[0],63,Arg[1],63,Arg[2],63);
	new player = cmd_target(player,Arg[1],8);
	new TicketsAmount = str_to_num(Arg[2])
	if(equali(Arg[0],"/tickets") || equali(Arg[0],"/ticket"))
	{
		if(equali(Arg[1],"") || id == player)
			return ColorChat(id,"You have ^4%d ^1lucky tickets",Tickets[id]);
		else if(!player)
			return ColorChat(id,"The player doesn't exist.");	
		ColorChat(id,"^3%s ^1has ^4%d ^1lucky tickets",get_name(player),Tickets[player]);
		return 1;
	}
	else if(equali(Arg[0],"/lucky") || equali(Arg[0],"/luckycard"))
		return LuckyMenu(id)
	else if(equali(Arg[0],"/transferlucky") || equali(Arg[0],"/transfertickets") || equali(Arg[0],"/transferticket") || equali(Arg[0],"/tt") || equali(Arg[0],"/tl"))
	{
		if(equali(Arg[1],"") || equali(Arg[2],""))
			return ColorChat(id,"^1Syntax: /^4tt ^1<^3player^1> <^3amount^1>");
		if(!player || player == id)
			return ColorChat(id,"The player doesn't exist.");
		else
		{
			if(!str_to_num(Arg[2]))
				return ColorChat(id,"^1Syntax: /^4tt ^1<^3player^1> <^3amount^1>");
			else if(TicketsAmount > Tickets[id])
				return ColorChat(id,"You don't have ^4%d ^1tickets",TicketsAmount)
			else if(TicketsAmount < 1)
				return ColorChat(id,"You cannot send ^4%d ^1tickets",TicketsAmount)
			else if(TicketsAmount + Tickets[player] > 150)
				return ColorChat(id,"You cannot send ^4%d ^1tickets, ^3%s ^1cannot over ^4%d ^1tickets",TicketsAmount,get_name(player),MaxTickets);
			else
			{
				//if(TicketsAmount < 1) return ColorChat(id,"Debug 1.");
				Tickets[id] -= TicketsAmount;
				Tickets[player] += TicketsAmount;	
				ColorChat(id,"You ^1have tranfsered ^4%d ^1tickets to the player ^3%s^1.",TicketsAmount,get_name(player));
				return ColorChat(player,"You ^1have got ^4%d ^1tickets from the player ^3%s^1.",TicketsAmount,get_name(id));
			}
		}
	}
	return 0;
}
//CallBacks
/*
	new bcb = menu_makecallback("buyCB");
	new ucb = menu_makecallback("useCB");
	new premiumbuycb = menu_makecallback("premiumbuyCB");
	new premiumusecb = menu_makecallback("premiumuseCB");
	new premiumfusecb = menu_makecallback("fastuseCB");
*/
public buyCB(id) 
{
	if(get_client_cash(id) < Price || Tickets[id] > 149)
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public useCB(id)
{
	if((Tickets[id] < 1) || Running[id])
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public premiumbuyCB(id) 
{
	if(Tickets[id] >= 150 || get_client_cash(id) < Price || !is_user_premium(id))
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}

public premiumuseCB(id) 
{
	if(Tickets[id] <= 0 || Running[id] || !is_user_premium(id))
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}
public fastuseCB(id)
{
	if((Tickets[id] < 1) || Running[id] || !is_user_premium(id))
		return ITEM_DISABLED;
	return ITEM_ENABLED;
}
	
public BuyPremium(id)
{
	if(!PremiumBuy[id])
		return ColorChat(id,"You must use ^3choose buy amount ^1option from the menu.");
	new Msg[192];
	read_argv(1,Msg,charsmax(Msg))
	new TicketsAmount = str_to_num(Msg);
	if((!str_to_num(Msg) || TicketsAmount < 1) && !equali(Msg,"all"))
		return ColorChat(id,"You must enter ^3numbers^1 ^1or ^3all.");
	if(Tickets[id] >= MaxTickets)
		return ColorChat(id,"You are already have ^3max tickets^1.");
	if(equali(Msg,"all"))
	{
		new cash = get_client_cash(id);
		new Tick;
		new Max = MaxTickets - Tickets[id];
		while(cash >= Price && Tick < Max)
		{
			Tick++;
			cash -= Price;
		}
		TicketsAmount = Tick;
	}
	if(Tickets[id] + TicketsAmount > MaxTickets)
		return ColorChat(id,"You cannot over the ^3max tickets^1. ^4%d",TicketsAmount);
	if(get_client_cash(id) < Price * TicketsAmount)
		return ColorChat(id,"You don't have ^3enough cash ^1to buy ^4%d ^1tickets.",TicketsAmount);
	
	set_client_cash(id,get_client_cash(id) - Price*TicketsAmount);
	ColorChat(id,"You have bought ^4%d ^1tickets",TicketsAmount);
	Tickets[id] += TicketsAmount;
	PremiumBuy[id] = false;
	return LuckyMenu(id);
}
public UsePremium(id)
{
	if(!PremiumUse[id])
		return ColorChat(id,"You must use ^3choose use amount ^1option from the menu.");
	new Msg[192];
	read_argv(1,Msg,charsmax(Msg))
	new TicketsAmount = str_to_num(Msg);
	if(!str_to_num(Msg) && !equali(Msg,"all"))
		return ColorChat(id,"You must enter ^3numbers^1 ^1or ^3all.");
	if(equali(Msg,"all"))
		TicketsAmount = Tickets[id];
	if(Tickets[id] < TicketsAmount || TicketsAmount < 1)
		return ColorChat(id,"You cannot use over than your ^3tickets amount^1.")
	
	ColorChat(id,"You have used ^4%d ^1tickets",TicketsAmount);
	PremiumUse[id] = false;
	u_Amount[id] = TicketsAmount;
	Running[id] = true;
	CD[id] = 3;
	return StartLotto(id);
}

//End CallBacks
//Menu
public LuckyMenu (id)
{
	new Info[512];
	formatex(Info,charsmax(Info),"\r[ \w%s \r] \wLucky Ticket Menu^n^n\d- \yTicket Price: \r%d ^n\d- \yMax Prize Amount: \r500000 \wCash ^n\d- \yMax Tickets Amount: \r%d \wTickets ^n\d- \yCash Amount: \r%d \wCash^n\d- \yTickets Amount: \r%d \wTickets^n",TAG,Price,MaxTickets,get_client_cash(id),Tickets[id]);
	new hMenu = menu_create(Info,"LuckyHandler");
	
	new bcb = menu_makecallback("buyCB");
	new ucb = menu_makecallback("useCB");
	new premiumbuycb = menu_makecallback("premiumbuyCB");
	new premiumusecb = menu_makecallback("premiumuseCB");
	new premiumfusecb = menu_makecallback("fastuseCB");
	
	menu_additem(hMenu,"\wBuy Ticket",.callback=bcb);
	menu_additem(hMenu,"\wUse Ticket^n^n\d- \yPremium Gets:",.callback=ucb);
	menu_additem(hMenu,"\wChoose Buy Amount \d(\yall for max\d)",.callback = premiumbuycb);
	menu_additem(hMenu,"\wChoose Use Amount \d(\yall for max\d)",.callback = premiumusecb);
	menu_additem(hMenu,"\wUse Fast Use",.callback=premiumfusecb);
	
	menu_display(id,hMenu);
	return 1;
}
public LuckyHandler (id,hMenu,Item)
{
	switch (Item)
	{
		case MENU_EXIT: menu_destroy(hMenu);
		case 0: 
		{
			if(get_client_cash(id) < Price) return 1;
			Tickets[id] ++;
			set_client_cash(id,get_client_cash(id) -Price)
			return LuckyMenu(id);
		}
		case 1:
		{
			if ((Tickets[id] < 1) || Running[id]) return 1;
			Tickets[id] --;
			Running[id] = true;
			u_Amount[id] = 1;
			CD[id] = 5;
			StartLotto(id);
		}
		case 2: 
		{
			if(Tickets[id] >= 150 || get_client_cash(id) < Price || !is_user_premium(id))
				return 1;
			PremiumBuy[id] = true;
			client_cmd(id,"messagemode buy_tickets");
		}
		case 3: 
		{
			if(Tickets[id] <= 0 || Running[id] || !is_user_premium(id))
				return 1;
			PremiumUse[id] = true;
			client_cmd(id,"messagemode use_tickets");
		}
		case 4:
		{
			if ((Tickets[id] < 1) || Running[id]) return 1;
			Tickets[id] --;
			Running[id] = true;
			u_Amount[id] = 1;
			CD[id] = 0;
			StartLotto(id);
			return LuckyMenu(id);
		}/*
		case 5:
		{
			if ((Tickets[id] < 1) || Running[id]) return 1;
			Running[id] = true;
			CD[id] = 3;
			u_All[id] = true;
			StartLotto(id);
		}*/
	}
	return 1;
}
//Prize Chance
public CheckPrize (id)
{
	new Number[33];
	Number[id] = random_num(1,100)
	if (Number[id] > 0 && Number[id] < 26)
		PrizeAmount[id] = random_num(0,500);
	if (Number[id] > 25 && Number[id] < 46)
		PrizeAmount[id] = random_num(500,1000);
	if (Number[id] > 45 && Number[id] < 66)
		PrizeAmount[id] = random_num(1000,3000);
	if (Number[id] > 65 && Number[id] < 86)
		PrizeAmount[id] = random_num(3000,5000);
	if (Number[id] > 80 && Number[id] < 91)
		PrizeAmount[id] = random_num(5000,15000);
	if (Number[id] > 90 && Number[id] < 95)
		PrizeAmount[id] = random_num(15000,30000);
	if(Number[id] > 94 && Number[id] < 99)
		PrizeAmount[id] = random_num(30000,50000);
	if(Number[id] > 98 && Number[id] < 100)
		PrizeAmount[id] = random_num(50000,150000);
	if(Number[id] == 100)
	{
		new Chance[33];
		Chance[id] = random_num(1,10)
		if (Chance[id] == 1)
			PrizeAmount[id] = 500000;
		else
			PrizeAmount[id] = random_num(50000,150000);
	}
	return PrizeAmount[id];
}
//Prize Messages
public StartLotto(id)
{
	new t_Prize[33];
	if(CD[id] < 1)
	{
		set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 15.0,_,_,4)
		if (u_Amount[id] != 0 && u_Amount[id] != 1)
		{
			new times[33],Use;
			if(u_Amount[id] == -1)
				Use = Tickets[id];
			else
				Use = u_Amount[id];
			for(new i; i < Use; i++)
			{
				CheckPrize(id);
				times[id] ++;
				t_Prize[id] += CheckPrize(id);
				Tickets[id] --;
				continue;
			}
			if(times[id] > 1)
				ColorChat(0,"^3Premium %s ^1has won ^3%d ^1cash from ^3%d ^4Lucky Tickets^1 ^1(%s%d Cash).",get_name(id),t_Prize[id],times[id],t_Prize[id]-(times[id]*Price) > 0 ? "+" : "" ,t_Prize[id]-(times[id]*Price));
			else
				ColorChat(id,"You ^1have won ^3%d ^1cash from ^3%d ^4Lucky Tickets^1 ^1(%s%d Cash).",t_Prize[id],times[id],t_Prize[id]-(times[id]*Price) > 0 ? "+" : "",t_Prize[id]-(times[id]*Price));
		}
		else
		{
			CheckPrize(id);
			show_hudmessage(id, "Congratulation, You won %d Cash!",PrizeAmount[id]);
			if (PrizeAmount[id] > 49999)
				ColorChat(0,"%s ^1has won ^3%d ^1cash from the ^4Lucky Ticket^1.",get_name(id),PrizeAmount[id]); 
			if (PrizeAmount[id] < 49999)
				ColorChat(id,"You ^1have won ^3%d ^1cash from the ^4Lucky Ticket^1.",PrizeAmount[id]); 
			t_Prize[id] = PrizeAmount[id];
		}	
		set_client_cash(id,get_client_cash(id)+t_Prize[id])
		remove_task(id);
		Running[id] = false;
		return 1;
	}
	new szVox[10];
	set_hudmessage(21, 157, 144, -1.0, 0.20, 1, 6.0, 3.0,_,_,4)
	show_hudmessage(id, "You will get your prize amount in %d seconds",CD[id] );
	num_to_word( CD[id], szVox, charsmax( szVox ) );
	client_cmd( id, "spk ^"vox/%s^"", szVox );
	CD[id]--;
	set_task(1.0,"StartLotto",id);
	return 1;
}
//Cmds Add/Set/Remove/Save Tickets
public AddCmd(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) return 1;
	new Args[128],aTarget[32],aTicket[32];
	read_args(Args,charsmax(Args));
	remove_quotes( Args );
	parse( Args,aTarget, charsmax( aTarget ), aTicket,charsmax( aTicket ) );
	if( equali( aTarget, "" ) || equali( aTicket, "" ) )
		return console_print(id,"Usage: amx_add_tickets <Nick> <Tickets>");
	new iPlayer = cmd_target( iPlayer, aTarget,8);
	if(!is_str_num(aTicket))
		return console_print(id,"You need to fill numbers in the Tickets Amount");
	if(!iPlayer)
		return console_print(id,"The Player has not found");
	new iTicket = str_to_num( aTicket );
	if( iTicket < 1)
		return console_print(id,"The Minimum of the value to add ticket is 1");
	if( iTicket > 150)
		return console_print(id,"The Maximum of the value to add ticket is 150");
	Tickets[iPlayer] += iTicket;
	ColorChat(0,"^1Admin: ^4%s ^1has ^3added ^4%d ^1lucky tickets to the player ^4%s",get_name(id),iTicket,get_name(iPlayer));
	if (Tickets[iPlayer] > 150)
		Tickets[iPlayer] = 150;
	return 1;
}

public SetCmd(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) return 1;
	new Args[128],aTarget[32],aTicket[32];
	read_args(Args,charsmax(Args));
	remove_quotes( Args );
	parse( Args,aTarget, charsmax( aTarget ), aTicket,charsmax( aTicket ) );
	if( equali( aTarget, "" ) || equali( aTicket, "" ) )
		return console_print(id,"Usage: amx_set_tickets <Nick> <Tickets>");
	new iPlayer = cmd_target( iPlayer, aTarget,8);
	if(!is_str_num(aTicket))
		return console_print(id,"You need to fill numbers in the Tickets Amount");
	if(!iPlayer)
		return console_print(id,"The Player has not found");
	new iTicket = str_to_num( aTicket );
	if( iTicket < 0)
		return console_print(id,"The Minimum of the value to set ticket is 0");
	if( iTicket > 150)
		return console_print(id,"The Maximum of the value to set ticket is 150");
	Tickets[iPlayer] = iTicket;
	ColorChat(0,"^1Admin: ^4%s ^1has ^3setted ^4%d ^1lucky tickets to the player ^4%s",get_name(id),iTicket,get_name(iPlayer));
	return 1;
}

public RemoveCmd(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) return 1;
	new Args[128],aTarget[32],aTicket[32];
	read_args(Args,charsmax(Args));
	remove_quotes( Args );
	parse( Args,aTarget, charsmax( aTarget ), aTicket,charsmax( aTicket ) );
	if( equali( aTarget, "" ) || equali( aTicket, "" ) )
		return console_print(id,"Usage: amx_remove_tickets <Nick> <Tickets>");
	new iPlayer = cmd_target( iPlayer, aTarget,8);
	if(!is_str_num(aTicket))
		return console_print(id,"You need to fill numbers in the Tickets Amount");
	if(!iPlayer)
		return console_print(id,"The Player has not found");
	new iTicket = str_to_num( aTicket );
	if( iTicket < 1)
		return console_print(id,"The Minimum of the value to remove ticket is 1");
	if( iTicket > 150)
		return console_print(id,"The Maximum of the value to remove ticket is 150");
	Tickets[iPlayer] -= iTicket;
	ColorChat(0,"^1Admin: ^4%s ^1has ^3removed ^4%d ^1lucky tickets to the player ^4%s",get_name(id),iTicket,get_name(iPlayer));
	if (Tickets[iPlayer] < 0)
		Tickets[iPlayer] = 0;
	return 1;
}

public ResetCmd(id)
{
	if(!(get_user_flags(id) & ADMIN_IMMUNITY)) return 1;
	for (new i; i < get_maxplayers(); i++)
	{
		if(!is_user_connected(i)) continue;
		Tickets[i] = 5;
	}
	ColorChat(0,"^1Admin: ^4%s ^1has ^3resetted ^4all online players ^1lucky tickets to^4 5",get_name(id));
	return 1;
}/*
public CmdSave(id)
{
	new szData[ 100 ],szAuth[ 60 ];
	formatex(szAuth,charsmax(szAuth),"%s",GetAuth(id))
	
	formatex( szData, charsmax( szData ), "%d", Tickets[ id ] );
	fvault_set_data( szVault,szAuth, szData );
	
	return 1;
}
public CmdLoad(id)
{
	// cash
	new sztData[ 100 ],szAuth[ 60 ];
	formatex(szAuth,charsmax(szAuth),"%s",GetAuth(id))
	// tickets
	if( ! ( fvault_get_data( szVault, szAuth, sztData, charsmax( sztData ) ) ) )
	{
		fvault_set_data( szVault, szAuth, "2" );
		Tickets[ id ] = 2;
	}
	else
		Tickets[ id ] = str_to_num( sztData );
}
//Stocks
stock GetAuth( id )
{
	static szAuth[ 60 ];
	get_user_authid( id, szAuth, charsmax( szAuth ) );
	if( contain( szAuth, "VALVE_" ) != -1 || contain( szAuth, "ID_LAN" ) != -1 )
		get_user_ip( id, szAuth, charsmax( szAuth ), 1 );
	return szAuth;
}
*/

stock get_name(index)
{
	new szName[32];
	get_user_name(index,szName,charsmax(szName))
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
