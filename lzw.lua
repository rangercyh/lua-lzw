local lzw = {}
local nTokenCode = 42   -- init token code

local function lzwFindFirstNormalChar(tbDeCodeToken, szCode)
    local szNormalChar = szCode
    while (tbDeCodeToken[tonumber(szNormalChar)]) do
        szNormalChar = tbDeCodeToken[tonumber(szNormalChar)][1]
    end
    return szNormalChar
end

local function lzwDecodeToSource(szSource, tbDeCodeToken, szPrefix)
    local tbPrefix = { szPrefix }
    while #tbPrefix ~= 0 do
        local szFirst = table.remove(tbPrefix, 1)
        local tbDecode = tbDeCodeToken[tonumber(szFirst)]
        if tbDecode then
            table.insert(tbPrefix, 1, tbDecode[2])
            table.insert(tbPrefix, 1, tbDecode[1])
        else
            szSource = szSource .. szFirst
        end
    end
    return szSource
end

-- compress
function lzw.deflate(szSource, nBeginCode)
    local tbOutput = {}
    local tbChar = {}
    local szPrefix = ""
    local tbToken = {}
    local nTokenCode = nBeginCode or nTokenCode
    for szChar in string.gmatch(szSource, ".") do
        tbChar[szChar] = true
        if szPrefix == "" then
            szPrefix = szChar
        else
            if tbToken[szPrefix .. szChar] then
                szPrefix = tbToken[szPrefix .. szChar]
            else
                tbToken[szPrefix .. szChar] = nTokenCode
                nTokenCode = nTokenCode + 1
                table.insert(tbOutput, szPrefix)
                szPrefix = szChar
            end
        end
    end
    if szPrefix~= "" then
        table.insert(tbOutput, szPrefix)
    end
    return tbOutput, tbChar
end

-- decompress
function lzw.inflate(tbCode, tbChar, nBeginCode)
    local szSource = ""
    local szPrefix = ""
    local tbToken = {}
    local tbDeCodeToken = {}
    local nTokenCode = nBeginCode or nTokenCode
    for _, szCode in ipairs(tbCode) do
        if szPrefix ~= "" then
            if tbChar[szCode] then  -- judge whether is a normal suffix
                tbToken[szPrefix .. szCode] = nTokenCode
                tbDeCodeToken[nTokenCode] = { szPrefix, szCode }
                nTokenCode = nTokenCode + 1
                --put prefix to output steam
                szSource = lzwDecodeToSource(szSource, tbDeCodeToken, szPrefix)
            else
                if tbDeCodeToken[tonumber(szCode)] then
                    local szSuffix = lzwFindFirstNormalChar(tbDeCodeToken, tbDeCodeToken[tonumber(szCode)][1])
                    tbToken[szPrefix .. szSuffix] = nTokenCode
                    tbDeCodeToken[nTokenCode] = { szPrefix, szSuffix }
                    nTokenCode = nTokenCode + 1
                    --put prefix to output steam
                    szSource = lzwDecodeToSource(szSource, tbDeCodeToken, szPrefix)
                else
                    if tbChar[szPrefix] then
                        tbToken[szPrefix .. szPrefix] = nTokenCode
                        tbDeCodeToken[nTokenCode] = { szPrefix, szPrefix }
                    else
                        local szSuffix = lzwFindFirstNormalChar(tbDeCodeToken, tbDeCodeToken[tonumber(szPrefix)][1])
                        tbToken[szPrefix .. szSuffix] = nTokenCode
                        tbDeCodeToken[nTokenCode] = { szPrefix, szSuffix }
                    end
                    nTokenCode = nTokenCode + 1
                    --put prefix to output steam
                    szSource = lzwDecodeToSource(szSource, tbDeCodeToken, szPrefix)
                end
            end
        end
        szPrefix = szCode
    end
    szSource = lzwDecodeToSource(szSource, tbDeCodeToken, szPrefix)
    return szSource
end

function lzw.setToken(num)
    assert(type(num) == "number")
    nTokenCode = num
end

return lzw
