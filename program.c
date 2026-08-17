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

int DELAY = 5;

void main() {
    // int i = 0;
    
    // char c = get_char();
    // put_char(c);

    while (1) {
        // if (gpio_read(3)) {
        //     gpio_write(0,1);
        // } else {
        //     gpio_write(0,0);
        // }
        // int j = gpio_read(4);
        // put_char(j);
        // put_char(test3);
        // i++;
        // for (int i = 0; i < 6; i++) {
        //     delay(27000000);
        //     gpio_read()
        // }
        // if (gpio_read(0)) { 
        //     gpio_write(0,1);
        // }
        // gpio_write(0,0);

        gpio_write(0,1);
        delay(DELAY);
        gpio_write(0,0);
        delay(DELAY);
        gpio_write(5,1);
        delay(DELAY);
        gpio_write(5,0);
        delay(DELAY);
    }
}