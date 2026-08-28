package h3

// H3Error is uint32_t in the C API. Keeping the enum's backing type at u32
// preserves the ABI while allowing callers to compare errors without casts.
Error :: enum u32 {
    E_SUCCESS = 0,             // Success (no error)
    E_FAILED = 1,              // The operation failed but a more specific error is not available
    E_DOMAIN = 2,              // Argument was outside of acceptable range (when a more specific error code is not available)
    E_LATLNG_DOMAIN = 3,       // Latitude or longitude arguments were outside of acceptable range
    E_RES_DOMAIN = 4,          // Resolution argument was outside of acceptable range
    E_CELL_INVALID = 5,        // `H3Index` cell argument was not valid
    E_DIR_EDGE_INVALID = 6,    // `H3Index` directed edge argument was not valid
    E_UNDIR_EDGE_INVALID = 7,  // `H3Index` undirected edge argument was not valid
    E_VERTEX_INVALID = 8,      // `H3Index` vertex argument was not valid
    E_PENTAGON = 9,            // Pentagon distortion was encountered which the algorithm could not handle it
    E_DUPLICATE_INPUT = 10,    // Duplicate input was encountered in the arguments and the algorithm could not handle it
    E_NOT_NEIGHBORS = 11,      // `H3Index` cell arguments were not neighbors
    E_RES_MISMATCH = 12,       // `H3Index` cell arguments had incompatible resolutions
    E_MEMORY_ALLOC = 13,       // Necessary memory allocation failed
    E_MEMORY_BOUNDS = 14,      // Bounds of provided memory were not large enough
    E_OPTION_INVALID = 15,     // Mode or flags argument was not valid.
    E_INDEX_INVALID = 16,      // `H3Index` argument was not valid
    E_BASE_CELL_DOMAIN = 17,   // Base cell number was outside of acceptable range
    E_DIGIT_DOMAIN = 18,       // Child digits invalid
    E_DELETED_DIGIT = 19,      // Deleted subsequence indicates invalid index
    H3_ERROR_END = 20,         // Sentinel value; not a real error
}

error_is_success :: proc(err: Error) -> bool {
    return err == .E_SUCCESS
}

error_message :: proc(err: Error) -> string {
    return string(describeH3Error(err))
}

containment_mode :: enum u32 {
    CONTAINMENT_CENTER = 0,
    CONTAINMENT_FULL = 1,
    CONTAINMENT_OVERLAPPING = 2,
    CONTAINMENT_OVERLAPPING_BBOX = 3,
    CONTAINMENT_INVALID = 4,
}
