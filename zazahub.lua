-- KILL AURA COMPLETO

local TargetPlayer = nil
local AttackAll = false
local KillAuraConnection = nil

-- Buscar jugador por nombre
local function FindPlayer(name)
	for _,player in pairs(Players:GetPlayers()) do
		if string.find(string.lower(player.Name), string.lower(name)) then
			return player
		end
	end
end

-- Iniciar Kill Aura
local function StartKillAura()

	if KillAuraConnection then
		KillAuraConnection:Disconnect()
	end

	KillAuraConnection = RunService.Heartbeat:Connect(function()

		if not Settings.KillAura.Enabled then return end

		local char = LocalPlayer.Character
		if not char then return end

		local myHRP = char:FindFirstChild("HumanoidRootPart")
		if not myHRP then return end


		-- 🌍 GOLPEAR A TODOS
		if AttackAll then

			for _,player in pairs(Players:GetPlayers()) do

				if player ~= LocalPlayer and player.Character then

					local hum = player.Character:FindFirstChild("Humanoid")
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")

					if hum and hrp and hum.Health > 0 then

						local dist = (hrp.Position - myHRP.Position).Magnitude

						if dist <= Settings.KillAura.Range then
							pcall(function()
								HitRemote:InvokeServer(hum,myHRP.Position)
							end)
						end

					end
				end
			end


		-- 🎯 OBJETIVO ESPECÍFICO
		elseif TargetPlayer and TargetPlayer.Character then

			local hum = TargetPlayer.Character:FindFirstChild("Humanoid")
			local hrp = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")

			if hum and hrp then

				local dist = (hrp.Position - myHRP.Position).Magnitude

				if dist <= Settings.KillAura.Range then
					pcall(function()
						HitRemote:InvokeServer(hum,myHRP.Position)
					end)
				end

			end


		-- 🔎 MAS CERCANO
		else

			local closest = nil
			local closestDist = Settings.KillAura.Range

			for _,player in pairs(Players:GetPlayers()) do

				if player ~= LocalPlayer and player.Character then

					local hum = player.Character:FindFirstChild("Humanoid")
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")

					if hum and hrp and hum.Health > 0 then

						local dist = (hrp.Position - myHRP.Position).Magnitude

						if dist <= closestDist then
							closestDist = dist
							closest = player
						end

					end
				end
			end

			if closest and closest.Character then

				local hum = closest.Character:FindFirstChild("Humanoid")

				if hum then
					pcall(function()
						HitRemote:InvokeServer(hum,myHRP.Position)
					end)
				end

			end

		end

	end)

end


-- Parar Kill Aura
local function StopKillAura()

	if KillAuraConnection then
		KillAuraConnection:Disconnect()
		KillAuraConnection = nil
	end

end
