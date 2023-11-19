package main

import "core:mem"
import "core:fmt"
import "core:os"

_DEBUG      :: false
DEBUG       :: _DEBUG
DEBUG_TRACE :: _DEBUG

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

apply :: proc(op: proc(a: Value, b: Value) -> Value) {
    b := pop(vm.stack)
    a := pop(vm.stack)
    push(vm.stack, op(a, b))
}

run :: proc() -> InterpretResult {
    for {
        when DEBUG_TRACE {
            // Print the content of the stack
            fmt.println("--- Stack ---")
            fmt.print("[")
            for value, i in &vm.stack.values {
                if &value == vm.stack.top {
                    break
                }
                if i > 0 {
                    fmt.print(", ")
                }
                fmt.print(value)
            }
            fmt.println("]")
            fmt.println("--- /Stack ---")
        }
        instruction := cast(OpCode) read_byte()
        switch instruction {
            case .OP_CONSTANT:
                value := read_constant()
                push(vm.stack, value)
                when DEBUG {
                    fmt.println("Value:", value)
                }
            case .OP_NEGATE:
                value := pop(vm.stack)
                push(vm.stack, -value)
            case .OP_ADD: apply(proc(a: Value, b: Value) -> Value { return a + b })
            case .OP_SUB: apply(proc(a: Value, b: Value) -> Value { return a - b })
            case .OP_MUL: apply(proc(a: Value, b: Value) -> Value { return a * b })
            case .OP_DIV: apply(proc(a: Value, b: Value) -> Value { return a / b })
            case .OP_RETURN:
                value := pop(vm.stack)
                fmt.println(value)
                return .OK
        }
    }

    return .RUNTIME_ERROR
}