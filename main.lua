local allowedUserIds = {5501220047, 7377110745, 2815154822}
local player = game:GetService("Players").LocalPlayer

local function checkAuthorization()
    for _, userId in ipairs(allowedUserIds) do
        if player.UserId == userId then return true end
    end
    return false
end

if checkAuthorization() then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Successfully Authorized",
        Text = "You have permission to use this Script",
        Duration = 5
    })

    local Fluent = loadstring(game:HttpGet(
                                  "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet(
                                       "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

    local Window = Fluent:CreateWindow({
        Title = "By Vyxon",
        SubTitle = "Muscle Legends | Rebirth V2",
        TabWidth = 140,
        Size = UDim2.fromOffset(450, 280),
        Acrylic = false,
        Transparency = 1,
        Theme = "Darker"
    })

    local Tabs = {
        Main = Window:AddTab({Title = "Auto Boost", Icon = "egg"}),
        Fast = Window:AddTab({
            Title = "Fast Tools",
            Icon = "rbxassetid://10709797622"
        }),
        Rebirth = Window:AddTab({
            Title = "Rebirth",
            Icon = "rbxassetid://10734933222"
        }),
        Visual = Window:AddTab({
            Title = "Visual",
            Icon = "rbxassetid://10723346871"
        })
    }

    local AutoEatProteinToggle = Tabs.Main:AddToggle("AutoEatProteinToggle", {
        Title = "Auto Eat Egg",
        Description = "Automatically eats Protein Egg",
        Default = false
    })

    AutoEatProteinToggle:OnChanged(function()
        if AutoEatProteinToggle.Value then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()

            local function equipProteinEgg()
                local backpack = player:WaitForChild("Backpack")
                local proteinEggTool = backpack:FindFirstChild("Protein Egg")
                if proteinEggTool then
                    character:WaitForChild("Humanoid"):EquipTool(proteinEggTool)
                else
                    warn("Protein Egg tool not found in Backpack!")
                end
            end

            local function fireMuscleEvent()
                local proteinEgg = workspace:FindFirstChild(player.Name) and
                                       workspace[player.Name]:FindFirstChild(
                                           "Protein Egg")
                if proteinEgg then
                    player.muscleEvent:FireServer("proteinEgg", proteinEgg)
                else
                    warn("Protein Egg object not found in Workspace!")
                end
            end

            local function runEvery30Minutes()
                while AutoEatProteinToggle.Value do
                    equipProteinEgg()
                    fireMuscleEvent()
                    task.wait(1800)
                end
            end

            task.spawn(runEvery30Minutes)
            AutoEatProteinToggle.BackgroundColor = Color3.fromRGB(255, 0, 0)
        else
            AutoEatProteinToggle.BackgroundColor = Color3.fromRGB(0, 0, 0)
        end
    end)

    local PetManager = {}
    PetManager.__index = PetManager

    local g = game
    local Player = g:GetService("Players").LocalPlayer
    local REvents = g:GetService("ReplicatedStorage").rEvents

    local PetManagerToggle = Tabs.Rebirth:AddToggle("PetManagerToggle", {
        Title = "Auto OP Reb",
        Description = "Automatically equips Swift and Tribal",
        Default = false
    })

    function PetManager.new(player, rEvents)
        local self = setmetatable({}, PetManager)
        self.Player = player
        self.REvents = rEvents
        self.Enabled = false
        return self
    end

    function PetManager:equipPet(pet)
        self.REvents.equipPetEvent:FireServer("equipPet", pet)
    end

    function PetManager:unequipPet(pet)
        self.REvents.equipPetEvent:FireServer("unequipPet", pet)
    end

    function PetManager:rebirth()
        self.REvents.rebirthRemote:InvokeServer("rebirthRequest")
    end

    function PetManager:getPetsByName(pattern)
        local pets = {}
        for _, pet in pairs(self.Player.petsFolder.Unique:GetChildren()) do
            if pet.Name:match(pattern) then table.insert(pets, pet) end
        end
        return pets
    end

    function PetManager:startLoop()
        self.Enabled = true

        task.spawn(function()
            while self.Enabled do
                local samuraiPets = self:getPetsByName("Swift Samurai")
                local overlordPets = self:getPetsByName("Tribal Overlord")

                for _, pet in pairs(samuraiPets) do
                    self:equipPet(pet)
                end

                task.wait(5)

                for _, pet in pairs(samuraiPets) do
                    self:unequipPet(pet)
                end

                for _, pet in pairs(overlordPets) do
                    self:equipPet(pet)
                end

                for i = 1, 10 do
                    self:rebirth()
                    task.wait(0.01)
                end

                for _, pet in pairs(overlordPets) do
                    self:unequipPet(pet)
                end
            end
        end)
    end

    function PetManager:stopLoop() self.Enabled = false end

    local Manager = PetManager.new(Player, REvents)

    PetManagerToggle:OnChanged(function(value)
        if value then
            Manager:startLoop()
        else
            Manager:stopLoop()
        end
    end)

    local RepTimeToggle = Tabs.Fast:AddToggle("RepTimeToggle", {
        Title = "Remove Rep Cooldown",
        Description = "No cooldown, for machines",
        Default = false
    })

    RepTimeToggle:OnChanged(function()
        local function updateRepTimeValues()
            for _, obj in ipairs(game:GetDescendants()) do
                if obj:IsA("NumberValue") and obj.Name == "repTime" then
                    if RepTimeToggle.Value then
                        obj.Value = 0
                        RepTimeToggle.BackgroundColor =
                            Color3.fromRGB(255, 0, 0)
                    else
                        obj.Value = 1
                        RepTimeToggle.BackgroundColor = Color3.fromRGB(0, 0, 0)
                    end
                end
            end
        end
        updateRepTimeValues()
    end)

    local AutoLiftToggle = Tabs.Fast:AddToggle("AutoLiftToggle", {
        Title = "Auto Lift",
        Description = "Automatically Lifts",
        Default = false
    })

    AutoLiftToggle:OnChanged(function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local autoLiftValue = LocalPlayer:FindFirstChild("autoLiftEnabled")
        if autoLiftValue then
            if AutoLiftToggle.Value then
                autoLiftValue.Value = true
            else
                autoLiftValue.Value = false
            end
        end
    end)

    local RemoveFramesToggle = Tabs.Visual:AddToggle("RemoveFramesToggle", {
        Title = "Remove Stats Frames",
        Description = "Removes Frames such as Strength etc.. (More FPS)",
        Default = false
    })

    RemoveFramesToggle:OnChanged(function()
        local strengthFrame = game:GetService("ReplicatedStorage")
                                  :FindFirstChild("strengthFrame")
        local durabilityFrame = game:GetService("ReplicatedStorage")
                                    :FindFirstChild("durabilityFrame")
        local agilityFrame = game:GetService("ReplicatedStorage")
                                 :FindFirstChild("agilityFrame")

        if strengthFrame then
            strengthFrame.Visible = not RemoveFramesToggle.Value
        end
        if durabilityFrame then
            durabilityFrame.Visible = not RemoveFramesToggle.Value
        end
        if agilityFrame then
            agilityFrame.Visible = not RemoveFramesToggle.Value
        end
    end)

    local UIS = game:GetService("UserInputService")
    local VU = game:GetService("VirtualUser")
    local clickSpeed = 0

    local FastGainToggle = Tabs.Fast:AddToggle("FastGainToggle", {
        Title = "Fast Gain",
        Description = "Enables fast Gains",
        Default = false
    })

    local function AutoClick()
        while FastGainToggle.Value do
            -- Get the screen dimensions (width and height)
            local screenWidth = game:GetService("Workspace").CurrentCamera
                                    .ViewportSize.X
            local screenHeight = game:GetService("Workspace").CurrentCamera
                                     .ViewportSize.Y

            -- Click at the bottom-right corner of the screen
            VU:ClickButton1(Vector2.new(screenWidth - 10, screenHeight - 10)) -- Adjusted slightly off the corner

            task.wait(clickSpeed) -- Adjust speed of clicks
        end
    end

    FastGainToggle:OnChanged(function()
        if FastGainToggle.Value then
            spawn(AutoClick) -- Run the AutoClick function asynchronously
        end
    end)

    Window:SelectTab(1)
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Not authorized",
        Text = "You don't have permission to use this Script",
        Duration = 5
    })
    warn("You are not authorized to use this script.")
    return
end
