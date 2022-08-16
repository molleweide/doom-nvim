local tm = {}

-- Dynamically generate titles so that you know exactly what parts of doom
-- that you are operating on.

tm.get_title = function()
  local title

  if DOOM_UI_STATE.query.type == "main_menu" then
    title = ":: MAIN MENU ::"

  elseif DOOM_UI_STATE.query.type == "settings" then
    title = ":: USER SETTINGS ::"

  elseif DOOM_UI_STATE.query.type == "modules" then
    title = ":: MODULES LIST ::"

    -- TODO: MODULES LIST (ORIGINS/CATEGORIES)

  elseif DOOM_UI_STATE.query.type == "module" then
    local postfix = ""
	  local morig = DOOM_UI_STATE.selected_module.origin
	  local mfeat = DOOM_UI_STATE.selected_module.section
	  local mname = DOOM_UI_STATE.selected_module.name
	  local menab = DOOM_UI_STATE.selected_module.enabled
    local on = menab and "enabled" or "disabled"
	  postfix = postfix .. "["..morig..":"..mfeat.."] -> " .. mname .. " (" .. on .. ")"
    title = "MODULE_FULL: " .. postfix -- make into const

  elseif DOOM_UI_STATE.query.type == "component" then
    -- TODO: MODULES LIST (/CATEGORIES)

  elseif DOOM_UI_STATE.query.type == "all" then
    -- TODO: MODULES LIST (/CATEGORIES)

  end

  return title
end



return tm
