class PhilosophersStone extends GGKActor;

var AlchemistGoat agMut;

function SetMut(AlchemistGoat newMut)
{
	agMut=newMut;
	SetMassScale( 1000000.f );
	CollisionComponent.WakeRigidBody();
}

function OnGrabbed( Actor grabbedByActor )
{
	super.OnGrabbed(grabbedByActor);

	if(agMut != none)
	{
		agMut.PhilosophersStoneGrabbed(grabbedByActor);
		Destroy();
	}
}

function int GetScore()
{
	return 1073741824;
}

function string GetActorName()
{
	return "Philosopher's Stone";
}

DefaultProperties
{
	Begin Object name=StaticMeshComponent0
		StaticMesh=StaticMesh'MMO_Castle.Mesh.Crystal_01'
		Scale=0.05f
		Materials(0)=Material'CaptureTheFlag.Materials.Red_Mat_01'
	End Object

	bNoDelete=false
}