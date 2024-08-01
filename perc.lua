-- Perc
--
-- Generate some percussion.
--
-- Note: This only outputs
-- MIDI. No sound is generated.
--
-- 0.0.1 @jtopjian
--
-- See the settings pages for
-- all settings.
--
-- E1: Switch between viewing
-- sounds 1-4 and 5-8
--
-- Some of this was based off of
-- The Endless Acid Banger
-- https://github.com/zykure/acid-banger
-- https://github.com/vitling/acid-banger

-- Version
VERSION = "0.0.1"

PercLib = include('lib/perc')
Midi = include("lib/midi")
PercUI = include("lib/ui")

MusicUtil = require "musicutil"
NornsUtil = require "lib.util"
NornsUI = require 'ui'

local pattern = {}
local pattern_pos_4 = 0
local pattern_pos_3 = 0

local SCREEN_FRAMERATE = 15
local screen_refresh_metro
local screen_dirty = true

local perc_refresh_metro = nil
local random_mute_perc_metro = nil

-- autosave parameters
function autosave_clock()
  clock.sleep(30)
  while true do
    params:write()
    clock.sleep(30)
  end
end

-- midi event monitoring
function clock.transport.start()
  pattern_pos_4 = 0
  pattern_pos_3 = 0
  Midi.start()
end

function clock.transport.stop()
  Midi.stop()
end

function clock.transport.reset()
  Midi.stop()
  pattern_pos_4 = 0
  pattern_pos_3 = 0
  Midi.start()
end

function midi_event(data)
  local msg = midi.to_msg(data)
  if msg.type == "start" then
    clock.transport.start()
  elseif msg.type == "continue" then
    if Midi.RUNNING then
      clock.transport.stop()
    else
      clock.transport.start()
    end
  end
  if msg.type == "stop" then
    clock.transport.stop()
  end
end

-- event loop
-- 4/4 signature
function step_4()
  while true do
    screen_dirty = true
    clock.sync(1/4)
    local p = {}

    if Midi.RUNNING then
      for key_idx, key in pairs(PercLib.perc_keys) do
        if PercLib.triplets[key] == nil or PercLib.triplets[key] == 0 then
          if PercLib.perc_mutes[key_idx] == 0 then
            p[key] = pattern[key]
          end
        end
      end
      -- Run the pattern
      pattern_pos_4 = NornsUtil.wrap(pattern_pos_4+1, 1, 16)
      Midi.play_perc(p, pattern_pos_4, false)
    end
  end
end

-- triplet signature
function step_3()
  while true do
    screen_dirty = true
    clock.sync(1/3)
    local p = {}

    if Midi.RUNNING then
      for key_idx, key in pairs(PercLib.perc_keys) do
        if PercLib.triplets[key] ~= nil and PercLib.triplets[key] == 1 then
          if PercLib.perc_mutes[key_idx] == 0 then
            p[key] = pattern[key]
          end
        end
      end
      -- Run the pattern
      pattern_pos_3 = NornsUtil.wrap(pattern_pos_3+1, 1, 12)
      Midi.play_perc(p, pattern_pos_3, true)
    end
  end
end

-- Screen graphics
function redraw()
  screen.clear()
  pages:redraw()

  -- draw the title bar
  PercUI.draw_title_bar()

  -- draw the pattern
  draw_pattern()
end


-- Draw the pattern
function draw_pattern()
  screen.level(15)
  screen.line_width(1)
  screen.font_size(8)
  local screen_x = 0
  local screen_y = 64
  screen.move(screen_x, screen_y)

  local key_start = 1
  local key_end = 4
  if pages.index == 2 then
    key_start = 5
    key_end = 8
  end

  for key_idx=key_start, key_end do
    local key = PercLib.perc_keys[key_idx]
    local pattern_end = 16
    local triplet = false
    local pattern_pos = pattern_pos_4
    if PercLib.triplets[key] == 1 then
      triplet = true
      pattern_end = 12
      pattern_pos = pattern_pos_3
    end

    screen.level(5)
    if PercLib.perc_mutes[key_idx] == 1 then
      screen.level(3)
    end
    screen.text(key)
    screen.stroke()
    screen_x = screen_x + 14
    if triplet then
      screen_x = screen_x + 3
    end
    screen.move(screen_x, screen_y)
    screen.close()

    for i=1, pattern_end do
      local pattern = pattern[key]

      screen.level(1)
      if pattern[i] ~= false then
        screen.level(5)
      end

      if i == pattern_pos then
        screen.level(15)
      end

      screen.line_rel(0, -5)
      screen.line_rel(4, 0)
      screen.line_rel(0, 5)
      screen.fill()
      screen.close()
      screen.stroke()

      screen_x = screen_x + 7
      if triplet then
        screen_x = screen_x + 1
        if i % 3 == 0 then
          screen_x = screen_x + 4
        end
      end
      screen.move(screen_x, screen_y)
    end
    screen_y = screen_y - 13
    screen_x = 0
    screen.move(screen_x, screen_y)
  end

  screen.update()
end


-- Encoder
function enc(n, delta)
  if n == 1 then
    pages:set_index_delta(NornsUtil.clamp(delta, -1, 1), false)
  end
  screen_dirty = true
end

function key(n, z)
  if z == 1 then
    if n == 2 then
      pattern =  PercLib.create_pattern()
    end

    if n == 3 then
      if Midi.RUNNING then
        Midi.RUNNING = 0
        clock.transport.stop()
      else
        Midi.RUNNING = 1
        clock.transport.start()
      end
    end

    screen_dirty = true
  end
end

-- Start here
function init()
  pages = NornsUI.Pages.new(1, 2)

  params:add_separator("PERC")
  PercLib.add_params()
  Midi.add_params()
  params:default()
  Midi.midi_out_device.event = midi_event
  autosave_clock_id = clock.run(autosave_clock)

  pattern =  PercLib.create_pattern()

  clock.run(step_4)
  clock.run(step_3)

  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    if screen_dirty then
      screen_dirty = false
      redraw()
    end
  end
  screen_refresh_metro:start(1 / SCREEN_FRAMERATE)

  perc_refresh_metro = metro.init()
  perc_refresh_metro.event = function()
    if params:get("perc_refresh") == 1 then
      pattern = PercLib.create_pattern()
    end
  end
  perc_refresh_metro:start(params:get("perc_refresh_seconds"))

  random_mute_perc_metro = metro.init()
  random_mute_perc_metro.event = function()
    if params:get("random_mute_perc") == 1 then
      PercLib.mute_perc()
    end
  end
  random_mute_perc_metro:start(60)

end

-- Cleanup here
function cleanup()
  clock.cancel(autosave_clock_id)
  params:write()
end
