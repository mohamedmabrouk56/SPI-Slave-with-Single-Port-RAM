/*---------------------------------------------------------------------------
 * Module: SPI
 * Author: Mohamed Mabrouk - Abdelrahman Assem
 * Date: 2025-03-13
 * Description: Ram For SPI module.
  ---------------------------------------------------------------------------*/
module SPR_RAM #(
    parameter ADDR_SIZE = 8,

    parameter MEM_DEPTH = 256

) (
    input [9:0] din,

    input clk,

    input rst_n,

    input rx_valid,

    output reg [ADDR_SIZE-1:0] dout,

    output reg tx_valid
);
    reg [ADDR_SIZE-1:0] RAM [MEM_DEPTH-1:0];

    reg [ADDR_SIZE-1:0] addr_rd, addr_wr;

    always @(posedge clk) begin
        if(~rst_n) begin
            dout <= 0;
            tx_valid <= 0;
            addr_rd <= 0;
            addr_wr <= 0;
        end
        else begin
            case(din[9:8])
                2'b00: begin
                tx_valid <= 0;
                    if(rx_valid)
                        addr_wr <= din[7:0];
                end
                2'b01: begin
                    tx_valid <= 0;
                    if(rx_valid)
                        RAM[addr_wr] <= din[7:0];    
                end
                2'b10: begin
                    tx_valid <= 0;
                    addr_rd <= din[7:0];
                end
                2'b11: begin
                    tx_valid <= 1;
                    dout <= RAM[addr_rd];
                end
            endcase
        end
    end
endmodule