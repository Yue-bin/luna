--- 这里是各种随机数辅助函数
--- @class RngHelper
local _M = {}

local bint = require("bint")(256)
local config = require("config")

--- 计算生成指定范围内的随机数所需的chunk数
--- 用于精确拒绝采样算法
--- @param range bint 随机数范围
--- @param chunk_size integer chunk大小
--- @return integer chunks 需要的chunk数
function _M.need_chunks(range, chunk_size)
    if range <= 1 then
        return 0
    end
    local chunks = 1
    local bits_per_chunk = chunk_size * 8
    -- 计算需要多少个 chunk 才能覆盖 range
    -- 使用左移构造阈值 2^(chunks*bits_per_chunk)，避免右移导致 bint 降级为 number
    while range > (bint.one() << (chunks * bits_per_chunk)) do
        chunks = chunks + 1
    end
    return chunks
end

return _M
