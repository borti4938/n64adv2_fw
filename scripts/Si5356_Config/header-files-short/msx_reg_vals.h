const unsigned char msx_reg_vals[NUM_SUPPORTED_CONFIGS][NUM_VARIABLE_MSx_REGS] __ufmdata_section__  = {
  {0xD2,0x54,0x10,0x00,0x00,0x00,0x0E,0x00,0x00,
   0xD2,0x54,0x10,0x00,0x00,0x00,0x0E,0x00,0x00 },  // NTSC_N64_DIRECT
  {0x7E,0x29,0xB0,0x23,0x00,0x00,0xB6,0x1C,0x00,
   0x69,0x29,0x10,0x00,0x00,0x00,0x1C,0x00,0x00 },  // NTSC_N64_VGA
  {0x8D,0x26,0x6C,0x04,0x00,0x00,0xB9,0x01,0x00,
   0x79,0x26,0x4C,0x00,0x00,0x00,0x15,0x00,0x00 },  // NTSC_N64_480p
  {0xC2,0x0C,0xE8,0x70,0x00,0x00,0xC3,0x1E,0x00,
   0xBB,0x0C,0x2C,0x00,0x00,0x00,0x0F,0x00,0x00 },  // NTSC_N64_720p
  {0xD6,0x0A,0x40,0x8E,0x00,0x00,0x68,0x25,0x00,
   0xD0,0x0A,0x00,0x0A,0x00,0x00,0x90,0x03,0x00 },  // NTSC_N64_960p
  {0x61,0x05,0x74,0x38,0x00,0x00,0xC3,0x1E,0x00,
   0x5D,0x05,0x34,0x00,0x00,0x00,0x0F,0x00,0x00 },  // NTSC_N64_1080p
  {0x67,0x06,0xE8,0x01,0x00,0x00,0x0A,0x01,0x00,
   0x63,0x06,0x70,0x00,0x00,0x00,0x4C,0x00,0x00 },  // NTSC_N64_1200p
  {0x12,0x04,0xA8,0x0D,0x00,0x00,0x33,0x18,0x00,
   0x0F,0x04,0x2C,0x00,0x00,0x00,0x3B,0x00,0x00 },  // NTSC_N64_1440p
  {0x11,0x07,0x44,0x7C,0x00,0x00,0x7F,0x28,0x00,
   0x0D,0x07,0x58,0x10,0x00,0x00,0x92,0x0B,0x00 },  // NTSC_N64_1440Wp
  {0x83,0x56,0x6C,0x23,0x19,0x00,0x37,0x41,0x07,
   0x83,0x56,0xEC,0x88,0x82,0x00,0x17,0xAA,0x25 },  // PAL0_N64_DIRECT
  {0x54,0x2A,0x10,0xB5,0x00,0x00,0xB3,0xE5,0x02,
   0x41,0x2A,0xA4,0x98,0x8C,0x00,0x17,0xAA,0x25 },  // PAL0_N64_VGA
  {0x5A,0x27,0x78,0xE8,0x00,0x00,0x55,0xD7,0x00,
   0x49,0x27,0x90,0x7E,0x0E,0x00,0xFC,0x17,0x0A },  // PAL0_N64_576p
  {0x09,0x0D,0x0C,0xDC,0x01,0x00,0x55,0xD7,0x00,
   0x03,0x0D,0x0C,0x12,0x04,0x00,0xFF,0x85,0x02 },  // PAL0_N64_720p
  {0x14,0x0B,0xC0,0x0A,0x00,0x00,0xE4,0x06,0x00,
   0x0F,0x0B,0x80,0x48,0x1A,0x00,0xA0,0x8F,0x9F },  // PAL0_N64_960p
  {0x84,0x05,0xB0,0x9C,0x02,0x00,0x55,0xD7,0x00,
   0x81,0x05,0x08,0x2A,0x0E,0x00,0xFE,0x0B,0x05 },  // PAL0_N64_1080p
  {0x8F,0x06,0x84,0x00,0x00,0x00,0x31,0x00,0x00,
   0x8C,0x06,0x80,0x0E,0x03,0x00,0xA8,0x6E,0x04 },  // PAL0_N64_1200p
  {0x2F,0x04,0x14,0x97,0x08,0x00,0xB5,0x3F,0x0B,
   0x2C,0x04,0x60,0xAF,0xB2,0x00,0x3E,0x7E,0x43 },  // PAL0_N64_1440p
  {0x3D,0x07,0x6C,0x73,0x0C,0x00,0x09,0xD3,0x12,
   0x39,0x07,0xD0,0xD1,0x5D,0x01,0x6C,0xE4,0xE1 },  // PAL0_N64_1440Wp
  {0x83,0x56,0x7C,0x64,0x4F,0x01,0xCB,0x4F,0x5E,
   0x83,0x56,0xEC,0xF8,0x85,0x00,0x17,0xAA,0x25 },  // PAL1_N64_DIRECT
  {0x54,0x2A,0xD0,0xE9,0x0A,0x00,0x17,0xAA,0x25,
   0x41,0x2A,0xA4,0x50,0x8E,0x00,0x17,0xAA,0x25 },  // PAL1_N64_VGA
  {0x5A,0x27,0xA0,0x53,0x0B,0x00,0xFC,0x17,0x0A,
   0x49,0x27,0x24,0xBB,0x03,0x00,0xFF,0x85,0x02 },  // PAL1_N64_576p
  {0x09,0x0D,0x24,0x9E,0x05,0x00,0xFF,0x85,0x02,
   0x03,0x0D,0x0C,0x1C,0x04,0x00,0xFF,0x85,0x02 },  // PAL1_N64_720p
  {0x14,0x0B,0x00,0x14,0xFB,0x00,0xA0,0x8F,0x9F,
   0x0F,0x0B,0xA0,0x1B,0x07,0x00,0xE8,0xE3,0x27 },  // PAL1_N64_960p
  {0x84,0x05,0x20,0xB6,0x0F,0x00,0xFE,0x0B,0x05,
   0x81,0x05,0x04,0x1A,0x07,0x00,0xFF,0x85,0x02 },  // PAL1_N64_1080p
  {0x8F,0x06,0xA0,0xFA,0x0B,0x00,0xA8,0x6E,0x04,
   0x8C,0x06,0x20,0xC6,0x00,0x00,0xAA,0x1B,0x01 },  // PAL1_N64_1200p
  {0x2F,0x04,0x78,0xF8,0x33,0x00,0x3E,0x7E,0x43,
   0x2C,0x04,0xB0,0x8E,0x59,0x00,0x1F,0xBF,0x21 },  // PAL1_N64_1440p
  {0x3D,0x07,0x10,0x8F,0x97,0x00,0x6C,0xE4,0xE1,
   0x39,0x07,0xF4,0xFD,0x57,0x00,0x1B,0x79,0x38 },  // PAL1_N64_1440Wp
  {0x00,0x2A,0x00,0x00,0x00,0x00,0x01,0x00,0x00,
   0xB3,0x26,0x14,0x08,0x00,0x00,0x99,0x09,0x00 },  // FREE_VGA60_480p
  {0xAC,0x29,0xF0,0x00,0x00,0x00,0x93,0x01,0x00,
   0xBD,0x26,0x44,0x00,0x00,0x00,0x1B,0x00,0x00 },  // FREE_VGA50_576p
  {0xD0,0x0C,0x40,0x00,0x00,0x00,0x1B,0x00,0x00,
   0xE2,0x0A,0x18,0x58,0x00,0x00,0x0D,0x1A,0x00 },  // FREE_720p_960p
  {0x68,0x05,0x20,0x00,0x00,0x00,0x1B,0x00,0x00,
   0x6F,0x06,0xD4,0x02,0x00,0x00,0xE5,0x02,0x00 },  // FREE_1080p_1200p
  {0x17,0x04,0xEC,0x6B,0x00,0x00,0x43,0x23,0x00,
   0x1A,0x07,0x88,0xC7,0x00,0x00,0x0B,0x27,0x01 }   // FREE_1440p
};