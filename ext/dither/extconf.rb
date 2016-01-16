
require 'mkmf'
$CPPFLAGS += ' -std=c++0x -O3 '
create_makefile('dither')
