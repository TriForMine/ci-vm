package main

import "core:fmt"

main :: proc () {
    stack : ^Stack = make_stack(8)
    defer delete_stack(stack)

    push(stack, 0.1)

    fmt.println(stack.top)
    fmt.println(stack.values)
    
    value := pop(stack)
    fmt.println(value)
    
    /*
    init_vm()
    defer free_vm()

    chunk := make_chunk();
    defer delete_chunk(chunk)

    // Set up test bytecode
    add_constant(chunk, 3, 1)
    add_constant(chunk, 15, 2)
    add_constant(chunk, 23, 3)

    add_op(chunk, .OP_RETURN, 4)

    // Print bytecode for reference
    assembly := disassemble(chunk)

    fmt.println("Disassembled:")
    fmt.println(assembly)

    interpret(chunk)*/
}