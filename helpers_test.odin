package h3

import "core:testing"
import "core:math"

@(test)
test_lat_lng_to_degrees :: proc(t: ^testing.T) {
	pos := LatLng{
		lat = math.PI / 2,
		lng = -math.PI,
	}
	result := lat_lng_to_degrees(pos)

	expect_approx(t, result.lat, 90, 1e-12)
	expect_approx(t, result.lng, -180, 1e-12)
}

@(test)
test_lat_lng_to_radians :: proc(t: ^testing.T) {
	pos := LatLngDeg{
		lat = 90,
		lng = -180,
	}
	result := lat_lng_to_radians(pos)

	expect_approx(t, result.lat, math.PI / 2, 1e-12)
	expect_approx(t, result.lng, -math.PI, 1e-12)
}
