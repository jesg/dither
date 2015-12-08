
require 'mkmf'
$CPPFLAGS += ' -std=c++11 -O3 '
create_makefile('dither')
