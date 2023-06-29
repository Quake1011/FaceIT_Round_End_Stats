#include <csgo_colors>
#include <sdktools>

#define TAG "[FACEIT^] "

public Plugin myinfo = 
{ 
	name = "FaceIT Round End Stats", 
	author = "Palonez", 
	description = "FaceIT Round End Stats", 
	version = "1.0", 
	url = "https://github.com/Quake1011" 
};

int g_iDamage[MAXPLAYERS+1][MAXPLAYERS+1];
int g_iHits[MAXPLAYERS+1][MAXPLAYERS+1];

public void OnPluginStart()
{
	HookEvent("round_end", OnRoundEnd, EventHookMode_Post);
	HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Post);
	
	LoadTranslations("faceit_round_end_stats.phrases");
}

public void OnPlayerHurt(Event hEvent, const char[] sEvent, bool bdb)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	int attacker = GetClientOfUserId(hEvent.GetInt("attacker"));

	if(0 < client <= MaxClients && IsClientInGame(client) && 0 < attacker <= MaxClients && IsClientInGame(attacker))
	{
		g_iDamage[attacker][client] += hEvent.GetInt("dmg_health");
		g_iHits[attacker][client]++;
	}
}

public void OnRoundEnd(Event hEvent, const char[] sEvent, bool bdb)
{
	char buffer[2048], buff[256+sizeof(buffer)], teams[2][128];
	
	GetConVarString(FindConVar("mp_teamname_2"), teams[0], sizeof(teams[]));
	GetConVarString(FindConVar("mp_teamname_1"), teams[1], sizeof(teams[]));
	
	Format(buff, sizeof(buff), "{GREEN}%t%t", "phrase3", "phrase2", teams[0], GetTeamScore(2),GetTeamScore(3), teams[1]);
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			for(int j = 1; j <= MaxClients; j++)
			{
				if(IsClientInGame(j))
				{
					if(GetClientTeam(j) > 1 && GetClientTeam(i) > 1 && GetClientTeam(i) != GetClientTeam(j))
					{
						Format(buffer, sizeof(buffer), "{GREEN}%t%t", "phrase3", "phrase1", g_iDamage[i][j], g_iHits[i][j], g_iDamage[j][i], g_iHits[j][i], j, GetClientHealth(j));
						StrCat(buff, sizeof(buff), buffer);
					}
				}
			}
			TrimString(buff);
			CGOPrintToChat(i, buff);
			
			for(int j = 1; j <= MaxClients; j++)
				g_iDamage[i][j] = g_iHits[i][j] = 0;
		}
	}
}