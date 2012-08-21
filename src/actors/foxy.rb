define_actor :foxy do

  has_behaviors do
    positioned
    audible
    layered ZOrder::Player
    animated_with_spritemap file: 'foxy.png', rows: 9, cols: 3, actions: {
      idle:         2,
      walking_right:21..23,
      walking_left: 21..23,
      jumping:      6..7,
      falling:      8,
      hurt:         9..11,
      knocked_down: 24..26,
    }
    input_mapper(
      [GpLeft, KbLeft] => :move_left,
      [GpRight, KbRight] => :move_right,
      [GpButton1, KbUp] => :charging_jump
    )
    grounded

    accelerator air_speed: 30, speed: 40, max_speed: 18 
    shooter recharge_time: 1000, shot_power: 1, kickback: 1
    jump power: 200
    friction amount: 0.04

    foxy_collision_points

    bound_by_box

    tile_oriented
    tile_collision_detector
  end

  view do
    draw do |target, x_off, y_off, z|
      img = actor.image
      return if img.nil?

      x = actor.x
      y = actor.y

      offset_x = x+x_off
      offset_y = y+y_off
      x_scale = 1
      
      if actor.flip_h
        x_scale = -1
      end

      if actor.can_shoot?
        gun = actor.gun_direction.dup
        gun.m = 20
        gun = gun.rotate(degrees_to_radians(actor.rotation)) + vec2(offset_x, offset_y)
        target.fill gun.x, gun.y, gun.x+2, gun.y+2, Color::WHITE, ZOrder::PlayerDecoration
      end

      rot = normalize_angle(actor.rotation)
      target.draw_rotated_image img, offset_x, offset_y, z, rot, 0.5, 0.5, x_scale
      target.draw_box offset_x-img.width/2.0, offset_y-img.height/2.0, offset_x+img.width/2.0, offset_y+img.height/2.0, Color::GREEN, ZOrder::Debug
      if actor.ground_normal
        target.draw_line offset_x, offset_y, offset_x+actor.ground_normal.x*40, offset_y+actor.ground_normal.y*40, Color::BLUE, ZOrder::Debug
      end
    end

  end
end
