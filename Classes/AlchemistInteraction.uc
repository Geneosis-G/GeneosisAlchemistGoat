class AlchemistInteraction extends Interaction;

var AlchemistGoat myMut;

function InitAlchemistInteraction(AlchemistGoat newMut)
{
	myMut=newMut;
}

exec function AlchemistGoatHelp()
{
	myMut.WorldInfo.Game.Broadcast(myMut, "Available spells: WorldMaterialsList / LearnTransmutationMaterial materialName materialSource / ForgetTransmutationMaterial materialName / ResetTransmutationMaterials");
}

exec function LearnTransmutationMaterial(string materialName, MaterialInterface materialSource)
{
	local AlchemicMaterial newMat, oldMat;
	local int index;

	newMat.name = materialName;
	newMat.mat = materialSource;
	index=myMut.alchemicGrimoire.Find('mat', materialSource);
	if(index == INDEX_NONE)
	{
		index=myMut.alchemicGrimoire.Find('name', materialName);
	}

	if(index != INDEX_NONE)
	{
		oldMat=myMut.alchemicGrimoire[index];
		myMut.WorldInfo.Game.Broadcast(myMut, "You already know how to transmute into" @ oldMat.name $ "[" $ oldMat.mat $ "]...");
	}
	else
	{
		myMut.alchemicGrimoire.AddItem(newMat);
		myMut.SaveConfig();
		myMut.WorldInfo.Game.Broadcast(myMut, "You can now transmute anything into" @ materialName $ "!");
	}
}

exec function ForgetTransmutationMaterial(string materialName)
{
	local int index;

	index=myMut.alchemicGrimoire.Find('name', materialName);
	if(index == INDEX_NONE)
	{
		myMut.WorldInfo.Game.Broadcast(myMut, "You don't know how to transmute into" @ materialName $ "...");
	}
	else
	{
		myMut.alchemicGrimoire.Remove(index, 1);
		myMut.SaveConfig();
		myMut.WorldInfo.Game.Broadcast(myMut, "You will not be able to transmute into" @ materialName @ " any more.");
	}
}

exec function ResetTransmutationMaterials()
{
	myMut.ResetAlchemicGrimoire();
	myMut.WorldInfo.Game.Broadcast(myMut, "Reset complete.");
}

exec function WorldMaterialsList()
{
	PlayerController(myMut.aGoat.Controller).ConsoleCommand("GetAll MaterialInterface Name");
}