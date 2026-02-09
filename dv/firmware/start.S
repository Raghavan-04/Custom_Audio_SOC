.section .text      #Tells the compiler this is the "Code" section
.global _start      # Define the entry point for the Chip

_start:
    j main_loop     # 1.Start by jumping over the interrupt vector to the main Code

.org 0x20           # Spl:Force the following code to live at address 0x20
interrupt_handler:  #This is Service routine
    li t0,  0x400   #Load the address of the audio pwm hardware
    li t1,  0xFF    #Load a high audio sample value
    sw t1,  0(t0)   #Write the sample to hardware
    j main_loop     #Return to main loop 

main_loop:          #The cpu days job
    nop             #No operation -just spinning
    j main_loop     #repeat the spinning