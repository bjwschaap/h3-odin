# H3-Odin
- This unofficial library provides [Odin](https://odin-lang.org/) bindings for [H3 Core Library v4.5.0](https://github.com/uber/h3/tree/v4.5.0). For API reference, please see the H3 Documentation.

## Installation guide for Darwin and Linux
- The bindings select a static library using the target OS and architecture:
    - `_gen/libh3_darwin_amd64.a`
    - `_gen/libh3_darwin_arm64.a`
    - `_gen/libh3_linux_amd64.a`
    - `_gen/libh3_linux_arm64.a`
- If the archive for your target is not included, build [H3](https://github.com/uber/h3/tree/v4.5.0) for that target and copy `libh3.a` to the matching path above.
- Regenerate the procedures after updating `h3api.h`:

```bash
cd _gen
python3 ./gen_procedures.py > ../procedures.odin
```

- Run basic examples after installation

```bash
# run basic tests
cd examples
odin test .
```

## Error handling

H3 procedures return an `Error` enum with the same `u32` representation as the
C API. Enum values can be compared directly, without casts:

```odin
if err := h3.latLngToCell(&location, 10, &cell); err != .E_SUCCESS {
	fmt.println(h3.error_message(err))
}
```
