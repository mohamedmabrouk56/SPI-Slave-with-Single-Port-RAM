/*---------------------------------------------------------------------------
 * Module: SPI
 * Author: Mohamed Mabrouk - Abdelrahman Assem
 * Date: 2025-03-14
 * Description: Testbench for SPI module.
  ---------------------------------------------------------------------------*/
module SPI_module_tb ();
    /* Input signal declarations */    
    wire  MISO;
    reg  SS_n;
    reg  clk;
    reg  rst_n;
    /* Output signal declarations */
    reg MOSI;
    integer i;

    /* Extra Internal Signals */
    reg [7:0] tx_data_test;
    reg [9:0] input_data;

    /* Instantiate the DUT */ 
    SPI_module DUT (
        .MISO(MISO),
        .SS_n(SS_n),
        .clk(clk),
        .rst_n(rst_n),
        .MOSI(MOSI)
    );
    
    /* Clock Generation */ 
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    
    initial begin
        $readmemh("mem.dat", DUT.SPR_RAM_inst.RAM);
        /* Apply first test Case applying Reset*/
        $display("Starting simulation - Applying Reset");
        rst_n = 0;
        repeat(3) @(negedge clk); 


        /* Apply first test Case - Slave not Selected*/
        $display("Applying first test Case - Slave Not Selected");
        rst_n = 1;
        /* Not Chossing Our Slave */
        SS_n = 1;
        repeat(3) @(negedge clk); 
   

        /* Apply  Slave Selected  */
        $display("Applying second test Case - Slave Selected");
        SS_n = 0;
        @(negedge clk); 
        
        /* Apply second test Case - Slave Selected & Write Address*/

        input_data = 10'b0001010001;
        MOSI = 0;
        @(negedge clk); 
        for(i = 0; i < 10; i = i + 1) begin
            MOSI = input_data[9-i];
            @(negedge clk); 
        end
        repeat(3) @(negedge clk); 
        SS_n = 1;
        repeat(3) @(negedge clk); 

        /* Apply Third test Case - Slave Selected & Write Data*/
        input_data = 10'b0101011100;
        SS_n = 0;
        @(negedge clk); 

        MOSI = 0;
        @(negedge clk); 
        for(i = 0; i < 10; i = i + 1) begin
            MOSI = input_data[9-i];
            @(negedge clk); 
        end
        repeat(3) @(negedge clk); 
        SS_n = 1;
        repeat(3) @(negedge clk); 
        SS_n = 0;
        @(negedge clk); 
    
        /* Apply Fourth test Case - Slave Selected & Read Address */
        input_data = 10'b1001010001;
        MOSI = 1;
        @(negedge clk); 
        for(i = 0; i < 10; i = i + 1) begin
            MOSI = input_data[9-i];
            @(negedge clk); 
        end
        
        repeat(3) @(negedge clk); 
        SS_n = 1;
        repeat(3) @(negedge clk); 
        SS_n = 0;
        @(negedge clk); 
        MOSI = 1;
        @(negedge clk); 

        /* Apply Fifth test Case - Slave Selected & Read Data*/
        input_data = 10'b1101010001;
        for(i = 0; i < 10; i = i + 1) begin
            MOSI = input_data[9-i];
            @(negedge clk); 
        end

        repeat(2) @(negedge clk); 
        for(i = 0; i < 8; i = i + 1) begin
            tx_data_test[7-i] = MISO;
            @(negedge clk); 
        end

        self_checker(tx_data_test,8'b01011100);
        $display("Simulation Done"); 
        $stop;
    end
    
/* -----------------------------------------------------------
       Self-Checker Task: Compares actual vs expected output
   ----------------------------------------------------------- */
    task self_checker(input [7:0] out ,input [7:0] Data_expected); 
        begin 
            if(Data_expected != out) begin 
                $display("Test Failed: Expected = %d, Output = %d",Data_expected , out);
                $stop; 
            end 
            else
                $display("Test Passed: Expected = %d, Output = %d ",Data_expected , out); 
        end 
    endtask 

endmodule