; Globals
(global short player_1_count -1)
(global short player_2_count -1)
(global short player_3_count -1)
(global long player_1_anim -1)
(global long player_2_anim -1)
(global long player_3_anim -1)
(global short player_1_index -1)
(global short player_2_index -1)
(global short player_3_index -1)

; Externs
(script extern long (pdm_get_player_animation_count (short idx)))
(script extern animationgraph (pdm_get_player_animation_tag (short idx)))
(script extern stringid (pdm_get_player_animation_str (short type) (short idx) (long anim)))
(script extern real (pdm_get_animation_offset (short idx) (long anim)))
(script extern anytag (pdm_get_animation_weapon (short idx) (long anim) (boolean primary)))
(script extern void (pdm_show_ui_place (short place) (short idx)))
(script extern void (pdm_respawn_player_offset (short idx) (cutscenecamerapoint camera) (real dis) (real hor) (real vert) (real yaw) (real pitch)))
(script extern void (pdm_event (string event)))
(script extern short player_get_local_idx)
(script extern short (player_get_idx_by_place (short place)))
(script extern void (hide_all_players (boolean hidden)))
(script extern void (delete_all_objects (boolean delete_modifiers)))
(script extern void (give_unit_weapon (unit player) (anytag primary) (anytag secondary)))
(script extern object (player_get_by_idx (short idx)))
(script extern short lobby_size)
(script extern effect (pdm_get_respawn_effect (short place)))
(script extern real (pdm_get_biped_offset (string field_type) (short place)))
(script extern long (pdm_get_biped_spawn_delay (short place)))
(script extern long pdm_get_tick_delay)
(script extern boolean pdm_has_forge_object)
(script extern void respawn_map_objects)
(script extern void mp_hide_scoreboard)
(script extern void player_reset_sprint)
(script extern void (pdm_forge_override_allowed (boolean allowed)))
(script extern void (mp_sync_global (string global)))

; Scripts
(script static void podium_init
	(pdm_forge_override_allowed true)
	(pdm_event "podium_init")
)

(script static void podium
	(set player_1_index (player_get_idx_by_place 1))
	(set player_2_index (player_get_idx_by_place 2))
	(set player_3_index (player_get_idx_by_place 3))
	(mp_sync_global player_1_index)
	(mp_sync_global player_2_index)
	(mp_sync_global player_3_index)
	(set player_1_count (pdm_get_player_animation_count player_1_index))
	(set player_2_count (pdm_get_player_animation_count player_2_index))
	(set player_3_count (pdm_get_player_animation_count player_3_index))
	(set player_1_anim (random_range 0 player_1_count))
	(set player_2_anim (random_range 0 player_2_count))
	(set player_3_anim (random_range 0 player_3_count))
	(mp_sync_global player_1_anim)
	(mp_sync_global player_2_anim)
	(mp_sync_global player_3_anim)
	(if (>= (lobby_size) 3)
		(game_finished_wait_time_add 2)
	)
	(if (>= (lobby_size) 2)
		(game_finished_wait_time_add 2)
	)
	(if (>= (lobby_size) 1)
		(game_finished_wait_time_add 18)
	)
	(sleep 100)
	(wake prepare_players)
	(sleep 11)
	(mp_wake_script podium_start)
)

(script dormant void prepare_players
	(mp_wake_script fade_out_players)
	(sleep 1)
	(if (pdm_has_forge_object)
		(respawn_map_objects)
		(delete_all_objects true)
	)
	(sleep 5)
	(pdm_respawn_player_offset player_1_index "podium_camera" (- (pdm_get_biped_offset "x" 0) (pdm_get_animation_offset player_1_index player_1_anim)) (pdm_get_biped_offset "y" 0) (pdm_get_biped_offset "z" 0) (pdm_get_biped_offset "i" 0) 90)
	(pdm_respawn_player_offset player_2_index "podium_camera" (- (pdm_get_biped_offset "x" 1) (pdm_get_animation_offset player_2_index player_2_anim)) (pdm_get_biped_offset "y" 1) (pdm_get_biped_offset "z" 1) (pdm_get_biped_offset "i" 1) 90)
	(pdm_respawn_player_offset player_3_index "podium_camera" (- (pdm_get_biped_offset "x" 2) (pdm_get_animation_offset player_3_index player_3_anim)) (pdm_get_biped_offset "y" 2) (pdm_get_biped_offset "z" 2) (pdm_get_biped_offset "i" 2) 90)
	(sleep 5)
	(give_unit_weapon (unit (player_get_by_idx player_1_index)) (pdm_get_animation_weapon player_1_index player_1_anim true) (pdm_get_animation_weapon player_1_index player_1_anim false))
	(give_unit_weapon (unit (player_get_by_idx player_2_index)) (pdm_get_animation_weapon player_2_index player_2_anim true) (pdm_get_animation_weapon player_2_index player_2_anim false))
	(give_unit_weapon (unit (player_get_by_idx player_3_index)) (pdm_get_animation_weapon player_3_index player_3_anim true) (pdm_get_animation_weapon player_3_index player_3_anim false))
	(mp_wake_script hide_players)
)

(script dormant void fade_out_players
	(mp_hide_scoreboard)
	(fade_out 0 0 0 0)
	(chud_cinematic_fade 0 0)
	(chud_show_messages false)
	(sound_class_set_gain "ui" 0 0)
	(player_enable_input false)
	(player_disable_movement true)
	(player_camera_control false)
	(player_reset_sprint)
	(pdm_event "podium_start")
)

(script dormant void hide_players
	(hide_all_players true)
)

(script dormant void podium_start
	(print "Podium Started")
	(sound_class_set_gain "ui" 1 0)
	(sleep 1)
	(camera_control true)
	(camera_set "podium_camera" 0)
	(fade_in 0 0 0 40)
	(sleep (pdm_get_tick_delay))
	(if (>= (lobby_size) 3)
		(begin
			(sleep (pdm_get_biped_spawn_delay 2))
			(wake player_third)
			(sleep (pdm_get_biped_spawn_delay 1))
		)
	)
	(if (>= (lobby_size) 2)
		(begin
			(wake player_second)
			(sleep (pdm_get_biped_spawn_delay 0))
		)
	)
	(if (>= (lobby_size) 1)
		(begin
			(wake player_first)
		)
	)
	(sleep 300)
	(pdm_show_ui_place -1 -1)
	(sleep 25)
	(sound_impulse_start "sound\ui\scoreboard\appear_whoosh" "none" 1)
	(sleep_forever)
)

(script dormant void player_third
	(sleep 1)
	(biped_force_ground_fitting_on (unit (player_get_by_idx player_3_index)) true)
	(custom_animation (unit (player_get_by_idx player_3_index)) (pdm_get_player_animation_tag player_3_index) (pdm_get_player_animation_str 0 player_3_index player_3_anim) false)
	(effect_new_on_object_marker (pdm_get_respawn_effect 2) (player_get_by_idx player_3_index) "body")
	(sleep 2)
	(pdm_show_ui_place 3 -1)
	(sound_impulse_start "sound\podium\third_place" "none" 1)
	(object_hide (player_get_by_idx player_3_index) false)
	(sleep_until (begin
		(sleep (unit_get_custom_animation_time (unit (player_get_by_idx player_3_index))))
		(custom_animation_loop (unit (player_get_by_idx player_3_index)) (pdm_get_player_animation_tag player_3_index) (pdm_get_player_animation_str 1 player_3_index player_3_anim) true)
		(sleep 1)
	)
	 -1)
	(sleep_forever)
)

(script dormant void player_second
	(sleep 1)
	(biped_force_ground_fitting_on (unit (player_get_by_idx player_2_index)) true)
	(custom_animation (unit (player_get_by_idx player_2_index)) (pdm_get_player_animation_tag player_2_index) (pdm_get_player_animation_str 0 player_2_index player_2_anim) false)
	(effect_new_on_object_marker (pdm_get_respawn_effect 1) (player_get_by_idx player_2_index) "body")
	(sleep 2)
	(pdm_show_ui_place 2 -1)
	(sound_impulse_start "sound\podium\second_place" "none" 1)
	(object_hide (player_get_by_idx player_2_index) false)
	(sleep_until (begin
		(sleep (unit_get_custom_animation_time (unit (player_get_by_idx player_2_index))))
		(custom_animation_loop (unit (player_get_by_idx player_2_index)) (pdm_get_player_animation_tag player_2_index) (pdm_get_player_animation_str 1 player_2_index player_2_anim) true)
		(sleep 1)
	)
	 -1)
	(sleep_forever)
)

(script dormant void player_first
	(sleep 1)
	(biped_force_ground_fitting_on (unit (player_get_by_idx player_1_index)) true)
	(custom_animation (unit (player_get_by_idx player_1_index)) (pdm_get_player_animation_tag player_1_index) (pdm_get_player_animation_str 0 player_1_index player_1_anim) false)
	(effect_new_on_object_marker (pdm_get_respawn_effect 0) (player_get_by_idx player_1_index) "body")
	(sleep 2)
	(pdm_show_ui_place 1 player_1_index)
	(sound_impulse_start "sound\podium\first_place" "none" 1)
	(object_hide (player_get_by_idx player_1_index) false)
	(sleep_until (begin
		(sleep (unit_get_custom_animation_time (unit (player_get_by_idx player_1_index))))
		(custom_animation_loop (unit (player_get_by_idx player_1_index)) (pdm_get_player_animation_tag player_1_index) (pdm_get_player_animation_str 1 player_1_index player_1_anim) true)
		(sleep 1)
	)
	 -1)
	(sleep_forever)
)