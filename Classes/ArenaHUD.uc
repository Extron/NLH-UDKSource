/*******************************************************************************
	ArenaHUD

	Creation date: 28/06/2012 20:52
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaHUD extends UDKHUD;

event DrawHUD()
{
	super.DrawHUD();
	
	if (ArenaPawn(PlayerOwner.Pawn) != None)
	{
		Canvas.DrawColor = WhiteColor;
		Canvas.Font = class'Engine'.Static.GetLargeFont();
		Canvas.SetPos(Canvas.ClipX * 0.01, Canvas.ClipY * 0.01);
		Canvas.DrawText("Project Codename Arena - Build 0.0.0.1");
		
		if (ArenaPawn(PlayerOwner.Pawn).ActiveAbility != None)
		{
			Canvas.SetPos(Canvas.ClipX * 0.75, Canvas.ClipY * 0.75);
			Canvas.DrawText("Ability:" @ ArenaPawn(PlayerOwner.Pawn).ActiveAbility.AbilityName);		
		
			if (ArenaPawn(PlayerOwner.Pawn).ActiveAbility.CanFire)
			{
				Canvas.DrawText("Ability ready to fire.");
			}
			else
			{
				Canvas.DrawText("Cooling Down..." @ ArenaPawn(PlayerOwner.Pawn).ActiveAbility.GetRemainingCoolDownTime());
			}
		
		}
		
		if (ArenaWeaponBase(ArenaPawn(PlayerOwner.Pawn).Weapon) != None)
		{
			Canvas.SetPos(Canvas.ClipX * 0.05, Canvas.ClipY * 0.75);
			Canvas.DrawText("Weapon:" @ ArenaWeaponBase(ArenaPawn(PlayerOwner.Pawn).Weapon).WeaponName);
		
			Canvas.SetPos(Canvas.ClipX * 0.05, Canvas.ClipY * 0.80);
			Canvas.DrawText("Clip:" @ ArenaWeaponBase(ArenaPawn(PlayerOwner.Pawn).Weapon).Clip);
			
			Canvas.SetPos(Canvas.ClipX * 0.05, Canvas.ClipY * 0.85);
			Canvas.DrawText("Bloom:" @ ArenaWeaponBase(ArenaPawn(PlayerOwner.Pawn).Weapon).Bloom);
		}
		
		Canvas.SetPos(Canvas.ClipX * 0.75, Canvas.ClipY * 0.8);

		Canvas.SetPos(Canvas.ClipX * 0.75, Canvas.ClipY * 0.85);
		Canvas.DrawText("Health:" @ PlayerOwner.Pawn.Health);
		Canvas.SetPos(Canvas.ClipX * 0.75, Canvas.ClipY * 0.9);
		Canvas.DrawText("Energy:" @ ArenaPawn(PlayerOwner.Pawn).Energy);
	}
}