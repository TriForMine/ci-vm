package main

import "core:fmt"
import "core:strings"

OpCode :: enum {
    OP_CONSTANT,
    OP_RETURN,
}

Chunk :: struct {
    code : [dynamic]u8,
    line_numbers: map[int]int,
    constants: ValueArray,
}

add_constant :: proc(chunk: ^Chunk, value: Value, line_number: int) {
    append(&chunk.constants, value)
    constant_idx := len(chunk.constants) - 1;

    add_op(chunk, .OP_CONSTANT, line_number)
    append(&chunk.code, cast(u8)constant_idx)
}

add_op :: proc(chunk: ^Chunk, op: OpCode, line_number: int) {
    append(&chunk.code, cast(u8)op)

    chunk.line_numbers[len(chunk.code) - 1] = line_number
}

make_chunk :: proc(code_cap := 0, constants_cap := 0) -> ^Chunk {
    chunk := new(Chunk)
    code := make([dynamic]u8, 0, code_cap)
    constants := make(ValueArray, 0, constants_cap)

    chunk.code = code
    chunk.constants = constants

    return chunk
}

delete_chunk :: proc(chunk: ^Chunk) {
    delete(chunk.code)
    delete(chunk.constants)
    delete(chunk.line_numbers)
    free(chunk)
}

disassemble :: proc(chunk: ^Chunk) -> string {
    output := "Instructions:\n"
    temp: string = ""

    index := 0
    inst_count := 0
    for index < len(chunk.code) {
        // Write OPCode
        byte_inst := chunk.code[index]
        op_code_string := OpCode(byte_inst)
        temp = strings.concatenate({temp, fmt.tprintf("    %04v %v", inst_count, op_code_string)})

        line_number := chunk.line_numbers[index]

        // Handle OPCodes that have operands
        if op_code_string == .OP_CONSTANT {
            // Read the address 
            // Print address next to opcode
            // Advance pointer 2 bytes
            address := chunk.code[index + 1]
            temp = strings.concatenate({temp, fmt.tprintf(" %04v", address)})
            index += 1
        }

        // Padding
        temp = strings.left_justify(temp, 30, " ")

        temp = strings.concatenate({temp, fmt.tprintf(" | Line: %04v", line_number)})
        temp = strings.concatenate({temp, "\n"})

        inst_count += 1
        index += 1

        output = strings.concatenate({output, temp})
        temp = ""
        
    }

    output = strings.concatenate({output, "\nConstants:\n"})

    for constant , index in chunk.constants {
        output = strings.concatenate({output, fmt.tprintf("    %04v %v '%v'\n", index, "CONSTANT", constant)})
    }

    output = strings.concatenate({output, "\n"})

    return output
}