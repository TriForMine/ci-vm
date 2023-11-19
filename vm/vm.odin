package main

import "core:mem"
import "core:fmt"
import "core:os"

STACK_CAP :: 256
DEBUG :: true

VM :: struct {
    chunk: ^Chunk,
    ip: ^u8,
    stack: ^Stack
}

vm : VM 

init_vm :: proc() {
    vm = VM {
        chunk = nil,
        ip = nil,
        stack = make_stack(STACK_CAP)
    }
}

free_vm :: proc() { }

InterpretResult :: enum {
    OK,
    COMPILE_ERROR,
    RUNTIME_ERROR,
}

interpret :: proc(chunk: ^Chunk) -> InterpretResult {
    vm.chunk = chunk
    vm.ip = &chunk.code[0]

    return run()
}

read_byte :: #force_inline proc() -> u8 {
    value := vm.ip^
    vm.ip = mem.ptr_offset(vm.ip, 1)

    return value
}

read_constant :: #force_inline proc() -> Value {
    return vm.chunk.constants[read_byte()]
}

Stack :: struct  {
    top: ^Value,
    values: []Value
}


make_stack :: proc(N: int) -> ^Stack {
    values := make([]Value, N)
    stack := new(Stack)
    stack.top = &values[0]
    stack.values = values

    return stack
}

delete_stack :: proc(stack: ^Stack) {
    delete(stack.values)
    free(stack)
}

push :: #force_inline proc(stack: ^Stack, value: Value) {
    when DEBUG {
        number_of_elements := mem.ptr_sub(stack.top, &stack.values[0])
        if number_of_elements >= len(stack.values) {
            fmt.println("Stack overflow!")
            os.exit(1)
        }
    }

    stack.top^ = value
    stack.top = mem.ptr_offset(stack.top, 1)
}

pop :: #force_inline proc(stack: ^Stack) -> Value {
    when DEBUG {
        number_of_elements := mem.ptr_sub(stack.top, &stack.values[0])
        if number_of_elements <= 0 {
            fmt.println("Stack underflow!")
            os.exit(1)
        }
    }

    stack.top = mem.ptr_offset(stack.top, -1)
    value := stack.top^

    return value
}

run :: proc() -> InterpretResult {
    for {
        instruction := cast(OpCode) read_byte()
        #partial switch instruction {
            case .OP_CONSTANT:
                value := read_constant()
                when DEBUG {
                    fmt.println("Value:", value)
                }
            case .OP_RETURN:
                return .OK
        }
    }

    return .RUNTIME_ERROR
}