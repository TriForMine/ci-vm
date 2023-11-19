package main

import "core:fmt"

main :: proc () {
    init_vm()
    defer free_vm()

    chunk := make_chunk();
    defer delete_chunk(chunk)

    // Set up test bytecode
    add_constant(chunk, 3, 1)
    add_constant(chunk, 2, 2)
    add_op(chunk, .OP_MUL, 3)
    add_constant(chunk, 1, 4)
    add_op(chunk, .OP_ADD, 5)
    add_constant(chunk, 15, 6)
    add_op(chunk, .OP_SUB, 7)
    add_op(chunk, .OP_RETURN, 8)

    // Print bytecode for reference
    assembly := disassemble(chunk)

    //fmt.println("Disassembled:")
    //fmt.println(assembly)

    interpret(chunk)
}