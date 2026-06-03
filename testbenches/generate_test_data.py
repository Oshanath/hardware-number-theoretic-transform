from dataclasses import dataclass
from pathlib import Path
from random import Random


DATA_DIR = Path(__file__).resolve().parent / "data"
SEED = 0x5EED2026

NTT_FORWARD_CASES = 15
NTT_INVERSE_CASES = 5
NTT_CASES = NTT_FORWARD_CASES + NTT_INVERSE_CASES
POLY_CASES = 20


@dataclass(frozen=True)
class Parameters:
    name: str
    n: int
    modulus: int
    root: int
    n_inverse: int
    width: int


PARAMETERS = (
    Parameters(name="n8", n=8, modulus=17, root=9, n_inverse=15, width=16),
    Parameters(name="kyber", n=256, modulus=3329, root=17, n_inverse=3316, width=24),
)


def forward_ntt(values, modulus, root):
    n = len(values)
    return [
        sum((values[j] % modulus) * pow(root, j * k, modulus) for j in range(n)) % modulus
        for k in range(n)
    ]


def inverse_ntt(values, modulus, root, n_inverse):
    n = len(values)
    return [
        (
            sum(
                (values[j] % modulus)
                * pow(root, (n - ((j * k) % n)) % n, modulus)
                for j in range(n)
            )
            * n_inverse
        )
        % modulus
        for k in range(n)
    ]


def polynomial_multiply(a, b, modulus):
    n = len(a)
    return [
        sum((a[j] % modulus) * (b[(i - j) % n] % modulus) for j in range(n)) % modulus
        for i in range(n)
    ]


def random_vector(rng, n, modulus):
    return [rng.randrange(modulus) for _ in range(n)]


def ntt_testcases(params, rng):
    cases = [
        ("edge_all_zero", "forward", [0] * params.n),
        ("edge_unit_impulse", "forward", [1] + [0] * (params.n - 1)),
        ("edge_all_modulus_minus_one", "forward", [params.modulus - 1] * params.n),
    ]

    while len(cases) < NTT_FORWARD_CASES:
        cases.append((f"random_forward_{len(cases) + 1}", "forward", random_vector(rng, params.n, params.modulus)))

    cases.append(("edge_inverse_all_zero", "inverse", [0] * params.n))

    while len(cases) < NTT_CASES:
        cases.append((f"random_inverse_{len(cases) - NTT_FORWARD_CASES}", "inverse", random_vector(rng, params.n, params.modulus)))

    return cases


def poly_testcases(params, rng):
    alternating = [0 if i % 2 == 0 else params.modulus - 1 for i in range(params.n)]
    reverse_alternating = list(reversed(alternating))
    ramp = [i % params.modulus for i in range(params.n)]
    reverse_ramp = list(reversed(ramp))

    cases = [
        ("edge_all_zero", [0] * params.n, [0] * params.n),
        ("edge_unit_times_ramp", [1] + [0] * (params.n - 1), ramp),
        ("edge_max_times_reverse_ramp", [params.modulus - 1] * params.n, reverse_ramp),
        ("edge_alternating_extremes", alternating, reverse_alternating),
    ]

    while len(cases) < POLY_CASES:
        cases.append(
            (
                f"random_pair_{len(cases) + 1}",
                random_vector(rng, params.n, params.modulus),
                random_vector(rng, params.n, params.modulus),
            )
        )

    return cases


def format_decimal_vector(values):
    return "[" + ", ".join(str(value) for value in values) + "]"


def write_vector(file, label, values, width):
    digits = (width + 3) // 4
    file.write(f"// {label} decimal = {format_decimal_vector(values)}\n")
    for index, value in enumerate(values):
        file.write(f"{value:0{digits}x} // {label}[{index}] = {value}\n")


def write_ntt_file(params, rng):
    path = DATA_DIR / f"ntt_{params.name}.mem"
    with path.open("w", encoding="ascii") as file:
        file.write(f"// Common NTT test data for {params.name}\n")
        file.write(
            f"// n={params.n} modulus={params.modulus} root={params.root} "
            f"n_inverse={params.n_inverse} width={params.width}\n"
        )
        file.write(f"// cases={NTT_CASES}; testcases 1-{NTT_FORWARD_CASES} are forward NTT\n")
        file.write(f"// testcases {NTT_FORWARD_CASES + 1}-{NTT_CASES} are inverse NTT\n")
        file.write("// Each testcase stores input vector followed by expected output vector.\n")
        file.write("// Hex values are for $readmemh; decimal comments are for humans.\n\n")

        for case_id, (name, direction, values) in enumerate(ntt_testcases(params, rng), start=1):
            if direction == "forward":
                expected = forward_ntt(values, params.modulus, params.root)
            else:
                expected = inverse_ntt(values, params.modulus, params.root, params.n_inverse)

            file.write(f"// testcase {case_id}: {name}, {direction}\n")
            write_vector(file, "input", values, params.width)
            write_vector(file, "expected", expected, params.width)
            file.write("\n")


def write_poly_file(params, rng):
    path = DATA_DIR / f"poly_{params.name}.mem"
    with path.open("w", encoding="ascii") as file:
        file.write(f"// Common polynomial multiplication test data for {params.name}\n")
        file.write(
            f"// n={params.n} modulus={params.modulus} root={params.root} "
            f"n_inverse={params.n_inverse} width={params.width}\n"
        )
        file.write(f"// cases={POLY_CASES}; each testcase stores a, b, expected product.\n")
        file.write("// Product is cyclic convolution modulo modulus.\n")
        file.write("// Hex values are for $readmemh; decimal comments are for humans.\n\n")

        for case_id, (name, a, b) in enumerate(poly_testcases(params, rng), start=1):
            expected = polynomial_multiply(a, b, params.modulus)

            file.write(f"// testcase {case_id}: {name}\n")
            write_vector(file, "a", a, params.width)
            write_vector(file, "b", b, params.width)
            write_vector(file, "expected", expected, params.width)
            file.write("\n")


def main():
    rng = Random(SEED)
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    for old_file in DATA_DIR.glob("*.mem"):
        old_file.unlink()

    for params in PARAMETERS:
        write_ntt_file(params, rng)
        write_poly_file(params, rng)


if __name__ == "__main__":
    main()
