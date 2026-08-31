# H3-Odin

Unofficial Odin bindings for [H3 Core Library v4.5.0](https://github.com/uber/h3/tree/v4.5.0).
The package exposes the H3 C API, ABI-compatible Odin types, a strongly typed
`Error` enum, and small helpers for converting coordinates between degrees and
radians. Refer to the [H3 API documentation](https://h3geo.org/docs/api/) for
details about individual H3 procedures.

## Supported targets

The bindings expect static H3 libraries with these names:

| OS | Architecture | Archive |
| --- | --- | --- |
| macOS | amd64 | `_gen/libh3_darwin_amd64.a` |
| macOS | arm64 | `_gen/libh3_darwin_arm64.a` |
| Linux | amd64 | `_gen/libh3_linux_amd64.a` |
| Linux | arm64 | `_gen/libh3_linux_arm64.a` |

For another target, build H3 v4.5.0 for that target, add the resulting static
library, and extend the target selection in `procedures.odin`.

### Building the native H3 library

The build wrapper compiles H3 for the machine on which it runs and copies the
static library to the matching path above. It supports macOS and Linux on amd64
and arm64, and requires CMake 3.20 or newer plus a C compiler. The `--ref`
option additionally requires Git and `tar`.

First clone H3, then run the wrapper from this repository. Passing `--ref` is
recommended so that the library version matches these bindings:

```bash
git clone https://github.com/uber/h3.git ../h3
./scripts/build_h3.sh --ref v4.5.0 ../h3
```

`--ref` accepts any branch, tag, or commit already present in the local H3
clone. The wrapper exports that revision to a temporary directory, so it does
not change the clone's current branch or working tree. Omit `--ref` to compile
the source tree exactly as it is currently checked out, including local tracked
or untracked changes:

```bash
./scripts/build_h3.sh ../h3
```

By default the output is written to `_gen/libh3_<os>_<arch>.a` in this
repository. These generated archives are ignored by Git. Use `--output-dir` to
place the archive elsewhere:

```bash
./scripts/build_h3.sh --ref v4.5.0 --output-dir ./dist ../h3
```

The wrapper builds one native archive at a time. Run it on each platform and
architecture whose archive you need. See all options with
`./scripts/build_h3.sh --help`.

## Installation

Clone or copy this repository into your project, or expose it through an Odin
library collection. Import paths are relative to the importing source file, so
adjust the path for your project layout:

```odin
import h3 "h3-odin"
```

## Usage

This example converts an Amsterdam coordinate from degrees to the radians
required by H3, creates a resolution 9 cell, and handles errors without casts:

```odin
package main

import "core:fmt"
import h3 "h3-odin"

main :: proc() {
	location := h3.lat_lng_to_radians({
		lat = 52.3676,
		lng = 4.9041,
	})

	cell: h3.Index
	if err := h3.latLngToCell(&location, 9, &cell); err != .E_SUCCESS {
		fmt.printf("H3 error: %s\n", h3.error_message(err))
		return
	}

	fmt.printf("cell: %x\n", cell)
}
```

H3 procedures return an `Error` enum with the same `u32` representation as the
C API. Use `error_is_success` for a boolean check or compare directly with
`.E_SUCCESS`; `error_message` returns H3's description of an error.

## Testing

Run the binding, ABI, and helper tests from the repository root:

```bash
odin test .
```

The examples have a separate smoke-test suite:

```bash
odin test ./examples
```

## Regenerating the bindings

After replacing `_gen/h3api.h`, regenerate the foreign procedure declarations:

```bash
cd _gen
python3 ./gen_procedures.py > ../procedures.odin
cd ..
odin test .
```

The generated `procedures.odin` must remain in sync with
`_gen/gen_procedures.py` and `_gen/h3api.h`.
