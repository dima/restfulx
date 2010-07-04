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

static inline void emitter_grow_buffer(emitter_t *emitter, size_t size) {
  size_t buffer_size = emitter_buffer_size(emitter) + size;
  if (emitter->allocated < buffer_size) {
    size_t new_allocation = emitter->allocated;
    while (emitter->allocated < buffer_size)
      new_allocation = new_allocation * 2;
    emitter->buffer = REALLOC_N(emitter->buffer, u_char, new_allocation);
    emitter->allocated = new_allocation;
  }
}

static inline void emitter_write_byte(emitter_t *emitter, u_char byte) {
  emitter_grow_buffer(emitter, 1);
  emitter->cursor[0] = byte;
  emitter->cursor++;
}

static inline void emitter_write_bytes(emitter_t *emitter, u_char *bytes, size_t len) {
  emitter_grow_buffer(emitter, len);
  MEMCPY(emitter->cursor, bytes, u_char, len);
  emitter->cursor += len;
}

static inline VALUE emitter_to_rstring(emitter_t *emitter) {
  return rb_str_new((char*)emitter->buffer, emitter_buffer_size(emitter));
}
