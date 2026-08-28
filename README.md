# H3-Odin

Unofficial Odin bindings for [H3 Core Library v4.5.0](https://github.com/uber/h3/tree/v4.5.0).
The package exposes the H3 C API, ABI-compatible Odin types, a strongly typed
`Error` enum, and small helpers for converting coordinates between degrees and
radians. Refer to the [H3 API documentation](https://h3geo.org/docs/api/) for
details about individual H3 procedures.

## Supported targets

The repository includes static H3 libraries for:

| OS | Architecture | Archive |
| --- | --- | --- |
| macOS | amd64 | `_gen/libh3_darwin_amd64.a` |
| macOS | arm64 | `_gen/libh3_darwin_arm64.a` |
| Linux | amd64 | `_gen/libh3_linux_amd64.a` |
| Linux | arm64 | `_gen/libh3_linux_arm64.a` |

For another target, build H3 v4.5.0 for that target, add the resulting static
library, and extend the target selection in `procedures.odin`.

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
