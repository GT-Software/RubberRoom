extends Node
## The Finite State Machine

# boolean variables
var is_idle     = false
var is_walking  = false
var is_running  = false
var locked_on   = false
var is_crouched = false
var is_in_combat= false
var can_jump    = false
var in_light_combo= false
var in_heavy_combo= false
var got_hit_light = false
var got_hit_heavy = false
var hitbox_active = false

# Combo System Variables
var buffer_open = false


var is_attacking = false
var can_fire = true
var is_reloading = false
var is_aiming = false

var is_dodging = false
var dodging_on_cooldown = false
var cannot_take_damage = false
var take_chip_damage = false

## Buffer to prevent the player from attacking again after being hit (Punishment)
var is_hitstunned = false

var is_in_range = true
