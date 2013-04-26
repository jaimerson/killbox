$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'config'))
require 'environment'
require GAMEBOX_PATH + 'spec/helper'


module FoxyAcceptanceHelpers
  def configure_game_with_testing_stage(opts={})
    opts[:tileset] ||= "tileset" # will look for a png in spec/fixtures/graphics/map/
    opts[:tile_size] ||= 36 # 36x36 is the size of tiles in tileset.png, but this can be changed for testing purposes
    opts[:player_count] ||= 1

    Gamebox.configuration.stages = [:level_play]
    Stage.definitions[:level_play].curtain_up do
      extend TestStageHelpers
      begin

      director.update_slots = [:first, :before, :update, :last]

      tmx_map = FoxyAcceptanceHelpers.get_test_map(opts[:map_name])
      map_data = LevelLoader::MapData.new
      map_data.tile_grid = LevelLoader.generate_map(tmx_map)[0]

      map_data.tileset_image = "map/#{opts[:tileset]}.png"
      map_data.tile_size = opts[:tile_size]
      
      @level = FakeLevel.new
      @level.map = self.create_actor :map, map_data: map_data
      @level.map_extents = [0,0, map_data.tile_grid[0].size * map_data.tile_size, map_data.tile_grid.size * map_data.tile_size]
      LevelLoader.load_objects self, tmx_map, @level

      setup_players opts[:player_count]
      rescue Exception => ex
        binding.pry
      end

    end

    game
  end

  def body_vector(body)
    vec2(body.x,body.y)
  end

  def get_test_map(name)
    require 'tmx'
    Tmx::Map.new("#{APP_ROOT}/spec/fixtures/maps/#{name}.tmx")
  end
  module_function :get_test_map

  def jump(time_held)
    # charge & jump
    hold_key KbN, time_held, step: 20
  end

  def charge_and_throw_bomb(time_held)
    hold_key KbM, time_held, step: 20
  end

  def walk_left(time_held)
    hold_key KbA, time_held, step: 20
  end

  def walk_right(time_held)
    hold_key KbD, time_held, step: 20
  end

  def hold_key(key, time_held, opts={})
    press_key key
    update time_held, step: opts[:step]
    release_key key
  end

  def look_up
    tap_key KbW
  end

  def look_right
    tap_key KbD
  end

  def shields_up
    tap_key KbV
  end

  def shoot
    tap_key KbB
  end

  def tap_key(key)
    press_key key
    release_key key
  end

  def see_bottom_right_standing_above(y)
    foxy.collision_points[4].y.should == (y - 1).ish
  end

  def see_bottom_left_standing_above(y)
    foxy.collision_points[5].y.should == (y - 1).ish
  end
end

RSpec.configure do |config|
  config.mock_with :mocha
  config.include FoxyAcceptanceHelpers
end

class Numeric
  def ish(acceptable_delta=0.001)
    ApproximateValue.new self, acceptable_delta
  end
end

module Enumerable
  def ish(acceptable_delta=0.001)
    self.map { |item| ApproximateValue.new item, acceptable_delta }
  end
end

class ApproximateValue
  def initialize(me, acceptable_delta)
    @me = me
    @acceptable_delta = acceptable_delta
  end

  def ==(other)
    (other - @me).abs < @acceptable_delta
  end

  def to_s
    "within #{@acceptable_delta} of #{@me}"
  end
end

# class MockImage
#   def width; 26; end
#   def height; 30; end
# end

class FakeLevel
  attr_accessor :named_objects, :objects, :map, :map_extents
  def initialize
    @named_objects = {}
    @objects = []
    @object_groups
  end
end


