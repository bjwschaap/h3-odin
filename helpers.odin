package h3


// latitude/longitude in degrees
LatLngDeg :: struct {
    lat: f64,
    lng: f64,
}

lat_lng_to_degrees :: proc(pos: LatLng) -> LatLngDeg {
    return {
        lat = radsToDegs(pos.lat),
        lng = radsToDegs(pos.lng)},
}

lat_lng_to_radians :: proc(pos: LatLngDeg) -> LatLng {
    return {
        lat = degsToRads(pos.lat),
        lng = degsToRads(pos.lng),
    }
}
