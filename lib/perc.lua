-- Perc Pattern code

MusicUtil = require "musicutil"

local Perc = {}
Perc.triplets = {
  ["P1"] = 0,
  ["P2"] = 0,
  ["P3"] = 0,
  ["P4"] = 0,
}

Perc.perc_keys = {"BD", "SD", "CH", "OH", "P1", "P2", "P3", "P4"}
Perc.perc_mutes = {0, 0, 0, 0, 0, 0, 0, 0}

local bd_mode = {"electro", "fourfloor"}
local sd_mode = {"backbeat", "skip"}
local hat_mode = {"offbeats", "skip"}
local density = 1


-- Logic for BD, SD, CH, and OH was taken from the Endless Acid Banger
-- https://github.com/zykure/acid-banger
-- https://github.com/vitling/acid-banger
function Perc.create_pattern()
  local pattern = {
    ["BD"] = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
    ["SD"] = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
    ["CH"] = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
    ["OH"] = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false},
    ["P1"] = {},
    ["P2"] = {},
    ["P3"] = {},
    ["P4"] = {},
  }

  -- BD / Kick
  if bd_mode[math.random(#bd_mode)] == "fourfloor" then
    for i=0, 15 do
      if i % 4 == 0 then
        pattern["BD"][i+1] = 0.9
      elseif i % 2 == 0 and math.random() < 0.1 then
        pattern["BD"][i+1] = 0.6
      end
    end
  else
    for i=0, 15 do
      if i == 0 then
        pattern["BD"][i+1] = 1
      elseif i % 2 == 0 and i % 8 ~= 4 and math.random() < 0.5 then
        pattern["BD"][i+1] = math.random() * 0.9
      elseif math.random() < 0.05 then
        pattern["BD"][i+1] = math.random() * 0.9
      end
    end
  end

  -- SD / Snare
  if sd_mode[math.random(#sd_mode)] == "backbeat" then
    for i=0, 15 do
      if i % 8 == 4 then
        pattern["SD"][i+1] = 1
      end
    end
  else
    for i=0, 15 do
      if i % 8 == 3 or i % 8 == 6 then
        pattern["SD"][i+1] = 0.6 + math.random() * 0.4
      elseif i % 2 == 0 and math.random() < 0.2 then
        pattern["SD"][i+1] = 0.4 + math.random() * 0.2
      elseif math.random() < 0.1 then
        pattern["SD"][i+1] = 0.2 + math.random() * 0.2
      end
    end
  end

  -- Hats
  if hat_mode[math.random(#hat_mode)] == "offbeats" then
    for i=0, 15 do
      if i % 4 == 2 then
        pattern["OH"][i+1] = 0.4
      elseif math.random() < 0.3 then
        if math.random() < 0.5 then
          pattern["CH"][i+1] = 0.2 + math.random() * 0.2
        else
          pattern["OH"][i+1] = 0.1 + math.random() * 0.2
        end
      end
    end
  else
    for i=0, 15 do
      if i % 2 == 0 then
        pattern["CH"][i+1] = 0.4
      elseif math.random() < 0.5 then
        pattern["CH"][i+1] = 0.2 + math.random() * 0.3
      end
    end
  end

  -- Percussion
  for _, p in pairs({"P1", "P2", "P3", "P4"}) do
    local idx = 15
    if Perc.triplets[p] == 1 then
      idx = 11
    end

    for i=0, idx do
      if math.random() < 0.5 then
        table.insert(pattern[p], 0.2 + math.random() * 0.3)
      else
        table.insert(pattern[p], false)
      end
    end
  end

  return pattern
end

function Perc.mute_perc()
  for key_idx=1, #Perc.perc_keys do
    Perc.perc_mutes[key_idx] = 0
  end
  if math.random() > 0.3 then
    random_key = math.random(#Perc.perc_keys)
    Perc.perc_mutes[random_key] = 1
  end
end

function Perc.add_params()
  params:add_group("Perc Options", 7)
  params:add {
    type = "number",
    id = "perc_refresh",
    name = "Refresh Drums",
    min = 0,
    max = 1,
    default = 1,
  }

  params:add {
    type = "number",
    id = "perc_refresh_seconds",
    name = "Refresh Drums Seconds",
    min = 1,
    max = 600,
    default = 330,
  }

  params:add {
    type = "number",
    id = "random_mute_perc",
    name = "Randomly Mute Drums",
    min = 0,
    max = 1,
    default = 1,
  }

  params:add {
    type = "number",
    name = "P1 Triplet",
    id = "p1_triplet",
    min = 0,
    max = 1,
    default = 0,
    action = function(x)
      Perc.triplets["P1"] = x
    end
  }

  params:add {
    type = "number",
    name = "P2 Triplet",
    id = "p2_triplet",
    min = 0,
    max = 1,
    default = 0,
    action = function(x)
      Perc.triplets["P2"] = x
    end
  }

  params:add {
    type = "number",
    name = "P3 Triplet",
    id = "p3_triplet",
    min = 0,
    max = 1,
    default = 0,
    action = function(x)
      Perc.triplets["P3"] = x
    end
  }

  params:add {
    type = "number",
    name = "P4 Triplet",
    id = "p4_triplet",
    min = 0,
    max = 1,
    default = 0,
    action = function(x)
      Perc.triplets["P4"] = x
    end
  }

end


return Perc
