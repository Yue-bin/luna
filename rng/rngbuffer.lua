--- 随机数缓冲区，应当从这里读取数据
--- 由于该缓冲区只是为了避免熵池被过度访问，所以事实上只需要保证下一个可读，而写入可以比较随意
--- 同时并非字节级，而是按chunk
--- 应当保证随时有一半以上的chunk可读，于是设置低水位线为size//2
--- 本质队列，从头写从尾读，保证读取开销最小
--- @class RngBuffer
--- @field private size integer 缓冲区的大小(chunk数)
--- @field private chunk_size integer 缓冲区中每个chunk的大小(字节)
--- @field private buffer table 缓冲区本身
--- @field private low_watermark integer 缓冲区的低水位线，当可读chunk数量小于该值时需要填充
--- @field private dev file* 默认为"/dev/urandom"
local _M = {}

local log = require("lapis.logging")

--- 读取n个chunk
--- @public
--- @param n? integer 需要读取的chunk数量
--- @return string 读取到的数据
function _M:read(n)
    n = n or 1
    if n > self.size then
        error("Rng buffer: requested chunks exceed buffer size")
    end
    local chunks = {}
    if #self.buffer < n then
        log.notice("Rng buffer is low, filling...")
        self:fill_to_full() -- 不够读完，直接填充缓冲区
    end
    while #chunks < n do
        table.insert(chunks, self.buffer[#self.buffer])
        table.remove(self.buffer)
    end
    -- 如果低于低水位线时，需要填充
    if #self.buffer < self.low_watermark then
        log.notice("Rng buffer is below low watermark, filling...")
        self:fill_to_full()
    end
    return table.concat(chunks)
end

--- 向队列头部写入单个chunk
--- @private
--- @param chunk string 需要写入的chunk
--- @return boolean fullfilled 是否填满
function _M:write(chunk)
    table.insert(self.buffer, 1, chunk)
    return #self.buffer == self.size
end

--- 从rngdev读取512字节并写入缓冲区，如果填满则提前停止
--- @private
--- @return boolean fullfilled 是否填满
function _M:fill()
    -- 这里为了跟usb层对接硬编码为一次读取512字节的chunk，随后切分
    local chunk = self.dev:read(512)
    --- @cast chunk string
    if not chunk then
        error("Rng buffer: device read failed")
    end
    local filled_chunks = 0
    local fullfilled = false
    for i = 1, #chunk, self.chunk_size do
        -- 保证最后一个写入的chunk是完整的
        if i + self.chunk_size - 1 <= #chunk then
            filled_chunks = filled_chunks + 1
            if self:write(chunk:sub(i, i + self.chunk_size - 1)) then
                log.notice("Rng buffer is full, stopping")
                fullfilled = true
                break
            end
        end
    end
    log.notice("Filled " .. filled_chunks .. " chunks")
    return fullfilled
end

--- 填充到满
--- @package
function _M:fill_to_full()
    while not self:fill() do end
end

--- 创建一个缓冲区
--- @param size integer 缓冲区的大小(chunk数)
--- @param chunk_size integer 缓冲区中每个chunk的大小(字节)
--- @param dev_path? string 要打开的设备文件，默认为"/dev/urandom"
--- @return RngBuffer 创建的缓冲区实例
local function new(size, chunk_size, dev_path)
    dev_path = dev_path or "/dev/urandom"
    local dev = io.open(dev_path, "rb")
    if not dev then
        error("Failed to open device: " .. dev_path)
    end
    local new_ring = setmetatable({
            size = size,
            chunk_size = chunk_size,
            buffer = {},
            dev = dev,
            low_watermark = size // 2
        },
        { __index = _M }
    )
    log.notice("Warming up rng buffer with " .. dev_path)
    new_ring:fill_to_full()
    return new_ring
end

return {
    new = new
}
