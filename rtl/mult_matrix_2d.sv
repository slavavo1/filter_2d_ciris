`include "fir_2d.svh"
(* use_dsp = "yes" *)
(* multstyle = "dsp" *)
module mult_matrix_2d #(
  parameter MATRIX_SIZE_H       = 7                                 ,
  parameter MATRIX_SIZE_V       = 7                                 ,
  parameter BITS_PER_SYMBOL     = 8                                 ,
  parameter CONVEYOR_IN         = 1                                 ,
  parameter CONVEYOR_MID        = 1                                 ,
  parameter CONVEYOR_OUT        = 1                                 ,
  parameter ENA_ON              = 1                                 ,
  parameter RST_ON              = 1                                 ,
  parameter SIGNED_B            = 0                                 ,
  parameter CONVEYOR_MULT       = 2                                 ,
  parameter CONVEYOR_SHIFT      = 1                                 ,
  parameter CONVEYOR_SUM        = 2                                 ,
  parameter SHIFT_OUT           = 8                                 ,
  parameter COEFF_WIDTH         = 8                                 ,
  parameter MATRIX_SIZE         = MATRIX_SIZE_H*MATRIX_SIZE_V       ,
  parameter SIGNED_CALCULATIONS = (SIGNED_B) ? "SIGNED" : "UNSIGNED",
  parameter bit [$clog2(2**($clog2(MATRIX_SIZE)))-1:0] REG_CONV = 'b1111
) (
  input                                                                      clk_i                         ,
  input                                                                      rst_n_i                       ,
  //din
  input  logic        [             BITS_PER_SYMBOL-1:0] din_dataa_i [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0],
  input  logic        [$clog2(2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE))-1:0] shift_out                                         ,
  `ifdef SIGNED_IN
  input  logic signed [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][COEFF_WIDTH-1:0] din_datab_i                  ,
  `else 
  input  logic        [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][COEFF_WIDTH-1:0] din_datab_i                  ,
  `endif 
  input  logic                                                                din_ena_i                    ,
  //dout
  output logic        [BITS_PER_SYMBOL-1:0]                                   dout_data_o
);
/*------------------------------------------------------------------------------
-- wires for connection and reg 
------------------------------------------------------------------------------*/
  `ifdef SIGNED_IN

    logic signed [BITS_PER_SYMBOL-!(SIGNED_B):0] dataa [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0];

    logic signed [2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE)-1:0] data_out_l;
    logic signed [2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE)-1:0] data_shift;

    logic signed [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][BITS_PER_SYMBOL+COEFF_WIDTH:0] result  ;
    logic signed [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][BITS_PER_SYMBOL+COEFF_WIDTH-2:0] result_l;
    logic signed [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][BITS_PER_SYMBOL+COEFF_WIDTH-2:0] result_w;


  `else

    logic [BITS_PER_SYMBOL-1:0] dataa[MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0];

    logic [2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE)-1:0] data_out_l;
    logic [2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE)-1:0] data_shift;

    logic [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][BITS_PER_SYMBOL+COEFF_WIDTH-1:0] result;
    logic [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][BITS_PER_SYMBOL+COEFF_WIDTH-1:0] result_l;
    logic [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][BITS_PER_SYMBOL+COEFF_WIDTH-1:0] result_w;
  `endif

  logic sign;

  logic [2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE)-SIGNED_B-1:BITS_PER_SYMBOL] overflow;

  logic [BITS_PER_SYMBOL-1:0] data_in_l[MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0];

  genvar x, y, z;
/*------------------------------------------------------------------------------
--
------------------------------------------------------------------------------*/
  generate begin

    assign sign = data_out_l[2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE)-1];

    for (x = 0; x < MATRIX_SIZE_V; x++) begin : SIGN_X_1
      for (y = 0; y < MATRIX_SIZE_H; y++) begin : SIGN_Y_1
        if (SIGNED_B) begin
          assign dataa[x][y] = signed'({1'b0,data_in_l[x][y]});
        end else begin
          assign dataa[x][y] = data_in_l[x][y];
        end
      end
    end

    for (x = 0; x < MATRIX_SIZE_V; x++) begin : MULT1
      for (y = 0; y < MATRIX_SIZE_H; y++) begin : MULT2

        `ifdef INTEL
          lpm_mult lpm_mult_component (
            .dataa (dataa[x][y]                        ),
            .datab (din_datab_i[x][y]                  ),
            .result(result[x][y]                       ),
            .aclr  ((CONVEYOR_MULT>0)? !rst_n_i  : 1'b0),
            .clken ((CONVEYOR_MULT>0)? din_ena_i : 1'b0),
            .clock ((CONVEYOR_MULT>0)? clk_i     : 1'b0),
            .sclr  (1'b0                               ),
            .sum   (1'b0                               )
          );

          defparam
            lpm_mult_component.lpm_hint = "DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_SPEED=9",
              lpm_mult_component.lpm_pipeline = CONVEYOR_MULT,
                lpm_mult_component.lpm_representation = SIGNED_CALCULATIONS,
                  lpm_mult_component.lpm_type = "LPM_MULT",
                    lpm_mult_component.lpm_widtha = BITS_PER_SYMBOL+SIGNED_B,
                      lpm_mult_component.lpm_widthb = COEFF_WIDTH,
                        lpm_mult_component.lpm_widthp = BITS_PER_SYMBOL+COEFF_WIDTH+SIGNED_B;

        `else

          if (SIGNED_B)
            assign result[x][y] = signed'(dataa[x][y] * din_datab_i[x][y]);
          else
            assign result[x][y] = dataa[x][y] * din_datab_i[x][y];

        `endif
      end
    end

    if (SIGNED_B) begin

      for (x = 0; x < MATRIX_SIZE_V; x++) begin : SIGN_X
        for (y = 0; y < MATRIX_SIZE_H; y++) begin : SIGN_Y
          for (z = 0; z < BITS_PER_SYMBOL+COEFF_WIDTH-1; z++) begin : SIGN_Z
            if(z == BITS_PER_SYMBOL+COEFF_WIDTH-2)
              assign result_w[x][y][z] = result[x][y][BITS_PER_SYMBOL+COEFF_WIDTH];
            else
              assign result_w[x][y][z] = result[x][y][z];
          end
        end
      end

    end else begin

      assign result_w = result;

    end


    for (x = 0; x < MATRIX_SIZE_V; x++) begin : DATA_X
      for (y = 0; y < MATRIX_SIZE_H; y++) begin : DATA_Y
        if (CONVEYOR_IN)

            always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_reg_mid
              if(!rst_n_i|!RST_ON)
                data_in_l[x][y] <= {BITS_PER_SYMBOL{1'b0}};
              else if(din_ena_i|!ENA_ON)
                data_in_l[x][y] <= din_dataa_i[x][y];
            end

        else
          assign data_in_l[x][y] = din_dataa_i[x][y];
      end
    end

    for (x = 0; x < MATRIX_SIZE_V; x++) begin : DATA_X_1
      for (y = 0; y < MATRIX_SIZE_H; y++) begin : DATA_Y_1
        if (CONVEYOR_MID) begin

            always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_reg_mid
              if(!rst_n_i|!RST_ON)
                result_l[x][y] <= {BITS_PER_SYMBOL+COEFF_WIDTH{1'b0}};
              else if(din_ena_i|!ENA_ON)
                result_l[x][y] <= result_w[x][y];
            end

        end else if (!CONVEYOR_MID) begin
          assign result_l[x][y] = result[x][y];
        end
      end
    end

    for (x = BITS_PER_SYMBOL;
      x < 2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE)-SIGNED_B;
      x++)  begin : proc_overflow
      assign overflow[x] = data_shift[x];
    end

    if(CONVEYOR_SHIFT)
      always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_data_shift
        if(!rst_n_i|!RST_ON)
          data_shift <= {2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE){1'b0}};
        else if(din_ena_i|!ENA_ON)
          data_shift <= (data_out_l >>> (shift_out));
      end
    else
      assign data_shift = (data_out_l >>> (shift_out));

    if (SIGNED_B) begin

      if (CONVEYOR_OUT) begin

        always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_dout_data_o
          if(!rst_n_i|!RST_ON)
            dout_data_o <= {BITS_PER_SYMBOL{1'b0}};
          else if (sign)
            dout_data_o <= {BITS_PER_SYMBOL{1'b0}};
          else if(din_ena_i|!ENA_ON)
            dout_data_o <= (|overflow) ? {BITS_PER_SYMBOL{1'b1}} : data_shift[BITS_PER_SYMBOL-1:0];
        end

      end else if (!CONVEYOR_OUT) begin

        assign dout_data_o = (~sign) & (|overflow) ? {BITS_PER_SYMBOL{1'b1}} : data_shift[BITS_PER_SYMBOL-1:0];

      end
    end else begin

      if (CONVEYOR_OUT) begin

        always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_dout_data_o
          if(!rst_n_i|!RST_ON)
            dout_data_o <= {BITS_PER_SYMBOL{1'b0}};
          else if(din_ena_i|!ENA_ON)
            dout_data_o <= (|overflow) ? {BITS_PER_SYMBOL{1'b1}} : data_shift[BITS_PER_SYMBOL-1:0];
        end

      end else if (!CONVEYOR_OUT) begin

        assign dout_data_o = (|overflow) ? {BITS_PER_SYMBOL{1'b1}} : data_shift[BITS_PER_SYMBOL-1:0];

      end
    end
  end endgenerate

    paralel_sum #(
      .NUMBER_OF_INPUTS(2**($clog2(MATRIX_SIZE))                ),
      .BITS_PER_SYMBOL (2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH-1)),
      .SIGNED_B        (SIGNED_B                                ),
      .RST_ON          (RST_ON                                  ),
      .REG_CONV        (REG_CONV                                )
    ) i_paralel_sum (
      .clk_i  (clk_i                                                                                                                                   ),
      .rst_n_i(rst_n_i|!RST_ON                                                                                                                         ),
      .ena_i  (din_ena_i|!ENA_ON                                                                                                                       ),
      .data_i ({result_l,{(((2**($clog2(MATRIX_SIZE)))*2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH-1))-(MATRIX_SIZE)*(BITS_PER_SYMBOL+COEFF_WIDTH-1)){1'b0}}}),
      .data_o (data_out_l                                                                                                                              )
    );

  
endmodule : mult_matrix_2d