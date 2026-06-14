local config = require("lapis.config")

config("development", {
  server = "cqueues",
  port = 8082,
  bind_host = "127.0.0.1"
})
