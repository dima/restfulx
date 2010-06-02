#include "serializer.h"
#include "writeio_helpers.h"

// AMF3 Type Markers
#define AMF3_UNDEFINED_MARKER  0x00 //"\000"
#define AMF3_NULL_MARKER       0x01 //"\001"
#define AMF3_FALSE_MARKER      0x02 //"\002"
#define AMF3_TRUE_MARKER       0x03 //"\003"
#define AMF3_INTEGER_MARKER    0x04 //"\004"
#define AMF3_DOUBLE_MARKER     0x05 //"\005"
#define AMF3_STRING_MARKER     0x06 //"\006"
#define AMF3_XML_DOC_MARKER    0x07 //"\a"
#define AMF3_DATE_MARKER       0x08 //"\b"
#define AMF3_ARRAY_MARKER      0x09 //"\t"
#define AMF3_OBJECT_MARKER     0x0A //"\n"
#define AMF3_XML_MARKER        0x0B //"\v"
#define AMF3_BYTE_ARRAY_MARKER 0x0C //"\f"

// Other AMF3 Markers
#define AMF3_EMPTY_STRING         0x01
#define AMF3_ANONYMOUS_OBJECT     0x01
#define AMF3_DYNAMIC_OBJECT       0x0B
#define AMF3_CLOSE_DYNAMIC_OBJECT 0x01
#define AMF3_CLOSE_DYNAMIC_ARRAY  0x01
  
#define MAX_AMF3_INTEGER  268435455
#define MIN_AMF3_INTEGER -268435456

VALUE rb_mRestfulX = Qnil;
VALUE rb_mRestfulX_AMF = Qnil;
VALUE rb_mRestfulX_AMF_Ext = Qnil;
VALUE rb_cRestfulX_AMF_Ext_AMF3Serializer = Qnil;

static VALUE t_init(VALUE self);
static VALUE t_version(VALUE self);
static VALUE t_stream(VALUE self);
static VALUE t_object_cache(VALUE self);
static VALUE t_string_cache(VALUE self);
static VALUE t_to_s(VALUE self);
static VALUE t_serialize_property(VALUE self, VALUE prop);
static VALUE t_foobar(VALUE self);

void Init_serializer() {
  rb_mRestfulX = rb_define_module("RestfulX");
  rb_mRestfulX_AMF = rb_define_module_under(rb_mRestfulX, "AMF");
  rb_mRestfulX_AMF_Ext = rb_define_module_under(rb_mRestfulX_AMF, "Ext");
  rb_cRestfulX_AMF_Ext_AMF3Serializer = rb_define_class_under(rb_mRestfulX_AMF_Ext, "AMF3Serializer", rb_cObject);
  rb_define_method(rb_cRestfulX_AMF_Ext_AMF3Serializer, "initialize", t_init, 0);
  rb_define_method(rb_cRestfulX_AMF_Ext_AMF3Serializer, "version", t_version, 0);
  rb_define_method(rb_cRestfulX_AMF_Ext_AMF3Serializer, "stream", t_stream, 0);
  rb_define_method(rb_cRestfulX_AMF_Ext_AMF3Serializer, "object_cache", t_object_cache, 0);
  rb_define_method(rb_cRestfulX_AMF_Ext_AMF3Serializer, "string_cache", t_string_cache, 0);
  rb_define_method(rb_cRestfulX_AMF_Ext_AMF3Serializer, "to_s", t_to_s, 0);
  rb_define_method(rb_cRestfulX_AMF_Ext_AMF3Serializer, "serialize_property", t_serialize_property, 1);
  rb_define_method(rb_cRestfulX_AMF_Ext_AMF3Serializer, "foobar", t_foobar, 0);
}

static VALUE t_init(VALUE self) {
  rb_iv_set(self, "@stream", rb_str_new2(""));
  rb_iv_set(self, "@object_cache", rb_funcall3(rb_const_get(rb_mRestfulX_AMF, rb_intern("SerializerCache")), rb_intern("new"), 0, 0));
  rb_iv_set(self, "@string_cache", rb_funcall3(rb_const_get(rb_mRestfulX_AMF, rb_intern("SerializerCache")), rb_intern("new"), 0, 0));
}

static VALUE t_stream(VALUE self) {
  return rb_iv_get(self, "@stream");
}

static VALUE t_object_cache(VALUE self) {
  return rb_iv_get(self, "@object_cache");
}

static VALUE t_string_cache(VALUE self) {
  return rb_iv_get(self, "@string_cache");
}

static VALUE t_version(VALUE self) {
	return INT2NUM(3);
}

static VALUE t_to_s(VALUE self) {
  return rb_iv_get(self, "@stream");
}

static VALUE t_serialize_property(VALUE self, VALUE prop) {
  VALUE stream = rb_iv_get(self, "@stream");
  char c;
  
  if (TYPE(prop) == T_NIL) {
    c = AMF3_NULL_MARKER;
    stream = rb_str_cat(stream, &c, 1);
  } else if (TYPE(prop) == T_TRUE) {
    c = AMF3_TRUE_MARKER;
    stream = rb_str_cat(stream, &c, 1);
  } else if (TYPE(prop) == T_FALSE) {
    c = AMF3_FALSE_MARKER;
    stream = rb_str_cat(stream, &c, 1);
  }
  
  return stream;
}

static VALUE t_foobar(VALUE self) {
  return rb_str_new2("foobar");
}