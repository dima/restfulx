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

#define CUSTOM_TYPE(self, type) GET_STATE(self); emitter_write_byte(&state->emitter, AMF3_OBJECT_MARKER); emitter_write_byte(&state->emitter, AMF3_XML_DOC_MARKER); t_write_vr(self, rb_str_new2(type));

static VALUE mRestfulX, mRestfulX_AMF, mRestfulX_AMF_Ext, cRxAMFSerializer, cState;

static VALUE t_write_reference(VALUE self, VALUE index);
static VALUE t_write_vr(VALUE self, VALUE prop);
static VALUE t_write_hash(VALUE self, VALUE prop);
static VALUE t_write_hash_attrs(VALUE pair, VALUE self);
static VALUE t_write_array_elm(VALUE elm, VALUE options, VALUE self);
static VALUE t_serialize_records(VALUE records, VALUE options, VALUE block, VALUE self);
static VALUE t_serialize_property(VALUE self, VALUE prop);

static ID i_to_s, i_attributes, i_to_amf;

typedef struct {
  emitter_t emitter;
  
  VALUE string_cache;
  VALUE object_cache;
  
  u_int  string_cache_count;
  u_int  object_cache_count;
} amf_state_t;

#define GET_STATE(self)                       \
    amf_state_t *state;              \
    Data_Get_Struct(self, amf_state_t, state);

static void state_gc(amf_state_t *state) {
  rb_gc_mark_maybe(state->string_cache);
  rb_gc_mark_maybe(state->object_cache);
  EMITTER_STOP(&state->emitter);
  free(&state->emitter);
}

static VALUE t_allocate(VALUE klass) {
  amf_state_t *state = ALLOC(amf_state_t);
  return Data_Wrap_Struct(klass, state_gc, -1, state);
}

static VALUE t_initialize(int argc, VALUE *argv, VALUE self) {
  GET_STATE(self);
  EMITTER_START(&state->emitter);
  state->string_cache = rb_hash_new();
  state->object_cache = rb_hash_new();
  state->string_cache_count = 0;
  state->object_cache_count = 0;
  
  return self;
}

static VALUE t_version(VALUE self) {
	return INT2FIX(3);
}

static VALUE t_to_s(VALUE self) {
  GET_STATE(self);
  EMITTER_RSTRING(&state->emitter);
}


static VALUE t_write_reference(VALUE self, VALUE index) {
  GET_STATE(self);
  char header = FIX2INT(index) << 1;
  emitter_write_byte(&state->emitter, header);  
  return self;
}

static VALUE t_write_vr(VALUE self, VALUE prop) {
  GET_STATE(self);
  int header;
  VALUE key;
  
  if (RSTRING(prop)->len == 0) {
    emitter_write_byte(&state->emitter, AMF3_EMPTY_STRING);
  } else {
    // check if prop is in the string cache
    key = rb_hash_aref(state->string_cache, prop);
    if (key != Qnil) {
      t_write_reference(self, key);
    } else {
      rb_hash_aset(state->string_cache, prop, INT2FIX(state->string_cache_count));
      // printf("caching string: %s, with key: %i\n", STR2CSTR(prop), state->string_cache_count);
      state->string_cache_count += 1;
      header = (u_int)RSTRING(prop)->len << 1;
      header = header | 1;
      emit_c_integer(&state->emitter, header);
      emitter_write_bytes(&state->emitter, RSTRING(prop)->ptr, RSTRING(prop)->len);
    }
  }

  return Qnil;
}

static VALUE t_write_hash(VALUE self, VALUE prop) {
  GET_STATE(self);
  VALUE key;
  
  emitter_write_byte(&state->emitter, AMF3_OBJECT_MARKER);
  key = rb_hash_aref(state->object_cache, prop);
  if (key != Qnil) {
    t_write_reference(self, key);
  } else {
    rb_hash_aset(state->object_cache, prop, INT2FIX(state->object_cache_count));
    // printf("caching string: %s, with key: %i\n", STR2CSTR(prop), state->string_cache_count);
    state->object_cache_count += 1;
    emitter_write_byte(&state->emitter, AMF3_DYNAMIC_OBJECT);
    emitter_write_byte(&state->emitter, AMF3_ANONYMOUS_OBJECT); 
    rb_iterate(rb_each, prop, t_write_hash_attrs, self);
    emitter_write_byte(&state->emitter, AMF3_CLOSE_DYNAMIC_OBJECT);
  }
  
  return Qnil;
}

static VALUE t_write_hash_attrs(VALUE pair, VALUE self) {
  VALUE key = rb_ary_entry(pair, 0);
  VALUE value = rb_ary_entry(pair, 1);

  t_write_vr(self, rb_funcall3(key, i_to_s, 0, 0));
  t_serialize_property(self, value);
  
  return Qnil;
}

static VALUE t_serialize_property(VALUE self, VALUE prop) {
  GET_STATE(self);
  u_char type;
  
  switch(TYPE(prop)) {
    case T_NIL:
      emitter_write_byte(&state->emitter, AMF3_NULL_MARKER);
      break;
    case T_TRUE:
      emitter_write_byte(&state->emitter, AMF3_TRUE_MARKER);
      break;
    case T_FALSE:
      emitter_write_byte(&state->emitter, AMF3_FALSE_MARKER);
      break;
    case T_FLOAT:
      emitter_write_byte(&state->emitter, AMF3_DOUBLE_MARKER);
      emit_c_double(&state->emitter, RFLOAT(prop)->value);
      break;
    case T_FIXNUM:
      emitter_write_byte(&state->emitter, AMF3_INTEGER_MARKER);
      emit_c_integer(&state->emitter, FIX2INT(prop));
      break;
    case T_STRING:
    case T_SYMBOL:
      emitter_write_byte(&state->emitter, AMF3_STRING_MARKER);
      t_write_vr(self, rb_funcall3(prop, i_to_s, 0, 0));
      break;
    case T_HASH:
      t_write_hash(self, prop);
      break;
    default:
      rb_raise(rb_eTypeError, "not valid value");
      break;
  }
    
  return self;
}

static VALUE t_serialize_typed_array(int argc, VALUE *argv, VALUE self) {
  VALUE records, options, block;
  rb_scan_args(argc, argv, "12", &records, &options, &block);
  
  if (options == Qnil) {
    options = rb_hash_new();
  }
  
  CUSTOM_TYPE(self, "org.restfulx.messaging.io.TypedArray");
  state->object_cache_count += 1;
  t_serialize_property(self, rb_hash_aref(options, i_attributes));
  state->object_cache_count += 1;
  t_serialize_records(records, options, block, self);
  
  return self;
}

static VALUE t_serialize_models_array(int argc, VALUE *argv, VALUE self) {
  VALUE records, options, block;
  rb_scan_args(argc, argv, "12", &records, &options, &block);
  
  if (options == Qnil) {
    options = rb_hash_new();
  }

  CUSTOM_TYPE(self, "org.restfulx.messaging.io.ModelsCollection");
  state->object_cache_count += 2;
  t_serialize_records(records, options, block, self);
  
  return self;
}

static VALUE t_serialize_records(VALUE records, VALUE options, VALUE block, VALUE self) {
  int header, i;
  VALUE elm;
  GET_STATE(self);
  emitter_write_byte(&state->emitter, AMF3_ARRAY_MARKER);
  
  header = RARRAY(records)->len << 1;
  header = header | 1;
  emit_c_integer(&state->emitter, header);
  
  emitter_write_byte(&state->emitter, AMF3_CLOSE_DYNAMIC_ARRAY);
  for (i = 0; i < RARRAY(records)->len; i++) {
    elm = RARRAY(records)->ptr[i];
    t_write_array_elm(elm, options, self);
  }

  return self;
}

static VALUE t_write_array_elm(VALUE elm, VALUE options, VALUE self) {
  if (rb_respond_to(elm, i_to_amf)) {
    // call to_amf?
  } else {
    t_serialize_property(self, elm);
  }
  
  return Qnil;
}

// FINISH UP
static VALUE t_serialize_record(int argc, VALUE *argv, VALUE self) {
  VALUE record_id, partials;
  GET_STATE(self);
  
  partials = rb_hash_new();
  
  emitter_write_byte(&state->emitter, AMF3_OBJECT_MARKER);
  
  return self;
}

static VALUE t_serialize_errors(VALUE self, VALUE prop) {
  GET_STATE(self);
  
  emitter_write_byte(&state->emitter, AMF3_OBJECT_MARKER);
  emitter_write_byte(&state->emitter, AMF3_XML_DOC_MARKER);
  t_write_vr(self, rb_str_new2("org.restfulx.messaging.io.ServiceErrors"));
  t_serialize_property(self, prop);
  emitter_write_byte(&state->emitter, AMF3_CLOSE_DYNAMIC_OBJECT);
  
  return self;
}

void Init_serializer() {
  mRestfulX = rb_define_module("RestfulX");
  mRestfulX_AMF = rb_define_module_under(mRestfulX, "AMF");
  mRestfulX_AMF_Ext = rb_define_module_under(mRestfulX_AMF, "Ext");
  cRxAMFSerializer = rb_define_class_under(mRestfulX_AMF_Ext, "RxAMFSerializer", rb_cObject);
  rb_define_alloc_func(cRxAMFSerializer, t_allocate);
  // these are the public interface
  rb_define_method(cRxAMFSerializer, "initialize", t_initialize, -1);
  rb_define_method(cRxAMFSerializer, "version", t_version, 0);
  rb_define_method(cRxAMFSerializer, "to_s", t_to_s, 0);
  rb_define_method(cRxAMFSerializer, "write_vr", t_write_vr, 1);
  rb_define_method(cRxAMFSerializer, "serialize_property", t_serialize_property, 1);
  rb_define_method(cRxAMFSerializer, "serialize_typed_array", t_serialize_typed_array, -1);
  rb_define_method(cRxAMFSerializer, "serialize_models_array", t_serialize_models_array, -1);
  rb_define_method(cRxAMFSerializer, "serialize_record", t_serialize_record, -1);
  rb_define_method(cRxAMFSerializer, "serialize_errors", t_serialize_errors, 1);
  
  i_to_s = rb_intern("to_s");
  i_to_amf = rb_intern("to_amf");
  i_attributes = rb_intern("attributes");
}