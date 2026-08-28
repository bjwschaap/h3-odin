
package h3

import c "core:c"

Index :: u64

when ODIN_OS == .Darwin && ODIN_ARCH == .amd64 {
	foreign import lib "_gen/libh3_darwin_amd64.a"
} else when ODIN_OS == .Darwin && ODIN_ARCH == .arm64 {
	foreign import lib "_gen/libh3_darwin_arm64.a"
} else when ODIN_OS == .Linux && ODIN_ARCH == .amd64 {
	foreign import lib "_gen/libh3_linux_amd64.a"
} else when ODIN_OS == .Linux && ODIN_ARCH == .arm64 {
	foreign import lib "_gen/libh3_linux_arm64.a"
}

@(default_calling_convention="c")
foreign lib {

	describeH3Error :: proc ( err: Error ) -> cstring ---
	latLngToCell :: proc ( g: ^LatLng, res: c.int, out: ^Index ) -> Error ---
	cellToLatLng :: proc ( h3: Index, g: ^LatLng ) -> Error ---
	cellToBoundary :: proc ( h3: Index, gp: ^CellBoundary ) -> Error ---
	maxGridDiskSize :: proc ( k: c.int, out: ^c.int64_t ) -> Error ---
	gridDiskUnsafe :: proc ( origin: Index, k: c.int, out: ^Index ) -> Error ---
	gridDiskDistancesUnsafe :: proc ( origin: Index, k: c.int, out: ^Index, distances: ^c.int ) -> Error ---
	gridDiskDistancesSafe :: proc ( origin: Index, k: c.int, out: ^Index, distances: ^c.int ) -> Error ---
	gridDisksUnsafe :: proc ( h3Set: ^Index, length: c.int, k: c.int, out: ^Index ) -> Error ---
	gridDisk :: proc ( origin: Index, k: c.int, out: ^Index ) -> Error ---
	gridDiskDistances :: proc ( origin: Index, k: c.int, out: ^Index, distances: ^c.int ) -> Error ---
	maxGridRingSize :: proc ( k: c.int, out: ^c.int64_t ) -> Error ---
	gridRingUnsafe :: proc ( origin: Index, k: c.int, out: ^Index ) -> Error ---
	gridRing :: proc ( origin: Index, k: c.int, out: ^Index ) -> Error ---
	maxPolygonToCellsSize :: proc ( geoPolygon: ^GeoPolygon, res: c.int, flags: c.uint32_t, out: ^c.int64_t ) -> Error ---
	polygonToCells :: proc ( geoPolygon: ^GeoPolygon, res: c.int, flags: c.uint32_t, out: ^Index ) -> Error ---
	maxPolygonToCellsSizeExperimental :: proc ( polygon: ^GeoPolygon, res: c.int, flags: c.uint32_t, out: ^c.int64_t ) -> Error ---
	polygonToCellsExperimental :: proc ( polygon: ^GeoPolygon, res: c.int, flags: c.uint32_t, size: c.int64_t, out: ^Index ) -> Error ---
	cellsToLinkedMultiPolygon :: proc ( h3Set: ^Index, numHexes: c.int, out: ^LinkedGeoPolygon ) -> Error ---
	destroyLinkedMultiPolygon :: proc ( polygon: ^LinkedGeoPolygon ) ---
	degsToRads :: proc ( degrees: c.double ) -> c.double ---
	radsToDegs :: proc ( radians: c.double ) -> c.double ---
	greatCircleDistanceRads :: proc ( a: ^LatLng, b: ^LatLng ) -> c.double ---
	greatCircleDistanceKm :: proc ( a: ^LatLng, b: ^LatLng ) -> c.double ---
	greatCircleDistanceM :: proc ( a: ^LatLng, b: ^LatLng ) -> c.double ---
	getHexagonAreaAvgKm2 :: proc ( res: c.int, out: ^c.double ) -> Error ---
	getHexagonAreaAvgM2 :: proc ( res: c.int, out: ^c.double ) -> Error ---
	cellAreaRads2 :: proc ( h: Index, out: ^c.double ) -> Error ---
	cellAreaKm2 :: proc ( h: Index, out: ^c.double ) -> Error ---
	cellAreaM2 :: proc ( h: Index, out: ^c.double ) -> Error ---
	getHexagonEdgeLengthAvgKm :: proc ( res: c.int, out: ^c.double ) -> Error ---
	getHexagonEdgeLengthAvgM :: proc ( res: c.int, out: ^c.double ) -> Error ---
	edgeLengthRads :: proc ( edge: Index, length: ^c.double ) -> Error ---
	edgeLengthKm :: proc ( edge: Index, length: ^c.double ) -> Error ---
	edgeLengthM :: proc ( edge: Index, length: ^c.double ) -> Error ---
	getNumCells :: proc ( res: c.int, out: ^c.int64_t ) -> Error ---
	res0CellCount :: proc (  ) -> c.int ---
	getRes0Cells :: proc ( out: ^Index ) -> Error ---
	pentagonCount :: proc (  ) -> c.int ---
	getPentagons :: proc ( res: c.int, out: ^Index ) -> Error ---
	getResolution :: proc ( h: Index ) -> c.int ---
	getBaseCellNumber :: proc ( h: Index ) -> c.int ---
	getIndexDigit :: proc ( h: Index, res: c.int, out: ^c.int ) -> Error ---
	constructCell :: proc ( res: c.int, baseCellNumber: c.int, digits: ^c.int, out: ^Index ) -> Error ---
	stringToH3 :: proc ( str: cstring, out: ^Index ) -> Error ---
	h3ToString :: proc ( h: Index, str: ^c.char, sz: c.size_t ) -> Error ---
	isValidCell :: proc ( h: Index ) -> c.int ---
	isValidIndex :: proc ( h: Index ) -> c.int ---
	cellToParent :: proc ( h: Index, parentRes: c.int, parent: ^Index ) -> Error ---
	cellToChildrenSize :: proc ( h: Index, childRes: c.int, out: ^c.int64_t ) -> Error ---
	cellToChildren :: proc ( h: Index, childRes: c.int, children: ^Index ) -> Error ---
	cellToCenterChild :: proc ( h: Index, childRes: c.int, child: ^Index ) -> Error ---
	cellToChildPos :: proc ( child: Index, parentRes: c.int, out: ^c.int64_t ) -> Error ---
	childPosToCell :: proc ( childPos: c.int64_t, parent: Index, childRes: c.int, child: ^Index ) -> Error ---
	compactCells :: proc ( h3Set: ^Index, compactedSet: ^Index, numHexes: c.int64_t ) -> Error ---
	uncompactCellsSize :: proc ( compactedSet: ^Index, numCompacted: c.int64_t, res: c.int, out: ^c.int64_t ) -> Error ---
	uncompactCells :: proc ( compactedSet: ^Index, numCompacted: c.int64_t, outSet: ^Index, numOut: c.int64_t, res: c.int ) -> Error ---
	isResClassIII :: proc ( h: Index ) -> c.int ---
	isPentagon :: proc ( h: Index ) -> c.int ---
	maxFaceCount :: proc ( h3: Index, out: ^c.int ) -> Error ---
	getIcosahedronFaces :: proc ( h3: Index, out: ^c.int ) -> Error ---
	areNeighborCells :: proc ( origin: Index, destination: Index, out: ^c.int ) -> Error ---
	cellsToDirectedEdge :: proc ( origin: Index, destination: Index, out: ^Index ) -> Error ---
	isValidDirectedEdge :: proc ( edge: Index ) -> c.int ---
	getDirectedEdgeOrigin :: proc ( edge: Index, out: ^Index ) -> Error ---
	getDirectedEdgeDestination :: proc ( edge: Index, out: ^Index ) -> Error ---
	directedEdgeToCells :: proc ( edge: Index, originDestination: ^Index ) -> Error ---
	originToDirectedEdges :: proc ( origin: Index, edges: ^Index ) -> Error ---
	directedEdgeToBoundary :: proc ( edge: Index, gb: ^CellBoundary ) -> Error ---
	reverseDirectedEdge :: proc ( edge: Index, out: ^Index ) -> Error ---
	cellToVertex :: proc ( origin: Index, vertexNum: c.int, out: ^Index ) -> Error ---
	cellToVertexes :: proc ( origin: Index, vertexes: ^Index ) -> Error ---
	vertexToLatLng :: proc ( vertex: Index, point: ^LatLng ) -> Error ---
	isValidVertex :: proc ( vertex: Index ) -> c.int ---
	gridDistance :: proc ( origin: Index, h3: Index, distance: ^c.int64_t ) -> Error ---
	gridPathCellsSize :: proc ( start: Index, end: Index, size: ^c.int64_t ) -> Error ---
	gridPathCells :: proc ( start: Index, end: Index, out: ^Index ) -> Error ---
	cellToLocalIj :: proc ( origin: Index, h3: Index, mode: c.uint32_t, out: ^CoordIJ ) -> Error ---
	localIjToCell :: proc ( origin: Index, ij: ^CoordIJ, mode: c.uint32_t, out: ^Index ) -> Error ---

}
