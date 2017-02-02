Description
=====
using pure lua to release lzw compress and decompress.
Using
=====
* require "lzw"
* -- compress
* local code, dict = lzw.deflate('asdf')
* -- decompress
* lzw.inflate(code, dict)

Licence
=====

[WTFPL](http://en.wikipedia.org/wiki/WTFPL) 


