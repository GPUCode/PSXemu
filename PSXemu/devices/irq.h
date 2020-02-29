#pragma once
#include <cstdint>
#include <cstdio>
#include <cpu/util.h>

enum class ExceptionType{
    Interrupt = 0x0,
    ReadError = 0x4,
    WriteError = 0x5,
    BusError = 0x6,
    Syscall = 0x8,
    Break = 0x9,
    IllegalInstr = 0xA,
    CoprocessorError = 0xB,
    Overflow = 0xC
};

enum class Interrupt {
    VBLANK = 0,
    GPU_IRQ = 1,
    CDROM = 2,
    DMA = 3,
    TIMER0 = 4,
    TIMER1 = 5,
    TIMER2 = 6,
    CONTR = 7,
    SIO = 8,
    SPU = 9,
    PIO = 10
};

class InterruptController {
public:
    uint32_t ISTAT = 0;
    uint32_t IMASK = 0;

    void set(Interrupt interrupt) {
        ISTAT = set_bit(ISTAT, (int)interrupt, true);
    }

    void writeISTAT(uint32_t value) {
        ISTAT &= value;
    }

    void writeIMASK(uint32_t value) {
        IMASK = value & 0x7FF;
    }

    uint32_t loadISTAT() {
        return ISTAT;
    }

    uint32_t loadIMASK() {
        return IMASK;
    }

    bool interruptPending() {
        return (ISTAT & IMASK) != 0;
    }
};