local lapis = require("lapis")
local app = lapis.Application()

app:get("/random", function(self)
  local lower = self.params.lower or 0
  local upper = self.params.upper or 100
  local random_number = math.random(lower, upper)
  return { json = { number = random_number } }
end)

return app
