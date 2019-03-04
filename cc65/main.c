/*
 * main.c - top level 6502 C code for icestick_6502
 * 03-04-19 E. Brombaugh
 * based on example code from https://cc65.github.io/doc/customizing.html
 */
 
#define GPIO     (*(unsigned char *) 0x1000)

extern void __fastcall__ rs232_tx (char *str);

char *msg = "Hello World!\n\r";
unsigned char x = 0;
    
int main()
{
    // Run forever
    while(1)
    {
        //  Transmit "Hello World!"
        rs232_tx(msg);
        
        // write counter to GPIO
        GPIO = x;
        x++;
    }

    //  We should never get here!
    return (0);
}
