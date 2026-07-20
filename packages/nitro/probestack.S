// Rust stack probe implementation for x86_64-linux
// Source: https://docs.rs/compiler_builtins/latest/src/compiler_builtins/probestack.rs.html
//
// Called in function prologues when stack allocation exceeds one page (4KB).
// Probes each page to ensure guard pages are hit, preventing stack clash attacks.
// ABI: stack size in %rax, must preserve %rsp and %rax on return.

.text
.global __rust_probestack
.type __rust_probestack, @function
__rust_probestack:
    .cfi_startproc
    pushq  %rbp
    .cfi_adjust_cfa_offset 8
    .cfi_offset %rbp, -16
    movq   %rsp, %rbp
    .cfi_def_cfa_register %rbp

    mov    %rax, %r11        // Save requested size (will be clobbered)

    cmp    $0x1000, %r11     // Less than one page?
    jna    3f                // Skip loop if so

2:  // Probe loop - touch each 4KB page
    sub    $0x1000, %rsp     // Move stack pointer down one page
    test   %rsp, 8(%rsp)     // Touch the page (read)
    sub    $0x1000, %r11     // Decrement remaining size
    cmp    $0x1000, %r11     // More pages to probe?
    ja     2b                // Continue loop

3:  // Handle remaining bytes (< 4KB)
    sub    %r11, %rsp        // Allocate remaining
    test   %rsp, 8(%rsp)     // Touch final page

    add    %rax, %rsp        // Restore stack pointer

    leave
    .cfi_def_cfa_register %rsp
    .cfi_adjust_cfa_offset -8
    ret
    .cfi_endproc
.size __rust_probestack, . - __rust_probestack
