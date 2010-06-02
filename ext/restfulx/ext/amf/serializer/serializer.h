#ifndef _SERIALIZER_H_
#define _SERIALIZER_H_

#include <ruby.h>

extern VALUE rb_mRestfulX;
extern VALUE rb_mRestfulX_AMF;
extern VALUE rb_mRestfulX_AMF_Ext;
extern VALUE rb_cRestfulX_AMF_Ext_AMF3Serializer;

void Init_serializer();

#endif