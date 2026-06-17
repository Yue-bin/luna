local lapis = require("lapis")
local app = lapis.Application()
local bint = require("bint")(256)

local pools = require("pools")
--- @cast pools RngPoolList
local config = require("rng_config")

-- 默认使用第一个池
local default_pool = config[1].name

app:get("/random/list-pools", function(self)
  local pools_list = {}
  for _, pool_config in ipairs(config) do
    table.insert(pools_list, pool_config.name)
  end
  return {
    json = {
      pools = pools_list,
    },
  }
end)

app:get("/random/number", function(self)
  local lower = bint.fromstring(self.params.lower) or bint.zero()
  local upper = bint.fromstring(self.params.upper) or bint.frominteger(100)
  local pool = self.params.pool or default_pool
  --- @cast upper bint
  --- gosh i need `shouldfrom` like same in go
  local random_number = pools[pool]:random_number(lower, upper)
  return {
    json = {
      number = tostring(random_number),
    },
  }
end)



return app
