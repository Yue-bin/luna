local config = require("lapis.config")

config("development", {
  server = "cqueues",
  port = 8082,
  bind_host = "127.0.0.1",
  code_cache = "on"
})

-- 下面用作rng部分的配置

--- 池配置
--- @class PoolConfig
--- @field name string 池名称
--- @field buffer_size integer 缓冲区大小(chunk数)
--- @field chunk_size integer 缓冲区中每个chunk的大小(字节)
--- @field dev_path string 要打开的设备文件，默认为"/dev/urandom"
--- rng配置
--- @alias RngConfig PoolConfig[] rng配置
local rng_config = {
  -- 池1
  {
    name = "infnoise",
    -- 共计1kb缓冲区，两次fill填满
    buffer_size = 256,            -- 缓冲区chunk数量
    chunk_size = 4,               -- 缓冲区每个chunk的字节数
    dev_path = "/dev/infnoise-01" -- 随机数设备路径
  },
  -- 池2
  {
    name = "urandom",
    -- 共计1kb缓冲区，两次fill填满
    buffer_size = 256,        -- 缓冲区chunk数量
    chunk_size = 4,           -- 缓冲区每个chunk的字节数
    dev_path = "/dev/urandom" -- 随机数设备路径
  },
}

return rng_config
