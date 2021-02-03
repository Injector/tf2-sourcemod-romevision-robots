#include <sourcemod>
#include <tf2_stocks>
#include <tf2attributes>

new Handle:wearCall;
new Handle:wearConfig;
new Handle:enabled;

new bool:isRobot[MAXPLAYERS+1];


/*	полезные ссылки
	https://wiki.alliedmods.net/Team_fortress_2_item_definition_indexes - список ID оружий и шляп
	https://wiki.teamfortress.com/wiki/Romevision/ru - подробнее о римовидении
*/

/* качества
	Normal Обычное = 0
	Genuine Высшей Пробы = 1
	rarity2 = 2 (не используется)
	Vintage Старой закалки = 3
	rarity3 = 4 (не используется)
	Unusual Необычного типа = 5
	Unique Уникальный = 6
	Community Члена сообщества = 7
	Valve Сотрудника Valve = 8
	Self-Made Ручной сборки = 9
	Customized = 10 (вроде не используется)
	Strange Странного типа = 11
	Completed Завершенного типа = 12 (не используется)
	Haunted Призрачного = 13
	Collector's Из колекции= 14
	Decorated Украшенное = 15
*/

// уровень шляп может быть от 1 до 100

public Plugin:myinfo = 
{
	name = "Romevision Robots",
	author = "BM",
	description = "Turns bots into Romevision robots",
	version = "1.0",
	url = "https://vk.com/mftwo"
}
// ставит шляпы на клиента
// setting hats forclient
void ISetRobotWearables(client, TFClassType class)
{
		if (class == TFClass_Unknown)
	{
	return;
	}
	
		if(class == TFClass_Scout)
		{
				ICreateHat(client, 30153);
				ICreateHat(client, 30154);
				//PrintToServer("[ROM BOTS] Created Hats for Scout");
		}
		else if (class == TFClass_Sniper)
		{
				ICreateHat(client, 30155);
				ICreateHat(client, 30156);
				//PrintToServer("[ROM BOTS] Created Hats for Sniper");
		}
		else if (class == TFClass_Soldier)
		{
				ICreateHat(client, 30157);
				ICreateHat(client, 30158);
				//PrintToServer("[ROM BOTS] Created Hats for Soldier");
		}
		else if (class == TFClass_DemoMan)
		{
				ICreateHat(client, 30143);
				ICreateHat(client, 30144);
				//PrintToServer("[ROM BOTS] Created Hats for Demoman");
		}
		else if (class == TFClass_Medic)
		{
				ICreateHat(client, 30149);
				ICreateHat(client, 30150);
				//PrintToServer("[ROM BOTS] Created Hats for Medic");
		}
		else if (class == TFClass_Heavy)
		{
				ICreateHat(client, 30147);
				ICreateHat(client, 30148);
				//PrintToServer("[ROM BOTS] Created Hats for Heavy");
		}
		else if (class == TFClass_Pyro)
		{
				ICreateHat(client, 30151);
				ICreateHat(client, 30152);
				//PrintToServer("[ROM BOTS] Created Hats for Pyro");
		}
		else if (class == TFClass_Spy)
		{
				ICreateHat(client, 30159);
				ICreateHat(client, 30160);
				//PrintToServer("[ROM BOTS] Created Hats for Spy");
		}
		else if (class == TFClass_Engineer)
		{
				ICreateHat(client, 30145);
				ICreateHat(client, 30146);
				//PrintToServer("[ROM BOTS] Created Hats for Engineer");
		}
}
// ставит модель робота на клиента
// set robot model for client
void ISetRobotModel(client, TFClassType:class)
{
	if (class == TFClass_Unknown)
	{
	return;
	}
	new String:m[PLATFORM_MAX_PATH];
	new String:c[10];
	IGetNameOfClass(class, c, sizeof(c));
	Format(m, sizeof(m), "models/bots/%s/bot_%s.mdl",c,c);
	ReplaceString(m, sizeof(m), "demoman", "demo", false);
	SetVariantString(m);
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	isRobot[client] = true;
}

// команда что-бы стать роботом
// забаговано
// command to be robot
// bugged
Action IRobotCommand(client, args)
{
	if(isRobot[client])
	{
		ISetHumanModel(client, TF2_GetPlayerClass(client));
	}
	else
	{
	ISetRobotModel(client, TF2_GetPlayerClass(client));
	ISetRobotWearables(client, TF2_GetPlayerClass(client));
	}
}

void ISetHumanModel(client, TFClassType:class)
{
	if( class == TFClass_Unknown)
	{
	return;
	}
	new String:m[PLATFORM_MAX_PATH];
	new String:c[10];
	IGetNameOfClass(class,c,sizeof(c));
	Format(m, sizeof(m), "models/player/%s.mdl",c);
	ReplaceString(m, sizeof(m), "demoman", "demo", false);
	SetVariantString(m);
	AcceptEntityUnput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	isRobot[client] = false;
	
}

ICreateHat(int:client, int:id)
{
	new int:h = CreateEntityByName("tf_wearable");
	if(!IsValidEntity(h))
	{
		return;
	}
	
	new String:e[64];
	GetEntityNetClass(h,e,sizeof(e));
	SetEntData(h, FindSendPropInfo(e,"m_iItemDefinitionIndex"), id);
	SetEntData(h, FindSendPropInfo(e,"m_bInitialized"), 1);
	SetEntData(h, FindSendPropInfo(e,"m_iEntityQuality"), 6); // 6 это уникальное качество
	SetEntData(h, FindSendPropInfo(e, "m_iEntityLevel"), 100); // уровень варьируется от 1 до 100
	DispatchSpawn(h);
	SDKCall(wearCall, client, h);
}

public OnPluginStart()
{
	wearConfig= LoadGameConfigFile("tf2romebots.offsets");
	if(!wearConfig)
	{
		SetFailState("No tf2romebots.offsets.txt in sourcemod/gamedata");
	}
	//RegConsoleCmd("sm_romebot", IRobotCommand); // забаговано // bugged
	enabled = CreateConVar("rb_enabled", "1.0",	"",FCVAR_NOTIFY|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	
	// подготавливается SDKCall что-бы надевать шляпы на ботов
	// prepare SDKCall for equip hats
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(wearConfig, SDKConf_Virtual, "EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	wearCall = EndPrepSDKCall();
	
	if(!wearCall)
	{
		SetFailState("Error with SDKCall for EquipWearable, check your tf2romebots.offsets");
	}
	
	HookEvent("post_inventory_application", IEventPIA, EventHookMode_Post);
	HookEvent("player_spawn", ISpawnPlayer);
	
	AddNormalSoundHook(RobotSoundHook);
}

// игрок спавнится, получаем клиента
// если клиент бот то даем ему вещи, если нет то выдаем римовидение
// player spawning, getting client
// if client is a bot, then giving him items, if not then giving romevision
public IEventPIA(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(enabled))
	{
		return;
	}
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (client == 0 || !IsClientInGame(client) || IsClientReplay(client) || IsClientSourceTV(client))
	{
		return;
	}
	
	new TFClassType:class = TF2_GetPlayerClass(client);
	
	if(class == TFClass_Unknown)
	{
		return;
	}
	
	if (IsFakeClient(client))
	{
		ISetRobotModel(client, class);
		ISetRobotWearables(client, class);
	}
	else
	{
		// броня не появится, если мы не включим игроку римовидение, 4.0 - римовидение
		// hats will be invisible if client will be withour romevision, 4.0 is romevision value
		TF2Attrib_SetByName(client, "vision opt in flags", 4.0);
	}
}

public Action:ISetRobotModelTimer(Handle:timer, any:client)
{
	if(IsFakeClient(client))
	{
		if(TF2_GetPlayerClass(client) == TFClass_Unknown)
		{
		return;
		}
		ISetRobotModel(client, TF2_GetPlayerClass(client));
	}
}

public ISpawnPlayer(Handle:event, const String:name[], bool:dontBroadcast)
{
		if (!GetConVarBool(enabled))
	{
		return;
	}
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (client == 0 || !IsClientInGame(client) || IsClientReplay(client) || IsClientSourceTV(client))
	{
		return;
	}
	
	new TFClassType:class = TF2_GetPlayerClass(client);
	
	if(class == TFClass_Unknown)
	{
		return;
	}
	
	if (!IsFakeClient(client))
	{
		// иногда римовидение может быть не добавлено когда игрок спавнится, поэтому навсякий случай еще во второй раз добавляет
		// sometimes romevision cannot be added first time, we'll add romevision twice
		TF2Attrib_SetByName(client, "vision opt in flags", 4.0);
	}
	else
	{
		// если у бота уже установлена модель, но не робота, то мы ставим модель через таймеры
		// if bot already has model, but not robot model, then we're setting model with timers
		CreateTimer(0.00, ISetRobotModelTimer, client);
		CreateTimer(0.01, ISetRobotModelTimer, client);
		CreateTimer(0.05, ISetRobotModelTimer, client);
		CreateTimer(0.25, ISetRobotModelTimer, client);
		CreateTimer(0.50, ISetRobotModelTimer, client);
		CreateTimer(0.75, ISetRobotModelTimer, client);
		CreateTimer(1.00, ISetRobotModelTimer, client);
	}
}

stock IGetNameOfClass(TFClassType:class, String:name[], maxlen)
{
	switch (class)
	{
		case TFClass_Scout: Format(name, maxlen, "scout");
		case TFClass_Soldier: Format(name, maxlen, "soldier");
		case TFClass_Pyro: Format(name, maxlen, "pyro");
		case TFClass_DemoMan: Format(name, maxlen, "demoman");
		case TFClass_Heavy: Format(name, maxlen, "heavy");
		case TFClass_Engineer: Format(name, maxlen, "engineer");
		case TFClass_Medic: Format(name, maxlen, "medic");
		case TFClass_Sniper: Format(name, maxlen, "sniper");
		case TFClass_Spy: Format(name, maxlen, "spy");
	}
}

// звуки робота
// robot sounds

public Action:Hook_TakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
		Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (!GetConVarBool(enabled) || victim < 1 || victim > MaxClients || !isRobot[victim])
	{
		return Plugin_Continue;
	}
	
	if (damage > 0)
	{
		EmitGameSoundToAll("MVM_Robot.BulletImpact", victim);
	}
	return Plugin_Continue;
}
		
public Action:RobotSoundHook(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (!GetConVarBool(enabled) || entity <= 0 || entity > MaxClients || !isRobot[entity])
	{
		return Plugin_Continue;
	}
	
	// звуки не работают пока что
	// sounds don't work
	
	return Plugin_Continue;
	
	if (StrContains(sample, "vo/", false) != -1)
	{
		ReplaceString(sample, sizeof(sample), "vo/", "vo/mvm/norm/");
		PrecacheSound(sample);
		return Plugin_Changed;
	}
	else if (StrContains(sample, "footsteps/", false) != -1)
	{
		if (GetGameSoundParams("MVM.BotStep", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			if (TF2_GetPlayerClass(entity) == TFClass_Medic)
			{
				return Plugin_Stop;
			}
			else
			{
				PrecacheSound(sample);
				return Plugin_Changed;
			}
		}
	}
	// Fall damage
	else if (StrContains(sample, "player/pl_fallpain", false) != -1)
	{
		if (GetGameSoundParams("MVM.FallDamageBots", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Pyro Axes
	else if (StrContains(sample, "weapons/axe_hit_flesh", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_FireAxe.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Third degree
	else if (StrContains(sample, "weapons\3rd_degree_hit_0", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_3rd_degree.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Sandman
	else if (StrContains(sample, "weapons/bat_baseball_hit_flesh", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_BaseballBat.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Spy knives
	else if (StrContains(sample, "weapons/blade_hit", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Knife.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Equalizer, Swords
	else if (StrContains(sample, "weapons/blade_slice_", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_PickAxe.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Bottle
	else if (StrContains(sample, "weapons/bottle_hit_flesh", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Bottle.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}	
	else if (StrContains(sample, "weapons/bottle_intact_hit_flesh", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Bottle.IntactHitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	else if (StrContains(sample, "weapons/bottle_broken_hit_flesh", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Bottle.BrokenHitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Generic melee (Kukri, Fist, Bonesaw, Wrench)
	else if (StrContains(sample, "weapons/cbar_hitbod", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Crowbar.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Stock bat
	else if (StrContains(sample, "weapons/bat_hit", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Bat.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	//Eviction Notice
	else if (StrContains(sample, "weapons\eviction_notice_0", false) != -1)
	{
		if (StrContains(sample, "crit", false) != -1)
		{
			if (GetGameSoundParams("MVM_EvictionNotice.ImpactCrit", channel, level, volume, pitch, sample, sizeof(sample), entity))
			{
				PrecacheSound(sample);
				return Plugin_Changed;
			}
		}
		else
		{
			if (GetGameSoundParams("MVM_EvictionNotice.Impact", channel, level, volume, pitch, sample, sizeof(sample), entity))
			{
				PrecacheSound(sample);
				return Plugin_Changed;
			}
		}
	}
	// Fists of Steel
	else if (StrContains(sample, "weapons/metal_gloves_hit_flesh", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_MetalGloves.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	else if (StrContains(sample, "weapons/metal_gloves_hit_crit", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_MetalGloves.CritHit", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	//Sharp Dresser
	else if (StrContains(sample, "weapons\\spy_assassin_knife_impact_", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Assassin_Knife.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	else if (StrContains(sample, "weapons\\spy_assassin_knife_bckstb", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Assassin_Knife.Backstab", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Huntsman / Crusader's Crossbow arrows
	else if (StrContains(sample, "weapons/fx/rics/arrow_impact_flesh", false) != -1)
	{
		if (GetGameSoundParams("MVM_Weapon_Arrow.ImpactFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	// Frying Pan
	else if (StrContains(sample, "weapons/pan/melee_frying_pan", false) != -1)
	{
		if (GetGameSoundParams("MVM_FryingPan.HitFlesh", channel, level, volume, pitch, sample, sizeof(sample), entity))
		{
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}