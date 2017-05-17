import struct
from PIL import Image

ALPHA_T = 5

def preview(img):
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = img.getpixel((x, y))
            if a >= ALPHA_T:
                img.putpixel((x, y), (r & 0b11100000, g & 0b11100000, b & 0b11100000, 255))
            else:
                img.putpixel((x, y), (0, 0, 0, 0))
    img.show()

def get_bin(img):
    buff = b''
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = img.getpixel((x, y))
            # MSB XXXXXXRRRGGGBBBA LSB
            if a >= ALPHA_T:
                word = (((r >> 5) & 0b111) << 7) | (((g >> 5) & 0b111) << 4) | \
                       (((b >> 5) & 0b111) << 1) | 0b1
            else:
                word = 0
            buff += struct.pack('<H', word)
    assert(len(buff) == 2 * w * h)
    if len(buff) % 4 != 0:
        assert(len(buff) % 4 == 2)
        buff += struct.pack('<H', 0)
        print('Warning: padding 4')
    return buff

SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480
SRAM_SIZE = 1024 * 1024 * 32 // 8
SECTOR_SIZE = 512

IMAGES = ['background1.png', 'background2.png', 'help.png', 'crow.png', 'holybullet.png',
          'loser.png', 'person_left_1.png', 'person_left_2.png', 'person_left_3.png',
          'person_middle_1.png', 'person_middle_2.png', 'person_middle_3.png',
          'person_right_1.png', 'person_right_2.png', 'person_right_3.png', 'bullet.png', 'start.png']

buff = b''
with open('mmap.csv', 'w') as f:
    f.write('filename,width,height,length(bytes),address(bytes),length(dwords),address(dwords)\n')
    print('Preallocating graphics memory')
    bin = b'\0' * SCREEN_WIDTH * SCREEN_HEIGHT * 4
    f.write('{},{},{},{},{},{},{}\n'.format('buffer1', SCREEN_WIDTH, SCREEN_HEIGHT, len(bin), len(buff),
                                            len(bin) // 4, len(buff) // 4))
    buff += bin
    f.write('{},{},{},{},{},{},{}\n'.format('buffer2', SCREEN_WIDTH, SCREEN_HEIGHT, len(bin), len(buff),
                                            len(bin) // 4, len(buff) // 4))
    buff += bin
    for filename in IMAGES:
        img = Image.open(filename)
        print('Processing {}: {}, {}x{}, {}'.format(filename, img.format, img.size[0], img.size[1], img.mode))
        bin = get_bin(img)
        f.write('{},{},{},{},{},{},{}\n'.format(filename, img.size[0], img.size[1], len(bin), len(buff),
                                                len(bin) // 4, len(buff) // 4))
        buff += bin
        preview(img)

if len(buff) % SECTOR_SIZE != 0:
    buff += b'\0' * (SECTOR_SIZE - len(buff) % SECTOR_SIZE)
    print('Warning: padding sector')

print('SRAM usage: {}/{}, {}%'.format(len(buff), SRAM_SIZE, len(buff) / SRAM_SIZE * 100))

with open('images.bin', 'wb') as f:
    f.write(buff)