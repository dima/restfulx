module RestfulX::AMF
  # AMF0 Type Markers
  AMF0_NUMBER_MARKER       = 0x00 #"\000"
  AMF0_BOOLEAN_MARKER      = 0x01 #"\001"
  AMF0_STRING_MARKER       = 0x02 #"\002"
  AMF0_OBJECT_MARKER       = 0x03 #"\003"
  AMF0_MOVIE_CLIP_MARKER   = 0x04 #"\004" # Unused
  AMF0_NULL_MARKER         = 0x05 #"\005"
  AMF0_UNDEFINED_MARKER    = 0x06 #"\006"
  AMF0_REFERENCE_MARKER    = 0x07 #"\a"
  AMF0_HASH_MARKER         = 0x08 #"\b"
  AMF0_OBJECT_END_MARKER   = 0x09 #"\t"
  AMF0_STRICT_ARRAY_MARKER = 0x0A #"\n"
  AMF0_DATE_MARKER         = 0x0B #"\v"
  AMF0_LONG_STRING_MARKER  = 0x0C #"\f"
  AMF0_UNSUPPORTED_MARKER  = 0x0D #"\r"
  AMF0_RECORDSET_MARKER    = 0x0E #"\016" # Unused
  AMF0_XML_MARKER          = 0x0F #"\017"
  AMF0_TYPED_OBJECT_MARKER = 0x10 #"\020"
  AMF0_AMF3_MARKER         = 0x11 #"\021"

  # AMF3 Type Markers
  AMF3_UNDEFINED_MARKER    =  0x00 #"\000"
  AMF3_NULL_MARKER         =  0x01 #"\001"
  AMF3_FALSE_MARKER        =  0x02 #"\002"
  AMF3_TRUE_MARKER         =  0x03 #"\003"
  AMF3_INTEGER_MARKER      =  0x04 #"\004"
  AMF3_DOUBLE_MARKER       =  0x05 #"\005"
  AMF3_STRING_MARKER       =  0x06 #"\006"
  AMF3_XML_DOC_MARKER      =  0x07 #"\a"
  AMF3_DATE_MARKER         =  0x08 #"\b"
  AMF3_ARRAY_MARKER        =  0x09 #"\t"
  AMF3_OBJECT_MARKER       =  0x0A #"\n"
  AMF3_XML_MARKER          =  0x0B #"\v"
  AMF3_BYTE_ARRAY_MARKER   =  0x0C #"\f"

  # Other AMF3 Markers
  AMF3_EMPTY_STRING             = 0x01
  AMF3_ANONYMOUS_OBJECT         = 0x01
  AMF3_DYNAMIC_OBJECT           = 0x0B
  AMF3_CLOSE_DYNAMIC_OBJECT     = 0x01
  AMF3_CLOSE_DYNAMIC_ARRAY      = 0x01

  # Other Constants
  MAX_INTEGER               = 268435455
  MIN_INTEGER               = -268435456
end