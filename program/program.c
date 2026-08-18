#define UART_TX (*(volatile unsigned char*)0x10000000)
#define UART_RX (*(volatile unsigned char*)0x10000010)
#define UART_STATUS (*(volatile unsigned char*)0x10000014)
#define GPIO_IN (*(volatile unsigned short*)0x1000001c)
#define GPIO_OUT (*(volatile unsigned short*)0x10000020)
#define TIMER_COUNT (*(volatile unsigned int*)0x10000024)

int test1 = 1234;
int test2 = 0xDEADBEEF;
unsigned char test3 = 0xAB;

void put_char(char c) {
    UART_TX = c;
}

char get_char() {
    while (!UART_STATUS){

    }
    return UART_RX;
}

void delay(unsigned int cycles)
{
    unsigned int start = TIMER_COUNT;

    while ((TIMER_COUNT - start) < cycles) {
    }
}

void gpio_write(int pin, int value)
{
    if (value)
        GPIO_OUT |= (1u << pin);
    else
        GPIO_OUT &= ~(1u << pin);
}

int gpio_read(int pin) { return (GPIO_IN >> pin) & 1; }

int DELAY = 13500000;

void main() {

    while (1) {
        for (int i = 0; i < 6; i++) {
            for (int j = 0; j < 6; j++) {
                if (j != i) {
                    gpio_write(j,1);
                } else {
                    gpio_write(j,0);
                }
            }
            delay(DELAY);
        }
    }
}
