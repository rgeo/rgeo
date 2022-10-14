/*
        Utilities for the ruby CAPI
*/

#ifndef RGEO_GEOS_RUBY_MORE_INCLUDED
#define RGEO_GEOS_RUBY_MORE_INCLUDED

#include "ruby_more.h"

#include <ruby.h>

#include "preface.h"

RGEO_BEGIN_C

struct funcall_args
{
  VALUE recv;
  ID mid;
  int argc;
  VALUE* argv;
};

static VALUE
inner_funcall(VALUE args_)
{
  struct funcall_args* args = (struct funcall_args*)args_;
  return rb_funcallv(args->recv, args->mid, args->argc, args->argv);
}

VALUE
rb_protect_funcall(VALUE recv, ID mid, int* state, int n, ...)
{
  struct funcall_args args;
  VALUE* argv;
  VALUE result;
  va_list ar;

  if (n > 0) {
    long i;
    va_start(ar, n);
    argv = RB_ALLOC_N(VALUE, n);
    for (i = 0; i < n; i++) {
      argv[i] = va_arg(ar, VALUE);
    }
    va_end(ar);
  } else {
    argv = 0;
  }

  args.recv = recv;
  args.mid = mid;
  args.argc = n;
  args.argv = argv;

  result = rb_protect(inner_funcall, (VALUE)&args, state);

  if (n > 0)
    RB_FREE(argv);

  return result;
}

RGEO_END_C

#endif
