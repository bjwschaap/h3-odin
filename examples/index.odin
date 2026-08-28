package examples
import "core:fmt"
import h3 "../"

index :: proc(){
    // Get the H3 index of some location and print it.
    location: h3.LatLng
    location.lat = h3.degsToRads(40.689167)
    location.lng = h3.degsToRads(-74.044444)
    resolution: i32 = 10
    indexed: h3.Index

    if err := h3.latLngToCell(&location, resolution, &indexed); err != .E_SUCCESS {
        fmt.println(h3.error_message(err))
        return
    }

    fmt.printf("The index is: %x\n", indexed)

    // Get the vertices of the H3 index.
    boundary: h3.CellBoundary
    if err := h3.cellToBoundary(indexed, &boundary); err != .E_SUCCESS {
        fmt.println(h3.error_message(err))
        return
    }
    
    // Indexes can have different number of vertices under some cases,
    // which is why boundary.numVerts is needed.
    for v in 0..<int(boundary.numVerts) {
        fmt.printf("Boundary vertex #%d: %.6f, %.6f\n",
                v,
                h3.radsToDegs(boundary.verts[v].lat),
                h3.radsToDegs(boundary.verts[v].lng))
    }

    // Get the center coordinates.
    center: h3.LatLng
    if err := h3.cellToLatLng(indexed, &center); err != .E_SUCCESS {
        fmt.println(h3.error_message(err))
        return
    }
    
    fmt.printf("Center coordinates: %.6f, %.6f\n", h3.radsToDegs(center.lat),
           h3.radsToDegs(center.lng))
}
