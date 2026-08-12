local function toggleTableAttribute(attribute, value)
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" and rawget(gcVal, attribute) then
            gcVal[attribute] = value
        end
    end
end

toggleTableAttribute("ShootCooldown", 0)
toggleTableAttribute("ShootSpread", 0)
toggleTableAttribute("ShootRecoil", 0)
toggleTableAttribute("AttackCooldown", 0)
toggleTableAttribute("DeflectCooldown", 0)
toggleTableAttribute("DashCooldown", 0)
toggleTableAttribute("Cooldown", 0)
toggleTableAttribute("SpinCooldown", 0)
toggleTableAttribute("BuildCooldown", 0)
toggleTableAttribute("ShootBurstCooldown", 0)
toggleTableAttribute("HeavyAttackCooldown", 0)
toggleTableAttribute("SlamCooldown", 0)
toggleTableAttribute("LeapCooldown", 0)
toggleTableAttribute("ChargeReleaseCooldown", 0)
toggleTableAttribute("QuickShotCooldown", 0)
toggleTableAttribute("BladeCooldown", 0)
toggleTableAttribute("VortexCooldown", 0)
toggleTableAttribute("AirblastCooldown", 0)
toggleTableAttribute("InternalUseCooldown", 0)
toggleTableAttribute("InternalHoldCooldown", 0)
toggleTableAttribute("EquipCooldown", 0)

print("done!")
