require 'spec_helper'


describe "Killbox bombing", acceptance: true do
  let(:zones) { KillboxAcceptanceHelpers.get_test_map("shooting").object_groups.detect{|og|og.name == "zones"}.objects.inject({}) do |h,x| h[x.name] = x; h; end }
  let(:floor_zone) { zones["floor"] }
  let(:right_wall_zone) { zones["right_wall"] }

  let(:tile_size) { 36 }
  let(:map) { game.actor(:map) }
  let(:player) { game.actor(:player) }

  let(:player_w) { 32 }
  let(:player_h) { 60 }

  before do
    mock_tiles 'map/tileset.png', 256/16, 208/16
    mock_image 'boxy.png' # TODO: provide width and height as 2nd and third args
    mock_image 'bullet.png'
    mock_image 'bomb.png'

    configure_game_with_testing_stage  map_name: "shooting"

    # See player land standing where expected:
    update 2000, step: 20
    see_actor_attrs :player, 
      rotation: 0.ish,
      on_ground: true
    see_bottom_right_standing_above floor_zone.y
    see_bottom_left_standing_above floor_zone.y
  end

  it 'can place and arm a land mine' do
    place_land_mine

    game.actors(:bomb).should be_empty

    see_actor_attrs :land_mine,
      armed: false,
      x: player.x.ish,
      y: (floor_zone.y - 1).ish

    # warp to safety
    player.x += 300

    # wait for land mine to arm
    update 3000, step: 20

    see_actor_attrs :land_mine,
      armed: true
  end

  it 'blows up via player proximity' do
    place_land_mine
    player.x += 300

    # wait for land mine to arm
    update 3000, step: 20

    see_actor_attrs :land_mine,
      armed: true

    # make sure it doesn't blow up on its own
    update 10_000, step: 20
    see_actor_attrs :land_mine,
      armed: true

    player.x -= 300
    # wait for death delay
    update 1000, step: 20

    game.actors(:land_mine).should be_empty
    player.should_not be_alive
  end

  it 'can be shot' do
    place_land_mine
    jump 1000
    update 4000

    look_up
    shoot

    update 4000, step: 20

    game.actors(:land_mine).should be_empty
  end
end

