local lapis = require("lapis")
local app = lapis.Application()
local bint = require("bint")(256)

local rng = require("rng")

app:get("/random/number", function(self)
  local lower = bint.fromstring(self.params.lower) or bint.zero()
  local upper = bint.fromstring(self.params.upper) or bint.frominteger(100)
  --- @cast upper bint
  --- gosh i need `shouldfrom` like same in go
  local random_number = rng.random_number(lower, upper)
  return {
    json = {
      number = tostring(random_number),
    },
  }
end)

return app
