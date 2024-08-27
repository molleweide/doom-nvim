local M = {}

-- TODO: Move this into the `nest` module.

M.mapper_records = {}

local function map(
    buffnr,
    mode,
    keys,
    cmd,
    options,
    category,
    unique_identifier,
    description,
    module_origin
)
  local buffer_only
  if buffnr == nil then
    buffer_only = false
  else
    buffer_only = true
  end

  local record = {
    mode = mode,
    keys = keys,
    cmd = cmd,
    options = options,
    category = category,
    unique_identifier = unique_identifier,
    description = description,
    buffer_only = buffer_only,
    module_origin = module_origin,
  }

  local maybe_existing_record = _G._doom.bindings_unique[unique_identifier]

  if maybe_existing_record then
    -- lookup table to prevent duplicates
    _G._doom.bindings_unique[unique_identifier] = record
    -- prepare indexed array for quick telescope init
    -- table.insert(_G._doom.bindings_array, record)
  elseif
      maybe_existing_record.mode ~= mode
      or maybe_existing_record.keys ~= keys
      or maybe_existing_record.cmd ~= cmd
      or maybe_existing_record.category ~= category
      or maybe_existing_record.description ~= description
  then
    print("Mapper error : unique identifier " .. unique_identifier .. " cannot be used twice")
  end
end

function M.map_buf_virtual(
    mode,
    keys,
    cmd,
    options,
    category,
    unique_identifier,
    description,
    module_origin
)
  map(true, mode, keys, cmd, options, category, unique_identifier, description, module_origin)
end
function M.map_virtual(
    mode,
    keys,
    cmd,
    options,
    category,
    unique_identifier,
    description,
    module_origin
)
  map(nil, mode, keys, cmd, options, category, unique_identifier, description, module_origin)
end

return M
