--- 这里是各种随机数辅助函数
--- @class RngHelper
local _M = {}

local log = require("lapis.logging")
local bint = require("bint")(256)
local config = require("config")

--- 计算生成指定范围内的随机数所需的chunk数
--- 用于精确拒绝采样算法
--- @param range bint 随机数范围
--- @return bint chunks 需要的chunk数
function _M.need_chunks(range)
    if range <= 1 then
        return bint.zero()
    end
    local chunks = bint.zero()
    while bint.ispos(range) do
        chunks = chunks + 1
        range = range >> (config.chunk_size * 8)
    end
    log.notice("Need " .. tostring(chunks) .. " chunks")
    if bint.iszero(chunks) then
        chunks = bint.one()
    end
    return chunks
end

return _M
