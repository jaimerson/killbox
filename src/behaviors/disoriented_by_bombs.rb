define_behavior :disoriented_by_bombs do
  requires :director

  setup do
    actor.has_attributes shake_intensity: 100,
                         disoriented_amount: 0

    director.when :update do |t_ms, time_in_sec|
      update_shake(time_in_sec) if actor.disoriented_amount > 0
    end

    reacts_with :disoriented
  end

  remove do
    actor.controller.unsubscribe_all self
    director.unsubscribe_all self
  end

  helpers do

    def disoriented(bomb, distance)
      potential = (bomb.radius * 4.0)
      actor.disoriented_amount = (potential - distance) / potential * actor.shake_intensity
    end

    def update_shake(time_secs)
      viewport = actor.viewport
      viewport.x_offset += rand(actor.disoriented_amount) - (actor.disoriented_amount / 2) * time_secs
      viewport.y_offset += rand(actor.disoriented_amount) - (actor.disoriented_amount / 2) * time_secs
      actor.disoriented_amount -= time_secs * 350
    end

  end
end
