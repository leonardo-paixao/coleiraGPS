#include "esp_gps.h"
#include "driver/uart.h"

#define GPS_UART_NUM UART_NUM_1
#define GPS_TXD (GPIO_NUM_17)
#define GPS_RXD (GPIO_NUM_16)
#define GPS_RTS (UART_PIN_NO_CHANGE)
#define GPS_CTS (UART_PIN_NO_CHANGE)

esp_gps_t gps;

void app_main(void) {
  uart_config_t uart_config = {
    .baud_rate = 9600,
    .data_bits = UART_DATA_8_BITS,
    .parity = UART_PARITY_DISABLE,
    .stop_bits = UART_STOP_BITS_1,
    .flow_ctrl = UART_HW_FLOWCTRL_DISABLE
  };
  uart_param_config(GPS_UART_NUM, &uart_config);
  uart_set_pin(GPS_UART_NUM, GPS_TXD, GPS_RXD, GPS_RTS, GPS_CTS);
  uart_driver_install(GPS_UART_NUM, 2048, 2048, 0, NULL, 0);

  esp_gps_init(&gps, GPS_UART_NUM);
  esp_gps_start(&gps);

  while (1) {
    esp_gps_get_data(&gps);
    if (gps.fix) {
      printf("Latitude: %.6f\n", gps.latitude);
      printf("Longitude: %.6f\n", gps.longitude);
    }
    vTaskDelay(1000 / portTICK_PERIOD_MS);
  }
}
 