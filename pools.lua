--- @alias RngPoolList Rng[]
--- rng池列表
--- @type RngPoolList
local pools = {}

local rng = require("rng")
local config = require("rng_config")

for _, pool_config in ipairs(config) do
    pools[pool_config.name] = rng.new(pool_config)
end

--- 兜底
--- @param _ any
--- @param rng_name string
local function reject_nil_index(_, rng_name)
    error("Invalid pool name: " .. tostring(rng_name))
end

pools = setmetatable(pools, {
    __index = reject_nil_index
})

return pools
