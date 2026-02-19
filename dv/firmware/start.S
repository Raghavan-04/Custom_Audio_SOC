.section .text      # Tells the compiler this is the "Code" section
.global _start      # Define the entry point for the Chip

_start:
    # --- Initialization ---
    li s0, 0x7F     # Load a 'base' audio sample (127) into a saved register
    li s1, 2        # Load a 'volume multiplier' (2x gain)
    j main_loop     # Start by jumping over the interrupt vector to main code

.org 0x20           # Force the following code to live at address 0x20
interrupt_handler:  # This is the Service Routine triggered by the Timer
    # 1. Load hardware addresses
    li t0, 0x400    # Address of the audio PWM hardware
    
    # 2. PERFORM HARDWARE MULTIPLICATION
    # This 'mul' instruction will now execute in 1 clock cycle in your ALU
    mul t1, s0, s1  # Multiply base sample (127) by gain (2). Result t1 = 254.
    
    # 3. Output to speaker
    sw t1, 0(t0)    # Write the amplified sample to the audio hardware
    
    j main_loop     # Return to background tasks

main_loop:          # The CPU's background job
    nop             # Just spinning here until the next timer interrupt
    j main_loop