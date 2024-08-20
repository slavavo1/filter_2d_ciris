`timescale 1ns / 100ps
`include "fir_2d.svh"
module filter_2d_ciris #(
  parameter GRAY                 = 1                                                                               ,
  parameter GRAY_MODE            = 1                                                                               ,
  parameter BITS_PER_SYMBOL      = 8                                                                               ,
  parameter SYMBOLS_PER_BEAT     = 3                                                                               ,
  parameter MAXIMUM_FRAME_WIDTH  = 20                                                                              ,
  parameter MAXIMUM_FRAME_HEIGHT = 20                                                                              ,
  parameter DEVICE_FAMILY        = "Cyclone IV E"                                                                  ,
  //AXI-Lite
  parameter AXIL_DW              = 32                                                                              ,
  parameter AXIL_AW              = 32                                                                              ,
  parameter TIMEOUT              = 1                                                                               ,
  parameter STARTING_ADDRESS     = 0                                                                               ,
  // fifo
  parameter OUTPUT_REGISTER_FIFO = "ON"                                                                           ,
  // conv
  parameter MATRIX_SIZE_H        = 3                                                                               ,
  parameter MATRIX_SIZE_V        = 3                                                                               ,
  parameter CONVEYOR_IN          = 1                                                                               ,
  parameter CONVEYOR_MID         = 1                                                                               ,
  parameter CONVEYOR_OUT         = 1                                                                               ,
  parameter SIGNED_OUT           = 0                                                                               ,
  //mult
  parameter CONVEYOR_MULT        = 0 /*количество последовательных регистров в умножение (intel)*/                 ,
  parameter CONVEYOR_SHIFT       = 1                                                                               ,
  parameter SIGNED_B             = 1 /*коэффициенты имеют знак*/                                                   ,
  parameter COEFF_WIDTH          = 9 /*количество бит на коэффициент*/                                             ,
  parameter SHIFT_OUT            = 0 /*начальное положение запятой*/                                               ,
  parameter MATRIX_SIZE          = MATRIX_SIZE_V/2                                                                 ,
  // paralel sum
  parameter bit [$clog2(2**($clog2(MATRIX_SIZE_H*MATRIX_SIZE_V)))-1:0] REG_CONV = 'b1001001                        ,
  parameter DATA_WIDTH           = BITS_PER_SYMBOL*SYMBOLS_PER_BEAT                                                ,
  parameter DATA_WIDTH_FIFO      = (GRAY) ? BITS_PER_SYMBOL : DATA_WIDTH                                           ,
  parameter DEPTH_FIFO           = MAXIMUM_FRAME_WIDTH-MATRIX_SIZE_H                                               ,
  parameter DATA_WIDTH_CB_CR     = BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-1)                                            ,
  parameter FIFO_FULL            = (2**$clog2(DEPTH_FIFO) == DEPTH_FIFO) ? 3 : (2**$clog2(DEPTH_FIFO)-DEPTH_FIFO+1),
  parameter REG_DATA             = MATRIX_SIZE_H*MATRIX_SIZE_V*COEFF_WIDTH+$clog2(COEFF_WIDTH-SIGNED_B)            ,
  parameter REG_DATA_FULL        = REG_DATA/AXIL_DW + ((REG_DATA % AXIL_DW != 0) ? 1 : 0)
) (
  /*------------------------------------------------------------------------------
  --  global signals
  ------------------------------------------------------------------------------*/
  input                              clk_i            ,
  input                              rst_n_i          ,
  /*------------------------------------------------------------------------------
  --  Avalon St
  ------------------------------------------------------------------------------*/
  // Avalon Streamig Sink
  output      logic                  avst_din_ready_o ,
  input       logic                  avst_din_valid_i ,
  input       logic                  avst_din_sop_i   ,
  input       logic                  avst_din_eop_i   ,
  input       logic [DATA_WIDTH-1:0] avst_din_data_i  ,
  // Avalon Streamig Source
  input       logic                  avst_dout_ready_i,
  output      logic                  avst_dout_valid_o,
  output      logic                  avst_dout_sop_o  ,
  output      logic                  avst_dout_eop_o  ,
  output      logic [DATA_WIDTH-1:0] avst_dout_data_o ,
  /*------------------------------------------------------------------------------
  --  AXI4-Lite
  ------------------------------------------------------------------------------*/
  // Write Address Channel Signals
  input       logic [   AXIL_AW-1:0] s_axil_awaddr_i  ,
  input       logic                  s_axil_awvalid_i ,
  input  wire       [           2:0] s_axil_awprot_i  ,
  output      logic                  s_axil_awready_o ,
  // Write Data Channel Signals
  input       logic [   AXIL_DW-1:0] s_axil_wdata_i   ,
  input       logic [ AXIL_DW/8-1:0] s_axil_wstrb_i   ,
  input       logic                  s_axil_wvalid_i  ,
  output      logic                  s_axil_wready_o  ,
  // Write Response Channel Signals
  output      logic [           1:0] s_axil_bresp_o   ,
  output      logic                  s_axil_bvalid_o  ,
  input       logic                  s_axil_bready_i  ,
  // Read Address Channel Signals
  input       logic [   AXIL_AW-1:0] s_axil_araddr_i  ,
  input       logic                  s_axil_arvalid_i ,
  input  wire       [           2:0] s_axil_arprot_i  ,
  output      logic                  s_axil_arready_o ,
  // Read Data Channel Signals
  output      logic [   AXIL_DW-1:0] s_axil_rdata_o   ,
  output      logic [           1:0] s_axil_rresp_o   ,
  output      logic                  s_axil_rvalid_o  ,
  input       logic                  s_axil_rready_i
);
/*------------------------------------------------------------------------------
--  
------------------------------------------------------------------------------*/
  function integer data_conveyor;
    input [$clog2(2**($clog2(MATRIX_SIZE_H*MATRIX_SIZE_V)))-1:0] value;
    integer caunt_conveyor;
    caunt_conveyor = 0;
    for (int i = 0; i < $clog2(2**($clog2(MATRIX_SIZE_H*MATRIX_SIZE_V))); i++) begin
      if(value[i]==1'b1)
        caunt_conveyor = caunt_conveyor + 1;
      else
        caunt_conveyor = caunt_conveyor;
     end
     data_conveyor = caunt_conveyor;
  endfunction

  localparam CONVEYOR = CONVEYOR_OUT+data_conveyor(REG_CONV)+CONVEYOR_IN+CONVEYOR_MID+CONVEYOR_SHIFT+CONVEYOR_MULT-MATRIX_SIZE;
/*------------------------------------------------------------------------------
--  wires for connection and reg
------------------------------------------------------------------------------*/
typedef struct packed{
  logic                  ready;
  logic                  valid;
  logic                  sop  ;
  logic                  eop  ;
  logic [DATA_WIDTH-1:0] data ;
} signal;

typedef struct packed{
  signal din ;
  signal dout;
} avalon;

typedef struct{
  logic [MATRIX_SIZE_V-1:0] ena;
}enable;

avalon in ;
avalon out;

logic [15:0] width     ;
logic [15:0] height    ;
logic [ 3:0] interlaced;

logic [BITS_PER_SYMBOL-1:0] data_delay_w[MATRIX_SIZE_V-1:0];

logic is_video;

logic end_of_video_o  ;
logic end_of_video_i  ;
logic vip_ctrl_valid_o;
logic vip_ctrl_valid_i;

logic [BITS_PER_SYMBOL-1:0] data_y  [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0]; // матрица для маски (Y)
logic [BITS_PER_SYMBOL-1:0] data_cr [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0]; // матрица для маски (cb)
logic [BITS_PER_SYMBOL-1:0] data_cb [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0]; // матрица для маски (cr)
logic                       data_end[    MATRIX_SIZE:0][MATRIX_SIZE_H-1:0]; // задержка end для компенсации 

logic [DATA_WIDTH_FIFO:0] data_fifo_i[MATRIX_SIZE_V-2:0];
logic [DATA_WIDTH_FIFO:0] data_fifo_o[MATRIX_SIZE_V-2:0]; // входные порты данных fifo
logic                     empty      [MATRIX_SIZE_V-2:0]; // fifo пустые
logic [MATRIX_SIZE_V-2:0] full                          ; // fifo заполнены на строку
logic [MATRIX_SIZE_V-2:0] full_full                     ; // fifo заполнены
logic [MATRIX_SIZE_V-2:0] full_full_n                   ;

enable read ;
enable write;

logic [MATRIX_SIZE_V-1:1] delay_read;

logic [BITS_PER_SYMBOL-1:0] data_y_wire  [MATRIX_SIZE_V-1:0];
logic [BITS_PER_SYMBOL-1:0] data_cb_wire [MATRIX_SIZE_V-1:0];
logic [BITS_PER_SYMBOL-1:0] data_cr_wire [MATRIX_SIZE_V-1:0];
logic                       data_end_wire[MATRIX_SIZE_V-1:0];

logic [CONVEYOR+MATRIX_SIZE_H-1:0] shift_valid;
logic [CONVEYOR-1:0] shift_end  ;

logic [DATA_WIDTH_CB_CR-1:0] data_shift[CONVEYOR-1:0];

logic [BITS_PER_SYMBOL-1:0] data_res_y   ;
logic [BITS_PER_SYMBOL-1:0] data_res_y_tr;
logic [BITS_PER_SYMBOL-1:0] data_res_cb  ;
logic [BITS_PER_SYMBOL-1:0] data_res_cr  ;

logic [DATA_WIDTH-1:0] data_out;

logic flag_sop;
logic flag_eop;

logic [15:0] string_length_r;

logic                       valid_reg                          ;
logic                       end_of_video_reg                   ;
logic                       ready_delay                        ;
logic [  MATRIX_SIZE_V-1:0] write_delay     [MATRIX_SIZE_V-1:0];
logic [DATA_WIDTH_FIFO-1:0] data_reg                           ;

logic delay_valid[MATRIX_SIZE_H-1:0][MATRIX_SIZE_V-1:0];

logic [BITS_PER_SYMBOL-1:0] data_delay_y  [MATRIX_SIZE_V-1:0];
logic [BITS_PER_SYMBOL-1:0] data_delay_cb [MATRIX_SIZE_V-1:0];
logic [BITS_PER_SYMBOL-1:0] data_delay_cr [MATRIX_SIZE_V-1:0];

logic [MATRIX_SIZE_V-1:0] delay_end;
logic [MATRIX_SIZE_V-1:0] delay_write;

logic [1:0] write_reg;

logic [DATA_WIDTH:0] data_reg_0 [MATRIX_SIZE_V-1:0];
logic [DATA_WIDTH:0] data_reg_1 [MATRIX_SIZE_V-1:0];
logic [DATA_WIDTH:0] data_reg_2 [MATRIX_SIZE_V-1:0];
logic                write_reg_0[MATRIX_SIZE_V-1:0];
logic                write_reg_1[MATRIX_SIZE_V-1:0];
logic                write_reg_2[MATRIX_SIZE_V-1:0];

logic [$clog2(MAXIMUM_FRAME_HEIGHT)-1:0]caunt_v;
logic [ $clog2(MAXIMUM_FRAME_WIDTH)-1:0]caunt_h;

`ifdef SIGNED_IN
logic signed [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][COEFF_WIDTH-1:0] COEF= '{{(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0)}, //{{(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0)},; //='{{(COEFF_WIDTH)'('d29),(COEFF_WIDTH)'('d29),(COEFF_WIDTH)'('d29)}, //'{{(COEFF_WIDTH)'(-'d3),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d3)},
                                                                           {(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d1),(COEFF_WIDTH)'('d0)}, // {(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d1),(COEFF_WIDTH)'('d0)},  //  {(COEFF_WIDTH)'('d29),(COEFF_WIDTH)'('d29),(COEFF_WIDTH)'('d29)}, // {(COEFF_WIDTH)'(-'d10),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d10)},
                                                                           {(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0)}};//  {(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0)}};//  {(COEFF_WIDTH)'('d29),(COEFF_WIDTH)'('d29),(COEFF_WIDTH)'('d29)}}; // {(COEFF_WIDTH)'(-'d3),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d3)}};
`else
logic [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][COEFF_WIDTH-1:0] COEF;// = '{{(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0)}, //{{(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0)}, //
                                                                  //    {(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d1),(COEFF_WIDTH)'('d0)}, // {(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d1),(COEFF_WIDTH)'('d0)},  //
                                                                  //    {(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0)}};//  {(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0),(COEFF_WIDTH)'('d0)}};//                                                                      
`endif

//always_comb
//  for (int i = 0; i < MATRIX_SIZE_V; i++)
//    for (int j = 0; j < MATRIX_SIZE_H; j++)
//      COEF[i][j] = 9'b11;


logic [$clog2(2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE_H*MATRIX_SIZE_V))-1:0] shift_out;

logic [AXIL_AW-1:0] reg_wr_addr;
logic [AXIL_DW-1:0] reg_wr_data;
logic [(AXIL_DW/8)-1:0] reg_wr_strb;
logic reg_wr_en;
logic reg_wr_wait;
logic reg_wr_ack;
logic [AXIL_AW-1:0] reg_rd_addr;
logic reg_rd_en;
logic [AXIL_DW-1:0] reg_rd_data;
logic reg_rd_wait;
logic reg_rd_ack;

  logic start;

`ifdef SIGNED_IN
logic signed [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][COEFF_WIDTH-1:0] coef_r;
logic signed [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][COEFF_WIDTH-1:0] coef_trans;
`else
logic [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][COEFF_WIDTH-1:0] coef_r;
logic [MATRIX_SIZE_V-1:0][MATRIX_SIZE_H-1:0][COEFF_WIDTH-1:0] coef_trans;   
`endif

  logic [AXIL_DW-1:0] reg_axil [REG_DATA_FULL-1:0];
  logic gray_out;
    
/*------------------------------------------------------------------------------
--  Functional
------------------------------------------------------------------------------*/
generate begin
  /*------------------------------------------------------------------------------
  --  AXIL_CNTROL
  ------------------------------------------------------------------------------*/
  axil_reg_if #(
    .DATA_WIDTH(AXIL_DW),
    .ADDR_WIDTH(AXIL_AW),
    .TIMEOUT   (TIMEOUT)
  ) i_axil_reg_if (
    .clk           (clk_i           ),
    .rst           (!rst_n_i         ),
    .s_axil_awaddr (s_axil_awaddr_i ),
    .s_axil_awvalid(s_axil_awvalid_i),
    .s_axil_awready(s_axil_awready_o),
    .s_axil_wdata  (s_axil_wdata_i  ),
    .s_axil_wstrb  (s_axil_wstrb_i  ),
    .s_axil_wvalid (s_axil_wvalid_i ),
    .s_axil_wready (s_axil_wready_o ),
    .s_axil_bresp  (s_axil_bresp_o  ),
    .s_axil_bvalid (s_axil_bvalid_o ),
    .s_axil_bready (s_axil_bready_i ),
    .s_axil_araddr (s_axil_araddr_i ),
    .s_axil_arvalid(s_axil_arvalid_i),
    .s_axil_arready(s_axil_arready_o),
    .s_axil_rdata  (s_axil_rdata_o  ),
    .s_axil_rresp  (s_axil_rresp_o  ),
    .s_axil_rvalid (s_axil_rvalid_o ),
    .s_axil_rready (s_axil_rready_i ),
    .reg_wr_addr   (reg_wr_addr     ),
    .reg_wr_data   (reg_wr_data     ),
    .reg_wr_strb   (reg_wr_strb     ),
    .reg_wr_en     (reg_wr_en       ),
    .reg_wr_wait   (reg_wr_wait     ),
    .reg_wr_ack    (reg_wr_ack      ),
    .reg_rd_addr   (reg_rd_addr     ),
    .reg_rd_en     (reg_rd_en       ),
    .reg_rd_data   (reg_rd_data     ),
    .reg_rd_wait   (reg_rd_wait     ),
    .reg_rd_ack    (reg_rd_ack      )
  );

  

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      for (int i = 0; i < REG_DATA_FULL; i++)
        reg_axil[i] <= {AXIL_DW{1'b0}};
    end else begin
      for (int i = 0; i < AXIL_DW/8; i++) begin
        if(reg_wr_strb[i] && reg_wr_en) begin
          reg_axil[reg_wr_addr-STARTING_ADDRESS][i*8+:8] <= reg_wr_data[i*8 +: 8];
        end
      end
    end
  end 

  assign reg_rd_data = reg_axil[reg_rd_addr-STARTING_ADDRESS];

  assign reg_wr_wait = 1'b0;
  assign reg_rd_wait = 1'b0;

  assign reg_rd_ack = 1'b0; 
  assign reg_wr_ack = 1'b0;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      for (int i = 0; i < MATRIX_SIZE_H; i++)
        for (int j = 0; j < MATRIX_SIZE_H; j++)
          coef_r[i][j] <= COEF[i][j];
      shift_out <= SHIFT_OUT;
    end else if(reg_axil[REG_DATA_FULL-1][AXIL_DW-1]) begin
      for (int i = 0; i < MATRIX_SIZE_H*MATRIX_SIZE_V; i++) begin
        coef_r[i/MATRIX_SIZE_H][i%MATRIX_SIZE_H] <= reg_axil[(COEFF_WIDTH*i)/AXIL_DW][i%(AXIL_DW/COEFF_WIDTH)*COEFF_WIDTH+:COEFF_WIDTH];
      end
      shift_out <= reg_axil[REG_DATA_FULL-1]
      [(COEFF_WIDTH*MATRIX_SIZE_H*MATRIX_SIZE_V)%(AXIL_DW/COEFF_WIDTH)*COEFF_WIDTH+$clog2(2**$clog2(BITS_PER_SYMBOL+COEFF_WIDTH)+$clog2(MATRIX_SIZE_H*MATRIX_SIZE_V)):
       (COEFF_WIDTH*MATRIX_SIZE_H*MATRIX_SIZE_V)%(AXIL_DW/COEFF_WIDTH)*COEFF_WIDTH];
      gray_out <= reg_axil[REG_DATA_FULL-1][AXIL_DW-2];
    end
  end 
  /*------------------------------------------------------------------------------
  --  crs_av_st_input
  ------------------------------------------------------------------------------*/
  crs_av_st_input #(
    .BITS_PER_SYMBOL (BITS_PER_SYMBOL ),
    .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT),
    .LATENCY         ("ON"            )
  ) i_crs_av_st_input (
    .rst_i           (~rst_n_i        ),
    .clk_i           (clk_i           ),
    .din_ready_o     (avst_din_ready_o),
    .din_valid_i     (avst_din_valid_i),
    .din_data_i      (avst_din_data_i ),
    .din_sop_i       (avst_din_sop_i  ),
    .din_eop_i       (avst_din_eop_i  ),
    .dout_ready_i    (in.dout.ready   ),
    .dout_valid_o    (in.dout.valid   ),
    .dout_data_o     (in.dout.data    ),
    .end_of_video_o  (end_of_video_o  ),
    .is_video_o      (is_video        ),
    .width_o         (width           ),
    .height_o        (height          ),
    .interlaced_o    (interlaced      ),
    .vip_ctrl_valid_o(vip_ctrl_valid_o)
  );
  /*------------------------------------------------------------------------------
  --  crs_av_st_output
  ------------------------------------------------------------------------------*/
  crs_av_st_output #(
    .BITS_PER_SYMBOL (BITS_PER_SYMBOL ),
    .SYMBOLS_PER_BEAT(SYMBOLS_PER_BEAT),
    .LATENCY         ("ON"            )
  ) i_crs_av_st_output (
    .rst_i          (~rst_n_i         ),
    .clk_i          (clk_i            ),
    .din_ready_o    (out.din.ready    ),
    .din_valid_i    (out.din.valid    ),
    .din_data_i     (out.din.data     ),
    .dout_ready_i   (avst_dout_ready_i),
    .dout_valid_o   (avst_dout_valid_o),
    .dout_data_o    (avst_dout_data_o ),
    .dout_sop_o     (avst_dout_sop_o  ),
    .dout_eop_o     (avst_dout_eop_o  ),
    .end_of_video_i (end_of_video_i   ),
    .width_i        (width            ),
    .height_i       (height           ),
    .interlaced_i   (interlaced       ),
    .vip_ctrl_send_i(vip_ctrl_valid_i )
  );
  /*------------------------------------------------------------------------------
  --  Y or R
  ------------------------------------------------------------------------------*/
  mult_matrix_2d #(
    .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
    .CONVEYOR_MULT  (CONVEYOR_MULT  ),
    .CONVEYOR_SHIFT (CONVEYOR_SHIFT ),
    .COEFF_WIDTH    (COEFF_WIDTH    ),
    .MATRIX_SIZE_H  (MATRIX_SIZE_H  ),
    .MATRIX_SIZE_V  (MATRIX_SIZE_V  ),
    .CONVEYOR_IN    (CONVEYOR_IN    ),
    .CONVEYOR_MID   (CONVEYOR_MID   ),
    .CONVEYOR_OUT   (CONVEYOR_OUT   ),
    .SIGNED_B       (SIGNED_B       ),
    .SHIFT_OUT      (SHIFT_OUT      ),
    .REG_CONV       (REG_CONV       )
  ) i_mult_matrix_2d_y (
    .clk_i      (clk_i                  ),
    .rst_n_i    (rst_n_i                ),
    .din_dataa_i(data_y                 ),
    .shift_out  (shift_out              ),
    .din_datab_i(coef_r                 ),
    .din_ena_i  (delay_read[MATRIX_SIZE]),
    .dout_data_o(data_res_y             )
  );

  if(!GRAY) begin
    /*------------------------------------------------------------------------------
    --  Cr or G
    ------------------------------------------------------------------------------*/
    mult_matrix_2d #(
      .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
      .CONVEYOR_MULT  (CONVEYOR_MULT  ),
      .CONVEYOR_SHIFT (CONVEYOR_SHIFT ),
      .COEFF_WIDTH    (COEFF_WIDTH    ),
      .MATRIX_SIZE_H  (MATRIX_SIZE_H  ),
      .MATRIX_SIZE_V  (MATRIX_SIZE_V  ),
      .CONVEYOR_IN    (CONVEYOR_IN    ),
      .CONVEYOR_MID   (CONVEYOR_MID   ),
      .CONVEYOR_OUT   (CONVEYOR_OUT   ),
      .SIGNED_B       (SIGNED_B       ),
      .SHIFT_OUT      (SHIFT_OUT      ),
      .REG_CONV       (REG_CONV       )
    ) i_mult_matrix_2d_cr (
      .clk_i      (clk_i                  ),
      .rst_n_i    (rst_n_i                ),
      .din_dataa_i(data_cr                ),
      .shift_out  (shift_out              ),
      .din_datab_i(coef_r                 ),
      .din_ena_i  (delay_read[MATRIX_SIZE]),
      .dout_data_o(data_res_cr            )
    );
    /*------------------------------------------------------------------------------
    --  Cb or B
    ------------------------------------------------------------------------------*/
    mult_matrix_2d #(
      .BITS_PER_SYMBOL(BITS_PER_SYMBOL),
      .CONVEYOR_MULT  (CONVEYOR_MULT  ),
      .CONVEYOR_SHIFT (CONVEYOR_SHIFT ),
      .COEFF_WIDTH    (COEFF_WIDTH    ),
      .MATRIX_SIZE_H  (MATRIX_SIZE_H  ),
      .MATRIX_SIZE_V  (MATRIX_SIZE_V  ),
      .CONVEYOR_IN    (CONVEYOR_IN    ),
      .CONVEYOR_MID   (CONVEYOR_MID   ),
      .CONVEYOR_OUT   (CONVEYOR_OUT   ),
      .SIGNED_B       (SIGNED_B       ),
      .SHIFT_OUT      (SHIFT_OUT      ),
      .REG_CONV       (REG_CONV       )
    ) i_mult_matrix_2d_cb (
      .clk_i      (clk_i                  ),
      .rst_n_i    (rst_n_i                ),
      .din_dataa_i(data_cb                ),
      .shift_out  (shift_out              ),
      .din_datab_i(coef_r                 ),
      .din_ena_i  (delay_read[MATRIX_SIZE]),
      .dout_data_o(data_res_cb            )
    );
  end
  /*------------------------------------------------------------------------------
  --  latency 1 to 0
  ------------------------------------------------------------------------------*/
  always_ff @ (posedge clk_i or negedge rst_n_i) begin
    if(~rst_n_i) begin
      valid_reg        <= 1'b0;
      end_of_video_reg <= 1'b0;
      data_reg         <= {DATA_WIDTH{1'b0}};
    end else if(ready_delay) begin
      valid_reg        <= shift_valid[CONVEYOR+MATRIX_SIZE_H-1];
      end_of_video_reg <= shift_end[CONVEYOR-1];
      data_reg         <= (GRAY) ? data_res_y : data_out;
    end
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_ready_delay
    if(~rst_n_i)
      ready_delay <= 1'b1;
    else
      ready_delay <= out.din.ready;
  end

  assign data_out = ((GRAY|(GRAY_MODE&gray_out)) ? {data_res_y,data_res_y,data_res_y} : {data_res_y,data_res_cb,data_res_cr});

  assign in.dout.ready  = (~full_full[0] & out.din.ready) | (~is_video & empty[0]);
  assign out.din.valid  = (ready_delay) ? shift_valid[CONVEYOR+MATRIX_SIZE_H-1] : valid_reg;
  assign end_of_video_i = (ready_delay) ? shift_end[CONVEYOR-1] : end_of_video_reg;
  assign out.din.data   = (ready_delay) ?  data_out : ((GRAY) ? {data_reg,data_reg,data_reg} : data_reg);
  /*------------------------------------------------------------------------------
  --  shift delay
  ------------------------------------------------------------------------------*/
  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_shift_valid
    if(~rst_n_i)
      for (int i = 0; i < CONVEYOR+MATRIX_SIZE_H; i++)
        shift_valid[i] <= 1'b0;
    else if (delay_read[MATRIX_SIZE])
      shift_valid <= {shift_valid[CONVEYOR+MATRIX_SIZE_H-1:0],delay_read[MATRIX_SIZE]};
    else if (shift_valid[CONVEYOR+MATRIX_SIZE_H-1] & ready_delay& !delay_read[MATRIX_SIZE])
      shift_valid[CONVEYOR+MATRIX_SIZE_H-1] <= 1'b0;
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_end
    if(~rst_n_i)
      for (int x = 0; x < CONVEYOR; x++)
        shift_end[x] <= 1'b0;
    else if (shift_end[CONVEYOR-1] & !delay_read[MATRIX_SIZE] & ready_delay)
      shift_end[CONVEYOR-1] <= 1'b0;
    else if (delay_read[MATRIX_SIZE])begin
      shift_end[0] <= data_end[MATRIX_SIZE][MATRIX_SIZE_H-1];
      for (int x = 0; x < CONVEYOR-1; x++)
        shift_end[x+1] <= shift_end[x];
    end
  end
  /*------------------------------------------------------------------------------
  --  startofpacket and endofpacket
  ------------------------------------------------------------------------------*/
  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_flag_sop
    if(~rst_n_i)
      flag_sop <= 1'b0;
    else if (vip_ctrl_valid_o)
      flag_sop <= 1'b1;
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_flag_eop
    if(~rst_n_i)
      flag_eop <= 1'b0;
    else if (end_of_video_i)
      flag_eop <= 1'b1;
    else if (vip_ctrl_valid_i)
      flag_eop <= 1'b0;
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_vip_ctrl_valid_i
    if(~rst_n_i) begin
      vip_ctrl_valid_i <= 1'b0;
    end else begin
      vip_ctrl_valid_i <= (vip_ctrl_valid_o & ~flag_sop) | (flag_eop & ~vip_ctrl_valid_i);
    end
  end
  /*------------------------------------------------------------------------------
  --  caunt frame
  ------------------------------------------------------------------------------*/
  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_caunt_h
    if(~rst_n_i)
      caunt_h <= {$clog2(MAXIMUM_FRAME_WIDTH){1'b0}};
    else if((caunt_h == MAXIMUM_FRAME_WIDTH-1) && is_video && in.dout.valid 
          && out.din.ready && !full_full[0])
      caunt_h <= {$clog2(MAXIMUM_FRAME_WIDTH){1'b0}};
    else if(is_video && in.dout.valid && out.din.ready && !full_full[0])
      caunt_h <= caunt_h + {{($clog2(MAXIMUM_FRAME_WIDTH)-1){1'b0}},1'b1};
  end

  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_caunt_v
    if(~rst_n_i)
      caunt_v <= {$clog2(MAXIMUM_FRAME_HEIGHT){1'b0}};
    else if((caunt_h == MAXIMUM_FRAME_WIDTH-2) && is_video && in.dout.valid 
          && out.din.ready && !full_full[0] && caunt_v < MAXIMUM_FRAME_HEIGHT)
      caunt_v <= caunt_v + {{($clog2(MAXIMUM_FRAME_HEIGHT)-1){1'b0}},1'b1};
  end
  /*------------------------------------------------------------------------------
  --  fifo
  ------------------------------------------------------------------------------*/

  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_string_length_r
    if(~rst_n_i)
      string_length_r <= DEPTH_FIFO;
    else if (vip_ctrl_valid_i)
      string_length_r <= width;
  end

  genvar i;

  for (i = 0; i < MATRIX_SIZE_V; i++) begin : NUM

    `ifdef FIFO_INTEL

      if(i<=MATRIX_SIZE) begin
        scfifo scfifo_component_1 (
          .clock      (clk_i                                         ),
          .data       (data_fifo_i[i]                                ),
          .rdreq      (read.ena[i]                                   ),
          .wrreq      (write.ena[i] & delay_valid[MATRIX_SIZE_H-1][i]),
          .empty      (empty[i]                                      ),
          .full       (full_full[i]                                  ),
          .almost_full(full[i]                                       ),
          .q          (data_fifo_o[i]                                ),
          .aclr       (!rst_n_i                                      )
        );

        defparam
          scfifo_component_1.add_ram_output_register = "OFF",
            scfifo_component_1.almost_full_value = DEPTH_FIFO-1,
              scfifo_component_1.intended_device_family = DEVICE_FAMILY,
                scfifo_component_1.lpm_numwords = 2**($clog2(DEPTH_FIFO)),
                  scfifo_component_1.lpm_showahead = "OFF",
                    scfifo_component_1.lpm_type = "scfifo",
                      scfifo_component_1.lpm_width = DATA_WIDTH+1,
                        scfifo_component_1.lpm_widthu = $clog2(DEPTH_FIFO),
                          scfifo_component_1.overflow_checking = "ON",
                            scfifo_component_1.underflow_checking = "ON",
                              scfifo_component_1.use_eab = "ON";

      end else if (i<MATRIX_SIZE_V-1) begin

        scfifo scfifo_component_2 (
          .clock      (clk_i                                         ),
          .data       (data_fifo_i[i]                                ),
          .rdreq      (read.ena[i]                                   ),
          .wrreq      (write.ena[i] & delay_valid[MATRIX_SIZE_H-1][i]),
          .empty      (empty[i]                                      ),
          .full       (full_full[i]                                  ),
          .almost_full(full[i]                                       ),
          .q          (data_fifo_o[i]                                ),
          .aclr       (!rst_n_i                                      )
        );

        defparam
          scfifo_component_2.add_ram_output_register = "OFF",
            scfifo_component_2.almost_full_value = DEPTH_FIFO-1,
              scfifo_component_2.intended_device_family = DEVICE_FAMILY,
                scfifo_component_2.lpm_numwords = 2**($clog2(DEPTH_FIFO)),
                  scfifo_component_2.lpm_showahead = "OFF",
                    scfifo_component_2.lpm_type = "scfifo",
                      scfifo_component_2.lpm_width = DATA_WIDTH,
                        scfifo_component_2.lpm_widthu = $clog2(DEPTH_FIFO),
                          scfifo_component_2.overflow_checking = "ON",
                            scfifo_component_2.underflow_checking = "ON",
                              scfifo_component_2.use_eab = "ON";
      end

    `else

      if(i <= MATRIX_SIZE) begin

        crs_lib_fifo_sync #(
          .DW    (DATA_WIDTH+1                   ),
          .AW    ($clog2(DEPTH_FIFO)                  ),
          .VENDOR("FPGA"                              ),
          .N     (2**$clog2(DEPTH_FIFO)-DEPTH_FIFO+1+1)
        ) crs_lib_fifo_sync_1 (
          .clk_i        (clk_i                                         ),
          .din_i        (data_fifo_i[i]                                ),
          .re_i         (read.ena[i]                                   ),
          .we_i         (write.ena[i] & delay_valid[MATRIX_SIZE_H-1][i]),
          .empty_o      (empty[i]                                      ),
          .full_o       (full_full[i]                                  ),
          .full_n_o     (full[i]                                       ),
          .dout_o       (data_fifo_o[i]                                ),
          .rst_i        (rst_n_i                                       ),
          .string_length(string_length_r                               )
        );

      end else if (i<MATRIX_SIZE_V-1)begin

        crs_lib_fifo_sync #(
          .DW    (DATA_WIDTH                     ),
          .AW    ($clog2(DEPTH_FIFO)                  ),
          .N     (2**$clog2(DEPTH_FIFO)-DEPTH_FIFO+1+1),
          .VENDOR("FPGA"                              )
        ) crs_lib_fifo_sync_2 (
          .clk_i        (clk_i                                         ),
          .din_i        (data_fifo_i[i]                                ),
          .re_i         (read.ena[i]                                   ),
          .we_i         (write.ena[i] & delay_valid[MATRIX_SIZE_H-1][i]),
          .empty_o      (empty[i]                                      ),
          .full_o       (full_full[i]                                  ),
          .full_n_o     (full[i]                                       ),
          .dout_o       (data_fifo_o[i]                                ),
          .rst_i        (rst_n_i                                       ),
          .string_length(string_length_r                               )
        );

      end
    `endif
    /*------------------------------------------------------------------------------
    --  
    ------------------------------------------------------------------------------*/
    if(i<MATRIX_SIZE_V-1)
      assign read.ena[i] = is_video & in.dout.valid & out.din.ready & full[i] & (caunt_v > i);
    if(i==0)
      assign write.ena[i] = is_video & in.dout.valid & out.din.ready & !full_full[i];
    else 
      assign write.ena[i] = delay_read[i];

    if(i>0)
      always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_delay_read
        if(~rst_n_i)
          delay_read[i] <= 1'b0;
        else
          delay_read[i] <= read.ena[i-1];
      end

    always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_delay_valid
      if (~rst_n_i) begin
        for (int x = 0; x < MATRIX_SIZE_H; x++)
          delay_valid[x][i] <= 1'b0;
      end else if (write.ena[i]) begin
        delay_valid[0][i] <= 1'b1;
        for (int x = 0; x < MATRIX_SIZE_H-1; x++)
          delay_valid[x+1][i] <= delay_valid[x][i];
      end
    end

    if(i<=MATRIX_SIZE) begin
      if(!GRAY)
        assign data_fifo_i[i] = {data_end[i][MATRIX_SIZE_H-1],data_y[i][MATRIX_SIZE_H-1],
                                 data_cb[i][MATRIX_SIZE_H-1],data_cr[i][MATRIX_SIZE_H-1]};
      else
        assign data_fifo_i[i] = {data_end[i][MATRIX_SIZE_H-1],data_y[i][MATRIX_SIZE_H-1]}; 
    end else if(i<MATRIX_SIZE_V-1) begin
      if(!GRAY)
        assign data_fifo_i[i] = {data_y[i][MATRIX_SIZE_H-1],
                                 data_cb[i][MATRIX_SIZE_H-1],data_cr[i][MATRIX_SIZE_H-1]};
      else
        assign data_fifo_i[i] =  data_y[i][MATRIX_SIZE_H-1];
    end

    if(i==0) begin 
      assign data_y_wire  [i] = in.dout.data[BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-1)];
      if(!GRAY) begin
        assign data_cb_wire [i] = in.dout.data[BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-1)-1:BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-2)]; 
        assign data_cr_wire [i] = in.dout.data[BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-2)-1:0];
      end
      assign data_end_wire[i] = end_of_video_o;
    end else begin
      if(!GRAY) begin
        assign data_y_wire  [i] = data_fifo_o[i-1][BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-1)];
        assign data_cb_wire [i] = data_fifo_o[i-1][BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-1)-1:BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-2)]; 
        assign data_cr_wire [i] = data_fifo_o[i-1][BITS_PER_SYMBOL*(SYMBOLS_PER_BEAT-2)-1:0];
      end else begin
        assign data_y_wire[i] = data_fifo_o[i-1][BITS_PER_SYMBOL-1:0];
      end
      assign data_end_wire[i] = data_fifo_o[i-1][DATA_WIDTH_FIFO];
    end
    /*------------------------------------------------------------------------------
    --  
    ------------------------------------------------------------------------------*/
    always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_data
      if (~rst_n_i) begin
        for (int x = 0; x < MATRIX_SIZE_H; x++) begin
          data_y [i][x] <= {BITS_PER_SYMBOL{1'b0}};
          if(!GRAY) begin
            data_cb[i][x] <= {BITS_PER_SYMBOL{1'b0}};
            data_cr[i][x] <= {BITS_PER_SYMBOL{1'b0}};
          end
        end
      end else if (write.ena[i]) begin
        data_y [i][0] <= data_y_wire [i];
        if(!GRAY) begin
          data_cb[i][0] <= data_cb_wire[i];
          data_cr[i][0] <= data_cr_wire[i];
        end
        for (int x = 0; x < MATRIX_SIZE_H-1; x++) begin
          data_y [i][x+1] <= data_y [i][x];
          if(!GRAY) begin
            data_cb[i][x+1] <= data_cb[i][x];
            data_cr[i][x+1] <= data_cr[i][x];
          end
        end
      end
    end

    if(i<=MATRIX_SIZE)
      always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_data_end
        if (~rst_n_i)
          for (int x = 0; x < MATRIX_SIZE_H; x++)
            data_end[i][x] <= 1'b0;
        else if (write.ena[i]) begin
          data_end[i][0] <= data_end_wire[i];
          for (int x = 0; x < MATRIX_SIZE_H-1; x++)
            data_end[i][x+1] <= data_end[i][x];
        end
      end


  end
end endgenerate

// Parameter checking :

  initial assert ( GRAY && GRAY_MODE )
    $error(1, "Выключите GRAY или GRAY_MODE");
    
  initial assert ( (BITS_PER_SYMBOL < 4) && (BITS_PER_SYMBOL > 32) )
    $error(1, "Out of range : alt_vip_motion_detect does not support - BITS_PER_SYMBOL = %0d", BITS_PER_SYMBOL);



endmodule : filter_2d_ciris