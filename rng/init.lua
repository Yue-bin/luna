--- rng生成接口
--- @class Rng
--- @field private rng_buffer RngBuffer 随机数缓冲区
--- @field private config PoolConfig 配置
local _M = {}

local log = require("lapis.logging")
local bint = require("bint")(256)
local helper = require("rng.helper")

--- 生成范围内的随机数
--- @param lower bint 随机数下界
--- @param upper bint 随机数上界
--- @return bint 生成的随机数
function _M:random_number(lower, upper)
    -- 归一化下界到0
    local range = upper - lower + 1
    if range == 1 then
        return lower
    end
    log.notice("Generating random number between " .. tostring(lower) .. " and " .. tostring(upper))
    local need_chunks = helper.need_chunks(range, self.config.chunk_size)
    if need_chunks == 0 then
        error("input out of range")
    end
    local total_bytes = bint.frominteger(need_chunks) * self.config.chunk_size
    local max_val = bint.one() << (total_bytes * 8) -- 2^(8*total_bytes)
    local limit = (max_val // range) * range        -- 安全区间上界
    local raw_random = nil
    local retry = -1
    repeat
        raw_random = bint.fromle(
            self.rng_buffer:read(need_chunks)
        )
        retry = retry + 1
    until raw_random < limit -- 直到落在接受区
    return raw_random % range + lower
end

--- 生成给定长度的随机hex字符串
--- @param length integer 生成的随机字符串长度
--- @return string 生成的随机字符串
function _M:random_hex(length)
    if length <= 0 then
        error("Length must be greater than 0")
    end
    -- 1 hex = 4 bits = 0.5 bytes
    local need_chunks = math.ceil(length * 0.5)
    local raw_hex = helper.buffer_to_hex(
        self.rng_buffer:read(need_chunks)
    )
    if not raw_hex then
        error("Failed to generate random hex")
    end
    return raw_hex:sub(1, length)
end

--- 实例化一个rng池实例
--- @param config PoolConfig
--- @return Rng 创建的rng池实例
local function new(config)
    return setmetatable({
        rng_buffer = require("rng.rngbuffer")
            .new(
                config.buffer_size,
                config.chunk_size,
                config.dev_path
            ),
        config = config
    }
    , { __index = _M })
end

return {
    new = new
}
