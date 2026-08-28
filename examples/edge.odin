package examples
import "core:fmt"
import h3 "../"

edge :: proc() {
    edge: h3.Index
    origin: h3.Index = 0x8a2a1072b59ffff
    destination: h3.Index = 0x8a2a1072b597fff
    assert_success(h3.cellsToDirectedEdge(origin, destination, &edge))
    fmt.printf("The edge is %x\n", edge)

    boundary: h3.CellBoundary
    assert_success(h3.directedEdgeToBoundary(edge, &boundary))
    for i in 0..<int(boundary.numVerts) {
        pos_degrees := h3.lat_lng_to_degrees(boundary.verts[i])
        fmt.printf("Edge vertex #%d: %.6f, %.6f\n", i, pos_degrees.lat, pos_degrees.lng)
    }

    // Output:
    // The edge is 16a2a1072b59ffff
    // Edge vertex #0: 40.690059, -74.044152
    // Edge vertex #1: 40.689908, -74.045062

    fmt.println("===== end of edge example =====")
}
