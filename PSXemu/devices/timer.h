#pragma once
#include <cstdint>
#include <cpu/enum.h>

enum class TimerID {
	TMR0 = 0,
	TMR1 = 1,
	TMR2 = 2
};

enum class SyncMode : uint32_t {
	/* For timers 0 and 1. */
	Pause = 0,
	Reset = 1,
	ResetPause = 2,
	PauseFreeRun = 3,

	/* For timer 2. */
	FreeRun = 4,
	Stop = 5
};

enum class ClockSrc : uint32_t {
	System,
	SystemDiv8,
	Dotclock,
	Hblank,
};

enum class ResetWhen : uint32_t {
	Overflow = 0,
	Target = 1
};

enum class IRQRepeat : uint32_t {
	OneShot = 0,
	Repeatedly = 1
};

enum class IRQToggle : uint32_t {
	Pulse = 0,
	Toggle = 1
};

typedef uint16_t CounterValue;

union CounterControl {
	uint32_t raw;

	struct {
		uint32_t sync_enable : 1;
		uint32_t sync_mode : 2;
		ResetWhen reset : 1;
		uint32_t irq_when_target : 1;
		uint32_t irq_when_overflow : 1;
		IRQRepeat irq_repeat_mode : 1;
		IRQToggle irq_pulse_mode : 1;
		uint32_t clock_source : 2;
		uint32_t irq_request : 1;
		uint32_t reached_target : 1;
		uint32_t reached_overflow : 1;
		uint32_t : 19;
	};
};

typedef uint16_t CounterTarget;

class Bus;
class Timer {
public:
	Timer() = default;
	~Timer() = default;

	void init(TimerID type, Bus* _bus);

	/* Trigger an interrupt. */
	void fire_irq();

	/* Add cycles to the timer. */
	void tick();

	/* Map timer to interrupt type. */
	Interrupt irq_type();

	/* Read/Write to the timer. */
	uint32_t read(uint32_t offset);
	void write(uint32_t offset, uint32_t data);

	/* Get the timer's clock source. */
	ClockSrc get_clock_source();

	/* Get the timer's sync mode. */
	SyncMode get_sync_mode();

public:
	CounterValue counter;
	CounterControl control;
	CounterTarget target;

	bool paused, one_shot_irq;
	uint32_t divider;

	TimerID timer_id;
	Bus* bus;
};