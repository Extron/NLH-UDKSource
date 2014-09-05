/*******************************************************************************
	GFx_CharacterView

	Creation date: 20/09/2013 10:19
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_CharacterView extends GFx_Menu
	dependson(PlayerData, Pawn_HeadData);

const NativeWidth = 1600;
const NativeHeight = 900;
const InfoBoxWidth = 416;
const InfoBoxHeight = 544;
const AspectRatio = 1.777777778;
const Far = 100;
const Near = 1;
const InfoBoxCount = 6;

struct InfoBoxContainer
{
	var InformationBoxDisplay Display;
	var vector ActiveFigureLocation;
	var rotator ActiveFigureRotation;
	var float ActiveFigureScale;
	var name Socket;
	var string Title;
	var string Subtitle;
	var bool Highlighted;
	var bool AllowFigureTranslation;
	var bool AllowFigureRotation;
	var bool AllowFigureScale;
};

/**
 * The information boxes linked to the player figure.
 */
var InfoBoxContainer InfoBoxes[InfoBoxCount];

/**
 * The Dek cube to use to help display the menu.
 */
var SkeletalMeshComponent Cube;

/**
 * The local pawn that is viewing the menu.
 */
var AP_Specter Pawn;

/**
 * The figure used to draw the player's loadout.
 */
var PlayerFigure Figure;

/**
 * The character data that the player is currently editing.
 */
var LoadoutData Character;

/**
 * The menu's cursor.
 */
var GFxObject Cursor;

/**
 * A reference to the current component list.
 */
var array<class<PlayerAppearanceComponent> > CurrentComponentList;

/**
 * The location to spawn the figure, relative to the viewer's location.
 */
var vector FigureLocation;

/**
 * The figure's translation, allowing the player to focus on any part of the figure when zooming.
 */
var vector FigureTranslation;

/**
 * When activating an info box, this is where the figure was.
 */
var vector FigureStartTranslation;

/**
 * The translation to go back to after deactivating an info box.
 */
var vector FigureEndTranslation;

/**
 * The rotation of the figure relative to the viewer's rotation.
 */
var rotator FigureRotation;

/**
 * When activating an info box, this is the figure's rotation.
 */
var rotator FigureStartRotation;

/**
 * The rotation to go back to after deactivating an info box.
 */
var rotator FigureEndRotation;

/**
 * The last recorded position of the mouse.
 */
var vector2D MousePosition;

/**
 * The scale of the figure.
 */
var float FigureScale;

/**
 * When activating an info box, this is the figure's scale.
 */
var float FigureStartScale;

/**
 * The scale to go back go after deactivating an info box.
 */
var float FigureEndScale;

/**
 * The currently selected weapon.
 */
var string SelectedWeapon;

/**
 * The counter to keep track of the look up time.
 */
var float LookUpCounter;

/**
 * The time it should take to look up and down in the menu transition.
 */
var float LookUpTime;

/**
 * The time it takes for the info box to travel from its starting position to its active position.
 */
var float ActiveTravelTime;

/**
 * The counter for the travel time.
 */
var float ActiveTravelCounter;

/**
 * A timer that keeps track of how long the mouse has been down.
 */
var float MouseDownTimer;

/**
 * Indicates that when transitioning to the weapon editor menu, we have created a new weapon.
 */
var bool NewWeapon;

/**
 * Indicates that the left mouse is being dragged, which should rotate the weapon.
 */
var bool DraggingMouse;

/**
 * Indicates that the right mouse is being dragged, which should rotate the weapon.
 */
var bool DraggingRightMouse;

/**
 * Indicates that the cursor is currently over the active menu box.
 */
var bool OverInfoBox;

/**
 * The info box that is currently active.  Will be -1 if none are.
 */
var int ActiveInfoBox;

/**
 * The direction we are looking.
 */
var int LookDirection;

/**
 * The delegate to call when the menu closes.
 */
delegate OnClose();


function bool Start(optional bool StartPaused = false)
{
	local SkeletalMeshActor iter;
	local vector playerViewLoc;
	local rotator playerViewRot;
	local int i;
	
	super.Start(StartPaused);
			
    Advance(0);
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
		ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = LookUp;
	}
	
	foreach Pawn.AllActors(class'SkeletalMeshActor', iter)
	{
		if (iter.Tag == 'DekCube')
		{
			Cube = iter.SkeletalMeshComponent;
			break;
		}
	}
	
	Cursor = GetVariableObject("_root.cursor");
	
	BuildCharacterProfile();
	
	Pawn.Controller.GetPlayerViewPoint(playerViewLoc, playerViewRot);

	Figure = Pawn.Spawn(class'Arena.PlayerFigure', , , Pawn.Location + (FigureLocation >> Pawn.Controller.Rotation), Pawn.Controller.Rotation, , true);
	Figure.LoadFigure(Character, ArenaPlayerController(Pawn.Controller), false);
	Figure.SetFigureDrawScale(FigureScale);
	Figure.SetFigureTranslation(FigureTranslation);
	
	Figure.Avatar.SetHeadAnimTreeTemplate(AnimTree'Head.Animations.DHCharEditorAnimationTree');
	Figure.Avatar.SetBodyAnimTreeTemplate(AnimTree'AC_Player.Animations.CharEditorAnimationTree');
	Figure.Avatar.RestartAnimationTree();
	
	for (i = 0; i < InfoBoxCount; i++)
	{
		InfoBoxes[i].Display = Pawn.Spawn(class'Arena.InformationBoxDisplay', Figure);
		InfoBoxes[i].Display.Figure = Figure;
		
		InfoBoxes[i].Display.ActiveLocation = Pawn.Location + (vect(-10, 17, 92) >> Pawn.Controller.Rotation);
		InfoBoxes[i].Display.ActiveRotation = rot(-32768, 16384, 16384);
		InfoBoxes[i].Display.ActiveScale = 1;
		
		InfoBoxes[i].Display.InfoBoxGFx.OnBack = DeactivateInfoBox;
	}
	
	InfoBoxes[0].Display.Socket = 'HeadInfoSocket';
	InfoBoxes[0].Display.InfoBoxGFx.SetTitle("Head");
	InfoBoxes[0].Display.InfoBoxGFx.SetSubtitle("");
	InfoBoxes[0].ActiveFigureLocation = vect(0, 0, -64);
	InfoBoxes[0].ActiveFigureRotation = rot(0, 36864, 0);
	InfoBoxes[0].ActiveFigureScale = 2.5;
	InfoBoxes[0].AllowFigureRotation = true;
	InfoBoxes[0].Display.PopulateData = PopulateHeadData;
	InfoBoxes[0].Display.InfoBoxGFx.OnSliderValueChanged = FacialFeatureChanged;
	InfoBoxes[0].Display.InfoBoxGFx.OnColorChanged = FacialColorChanged;
	InfoBoxes[0].Display.InfoBoxGFx.OnEquipSlot = EquipSlot;
	InfoBoxes[0].Display.InfoBoxGFx.OnBarycentricSliderValueChanged = RaceSliderChanged;
	InfoBoxes[0].Display.InfoBoxGFx.OnRadioButtonSelected = GenderChanged;
	InfoBoxes[0].Display.InfoBoxGFx.OnDropdownSelectionChanged = HairChanged;
	InfoBoxes[0].Display.Layout = "Head Layout";
	
	InfoBoxes[1].Display.Socket = 'LeftArmInfoSocket';
	InfoBoxes[1].Display.InfoBoxGFx.SetTitle("Left Arm");
	InfoBoxes[1].Display.InfoBoxGFx.SetSubtitle(Figure.Avatar.BodyParts[1].ComponentName);
	InfoBoxes[1].ActiveFigureLocation = vect(-5, 0, -45);
	InfoBoxes[1].ActiveFigureRotation = rot(0, 49152, 0);
	InfoBoxes[1].ActiveFigureScale = 1.65;
	InfoBoxes[1].Display.PopulateData = PopulateLeftArmData;
	InfoBoxes[1].Display.InfoBoxGFx.OnEquipSlot = EquipSlot;
	InfoBoxes[1].Display.Layout = "Limb Layout";
	
	InfoBoxes[2].Display.Socket = 'RightArmInfoSocket';
	InfoBoxes[2].Display.InfoBoxGFx.SetTitle("Right Arm");
	InfoBoxes[2].Display.InfoBoxGFx.SetSubtitle(Figure.Avatar.BodyParts[2].ComponentName);
	InfoBoxes[2].ActiveFigureLocation = vect(-15, 0, -45);
	InfoBoxes[2].ActiveFigureRotation = rot(0, 16384, 0);
	InfoBoxes[2].ActiveFigureScale = 1.65;
	InfoBoxes[2].Display.PopulateData = PopulateRightArmData;
	InfoBoxes[2].Display.InfoBoxGFx.OnEquipSlot = EquipSlot;
	InfoBoxes[2].Display.Layout = "Limb Layout";
	
	InfoBoxes[3].Display.Socket = 'LeftLegInfoSocket';
	InfoBoxes[3].Display.InfoBoxGFx.SetTitle("Left Leg");
	InfoBoxes[3].Display.InfoBoxGFx.SetSubtitle(Figure.Avatar.BodyParts[3].ComponentName);
	InfoBoxes[3].ActiveFigureLocation = vect(0, 0, 0);
	InfoBoxes[3].ActiveFigureRotation = rot(0, 40960, 0);
	InfoBoxes[3].ActiveFigureScale = 1.175;
	InfoBoxes[3].AllowFigureRotation = true;
	InfoBoxes[3].Display.PopulateData = PopulateLeftLegData;
	InfoBoxes[3].Display.InfoBoxGFx.OnEquipSlot = EquipSlot;
	InfoBoxes[3].Display.Layout = "Limb Layout";
	
	InfoBoxes[4].Display.Socket = 'RightLegInfoSocket';
	InfoBoxes[4].Display.InfoBoxGFx.SetTitle("Right Leg");
	InfoBoxes[4].Display.InfoBoxGFx.SetSubtitle(Figure.Avatar.BodyParts[4].ComponentName);
	InfoBoxes[4].ActiveFigureLocation = vect(0, 0, 0);
	InfoBoxes[4].ActiveFigureRotation = rot(0, 24576, 0);
	InfoBoxes[4].ActiveFigureScale = 1.175;
	InfoBoxes[4].AllowFigureRotation = true;
	InfoBoxes[4].Display.PopulateData = PopulateRightLegData;
	InfoBoxes[4].Display.InfoBoxGFx.OnEquipSlot = EquipSlot;
	InfoBoxes[4].Display.Layout = "Limb Layout";
	
	InfoBoxes[5].Display.Socket = 'TorsoInfoSocket';
	InfoBoxes[5].Display.InfoBoxGFx.SetTitle("Torso");
	InfoBoxes[5].Display.InfoBoxGFx.SetSubtitle(Figure.Avatar.BodyParts[5].ComponentName);
	InfoBoxes[5].ActiveFigureLocation = vect(0, 0, -40);
	InfoBoxes[5].ActiveFigureRotation = rot(0, -32768, 0);
	InfoBoxes[5].ActiveFigureScale = 1.40;
	InfoBoxes[5].AllowFigureRotation = true;
	
	return true;
}

function Update(float dt)
{
	local vector playerViewLoc;
	local rotator playerViewRot;
	
	if (LookUpCounter <= LookUpTime)
		LookUpCounter += dt * LookDirection;
			
	Pawn.Controller.GetPlayerViewPoint(playerViewLoc, playerViewRot);
	
	if (ActiveTravelCounter < ActiveTravelTime)
	{
		ActiveTravelCounter += dt;

		FigureTranslation = VLerp(FigureStartTranslation, FigureEndTranslation, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1));
		FigureRotation = RLerp(FigureStartRotation, FigureEndRotation, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1), true);
		FigureScale = Lerp(FigureStartScale, FigureEndScale, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1));
	}
	
	if (DraggingMouse)
		MouseDownTimer += dt;
	else
		MouseDownTimer = 0;
		
	Figure.SetRotation(RTransform(FigureRotation, playerViewRot));
	Figure.SetFigureDrawScale(FigureScale);
	Figure.SetFigureTranslation(FigureTranslation);

}

function PostRender()
{
	local vector2D mousePos, infoBoxMousePos;
	local vector origin, direction;
	local vector traceLoc, traceNorm;
	local vector topLeftSocket, topLeftScreen, bottomRightSocket, bottomRightScreen;
	local int i;
	
	mousePos.x = Cursor.GetFloat("x") * ArenaPlayerController(Pawn.Controller).MyHUD.SizeX / NativeWidth;
	mousePos.y = Cursor.GetFloat("y") * ArenaPlayerController(Pawn.Controller).MyHUD.SizeY / NativeHeight;
	
	ArenaPlayerController(Pawn.Controller).MyHUD.Canvas.DeProject(mousePos, origin, direction);
	
	if (ActiveInfoBox > -1)
	{
		InfoBoxes[ActiveInfoBox].Display.GetCornerWorldLoc(topLeftSocket, bottomRightSocket);
		
		topLeftScreen = ArenaPlayerController(Pawn.Controller).MyHUD.Canvas.Project(topLeftSocket);
		bottomRightScreen = ArenaPlayerController(Pawn.Controller).MyHUD.Canvas.Project(bottomRightSocket);
		
		infoBoxMousePos.x = (mousePos.x - topLeftScreen.x) * InfoBoxWidth / (bottomRightScreen.x - topLeftScreen.x);
		infoBoxMousePos.y = (mousePos.y - topLeftScreen.y) * InfoBoxHeight / (bottomRightScreen.y - topLeftScreen.y);
		
		InfoBoxes[ActiveInfoBox].Display.InfoBoxGFx.SetCursorLocation(infoBoxMousePos.x, infoBoxMousePos.y, DraggingMouse);
		
		if (infoBoxMousePos.x > 0 && infoBoxMousePos.x < InfoBoxWidth && infoBoxMousePos.y > 0 && infoBoxMousePos.y < InfoBoxHeight)
			OverInfoBox = true;
		else
			OverInfoBox = false;
			
		//`log("Over Info Box?" @ OverInfoBox @ infoBoxMousePos.x @ infoBoxMousePos.y);
	}
	else
	{
		for (i = 0; i < InfoBoxCount; i++)
		{
			if (ArenaPlayerController(Pawn.Controller).TraceComponent(traceLoc, traceNorm, InfoBoxes[i].Display.SkeletalMeshComponent, origin + direction * 512, origin))
			{
				if (!InfoBoxes[i].Highlighted)
				{
					InfoBoxes[i].Highlighted = true;
					InfoBoxes[i].Display.InfoBoxGFx.Highlight();
				}
			}
			else
			{
				if (InfoBoxes[i].Highlighted)
				{
					InfoBoxes[i].Highlighted = false;
					InfoBoxes[i].Display.InfoBoxGFx.DeHighlight();
				}
			}
		}
	}
}

function LookUp(out vector loc, out rotator rot)
{
	rot.Pitch = 16384 * FMin(LookUpCounter / LookUpTime, 1.0);
}

event OnMouseMove()
{
	local vector2D mousePos, delta;
	
	mousePos.x = Cursor.GetFloat("x");
	mousePos.y = Cursor.GetFloat("y");
	delta = mousePos - MousePosition;
	
	if (DraggingMouse && !DraggingRightMouse)
	{
		if (ActiveInfoBox == -1 || (InfoBoxes[ActiveInfoBox].AllowFigureRotation && !OverInfoBox))
			FigureRotation.Yaw = (FigureRotation.Yaw + 64 * -delta.x) % 65536;
			
		if (ActiveInfoBox == -1 || (InfoBoxes[ActiveInfoBox].AllowFigureTranslation && !OverInfoBox))
			FigureTranslation.Z = FClamp(FigureTranslation.Z - 0.25 * delta.y / FigureScale, -64 * Lerp(0, 1, FClamp((FigureScale - 0.5) * 2, 0, 1)), 0);
	}
	else if (DraggingRightMouse)
	{
		if (ActiveInfoBox == -1 || (InfoBoxes[ActiveInfoBox].AllowFigureScale && !OverInfoBox))
			FigureScale = FClamp(FigureScale - delta.y * 0.01, 0.5, 2.5);
			
		FigureTranslation.Z = FClamp(FigureTranslation.Z, -64 * Lerp(0, 1, FClamp((FigureScale - 0.5) * 4, 0, 1)), 0);
	}
	
	//`log("Translation" @ FigureTranslation @ "Rotation" @ FigureRotation @ "Scale" @ FigureScale);
	
	MousePosition = mousePos;
}

event OnMouseClick()
{
	local int i;
	
	if (ActiveInfoBox == -1)
	{
		if (MouseDownTimer >= 0.15)
			return;
			
		for (i = 0; i < InfoBoxCount; i++)
		{
			if (InfoBoxes[i].Highlighted)
			{
				InfoBoxes[i].Display.Activate();
				
				ActiveInfoBox = i;
				ActiveTravelCounter = 0;
				
				FigureStartTranslation = FigureTranslation;
				FigureStartRotation= FigureRotation;
				FigureStartScale = FigureScale;
				
				FigureEndTranslation = InfoBoxes[i].ActiveFigureLocation;
				FigureEndRotation = InfoBoxes[i].ActiveFigureRotation;
				FigureEndScale = InfoBoxes[i].ActiveFigureScale;
				break;
			}
		}
		
		if (ActiveInfoBox != -1)
		{
			for (i = 0; i < InfoBoxCount; i++)
			{
				if (i != ActiveInfoBox)
					InfoBoxes[i].Display.SetHidden(true);
			}
		}
	}
	else
	{
		InfoBoxes[ActiveInfoBox].Display.InfoBoxGFx.ClickMouse();
	}
}

event OnMouseDown()
{
	DraggingMouse = true;
	
	if (ActiveInfoBox > -1)
	{
		InfoBoxes[ActiveInfoBox].Display.InfoBoxGFx.MouseDown();
	}
}

event OnMouseUp()
{
	DraggingMouse = false;
	
	if (ActiveInfoBox > -1)
	{
		InfoBoxes[ActiveInfoBox].Display.InfoBoxGFx.MouseUp();
	}
}

event OnRightMouseDown()
{
	DraggingRightMouse = true;
}

event OnRightMouseUp()
{
	DraggingRightMouse = false;
}

function EquipComponentSelection(int selectedComponent)
{
	local class<PlayerAppearanceComponent> component;
	local rotator oldRot;
	
	component = CurrentComponentList[selectedComponent];
	oldRot = Figure.Rotation;
	
	Figure.SetRotation(rot(0, 0, 0));
	
	if (class<BodyPartComponent>(component) != None)
	{
		Figure.Avatar.ReplaceBodyPart(class<BodyPartComponent>(component));
		Figure.Avatar.BodyParts[class<BodyPartComponent>(component).default.Type].MeshComponent.SetAnimTreeTemplate(AnimTree'AC_Player.Animations.CharEditorAnimationTree');
		
		if (class<BodyPartComponent>(component).default.Type == BPTRightArm)
			Figure.ReattachWeapon();
	}
	else if (class<ArmorComponent>(component) != None)
	{
		Figure.Avatar.ReplaceArmor(class<ArmorComponent>(component));
		Figure.Avatar.Armor[class<ArmorComponent>(component).default.Type].MeshComponent.SetAnimTreeTemplate(AnimTree'AC_Player.Animations.CharEditorAnimationTree');
	}
	else if (class<ClothingComponent>(component) != None)
	{
		Figure.Avatar.ReplaceClothes(class<ClothingComponent>(component));
		Figure.Avatar.Clothes[class<ClothingComponent>(component).default.Type].MeshComponent.SetAnimTreeTemplate(AnimTree'AC_Player.Animations.CharEditorAnimationTree');
	}
		
	Figure.SetRotation(oldRot);
	Figure.Avatar.RestartAnimationTree();
	
	InfoBoxes[ActiveInfoBox].Display.SetHidden(false);
}

function CancelComponentSelection()
{
	InfoBoxes[ActiveInfoBox].Display.SetHidden(false);
}

function DeactivateInfoBox()
{
	local int i;
	
	InfoBoxes[ActiveInfoBox].Display.Deactivate();
	
	ActiveInfoBox = -1;
	ActiveTravelCounter = 0;

	FigureStartTranslation = FigureTranslation;
	FigureStartRotation= FigureRotation;
	FigureStartScale = FigureScale;

	FigureEndTranslation = vect(0, 0, 0);
	FigureEndRotation = rot(0, 36864, 0);
	FigureEndScale = 0.5;
	
	for (i = 0; i < InfoBoxCount; i++)
	{
		InfoBoxes[i].Display.SetHidden(false);
	}
}

function FacialFeatureChanged(string featureName, string featureCategory, float featureValue)
{
	if (Figure.Avatar.BodyParts[BPTHead] != None)
		BPC_Head(Figure.Avatar.BodyParts[BPTHead]).SetFacialFeatureMorphValue(featureName, featureCategory, featureValue);
}

function RaceSliderChanged(string featureName, float x, float y, float z)
{
	if (featureName == "Race")
	{		
		BPC_Head(Figure.Avatar.BodyParts[BPTHead]).SetFacialFeatureMorphValue("African", "Race", x);
		BPC_Head(Figure.Avatar.BodyParts[BPTHead]).SetFacialFeatureMorphValue("Asian", "Race", z);
	}
}

function FacialColorChanged(string featureName, Color newColor)
{
	if (Figure.Avatar.BodyParts[BPTHead] != None)
	{
		switch (featureName)
		{
		case "Eyes":
			BPC_Head(Figure.Avatar.BodyParts[BPTHead]).SetEyeColor(newColor);
			break;
			
		case "Hair":
			BPC_Head(Figure.Avatar.BodyParts[BPTHead]).SetHairColor(newColor);
			break;
		}
	}
}

function GenderChanged(string buttonName)
{
	if (buttonName == "Male")
		BPC_Head(Figure.Avatar.BodyParts[BPTHead]).SetFacialFeatureMorphValue("Female", "Gender", 0.0);
	else if (buttonName == "Female")
		BPC_Head(Figure.Avatar.BodyParts[BPTHead]).SetFacialFeatureMorphValue("Female", "Gender", 1.0);
}

function HairChanged(string featureName, int selection)
{
	if (featureName != "Hair")
		return;
		
	BPC_Head(Figure.Avatar.BodyParts[BPTHead]).SetHairMesh(selection);
}

function EquipSlot(string slotName)
{
	local GFxObject componentList, componentObject;
	local PlayerAppearanceComponent component;
	local int i, index;
	
	switch (slotName)
	{
	case "Eye Implants":
		component = Figure.Avatar.Armor[ACTEyeImplant];
		break;
		
	case "Helmet":
		component = Figure.Avatar.Armor[ACTHelmet];
		break;
	
	case "Upper Arm Armor":
		if (activeInfoBox == 1)
			component = Figure.Avatar.Armor[ACTLeftUpperArm];
		else
			component = Figure.Avatar.Armor[ACTRightUpperArm];
		break;
		
	case "Left Arm":
		component = Figure.Avatar.BodyParts[BPTLeftArm];
		break;
		
	case "Right Arm":
		component = Figure.Avatar.BodyParts[BPTRightArm];
		break;
		
	case "Left Leg":
		component = Figure.Avatar.BodyParts[BPTLeftLeg];
		break;
		
	case "Right Leg":
		component = Figure.Avatar.BodyParts[BPTRightLeg];
		break;
		
	case "Forearm Armor":
		if (activeInfoBox == 1)
			component = Figure.Avatar.Armor[ACTLeftForearm];
		else
			component = Figure.Avatar.Armor[ACTRightForearm];
		break;
			
	case "Thigh Armor":
		if (activeInfoBox == 3)
			component = Figure.Avatar.Armor[ACTLeftThigh];
		else
			component = Figure.Avatar.Armor[ACTRightThigh];
		break;
		
	case "Calf Armor":
		if (activeInfoBox == 3)
			component = Figure.Avatar.Armor[ACTLeftFoot];
		else
			component = Figure.Avatar.Armor[ACTRightFoot];
		break;
	}
	
	componentList = CreateArray();
	CurrentComponentList.Length = 0;
	
	index = 0;
	
	if (component != None)
	{
		for (i = 0; i < component.default.Subclasses.Length; i++)
		{
			if (component.IsOfSameType(component.default.Subclasses[i]))
			{
				componentObject = CreateObject("Object");
				
				componentObject.SetString("name", component.default.Subclasses[i].default.ComponentName);
				componentObject.SetString("description", component.default.Subclasses[i].default.ComponentDescription);
				componentObject.SetFloat("energy", component.default.Subclasses[i].default.EnergyCost);
				componentObject.SetFloat("cost", component.default.Subclasses[i].default.Cost);
				componentObject.SetString("imgSrc", component.default.Subclasses[i].default.ComponentIcon);
				componentObject.SetBool("owned", true);
				
				CurrentComponentList.AddItem(component.default.Subclasses[i]);
				componentList.SetElementObject(index, componentObject);
				index++;
			}
		}
	}
	
	OpenComponentList(componentList, -1);
	InfoBoxes[ActiveInfoBox].Display.SetHidden(true);
}

function PopulateHeadData(GFxObject data, GFx_InformationBox sender)
{
	local GFxObject eyeImplantObject, helmetObject, facialFeatureObject, featuresList, featuresElement, hairStyles;
	local MorphData morph;
	local string featureCategories[8];
	local int i, j, index;

	featureCategories[0] = "Forehead";
	featureCategories[1] = "Eyes";
	featureCategories[2] = "Eyebrows";
	featureCategories[3] = "Ears";
	featureCategories[4] = "Nose";
	featureCategories[5] = "Mouth";
	featureCategories[6] = "Cheeks";
	featureCategories[7] = "Chin";
	
	if (Figure.Avatar.Armor[ACTEyeImplant] != None && AC_None(Figure.Avatar.Armor[ACTEyeImplant]) == None)
	{
		eyeImplantObject = sender.CreateObject("Object");
		
		eyeImplantObject.SetString("name", Figure.Avatar.Armor[ACTEyeImplant].ComponentName);
		eyeImplantObject.SetString("icon", Figure.Avatar.Armor[ACTEyeImplant].ComponentIcon);
		eyeImplantObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTEyeImplant].EnergyCost);
		
		data.SetObject("eyeImplants", eyeImplantObject);
	}
	
	if (Figure.Avatar.Armor[ACTHelmet] != None && AC_None(Figure.Avatar.Armor[ACTHelmet]) == None)
	{
		helmetObject = sender.CreateObject("Object");
		
		helmetObject.SetString("name", Figure.Avatar.Armor[ACTHelmet].ComponentName);
		helmetObject.SetString("icon", Figure.Avatar.Armor[ACTHelmet].ComponentIcon);
		helmetObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTHelmet].EnergyCost);
		
		data.SetObject("helmet", helmetObject);
	}
	
	if (Figure.Avatar.BodyParts[BPTHead] != None)
	{
		facialFeatureObject = sender.CreateObject("Object");
		
		for (j = 0; j < 8; j++)
		{
			featuresList = sender.CreateArray();
			index = 0;
			
			for (i = 0; i < BPC_Head(Figure.Avatar.BodyParts[BPTHead]).HeadData.Morphs.Length; i++)
			{
				morph = BPC_Head(Figure.Avatar.BodyParts[BPTHead]).HeadData.Morphs[i];
				
				if (morph.Category == featureCategories[j])
				{
					featuresElement = sender.CreateObject("Object");
					
					featuresElement.SetString("featureName", morph.DisplayName);
					featuresElement.SetFloat("featureValue", morph.DoubleSided ? 0.5 * (morph.MorphWeight + 1) : morph.MorphWeight);
					featuresElement.SetString("featureCategory", morph.Category);
					
					featuresList.SetElementObject(index, featuresElement);
					index++;
				}
			}
			
			facialFeatureObject.SetObject(Locs(featureCategories[j]) $ "Features", featuresList);
		}
		
		hairStyles = sender.CreateArray();
		
		for (j = 0; j < class'Arena.Pawn_HeadData'.default.HairPieces.Length; j++)
			hairStyles.SetElementString(j, class'Arena.Pawn_HeadData'.default.HairPieces[j].DisplayName);
		
		facialFeatureObject.SetObject("hairStyles", hairStyles);
		facialFeatureObject.SetInt("currentHairStyle", BPC_Head(Figure.Avatar.BodyParts[BPTHead]).HeadData.HairMesh);
		
		data.SetObject("facialFeatures", facialFeatureObject);
	}
}

function PopulateLeftArmData(GFxObject data, GFx_InformationBox sender)
{
	local GFxObject limbObject, upperArmorObject, lowerArmorObject;
	
	data.SetString("limbName", "Left Arm");
	limbObject = sender.CreateObject("Object");
	
	limbObject.SetString("name", Figure.Avatar.BodyParts[BPTLeftArm].ComponentName);
	limbObject.SetString("icon", Figure.Avatar.BodyParts[BPTLeftArm].ComponentIcon);
	limbObject.SetFloat("energyCost", Figure.Avatar.BodyParts[BPTLeftArm].EnergyCost);
	
	data.SetObject("limb", limbObject);
	
	if (Figure.Avatar.Armor[ACTLeftUpperArm] != None && AC_None(Figure.Avatar.Armor[ACTLeftUpperArm]) == None)
	{
		upperArmorObject = sender.CreateObject("Object");
		
		upperArmorObject.SetString("name", Figure.Avatar.Armor[ACTLeftUpperArm].ComponentName);
		upperArmorObject.SetString("icon", Figure.Avatar.Armor[ACTLeftUpperArm].ComponentIcon);
		upperArmorObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTLeftUpperArm].EnergyCost);
		
		data.SetObject("eyeImplants", upperArmorObject);
	}
	
	if (Figure.Avatar.Armor[ACTLeftForearm] != None && AC_None(Figure.Avatar.Armor[ACTLeftForearm]) == None)
	{
		lowerArmorObject = sender.CreateObject("Object");
		
		lowerArmorObject.SetString("name", Figure.Avatar.Armor[ACTLeftForearm].ComponentName);
		lowerArmorObject.SetString("icon", Figure.Avatar.Armor[ACTLeftForearm].ComponentIcon);
		lowerArmorObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTLeftForearm].EnergyCost);
		
		data.SetObject("helmet", lowerArmorObject);
	}
}

function PopulateRightArmData(GFxObject data, GFx_InformationBox sender)
{
	local GFxObject limbObject, upperArmorObject, lowerArmorObject;
	
	data.SetString("limbName", "Right Arm");
	
	limbObject = sender.CreateObject("Object");
	
	limbObject.SetString("name", Figure.Avatar.BodyParts[BPTRightArm].ComponentName);
	limbObject.SetString("icon", Figure.Avatar.BodyParts[BPTRightArm].ComponentIcon);
	limbObject.SetFloat("energyCost", Figure.Avatar.BodyParts[BPTRightArm].EnergyCost);
	
	data.SetObject("limb", limbObject);
	
	if (Figure.Avatar.Armor[ACTRightUpperArm] != None && AC_None(Figure.Avatar.Armor[ACTRightUpperArm]) == None)
	{
		upperArmorObject = sender.CreateObject("Object");
		
		upperArmorObject.SetString("name", Figure.Avatar.Armor[ACTRightUpperArm].ComponentName);
		upperArmorObject.SetString("icon", Figure.Avatar.Armor[ACTRightUpperArm].ComponentIcon);
		upperArmorObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTRightUpperArm].EnergyCost);
		
		data.SetObject("eyeImplants", upperArmorObject);
	}
	
	if (Figure.Avatar.Armor[ACTRightForearm] != None && AC_None(Figure.Avatar.Armor[ACTRightForearm]) == None)
	{
		lowerArmorObject = sender.CreateObject("Object");
		
		lowerArmorObject.SetString("name", Figure.Avatar.Armor[ACTRightForearm].ComponentName);
		lowerArmorObject.SetString("icon", Figure.Avatar.Armor[ACTRightForearm].ComponentIcon);
		lowerArmorObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTRightForearm].EnergyCost);
		
		data.SetObject("helmet", lowerArmorObject);
	}
}

function PopulateLeftLegData(GFxObject data, GFx_InformationBox sender)
{
	local GFxObject limbObject, upperArmorObject, lowerArmorObject;
	
	data.SetString("limbName", "Left Leg");
	limbObject = sender.CreateObject("Object");
	
	limbObject.SetString("name", Figure.Avatar.BodyParts[BPTLeftLeg].ComponentName);
	limbObject.SetString("icon", Figure.Avatar.BodyParts[BPTLeftLeg].ComponentIcon);
	limbObject.SetFloat("energyCost", Figure.Avatar.BodyParts[BPTLeftLeg].EnergyCost);
	
	data.SetObject("limb", limbObject);
	
	if (Figure.Avatar.Armor[ACTLeftThigh] != None && AC_None(Figure.Avatar.Armor[ACTLeftThigh]) == None)
	{
		upperArmorObject = sender.CreateObject("Object");
		
		upperArmorObject.SetString("name", Figure.Avatar.Armor[ACTLeftThigh].ComponentName);
		upperArmorObject.SetString("icon", Figure.Avatar.Armor[ACTLeftThigh].ComponentIcon);
		upperArmorObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTLeftThigh].EnergyCost);
		
		data.SetObject("eyeImplants", upperArmorObject);
	}
	
	if (Figure.Avatar.Armor[ACTLeftFoot] != None && AC_None(Figure.Avatar.Armor[ACTLeftFoot]) == None)
	{
		lowerArmorObject = sender.CreateObject("Object");
		
		lowerArmorObject.SetString("name", Figure.Avatar.Armor[ACTLeftFoot].ComponentName);
		lowerArmorObject.SetString("icon", Figure.Avatar.Armor[ACTLeftFoot].ComponentIcon);
		lowerArmorObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTLeftFoot].EnergyCost);
		
		data.SetObject("helmet", lowerArmorObject);
	}
}

function PopulateRightLegData(GFxObject data, GFx_InformationBox sender)
{
	local GFxObject limbObject, upperArmorObject, lowerArmorObject;
	
	data.SetString("limbName", "Right Leg");
	limbObject = sender.CreateObject("Object");
	
	limbObject.SetString("name", Figure.Avatar.BodyParts[BPTRightLeg].ComponentName);
	limbObject.SetString("icon", Figure.Avatar.BodyParts[BPTRightLeg].ComponentIcon);
	limbObject.SetFloat("energyCost", Figure.Avatar.BodyParts[BPTRightLeg].EnergyCost);
	
	data.SetObject("limb", limbObject);
	
	if (Figure.Avatar.Armor[ACTRightThigh] != None && AC_None(Figure.Avatar.Armor[ACTRightThigh]) == None)
	{
		upperArmorObject = sender.CreateObject("Object");
		
		upperArmorObject.SetString("name", Figure.Avatar.Armor[ACTRightThigh].ComponentName);
		upperArmorObject.SetString("icon", Figure.Avatar.Armor[ACTRightThigh].ComponentIcon);
		upperArmorObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTRightThigh].EnergyCost);
		
		data.SetObject("eyeImplants", upperArmorObject);
	}
	
	if (Figure.Avatar.Armor[ACTRightFoot] != None && AC_None(Figure.Avatar.Armor[ACTRightFoot]) == None)
	{
		lowerArmorObject = sender.CreateObject("Object");
		
		lowerArmorObject.SetString("name", Figure.Avatar.Armor[ACTRightFoot].ComponentName);
		lowerArmorObject.SetString("icon", Figure.Avatar.Armor[ACTRightFoot].ComponentIcon);
		lowerArmorObject.SetFloat("energyCost", Figure.Avatar.Armor[ACTRightFoot].EnergyCost);
		
		data.SetObject("helmet", lowerArmorObject);
	}
}


function BuildCharacterProfile()
{
	local GFxObject classInfo, stats;
	local GFxObject equippedAbilities;
	local GFxObject ability;
	local GFxObject stat;
	local string charType;
	local array<string> statNames;
	local int i;
	
	statNames[0] = "Weight"; statNames[1] = "Mobility";  statNames[2] = "Accuracy";  statNames[3] = "Stability";  statNames[4] = "Movement";  statNames[5] = "Health";  statNames[6] = "Energy"; 
	
	classInfo = CreateObject("Object");
	equippedAbilities = CreateArray();
	
	`log("Character Loadout" @ Character.CharacterName);
	
	if (Character.AbilityClass == class'Arena.PC_Electricity')
	{
		charType = "Tempest";
		classInfo.SetString("className", "Electricity");
	}
	else if (Character.AbilityClass == class'Arena.PC_Water')
	{
		charType = "Lamentia";
		classInfo.SetString("className", "water");
	}
	else if (Character.AbilityClass == class'Arena.PC_Earth')
	{
		charType = "Solus";
		classInfo.SetString("className", "earth");
	}
		 
	for (i = 0; i < Character.EquippedAbilities.Length; i++)
	{
		ability = CreateObject("Object");
		
		ability.SetString("ability", Character.EquippedAbilities[i].default.AbilityName);
		ability.SetFloat("cost", Character.EquippedAbilities[i].default.EnergyCost);
		ability.SetFloat("cooldown", Character.EquippedAbilities[i].default.CoolDown);
		ability.SetString("description", Character.EquippedAbilities[i].default.AbilityDescription);
		ability.SetString("imgSrc", "img://" $ Character.EquippedAbilities[i].default.AbilityIcon);
		
		equippedAbilities.SetElementObject(i, ability);
	}
	
	classInfo.SetObject("equippedAbilities", equippedAbilities);
	
	SetClassInfo(classInfo);
	SetCharacter(Character.CharacterName, charType, Character.Level);
	SetXP(Character.XP, ArenaPlayerController(Pawn.Controller).ComputeNextLevelXP(Character.Level));
	
	BuildPrimanyWeaponInfo();
	
	stats = CreateArray();
	
	for (i = 0; i < 7; i++)
	{
		stat = CreateObject("Object");
		
		stat.SetString("statName", statNames[i]);
		stat.SetFloat("statValue", class'Arena.GlobalGameConstants'.static.GetStatDefault(statNames[i]) * Character.AbilityClass.default.Mod.ValueMods[class'Arena.PlayerStats'.static.GetStatEnum(statNames[i])]);
		stat.SetFloat("statDefault", class'Arena.GlobalGameConstants'.static.GetStatDefault(statNames[i]));
		
		stats.SetElementObject(i, stat);
	}
	
	SetStats(stats);
}

function BuildClassInfo()
{
	local GFxObject classInfo;
	local GFxObject equippedAbilities;
	local GFxObject ability;
	local int i;
	
	classInfo = CreateObject("Object");
	equippedAbilities = CreateArray();
	
	if (Character.AbilityClass == class'Arena.PC_Electricity')
		classInfo.SetString("className", "Electricity");
	else if (Character.AbilityClass == class'Arena.PC_Water')
		classInfo.SetString("className", "water");
	else if (Character.AbilityClass == class'Arena.PC_Earth')
		classInfo.SetString("className", "earth");
		 
	for (i = 0; i < Character.EquippedAbilities.Length; i++)
	{
		ability = CreateObject("Object");
		
		ability.SetString("ability", Character.EquippedAbilities[i].default.AbilityName);
		ability.SetFloat("cost", Character.EquippedAbilities[i].default.EnergyCost);
		ability.SetFloat("cooldown", Character.EquippedAbilities[i].default.CoolDown);
		ability.SetString("description", Character.EquippedAbilities[i].default.AbilityDescription);
		ability.SetString("imgSrc", "img://" $ Character.EquippedAbilities[i].default.AbilityIcon);
		
		equippedAbilities.SetElementObject(i, ability);
	}
	
	classInfo.SetObject("equippedAbilities", equippedAbilities);
	
	SetClassInfo(classInfo);
}

function BuildPrimanyWeaponInfo()
{
	local WeaponSchematicData schematic, nullData;
	local GFxObject weapSchem;
	local GFxObject baseObj;
	local GFxObject componentArray;
	local GFxObject component;
	local int i, index;
	
	schematic = ArenaPlayerController(Pawn.Controller).GetWeapon(Character.PrimaryWeaponName);
	
	if (schematic == nullData)
		return;
		
	weapSchem = CreateObject("Object");
	
	weapSchem.SetString("weapName", schematic.WeaponName);
	
	baseObj = CreateObject("Object");
	
	baseObj.SetString("baseName", schematic.BaseClass.default.BaseName);
	baseObj.SetString("icon", "img://" $ schematic.BaseClass.default.BaseIcon);
	
	componentArray = CreateArray();
	
	index = 0;
	
	for (i = 0; i < schematic.Components.Length; i++)
	{
		if (schematic.Components[i] == None)
			continue;
		
		if (DisplayComponentType(schematic.Components[i]))
		{
			component = CreateObject("Object");
			
			component.SetString("compType", GetComponentType(schematic.Components[i]));
			component.SetString("compName", schematic.Components[i].default.ComponentName);
			component.SetString("icon", "img://" $ schematic.Components[i].default.ComponentIcon);
			
			componentArray.SetElementObject(index, component);
			index++;
		}
	}
	
	weapSchem.SetObject("baseComp", baseObj);
	weapSchem.SetObject("components", componentArray);
	
	SetPrimaryWeapon(weapSchem);
}

function vector ProjectPosition(vector pos)
{
	local vector viewPos;
	local vector newPos;
	local vector cameraPos;
	local rotator cameraRot;
	local float theta;
	
	GetPC().GetPlayerViewPoint(cameraPos, cameraRot);
	theta = GetPC().PlayerCamera.DefaultFOV * PI / 180;
	
	viewPos = pos - cameraPos;
	
	newPos.x = viewPos.y / (AspectRatio * viewPos.x * Tan(theta / 2)) * NativeWidth * 0.5;
	newPos.y = -viewPos.z / (viewPos.x * Tan(theta / 2)) * NativeHeight * 0.5;
	newPos.z = (Far + Near + 2 * Far * Near / viewPos.x ) / (Far - Near);
	
	return newPos;
}


function ButtonClicked(string label)
{
	if (label == "Save")
	{
		ArenaPlayerController(Pawn.Controller).SetCharacterLoadout(Character);
		ArenaPlayerController(Pawn.Controller).SavePlayerData();
		OnClose = GotoMainMenu;
		LookDirection = -1;
		LookUpCounter = LookUpTime;
	}
	else if (label == "Equip Ability")
	{
		OnClose = GotoAbilitiesMenu;
		CloseMenu();
	}
	else if (label == "Edit Weapon")
	{
		OnClose = GotoWeaponEditorMenu;
		CloseMenu();
	}
}

function CancelButtonClicked()
{
	OnClose = GotoMainMenu;
	LookDirection = -1;
	LookUpCounter = LookUpTime;
}

function CreateNewWeaponSchematic()
{
	local WeaponSchematicData newWeap;
	
	newWeap.BaseClass = class'Arena.Wp_CheapRifleBase';
	
	newWeap.Components[WCStock] = class'Arena.Wp_S_CheapStock';
	newWeap.Components[WCBarrel] = class'Arena.Wp_B_ShortSimpleBarrel';
	newWeap.Components[WCMuzzle] = class'Arena.Wp_M_NoMuzzle';
	newWeap.Components[WCOptics] = class'Arena.Wp_O_VIronSights';
	newWeap.Components[WCUnderAttachment] = class'Arena.Wp_UA_NoUnderAttachment';
	newWeap.Components[WCSideAttachment] = class'Arena.Wp_SA_NoSideAttachment';
	newWeap.WeaponName = "New Weapon" @ ArenaPlayerController(Pawn.Controller).SaveData.WeapData.WeaponLibrary.Length;
	newWeap.FireModes[0] = FMFullAuto;
	
	ArenaPlayerController(Pawn.Controller).AddWeaponSchematic(newWeap);
	SelectedWeapon = newWeap.WeaponName;
	OnClose = GotoWeaponEditorMenu;
	NewWeapon = true;
	CloseMenu();
}

function EditWeaponSchematic(string weapon)
{
	NewWeapon = false;
	SelectedWeapon = weapon;
	OnClose = GotoWeaponEditorMenu;
	CloseMenu();
}

function SelectWeaponSchematic(string weapon)
{
	Character.PrimaryWeaponName = weapon;
	BuildPrimanyWeaponInfo();
	DispatchPopupClose();
}

function RemoveAbility(int abilityIndex)
{
	Character.EquippedAbilities.Remove(abilityIndex, 1);
	
	BuildClassInfo();
}

function OpenComponentList(GFxObject componentList, int selectedComponent)
{
	ActionScriptVoid("_root.OpenComponentList");
}

function CloseComponentList()
{
	ActionScriptVoid("_root.CloseComponentList");
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function PlayOpenAnimation()
{
	ActionScriptVoid("_root.OpenMenu");
}

function CloseAnimCompleted()
{
	Figure.Destroy();
	OnClose();
}

function GotoMainMenu()
{
	local GFx_MainMenu menu;
	local int i;
	
	`log("Going to main menu");
	
	menu = new class'Arena.GFx_MainMenu';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);

	Figure.Destroy();
	
	for (i = 0; i < InfoBoxCount; i++)
	{
		InfoBoxes[i].Display.Destroy();
	}
	
	Cube.Owner.SetRotation(rot(0, -16384, 0));
	Cube.Owner.SetPhysics(PHYS_Rotating);
	
	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);
	
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = None;
	
	Close();
}

function GotoAbilitiesMenu()
{
	local GFx_AbilitiesMenu menu;
	
	menu = new class'Arena.GFx_AbilitiesMenu';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);
	menu.AbilityClass = Character.AbilityClass;
	menu.Parent = self;
	menu.Character = Character;
	
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = None;
	
	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);
}


function GotoWeaponEditorMenu()
{
	local GFx_WeaponEditor menu;

	menu = new class'Arena.GFx_WeaponEditor';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);
	menu.WeaponData = ArenaPlayerController(Pawn.Controller).GetWeapon(SelectedWeapon);
	menu.Parent = self;
	//menu.Character = Character;
	
	if (NewWeapon)
		menu.ChangedWeapon = true;
		
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = None;
	
	menu.Start();
	menu.PlayOpenAnimation();
}

function SetCharacter(string charName, string charClass, int charLevel)
{
	ActionScriptVoid("_root.SetCharacter");
}

function SetClassInfo(GFxObject classInfo)
{
	ActionScriptVoid("_root.SetClassInfo");
}

function SetPrimaryWeapon(GFxObject weaponInfo)
{
	ActionScriptVoid("_root.SetPrimaryWeapon");
}

function SetStats(GFxObject stats)
{
	ActionScriptVoid("_root.SetStats");
}

function SetXP(float xp, float nextLevel)
{
	ActionScriptVoid("_root.SetXP");
}

function DispatchPopupClose()
{
	ActionScriptVoid("_root.DispatchPopupClose");
}

function array<string> GetWeaponLibrary()
{
	return ArenaPlayerController(Pawn.Controller).GetWeapons();
}

function string GetComponentType(class<ArenaWeaponComponent> component)
{
	if (class<Wp_Stock>(component) != None)
		return "Stock:";
	else if (class<Wp_Barrel>(component) != None)
		return "Barrel:";
	else if (class<Wp_Muzzle>(component) != None)
		return "Muzzle:";
	else if (class<Wp_Optics>(component) != None)
		return "Optics:";
	else if (class<Wp_UnderAttachment>(component) != None)
		return "Under Attachment:";
	else if (class<Wp_SideAttachment>(component) != None)
		return "Side Attachment:";
	else
		return "";
}

function bool DisplayComponentType(class<ArenaWeaponComponent> component)
{
	if (class<Wp_S_NoStock>(component) != None)
		return false;
	else if (class<Wp_B_NoBarrel>(component) != None)
		return false;
	else if (class<Wp_M_NoMuzzle>(component) != None)
		return false;
	else if (class<Wp_O_NoOptics>(component) != None)
		return false;
	else if (class<Wp_UA_NoUnderAttachment>(component) != None)
		return false;
	else if (class<Wp_SA_NoSideAttachment>(component) != None)
		return false;
	else
		return true;
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.CharacterView'
	SelectedWeapon="Default Weapon"
	LookDirection=1
	LookUpTime=0.33
	bCaptureInput=false
	FigureLocation=(X=24,Y=0,Z=128)
	FigureRotation=(Yaw=36864)
	FigureScale=0.5
	ActiveInfoBox=-1
	ActiveTravelTime=0.15
	ActiveTravelCounter=0.2
}