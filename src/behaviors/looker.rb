define_behavior :looker do
  requires :director

  setup do
    # in pixels
    actor.has_attributes look_distance: 100,
                         flip_h: false, 
                         look_vector: look_directions[:left]

    input = actor.input
    input.when(:look_left) { actor.flip_h = true }
    input.when(:look_right) { actor.flip_h = false }

    director.when :update do |t_ms, time_in_sec|
      if actor.do_or_do_not :viewport
        update_look_point time_in_sec
      end
    end

    reacts_with :remove
  end


  helpers do
    include MinMaxHelpers

    def remove
      actor.input.unsubscribe_all self
      director.unsubscribe_all self
    end

    def look_directions 
      {
      left: vec2(-1,0),
      right: vec2(1,0),
      up: vec2(0,-1),
      down: vec2(0,1)
      }
    end

    def update_look_point(time_secs)
      input = actor.input

      look_vector = if input.look_left?
        look_directions[:left]
      elsif input.look_right?
        look_directions[:right]
      elsif input.look_up?
        look_directions[:up]
      elsif input.look_down?
        look_directions[:down]
      end

      viewport = actor.viewport
      current_vec = vec2(viewport.follow_offset_x, viewport.follow_offset_y)
      if look_vector 
        actor.look_vector = look_vector
        rot = actor.do_or_do_not(:rotation) || 0
        offset_vec = current_vec - look_vector.rotate_deg(rot) * actor.look_distance * time_secs

        offset_vec.magnitude = actor.look_distance if offset_vec.magnitude > actor.look_distance

        viewport.follow_offset_x = offset_vec.x
        viewport.follow_offset_y = offset_vec.y
      end

    end

  end
end
