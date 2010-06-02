#ifndef __WRITEIO_HELPERS__
#define __WRITEIO_HELPERS__

#include <ruby.h>
#include <stdint.h>
#include "writer.h"

static inline void emmit_c_integer(emitter_t * emitter, int32_t integer) {
  integer = integer & 0x1fffffff;
  if (integer < 0x80) {
    emitter_write_byte(emitter, integer);
  } else if (integer < 0x4000) {
    emitter_write_byte(emitter, ((integer >> 7) & 0x7f) | 0x80);
    emitter_write_byte(emitter, integer & 0x7f);
  } else if (integer < 0x200000) {
    emitter_write_byte(emitter, ((integer >> 14) & 0x7f) | 0x80);
    emitter_write_byte(emitter, ((integer >>  7) & 0x7f) | 0x80);
    emitter_write_byte(emitter, integer & 0x7f);
  } else {
    emitter_write_byte(emitter, ((integer >> 22) & 0x7f) | 0x80);
    emitter_write_byte(emitter, ((integer >> 15) & 0x7f) | 0x80);
    emitter_write_byte(emitter, ((integer >>  8) & 0x7f) | 0x80);
    emitter_write_byte(emitter, integer & 0xff);
  }
}

static inline void emmit_c_double(emitter_t * emitter, double num) {
  union aligned {
    double dval;
    char cval[8];
  } d;
  
  const char * number = d.cval;
  d.dval = num;
  u_char buffer[8];
  
  if (BIG_ENDIAN) {
    buffer[0] = number[7];
    buffer[1] = number[6];
    buffer[2] = number[5];
    buffer[3] = number[4];
    buffer[4] = number[3];
    buffer[5] = number[2];
    buffer[6] = number[1];
    buffer[7] = number[0];
  } else {
    buffer[0] = number[0];
    buffer[1] = number[1];
    buffer[2] = number[2];
    buffer[3] = number[3];
    buffer[4] = number[4];
    buffer[5] = number[5];
    buffer[6] = number[6];
    buffer[7] = number[7];
  }
  
  emitter_write_bytes(emitter, buffer, 8);
}

static inline void emmit_c_int8(emitter_t * emitter, int8_t object) {
  emitter_write_byte(emitter, object);
}

static inline void emmit_c_int16_network(emitter_t * emitter, int16_t object) {
  union aligned {
    uint16_t ival;
    u_char cval[2];
  } d;
  
  const char * number = d.cval;
  d.ival = object;
  u_char buffer[2];
  
  if (LITTLE_ENDIAN) {
    buffer[0] = d.cval[1];
    buffer[1] = d.cval[0];
  } else {
    buffer[0] = d.cval[0];
    buffer[1] = d.cval[1];
  }
  
  emitter_write_bytes(emitter, buffer, 2);
}

static inline void emmit_c_word32_network(emitter_t * emitter, uint32_t object) {
  union aligned {
    uint32_t ival;
    u_char cval[4];
  } d;
  
  const char * number = d.cval;
  d.ival = object;
  u_char buffer[4];
  
  if (LITTLE_ENDIAN) {
    buffer[0] = d.cval[3];
    buffer[1] = d.cval[2];
    buffer[2] = d.cval[1];
    buffer[3] = d.cval[0];
  } else {
    buffer[0] = d.cval[0];
    buffer[1] = d.cval[1];
    buffer[2] = d.cval[2];
    buffer[3] = d.cval[3];
  }
  
  emitter_write_bytes(emitter, buffer, 4);
}

#define EMITTER_START(n) emitter_t n; emitter_initialize(& n );
#define EMITTER_STOP(n) VALUE string = emitter_to_rstring(& n ); emitter_finalize(& n ); return string;
#define PACK(n, a ...) EMITTER_START(n) { a } EMITTER_STOP(n)

static inline VALUE rb_pack_c_integer(int32_t object) {
  PACK(e,
    emmit_c_integer(&e, object);
  )
}

static inline VALUE rb_pack_c_double(double object) {
  PACK(e,
    emmit_c_double(&e, object);
  )
}

static inline VALUE rb_pack_c_int8(int8_t object) {
  PACK(e,
    emmit_c_int8(&e, object);
  )
}

static inline VALUE rb_pack_c_int16_network(int16_t object) {
  PACK(e,
    emmit_c_int16_network(&e, object);
  )
}

static inline VALUE rb_pack_c_word32_network(uint32_t object) {
  PACK(e,
    emmit_c_word32_network(&e, object);
  )
}

#endif