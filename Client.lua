
local PlayerLoaded = false
local Pourcent = 0.0
local FirstSpawn = true
local Character = {}
local ClotheList = {}
local identityInfo = {
    firstName = nil,
    lastName = nil,
    dateOfBirth = nil,
    cut = nil,
    sex = nil,
    identityCreated = false
}

Citizen.CreateThread(function()
	GenerateClotheList()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerLoaded = true
end)

Panel = {
	GridPanel = {
		x = 0.5,
		y = 0.5,
		Top = "Haut",
        Bottom = "Bas",
        Left = "Gauche",
        Right = "Droite",
		enable = false
	},

	GridPanelHorizontal = {
		x = 0.5,
        Left = "Gauche",
        Right = "Droite",
		enable = false
	},

	ColourPanel = {
		itemIndex = 1,
        index_one = 1,
        index_two = 1,
		name = "Couleur",
        Color = RageUI.PanelColour.HairCut,
		enable = false
	},

	PercentagePanel = {
		index = 0,
        itemIndex = 1,
        MinText = '0%',
        HeaderText = "Opacité",
        MaxText = '100%',
		enable = false
	}


}

function ManagePanel(type, data)
    if data.Top then
    	Panel[type].Top = data.Top
    end

    if data.Bottom then
    	Panel[type].Bottom = data.Bottom
    end

    if data.Left then
    	Panel[type].Left = data.Left
    end

    if data.Right then
    	Panel[type].Right = data.Right
    end

    if data.x then
    	Panel[type].PFF = data.x
    end

    if data.y then
    	Panel[type].PFF2 = data.y
    end

    if type ~= 'ColourPanel' and type ~= 'PercentagePanel' and type ~= '' then

	    if not Panel[type].currentItem then
	        Panel[type].lastItem = data.x[2]
		else
			Panel[type].lastItem = Panel[type].currentItem
		end	
		Panel[type].currentItem = data.x[2]
		if not Panel[type][Panel[type].currentItem] then
			Panel[type][Panel[type].currentItem] = {
				x = 0.5,
				y = 0.5
			}
		end
	end

	if type == 'ColourPanel' or type == 'PercentagePanel' then

		Panel[type].itemIndex = data.index
		if data.Panel then
			Panel[data.Panel].itemIndex = data.index
		end

		if not Panel[type].currentItem then
	        Panel[type].lastItem = data.item
		else
			Panel[type].lastItem = Panel[type].currentItem
		end	
		Panel[type].currentItem = data.item

		if not Panel[type][Panel[type].currentItem] then
			Panel[type][Panel[type].currentItem] = {
				index = type == 'ColourPanel' and 1 or 0,
				minindex = 1
			}
		end

		if data.Panel then
			if not Panel[data.Panel].currentItem then
		        Panel[data.Panel].lastItem = data.item
			else
				Panel[data.Panel].lastItem = Panel[data.Panel].currentItem
			end	
			Panel[data.Panel].currentItem = data.item

			if not Panel[data.Panel][Panel[data.Panel].currentItem] then
				Panel[data.Panel][Panel[data.Panel].currentItem] = {
					index = data.Panel == 'PercentagePanel' and 0 or 1,
					minindex = 1
				}
			end
		end
	end

	for k,v in pairs(Panel) do
		if data.Panel then
			if k == type or k == data.Panel then
				v.enable = true
			else
				v.enable = false
			end
		else
	        if k == type then
	            v.enable = true
	        else
	            v.enable = false
	        end
	    end
    end
end

-- Clothe modification
function GenerateClotheList()
	for i=1, #Creator.Outfit, 1 do
		table.insert(ClotheList, Creator.Outfit[i].label)
	end
end

local ComponentClothe = {tshirt = 8, torso = 11, decals = 10, arms = 3, pants = 4, shoes = 6, chain = 7}
local PropIndexClothe = {helmet = 0, glasses = 1}

function updateClothe(index)
    local clothe = Creator.Outfit[index]
    local gender
    if Character['sex'] == 0 then
        gender = 'male'
    else
        gender = 'female'
    end

    local playerPed = PlayerPedId()

    for k,v in pairs(clothe.id[gender]) do
        if k == 'helmet' or k == 'glasses' then
            SetPedPropIndex(playerPed, PropIndexClothe[k], v[1], v[2])
        else
            if k == 'arms' then
            	Character[k] = v[1]
            else
            	Character[k..'_1'] = v[1]
            end
           	Character[k..'_2'] = v[2]
            SetPedComponentVariation(playerPed, ComponentClothe[k], v[1], v[2])
        end
    end
end

local function Keyboard(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

function menuIdentity()
    local vide_style_nom = RageUI.BadgeStyle.None
    local vide_style_prenom = RageUI.BadgeStyle.None
    local vide_style_date = RageUI.BadgeStyle.None
    local vide_style_taille = RageUI.BadgeStyle.None
    local vide_style_sexe = RageUI.BadgeStyle.None
    local createidentity = RageUI.CreateMenu('', 'Bienvenue')
    createidentity.Closable = false
            SetEntityCoords(PlayerPedId(), Creator.posIdentity)
            SetEntityHeading(PlayerPedId(), Creator.headingIdentity)
            startAnim('anim@heists@prison_heiststation@cop_reactions', 'cop_b_idle')
            FreezeEntityPosition(PlayerPedId(), true)
            RageUI.Visible(createidentity, not RageUI.Visible(createidentity))
            while createidentity do
            Citizen.Wait(0)
            RageUI.IsVisible(createidentity, true, true, true, function()

                RageUI.Separator("~y~↓ Création de votre carte d'identité ↓")

                RageUI.Line(218, 165, 32, 255)

                RageUI.ButtonWithStyle("Prénom", description, { RightBadge = vide_style_prenom }, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        local prenom = lib.inputDialog('Mettez votre prénom', {
                            {type = 'input', label = '', placeholder = 'Mettez votre prénom', description = '', required = true, min = 5, max = 25},
                        })
                        if prenom ~= nil then
                            identityInfo.firstName = prenom[1]
                            vide_style_prenom = RageUI.BadgeStyle.Tick
                        end
                    end 
                end)
                RageUI.ButtonWithStyle("Nom", description, { RightBadge = vide_style_nom }, true, function(Hovered, Active, Selected)
                    if Selected then 
                        local nom = lib.inputDialog('Mettez votre nom', {
                            {type = 'input', label = '', placeholder = 'Mettez votre nom', description = '', required = true, min = 5, max = 25},
                        })
                        if nom ~= nil then
                            identityInfo.lastName = nom[1]
                            vide_style_nom = RageUI.BadgeStyle.Tick
                        end
                    end 
                end)
                RageUI.ButtonWithStyle("Date de naissance", description, { RightBadge = vide_style_date }, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        local JessyTS = lib.inputDialog('Date de naissance', {
                            {type = 'date', label = '', icon = {'far', 'calendar'}, default = true, format = "DD/MM/YYYY"}
                        })
                        if JessyTS ~= nil then
                            identityInfo.dateOfBirth = JessyTS[1]
                            vide_style_date = RageUI.BadgeStyle.Tick
                        end
                    end 
                end)
                RageUI.ButtonWithStyle("Taille", description, { RightBadge = vide_style_taille }, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        local taile = lib.inputDialog('Selectionnez votre taile', {
                            {type = 'slider', label = '', placeholder = '', description = '', required = true, default = 180, min = 150, max = 250},
                        })
                        if taile ~= nil then
                            identityInfo.cut = taile[1]
                            vide_style_taille = RageUI.BadgeStyle.Tick
                        end
                    end 
                end)
                RageUI.ButtonWithStyle("Sex", description, { RightBadge = vide_style_sexe }, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        local sex_ = lib.inputDialog('Selectionnez votre Sexe', {
                            {type = 'select', label = '', placeholder = '', description = '', required = true, options = {{label = 'Homme', value = "H"}, {label = 'Femme', value = "F"}}},
                        })
                        if sex_ ~= nil then
                            identityInfo.sex = sex_[1]
                            vide_style_sexe = RageUI.BadgeStyle.Tick
                        end
                    end 
                end)

                RageUI.Line(218, 165, 32, 255)

            if identityInfo.firstName == nil or identityInfo.lastName == nil or identityInfo.dateOfBirth == nil or identityInfo.cut == nil or identityInfo.sex == nil then
                RageUI.ButtonWithStyle("Valider", description, {RightBadge = RageUI.BadgeStyle.Lock}, true, function(Hovered, Active, Selected) 
                end)
            else
                RageUI.ButtonWithStyle("Valider", description, {Color = {BackgroundColor = { 0, 120, 0, 25 }}}, true, function(Hovered, Active, Selected) 
                    if Selected then 
                        TriggerServerEvent('rCreator:CreateIdentity', identityInfo, GetPlayerServerId(PlayerId()))
                        identityInfo.identityCreated = true
                    end
                end)
            end

            RageUI.Line(218, 165, 32, 255)

            if identityInfo.identityCreated then
                RageUI.PercentagePanel(Pourcent or 0.0, "Création... (~y~" .. math.floor(Pourcent*100) .. "%~s~)", "", "",  function(Hovered, Active, Percent)
                    if Pourcent < 1.0 then
                        Pourcent = Pourcent + 0.004
                    else
                        RageUI.CloseAll()
                        --FreezeEntityPosition(PlayerPedId(), false)
                        ClearPedTasks(PlayerPedId())
                        DoScreenFadeOut(1500)
                        Wait(1500)
                        SetEntityCoords(PlayerPedId(), Creator.posPerso)
                        SetEntityHeading(PlayerPedId(), Creator.headingPerso)
                        DoScreenFadeIn(1500)
                        TriggerServerEvent("JessyTS:uniqueID_")
                        TriggerServerEvent("JessyTS:IDT:Stack", GetPlayerServerId(PlayerId()))
                        TriggerServerEvent('JessyTS:Boutique:Car:GetData')
                        TriggerServerEvent('JessyTS:Boutique:Money:GetData')
                        TriggerServerEvent('JessyTS:Boutique:Weapon:GetData')
                        TriggerServerEvent('JessyTS:Boutique:Player')
                        TriggerServerEvent('JessyTS:Boutique:AllPlayer')
                        TriggerServerEvent("JessyTS:getMyLevel")
                        TriggerServerEvent("JessyTS:uniqueID")
                        TriggerServerEvent("JessyTS:AllJob")
                        TriggerServerEvent("JessyTS:Service:loaded", ESX.PlayerData.job.name)
                        TriggerServerEvent("JessyTS:Service:GetData:All")
                        TriggerServerEvent('JessyTS:Society:Money:Get', 'society_'..ESX.PlayerData.job.name)
                        TriggerServerEvent('JessyTS:Society:Employe:Get', ESX.PlayerData.job.name)
                        TriggerServerEvent('JessyTS:Society:AllJob:Get')
                        menuCreator()
                    end
                end)
            end
            end, function()
            end)
            if not RageUI.Visible(createidentity) then
            createidentity = RMenu:DeleteType(createidentity, true)
        end
    end
end

function menuCreator()
    local main = RageUI.CreateMenu('', "Interaction")
    local main_sub = RageUI.CreateSubMenu(main, '', "Interaction")
    local heritage = RageUI.CreateSubMenu(main, '', "Interaction")
    local visage = RageUI.CreateSubMenu(main, '', "Interaction")
    local apperance = RageUI.CreateSubMenu(main, '', "Interaction")
    -- Item
    local actionGender, actionClothe, actionMother, actionFather, actionRessemblance, actionSkin = 1, 1, 1, 1, 5, 5
    local CharacterMom, CharacterDad, ShapeMixData, SkinMixData = 1, 1, 0.5, 0.5
    local amount = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 };

    visage.EnableMouse = true;
    apperance.EnableMouse = true;
    main.Closable = false
    --------------------
    --------------------

        RageUI.Visible(main, not RageUI.Visible(main))
        while main do
        Citizen.Wait(0)
        RageUI.IsVisible(main, true, true, true, function()

        RageUI.Line(218, 165, 32, 255)

        RageUI.List("Sexe", {"Homme", "Femme"}, actionGender, nil, {}, true, function(Hovered, Active, Selected, Index)
        end, function(Index, Item)
            actionGender = Index
            changeGender(Index)
        end)

        RageUI.Line(218, 165, 32, 255)

        RageUI.ButtonWithStyle("Héritage", nil, {}, true, function(Hovered, Active, Selected)
        end, heritage)

        RageUI.ButtonWithStyle("Traits du visage", nil,{}, true, function(Hovered, Active, Selected)
        end, visage)

        RageUI.ButtonWithStyle("Apparence du personnage", nil,{}, true, function(Hovered, Active, Selected)
        end, apperance)

        RageUI.ButtonWithStyle("Tenues", nil, {}, true, function(Hovered, Active, Selected)
        end, main_sub)

        RageUI.Line(218, 165, 32, 255)

        RageUI.ButtonWithStyle("Valider", description, {Color = {BackgroundColor = { 0, 255, 0, 25 }}}, true, function(Hovered, Active, Selected)
            if Selected then
                FreezeEntityPosition(PlayerPedId(), false)
                RageUI.CloseAll()
                TriggerEvent('introCinematic:start')
            end
        end)

        RageUI.Line(218, 165, 32, 255)

        end, function()
        end)

        RageUI.IsVisible(main_sub, true, true, true, function()

        RageUI.List("Tenues", ClotheList, actionClothe, "", {}, true, function(Hovered, Active, Selected, Index)
        end, function(Index, Item) 
            actionClothe = Index
            updateClothe(actionClothe)
        end)

        RageUI.Line(218, 165, 32, 255)
        
        end, function()
        end)


        RageUI.IsVisible(heritage, true, true, true, function()

		RageUI.HeritageWindow(CharacterMom, CharacterDad)

		RageUI.List("Mère", Creator.MotherList, actionMother, nil, {}, true, function(hovered,active,selected, Index)
        end, function(Index, Item)
        	actionMother = Index
        	CharacterMom = Index
        	Character['mom'] = Index
            TriggerEvent("skinchanger:change", "mom", Index)
        end)

        RageUI.List("Père", Creator.FatherList, actionFather, nil, {}, true, function(hovered,active,selected, Index)
        end, function(Index, Item)
        	actionFather = Index
        	CharacterDad = Index
        	Character['dad'] = Index
            TriggerEvent("skinchanger:change", "dad", Index)
        end)

        RageUI.Line(218, 165, 32, 255)

        end, function() 
        end)


	    RageUI.IsVisible(visage, true, true, true, function()

            RageUI.Line(218, 165, 32, 255)

		RageUI.ButtonWithStyle("Nez", false, {}, true, function(Hovered, Active, Selected)
			if Active then
				ManagePanel('GridPanel', {x = {0, 'nose_1'}, y = {1, 'nose_2'}, Top = "Haut", Bottom = "Bas", Left = "Étroit", Right = "Large"})
			end
    	end)

        RageUI.ButtonWithStyle("Profil nez", false, {}, true, function(Hovered, Active, Selected)
        	if Active then
				ManagePanel('GridPanel', {x = {2, 'nose_3'}, y = {3, 'nose_4'}, Top = "Courber", Bottom = "Incurver", Left = "Court", Right = "Long"})
			end
        end)

        RageUI.ButtonWithStyle("Pointe de nez", false, {}, true, function(Hovered, Active, Selected)
        	if Active then
				ManagePanel('GridPanel', {x = {4, 'nose_5'}, y = {5, 'nose_6'}, Top = "Casser à gauche", Bottom = "Casser à droite", Left = "Pointe Haute", Right = "Pointe Basse"})
			end
        end)

        RageUI.ButtonWithStyle("Sourcils", false, {}, true, function(Hovered, Active, Selected)
        	if Active then
				ManagePanel('GridPanel', {x = {6, 'eyebrows_5'}, y = {7, 'eyebrows_6'}, Top = "Haut", Bottom = "Bas", Left = "Extérieur", Right = "Intérieur"})
			end
        end)

        RageUI.ButtonWithStyle("Pommettes", false, {}, true, function(Hovered, Active, Selected)
        	if Active then
				ManagePanel('GridPanel', {x = {9, 'cheeks_1'}, y = {8, 'cheeks_2'}, Top = "Haut", Bottom = "Bas", Left = "Creuse", Right = "Gonfler"})
			end
        end)

        RageUI.ButtonWithStyle("Joues", false, {}, true, function(Hovered, Active, Selected)
        	if Active then
				ManagePanel('GridPanelHorizontal', {x = {10, 'cheeks_3'}, Left = "Gonfler", Right = "Creuse"})
			end
        end)

        RageUI.ButtonWithStyle("Yeux", false, {}, true, function(Hovered, Active, Selected)
			if Active then
				ManagePanel('GridPanelHorizontal', {x = {11, 'eye_open'}, Left = "Ouvert", Right = "Plisser"})
			end
        end)

        RageUI.ButtonWithStyle("Lèvres", false, {}, true, function(Hovered, Active, Selected)
			if Active then
				ManagePanel('GridPanelHorizontal', {x = {12, 'lips_thick'}, Left = "Épais", Right = "Mince"})
			end
        end)

        RageUI.ButtonWithStyle("Mâchoire", false, {}, true, function(Hovered, Active, Selected)
			if Active then
				ManagePanel('GridPanel', {x = {13, 'jaw_1'}, y = {14, 'jaw_2'}, Top = "Rond", Bottom = "Carré", Left = "Étroit", Right = "Large"})
			end
        end)

        RageUI.ButtonWithStyle("Menton", false, {}, true, function(Hovered, Active, Selected)
			if Active then
				ManagePanel('GridPanel', {x = {15, 'chin_height'}, y = {16, 'chin_lenght'}, Top = "Haut", Bottom = "Bas", Left = "Profond", Right = "Extérieur"})
			end
        end)

        RageUI.ButtonWithStyle("Forme de menton", false, {}, true, function(Hovered, Active, Selected)
			if Active then
				ManagePanel('GridPanel', {x = {17, 'chin_width'}, y = {18, 'chin_hole'}, Top = "Pointu", Bottom = "Bum", Left = "Rond", Right = "Carré"})
			end
        end)

        RageUI.ButtonWithStyle("Épaisseur du cou", false, {}, true, function(Hovered, Active, Selected)
			if Active then
				ManagePanel('GridPanelHorizontal', {x = {19, 'neck_thick'}, Left = "Mince", Right = "Épais"})
			end
        end)

        RageUI.Line(218, 165, 32, 255)


	end, function() 
		if Panel.GridPanel.enable then
			RageUI.GridPanel(Panel.GridPanel.x, Panel.GridPanel.y, Panel.GridPanel.Top, Panel.GridPanel.Bottom, Panel.GridPanel.Left, Panel.GridPanel.Right, function(Hovered, Active, X, Y)
	        	if Panel.GridPanel.lastItem == Panel.GridPanel.currentItem then
      				Panel.GridPanel.x = X
	        		Panel.GridPanel.y = Y
      			else
      				Panel.GridPanel.x = Panel.GridPanel[Panel.GridPanel.currentItem].x
      				Panel.GridPanel.y = Panel.GridPanel[Panel.GridPanel.currentItem].y
      			end


	        	if Active then
      				Panel.GridPanel[Panel.GridPanel.currentItem].x = X
      				Panel.GridPanel[Panel.GridPanel.currentItem].y = Y

		        	SetPedFaceFeature(GetPlayerPed(-1), Panel.GridPanel.PFF[1], X)
		        	SetPedFaceFeature(GetPlayerPed(-1), Panel.GridPanel.PFF2[1], Y)

		        	Character[Panel.GridPanel.PFF[2]] = X
		        	Character[Panel.GridPanel.PFF2[2]] = Y
		        end
	        end)
	    end

	    if Panel.GridPanelHorizontal.enable then
      		RageUI.GridPanelHorizontal(Panel.GridPanelHorizontal.x, Panel.GridPanelHorizontal.Left, Panel.GridPanelHorizontal.Right, function(Hovered, Active, X)
      			if Panel.GridPanelHorizontal.lastItem == Panel.GridPanelHorizontal.currentItem then
      				Panel.GridPanelHorizontal.x = X
      			else
      				Panel.GridPanelHorizontal.x = Panel.GridPanelHorizontal[Panel.GridPanelHorizontal.currentItem].x
      			end
      			if Active then
      				Panel.GridPanelHorizontal[Panel.GridPanelHorizontal.currentItem].x = X
	      			SetPedFaceFeature(GetPlayerPed(-1), Panel.GridPanelHorizontal.PFF[1], X)
	      			Character[Panel.GridPanelHorizontal.PFF[2]] = X
	      		end
      		end)
	    end
	end)

	-- Apparence Menu
	RageUI.IsVisible(apperance, true, true,  true, function()

        RageUI.Line(218, 165, 32, 255)

		for k,v in ipairs(Apperance) do
			RageUI.List(v.item, v.List, v.index, nil, {}, true, function(Hovered, Active, Selected, Index)
				if Active then
					if v.ColourPanel and v.PercentagePanel then
						ManagePanel('ColourPanel', {Panel = 'PercentagePanel', index = k, item = v.item})
					elseif v.ColourPanel and not v.PercentagePanel then
						ManagePanel('ColourPanel', {index = k, item = v.item})
					elseif not v.ColourPanel and v.PercentagePanel then
						ManagePanel('PercentagePanel', {index = k, item = v.item})
					elseif not v.ColourPanel and not v.PercentagePanel then
						ManagePanel('', {})
					end

                end
            end, function(Index, Item)
                v.index = Index
                updateApperance(k)
            end)
		end

        RageUI.Line(218, 165, 32, 255)
	end, function()
		if Panel.ColourPanel.enable then
			RageUI.ColourPanel(Panel.ColourPanel.name, Panel.ColourPanel.Color, Panel.ColourPanel.index_one, Panel.ColourPanel.index_two, function(Hovered, Active, MinimumIndex, CurrentIndex)
				if Panel.ColourPanel.lastItem == Panel.ColourPanel.currentItem then
					Panel.ColourPanel.index_one = MinimumIndex
					Panel.ColourPanel.index_two = CurrentIndex
				else
					Panel.ColourPanel.index_one = Panel.ColourPanel[Panel.ColourPanel.currentItem].minindex
					Panel.ColourPanel.index_two = Panel.ColourPanel[Panel.ColourPanel.currentItem].index
				end

				if Active then
					Panel.ColourPanel[Panel.ColourPanel.currentItem].minindex = MinimumIndex
					Panel.ColourPanel[Panel.ColourPanel.currentItem].index = CurrentIndex

					Apperance[Panel.ColourPanel.itemIndex].indextwo = math.floor(CurrentIndex+0.0)
					updateApperance(Panel.ColourPanel.itemIndex, true, false)
				end
			end)
		end

		if Panel.PercentagePanel.enable then
			RageUI.PercentagePanel(Panel.PercentagePanel.index, Panel.PercentagePanel.HeaderText, Panel.PercentagePanel.MinText, Panel.PercentagePanel.MaxText, function(Hovered, Active, Percent)
				if Panel.PercentagePanel.lastItem == Panel.PercentagePanel.currentItem then
					Panel.PercentagePanel.index = Percent
				else
					Panel.PercentagePanel.index = Panel.PercentagePanel[Panel.PercentagePanel.currentItem].index
				end
				if Active then
					Panel.PercentagePanel[Panel.PercentagePanel.currentItem].index = Percent

					Apperance[Panel.PercentagePanel.itemIndex].indextwo = math.floor(Percent*10)
					updateApperance(Panel.PercentagePanel.itemIndex, false)
				end
			end)
		end
	end)

            if not RageUI.Visible(main) and not RageUI.Visible(main_sub) and not RageUI.Visible(heritage) and not RageUI.Visible(visage) and not RageUI.Visible(apperance) then
            main = RMenu:DeleteType(main, true)
        end
    end
end

function startAnim(lib, anim)
    ESX.Streaming.RequestAnimDict(lib, function()
        TaskPlayAnim(PlayerPedId(), lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
    end)
end


local sub_b0b5 = {
    [0] = "MP_Plane_Passenger_1",
    [1] = "MP_Plane_Passenger_2",
    [2] = "MP_Plane_Passenger_3",
    [3] = "MP_Plane_Passenger_4",
    [4] = "MP_Plane_Passenger_5",
    [5] = "MP_Plane_Passenger_6",
    [6] = "MP_Plane_Passenger_7"
}

function sub_b747(ped, a_1)
    if a_1 == 0 then
        SetPedComponentVariation(ped, 0, 21, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 9, 0, 0)
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 4, 9, 0, 0)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 4, 8, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)
        SetPedComponentVariation(ped, 8, 15, 0, 0)
        SetPedComponentVariation(ped, 9, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 10, 0, 0)
        ClearPedProp(ped, 0)
        ClearPedProp(ped, 1)
        ClearPedProp(ped, 2)
        ClearPedProp(ped, 3)
        ClearPedProp(ped, 4)
        ClearPedProp(ped, 5)
        ClearPedProp(ped, 6)
        ClearPedProp(ped, 7)
        ClearPedProp(ped, 8)
    elseif a_1 == 1 then
        SetPedComponentVariation(ped, 0, 13, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 5, 4, 0)
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 4, 10, 0, 0)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 10, 0, 0)
        SetPedComponentVariation(ped, 7, 11, 2, 0)
        SetPedComponentVariation(ped, 8, 13, 6, 0)
        SetPedComponentVariation(ped, 9, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 10, 0, 0)
        ClearPedProp(ped, 0)
        ClearPedProp(ped, 1)
        ClearPedProp(ped, 2)
        ClearPedProp(ped, 3)
        ClearPedProp(ped, 4)
        ClearPedProp(ped, 5)
        ClearPedProp(ped, 6)
        ClearPedProp(ped, 7)
        ClearPedProp(ped, 8)
    elseif a_1 == 2 then
        SetPedComponentVariation(ped, 0, 15, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 1, 4, 0)
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 4, 0, 1, 0)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 1, 7, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)
        SetPedComponentVariation(ped, 8, 2, 9, 0)
        SetPedComponentVariation(ped, 9, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 6, 0, 0)
        ClearPedProp(ped, 0)
        ClearPedProp(ped, 1)
        ClearPedProp(ped, 2)
        ClearPedProp(ped, 3)
        ClearPedProp(ped, 4)
        ClearPedProp(ped, 5)
        ClearPedProp(ped, 6)
        ClearPedProp(ped, 7)
        ClearPedProp(ped, 8)
    elseif a_1 == 3 then
        SetPedComponentVariation(ped, 0, 14, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 5, 3, 0)
        SetPedComponentVariation(ped, 3, 3, 0, 0)
        SetPedComponentVariation(ped, 4, 1, 6, 0)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 11, 5, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)
        SetPedComponentVariation(ped, 8, 2, 0, 0)
        SetPedComponentVariation(ped, 9, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 3, 12, 0)
        ClearPedProp(ped, 0)
        ClearPedProp(ped, 1)
        ClearPedProp(ped, 2)
        ClearPedProp(ped, 3)
        ClearPedProp(ped, 4)
        ClearPedProp(ped, 5)
        ClearPedProp(ped, 6)
        ClearPedProp(ped, 7)
        ClearPedProp(ped, 8)
    elseif a_1 == 4 then
        SetPedComponentVariation(ped, 0, 18, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 15, 3, 0)
        SetPedComponentVariation(ped, 3, 15, 0, 0)
        SetPedComponentVariation(ped, 4, 2, 5, 0)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 4, 6, 0)
        SetPedComponentVariation(ped, 7, 4, 0, 0)
        SetPedComponentVariation(ped, 8, 3, 0, 0)
        SetPedComponentVariation(ped, 9, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 4, 0, 0)
        ClearPedProp(ped, 0)
        ClearPedProp(ped, 1)
        ClearPedProp(ped, 2)
        ClearPedProp(ped, 3)
        ClearPedProp(ped, 4)
        ClearPedProp(ped, 5)
        ClearPedProp(ped, 6)
        ClearPedProp(ped, 7)
        ClearPedProp(ped, 8)
    elseif a_1 == 5 then
        SetPedComponentVariation(ped, 0, 27, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 7, 3, 0)
        SetPedComponentVariation(ped, 3, 11, 0, 0)
        SetPedComponentVariation(ped, 4, 4, 8, 0)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 13, 14, 0)
        SetPedComponentVariation(ped, 7, 5, 3, 0)
        SetPedComponentVariation(ped, 8, 3, 0, 0)
        SetPedComponentVariation(ped, 9, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 2, 7, 0)
        ClearPedProp(ped, 0)
        ClearPedProp(ped, 1)
        ClearPedProp(ped, 2)
        ClearPedProp(ped, 3)
        ClearPedProp(ped, 4)
        ClearPedProp(ped, 5)
        ClearPedProp(ped, 6)
        ClearPedProp(ped, 7)
        ClearPedProp(ped, 8)
    elseif a_1 == 6 then
        SetPedComponentVariation(ped, 0, 16, 0, 0)
        SetPedComponentVariation(ped, 1, 0, 0, 0)
        SetPedComponentVariation(ped, 2, 15, 1, 0)
        SetPedComponentVariation(ped, 3, 3, 0, 0)
        SetPedComponentVariation(ped, 4, 5, 6, 0)
        SetPedComponentVariation(ped, 5, 0, 0, 0)
        SetPedComponentVariation(ped, 6, 2, 8, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)
        SetPedComponentVariation(ped, 8, 2, 0, 0)
        SetPedComponentVariation(ped, 9, 0, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        SetPedComponentVariation(ped, 11, 3, 7, 0)
        ClearPedProp(ped, 0)
        ClearPedProp(ped, 1)
        ClearPedProp(ped, 2)
        ClearPedProp(ped, 3)
        ClearPedProp(ped, 4)
        ClearPedProp(ped, 5)
        ClearPedProp(ped, 6)
        ClearPedProp(ped, 7)
        ClearPedProp(ped, 8)
    end
end

RegisterNetEvent('introCinematic:start')
AddEventHandler('introCinematic:start', function()
	PrepareMusicEvent("FM_INTRO_START")
	TriggerMusicEvent("FM_INTRO_START")
    local plyrId = PlayerPedId()
    -----------------------------------------------
	if IsMale(plyrId) then
		RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", 31, 8)
	else	
		RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", 103, 8)
	end
    while not HasCutsceneLoaded() do Wait(10) end
	if IsMale(plyrId) then
		RegisterEntityForCutscene(0, 'MP_Male_Character', 3, GetEntityModel(PlayerPedId()), 0)
		RegisterEntityForCutscene(PlayerPedId(), 'MP_Male_Character', 0, 0, 0)
		SetCutsceneEntityStreamingFlags('MP_Male_Character', 0, 1) 
		local female = RegisterEntityForCutscene(0,"MP_Female_Character",3,0,64)
		NetworkSetEntityInvisibleToNetwork(female, true)
	else
		RegisterEntityForCutscene(0, 'MP_Female_Character', 3, GetEntityModel(PlayerPedId()), 0)
		RegisterEntityForCutscene(PlayerPedId(), 'MP_Female_Character', 0, 0, 0)
		SetCutsceneEntityStreamingFlags('MP_Female_Character', 0, 1) 
		local male = RegisterEntityForCutscene(0,"MP_Male_Character",3,0,64) 
		NetworkSetEntityInvisibleToNetwork(male, true)
	end
	local ped = {}
	for v_3=0, 6, 1 do
		if v_3 == 1 or v_3 == 2 or v_3 == 4 or v_3 == 6 then
			ped[v_3] = CreatePed(26, 'mp_f_freemode_01', -1117.77783203125, -1557.6248779296875, 3.3819, 0.0, 0, 0)
		else
			ped[v_3] = CreatePed(26, 'mp_m_freemode_01', -1117.77783203125, -1557.6248779296875, 3.3819, 0.0, 0, 0)
		end
        if not IsEntityDead(ped[v_3]) then
			sub_b747(ped[v_3], v_3)
            FinalizeHeadBlend(ped[v_3])
            RegisterEntityForCutscene(ped[v_3], sub_b0b5[v_3], 0, 0, 64)
        end
    end
	
	NewLoadSceneStartSphere(-1212.79, -1673.52, 7, 1000, 0)

    SetWeatherTypeNow("EXTRASUNNY")
    StartCutscene(4)

    Wait(38600)
     StopCutsceneImmediately()
	for v_3=0, 6, 1 do
		DeleteEntity(ped[v_3])
	end
	PrepareMusicEvent("AC_STOP")
	TriggerMusicEvent("AC_STOP")
    TriggerServerEvent('rCreator:setPlayerToNormalBucket')
    SetEntityCoords(PlayerPedId(), Creator.SpawnAfterCreate)
    SetEntityHeading(PlayerPedId(), Creator.headingAfterCreate)
    TriggerEvent("bulletin:sendAdvanced", "Bienvenu à Los Santos 🎉", "Bienvenue", "~g~Mboka~s~ RolePlay", Creator.CharNotif, 10000)
    TriggerServerEvent('esx_skin:save', Character)
	TriggerEvent('skinchanger:loadSkin', Character)
end)


function IsMale(ped)
	if IsPedModel(ped, 'mp_m_freemode_01') then
		return true
	else
		return false
	end
end

AddEventHandler('playerSpawned', function()
	CreateThread(function()
		while not PlayerLoaded do Wait(10) end

		if FirstSpawn then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin == nil then
                    Wait(3000)
                    TriggerServerEvent("rCreator:setPlayerToBucket", GetPlayerServerId(PlayerId()))
                    menuIdentity()
                else
                    TriggerEvent('skinchanger:loadSkin', skin)
				end
			end)
			FirstSpawn = false
		end
	end)
end)

RegisterCommand("tsregister", function()
    TriggerServerEvent("rCreator:setPlayerToBucket", GetPlayerServerId(PlayerId()))
    menuIdentity()
end)

-- Apparence modification
local pedModel = 'mp_m_freemode_01'
function changeGender(sex)
	if sex == 1 then
		Character['sex'] = 0
		pedModel = 'mp_m_freemode_01'
		changeModel(pedModel)
	else
		Character['sex'] = 1
		pedModel = 'mp_f_freemode_01'
		changeModel(pedModel)
	end
end

function changeModel(skin)
	local model = GetHashKey(skin)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetPedDefaultComponentVariation(PlayerPedId())

        if skin == 'mp_m_freemode_01' then
            SetPedComponentVariation(GetPlayerPed(-1), 3, 15, 0, 2) -- arms
            SetPedComponentVariation(GetPlayerPed(-1), 11, 15, 0, 2) -- torso
            SetPedComponentVariation(GetPlayerPed(-1), 8, 15, 0, 2) -- tshirt
            SetPedComponentVariation(GetPlayerPed(-1), 4, 61, 4, 2) -- pants
            SetPedComponentVariation(GetPlayerPed(-1), 6, 34, 0, 2) -- shoes

            Character['arms'] = 15
            Character['torso_1'] = 15
            Character['tshirt_1'] = 15
            Character['pants_1'] = 61
            Character['pants_2'] = 4
            Character['shoes_1'] = 34
            Character['glasses_1'] = 0


        elseif skin == 'mp_f_freemode_01' then
            SetPedComponentVariation(GetPlayerPed(-1), 3, 15, 0, 2) -- arms
            SetPedComponentVariation(GetPlayerPed(-1), 11, 5, 0, 2) -- torso
            SetPedComponentVariation(GetPlayerPed(-1), 8, 15, 0, 2) -- tshirt
            SetPedComponentVariation(GetPlayerPed(-1), 4, 57, 0, 2) -- pants
            SetPedComponentVariation(GetPlayerPed(-1), 6, 35, 0, 2) -- shoes

            Character['arms'] = 15
            Character['torso_1'] = 5
            Character['tshirt_1'] = 15
            Character['pants_1'] = 57
            Character['pants_2'] = 0
            Character['shoes_1'] = 35
            Character['glasses_1'] = -1
        end


        SetModelAsNoLongerNeeded(model)
    end
end

Apperance = {
	{
		item = 'Coupe de Cheveux',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'component',
		itemID = 2,
		PercentagePanel = false,
		ColourPanel = true,
	},
	{
		item = 'Sourcils',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 2,
		PercentagePanel = true,
		ColourPanel = true,
	},
	{
		item = 'Barbe',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 1,
		PercentagePanel = true,
		ColourPanel = true,
	},
	{
		item = 'Imperfection cutanées',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11},
		index = 1,
		indextwo = 1,
		cam = 'body',
		itemType = 'headoverlay',
		itemID = 11,
		PercentagePanel = true,
	},
	{
		item = 'Vieillissement de la peau',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 3,
		PercentagePanel = true,
	},
	{
		item = 'Acnée',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17, 18, 19, 20, 21, 22, 23},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 0,
		PercentagePanel = true,
	},
	{
		item = 'Taches de rousseur',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 9,
		PercentagePanel = true,
	},
	{
		item = 'Dommages de la peau',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 7,
		PercentagePanel = true,
	},
	{
		item = 'Couleur des yeux',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'eye'
	},
	{
		item = 'Maquillage pour les yeux',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 4,
		PercentagePanel = true,
		ColourPanel = true,
	},
	{
		item = 'Rouge à lèvre',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 8,
		PercentagePanel = true,
		ColourPanel = true,
	},
	{
		item = 'Poil sur le torse',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16},
		index = 1,
		indextwo = 1,
		cam = 'body',
		itemType = 'headoverlay',
		itemID = 10,
		PercentagePanel = true,
		ColourPanel = true,
	},
	{
		item = 'Rougeur',
		List = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 ,16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32},
		index = 1,
		indextwo = 1,
		cam = 'face',
		itemType = 'headoverlay',
		itemID = 5,
		PercentagePanel = true,
		ColourPanel = true,
	},
}

function updateApperance(id, color)
	local app = Apperance[id]
	local playerPed = PlayerPedId()
	if not color then
		if app.itemType == 'component' then
			SetPedComponentVariation(playerPed, app.itemID, app.index, 0, 2)
			Character[app.item..'_1'] = app.index
	    elseif app.itemType == 'headoverlay' then
			SetPedHeadOverlay(playerPed, app.itemID, app.index, math.floor(app.indextwo)/10+0.0)
			Character[app.item..'_1'] = app.index
			Character[app.item..'_2'] = math.floor(app.indextwo)
	    elseif app.itemType == 'eye' then
			SetPedEyeColor(playerPed, app.index, 0, 1)
			Character['eye_color'] = app.index
	    end
	end

    if color then
    	if app.itemType == 'component' then
            SetPedHairColor(playerPed, app.indextwo, 0)
            Character['hair_color_1'] = app.indextwo
        elseif app.itemType == 'headoverlay' then
            SetPedHeadOverlayColor(playerPed, app.itemID, 1, app.indextwo, 0)
            Character[app.item..'_3'] = app.indextwo
        end
    end	
end