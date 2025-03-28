module SPI_module (
    output  MISO,
    
    input SS_n,

    input clk,
    
    input rst_n,
    
    input MOSI
);
wire [9:0] rx_data;
wire  rx_valid;
wire [7:0] tx_data;
wire  tx_valid;

SPI_Slave_interface SPI_Slave_interface_inst (
    .MISO(MISO),
    .SS_n(SS_n),
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_data),
    .tx_valid(tx_valid),
    .MOSI(MOSI),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
);

SPR_RAM SPR_RAM_inst (
    .din(rx_data),
    .clk(clk),
    .rst_n(rst_n),
    .rx_valid(rx_valid),
    .dout(tx_data),
    .tx_valid(tx_valid)
);


endmodule