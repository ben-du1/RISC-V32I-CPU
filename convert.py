import argparse

parser = argparse.ArgumentParser(description="Input Binary, Output Hex")
parser.add_argument("output_type",type=str, help="hex OR bin")
parser.add_argument("input_file",type=str, help="Input Binary File")
parser.add_argument("output_file",type=str, help="Output Hex File")

args = parser.parse_args()

with open(args.input_file,"rb") as f:
    data = f.read()

with open(args.output_file, 'w') as f:

    if (args.output_type == 'hex'):
        for i in range(0, len(data), 4):
            word = data[i:i+4]
            word += b'\x00' * (4-len(word))
            value = int.from_bytes(word, byteorder="little")
            f.write(f"{value:08x}\n")
    elif (args.output_type == 'bin'):
        for byte in data:
            f.write(f"{byte:02x}\n")
    else:
        print("Please provide a valid output type")