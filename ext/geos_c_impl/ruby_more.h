/*
	Utilities for the ruby CAPI
*/

#ifndef RGEO_GEOS_RUBY_MORE_INCLUDED
#define RGEO_GEOS_RUBY_MORE_INCLUDED

#include <ruby.h>

RGEO_BEGIN_C

VALUE rb_protect_funcall(VALUE recv, ID mid, int *state, int n, ...);

RGEO_END_C

#endif
