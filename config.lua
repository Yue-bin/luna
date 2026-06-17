local config = require("lapis.config")

config("development", {
  server = "cqueues",
  port = 8082,
  bind_host = "127.0.0.1",
  code_cache = "on"
})

-- 下面用作rng部分的配置
local rng_config = {
  -- 共计1kb缓冲区，两次fill填满
  buffer_size = 256,        -- 缓冲区chunk数量
  chunk_size = 4,           -- 缓冲区每个chunk的字节数
  dev_path = "/dev/urandom" -- 随机数设备路径
}

return rng_config
