from pathlib import Path


DATA_DIR = Path(__file__).resolve().parent / "data"


def write_mem(name, values, width, title, group_size=None, group_name="testcase"):
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    digits = (width + 3) // 4
    with (DATA_DIR / name).open("w", encoding="ascii") as f:
        f.write(f"// {title}\n")
        f.write(f"// width={width} entries={len(values)} radix=hex\n")
        f.write("// Format: <hex value> // [absolute_index] decimal=<decimal value>\n")
        for index, value in enumerate(values):
            if group_size is not None and index % group_size == 0:
                f.write("\n")
                f.write(f"// {group_name} {(index // group_size) + 1}\n")
            f.write(f"{value & ((1 << width) - 1):0{digits}x} // [{index}] decimal={value}\n")


def cyclic_convolution(a_values, b_values, modulus):
    n = len(a_values)
    out = []
    for i in range(n):
        total = 0
        for j in range(n):
            source_index = (i - j + n) % n
            total = (total + (a_values[j] % modulus) * (b_values[source_index] % modulus)) % modulus
        out.append(total)
    return out


def flatten(vectors):
    values = []
    for vector in vectors:
        values.extend(vector)
    return values


def main():
    n8_cases = [
        ([0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0]),
        ([1, 0, 0, 0, 0, 0, 0, 0], [3, 1, 4, 1, 5, 9, 2, 6]),
        ([1, 2, 3, 4, 5, 6, 7, 8], [8, 7, 6, 5, 4, 3, 2, 1]),
        ([16, 15, 14, 13, 12, 11, 10, 9], [1, 2, 3, 4, 5, 6, 7, 8]),
    ]
    n8_expected = [cyclic_convolution(a, b, 17) for a, b in n8_cases]
    write_mem("poly_seq_n8_a.mem", flatten(a for a, _ in n8_cases), 10, "Sequential polynomial multiplier N=8 A inputs", 8)
    write_mem("poly_seq_n8_b.mem", flatten(b for _, b in n8_cases), 10, "Sequential polynomial multiplier N=8 B inputs", 8)
    write_mem("poly_seq_n8_expected.mem", flatten(n8_expected), 10, "Sequential polynomial multiplier N=8 expected outputs", 8)

    n4_cases = [
        ([0, 0, 0, 0], [0, 0, 0, 0]),
        ([1, 0, 0, 0], [3, 1, 4, 1]),
        ([1, 2, 3, 4], [4, 3, 2, 1]),
        ([16, 15, 14, 13], [1, 2, 3, 4]),
    ]
    n4_expected = [cyclic_convolution(a, b, 17) for a, b in n4_cases]
    write_mem("poly_seq_n4_a.mem", flatten(a for a, _ in n4_cases), 8, "Sequential polynomial multiplier N=4 A inputs", 4)
    write_mem("poly_seq_n4_b.mem", flatten(b for _, b in n4_cases), 8, "Sequential polynomial multiplier N=4 B inputs", 4)
    write_mem("poly_seq_n4_expected.mem", flatten(n4_expected), 8, "Sequential polynomial multiplier N=4 expected outputs", 4)


if __name__ == "__main__":
    main()
