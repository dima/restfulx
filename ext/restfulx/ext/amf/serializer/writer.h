#include "ruby.h"

typedef struct {
  u_char *buffer;
  u_char *cursor;
  size_t allocated;
} emitter_t;

static inline void emitter_initialize(emitter_t *emitter) {
  emitter->buffer = ALLOC_N(u_char, 256);
  emitter->cursor = emitter->buffer;
  emitter->allocated = 256;
}

static inline void emitter_finalize(emitter_t *emitter) {
  free(emitter->buffer);
  emitter->buffer = 0;
  emitter->cursor = 0;
  emitter->allocated = 0;
}

static inline size_t emitter_buffer_size(emitter_t *emitter) {
  return emitter->cursor - emitter->buffer;
}

static inline int emitter_grow_buffer(emitter_t *emitter, size_t size) {
  size_t current_offset = emitter_buffer_size(emitter);
  size_t new_size = current_offset + size;
  size_t current_size = emitter->allocated;
  
  while (new_size > current_size) {
    current_size *= 2;
  }
  
  if (current_size > emitter->allocated) {
    emitter->buffer = REALLOC_N(emitter->buffer, u_char, current_size);
    if (!emitter->buffer) {
      rb_raise(rb_eNoMemError, "failed to allocate memory for buffer");
      return -1;
    }
    emitter->cursor = emitter->buffer + current_offset;
    emitter->allocated = current_size;
  }
  
  return 0;
}

static inline void emitter_write_bytes(emitter_t *emitter, u_char *bytes, size_t len) {
  if (emitter_grow_buffer(emitter, len) != -1) {
    MEMCPY(emitter->cursor, bytes, u_char, len);
    emitter->cursor += len; 
  }
}

static inline void emitter_write_byte(emitter_t *emitter, u_char byte) {
  if (emitter_grow_buffer(emitter, 1) != -1) {
    emitter->cursor[0] = byte;
    emitter->cursor++; 
  }
}

static inline VALUE emitter_to_rstring(emitter_t *emitter) {
  return rb_str_new((char*)emitter->buffer, emitter_buffer_size(emitter));
}
