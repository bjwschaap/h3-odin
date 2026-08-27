package examples

import "core:fmt"
import h3 "../"

cstringTest :: proc() {
    g: h3.LatLng
    g.lat = 37.334713
    g.lng = 127.0715296
    out: h3.Index
    h3.latLngToCell(&g, 10, &out)

    str := make([]u8, 17)
    defer delete(str)
    err := h3.h3ToString(out, str, 17)
    fmt.printf("h3ToString result: %s\n", cstring(&str[0]))

    str2 := cstring("8aaa45945b27fff")
    out2 :h3.Index
    h3.stringToH3(str2, &out2)
    fmt.printf("stringToH3 result: %x\n", out2)
}
