Scriptname Stentorious:CommandAnimations:CompanionAlias extends RefCollectionAlias

Group Base
	; actors
	Actor Property PlayerRef Auto Const Mandatory
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

Event OnCommandModeGiveCommand(ObjectReference akSenderRef, int aeCommandType, ObjectReference akTarget)

	Stentorious:CommandAnimations:Quest myQuest = GetOwningQuest() as Stentorious:CommandAnimations:Quest

	;Debug.Trace("Companion Command Animations: Give Command " + aeCommandType + " to " + akSenderRef.GetSelfAsActor())

	; Prevent anim on mod init
	if myQuest.iCommandModeActive < 2 && myQuest.iCommandModeActive > -1
		if myQuest.iCommandModeActive == 1
			myQuest.iCommandModeActive = 2
		endif
		return
	endif

	; Condition checks
	if PlayerRef.IsDead() || PlayerRef.GetAnimationVariableBool("IsFirstPerson") == false ; || PlayerRef.IsInScene()
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
Event OnCommandModeEnter(ObjectReference akSenderRef)
	;Debug.Trace("Companion Command Animations: Enter mode")
	(GetOwningQuest() as Stentorious:CommandAnimations:Quest).iCommandModeActive = 1
EndEvent

; Event received when the player begins commanding this actor.
Event OnCommandModeExit(ObjectReference akSenderRef)
	;Debug.Trace("Companion Command Animations: Exit mode")
	(GetOwningQuest() as Stentorious:CommandAnimations:Quest).iCommandModeActive = -1
EndEvent