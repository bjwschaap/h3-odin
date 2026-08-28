package examples

import "core:testing"
import c "core:c"
import h3 "../"

H3_SUCCESS :: h3.Error.E_SUCCESS

#assert(size_of(h3.Error) == size_of(c.uint32_t))
#assert(size_of(h3.CoordIJ) == 2 * size_of(c.int))

expect_success :: proc(t: ^testing.T, err: h3.Error) -> bool {
	return testing.expectf(t, h3.error_is_success(err), "unexpected H3 error: %s", h3.error_message(err))
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
	testing.expect_value(t, h3.H3_VERSION_MAJOR, 4)
	testing.expect_value(t, h3.H3_VERSION_MINOR, 5)
	testing.expect_value(t, h3.H3_VERSION_PATCH, 0)
	testing.expect_value(t, h3.error_message(H3_SUCCESS), "Success")
	testing.expect(t, len(h3.error_message(.E_INDEX_INVALID)) > 0)
}

@(test)
test_h3_4_5_safe_grid_ring :: proc(t: ^testing.T) {
	origin: h3.Index = 0x8a2a1072b59ffff
	max_size: i64
	if !expect_success(t, h3.maxGridRingSize(2, &max_size)) {
		return
	}
	testing.expect_value(t, max_size, i64(12))

	ring: [12]h3.Index
	if !expect_success(t, h3.gridRing(origin, 2, &ring[0])) {
		return
	}

	for cell in ring {
		testing.expect(t, cell != h3.H3_NULL)
		distance: i64
		if expect_success(t, h3.gridDistance(origin, cell, &distance)) {
			testing.expect_value(t, distance, i64(2))
		}
	}
}

@(test)
test_h3_4_5_great_circle_and_edge_measurements :: proc(t: ^testing.T) {
	origin: h3.Index = 0x8a2a1072b59ffff
	destination: h3.Index = 0x8a2a1072b597fff

	origin_point, destination_point: h3.LatLng
	if !expect_success(t, h3.cellToLatLng(origin, &origin_point)) ||
	   !expect_success(t, h3.cellToLatLng(destination, &destination_point)) {
		return
	}

	distance_rads := h3.greatCircleDistanceRads(&origin_point, &destination_point)
	distance_km := h3.greatCircleDistanceKm(&origin_point, &destination_point)
	distance_m := h3.greatCircleDistanceM(&origin_point, &destination_point)
	testing.expect(t, distance_rads > 0)
	expect_approx(t, distance_m, distance_km * 1000, 1e-6)
	expect_approx(t, distance_km, distance_rads * 6371.007180918475, 1e-9)

	edge: h3.Index
	if !expect_success(t, h3.cellsToDirectedEdge(origin, destination, &edge)) {
		return
	}
	testing.expect_value(t, h3.isValidIndex(edge), 1)
	testing.expect_value(t, h3.isValidCell(edge), 0)

	edge_rads, edge_km, edge_m: f64
	if !expect_success(t, h3.edgeLengthRads(edge, &edge_rads)) ||
	   !expect_success(t, h3.edgeLengthKm(edge, &edge_km)) ||
	   !expect_success(t, h3.edgeLengthM(edge, &edge_m)) {
		return
	}
	expect_approx(t, edge_m, edge_km * 1000, 1e-6)
	expect_approx(t, edge_km, edge_rads * 6371.007180918475, 1e-9)

	reversed: h3.Index
	if !expect_success(t, h3.reverseDirectedEdge(edge, &reversed)) {
		return
	}
	reversed_cells: [2]h3.Index
	if expect_success(t, h3.directedEdgeToCells(reversed, &reversed_cells[0])) {
		testing.expect_value(t, reversed_cells[0], destination)
		testing.expect_value(t, reversed_cells[1], origin)
	}
}

@(test)
test_h3_4_5_index_construction :: proc(t: ^testing.T) {
	cell: h3.Index = 0x8a2a1072b59ffff
	parent: h3.Index
	if !expect_success(t, h3.cellToParent(cell, 1, &parent)) {
		return
	}

	digit: c.int = 0
	if !expect_success(t, h3.getIndexDigit(parent, 1, &digit)) {
		return
	}
	testing.expect(t, digit >= 0 && digit <= 6)

	reconstructed: h3.Index
	if expect_success(t, h3.constructCell(1, h3.getBaseCellNumber(parent), &digit, &reconstructed)) {
		testing.expect_value(t, reconstructed, parent)
		testing.expect_value(t, h3.isValidIndex(reconstructed), 1)
	}

	invalid_digit: c.int = 7
	err := h3.constructCell(1, h3.getBaseCellNumber(parent), &invalid_digit, &reconstructed)
	testing.expect_value(t, err, h3.Error.E_DIGIT_DOMAIN)
}

@(test)
test_h3_4_5_child_position_round_trip :: proc(t: ^testing.T) {
	child: h3.Index = 0x8a2a1072b59ffff
	parent: h3.Index
	if !expect_success(t, h3.cellToParent(child, 8, &parent)) {
		return
	}

	position: i64
	if !expect_success(t, h3.cellToChildPos(child, 8, &position)) {
		return
	}
	testing.expect(t, position >= 0)

	reconstructed: h3.Index
	if expect_success(t, h3.childPosToCell(position, parent, 10, &reconstructed)) {
		testing.expect_value(t, reconstructed, child)
	}
}

@(test)
test_h3_4_5_experimental_polygon_fill :: proc(t: ^testing.T) {
	center_mode := u32(h3.containment_mode.CONTAINMENT_CENTER)
	vertices := [4]h3.LatLng{
		{h3.degsToRads(37.68), h3.degsToRads(-122.54)},
		{h3.degsToRads(37.68), h3.degsToRads(-122.35)},
		{h3.degsToRads(37.82), h3.degsToRads(-122.35)},
		{h3.degsToRads(37.82), h3.degsToRads(-122.54)},
	}
	polygon := h3.GeoPolygon{
		geoLoop = h3.GeoLoop{numVerts = c.int(len(vertices)), verts = &vertices[0]},
	}

	max_size: i64
	if !expect_success(t, h3.maxPolygonToCellsSizeExperimental(&polygon, 9, center_mode, &max_size)) {
		return
	}
	testing.expect(t, max_size > 0)

	cells := make([]h3.Index, int(max_size))
	defer delete(cells)
	if !expect_success(t, h3.polygonToCellsExperimental(&polygon, 9, center_mode, max_size, &cells[0])) {
		return
	}

	cell_count := 0
	for cell in cells {
		if cell != h3.H3_NULL {
			cell_count += 1
			testing.expect_value(t, h3.isValidCell(cell), 1)
		}
	}
	testing.expect(t, cell_count > 0)

	invalid_size: i64
	invalid_mode := u32(h3.containment_mode.CONTAINMENT_INVALID)
	err := h3.maxPolygonToCellsSizeExperimental(&polygon, 9, invalid_mode, &invalid_size)
	testing.expect_value(t, err, h3.Error.E_OPTION_INVALID)
}

@(test)
test_c_int_output_arrays :: proc(t: ^testing.T) {
	origin: h3.Index = 0x8a2a1072b59ffff
	cells: [7]h3.Index
	distances: [7]c.int
	if !expect_success(t, h3.gridDiskDistances(origin, 1, &cells[0], &distances[0])) {
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
	origin: h3.Index = 0x8a2a1072b59ffff
	ij: h3.CoordIJ
	if !expect_success(t, h3.cellToLocalIj(origin, origin, 0, &ij)) {
		return
	}

	cell: h3.Index
	if expect_success(t, h3.localIjToCell(origin, &ij, 0, &cell)) {
		testing.expect_value(t, cell, origin)
	}
}

@(test)
test_h3_string_output_buffer :: proc(t: ^testing.T) {
	cell: h3.Index = 0x8a2a1072b59ffff
	buffer: [17]c.char
	if expect_success(t, h3.h3ToString(cell, &buffer[0], len(buffer))) {
		testing.expect_value(t, string(cstring(&buffer[0])), "8a2a1072b59ffff")
	}
}
