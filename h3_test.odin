package h3

import "core:testing"
import c "core:c"


#assert(size_of(Error) == size_of(c.uint32_t))
#assert(size_of(CoordIJ) == 2 * size_of(c.int))

expect_success :: proc(t: ^testing.T, err: Error) -> bool {
	return testing.expectf(t, error_is_success(err), "unexpected H3 error: %s", error_message(err))
}

expect_approx :: proc(t: ^testing.T, actual, expected, tolerance: f64) -> bool {
	difference := actual - expected
	if difference < 0 {
		difference = -difference
	}
	return testing.expectf(
		t,
		difference <= tolerance,
		"expected %.12f to be within %.12f of %.12f",
		actual,
		tolerance,
		expected,
	)
}

@(test)
test_h3_4_5_version_and_error_descriptions :: proc(t: ^testing.T) {
	testing.expect_value(t, H3_VERSION_MAJOR, 4)
	testing.expect_value(t, H3_VERSION_MINOR, 5)
	testing.expect_value(t, H3_VERSION_PATCH, 0)
	testing.expect_value(t, error_message(.E_SUCCESS), "Success")
	testing.expect(t, len(error_message(.E_INDEX_INVALID)) > 0)
}

@(test)
test_h3_4_5_safe_grid_ring :: proc(t: ^testing.T) {
	origin: Index = 0x8a2a1072b59ffff
	max_size: i64
	if !expect_success(t, maxGridRingSize(2, &max_size)) {
		return
	}
	testing.expect_value(t, max_size, i64(12))

	ring: [12]Index
	if !expect_success(t, gridRing(origin, 2, &ring[0])) {
		return
	}

	for cell in ring {
		testing.expect(t, cell != H3_NULL)
		distance: i64
		if expect_success(t, gridDistance(origin, cell, &distance)) {
			testing.expect_value(t, distance, i64(2))
		}
	}
}

@(test)
test_h3_4_5_great_circle_and_edge_measurements :: proc(t: ^testing.T) {
	origin: Index = 0x8a2a1072b59ffff
	destination: Index = 0x8a2a1072b597fff

	origin_point, destination_point: LatLng
	if !expect_success(t, cellToLatLng(origin, &origin_point)) ||
	   !expect_success(t, cellToLatLng(destination, &destination_point)) {
		return
	}

	distance_rads := greatCircleDistanceRads(&origin_point, &destination_point)
	distance_km := greatCircleDistanceKm(&origin_point, &destination_point)
	distance_m := greatCircleDistanceM(&origin_point, &destination_point)
	testing.expect(t, distance_rads > 0)
	expect_approx(t, distance_m, distance_km * 1000, 1e-6)
	expect_approx(t, distance_km, distance_rads * 6371.007180918475, 1e-9)

	edge: Index
	if !expect_success(t, cellsToDirectedEdge(origin, destination, &edge)) {
		return
	}
	testing.expect_value(t, isValidIndex(edge), 1)
	testing.expect_value(t, isValidCell(edge), 0)

	edge_rads, edge_km, edge_m: f64
	if !expect_success(t, edgeLengthRads(edge, &edge_rads)) ||
	   !expect_success(t, edgeLengthKm(edge, &edge_km)) ||
	   !expect_success(t, edgeLengthM(edge, &edge_m)) {
		return
	}
	expect_approx(t, edge_m, edge_km * 1000, 1e-6)
	expect_approx(t, edge_km, edge_rads * 6371.007180918475, 1e-9)

	reversed: Index
	if !expect_success(t, reverseDirectedEdge(edge, &reversed)) {
		return
	}
	reversed_cells: [2]Index
	if expect_success(t, directedEdgeToCells(reversed, &reversed_cells[0])) {
		testing.expect_value(t, reversed_cells[0], destination)
		testing.expect_value(t, reversed_cells[1], origin)
	}
}

@(test)
test_h3_4_5_index_construction :: proc(t: ^testing.T) {
	cell: Index = 0x8a2a1072b59ffff
	parent: Index
	if !expect_success(t, cellToParent(cell, 1, &parent)) {
		return
	}

	digit: c.int = 0
	if !expect_success(t, getIndexDigit(parent, 1, &digit)) {
		return
	}
	testing.expect(t, digit >= 0 && digit <= 6)

	reconstructed: Index
	if expect_success(t, constructCell(1, getBaseCellNumber(parent), &digit, &reconstructed)) {
		testing.expect_value(t, reconstructed, parent)
		testing.expect_value(t, isValidIndex(reconstructed), 1)
	}

	invalid_digit: c.int = 7
	err := constructCell(1, getBaseCellNumber(parent), &invalid_digit, &reconstructed)
	testing.expect_value(t, err, Error.E_DIGIT_DOMAIN)
}

@(test)
test_h3_4_5_child_position_round_trip :: proc(t: ^testing.T) {
	child: Index = 0x8a2a1072b59ffff
	parent: Index
	if !expect_success(t, cellToParent(child, 8, &parent)) {
		return
	}

	position: i64
	if !expect_success(t, cellToChildPos(child, 8, &position)) {
		return
	}
	testing.expect(t, position >= 0)

	reconstructed: Index
	if expect_success(t, childPosToCell(position, parent, 10, &reconstructed)) {
		testing.expect_value(t, reconstructed, child)
	}
}

@(test)
test_h3_4_5_experimental_polygon_fill :: proc(t: ^testing.T) {
	center_mode := u32(containment_mode.CONTAINMENT_CENTER)
	vertices := [4]LatLng{
		{degsToRads(37.68), degsToRads(-122.54)},
		{degsToRads(37.68), degsToRads(-122.35)},
		{degsToRads(37.82), degsToRads(-122.35)},
		{degsToRads(37.82), degsToRads(-122.54)},
	}
	polygon := GeoPolygon{
		geoLoop = GeoLoop{numVerts = c.int(len(vertices)), verts = &vertices[0]},
	}

	max_size: i64
	if !expect_success(t, maxPolygonToCellsSizeExperimental(&polygon, 9, center_mode, &max_size)) {
		return
	}
	testing.expect(t, max_size > 0)

	cells := make([]Index, int(max_size))
	defer delete(cells)
	if !expect_success(t, polygonToCellsExperimental(&polygon, 9, center_mode, max_size, &cells[0])) {
		return
	}

	cell_count := 0
	for cell in cells {
		if cell != H3_NULL {
			cell_count += 1
			testing.expect_value(t, isValidCell(cell), 1)
		}
	}
	testing.expect(t, cell_count > 0)

	invalid_size: i64
	invalid_mode := u32(containment_mode.CONTAINMENT_INVALID)
	err := maxPolygonToCellsSizeExperimental(&polygon, 9, invalid_mode, &invalid_size)
	testing.expect_value(t, err, Error.E_OPTION_INVALID)
}

@(test)
test_c_int_output_arrays :: proc(t: ^testing.T) {
	origin: Index = 0x8a2a1072b59ffff
	cells: [7]Index
	distances: [7]c.int
	if !expect_success(t, gridDiskDistances(origin, 1, &cells[0], &distances[0])) {
		return
	}

	counts: [2]int
	for distance in distances {
		if testing.expect(t, distance >= 0 && distance <= 1) {
			counts[distance] += 1
		}
	}
	testing.expect_value(t, counts[0], 1)
	testing.expect_value(t, counts[1], 6)
}

@(test)
test_coord_ij_round_trip :: proc(t: ^testing.T) {
	origin: Index = 0x8a2a1072b59ffff
	ij: CoordIJ
	if !expect_success(t, cellToLocalIj(origin, origin, 0, &ij)) {
		return
	}

	cell: Index
	if expect_success(t, localIjToCell(origin, &ij, 0, &cell)) {
		testing.expect_value(t, cell, origin)
	}
}

@(test)
test_h3_string_output_buffer :: proc(t: ^testing.T) {
	cell: Index = 0x8a2a1072b59ffff
	buffer: [17]c.char
	if expect_success(t, h3ToString(cell, &buffer[0], len(buffer))) {
		testing.expect_value(t, string(cstring(&buffer[0])), "8a2a1072b59ffff")
	}
}
