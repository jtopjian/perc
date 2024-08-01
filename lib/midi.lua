-- MIDI Functions

MusicUtil = require "musicutil"

local midi_out = {}

midi_out.midi_out_device = nil
midi_out.accent_velocity = 127
midi_out.velocity = 100
midi_out.RUNNING = true

midi_out.channels = {
  ["BD"] = nil,
  ["SD"] = nil,
  ["CH"] = nil,
  ["OH"] = nil,

  ["P1"] = nil,
  ["P2"] = nil,
  ["P3"] = nil,
  ["P4"] = nil
}

midi_out.perc_notes = {
  ["BD"] = 60,
  ["SD"] = 60,
  ["CH"] = 60,
  ["OH"] = 60,
  ["P1"] = 60,
  ["P2"] = 60,
  ["P3"] = 60,
  ["P4"] = 60
}

-- MIDI Parameters
function midi_out.add_params()
  local devices = {}
  for id, device in pairs(midi.vports) do
    devices[id] = device.name
  end

  params:add_group("MIDI", 17)

  -- Add MIDI device param
  params:add {
    type = "option",
    id = "midi_device",
    name = "Device",
    options = devices,
    default = 1,
    action = function(x)
      midi_out.midi_out_device = midi.connect(x)
    end
  }

  -- Add MIDI channel for the BD
  params:add {
    type = "number",
    id = "midi_channel_bd",
    name = "BD Channel",
    min = 1,
    max = 16,
    default = 1,
    action = function(x)
      midi_out.channels["BD"] = x
      midi_out.all_notes_off("BD")
    end
  }

  params:add {
    type = "number",
    id = "root_note_bd",
    name = "BD Root Note",
    min = 0,
    max = 127,
    default = 60,
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function(x)
      midi_out.perc_notes["BD"] = x
    end
  }

  -- Add MIDI channel for the SD
  params:add {
    type = "number",
    id = "midi_channel_sd",
    name = "SD Channel",
    min = 1,
    max = 16,
    default = 2,
    action = function(x)
      midi_out.channels["SD"] = x
      midi_out.all_notes_off("SD")
    end
  }

  params:add {
    type = "number",
    id = "root_note_sd",
    name = "SD Root Note",
    min = 0,
    max = 127,
    default = 60,
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function(x)
      midi_out.perc_notes["SD"] = x
    end
  }

  -- Add MIDI channel for the CH
  params:add {
    type = "number",
    id = "midi_channel_ch",
    name = "CH Channel",
    min = 1,
    max = 16,
    default = 3,
    action = function(x)
      midi_out.channels["CH"] = x
      midi_out.all_notes_off("CH")
    end
  }

  params:add {
    type = "number",
    id = "root_note_ch",
    name = "CH Root Note",
    min = 0,
    max = 127,
    default = 60,
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function(x)
      midi_out.perc_notes["CH"] = x
    end
  }

  -- Add MIDI channel for the OH
  params:add {
    type = "number",
    id = "midi_channel_oh",
    name = "OH Channel",
    min = 1,
    max = 16,
    default = 4,
    action = function(x)
      midi_out.channels["OH"] = x
      midi_out.all_notes_off("OH")
    end
  }

  params:add {
    type = "number",
    id = "root_note_oh",
    name = "OH Root Note",
    min = 0,
    max = 127,
    default = 60,
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function(x)
      midi_out.perc_notes["OH"] = x
    end
  }

  -- Add MIDI channel for perc 1
  params:add {
    type = "number",
    id = "midi_channel_p1",
    name = "P1 Channel",
    min = 1,
    max = 16,
    default = 5,
    action = function(x)
      midi_out.channels["P1"] = x
      midi_out.all_notes_off("P1")
    end
  }

  params:add {
    type = "number",
    id = "root_note_p1",
    name = "P1 Root Note",
    min = 0,
    max = 127,
    default = 60,
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function(x)
      midi_out.perc_notes["P1"] = x
    end
  }

  -- Add MIDI channel for perc 2
  params:add {
    type = "number",
    id = "midi_channel_p2",
    name = "P2 Channel",
    min = 1,
    max = 16,
    default = 6,
    action = function(x)
      midi_out.channels["P2"] = x
      midi_out.all_notes_off("P2")
    end
  }

  params:add {
    type = "number",
    id = "root_note_p2",
    name = "P2 Root Note",
    min = 0,
    max = 127,
    default = 60,
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function(x)
      midi_out.perc_notes["P2"] = x
    end
  }

  -- Add MIDI channel for perc 3
  params:add {
    type = "number",
    id = "midi_channel_p3",
    name = "P3 Channel",
    min = 1,
    max = 16,
    default = 7,
    action = function(x)
      midi_out.channels["P3"] = x
      midi_out.all_notes_off("P3")
    end
  }

  params:add {
    type = "number",
    id = "root_note_p3",
    name = "P3 Root Note",
    min = 0,
    max = 127,
    default = 60,
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function(x)
      midi_out.perc_notes["P3"] = x
    end
  }

  -- Add MIDI channel for perc 4
  params:add {
    type = "number",
    id = "midi_channel_p4",
    name = "P4 Channel",
    min = 1,
    max = 16,
    default = 8,
    action = function(x)
      midi_out.channels["P4"] = x
      midi_out.all_notes_off("P4")
    end
  }

  params:add {
    type = "number",
    id = "root_note_p4",
    name = "P1 Root Note",
    min = 0,
    max = 127,
    default = 60,
    formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function(x)
      midi_out.perc_notes["P4"] = x
    end
  }
end

function midi_out.play_perc(pattern, pos, triplet)
  local step_length = clock.get_beat_sec() / 4
  if triplet then
   local step_length = clock.get_beat_sec() / 3
 end


  for key, p in pairs(pattern) do
    if p[pos] ~= false then
      local note = midi_out.perc_notes[key]
      local vel = math.floor(p[pos] * 127)
      midi_out.note_on(note, vel, key)
      clock.run(midi_out.schedule_note_off, note, step_length, key)
    end
  end
end

-- MIDI Functions
function midi_out.start()
  midi_out.RUNNING = true
  for key_idx, key in pairs(PercLib.perc_keys) do
    midi_out.all_notes_off(key)
  end
end

function midi_out.stop()
  midi_out.RUNNING = false
  for key_idx, key in pairs(PercLib.perc_keys) do
    midi_out.all_notes_off(key)
  end
end

function midi_out.note_on(note, velocity, channel)
  midi_out.midi_out_device:note_on(note, velocity, midi_out.channels[channel])
end

function midi_out.note_off(note, channel)
  if midi_out.midi_out_device ~= nil then
    midi_out.midi_out_device:note_off(note, nil, midi_out.channels[channel])
  end
end

function midi_out.all_notes_off(channel)
  if midi_out.midi_out_device ~= nil then
    midi_out.midi_out_device:cc(123, 0, midi_out.channels[channel])
  end
end

function midi_out.schedule_note_off(note, step_length, channel)
  local sleeptime = step_length * 0.5
  clock.sleep(sleeptime)
  midi_out.note_off(note, channel)
end

function midi_out.init()
  midi_out.midi_out_device = midi.connect(1)
  midi_out.midi_out_device.event = function() end

  midi_out.paramGroupName = "MIDI Output"
  midi_out.addParams()
  midi_out.all_notes_off()
end

return midi_out
