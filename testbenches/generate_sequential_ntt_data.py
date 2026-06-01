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


def mod_pow(base, exponent, modulus):
    result = 1
    for _ in range(exponent):
        result = (result * base) % modulus
    return result


def bit_reverse(value, bits):
    result = 0
    for i in range(bits):
        result = (result << 1) | ((value >> i) & 1)
    return result


def ntt(values, modulus, root):
    n = len(values)
    out = []
    for k in range(n):
        factor = mod_pow(root, k, modulus)
        power = 1
        total = 0
        for value in values:
            total = (total + (value % modulus) * power) % modulus
            power = (power * factor) % modulus
        out.append(total)
    return out


def inverse_ntt(values, modulus, root, n_inverse):
    n = len(values)
    out = []
    for k in range(n):
        total = 0
        for j, value in enumerate(values):
            exponent = (n - ((j * k) % n)) % n
            total = (total + (value % modulus) * mod_pow(root, exponent, modulus)) % modulus
        out.append((total * n_inverse) % modulus)
    return out


def first_stage(values, modulus):
    n = len(values)
    bits = (n - 1).bit_length()
    mem = [0] * n
    for i, value in enumerate(values):
        mem[bit_reverse(i, bits)] = value % modulus

    results = [0] * n
    for i in range(0, n, 2):
        a = mem[i]
        b = mem[i + 1]
        results[i] = (a + b) % modulus
        results[i + 1] = (a - b) % modulus
    return results


def kyber_coeff(testcase, index):
    modulus = 3329
    n = 256
    if testcase == 1:
        return 0
    if testcase == 2:
        return 1 if index == 0 else 0
    if testcase == 3:
        return modulus - 1 if index == 0 else 0
    if testcase == 4:
        return index % modulus
    if testcase == 5:
        return (n - 1 - index) % modulus
    if testcase == 6:
        return 1 if (index & 1) == 0 else modulus - 1
    if testcase == 7:
        return 2 if index % 3 == 0 else (modulus - 2 if index % 3 == 1 else 0)
    if testcase == 8:
        return 3 if index % 5 == 0 else (modulus - 3 if index % 5 == 1 else 0)
    if testcase == 9:
        return (17 * index + 91) % modulus
    if testcase == 10:
        lcg = (1229 * index + 321) % modulus
        return (lcg * lcg + 7 * index + 11) % modulus
    return 0


def small_coeff(testcase, index):
    if testcase == 1:
        return index + 1
    if testcase == 2:
        return 1 if (index & 1) == 0 else 16
    return 0


def generate_mem_load():
    n8_values = [(i * 3 + 1) % 17 for i in range(8)]
    n8_ram = [0] * 8
    for i, value in enumerate(n8_values):
        n8_ram[bit_reverse(i, 3)] = value
    write_mem("ntt_mem_load_n8_input.mem", n8_values, 10, "Sequential NTT memory-load N=8 input coefficients")
    write_mem("ntt_mem_load_n8_expected_ram.mem", n8_ram, 10, "Sequential NTT memory-load N=8 expected RAM after bit-reversed load")

    n16_values = [(i * 7 + 4) % 97 for i in range(16)]
    n16_ram = [0] * 16
    for i, value in enumerate(n16_values):
        n16_ram[bit_reverse(i, 4)] = value
    write_mem("ntt_mem_load_n16_input.mem", n16_values, 12, "Sequential NTT memory-load N=16 input coefficients")
    write_mem("ntt_mem_load_n16_expected_ram.mem", n16_ram, 12, "Sequential NTT memory-load N=16 expected RAM after bit-reversed load")


def generate_small_ntt():
    values = [i + 1 for i in range(8)]
    expected = ntt(values, 17, 9)
    expected_stage = first_stage(values, 17)

    write_mem("ntt_full_default_input.mem", values, 16, "Sequential NTT full-run default-width input coefficients")
    write_mem("ntt_full_default_expected.mem", expected, 16, "Sequential NTT full-run default-width expected output coefficients")
    write_mem("ntt_full_wide_input.mem", values, 20, "Sequential NTT full-run width=20 input coefficients")
    write_mem("ntt_full_wide_expected.mem", expected, 20, "Sequential NTT full-run width=20 expected output coefficients")

    write_mem("ntt_one_stage_default_input.mem", values, 16, "Sequential NTT one-stage default-width input coefficients")
    write_mem("ntt_one_stage_default_expected.mem", expected_stage, 16, "Sequential NTT one-stage default-width expected butterfly results")
    write_mem("ntt_one_stage_wide_input.mem", values, 20, "Sequential NTT one-stage width=20 input coefficients")
    write_mem("ntt_one_stage_wide_expected.mem", expected_stage, 20, "Sequential NTT one-stage width=20 expected butterfly results")


def generate_ml_kem():
    kyber_forward_in = []
    kyber_forward_expected = []
    for testcase in range(1, 11):
        values = [kyber_coeff(testcase, i) for i in range(256)]
        kyber_forward_in.extend(values)
        kyber_forward_expected.extend(ntt(values, 3329, 17))
    write_mem("ml_kem_kyber_forward_input.mem", kyber_forward_in, 24, "ML-KEM-like sequential NTT Kyber forward inputs", 256)
    write_mem("ml_kem_kyber_forward_expected.mem", kyber_forward_expected, 24, "ML-KEM-like sequential NTT Kyber forward expected outputs", 256)

    kyber_inverse_in = []
    kyber_inverse_expected = []
    for testcase in range(1, 6):
        values = [kyber_coeff(testcase, i) for i in range(256)]
        kyber_inverse_in.extend(values)
        kyber_inverse_expected.extend(inverse_ntt(values, 3329, 17, 3316))
    write_mem("ml_kem_kyber_inverse_input.mem", kyber_inverse_in, 24, "ML-KEM-like sequential NTT Kyber inverse inputs", 256)
    write_mem("ml_kem_kyber_inverse_expected.mem", kyber_inverse_expected, 24, "ML-KEM-like sequential NTT Kyber inverse expected outputs", 256)

    small_forward_in = []
    small_forward_expected = []
    small_inverse_in = []
    small_inverse_expected = []
    for testcase in range(1, 3):
        values = [small_coeff(testcase, i) for i in range(8)]
        small_forward_in.extend(values)
        small_forward_expected.extend(ntt(values, 17, 9))
        small_inverse_in.extend(values)
        small_inverse_expected.extend(inverse_ntt(values, 17, 9, 15))
    write_mem("ml_kem_small_forward_input.mem", small_forward_in, 10, "ML-KEM-style small sequential NTT forward inputs", 8)
    write_mem("ml_kem_small_forward_expected.mem", small_forward_expected, 10, "ML-KEM-style small sequential NTT forward expected outputs", 8)
    write_mem("ml_kem_small_inverse_input.mem", small_inverse_in, 10, "ML-KEM-style small sequential NTT inverse inputs", 8)
    write_mem("ml_kem_small_inverse_expected.mem", small_inverse_expected, 10, "ML-KEM-style small sequential NTT inverse expected outputs", 8)


def main():
    generate_mem_load()
    generate_small_ntt()
    generate_ml_kem()


if __name__ == "__main__":
    main()
