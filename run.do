#creates work library 
vlib work 

#Compile the files of the modules 
vlog spi.v spr_ram.v spi_slave_interface.v spi_tb.v

#simulate
#-voptargs: arguments for the optimization 
#+acc:stop optimization  
vsim -voptargs=+acc work.SPI_module_tb

add wave *

#run the simulation 
run -all 
 
#quit -sim 