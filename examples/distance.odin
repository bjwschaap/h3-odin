package examples
import h3 "../"

import "core:math"
import "base:runtime"
import "core:fmt"

R :: 6371.0088
haversineDistance :: proc(th1, ph1, th2, ph2: f64) -> f64{
    dx, dy, dz :f64
    ph1_local:f64 = ph1 - ph2
    dz = math.sin_f64(th1) - math.sin_f64(th2)
    dx = math.cos_f64(ph1_local) * math.cos_f64(th1) - math.cos_f64(th2)
    dy = math.sin_f64(ph1_local) * math.cos_f64(th1)
    return math.asin(math.sqrt_f64(dx * dx + dy * dy + dz * dz) / 2 ) * 2 * R
}

distance :: proc() {
    h3HQ1, h3HQ2: h3.Index 
    assert_success(h3.stringToH3("8f2830828052d25", &h3HQ1))
    assert_success(h3.stringToH3("8f283082a30e623", &h3HQ2))

    geoHQ1, geoHQ2: h3.LatLng
    assert_success(h3.cellToLatLng(h3HQ1, &geoHQ1))
    assert_success(h3.cellToLatLng(h3HQ2, &geoHQ2))

    distance: i64
    runtime.assert(h3.gridDistance(h3HQ1, h3HQ2, &distance) == .E_SUCCESS)

    geoHQ1Deg := h3.lat_lng_to_degrees(geoHQ1)
    geoHQ2Deg := h3.lat_lng_to_degrees(geoHQ2)
    fmt.printf( "origin: (%.6f, %.6f)\n" +
        "destination: (%.6f, %.6f)\n" +
        "grid distance: %d\n" +
        "distance in km: %.6fkm\n", +
        geoHQ1Deg.lat, geoHQ1Deg.lng,
        geoHQ2Deg.lat, geoHQ2Deg.lng,
        distance,
        haversineDistance(geoHQ1.lat, geoHQ1.lng, geoHQ2.lat, geoHQ2.lng))
    
    // Output:
    // origin: (37.775236, -122.419755)
    // destination: (37.789991, -122.402121)
    // grid distance: 2340
    // distance in km: 2.256853km
    
    fmt.println("===== end of distance example =====")
    
}
