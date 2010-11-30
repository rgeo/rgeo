/*
  -----------------------------------------------------------------------------
  
  Main initializer for Proj4 wrapper
  
  -----------------------------------------------------------------------------
  Copyright 2010 Daniel Azuma
  
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of the copyright holder, nor the names of any other
    contributors to this software, may be used to endorse or promote products
    derived from this software without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
  -----------------------------------------------------------------------------
*/


#ifdef HAVE_PROJ_API_H
#ifdef HAVE_PJ_INIT_PLUS
#define RGEO_PROJ4_SUPPORTED
#endif
#endif

#ifdef __cplusplus
#define RGEO_BEGIN_C extern "C" {
#define RGEO_END_C }
#else
#define RGEO_BEGIN_C
#define RGEO_END_C
#endif


#ifdef RGEO_PROJ4_SUPPORTED

#include <ruby.h>
#include <proj_api.h>

#endif


RGEO_BEGIN_C


#ifdef RGEO_PROJ4_SUPPORTED


typedef struct {
  projPJ pj;
  VALUE original_str;
} RGeo_Proj4Data;


#define RGEO_PROJ4_DATA_PTR(obj) ((RGeo_Proj4Data*)DATA_PTR(obj))


// Destroy function for proj data.

static void destroy_proj4_func(RGeo_Proj4Data* data)
{
  if (data->pj) {
    pj_free(data->pj);
  }
  free(data);
}


static void mark_proj4_func(RGeo_Proj4Data* data)
{
  if (!NIL_P(data->original_str)) {
    rb_gc_mark(data->original_str);
  }
}


static VALUE alloc_proj4(VALUE klass)
{
  VALUE result = Qnil;
  RGeo_Proj4Data* data = ALLOC(RGeo_Proj4Data);
  if (data) {
    data->pj = NULL;
    data->original_str = Qnil;
    result = Data_Wrap_Struct(klass, mark_proj4_func, destroy_proj4_func, data);
  }
  return result;
}


static VALUE method_proj4_initialize_copy(VALUE self, VALUE orig)
{
  // Clear out any existing value
  projPJ pj = RGEO_PROJ4_DATA_PTR(self)->pj;
  if (pj) {
    pj_free(pj);
    RGEO_PROJ4_DATA_PTR(self)->pj = NULL;
    RGEO_PROJ4_DATA_PTR(self)->original_str = Qnil;
  }
  
  // Copy value from orig
  RGEO_PROJ4_DATA_PTR(self)->pj = RGEO_PROJ4_DATA_PTR(orig)->pj;
  RGEO_PROJ4_DATA_PTR(self)->original_str = RGEO_PROJ4_DATA_PTR(orig)->original_str;
  
  return self;
}


static VALUE method_proj4_get_geographic(VALUE self)
{
  VALUE result = Qnil;
  RGeo_Proj4Data* data = ALLOC(RGeo_Proj4Data);
  if (data) {
    data->pj = pj_latlong_from_proj(RGEO_PROJ4_DATA_PTR(self)->pj);
    data->original_str = Qnil;
    result = Data_Wrap_Struct(CLASS_OF(self), mark_proj4_func, destroy_proj4_func, data);
  }
  return result;
}


static VALUE method_proj4_original_str(VALUE self)
{
  return RGEO_PROJ4_DATA_PTR(self)->original_str;
}


static VALUE method_proj4_canonical_str(VALUE self)
{
  VALUE result = Qnil;
  projPJ pj = RGEO_PROJ4_DATA_PTR(self)->pj;
  if (pj) {
    char* str = pj_get_def(pj, 0);
    if (str) {
      result = rb_str_new2(str);
      pj_dalloc(str);
    }
  }
  return result;
}


static VALUE method_proj4_is_geographic(VALUE self)
{
  VALUE result = Qnil;
  projPJ pj = RGEO_PROJ4_DATA_PTR(self)->pj;
  if (pj) {
    result = pj_is_latlong(pj) ? Qtrue : Qfalse;
  }
  return result;
}


static VALUE method_proj4_is_geocentric(VALUE self)
{
  VALUE result = Qnil;
  projPJ pj = RGEO_PROJ4_DATA_PTR(self)->pj;
  if (pj) {
    result = pj_is_geocent(pj) ? Qtrue : Qfalse;
  }
  return result;
}


static VALUE method_proj4_is_valid(VALUE self)
{
  return RGEO_PROJ4_DATA_PTR(self)->pj ? Qtrue : Qfalse;
}


static VALUE cmethod_proj4_transform(VALUE method, VALUE from, VALUE to, VALUE x, VALUE y, VALUE z)
{
  VALUE result = Qnil;
  projPJ from_pj = RGEO_PROJ4_DATA_PTR(from)->pj;
  projPJ to_pj = RGEO_PROJ4_DATA_PTR(to)->pj;
  if (from_pj && to_pj) {
    double xval = rb_num2dbl(x);
    double yval = rb_num2dbl(y);
    double zval = 0.0;
    if (!NIL_P(z)) {
      zval = rb_num2dbl(z);
    }
    int err = pj_transform(from_pj, to_pj, 1, 1, &xval, &yval, NIL_P(z) ? NULL : &zval);
    if (!err && xval != HUGE_VAL && yval != HUGE_VAL && (NIL_P(z) || zval != HUGE_VAL)) {
      result = rb_ary_new2(NIL_P(z) ? 2 : 3);
      rb_ary_push(result, rb_float_new(xval));
      rb_ary_push(result, rb_float_new(yval));
      if (!NIL_P(z)) {
        rb_ary_push(result, rb_float_new(zval));
      }
    }
  }
  return result;
}


static VALUE cmethod_proj4_create(VALUE klass, VALUE str)
{
  VALUE result = Qnil;
  Check_Type(str, T_STRING);
  RGeo_Proj4Data* data = ALLOC(RGeo_Proj4Data);
  if (data) {
    data->pj = pj_init_plus(RSTRING_PTR(str));
    data->original_str = str;
    result = Data_Wrap_Struct(klass, mark_proj4_func, destroy_proj4_func, data);
  }
  return result;
}


static void rgeo_init_proj4()
{
  VALUE rgeo_module = rb_define_module("RGeo");
  VALUE coordsys_module = rb_define_module_under(rgeo_module, "CoordSys");
  VALUE proj4_class = rb_define_class_under(coordsys_module, "Proj4", rb_cObject);
  rb_define_module_function(proj4_class, "_create", cmethod_proj4_create, 1);
  rb_define_method(proj4_class, "initialize_copy", method_proj4_initialize_copy, 1);
  rb_define_method(proj4_class, "_original_str", method_proj4_original_str, 0);
  rb_define_method(proj4_class, "_canonical_str", method_proj4_canonical_str, 0);
  rb_define_method(proj4_class, "_valid?", method_proj4_is_valid, 0);
  rb_define_method(proj4_class, "_geographic?", method_proj4_is_geographic, 0);
  rb_define_method(proj4_class, "_geocentric?", method_proj4_is_geocentric, 0);
  rb_define_method(proj4_class, "_get_geographic", method_proj4_get_geographic, 0);
  rb_define_module_function(proj4_class, "_transform_coords", cmethod_proj4_transform, 5);
}


#endif


void Init_proj4_c_impl()
{
#ifdef RGEO_PROJ4_SUPPORTED
  rgeo_init_proj4();
#endif
}


RGEO_END_C
