globalize_all_functions

#if FSCC_ENABLED && FSU_ENABLED

struct {
	array< entity > loggedin
} admins

/**
 * Gets called after the map is loaded
*/
void function FSA_Init() {
	if( GetConVarBool( "FSA_PREFIX_ADMINS_IN_CHAT" ) )
 		AddCallback_OnReceivedSayTextMessage( FSA_CheckForAdminMessage )

	if( GetConVarBool("FSA_HIGHLIGHT_OWNERS_IN_CHAT") )
		AddCallback_OnReceivedSayTextMessage( FSA_AddOwnerTag )

	FSCC_CommandStruct command
	command.m_UsageUser = "npc <npc> <team>"
	command.m_UsageAdmin = ""
	command.m_Description = "Spawns an npc at your crosshair."
	command.m_Group = "ADMIN"
	command.m_Abbreviations = []
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSA_CommandCallback_NPC
	FSCC_RegisterCommand( "npc", command )

	if( GetConVarBool( "FSA_ADMINS_REQUIRE_LOGIN" ) ) {
		command.m_UsageUser = "login <password>"
		command.m_UsageAdmin = ""
		command.m_Description = "Logs you in if you are registered on the server as an admin."
		command.m_Group = "ADMIN"
		command.m_Abbreviations = []
		command.PlayerCanUse = null
		command.Callback = FSA_CommandCallback_Login
		FSCC_RegisterCommand( "login", command )

		command.m_UsageUser = "logout"
		command.m_UsageAdmin = ""
		command.m_Description = "Logs you out if you are logged in as an admin"
		command.m_Group = "ADMIN"
		command.m_Abbreviations = []
		command.PlayerCanUse = FSA_IsAdmin
		command.Callback = FSA_CommandCallback_Logout
		FSCC_RegisterCommand( "logout", command )
	}
}

/**
 * Returns loggedin admins
*/
array< entity > function FSA_GetLoggedInAdmins() {
	return admins.loggedin
}

/**
 * Gets called when a player sends a chat message
 * @param message The message struct containing information about the chat message
*/
ClServer_MessageStruct function FSA_CheckForAdminMessage( ClServer_MessageStruct message ) {
	if( message.message.find( GetConVarString( "FSCC_PREFIX" ) ) == 0 || message.message.len() == 0 || message.shouldBlock ) {
		message.shouldBlock = true
		return message
	}

	if( FSA_IsAdmin( message.player ) && FSA_IsOwner( message.player ) {
		message.shouldBlock = true
		FSA_SendMessageWithPrefix(message.player, message.message, message.isTeam, "ADMIN")
	}

	return message
}

/**
 * Gets called when someone sends a message and checks if they're the owner. If so it adds the [OWNER] tag
 * @param message The message struct containing information about the chat message
*/
ClServer_MessageStruct function FSA_AddOwnerTag( ClServer_MessageStruct message ) {
	message.shouldBlock = true
	FSA_SendMessageWithPrefix( message.player, message.message, message.isTeam, "OWNER" )
	return message
}

/**
 * Sends a message with a prefix
 * @param from The player who originally sent the message
 * @param message The message string
 * @param isTeamMessage Whether it was sent in team or grobal chat
 * @param prefix The prefix to add
*/
void function FSA_SendMessageWithPrefix(entity from, string message, bool isTeamMessage, string prefix){
	foreach( entity p in GetPlayerArray() ) {
		if( isTeamMessage && p.GetTeam() != from.GetTeam())
			continue
		Chat_ServerPrivateMessage( p, FSU_FmtAdmin() + "["+ prefix +"] " + FSU_FmtEnd() + ((p.GetTeam() == from.GetTeam()) ? "\x1b[111m" : "\x1b[112m" )+ from.GetPlayerName() + FSU_FmtEnd()+ ": "+ message, isTeamMessage, false)
	}
}

/**
 * Returns true if player is an owner
 * @ param player The player to check
*/
bool function FSA_IsOwner( entity player ) {
	array< string > ownerUIDs = split( GetConVarString( "FSA_OWNERS" ), "," )

	if( ownerUIDs.find( player.GetUID() ) != -1 ) {
		return true
	}

	return false
}

/**
 * Returns true if player is an admin
 * @ param player The player to check
*/
bool function FSA_IsAdmin( entity player ) {
	array< string > adminUIDs = split( GetConVarString( "FSA_ADMIN_UIDS" ), "," )

	if( adminUIDs.find( player.GetUID() ) != -1 ) {
		if( !GetConVarBool( "FSA_ADMINS_REQUIRE_LOGIN" ) || GetConVarBool( "FSA_ADMINS_REQUIRE_LOGIN" ) && admins.loggedin.find( player ) != -1 )
			return true
	}

	return false
}

#else
void function FSA_Init() {
	print( "[FSA][ERRR] FSU and FSCC Need to be enabled for FSA to work!!!" )
}
#endif
