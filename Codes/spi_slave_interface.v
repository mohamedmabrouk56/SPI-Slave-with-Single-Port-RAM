/*---------------------------------------------------------------------------
 * Module: SPI
 * Author: Mohamed Mabrouk - Abdelrahman Assem
 * Date: 2025-03-12
 * Description: SPI Slave Interface for SPI module.
  ---------------------------------------------------------------------------*/
module SPI_Slave_interface #(
    /* FSM Encoding Type */
    parameter FSM_ENCODING = "sequential"
)
(
    /* MOSI: Master Out Slave In */
    input  MOSI,
    
    /* SS_n: Slave Select (Active Low) */
    input SS_n,

    /* clk: Clock Signal */
    input clk,
    
    /* rst_n: Active Low Reset */
    input rst_n,

    /* tx_data: Data to be transmitted */
    input [7:0] tx_data,

    /* tx_valid: Indicates valid transmission data */
    input tx_valid,

    /* MISO: Master In Slave Out */
    output reg MISO,

    /* rx_data: Received Data */
    output reg [9:0] rx_data,

    /* rx_valid: Indicates valid received data */
    output reg rx_valid
);

  // Define state codes uniformly as 3-bit values

  localparam [4:0] IDLE = 0;                
  localparam [4:0] CHK_CMD = 1;      
  localparam [4:0] WRITE = 2;
  localparam [4:0] READ_ADD = 3;   
  localparam [4:0] READ_DATA = 4;

  // Attach the FSM encoding attribute directly to the state registers.
  (* fsm_encoding = FSM_ENCODING *)

    /* Registers for current and next state */
    reg [2:0] cs, ns;
    
    /* Flag to indicate Data Address */
    reg Data_ADD_FLAG;
    
    /* Counters for serial-to-parallel and parallel-to-serial conversion */
    integer CounterP2S;
    integer CounterS2P;
    
    /* State Memory */
    always@(posedge clk) begin
        if (~rst_n) begin
            /* Reset to IDLE state */
            cs <= IDLE;
        end    
        else begin
            /* Transition to next state */
            cs <= ns;
        end
    end

    /* Next State Logic */
    always@(*) begin
        if (~rst_n) begin
            /* Reset state */
            ns = IDLE;
        end
        else begin
            case (cs)
                IDLE: begin 
                    if (SS_n == 0) begin
                        ns = CHK_CMD;
                    end
                    else begin
                        ns = IDLE;
                    end
                end
                CHK_CMD: begin
                    if (SS_n) begin
                        ns = IDLE;
                    end
                    else if (SS_n == 0 && MOSI == 0) begin
                        ns = WRITE;
                    end
                    else if (SS_n == 0 && MOSI == 1) begin
                        if (Data_ADD_FLAG == 0) begin
                            ns = READ_ADD;
                        end
                        else begin
                            ns = READ_DATA;
                        end
                    end
                end
                WRITE: begin
                    if (SS_n) begin
                        ns = IDLE;
                    end
                    else begin
                        ns = WRITE;
                    end
                end
                READ_ADD: begin
                    if (SS_n) begin
                        ns = IDLE;
                    end
                    else begin
                        ns = READ_ADD;
                    end
                end
                READ_DATA: begin
                    if (SS_n) begin
                        ns = IDLE;
                    end
                    else begin
                        ns = READ_DATA;
                    end        
                end
                default: begin
                    ns = IDLE;
                end
            endcase
        end
    end

    /* Output Logic */
    always@(posedge clk) begin
        if (~rst_n) begin
            /* Reset output signals */
            MISO <= 0;
            rx_data <= 0;
            rx_valid <= 0;
            CounterP2S <= 0;
            CounterS2P <= 0;
            Data_ADD_FLAG <= 0;
        end
        else begin
            case (cs)
                IDLE: begin
                    /* Reset values in IDLE state */
                    MISO <= 0;
                    rx_data <= 10'b0;
                    rx_valid <= 0;
                    CounterP2S <= 0;
                    CounterS2P <= 0;
                end
                CHK_CMD: begin
                    /* Reset values in CHK_CMD state */
                    MISO <= 0;
                    rx_data <= 10'b0;
                    rx_valid <= 0;
                    CounterP2S <= 0;
                    CounterS2P <= 0;
                end
                WRITE: begin
                    if(CounterP2S < 10) begin
                        /* Shift and store MOSI data */
                        rx_data <= (rx_data << 1) + MOSI;
                        if(CounterP2S == 9) begin
                            rx_valid <= 1;
                        end
                        CounterP2S <= CounterP2S + 1;
                    end
                end
                READ_ADD: begin
                    if(CounterP2S < 10) begin
                        /* Read Address Data */
                        rx_data <= (rx_data << 1) + MOSI;
                        if(CounterP2S == 9) begin
                            rx_valid <= 1;
                            Data_ADD_FLAG <= 1;
                        end
                        CounterP2S <= CounterP2S + 1;
                    end
                end
                READ_DATA: begin
                    if (tx_valid && CounterS2P < 8) begin
                        /* Send Data via MISO */
                        MISO <= (tx_data[7 - CounterS2P]);
                        CounterS2P <= CounterS2P + 1;
                    end
                    else begin
                        if(CounterP2S < 10) begin
                            /* Shift and store MOSI data */
                            rx_data <= (rx_data << 1) + MOSI;
                            if(CounterP2S == 9) begin
                                rx_valid <= 1;
                                Data_ADD_FLAG <= 0;
                            end
                            CounterP2S <= CounterP2S + 1;
                        end
                    end
                end
                default: begin
                    /* Default state resets outputs */
                    MISO <= 0;
                    rx_valid <= 0;
                    rx_data <= 10'b0;
                end
            endcase
        end
    end

endmodule