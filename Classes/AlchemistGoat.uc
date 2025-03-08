class AlchemistGoat extends GGMutator
	config(Geneosis);

struct AlchemicMaterial
{
	var string name;
	var MaterialInterface mat;
};

var GGGoat aGoat;
var array<AlchemistGoatComponent> mComponents;
var config int alchemistVersion;
var int currentVersion;//////////////////////////////// DONT FORGET TO UPDATE THIS NUMBER
var config array<AlchemicMaterial> alchemicGrimoire;
var array<AlchemicMaterial> defaultAlchemicGrimoire;
var int sacrificesRequired;
var int sacrificeCount;

/**
 * See super.
 */
function ModifyPlayer(Pawn Other)
{
	local GGGoat goat;
	local AlchemistGoatComponent alchemistComp;

	super.ModifyPlayer( other );

	goat = GGGoat( other );
	if( goat != none )
	{
		alchemistComp=AlchemistGoatComponent(GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game ).FindMutatorComponent(class'AlchemistGoatComponent', goat.mCachedSlotNr));
		if(alchemistComp != none && mComponents.Find(alchemistComp) == INDEX_NONE)
		{
			mComponents.AddItem(alchemistComp);
			if(mComponents.Length == 1)
			{
				InitAlchemicGrimoire();
				InitAlchemistInteraction();
				CheckVersion();
			}
		}
		if(aGoat == none)
		{
			aGoat=goat;
		}
	}
}

function InitAlchemistInteraction()
{
	local AlchemistInteraction ai;

	ai = new class'AlchemistInteraction';
	ai.InitAlchemistInteraction(self);
	GetALocalPlayerController().Interactions.AddItem(ai);
}

function InitAlchemicGrimoire()
{
	if(default.alchemicGrimoire.Length == 0)
	{
		ResetAlchemicGrimoire();
	}
}

function CheckVersion()
{
	if(alchemistVersion < currentVersion)
	{
		alchemistVersion=currentVersion;
		ResetAlchemicGrimoire();
	}
}

function ResetAlchemicGrimoire()
{
	alchemicGrimoire=defaultAlchemicGrimoire;
	SaveConfig();
}

function MaterialInterface GetNextMaterial(out int currMatIndex, out string matName)
{
	local AlchemicMaterial nextAM;

	if(alchemicGrimoire.Length == 0)
	{
		WorldInfo.Game.Broadcast(self, "You don't know any transmutation material :( Use 'ResetTransmutationMaterials' to get the default list.");
		return none;
	}

	currMatIndex++;
	if(currMatIndex>=alchemicGrimoire.Length)
	{
		currMatIndex=0;
	}

	nextAM=alchemicGrimoire[currMatIndex];
	matName=nextAM.name;
	WorldInfo.Game.Broadcast(self, nextAM.name);
	return nextAM.mat;
}

function bool TrandmutedPhilosophersStone()
{
	local bool gotPhilStone;

	sacrificeCount++;
	gotPhilStone = (Rand(sacrificesRequired-sacrificeCount) == 0);
	if(gotPhilStone)
	{
		sacrificeCount=0;
	}
	return gotPhilStone;
}

function PhilosophersStoneGrabbed(Actor grabbedByActor)
{
	local AlchemistGoatComponent agc;

	foreach mComponents(agc)
	{
		if(agc.gMe == grabbedByActor)
		{
			agc.SetAlchemistMaster();
			break;
		}
	}
	class'AlchemistMaster'.static.UnlockAlchemistMaster();
}

DefaultProperties
{
	mMutatorComponentClass=class'AlchemistGoatComponent'

	sacrificesRequired=100

	currentVersion=7

	defaultAlchemicGrimoire.Add((name="Gold", mat=Material'goat.Materials.GoldenGoat_Mat'))
	defaultAlchemicGrimoire.Add((name="Ruby", mat=Material'Hats.Materials.Ruby_Mat'))
	defaultAlchemicGrimoire.Add((name="Emerald", mat=Material'Hats.Materials.Emerald_Mat'))
	defaultAlchemicGrimoire.Add((name="Silver", mat=Material'Kitchen_01.Materials.Chrome_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Bronze", mat=Material'Bedroom.Materials.Bronze'))
	defaultAlchemicGrimoire.Add((name="Iron", mat=Material'Living_Room_01.Materials.Metal_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Metal", mat=MaterialInstanceConstant'Goat_Props_01.Materials.Props_Generator_Industry_Mat_02'))
	defaultAlchemicGrimoire.Add((name="Machine", mat=Material'Props_01.Materials.ConstructionLight_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Spaceship", mat=Material'Space_Buildings.Materials.Bridge_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Porcelain", mat=Material'Living_Room_01.Materials.Porcelain_Green_01'))
	defaultAlchemicGrimoire.Add((name="White Plastic", mat=Material'Kitchen_01.Materials.White_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Black Plastic", mat=Material'Flat_Materials.Materials.Black_01'))
	defaultAlchemicGrimoire.Add((name="Grey Plastic", mat=Material'Office_Set_01.Materials.PaperBoxGray_01'))
	defaultAlchemicGrimoire.Add((name="Red Plastic", mat=Material'GasStation.Materials.FireExtinguisher_Red'))
	defaultAlchemicGrimoire.Add((name="Green Plastic", mat=Material'Playground.Materials.Green'))
	defaultAlchemicGrimoire.Add((name="Blue Plastic", mat=Material'DivingTower.Materials.Blue'))
	defaultAlchemicGrimoire.Add((name="Dark Red Plastic", mat=Material'AmusmentPark.Materials.DarkRed'))
	defaultAlchemicGrimoire.Add((name="Dark Green Plastic", mat=Material'GasStation.Materials.Green_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Dark Blue Plastic", mat=Material'Playground.Materials.Blue'))
	defaultAlchemicGrimoire.Add((name="Cyber", mat=Material'MMO_ServerRoom.Materials.Server_Mat'))
	defaultAlchemicGrimoire.Add((name="Glass", mat=Material'House_01.Materials.Window_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Shield", mat=Material'Space_Dome.Materials.Dome_Glass_Mat'))
	defaultAlchemicGrimoire.Add((name="Ice", mat=Material'Zombie_Particles.Materials.Crystal_Glow_Mat'))
	defaultAlchemicGrimoire.Add((name="Water", mat=MaterialInstanceConstant'MMO_Environment_01.Materials.ocean.Water_Tropical_Mat_02'))
	defaultAlchemicGrimoire.Add((name="Lava", mat=Material'MMO_Environment_01.Materials.Flowinglava_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Cloud", mat=Material'MMO_Genie.Materials.Cloud_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Thunder", mat=Material'Space_Portal.Materials.TeslaEnergy_MAT'))
	defaultAlchemicGrimoire.Add((name="Bubbles", mat=Material'Space_BottleRockets.Materials.BottleRocketWater_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Tissue", mat=Material'Human_Characters.Materials.Cloth_df_Mat'))
	defaultAlchemicGrimoire.Add((name="Natural Wood", mat=Material'MMO_Effects.Materials.Table_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Refined Wood", mat=Material'Bedroom.Materials.Wood_Mat'))
	defaultAlchemicGrimoire.Add((name="Sorrel", mat=Material'Living_Room_01.Materials.2Sided_Master_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Cheese", mat=Material'Circus.Materials.CheeseWheel_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Thatch", mat=Material'MMO_Farm_01.Materials.Thatched_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Grass", mat=Material'Goat_Environment_01.Materials.Grass_02_Mat'))
	defaultAlchemicGrimoire.Add((name="Dirt", mat=MaterialInstanceConstant'Goat_Environment_01.Materials.Soil_01_Mat'))
	defaultAlchemicGrimoire.Add((name="Rock", mat=Material'MMO_Effects.Materials.Rock_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Sand", mat=Material'BeachWedding.Materials.Sandman_Mat'))
	defaultAlchemicGrimoire.Add((name="Asphalt", mat=Material'Roads_01.Materials.Asphalt_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Concrete", mat=Material'CityProps.Materials.wall04_Mat'))
	defaultAlchemicGrimoire.Add((name="Goo", mat=Material'Zombie_Weapons.Materials.GooGun_Mat'))
	defaultAlchemicGrimoire.Add((name="Blob", mat=Material'Space_Vendors.Materials.AlienThing_Mat'))
	defaultAlchemicGrimoire.Add((name="Plasma", mat=Material'Heist_Effects_01.Effects.PlasmaBall_Mat'))
	defaultAlchemicGrimoire.Add((name="Crystal", mat=Material'Camper.Materials.CrystalBreath_Mat'))
	defaultAlchemicGrimoire.Add((name="Ore", mat=Material'Space_Quarry.Materials.Orechunk_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Neon", mat=MaterialInstanceConstant'Kitchen_01.Materials.Glodlampa_Mat_05'))
	defaultAlchemicGrimoire.Add((name="Disco", mat=Material'Kitchen_01.Materials.DiscoLight_01'))
	defaultAlchemicGrimoire.Add((name="Blink", mat=Material'Space_Dome.Materials.Glassdome3'))
	defaultAlchemicGrimoire.Add((name="Spirit", mat=Material'MMO_GravitationGoat.Materials.Sphere_Mat'))
	defaultAlchemicGrimoire.Add((name="Binary", mat=Material'Zombie_Characters.Materials.TheGlitch_Mat'))
	defaultAlchemicGrimoire.Add((name="Stars", mat=Material'Studio_Lot.Materials.DiscoLight_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Space", mat=Material'UFO.Materials.Space_Cube_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Vortex", mat=Material'Space_Effects.Materials.HalfAGoat_Vortex_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Money", mat=Material'Zombie_Props.Materials.CoinSea_Mat_01'))
	defaultAlchemicGrimoire.Add((name="Hologram", mat=Material'Space_CrowdfundingCentral.Materials.Crowdfunding_Holo_Mat_01'))
}