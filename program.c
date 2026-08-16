#define UART_TX (*(volatile unsigned char*)0x10000000)
#define UART_RX (*(volatile unsigned char*)0x10000010)
#define UART_STATUS (*(volatile unsigned char*)0x10000014)
#define GPIO_IN (*(volatile unsigned char*)0x1000001c)
#define GPIO_OUT (*(volatile unsigned char*)0x10000020)
#define TIMER_COUNT (*(volatile unsigned int*)0x10000024)


// void put_char(char c) {
//     UART_TX = c;
// }

// char get_char() {
//     while (!UART_STATUS){

//     }
//     return UART_RX;
// }

void delay(unsigned int cycles)
{
    unsigned int start = TIMER_COUNT;

    while ((TIMER_COUNT - start) < cycles) {
    }
}



void main() {
    // char message[] = "Hello World";

    // for (int i = 0; i<11; i++) {
    //     put_char(message[i]);
    // }

    // if (GPIO_IN) {
    //     GPIO_OUT =1;
    // }

    // unsigned int start = TIMER_COUNT;
    // unsigned int state = 0;

    // GPIO_OUT = 0;
    while (1) {
        // char c = get_char();
        // put_char(c);
        GPIO_OUT = 1;
        delay(27000000);

        GPIO_OUT = 0;
        delay(27000000);

        GPIO_OUT = 1;
        delay(27000000*2);

        GPIO_OUT = 0;
        delay(27000000*2);

        GPIO_OUT = 1;
        delay(27000000*4);

        GPIO_OUT = 0;
        delay(27000000*4);
    }
}