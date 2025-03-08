class AlchemistMaster extends GGMutator
	config(Geneosis);

var config bool isAlchemistMasterUnlocked;
var array<GGGoat> mGoats;

/**
 * if the mutator should be selectable in the Custom Game Menu.
 */
static function bool IsUnlocked( optional out array<AchievementDetails> out_CachedAchievements )
{
	return default.isAlchemistMasterUnlocked;
}

/**
 * Unlock the mutator
 */
static function UnlockAlchemistMaster()
{
	if(!default.isAlchemistMasterUnlocked)
	{
		PostJuice( "Unlocked Alchemist Master" );
		default.isAlchemistMasterUnlocked=true;
		static.StaticSaveConfig();
	}
}

function static PostJuice( string text )
{
	local GGGameInfo GGGI;
	local GGPlayerControllerGame GGPCG;
	local GGHUD localHUD;

	GGGI = GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game );
	GGPCG = GGPlayerControllerGame( GGGI.GetALocalPlayerController() );

	localHUD = GGHUD( GGPCG.myHUD );

	if( localHUD != none && localHUD.mHUDMovie != none )
	{
		localHUD.mHUDMovie.AddJuice( text );
	}
}

/**
 * See super.
 */
function ModifyPlayer(Pawn Other)
{
	local GGGoat goat;

	super.ModifyPlayer( other );

	goat = GGGoat( other );
	if( goat != none )
	{
		if( IsValidForPlayer( goat ) )
		{
   			mGoats.AddItem(goat);
			ClearTimer(NameOf(InitAlchemistMasters));
			SetTimer(1.f, false, NameOf(InitAlchemistMasters));
		}
	}
}

function InitAlchemistMasters()
{
	local AlchemistGoat alchemist;
	local GGGoat goat;

	//Find Alchemist Goat mutator
	foreach AllActors(class'AlchemistGoat', alchemist)
	{
		if(alchemist != none)
		{
			break;
		}
	}

	if(alchemist == none)
	{
		DisplayUnavailableMessage();
		return;
	}

	//Activate master mode
	foreach mGoats(goat)
	{
		alchemist.PhilosophersStoneGrabbed(goat);
	}
}

function DisplayUnavailableMessage()
{
	WorldInfo.Game.Broadcast(self, "Alchemist Master only works if combined with Alchemist Goat.");
	SetTimer(3.f, false, NameOf(DisplayUnavailableMessage));
}

DefaultProperties
{

}