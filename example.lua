local lzw = require "lzw"

--[[string test]]
print('1.######### string test')
local szSource = "dsfakfjljsds  sdf "
local nBeginCode = 6
print("szSource = ", szSource)
local tbCode, tbChar = lzw.deflate(szSource, nBeginCode)
print('tbCode, tbChar = ', tbCode, tbChar)
print(lzw.inflate(tbCode, tbChar, nBeginCode))

--[[file test]]
print('2.######### file test')
local hFile = io.open("source", "r")
local szStr = hFile:read("*a")
hFile:close()
print("origin length = ", string.len(szStr))
local tbCode, tbChar = lzw.deflate(szStr, nBeginCode)
local hOutputFile = io.open("deflate", "w")
hOutputFile:write(table.concat(tbCode, ","))
hOutputFile:close()
print("deflate length = ", #tbCode)
local hDecodeFile = io.open("inflate", "w")
hDecodeFile:write(lzw.inflate(tbCode, tbChar, nBeginCode))
hDecodeFile:close()

--[[token test]]
print('3.######### token test')
local szSource = "fasdfasdujof"
print("szSource = ", szSource)
local tbCode, tbChar = lzw.deflate(szSource)
print('tbCode, tbChar = ', tbCode, tbChar)
print(lzw.inflate(tbCode, tbChar))

lzw.setToken(345)
print(lzw.inflate(lzw.deflate(szSource)))
