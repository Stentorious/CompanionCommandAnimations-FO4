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
EndGroup

Event OnCommandModeGiveCommand(ObjectReference akSenderRef, int aeCommandType, ObjectReference akTarget)

	Stentorious:CommandAnimations:Quest myQuest = GetOwningQuest() as Stentorious:CommandAnimations:Quest

	Debug.Trace("Companion Command Animations: Give Command " + aeCommandType + " to " + akSenderRef.GetSelfAsActor())

	; Prevent anim on mod init
	if myQuest.iCommandModeActive < 2 && myQuest.iCommandModeActive > -1
		if myQuest.iCommandModeActive == 1
			myQuest.iCommandModeActive = 2
		endif
		return
	endif

	; Condition checks
	if PlayerRef.IsDead() || PlayerRef.IsInScene() != 0 || PlayerRef.GetAnimationVariableBool("IsFirstPerson") == false
		return
	endif

	; Play idle
	if aeCommandType == 2
		PlayerRef.PlayIdle(CompanionCommand_Follow)
	elseif aeCommandType == 3
		PlayerRef.PlayIdle(CompanionCommand_Go)
	elseif aeCommandType == 4
		PlayerRef.PlayIdle(CompanionCommand_Attack)
	elseif aeCommandType == 5 || aeCommandType == 6
		PlayerRef.PlayIdle(CompanionCommand_Interact)
	elseif aeCommandType == 7
		PlayerRef.PlayIdle(CompanionCommand_Hold)
	endif

EndEvent

; Event received when the player begins commanding this actor.
Event OnCommandModeEnter(ObjectReference akSenderRef)
	Debug.Trace("Companion Command Animations: Enter mode")
	(GetOwningQuest() as Stentorious:CommandAnimations:Quest).iCommandModeActive = 1
EndEvent

; Event received when the player begins commanding this actor.
Event OnCommandModeExit(ObjectReference akSenderRef)
	Debug.Trace("Companion Command Animations: Exit mode")
	(GetOwningQuest() as Stentorious:CommandAnimations:Quest).iCommandModeActive = -1
EndEvent