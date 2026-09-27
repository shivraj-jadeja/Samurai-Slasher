// Completion depends on state, not mutable form sprite references.
if (is_dead) { image_index = image_number - 1; image_speed = 0; }
else if (attack_kind != 0) { attack_kind = 0; }
