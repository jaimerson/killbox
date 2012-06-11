define_actor :foxy do
  has_attributes view: :graphical_actor_view
  has_behaviors do
    positioned
    layered ZOrder::Player
    animated
    input_mapper(
      KbLeft => :move_left,
      KbRight => :move_right,
      KbUp => :attempt_jump
    )
    friction amount: 0.99
    mover speed: 0.44, max_speed: 2
    bound_by_box
    tile_bound
    tile_collision_detector #(emits :tile_collided, data)
    #gravity dir: vec2(0,0.01)
  end

end

