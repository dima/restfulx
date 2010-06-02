#ifndef _SERIALIZER_H_
#define _SERIALIZER_H_

#include <ruby.h>

extern VALUE rb_mRestfulX;
extern VALUE rb_mRestfulX_AMF;
extern VALUE rb_mRestfulX_AMF_Ext;
extern VALUE rb_cRestfulX_AMF_Ext_AMF3Serializer;

static VALUE t_init(VALUE self);
static VALUE t_version(VALUE self);
static VALUE t_to_s(VALUE self);
static VALUE t_foobar(VALUE self);

void Init_serializer();

#endif