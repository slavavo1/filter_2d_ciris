`include "fir_2d.svh"
module paralel_sum #(
	parameter                                    NUMBER_OF_INPUTS = 16    ,
	parameter                                    BITS_PER_SYMBOL  = 16    ,
	parameter                                    SIGNED_B         = 1     ,
	parameter                                    RST_ON           = 1     ,
	parameter bit [$clog2(NUMBER_OF_INPUTS)-1:0] REG_CONV         = 'b1111
) (
	input                                                              clk_i  ,
	input                                                              rst_n_i,
	input                                                              ena_i  ,
	`ifdef SIGNED_IN
	input  logic signed [        NUMBER_OF_INPUTS*BITS_PER_SYMBOL-1:0] data_i ,
	output logic signed [BITS_PER_SYMBOL+$clog2(NUMBER_OF_INPUTS)-1:0] data_o
	`else
	input  logic        [        NUMBER_OF_INPUTS*BITS_PER_SYMBOL-1:0] data_i ,
	output logic        [BITS_PER_SYMBOL+$clog2(NUMBER_OF_INPUTS)-1:0] data_o
	`endif
);

/*------------------------------------------------------------------------------
--  
------------------------------------------------------------------------------*/
	genvar i,j;

  `ifdef SIGNED_IN
		logic signed [NUMBER_OF_INPUTS/2-1:0][$clog2(NUMBER_OF_INPUTS)-1:0][BITS_PER_SYMBOL+$clog2(NUMBER_OF_INPUTS)-1:0] data_sum;
	`else
		logic [NUMBER_OF_INPUTS/2-1:0][$clog2(NUMBER_OF_INPUTS)-1:0][BITS_PER_SYMBOL+$clog2(NUMBER_OF_INPUTS)-1:0] data_sum;
  `endif

	generate begin
		for (j = 0; j < $clog2(NUMBER_OF_INPUTS); j++) begin : NUM1
			for (i = 0; i < NUMBER_OF_INPUTS/(j+1)/2; i++) begin : NUM2

				if(j==0 & REG_CONV[0]==1'b1)

					always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_data_sum
						if(!rst_n_i) begin
							data_sum[i][j][BITS_PER_SYMBOL+j:0] <= {(BITS_PER_SYMBOL+j+1){1'b0}};
						end else if(ena_i) begin
							data_sum[i][j][BITS_PER_SYMBOL+j:0] <= signed'(data_i[BITS_PER_SYMBOL*(i*2+1)-1:BITS_PER_SYMBOL*i*2] + 
										                                   data_i[BITS_PER_SYMBOL*(i*2+2)-1:BITS_PER_SYMBOL*(i*2+1)]);
						end
					end

				else if (REG_CONV[j]==1'b1)

					always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_data_sum
						if(!rst_n_i) begin
							data_sum[i][j][BITS_PER_SYMBOL+j:0] <= {(BITS_PER_SYMBOL+j+1){1'b0}};
						end else if(ena_i) begin
							data_sum[i][j][BITS_PER_SYMBOL+j:0] <= signed'(data_sum[  i*2][j-1][BITS_PER_SYMBOL+j-2:0] + 
							                                         data_sum[i*2+1][j-1][BITS_PER_SYMBOL+j-2:0]);
						end
					end

				else if(j==0)
					assign data_sum[i][j][BITS_PER_SYMBOL+j:0] = signed'(data_i[BITS_PER_SYMBOL*(i*2+1)-1:BITS_PER_SYMBOL*i*2] + 
										                                     data_i[BITS_PER_SYMBOL*(i*2+2)-1:BITS_PER_SYMBOL*(i*2+1)]);
				else
					assign data_sum[i][j][BITS_PER_SYMBOL+j:0] = signed'(data_sum[  i*2][j-1][BITS_PER_SYMBOL+j-2:0] + 
				                                                 data_sum[i*2+1][j-1][BITS_PER_SYMBOL+j-2:0]);
			end
		end
	end endgenerate

	assign data_o = data_sum[0][$clog2(NUMBER_OF_INPUTS)-1];

endmodule