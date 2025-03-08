class AlchemistGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;// DONT FORGET TO UPDATE VERSION NUMBER

var float transmutationTimer;
var StaticMeshComponent hatMesh;
var StaticMeshComponent orbMesh;
var int currMatIndex;
var float transmutationEffectRatio;

var AlchemicCircle alcCir;
var bool isTransmuting;

var bool isAlchemistMaster;
var ParticleSystem transmutationTemplate;
var SoundCue transmutationSound;
var ParticleSystem becomeAlchemistMasterTemplate;
var SoundCue becomeAlchemistMasterSound;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;

		hatMesh.SetLightEnvironment( gMe.mesh.LightEnvironment );
		gMe.mesh.AttachComponentToSocket( hatMesh, 'hairSocket' );
		HatMesh.SetHidden(true);

		orbMesh.SetLightEnvironment( gMe.mesh.LightEnvironment );
		gMe.mesh.AttachComponent( orbMesh, 'Spine_01', vect(0.f, 0.f, 30.f));
		TransmuteOrb();

		alcCir=gMe.Spawn(class'AlchemicCircle', gMe,, gMe.Location, Rotator(vect(0, 0, -1)));
		alcCir.SetBase(gMe,, gMe.Mesh, 'JetPackSocket');
		alcCir.SetHidden(true);

		transmutationTemplate.Delay = 0.1f;//Give time to the effect to be rescaled
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	local GGPlayerInputGame localInput;

	if(PCOwner != gMe.Controller)
		return;

	localInput = GGPlayerInputGame( PlayerController( gMe.Controller ).PlayerInput );

	if( keyState == KS_Down )
	{
		if(newKey == 'LEFTCONTROL' || newKey == 'XboxTypeS_DPad_Down')
		{
			if(gMe.Controller != none && GGPlayerControllerGame( gMe.Controller ).mFreeLook)
			{
				TransmuteOrb();
			}
		}

		if( localInput.IsKeyIsPressed( "GBA_AbilityBite", string( newKey ) ) )
		{
			SetTransmuting(true);
			gMe.SetTimer( transmutationTimer, false, NameOf( Transmutation ), self);
		}
	}
	else if( keyState == KS_Up )
	{
		if( localInput.IsKeyIsPressed( "GBA_AbilityBite", string( newKey ) ) )
		{
			if(gMe.IsTimerActive(NameOf( Transmutation ), self))
			{
				gMe.ClearTimer(NameOf( Transmutation ), self);
			}
			SetTransmuting(false);
		}
	}
}

function Transmutation()
{
	local Actor hitAct;
	local vector hitLocation, hitNormal, traceEnd, traceStart;
	local float h, r;

	//If right click, transmute licked item into orb material
	if(gMe.Controller != none && GGPlayerControllerGame( gMe.Controller ).mFreeLook)
	{
		if(gMe.mGrabbedItem != none)
		{
			TransmuteActor(gMe.mGrabbedItem);
		}
		else if(isAlchemistMaster)
		{
			gMe.GetBoundingCylinder(r, h);
			gMe.mesh.GetSocketWorldLocationAndRotation( 'Demonic', traceStart );
			if(IsZero(traceStart))
			{
				traceStart=gMe.Location + (Normal(vector(gMe.Rotation)) * (gMe.GetCollisionRadius() + 30.f));
			}
			traceEnd=traceStart + (Normal(vect(1, 0, -1)) >> gMe.Rotation) * Sqrt(2.f) * (Abs(traceStart.Z - gMe.Location.Z) + h*2.f);
			foreach gMe.TraceActors( class'Actor', hitAct, hitLocation, hitNormal, traceEnd, traceStart )
			{
				if(TransmuteActor(hitAct))
					break;
			}
		}
	}
}

function TransmuteOrb()
{
	local MaterialInterface newMat;
	local string matName;

	newMat=AlchemistGoat(myMut).GetNextMaterial(currMatIndex, matName);
	InitMaterialName(newMat, matName);// Fix weird names after tansmutation
	Transmute(newMat, orbMesh);
}

function InitMaterialName(MaterialInterface matInt, string matName)
{
	local Material mat;
	local MaterialInstance matInst;
	local PhysicalMaterial physMat;

	mat=Material(matInt);
	matInst=MaterialInstance(matInt);
	// Get Phys Mat
	if(mat != none)
	{
		physMat=mat.PhysMaterial;
	}
	else if(matInst != none)
	{
		physMat=matInst.PhysMaterial;
	}
	else
	{
		return;
	}
	// Edit or create mat settings
	if(physMat == none)
	{
		physMat = new class'PhysicalMaterial';
	}
	if(GGPhysicalMaterialProperty(physMat.GetPhysicalMaterialProperty(class'GGPhysicalMaterialProperty')) == none)
	{
		physMat.PhysicalMaterialProperty = new class'GGPhysicalMaterialProperty';
	}
	if(GGPhysicalMaterialProperty(physMat.PhysicalMaterialProperty).GetActorName() != matName)
	{
		GGPhysicalMaterialProperty(physMat.PhysicalMaterialProperty).SetActorName(matName);
	}
	// Set Phys Mat
	if(mat != none)
	{
		mat.PhysMaterial=physMat;
	}
	else if(matInst != none)
	{
		matInst.PhysMaterial=physMat;
	}
}

function bool TransmuteActor(Actor targetAct)
{
	local GGKAsset targetKA;
	local StaticMeshActor targetSMA;
	local DynamicSMActor targetDSMA;
	local ApexDestructibleActor targetADA;
	local Pawn targetPawn;
	local vector effectLoc;
	local bool playEffect;
	local ParticleSystemComponent transmutationEffect;
	local float r, h, diagonal;

	if(targetAct == none)
	{
		return false;
	}

	targetSMA = StaticMeshActor(targetAct);
	targetDSMA = DynamicSMActor(targetAct);
	targetADA = ApexDestructibleActor(targetAct);
	targetPawn = Pawn(targetAct);
	targetKA = GGKAsset(targetAct);

	if(targetSMA != none)
	{
		effectLoc=targetSMA.StaticMeshComponent.GetPosition();
		Transmute(orbMesh.Materials[0], targetSMA.StaticMeshComponent);
		playEffect=true;
	}
	else if(targetDSMA != none)
	{
		effectLoc=targetDSMA.StaticMeshComponent.GetPosition();
		Transmute(orbMesh.Materials[0], targetDSMA.StaticMeshComponent);
		playEffect=true;
	}
	else if(targetADA != none)
	{
		effectLoc=targetADA.StaticDestructibleComponent.GetPosition();
		Transmute(orbMesh.Materials[0], targetADA.StaticDestructibleComponent);
		playEffect=true;
	}
	else if(targetPawn != none)
	{
		effectLoc=targetPawn.Mesh.GetPosition();
		playEffect=Sacrifice(GGPawn(targetPawn));
		if(!playEffect && isAlchemistMaster)
		{
			Transmute(orbMesh.Materials[0], targetPawn.mesh);
			playEffect=true;
		}
	}
	else if(targetKA != none)
	{
		effectLoc=targetKA.SkeletalMeshComponent.GetPosition();
		if(isAlchemistMaster)
		{
			Transmute(orbMesh.Materials[0], targetKA.SkeletalMeshComponent);
			playEffect=true;
		}
	}

	if(playEffect)
	{
		targetAct.GetBoundingCylinder(r, h);
		diagonal=Sqrt(r*r + h*h);
		transmutationEffect=gMe.WorldInfo.MyEmitterPool.SpawnEmitter( transmutationTemplate, effectLoc );
		if(diagonal < 0.1f)
		{
			diagonal=1.f/transmutationEffectRatio;
		}
		transmutationEffect.SetScale( diagonal * transmutationEffectRatio );
		gMe.PlaySound( transmutationSound, true, true, , effectLoc );
	}

	return playEffect;
}

function Transmute(MaterialInterface sourceMaterial, MeshComponent targetComp)
{
	local int index;

	if(sourceMaterial == none || targetComp == none)
		return;

	for(index=0 ; index <targetComp.GetNumElements() ; index++)
	{
		targetComp.SetMaterial(index, sourceMaterial);
	}
}

function SetTransmuting(bool transmuting)
{
	if(transmuting == isTransmuting)
		return;

	isTransmuting=transmuting;
	alcCir.SetHidden(!isTransmuting);
}

/**
 * Called from gameInfo if this is used by players.
 */
function TickMutatorComponent( float deltaTime )
{
	if(isTransmuting)
	{
		//Stop human transmutation of key released or ragdoll or moving
		if(gMe.Controller == none || !GGPlayerControllerGame( gMe.Controller ).mFreeLook || gMe.mIsRagdoll || VSize(gMe.Velocity)>0.1f)
		{
			SetTransmuting(false);
		}
	}
}

function bool Sacrifice(GGPawn gpawn)
{
	local vector spawnLoc;
	local PhilosophersStone ps;
	local int i;

	if(!isTransmuting || gpawn == none || PlayerController(gpawn.Controller) != none)
	{
		return false;
	}

	gMe.DropGrabbedItem();
	for( i = 0; i < gpawn.Attached.Length; i++ )
	{
		if(GGGoat(gpawn.Attached[i]) == none)
		{
			gpawn.Attached[i].ShutDown();
			gpawn.Attached[i].Destroy();
		}
	}
	gpawn.SetPhysics(PHYS_None);
	gpawn.SetLocation(vect(0, 0, -1000));
	gpawn.SetHidden(true);
	gpawn.ShutDown();
	gpawn.Destroy();
	if(AlchemistGoat(myMut).TrandmutedPhilosophersStone())
	{
		gMe.mesh.GetSocketWorldLocationAndRotation( 'Demonic', spawnLoc );
		if(IsZero(spawnLoc))
		{
			spawnLoc=gMe.Location + (Normal(vector(gMe.Rotation)) * (gMe.GetCollisionRadius() + 30.f));
		}
		ps=gMe.Spawn(class'PhilosophersStone',,,spawnLoc);
		ps.SetMut(AlchemistGoat(myMut));
	}
	return true;
}

function SetAlchemistMaster()
{
	if(isAlchemistMaster)
		return;

	gMe.WorldInfo.MyEmitterPool.SpawnEmitter( becomeAlchemistMasterTemplate, gMe.mesh.GetPosition(), Rotator(vect(0, 0, 1)));
	gMe.PlaySound( becomeAlchemistMasterSound );
	hatMesh.SetHidden(false);
	isAlchemistMaster=true;
}

defaultproperties
{
	transmutationTimer=1.f
	currMatIndex=-1
	transmutationEffectRatio=0.005f

	Begin Object class=StaticMeshComponent Name=StaticMeshComp1
		StaticMesh=StaticMesh'Hats.Mesh.WizrdHat'
		Materials(0)=Material'Camper.Materials.CrystalBreath_Mat'
	End Object
	hatMesh=StaticMeshComp1

	Begin Object class=StaticMeshComponent Name=StaticMeshComp2
		StaticMesh=StaticMesh'MMO_ElfForest.Mesh.Lamp_01'
		Scale=0.25f
		Rotation=(Pitch=0, Yaw=-16384, Roll=32768)
		Translation=(X=0, Y=0, Z=5)
	End Object
	orbMesh=StaticMeshComp2

	transmutationTemplate=ParticleSystem'MMO_Effects.Effects.Effects_GenieSmoke_01'
	transmutationSound=SoundCue'Goat_Sound_UI.Cue.CheckPoint_Que'
	becomeAlchemistMasterTemplate=ParticleSystem'MMO_Effects.Effects.Effects_Xcalibur_01'
	becomeAlchemistMasterSound=SoundCue'MMO_SFX_SOUND.Cue.SFX_Level_Up_Cue'
}