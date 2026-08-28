package examples

import "core:fmt"
import "base:runtime"
import h3 "../"

compactCells :: proc(){
    input: []h3.Index = []h3.Index{
        // All with the same parent index
        0x8a2a1072b587fff, 0x8a2a1072b5b7fff, 0x8a2a1072b597fff,
        0x8a2a1072b59ffff, 0x8a2a1072b58ffff, 0x8a2a1072b5affff,
        0x8a2a1072b5a7fff,
        // These don't have the same parent index as above.
        0x8a2a1070c96ffff, 0x8a2a1072b4b7fff, 0x8a2a1072b4a7fff
    }

    inputSize := len(input)
    fmt.printf("Starting with %d indexes.\n", inputSize);

    compacted := make([]h3.Index, inputSize)
    defer delete(compacted)
    err := h3.compactCells(&input[0], &compacted[0], i64(inputSize))
    // An error case can occur on e.g. duplicate input.
    runtime.assert(h3.error_is_success(err))

    compactedCount := 0
    fmt.println("Compacted:")
    for i:=0 ; i<inputSize ; i+=1 {
        if compacted[i] != 0 {
            fmt.printf("%x\n", compacted[i])
            compactedCount+=1
        }
    }
    fmt.printf("Compacted to %d indexes.\n", compactedCount)
    
    uncompactedRes: i32 = 10
    uncompactedSize: i64
    err2 := h3.uncompactCellsSize(&compacted[0], i64(compactedCount), uncompactedRes, &uncompactedSize)
    runtime.assert(h3.error_is_success(err2))
    uncompacted := make([]h3.Index, int(uncompactedSize))
    defer delete(uncompacted)
    err3 := h3.uncompactCells(&compacted[0], i64(compactedCount), &uncompacted[0], i64(uncompactedSize), uncompactedRes)
    runtime.assert(h3.error_is_success(err3))

    uncompactedCount := 0
    fmt.println("Uncompacted:");
    for i := 0; i < int(uncompactedSize); i+=1 {
        if (uncompacted[i] != 0) {
            fmt.printf("%x\n", uncompacted[i]);
            uncompactedCount+=1;
        }
    }
    fmt.printf("Uncompacted to %d indexes.\n", uncompactedCount);
}
