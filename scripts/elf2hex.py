import sys

def elf_to_hex(bin_file, hex_file):
    with open(bin_file, "rb") as f:
        data = f.read()
    
    with open(hex_file, "w") as f:
        # Process 4 bytes at a time (32-bit RISC-V words)
        for i in range(0, len(data), 4):
            word = data[i:i+4]
            # Convert to Little Endian Hex string
            hex_val = "".join(f"{b:02x}" for b in reversed(word))
            f.write(f"{hex_val}\n")

if __name__ == "__main__":
    elf_to_hex(sys.argv[1], sys.argv[2])