local mod = get_mod("Onslaught")

-- thank you kuli
-- firewatch

-- TWINS: Lower health damage cap per hit
local breed_renegade_twin_captain = require("scripts/settings/breed/breeds/renegade/renegade_twin_captain_breed")
local breed_renegade_twin_captain_two = require("scripts/settings/breed/breeds/renegade/renegade_twin_captain_two_breed")

breed_renegade_twin_captain.clamp_health_percent_damage = 0.1 -- 0.2
breed_renegade_twin_captain_two.clamp_health_percent_damage = 0.1 -- 0.2

-- TOX BOMBER GAS & BEAST OF NURGLE SLIME: Lower duration
mod:hook_require("scripts/settings/liquid_area/liquid_area_templates/minion_liquid_area_templates", function(templates)
    templates.cultist_grenadier_gas.life_time = 8 -- 16
    templates.beast_of_nurgle_slime.life_time = 10 -- 20
end)

-- BEAST OF NURGLE SLIME: Remove ground texture with liquid area (host & clients)
local function destroy_slime_particles(func, self, ...)
	if self._area_template_name == "beast_of_nurgle_slime" then
		for _, liquid in pairs(self._flow) do
			local particle_id = liquid.particle_id or liquid.filled_particle_id

			if particle_id and World.are_particles_playing(self._world, particle_id) then
				World.destroy_particles(self._world, particle_id)
			end

			liquid.particle_id, liquid.filled_particle_id = nil, nil
		end
	end

	return func(self, ...)
end

mod:hook_require("scripts/extension_systems/liquid_area/liquid_area_extension", function(LiquidAreaExtension)
	mod:hook(LiquidAreaExtension, "destroy", destroy_slime_particles)
end)

mod:hook_require("scripts/extension_systems/liquid_area/husk_liquid_area_extension", function(HuskLiquidAreaExtension)
	mod:hook(HuskLiquidAreaExtension, "destroy", destroy_slime_particles)
end)

-- MINION DAMAGE PROFILE EDITOR
local ArmorSettings = require("scripts/settings/damage/armor_settings")
local Attack = require("scripts/utilities/attack/attack")
local BreedActions = require("scripts/settings/breed/breed_actions")
local BreedSettings = require("scripts/settings/breed/breed_settings")
local DamageProfileSettings = require("scripts/settings/damage/damage_profile_settings")
local DamageProfileTemplates = require("scripts/settings/damage/damage_profile_templates")
local MinionAttack = require("scripts/utilities/minion_attack")
local MinionDifficultySettings = require("scripts/settings/difficulty/minion_difficulty_settings")
local MinionPushFx = require("scripts/utilities/minion_push_fx")
local PowerLevelSettings = require("scripts/settings/damage/power_level_settings")
local PushSettings = require("scripts/settings/damage/push_settings")

local armor_types = ArmorSettings.types
local push_templates = PushSettings.push_templates

--[[
Damage Profile Editor:

	profiles.add(name, profile_table)
		New damage profile written from scratch.

	profiles.copy(new_name, source_name, edit)
		New damage profile that starts as a deep copy of an existing one. 'edit' is optional.

	profiles.modify(name_or_list_of_names, edit)
		Change existing damage profile(s).

'edit' is either
	a table:    only the listed fields change, everything else is kept. Nested tables are merged, so
	            { power_distribution = { attack = 5 } } leaves power_distribution.impact alone.
	            Two markers can be used as values inside that table:
	              REMOVE            deletes the field:                  unblockable = REMOVE
	              replace(value)    swaps the whole value, no merging:  push_template = replace(push_templates.light)
	            Use replace() when assigning a template table (push_template, catapulting_template, ...), otherwise the
	            new table is merged into the old one instead of replacing it.
	a function: receives the damage profile and edits it in place (or returns a new table to use instead):
	            function(profile) profile.power_distribution.attack = profile.power_distribution.attack * 2 end
]]

local REMOVE = {}
local REPLACE_TAG = {}

local function replace(value)
	return setmetatable({ value = value }, REPLACE_TAG)
end

local function merge(target, changes)
	for key, value in pairs(changes) do
		if value == REMOVE then
			target[key] = nil
		elseif type(value) == "table" and getmetatable(value) == REPLACE_TAG then
			target[key] = value.value
		elseif type(value) == "table" and type(target[key]) == "table" then
			merge(target[key], value)
		else
			target[key] = value
		end
	end
end

local function apply_edit(profile, edit)
	if type(edit) == "function" then
		local result = edit(profile)

		if result ~= nil then
			return result
		end
	elseif type(edit) == "table" then
		merge(profile, edit)
	end

	return profile
end

local function overwrite(live, profile)
	for key in pairs(live) do
		live[key] = nil
	end

	for key, value in pairs(profile) do
		live[key] = value
	end
end

local function create_editor(templates)
	local base_templates = templates.base_templates
	local overrides = templates.overrides
	local already_merged = false

	for name, profile in upairs(base_templates) do
		already_merged = profile.name == name

		break
	end

	local DamageProfileTemplates

	if already_merged then
		DamageProfileTemplates = require("scripts/settings/damage/damage_profile_templates")
	end

	if mod.info then
		mod:info("Damage profile editor: %s", already_merged and "profiles were already merged, editing DamageProfileTemplates directly" or "editing before the merge")
	end

	local function exists(name)
		if already_merged then
			return DamageProfileTemplates[name] ~= nil
		end

		return base_templates[name] ~= nil or overrides[name] ~= nil
	end

	local function build_variant(name)
		local variant = overrides[name]
		local profile = table.clone(base_templates[variant.parent_template_name])

		for _, path in ipairs(variant.overrides) do
			local entry = profile
			local last_key_index = #path - 1

			for i = 1, last_key_index - 1 do
				entry = entry[path[i]]
			end

			entry[path[last_key_index]] = path[#path]
		end

		return profile
	end

	local function copy_of(name)
		if already_merged then
			local profile = DamageProfileTemplates[name]

			return profile ~= nil and table.clone(profile) or nil
		end

		local profile = base_templates[name]

		if profile ~= nil then
			return table.clone(profile)
		end

		if overrides[name] ~= nil then
			return build_variant(name)
		end

		return nil
	end

	local function live_profile(name)
		if already_merged then
			return DamageProfileTemplates[name]
		end

		local profile = base_templates[name]

		if profile == nil and overrides[name] ~= nil then
			profile = build_variant(name)
			base_templates[name] = profile
			overrides[name] = nil
		end

		return profile
	end

	local function detach_variants(parent_name)
		local variant_names = {}

		for name, variant in upairs(overrides) do
			if variant.parent_template_name == parent_name then
				variant_names[#variant_names + 1] = name
			end
		end

		for _, name in ipairs(variant_names) do
			base_templates[name] = build_variant(name)
			overrides[name] = nil
		end
	end

	-- Register to NetworkLookup
	local function register_network_id(name)
		local lookup = require("scripts/network_lookup/network_lookup").damage_profile_templates

		if rawget(lookup, name) == nil then
			local id = #lookup + 1

			lookup[id] = name
			lookup[name] = id
		end
	end

	local function publish(name, profile)
		if already_merged then
			profile.name = name
			DamageProfileTemplates[name] = profile

			register_network_id(name)
		else
			base_templates[name] = profile
		end
	end

	local editor = {}

	function editor.add(name, profile)
		if type(profile) ~= "table" then
			mod:error("profiles.add(%s): profile must be a table", tostring(name))

			return
		end

		if exists(name) then
			mod:error("profiles.add(%s): a damage profile with this name already exists", tostring(name))

			return
		end

		publish(name, profile)
	end

	function editor.copy(new_name, source_name, edit)
		if exists(new_name) then
			mod:error("profiles.copy(%s): a damage profile with this name already exists", tostring(new_name))

			return
		end

		local profile = copy_of(source_name)

		if profile == nil then
			mod:error("profiles.copy(%s): source damage profile '%s' not found", tostring(new_name), tostring(source_name))

			return
		end

		publish(new_name, apply_edit(profile, edit))
	end

	local function modify_one(name, edit)
		local live = live_profile(name)

		if live == nil then
			mod:error("profiles.modify: damage profile '%s' not found", tostring(name))

			return
		end

		if not already_merged then
			detach_variants(name)
		end

		overwrite(live, apply_edit(table.clone(live), edit))

		if already_merged then
			live.name = name
		end
	end

	function editor.modify(names, edit)
		if type(names) == "table" then
			for _, name in ipairs(names) do
				modify_one(name, edit)
			end
		else
			modify_one(names, edit)
		end
	end

	return editor
end

-- MINION DAMAGE PROFILES CHANGES
mod:hook_require("scripts/settings/damage/damage_profiles/minion_damage_profile_templates", function(templates)
	local profiles = create_editor(templates)

	-- CHAOS SPAWN: CHEW
	profiles.add("chaos_spawn_eat", {
		ignore_toughness = true,
		permanent_damage_ratio = 0.5, -- 1
		stagger_category = "melee",
		armor_damage_modifier = {
			attack = {
				[armor_types.unarmored] = 0,
				[armor_types.armored] = 0,
				[armor_types.resistant] = 0,
				[armor_types.player] = 0.08,
				[armor_types.berserker] = 0,
				[armor_types.super_armor] = 0,
				[armor_types.disgustingly_resilient] = 0,
				[armor_types.void_shield] = 0,
			},
			impact = {
				[armor_types.unarmored] = 0,
				[armor_types.armored] = 0,
				[armor_types.resistant] = 0,
				[armor_types.player] = 0.1,
				[armor_types.berserker] = 0,
				[armor_types.super_armor] = 0,
				[armor_types.disgustingly_resilient] = 0,
				[armor_types.void_shield] = 0,
			},
		},
		power_distribution = {
			attack = 350, -- 1
			impact = 0,
		},
		cleave_distribution = {
			attack = 1,
			impact = 0,
		},
		targets = {
			default_target = {
				boost_curve = PowerLevelSettings.boost_curves.default,
			},
		},
		push_template = push_templates.medium,
		ogryn_push_template = push_templates.medium,
	})
	-- CHAOS SPAWN: 1H COMBO
	profiles.modify("chaos_spawn_combo", {
		block_cost_multiplier = 1.75, -- 1.25
		power_distribution = { attack = 40 }, -- 30
	})
	-- CHAOS SPAWN: 2H COMBO
	profiles.modify("chaos_spawn_combo_heavy", {
		block_cost_multiplier = 2.35, -- 1.85
		power_distribution = { attack = 45 }, -- 35
	})
	-- CHAOS SPAWN: OVERHEAD CLAW
	profiles.modify("chaos_spawn_claw", {
		block_cost_multiplier = REMOVE,
		unblockable = true,
		power_distribution = { attack = 80 }, -- 60
	})
	-- CAPTAIN VOID SHIELD EXPLOSION
	profiles.modify("renegade_captain_void_shield_explosion", {
		power_distribution = { attack = 0 }, -- 0.2
	})
	-- MUTANT: SMASH
	profiles.modify("cultist_mutant_smash", {
		power_distribution = { attack = 0.075 }, -- 0.1
		toughness_multiplier = 4, -- 2
	})
	-- DOGS: POUNCED DAMAGE
	profiles.modify("chaos_hound_pounce", {
		power_distribution = { attack = 60 }, -- 40
		permanent_damage_ratio = 0.25, -- 0.98
	})
	-- POXBURSTER: EXPLOSION
	profiles.modify("poxwalker_explosion", {
		targets = {
			default_target = {
				power_distribution_ranged = {
					attack = {
						far = 50, -- 25
						near = 125,
					}
				}
			}
		}
	})

	-- EXAMPLES
	--[[
	MODIFY WITH A TABLE: only these fields change
	profiles.modify("beast_of_nurgle_tail_whip", {
		toughness_multiplier = 10, -- 20
	 	power_distribution = { attack = 0.4 }, -- 0.2 (impact stays 0.5)
	 	armor_damage_modifier = { attack = { [armor_types.armored] = 0.5 } }, -- only this armor type; safe even though the vanilla table is shared
	 	unblockable = REMOVE, -- true
	 	push_template = replace(push_templates.light), -- push_templates.medium
	})

	MODIFY WITH A FUNCTION: for anything computed from the current value
	profiles.modify("beast_of_nurgle_tail_whip", function(profile)
	 	profile.power_distribution.attack = profile.power_distribution.attack * 2
	end)

	MODIFY SEVERAL DAMAGE PROFILES THE SAME WAY
	profiles.modify({ "chaos_spawn_eat", "beast_of_nurgle_hit_by_vomit" }, { toughness_multiplier = 5 })

	COPY AN EXISTING DAMAGE PROFILE AND TWEAK IT
	profiles.copy("chaos_spawn_eat_strong", "beast_of_nurgle_hit_by_vomit", {
	 	power_distribution = { attack = 2 }, -- 1
	})

	VARIANTS (defined through overrides in the game): renegade_rifleman is default_rifleman and no changes.
	Only named damage profiles change, so to change a parent and its variants list them all:
	profiles.modify({ "default_rifleman", "renegade_rifleman", "renegade_rifleman_single_shot" }, { power_distribution = { attack = 20 } }) -- 24
	]]
end)

-- CHAOS SPAWN GRAB: Increased chew damage, self-heal, added unique eat damage profile
BreedActions.chaos_spawn.grab.power_level[5] = 900 -- 450
BreedActions.chaos_spawn.grab.heal_amount[5] = 10000 -- 1000
BreedActions.chaos_spawn.grab.eat_damage_profile = DamageProfileTemplates.chaos_spawn_eat -- DamageProfileTemplates.beast_of_nurgle_hit_by_vomit

-- Toughness break helper
local BtVoidShieldExplosionAction = require("scripts/extension_systems/behavior/nodes/actions/bt_void_shield_explosion_action")

BtVoidShieldExplosionAction._break_toughness = function (self, hit_unit)
	local toughness_extension = ScriptUnit.has_extension(hit_unit, "toughness_system")

	if toughness_extension and toughness_extension:current_toughness_percent() > 0 then
		toughness_extension:break_toughness()
	end
end

-- CAPTAIN VOID SHIELD EXPLOSION: Add toughness break to action
mod:hook(BtVoidShieldExplosionAction, "_deal_damage", function (func, self, t, unit, action_data)
	local broadphase_system = Managers.state.extension:system("broadphase_system")
	local broadphase = broadphase_system.broadphase
	local side_system = Managers.state.extension:system("side_system")
	local side = side_system.side_by_unit[unit]
	local relation = action_data.relation or "enemy"
	local target_side_names = side:relation_side_names(relation)
	local damage_profile = action_data.damage_profile
	local power_level = action_data.power_level
	local hit_zone_name = action_data.hit_zone_name
	local damage_type = action_data.damage_type
	local from = POSITION_LOOKUP[unit]
	local broadphase_radius = action_data.radius
	local broadphase_results = Managers.frame_table:get_table()
	local num_results = broadphase.query(broadphase, from, broadphase_radius, broadphase_results, target_side_names)

	for i = 1, num_results do
		local hit_unit = broadphase_results[i]

		if hit_unit ~= unit then
			local to = POSITION_LOOKUP[hit_unit]
			local direction = Vector3.normalize(to - from)

			Attack.execute(hit_unit, damage_profile, "power_level", power_level, "attacking_unit", unit, "attack_direction", direction, "hit_zone_name", hit_zone_name, "damage_type", damage_type)
			self:_break_toughness(hit_unit)

			local fx_extension = ScriptUnit.has_extension(hit_unit, "fx_system")

			if fx_extension and fx_extension.spawn_particles then
				local hit_effect = action_data.hit_effect
				local position = Vector3(0, 0, 1)

				fx_extension:spawn_particles(hit_effect, position)
			end
		end
	end
end)

-- CAPTAINS: Spawn with both powersword and powermaul, allow to switch melee weapons mid-fight
local function select_both_melee_weapons(templates, names)
	for _, name in ipairs(names) do
		local template = templates[name]

		if template and template.amount_from_category.melee then
			template.amount_from_category.melee = 2 -- 1
		end
	end
end

mod:hook_require("scripts/settings/minion_attack_selection/templates/renegade_captain_attack_selection_templates", function(templates)
	select_both_melee_weapons(templates, { "renegade_captain_default", "renegade_captain_melee", "renegade_captain_plasma_pistol" })
end)

mod:hook_require("scripts/settings/minion_attack_selection/templates/cultist_captain_attack_selection_templates", function(templates)
	local melee = templates.cultist_captain_default.categories.melee
	local has_power_sword = false

	for _, entry in ipairs(melee) do
		if entry.required_weapon_slot_name == "slot_power_sword" then
			has_power_sword = true
			break
		end
	end

	if not has_power_sword then
		table.insert(melee, 1, {
			required_weapon_slot_name = "slot_power_sword",
			attack_names = { "power_sword_melee_combo_attack" },
		})
	end

	templates.cultist_captain_all.amount_from_category.melee = 2
	select_both_melee_weapons(templates, { "cultist_captain_default", "cultist_captain_melee" })
end)

-- Fix broken sword kick combo for cultist captain
local RenegadeCaptainActions = require("scripts/settings/breed/breed_actions/renegade/renegade_captain_actions")

mod:hook_require("scripts/settings/breed/breed_actions/cultist/cultist_captain_actions", function(action_data)
	action_data.power_sword_melee_combo_attack = table.clone(RenegadeCaptainActions.power_sword_melee_combo_attack)
end)

-- Duration until weapon switch
mod:hook_require("scripts/settings/phases/templates/renegade_captain_phase_templates", function(templates)
	local melee_phases = templates.renegade_captain_default.melee.phases

	melee_phases.melee_power_sword.duration = { 9, 14 }
	melee_phases.melee_powermaul.duration = { 9, 14 }
end)

-- Block weapon switch mid-attack
local CAPTAIN_BREEDS = {
	renegade_captain = true,
	cultist_captain = true,
}
local PHASE_SWITCH_BLOCKING_ACTIONS = {
	power_sword_melee_attack = true,
	power_sword_melee_combo_attack = true,
	power_sword_melee_sweep = true,
	power_sword_moving_melee_attack = true,
	powermaul_ground_slam = true,
	powermaul_melee_attack = true,
	powermaul_melee_cleave = true,
	powermaul_moving_melee_cleave = true,
	powermaul_pommel = true,
	kick = true,
	punch = true,
}

mod:hook_require("scripts/extension_systems/behavior/combat_range_user_behavior_extension", function(CombatRangeUserBehaviorExtension)
	mod:hook(CombatRangeUserBehaviorExtension, "update_minion_phase", function(func, self, unit, blackboard, dt, t)
		if CAPTAIN_BREEDS[self._breed.name] then
			if self._force_phase_update then
				self._force_phase_update = nil
			else
				local action_name = self:running_action()

				if action_name and PHASE_SWITCH_BLOCKING_ACTIONS[action_name] then
					return
				end
			end

			local range_data = self._phase_template[self._behavior_component.combat_range]

			if not (range_data and range_data.phases[self._phase_component.wanted_phase]) then
				return
			end
		end

		return func(self, unit, blackboard, dt, t)
	end)

	mod:hook_safe(CombatRangeUserBehaviorExtension, "_switch_combat_range", function(self, unit, blackboard, config, weapon_switch_component)
		if CAPTAIN_BREEDS[self._breed.name] and not config.switch_weapon_slot then
			weapon_switch_component.wanted_combat_range = config.switch_combat_range
		end
	end)
end)

mod:hook_require("scripts/extension_systems/behavior/nodes/actions/bt_melee_attack_action", function(BtMeleeAttackAction)
	mod:hook_safe(BtMeleeAttackAction, "leave", function(self, unit, breed, blackboard, scratchpad, action_data, t, reason, destroy)
		if destroy or not CAPTAIN_BREEDS[breed.name] then
			return
		end

		local behavior_extension = ScriptUnit.has_extension(unit, "behavior_system")

		if behavior_extension and behavior_extension.update_minion_phase then
			behavior_extension._force_phase_update = true
			behavior_extension:update_minion_phase(unit, blackboard, 0, t)
			behavior_extension._force_phase_update = nil
		end
	end)
end)

-- CAPTAINS: Enable grenade throw action (renegade = frag; cultist = fire)
local GRENADE_COOLDOWN = 12

local function find_bt_node(node, name)
	if node.name == name then
		return node
	end

	for i = 1, #node do
		local child = node[i]

		if type(child) == "table" then
			local found = find_bt_node(child, name)

			if found then
				return found
			end
		end
	end
end

local function setup_captain_grenade(action)
	local considerations = table.clone(action.considerations)

	considerations.is_available = nil -- always allowed
	considerations.last_done_time.max_value = GRENADE_COOLDOWN * 2 -- results in our wanted minimum time

	action.considerations = considerations

	-- Fix throw_timing crash
	if not action.throw_timing then
		action.throw_timing = table.clone(action.aim_duration or { throw_grenade = 1.2916666666666667 })
	end
end

-- RENEGADE CAPTAIN: swap the fire grenade node for frag grenade node
mod:hook_require("scripts/extension_systems/behavior/trees/renegade/renegade_captain_behavior_tree", function(tree)
	local specials = find_bt_node(tree, "renegade_captain_specials")
	local actions = BreedActions.renegade_captain

	for i = 1, #specials do
		local child = specials[i]

		if type(child) == "table" and child.name == "throw_fire_grenade" then
			specials[i] = {
				"BtQuickGrenadeThrowAction",
				name = "throw_frag_grenade",
				action_data = actions.throw_frag_grenade,
				enter_hook = child.enter_hook,
				leave_hook = child.leave_hook,
			}

			break
		end
	end

	setup_captain_grenade(actions.throw_frag_grenade)
end)

-- CULTIST CAPTAIN: Make fire grenade always available
mod:hook_require("scripts/extension_systems/behavior/trees/cultist/cultist_captain_behavior_tree", function(tree)
	setup_captain_grenade(BreedActions.cultist_captain.throw_fire_grenade)
end)

-- CULTIST CAPTAIN:: Give fire grenade fuse on impact to make the fuse sound play
mod:hook_require("scripts/settings/projectile/minion_projectile_templates", function(templates)
	local fuse = templates.renegade_captain_fire_grenade.damage.fuse

	fuse.impact_triggered = true -- nil
	fuse.fuse_time = 1.2 -- 2
end)

-- BEAST OF NURGLE: Only consume targets with 3 vomit stacks
local BtConditions = require("scripts/extension_systems/behavior/utilities/bt_conditions")
local BON_VOMIT_BUFF = "chaos_beast_of_nurgle_hit_by_vomit"
local REQUIRED_VOMIT_STACKS = 3

BtConditions.bon_target_three_vomit_stacks = function(unit, blackboard, scratchpad, condition_args, action_data, is_running)
	if is_running then
		return true
	end

	local target_unit = blackboard.perception.target_unit
	local buff_extension = HEALTH_ALIVE[target_unit] and ScriptUnit.has_extension(target_unit, "buff_system")

	return buff_extension and buff_extension:current_stacks(BON_VOMIT_BUFF) >= REQUIRED_VOMIT_STACKS or false
end

mod:hook_require("scripts/extension_systems/behavior/trees/chaos/chaos_beast_of_nurgle_behavior_tree", function(tree)
	local consuming = find_bt_node(tree, "consuming")
	local align = consuming and consuming[2]

	if align and align.name == "align" then
		align.condition = "bon_target_three_vomit_stacks"
	end
end)

-- BEAST OF NURGLE: Force spit out when Runaway times out
local BtRunAwayAction = require("scripts/extension_systems/behavior/nodes/actions/bt_run_away")

mod:hook(BtRunAwayAction, "run", function (func, self, unit, breed, blackboard, scratchpad, action_data, dt, t, ...)
    if breed.name == "chaos_beast_of_nurgle" and scratchpad.exit_t and t > scratchpad.exit_t then
        return "failed"
    end

    return func(self, unit, breed, blackboard, scratchpad, action_data, dt, t, ...)
end)

-- BEAST OF NURGLE: Runaway timeout duration, self-heal
BreedActions.chaos_beast_of_nurgle.run_away.max_duration = 8 -- 25
BreedActions.chaos_beast_of_nurgle.consume_minion.heal_amount[5] = 5000 -- 1000

-- BEAST OF NURGLE: Expand eat enemy table
local breed_chaos_beast_of_nurgle = require("scripts/settings/breed/breeds/chaos/chaos_beast_of_nurgle_breed")

breed_chaos_beast_of_nurgle.nearby_units_broadphase_config.valid_breeds = {
	chaos_armored_infected = true,
	chaos_newly_infected = true,
	chaos_poxwalker = true,
	chaos_mutated_poxwalker = true,
	chaos_lesser_mutated_poxwalker = true,
	cultist_assault = true,
	cultist_berzerker = true,
	cultist_gunner = true,
	cultist_melee = true,
	cultist_shocktrooper = true,
	renegade_assault = true,
	renegade_berzerker = true,
	renegade_gunner = true,
	renegade_melee = true,
	renegade_rifleman = true,
	renegade_shocktrooper = true,
}

-- Fix crash for breeds without death_bon_eaten animation
local MinionAnimationExtension = require("scripts/extension_systems/animation/minion_animation_extension")
local BON_EATEN_ANIM = "death_bon_eaten"

mod:hook(MinionAnimationExtension, "anim_event", function(func, self, event_name, ...)
	if event_name == BON_EATEN_ANIM and not Unit.has_animation_event(self._unit, event_name) then
		return
	end

	return func(self, event_name, ...)
end)

-- BEAST OF NURGLE: Vomit cooldown increase
mod:hook_require("scripts/settings/monster/chaos_beast_of_nurgle_settings", function(settings)
    settings.cooldowns.vomit = 3 -- 2
end)

-- GUNNERS: Shoot without clear shot (also from cover), ignore locked_in_melee
local UNLOCKED_INTENSITY_TYPE = "elite_ranged_unlocked"
local UNLOCKED_GUNNER_BREEDS = {
	renegade_radio_operator = {
		breed = "scripts/settings/breed/breeds/renegade/renegade_radio_operator_breed",
		tree = "scripts/extension_systems/behavior/trees/renegade/renegade_radio_operator_behavior_tree",
		shoot_node = "shoot_spray_n_pray",
	},
	chaos_ogryn_gunner = {
		breed = "scripts/settings/breed/breeds/chaos/chaos_ogryn_gunner_breed",
		tree = "scripts/extension_systems/behavior/trees/chaos/chaos_ogryn_gunner_behavior_tree",
		shoot_node = "shoot",
	},
}

-- New intensity type: elite_ranged but without the locked_in_melee check
mod:hook_require("scripts/settings/attack_intensity/attack_intensity_settings", function(settings)
	local intensities = settings.attack_intensities

	if not intensities[UNLOCKED_INTENSITY_TYPE] then
		local unlocked = table.clone(intensities.elite_ranged)

		for _, difficulty_entry in ipairs(unlocked) do
			difficulty_entry.locked_in_melee_check = false -- true
		end

		intensities[UNLOCKED_INTENSITY_TYPE] = unlocked
	end
end)

mod:hook_require("scripts/extension_systems/attack_intensity/player_unit_attack_intensity_extension", function(PlayerUnitAttackIntensityExtension)
	mod:hook_safe(PlayerUnitAttackIntensityExtension, "add_intensity", function(self, intensity_type, intensity)
		if intensity_type == "elite_ranged" and self._intensity_data[UNLOCKED_INTENSITY_TYPE] then
			PlayerUnitAttackIntensityExtension.add_intensity(self, UNLOCKED_INTENSITY_TYPE, intensity)
		end
	end)
end)

local UNLOCKED_GUNNER_ACTIONS = {}

for breed_name, paths in pairs(UNLOCKED_GUNNER_BREEDS) do
	local breed = require(paths.breed)
	local cooldowns = breed.attack_intensity_cooldowns

	cooldowns[UNLOCKED_INTENSITY_TYPE] = table.clone(cooldowns.elite_ranged)

	for _, action in pairs(BreedActions[breed_name]) do
		if type(action) == "table" then
			UNLOCKED_GUNNER_ACTIONS[action] = true

			if action.attack_intensity_type == "elite_ranged" then
				action.attack_intensity_type = UNLOCKED_INTENSITY_TYPE -- "elite_ranged"
			end
		end
	end
end

-- Open combat: Remove has_clear_shot from behavior trees
for _, paths in pairs(UNLOCKED_GUNNER_BREEDS) do
	mod:hook_require(paths.tree, function(tree)
		local shoot_node = find_bt_node(tree, paths.shoot_node)

		if shoot_node and shoot_node.condition == "has_clear_shot" then
			shoot_node.condition = nil -- "has_clear_shot"
		end
	end)
end

-- In cover combat: shoot anyway without a clear shot
mod:hook_require("scripts/extension_systems/behavior/nodes/actions/bt_in_cover_action", function(BtInCoverAction)
	mod:hook(BtInCoverAction, "_has_clear_shot_from_aiming_when_peeking", function(func, self, unit, scratchpad, action_data, perception_component, target_unit)
		local has_clear_shot, aim_position = func(self, unit, scratchpad, action_data, perception_component, target_unit)

		if has_clear_shot or not UNLOCKED_GUNNER_ACTIONS[action_data] then
			return has_clear_shot, aim_position
		end

		local to_node = scratchpad.clear_shot_line_of_sight_data.to_node

		aim_position = MinionAttack.get_aim_position(unit, scratchpad, action_data.clear_shot_line_of_sight_id, to_node) or POSITION_LOOKUP[target_unit]

		if not aim_position then
			return false, nil
		end

		return true, aim_position
	end)
end)

-- MUTANT: GRAB
local BreedActions = require("scripts/settings/breed/breed_actions")
BreedActions.cultist_mutant.charge.grab_anim_duration = {
    cryptic = 0.75, -- 1.5
    human = 0.75,  -- 1.5
    ogryn = 0.75, -- 0.8333333333
}

-- MUTANT: Keep smashing the grabbed player until downed/death
local BtMutantChargerChargeAction = require("scripts/extension_systems/behavior/nodes/actions/bt_mutant_charger_charge_action")
local ENDLESS_SMASH_BREEDS = {
	cultist_mutant = true,
	-- cultist_mutant_mutator = true,
}

local function smash_target_finished(target)
	local unit_data_extension = ScriptUnit.has_extension(target, "unit_data_system")

	if not unit_data_extension then
		return true
	end

	return unit_data_extension:read_component("knocked_down_state_input").knock_down or unit_data_extension:read_component("dead_state_input").die
end

mod:hook(BtMutantChargerChargeAction, "_update_grabbed_target", function(func, self, unit, scratchpad, action_data, t, dt)
	if scratchpad.next_smash_anim_t then
		local unit_data_extension = ScriptUnit.extension(unit, "unit_data_system")

		if ENDLESS_SMASH_BREEDS[unit_data_extension:breed().name] then
			if smash_target_finished(scratchpad.grabbed_target) then
				if scratchpad.endless_smash then
					scratchpad.endless_smash = nil
					scratchpad.grab_target_duration = t
				end
			else
				scratchpad.endless_smash = true
				scratchpad.grab_target_duration = math.huge -- never reach the throw
			end
		end
	end

	return func(self, unit, scratchpad, action_data, t, dt)
end)

-- Fix smash animation playing only once for player breeds
local PlayerCharacterStateMutantCharged = require("scripts/extension_systems/character_state_machine/character_states/player_character_state_mutant_charged")
local PLAYER_SMASH_LOOP_TIME = {
	cryptic = 1.8333333333333333,
	human = 1.8333333333333333,
	ogryn = 1.6666666666666667,
}

mod:hook(PlayerCharacterStateMutantCharged, "fixed_update", function(func, self, unit, dt, t, ...)
	if self._charger_throw_smash and self._disabled_state_input.trigger_animation == "smash" then
		local next_t = self._endless_next_smash_t

		if not next_t then
			self._endless_next_smash_t = t + PLAYER_SMASH_LOOP_TIME[self._breed.name]
		elseif t >= next_t then
			self._charger_throw_smash = false -- replays charger_smash
			self._endless_next_smash_t = nil
		end
	end

	return func(self, unit, dt, t, ...)
end)

mod:hook_safe(PlayerCharacterStateMutantCharged, "on_exit", function(self)
	self._endless_next_smash_t = nil
end)

-- DOGS: Unstaggerable while having pounced a player (except Ogryn charge)
local POUNCE_NO_STAGGER_GRACE = 1.5
local POUNCE_NO_STAGGER_BREEDS = {
	-- chaos_hound = true,
	chaos_armored_hound = true,
	-- chaos_hound_mutator = true,
}

mod:hook_require("scripts/extension_systems/behavior/nodes/actions/bt_chaos_hound_target_pounced_action", function(BtChaosHoundTargetPouncedAction)
	mod:hook_safe(BtChaosHoundTargetPouncedAction, "enter", function(self, unit, breed, blackboard, scratchpad, action_data, t)
		if POUNCE_NO_STAGGER_BREEDS[breed.name] then
			scratchpad.no_stagger_grace_t = t + POUNCE_NO_STAGGER_GRACE
		end
	end)

	mod:hook(BtChaosHoundTargetPouncedAction, "run", function(func, self, unit, breed, blackboard, scratchpad, action_data, dt, t)
		local apply_t = scratchpad.no_stagger_grace_t

		if apply_t and t >= apply_t then
			scratchpad.no_stagger_grace_t = nil

			local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

			if buff_extension then
				local _, local_index = buff_extension:add_externally_controlled_buff("havoc_no_stagger", t)

				scratchpad.no_stagger_buff_index = local_index
			end
		end

		return func(self, unit, breed, blackboard, scratchpad, action_data, dt, t)
	end)

	mod:hook(BtChaosHoundTargetPouncedAction, "leave", function(func, self, unit, breed, blackboard, scratchpad, action_data, t, reason, destroy)
		scratchpad.no_stagger_grace_t = nil

		local local_index = scratchpad.no_stagger_buff_index

		if local_index then
			scratchpad.no_stagger_buff_index = nil

			local buff_extension = not destroy and ScriptUnit.has_extension(unit, "buff_system")

			if buff_extension then
				buff_extension:remove_externally_controlled_buff(local_index)
			end
		end

		return func(self, unit, breed, blackboard, scratchpad, action_data, t, reason, destroy)
	end)
end)

-- DOGS: Leap speed
local ChaosHoundSettings = require("scripts/settings/specials/chaos_hound_settings")
local DEFAULT_LEAP_SPEED = ChaosHoundSettings.leap_speed
local DEFAULT_LEAP_GRAVITY = ChaosHoundSettings.leap_gravity
local DOG_LEAP_SPEED = {
	chaos_hound = 26, -- 21
	chaos_armored_hound = 18, -- 21
	-- chaos_hound_mutator = 21,
}
local DOG_LEAP_GRAVITY = {
	-- chaos_hound = 13.82,
	-- chaos_armored_hound = 13.82,
	-- chaos_hound_mutator = 13.82,
}

local function set_leap_speed(func, self, unit, breed, ...)
	ChaosHoundSettings.leap_speed = DOG_LEAP_SPEED[breed.name] or DEFAULT_LEAP_SPEED
	ChaosHoundSettings.leap_gravity = DOG_LEAP_GRAVITY[breed.name] or DEFAULT_LEAP_GRAVITY

	return func(self, unit, breed, ...)
end

for _, path in ipairs({
	"scripts/extension_systems/behavior/nodes/actions/bt_chaos_hound_approach_action",
	"scripts/extension_systems/behavior/nodes/actions/bt_chaos_hound_leap_action",
}) do
	mod:hook_require(path, function(action)
		mod:hook(action, "run", set_leap_speed)
	end)
end

-- PUSH NEARBY ENEMIES: Exclude Poxburster
local breed_chaos_poxwalker_bomber = require("scripts/settings/breed/breeds/chaos/chaos_poxwalker_bomber_breed")

breed_chaos_poxwalker_bomber.ignore_minion_push = true -- nil

-- POXBURSTER LUNGE: Let any nearby player trigger the extended push
local POXBURSTER_PUSH_RANGE = 5

mod:hook_require("scripts/extension_systems/behavior/nodes/actions/bt_poxwalker_bomber_approach_action", function(BtPoxwalkerBomberApproachAction)
	mod:hook(BtPoxwalkerBomberApproachAction, "run", function(func, self, unit, breed, blackboard, scratchpad, action_data, dt, t)
		local result = func(self, unit, breed, blackboard, scratchpad, action_data, dt, t)

		if scratchpad.state == "lunging" and not scratchpad.extra_push_applied then
			local side_system = Managers.state.extension:system("side_system")
			local side = side_system.side_by_unit[unit]
			local player_units = side and side.valid_enemy_player_units
			local bomber_position = POSITION_LOOKUP[unit]

			if player_units and bomber_position then
				for i = 1, #player_units do
					local player_unit = player_units[i]
					local player_position = POSITION_LOOKUP[player_unit]

					if ALIVE[player_unit] and player_position and Vector3.distance(bomber_position, player_position) < POXBURSTER_PUSH_RANGE then
						local unit_data_extension = ScriptUnit.has_extension(player_unit, "unit_data_system")
						local action_push_component = unit_data_extension and unit_data_extension:read_component("action_push")

						if action_push_component and action_push_component.has_pushed then
							Attack.execute(unit, action_data.push_enemies_damage_profile, "power_level", action_data.push_enemies_power_level, "attacking_unit", player_unit, "attack_direction", Vector3.normalize(bomber_position - player_position), "hit_zone_name", "torso")

							scratchpad.extra_push_applied = true

							break
						end
					end
				end
			end
		end

		return result
	end)
end)

-- PUSH FRIENDLY MINIONS: Exclude Poxburster
local FRIENDLY_BROADPHASE_RESULTS = {}
local MINION_BREED_TYPE = BreedSettings.types.minion

mod:hook_origin(MinionAttack, "push_friendly_minions", function(unit, scratchpad, action_data, t, optional_from_position)
	table.clear(FRIENDLY_BROADPHASE_RESULTS)

	local broadphase_system = scratchpad.broadphase_system
	local broadphase = broadphase_system.broadphase
	local side_system = scratchpad.side_system
	local side = side_system.side_by_unit[unit]
	local broadphase_relation = action_data.push_minions_side_relation
	local target_side_names = side:relation_side_names(broadphase_relation)
	local radius = action_data.push_minions_radius
	local from = optional_from_position or POSITION_LOOKUP[unit]
	local num_results = broadphase.query(broadphase, from, radius, FRIENDLY_BROADPHASE_RESULTS, target_side_names, MINION_BREED_TYPE)

	if num_results < 1 then
		return
	end

	local power_level = action_data.push_minions_power_level
	local damage_profile = action_data.push_minions_damage_profile
	local damage_type = action_data.push_minions_damage_type
	local pushed_minions = scratchpad.pushed_minions
	local push_minions_fx_template = action_data.push_minions_fx_template

	for i = 1, num_results do
		local hit_unit = FRIENDLY_BROADPHASE_RESULTS[i]

		if hit_unit ~= unit and not pushed_minions[hit_unit] then
			local to = POSITION_LOOKUP[hit_unit]
			local direction = Vector3.normalize(to - from)

			if Vector3.length_squared(direction) == 0 then
				local current_rotation = Unit.local_rotation(unit, 1)

				direction = Quaternion.forward(current_rotation)
			end

			local unit_data_extension = ScriptUnit.extension(hit_unit, "unit_data_system")
			local breed = unit_data_extension:breed()
			local tags = breed.tags

			if breed.name ~= "chaos_poxwalker_bomber" and (not tags.monster or not tags.interrupter) then
				pushed_minions[hit_unit] = true

				Attack.execute(hit_unit, damage_profile, "power_level", power_level, "attacking_unit", unit, "attack_direction", direction, "hit_zone_name", "torso", "damage_type", damage_type)

				if push_minions_fx_template and (not scratchpad.push_minions_fx_cooldown or t >= scratchpad.push_minions_fx_cooldown) then
					MinionPushFx.play_fx(unit, hit_unit, push_minions_fx_template)

					scratchpad.push_minions_fx_cooldown = t + math.random_range(action_data.push_minions_fx_cooldown[1], action_data.push_minions_fx_cooldown[2])
				end
			end
		end
	end
end)

-- RADIO OPERATOR: Summons table
BreedActions.renegade_radio_operator.summon.breed_data = {
			{
				name = "renegade_assault",
				amount = {
					5,
					5,
				},
			},
			{
				name = "chaos_ogryn_gunner",
				amount = {
					1,
					1,
				},
			},
			{
				name = "cultist_berzerker",
				amount = {
					4,
					4,
				},
			},
			{
				name = "chaos_ogryn_executor",
				amount = {
					1,
					1,
				},
			}
		}

BreedActions.renegade_radio_operator.should_close_spawn_outside_los = true

-- PACK MASTER: Back to elite
local breed_chaos_ogryn_houndmaster = require("scripts/settings/breed/breeds/chaos/chaos_ogryn_houndmaster_breed")

breed_chaos_ogryn_houndmaster.size_variation_range = { 1, 1 }
breed_chaos_ogryn_houndmaster.tags.monster = nil
breed_chaos_ogryn_houndmaster.tags.elite = true
breed_chaos_ogryn_houndmaster.boss_health_bar_disabled = true
breed_chaos_ogryn_houndmaster.trigger_boss_health_bar_on_aggro = false
breed_chaos_ogryn_houndmaster.trigger_boss_health_bar_on_damaged = false
breed_chaos_ogryn_houndmaster.is_boss = false

BreedActions.chaos_ogryn_houndmaster.summon.scale_breeds_by_resistance = true
BreedActions.chaos_ogryn_houndmaster.summon.breed_data = {
			{
				{
					name = "chaos_hound",
					amount = {
						2,
						2,
					},
				},
			},
}

-- SCAB BOMBER: Increase throw cooldown 
BreedActions.renegade_grenadier.throw_grenade.cooldown = MinionDifficultySettings.cooldowns.cultist_grenadier_throw
BreedActions.renegade_grenadier.quick_throw_grenade.cooldown = MinionDifficultySettings.cooldowns.cultist_grenadier_throw

-- NET: SPEED CHANGES & DETECTION RANGE ADJUSTMENTS
local breed_renegade_netgunner = require("scripts/settings/breed/breeds/renegade/renegade_netgunner_breed")

breed_renegade_netgunner.run_speed = 6.5
breed_renegade_netgunner.walk_speed = 3.5
BreedActions.renegade_netgunner.approach_target.speed = 6.5

mod:hook_require("scripts/extension_systems/perception/minion_perception_extension", function(MinionPerceptionExtension)
	mod:hook(MinionPerceptionExtension, "_within_detection_los_range", function(func, self, unit, unit_position, target_unit, target_position)
		local within_range, clear_last_los_position = func(self, unit, unit_position, target_unit, target_position)

		if within_range or self._breed.name ~= "renegade_netgunner" then
			return within_range, clear_last_los_position
		end

		local target_distance_squared = Vector3.distance_squared(unit_position, target_position)

		if target_distance_squared <= 25 or target_distance_squared > 100 then
			return within_range, clear_last_los_position
		end

		local target_buff_extension = ScriptUnit.has_extension(target_unit, "buff_system")

		if not target_buff_extension or not target_buff_extension:has_keyword("concealed") then
			return within_range, clear_last_los_position
		end

		local ignore_detection_los_modifiers = self._ignore_detection_los_modifiers

		self._ignore_detection_los_modifiers = true
		within_range, clear_last_los_position = func(self, unit, unit_position, target_unit, target_position)
		self._ignore_detection_los_modifiers = ignore_detection_los_modifiers

		return within_range, clear_last_los_position
	end)
end)

-- NET: Enable collision after being dragged for 0.7 seconds to avoid cross-country drag bullshit
local NETTED_MINION_COLLISION_DELAY = 0.7

mod:hook_require("scripts/extension_systems/character_state_machine/character_states/player_character_state_netted", function(PlayerCharacterStateNetted)
	mod:hook_safe(PlayerCharacterStateNetted, "on_enter", function(self)
		self._locomotion_steering_component.disable_minion_collision = false
		self._onslaught_minion_collision_enable_t = self._character_state_component.entered_t + NETTED_MINION_COLLISION_DELAY
	end)

	mod:hook_safe(PlayerCharacterStateNetted, "fixed_update", function(self, unit, dt, t)
		local enable_t = self._onslaught_minion_collision_enable_t

		if enable_t and t >= enable_t then
			self._locomotion_steering_component.disable_minion_collision = false
			self._onslaught_minion_collision_enable_t = nil
		end
	end)

	mod:hook_safe(PlayerCharacterStateNetted, "on_exit", function(self)
		self._onslaught_minion_collision_enable_t = nil
	end)
end)

local breed_renegade_sniper = require("scripts/settings/breed/breeds/renegade/renegade_sniper_breed")

-- SNIPERS: SEE THROUGH SMOKE AND PUSH FORWARD MORE AGGRESSIVELY
breed_renegade_sniper.ignore_smoke_fog_los = true
breed_renegade_sniper.max_distance_from_combat_vector = 70
breed_renegade_sniper.cover_config.min_distance_from_target = 12
breed_renegade_sniper.cover_config.max_distance_from_target = 35
breed_renegade_sniper.cover_config.leave_cover_after_losing_los_duration = 5
breed_renegade_sniper.combat_vector_config.choose_furthest_away = false
BreedActions.renegade_sniper.shoot.lost_los_fail_duration = 3

-- RENEGADE FLAMER MUTATOR: Add the explosive backpack
local HitZone = require("scripts/utilities/attack/hit_zone")
local WeakspotSettings = require("scripts/settings/damage/weakspot_settings")
local breed_renegade_flamer = require("scripts/settings/breed/breeds/renegade/renegade_flamer_breed")
local breed_renegade_flamer_mutator = require("scripts/settings/breed/breeds/renegade/renegade_flamer_mutator_breed")
local BACKPACK = HitZone.hit_zone_names.backpack

do
	local original = breed_renegade_flamer
	local breed = breed_renegade_flamer_mutator

	-- Change base unit which has actor for backpack
	breed.base_unit = original.base_unit

	-- Copy hit zone etc
	local has_backpack_zone = false

	for _, zone in ipairs(breed.hit_zones) do
		if zone.name == BACKPACK then
			has_backpack_zone = true

			break
		end
	end

	if not has_backpack_zone then
		for _, zone in ipairs(original.hit_zones) do
			if zone.name == BACKPACK then
				table.insert(breed.hit_zones, 2, table.clone(zone))

				break
			end
		end
	end

	breed.hit_zone_ragdoll_actors[BACKPACK] = table.clone(original.hit_zone_ragdoll_actors[BACKPACK])
	breed.hit_zone_ragdoll_pushes[BACKPACK] = table.clone(original.hit_zone_ragdoll_pushes[BACKPACK])
	breed.hit_zone_weakspot_types[BACKPACK] = WeakspotSettings.types.explosive_backpack
	breed.hitzone_damage_multiplier.ranged[BACKPACK] = original.hitzone_damage_multiplier.ranged[BACKPACK] -- 0.2

	if not table.contains(breed.spawn_buffs, "flamer_backpack_counter") then
		table.insert(breed.spawn_buffs, "flamer_backpack_counter")
	end

	breed.blackboard_component_config.statistics.flamer_backpack_impacts = "number"

	-- Add vortex_settings
	breed.vortex_settings = table.clone(original.vortex_settings)
end

-- Copy backpack counter buff
mod:hook_require("scripts/settings/buff/minion_buff_templates", function(templates)
	mod:hook_safe(templates.flamer_backpack_counter, "start_func", function(template_data, template_context)
		if template_context.breed.name == "renegade_flamer_mutator" then
			template_data.buff_name = "renegade_flamer_backpack_damaged"
		end
	end)
end)

-- Copy action data
BreedActions.renegade_flamer_mutator.explode = table.shallow_copy(BreedActions.renegade_flamer.explode)
BreedActions.renegade_flamer_mutator.vortex_grabbed = table.clone(BreedActions.renegade_flamer.vortex_grabbed)

-- Behavior tree
mod:hook_require("scripts/extension_systems/behavior/trees/behavior_trees", function(trees)
	local tree = trees.renegade_flamer_mutator

	if not tree then
		return
	end

	tree[1] = "BtSelectorNode" -- "BtRenegadeFlamerMutatorSelectorNode"

	for i = 2, #tree do
		local child = tree[i]

		if type(child) == "table" then
			if child.name == "death" and child[1] == "BtDieAction" then
				tree[i] = {
					"BtSequenceNode",
					{
						"BtFlamerCheckBackpackAction",
						name = "explode",
						action_data = BreedActions.renegade_flamer_mutator.explode,
					},
					{
						"BtDieAction",
						name = "death",
						action_data = child.action_data,
					},
					name = "death_sequence",
					state = "dead",
				}
			elseif child.name == "disable" and child[1] == "BtDisableAction" then
				tree[i] = {
					"BtSelectorNode",
					{
						"BtMinionVortexGrabbedAction",
						condition = "vortex_grabbed",
						name = "vortex_grabbed",
						action_data = BreedActions.renegade_flamer_mutator.vortex_grabbed,
					},
					child,
					name = "disable_actions",
				}
			end
		end
	end
end)

-- Experimental targetting behavior changes
local breed_renegade_executor = require("scripts/settings/breed/breeds/renegade/renegade_executor_breed")
local breed_chaos_ogryn_bulwark = require("scripts/settings/breed/breeds/chaos/chaos_ogryn_bulwark_breed")

local TargetSelectionTemplates = require("scripts/extension_systems/perception/target_selection_templates")

local Breed = require("scripts/utilities/breed")
local MinionMovement = require("scripts/utilities/minion_movement")
local MinionTargetSelection = require("scripts/utilities/minion_target_selection")
local MinionTargetOverride = require("scripts/utilities/minion_target_override")
local PerceptionSettings = require("scripts/settings/perception/perception_settings")
local aggro_states = PerceptionSettings.aggro_states

-- CUSTOM SCORING: Linear Falloff + Backline Bonus
local function _calculate_distance_and_backline_weight(target_selection_weights, distance_sq, breed)
    local max_distance = target_selection_weights.max_distance or MinionTargetSelection.detection_radius(breed)

    local distance = math.sqrt(distance_sq)
    local normalized_distance = math.clamp(distance / max_distance, 0, 1)
    local inverse_radius = 1 - normalized_distance

    local base_weight = target_selection_weights.distance_to_target or 1

    local distance_weight = inverse_radius * base_weight

    local backline_threshold = 0.5
    if normalized_distance >= backline_threshold then
        local backline_bonus = 50

        local backline_factor = (normalized_distance - backline_threshold) / (1 - backline_threshold)
        distance_weight = distance_weight + (backline_bonus * backline_factor)
    end

    return distance_weight, inverse_radius
end

local function _calculate_score_bulwark(breed, unit, target_unit, distance_sq, is_new_target, threat_units, perception_component, t, debug_target_weighting_or_nil)
    local target_selection_weights = breed.target_selection_weights
    local target_unit_data_extension = ScriptUnit.extension(target_unit, "unit_data_system")
    local target_breed = target_unit_data_extension:breed()

    local score = 0

    local distance_weight, inverse_radius = _calculate_distance_and_backline_weight(target_selection_weights, distance_sq, breed)
    score = score + distance_weight

    local occupied_slots_weight = MinionTargetSelection.occupied_slots_weight(target_selection_weights, target_unit, target_breed, is_new_target, inverse_radius)
    score = score + occupied_slots_weight

    local threat_weight = MinionTargetSelection.threat_weight(target_selection_weights, target_unit, threat_units)
    score = score + threat_weight

    local disabled_weight = MinionTargetSelection.disabled_weight(target_selection_weights, target_unit, target_breed)
    score = score + disabled_weight

    local targeted_by_monster_weight = MinionTargetSelection.targeted_by_monster_weight(target_selection_weights, target_unit, unit)
    score = score + targeted_by_monster_weight

    local stickiness_weight = MinionTargetSelection.stickiness_weight(target_selection_weights, is_new_target, perception_component, t)
    score = score + stickiness_weight

    local weight_multiplier = MinionTargetSelection.weight_multiplier(target_unit)
    score = score * weight_multiplier

    return math.max(score, 0)
end

-- MAIN TEMPLATE FUNCTION
local DEFAULT_STICKINESS_DISTANCE = 1
local EXTRA_SHOOT_DISTANCE_SQ = 625

TargetSelectionTemplates.custom_backline_melee_elite = function (unit, side, perception_component, buff_extension, breed, target_units, line_of_sight_lookup, t, threat_units, force_new_target_attempt, force_new_target_attempt_config_or_nil, debug_target_weighting_or_nil)
    local current_target_unit = perception_component.target_unit
    local position = POSITION_LOOKUP[unit]
    local best_score, best_target_unit, closest_distance_sq, closest_z_distance

    local detection_radius = MinionTargetSelection.detection_radius(breed)
    local detection_radius_sq = detection_radius^2
    local vector3_distance_squared = Vector3.distance_squared

    target_units = MinionTargetOverride.check_for_target_overrides(unit, target_units, buff_extension)

    if target_units[current_target_unit] then
        local stickiness = breed.target_stickiness_distance or DEFAULT_STICKINESS_DISTANCE
        local target_position = POSITION_LOOKUP[current_target_unit]
        local distance_sq = vector3_distance_squared(position, target_position)
        local z_distance = math.abs(position.z - target_position.z)

        best_target_unit, closest_distance_sq, closest_z_distance = current_target_unit, distance_sq, z_distance

        if force_new_target_attempt then
            best_score = -math.huge
        else
            local is_new_target = false
            best_score = _calculate_score_bulwark(breed, unit, current_target_unit, distance_sq - stickiness, is_new_target, threat_units, perception_component, t, debug_target_weighting_or_nil)
        end
    else
        best_target_unit, closest_distance_sq, closest_z_distance = nil, math.huge, math.huge
        best_score = -math.huge
    end

    local lock_target = perception_component.lock_target

    if not lock_target then
        local taunter_unit = buff_extension:owner_of_buff_with_id("taunted")

        if target_units[taunter_unit] then
            local target_position = POSITION_LOOKUP[taunter_unit]
            local distance_to_target_sq = vector3_distance_squared(position, target_position)
            local z_distance = math.abs(position.z - target_position.z)

            best_target_unit, closest_distance_sq, closest_z_distance = taunter_unit, distance_to_target_sq, z_distance
        else
            local aggro_state = perception_component.aggro_state

            for i = 1, #target_units do
                local target_unit = target_units[i]

                if target_unit ~= current_target_unit and ALIVE[target_unit] then
                    local unit_data_extension = ScriptUnit.extension(target_unit, "unit_data_system")
                    local target_breed = unit_data_extension:breed()
                    local is_shooting = false

                    if Breed.is_player(target_breed) then
                        local shooting_status = unit_data_extension:read_component("shooting_status")
                        is_shooting = shooting_status.shooting or not shooting_status.shooting and t <= shooting_status.shooting_end_time + 1
                    end

                    local target_position = POSITION_LOOKUP[target_unit]
                    local distance_to_target_sq = vector3_distance_squared(position, target_position)

                    local check_distance_sq = is_shooting and distance_to_target_sq - EXTRA_SHOOT_DISTANCE_SQ or distance_to_target_sq

                    if aggro_state == aggro_states.aggroed or check_distance_sq < detection_radius_sq then
                        local is_new_target = true
                        local score = _calculate_score_bulwark(breed, unit, target_unit, distance_to_target_sq, is_new_target, threat_units, perception_component, t, debug_target_weighting_or_nil)

                        if best_score < score then
                            local has_line_of_sight = line_of_sight_lookup[target_unit]

                            if aggro_state == aggro_states.aggroed or has_line_of_sight then
                                local z_distance = math.abs(position.z - target_position.z)

                                best_target_unit, closest_distance_sq, closest_z_distance = target_unit, distance_to_target_sq, z_distance
                                best_score = score
                            end
                        end
                    end
                end
            end
        end
    end

    if best_target_unit then
        local has_line_of_sight = line_of_sight_lookup[best_target_unit]

        perception_component.has_line_of_sight = has_line_of_sight
        perception_component.target_distance = math.sqrt(closest_distance_sq)
        perception_component.target_distance_z = closest_z_distance
        perception_component.target_speed_away = MinionMovement.target_speed_away(unit, best_target_unit)
    end

    return best_target_unit
end


breed_renegade_executor.target_selection_template = TargetSelectionTemplates.melee
breed_chaos_ogryn_bulwark.target_selection_template = TargetSelectionTemplates.custom_backline_melee_elite