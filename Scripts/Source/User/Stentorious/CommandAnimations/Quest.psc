Scriptname Stentorious:CommandAnimations:Quest extends Quest

; #### VARIABLES ####

float modVersion = 0.0
actor kCommandVictimTemp = NONE

; #### PROPERTIES ####

Group Base
	; actors
	Actor Property PlayerRef Auto Const Mandatory
EndGroup

Group Followers
	ReferenceAlias Property DogmeatCompanion Auto Const Mandatory
	ReferenceAlias Property CommandVictimAlias Auto Const Mandatory
EndGroup

Group Mod
	; animations
	Idle Property CompanionCommand_Attack Auto Const Mandatory
	Idle Property CompanionCommand_Hold Auto Const Mandatory
	Idle Property CompanionCommand_Go Auto Const Mandatory
	Idle Property CompanionCommand_Follow Auto Const Mandatory
	Idle Property CompanionCommand_Interact Auto Const Mandatory
	; sound
	Sound Property CompanionCommandFoley_Default Auto Const Mandatory
	Sound Property CompanionCommandFoley_Power Auto Const Mandatory
EndGroup

Group Public
	int Property iCommandModeActive Auto
EndGroup

Group Internal
	; mod version
	float property fModVersion = 1.00 AutoReadOnly
EndGroup


; #### FUNCTIONS ####

Function OnGameLoad()

	; Release Version
	if modVersion < 1.00
		Debug.Trace("Companion Command Animations: Init")
		self.RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
	endif
	modVersion = fModVersion

	RegisterEvents(true)

	iCommandModeActive = 2

EndFunction

Function RegisterEvents(bool abRegister = true)
	if (abRegister)
		RegisterForRemoteEvent(DogmeatCompanion, "OnCommandModeGiveCommand")
		RegisterForRemoteEvent(DogmeatCompanion, "OnCommandModeEnter")
		RegisterForRemoteEvent(DogmeatCompanion, "OnCommandModeExit")
		RegisterForRemoteEvent(CommandVictimAlias, "OnCommandModeGiveCommand")
		RegisterForRemoteEvent(CommandVictimAlias, "OnCommandModeEnter")
		RegisterForRemoteEvent(CommandVictimAlias, "OnCommandModeExit")
		RefreshModSupport()
	else
		UnRegisterForAllRemoteEvents()
	endif
EndFunction

Function RefreshModSupport()
	if Game.IsPluginInstalled("llamaCompanionHeatherv2.esp")	; Heather Casdin
		Quest kQuest = Game.GetFormFromFile(0x00052049, "llamaCompanionHeatherv2.esp") as Quest
		ReferenceAlias HeatherAlias = kQuest.GetAlias(1) as ReferenceAlias
		RegisterForRemoteEvent(HeatherAlias, "OnCommandModeGiveCommand")
		RegisterForRemoteEvent(HeatherAlias, "OnCommandModeEnter")
		RegisterForRemoteEvent(HeatherAlias, "OnCommandModeExit")
	endif
EndFunction


; #### EVENTS ####

Event OnQuestInit()
	OnGameLoad()
EndEvent

Event Actor.OnPlayerLoadGame(Actor akSender)
	OnGameLoad()
EndEvent

Event OnQuestShutdown()
	self.UnregisterForAllEvents()
	RegisterEvents(false)
EndEvent

;Companion command interface commands
;	aeCommandType: Type of Command that is given, which is one of the following:
;    0 - None
;    1 - Call
;    2 - Follow
;    3 - Move
;    4 - Attack
;    5 - Inspect
;    6 - Retrieve
;    7 - Stay
;    8 - Release
;    9 - Heal
Event ReferenceAlias.OnCommandModeGiveCommand(ReferenceAlias akSender, int aeCommandType, ObjectReference akTarget)

	;Debug.Trace("Companion Command Animations: Give Command " + aeCommandType + " to " + akSender.GetActorReference())

	; Handle generic actor commands
	actor kCommandActor = akSender.GetActorReference()
	if CommandVictimAlias.GetActorReference() == kCommandActor
		;Debug.Trace("Companion Command Animations: Command Victim")
		if kCommandVictimTemp != kCommandActor
			;Debug.Trace("Companion Command Animations: Command Victim (Same)")
			iCommandModeActive = 2
			kCommandVictimTemp = kCommandActor
		endif
	endif

	; Prevent anim on mod init
	if iCommandModeActive < 2 && iCommandModeActive > -1
		if iCommandModeActive == 1
			iCommandModeActive = 2
		endif
		return
	endif

	; Condition checks
	if PlayerRef.IsDead(); || PlayerRef.GetAnimationVariableBool("IsFirstPerson") == false  || PlayerRef.IsInScene()
		return
	endif

	; Play idle
	Idle idleAnim = NONE
	if aeCommandType == 2
		idleAnim = CompanionCommand_Follow
	elseif aeCommandType == 3
		idleAnim = CompanionCommand_Go
	elseif aeCommandType == 4
		idleAnim = CompanionCommand_Attack
	elseif aeCommandType == 5 || aeCommandType == 6
		idleAnim = CompanionCommand_Interact
	elseif aeCommandType == 7
		idleAnim = CompanionCommand_Hold
	endif

	if idleAnim != NONE
		PlayerRef.PlayIdle(idleAnim)
		if PlayerRef.IsInPowerArmor()
			CompanionCommandFoley_Power.Play(PlayerRef)
		else
			CompanionCommandFoley_Default.Play(PlayerRef)
		endif
	endif

EndEvent

; Event received when the player begins commanding this actor.
Event ReferenceAlias.OnCommandModeEnter(ReferenceAlias akSender)
	;Debug.Trace("Companion Command Animations: Enter mode")
	iCommandModeActive = 1
EndEvent

; Event received when the player begins commanding this actor.
Event ReferenceAlias.OnCommandModeExit(ReferenceAlias akSender)
	;Debug.Trace("Companion Command Animations: Exit mode")
	iCommandModeActive = -1
EndEvent