
file_name = r'\\wsl.localhost\Debian\home\chad\riscv_0001\test.bin'

with open(file_name, "rb") as f:
    data = f.read()

# pad to a multiple of 4 in case the binary isn't word-aligned in length
while len(data) % 4 != 0:
    data += b'\x00'

str_lines = []
for i in range(0, len(data), 4):
    word = data[i:i+4]
    hex_word = f"{word[3]:02x}{word[2]:02x}{word[1]:02x}{word[0]:02x}"
    str_lines.append(f"0x{hex_word}")

filename = r'C:\Users\cudac\Desktop\new\code\art\VCB\riscv.vcbmem'

str_lines.insert(0, '0xFAFAFAFA') # first word is never used in VCB

with open(filename, "wb") as file:
    for line in str_lines:
        file.write(bytes.fromhex(line[2:]))