`timescale 1ns / 100ps
module fir_2d_tb ();

  parameter   BITS_PER_SYMBOL                                    = 8 ;
  parameter   MATRIX_SIZE                                        = 3 ;
  parameter   SYMBOLS_PER_BEAT                                   = 3 ;
  parameter   AXIL_DW                                            = 32;
  parameter   AXIL_AW                                            = 32;
  logic       clk_i                                                  ;
  logic       rst_n_i                                                ;
  logic [7:0] din_data_i      [MATRIX_SIZE-1:0][MATRIX_SIZE-1:0]     ;
  logic [7:0] dout_data_o                                            ;
  logic       din_ena_i                                              ;


  logic [BITS_PER_SYMBOL-1:0] data;

  integer cp = '0;
  reg     sl = '0;
  integer i  = '0;
  integer z  = '0;
  integer b  = '0;

  logic                                        avst_din_ready_o ;
  logic                                        avst_din_valid_i ;
  logic                                        avst_din_sop_i   ;
  logic                                        avst_din_eop_i   ;
  logic [BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:0] avst_din_data_i  ;
  logic                                        avst_dout_ready_i;
  logic                                        avst_dout_valid_o;
  logic                                        avst_dout_sop_o  ;
  logic                                        avst_dout_eop_o  ;
  logic [BITS_PER_SYMBOL*SYMBOLS_PER_BEAT-1:0] avst_dout_data_o ;

  logic [$clog2(8):0] shift_out;

  assign shift_out = 8;

  logic [  AXIL_AW-1:0] s_axil_awaddr_i ;
  logic [          2:0] s_axil_awprot_i ;
  logic                 s_axil_awvalid_i;
  logic                 s_axil_awready_o;
  logic [  AXIL_DW-1:0] s_axil_wdata_i  ;
  logic [AXIL_DW/8-1:0] s_axil_wstrb_i  ;
  logic                 s_axil_wvalid_i ;
  logic                 s_axil_wready_o ;
  logic [          1:0] s_axil_bresp_o  ;
  logic                 s_axil_bvalid_o ;
  logic                 s_axil_bready_i ;
  logic [  AXIL_AW-1:0] s_axil_araddr_i ;
  logic [          2:0] s_axil_arprot_i ;
  logic                 s_axil_arvalid_i;
  logic                 s_axil_arready_o;
  logic [  AXIL_DW-1:0] s_axil_rdata_o  ;
  logic [          1:0] s_axil_rresp_o  ;
  logic                 s_axil_rvalid_o ;
  logic                 s_axil_rready_i ;

  filter_2d_ciris i_filter_2d_ciris (
    .clk_i            (clk_i            ),
    .rst_n_i          (rst_n_i          ),
    //.shift_out        (shift_out        ),
    .avst_din_ready_o (avst_din_ready_o ),
    .avst_din_valid_i (avst_din_valid_i ),
    .avst_din_sop_i   (avst_din_sop_i   ),
    .avst_din_eop_i   (avst_din_eop_i   ),
    .avst_din_data_i  (avst_din_data_i  ),
    .avst_dout_ready_i(avst_dout_ready_i),
    .avst_dout_valid_o(avst_dout_valid_o),
    .avst_dout_sop_o  (avst_dout_sop_o  ),
    .avst_dout_eop_o  (avst_dout_eop_o  ),
    .avst_dout_data_o (avst_dout_data_o ),
    //
    .s_axil_awaddr_i  (s_axil_awaddr_i  ),
    .s_axil_awvalid_i (s_axil_awvalid_i ),
    .s_axil_awready_o (s_axil_awready_o ),
    .s_axil_wdata_i   (s_axil_wdata_i   ),
    .s_axil_wstrb_i   (s_axil_wstrb_i   ),
    .s_axil_wvalid_i  (s_axil_wvalid_i  ),
    .s_axil_wready_o  (s_axil_wready_o  ),
    .s_axil_bresp_o   (s_axil_bresp_o   ),
    .s_axil_bvalid_o  (s_axil_bvalid_o  ),
    .s_axil_bready_i  (s_axil_bready_i  ),
    .s_axil_araddr_i  (s_axil_araddr_i  ),
    .s_axil_arvalid_i (s_axil_arvalid_i ),
    .s_axil_arready_o (s_axil_arready_o ),
    .s_axil_rdata_o   (s_axil_rdata_o   ),
    .s_axil_rresp_o   (s_axil_rresp_o   ),
    .s_axil_rvalid_o  (s_axil_rvalid_o  ),
    .s_axil_rready_i  (s_axil_rready_i  )
  );
/*------------------------------------------------------------------------------
--   // Write Address Channel Signals
  input  logic [   AXIL_AW-1:0] s_axil_awaddr_i  ,
  input  logic                  s_axil_awvalid_i ,
  output logic                  s_axil_awready_o ,
  // Write Data Channel Signals
  input  logic [   AXIL_DW-1:0] s_axil_wdata_i   ,
  input  logic [ AXIL_DW/8-1:0] s_axil_wstrb_i   ,
  input  logic                  s_axil_wvalid_i  ,
  output logic                  s_axil_wready_o  ,
  // Write Response Channel Signals
  output logic [           1:0] s_axil_bresp_o   ,
  output logic                  s_axil_bvalid_o  ,
  input  logic                  s_axil_bready_i  ,
  // Read Address Channel Signals
  input  logic [   AXIL_AW-1:0] s_axil_araddr_i  ,
  input  logic [           2:0] s_axil_arprot_i  ,
  input  logic                  s_axil_arvalid_i ,
  output logic                  s_axil_arready_o ,
  // Read Data Channel Signals
  output logic [   AXIL_DW-1:0] s_axil_rdata_o   ,
  output logic [           1:0] s_axil_rresp_o   ,
  output logic                  s_axil_rvalid_o  ,
  input  logic                  s_axil_rready_i
------------------------------------------------------------------------------*/
  task axi4l_w(
      input logic [31:0] adres,
      input logic [31:0] data ,
      input logic [ 3:0] strob
    );

    pause(1);
    s_axil_awaddr_i = adres;
    s_axil_awvalid_i = 1'b1;
    s_axil_wdata_i = data;
    pause(1);

    while (!s_axil_awready_o) begin
      pause(1);
    end
    s_axil_awvalid_i = 1'b0;
    s_axil_wstrb_i = strob;
    s_axil_wvalid_i = 1'b1;

    while (!s_axil_awready_o) begin
      pause(1);
    end

    if (s_axil_awready_o) begin
      pause(1); 
      s_axil_wvalid_i = 1'b0;
    end else
      s_axil_wvalid_i = 1'b0;

    s_axil_bready_i = 1'b1;
    

    pause(1);
    while (!s_axil_bvalid_o) begin
      pause(1);
    end

    s_axil_bready_i = 1'b0;
  endtask : axi4l_w



  task control_packet(input logic [15:0] width,
      input logic [15:0] heigth,
      input logic [15:0] interlaser); begin

      $display("control packet");
      pause(1);
      avst_din_sop_i = 1'b0;
      while (!avst_din_ready_o) begin
        avst_din_data_i = 16'h0000;
        avst_din_valid_i = 1'b0;
        pause(1);
      end

      avst_din_data_i = 16'h000f;
      avst_din_valid_i = 1'b1;
      avst_din_sop_i = 1'b1;
      pause(1);

      avst_din_sop_i = 1'b0;
      while (!avst_din_ready_o) begin
        avst_din_valid_i = 1'b0;
        pause(1);
      end

      avst_din_data_i = {4'b0, width[7:4], 4'h0, width[11:8], 4'b0, width[15:12]};
      avst_din_valid_i = 1'b1;
      pause(1);

      while (!avst_din_ready_o) begin
        avst_din_valid_i = 1'b0;
        pause(1);
      end

      avst_din_data_i = {4'h0, heigth[11:8], 4'b0, heigth[15:12], 4'h0, width[3:0]};
      avst_din_valid_i = 1'b1;
      pause(1);

      while (!avst_din_ready_o) begin
        avst_din_valid_i = 1'b0;
        pause(1);
      end

      avst_din_data_i = {4'b0, interlaser[3:0], 4'h0, heigth[3:0], 4'b0, heigth[7:4]};
      avst_din_valid_i = 1'b1;
      avst_din_eop_i = 1'b1;
      pause(1);
      avst_din_eop_i = 1'b0;
      while (!avst_din_ready_o) begin
        avst_din_valid_i = 1'b0;
        pause(1);
      end

      $display("control packet: ");
      $display("%d %d %h", width, heigth, interlaser[3:0]);

    end
  endtask

  task data_potok( input logic [15:0] width,
      input logic [15:0] heigth);
    begin
      $display("send picture");

      avst_din_sop_i = 1'b0;
      while (!avst_din_ready_o) begin
        avst_din_data_i = 24'h000003;
        avst_din_valid_i = 1'b0;
        pause(1);
      end

      avst_din_data_i = 24'h000000;
      avst_din_valid_i = 1'b1;
      avst_din_sop_i = 1'b1;
      //din_is_video_i = 1'b1;
      pause(1);

      avst_din_sop_i = 1'b0;
      while (!avst_din_ready_o) begin
        avst_din_data_i = 24'h000000;
        avst_din_valid_i = 1'b0;
        pause(1);
      end

      i = '0;

      while (i < width*heigth-1)
        begin
          cp = ($urandom_range(100,0) < 90) ? 1 : 0;
          case ( cp )
            1'b1 : begin
              if ( avst_din_ready_o ) begin
                i++;
                avst_din_valid_i = 1'b1;
                if ( avst_din_data_i[7:0] == 8'd255 )
                  avst_din_data_i = '0;
                if (i == 1)
                  avst_din_data_i = 24'h123456;
                if (i == 2)
                  avst_din_data_i = 24'h010101;
                else if(( i != 1 ) && ( i != 2 )) begin
                  avst_din_data_i[23:16] = avst_din_data_i[23:16] + 1'b1;
                  avst_din_data_i[15:8] = avst_din_data_i[15:8] + 2'b1;
                  avst_din_data_i[7:0] = avst_din_data_i[7:0] + 2'b1;
                end
              end else begin
                avst_din_valid_i = 1'b0;
              end
            end
            default : begin
              avst_din_valid_i = 1'b0;
            end
          endcase

          pause(1);

        end

      while (!avst_din_ready_o) begin
        avst_din_data_i = 24'h000000;
        avst_din_valid_i = 1'b0;
        pause(1);
      end

      avst_din_data_i = '1;
      avst_din_eop_i = 1'b1;
      avst_din_valid_i = 1'b1;
      pause(1);

      avst_din_valid_i = 1'b0;
      while (!avst_din_ready_o) begin
        avst_din_data_i = 24'h000000;
        avst_din_eop_i = 1'b0;
        pause(1);
      end

      avst_din_data_i = '0;
      //din_is_video_i = 1'b0;
      avst_din_eop_i = 1'b0;
      pause(1);

    end
  endtask : data_potok

  logic[7:0] test_caunt;

  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_test_caunt
    if(~rst_n_i) begin
      test_caunt <= '0;
    end else begin
      test_caunt <= test_caunt + 1'b1;
    end
  end

  always
    #1 clk_i = ~clk_i;

  always_ff @(posedge clk_i or negedge rst_n_i) begin : proc_avst_dout_ready_i
    if (!rst_n_i)
      avst_dout_ready_i <= 1'b0;
    else if(test_caunt > 100)
      avst_dout_ready_i <= ($urandom_range(100,0) < 41) ? 1 : 0;
  end

  task pause(input integer delta_t);
    begin
      repeat (delta_t) @(posedge clk_i);
      #0;
    end
  endtask

  task matrix(); begin
      din_data_i[0][0] <= data;
      din_data_i[0][1] <= data;
      din_data_i[0][2] <= data;
      din_data_i[1][0] <= data;
      din_data_i[1][1] <= data;
      din_data_i[1][2] <= data;
      din_data_i[2][0] <= data;
      din_data_i[2][1] <= data;
      din_data_i[2][2] <= data;
      data <= data + 1'b1;
      pause(1);
    end endtask

  initial begin
    clk_i = 1'b0;
    rst_n_i = 1'b0;
    i = 0;
    avst_din_valid_i = '0;
    avst_din_data_i = '0;
    avst_din_eop_i = '0;
    avst_din_sop_i = '0;
    s_axil_awaddr_i = '0;
    s_axil_awvalid_i = '0;
    s_axil_wdata_i = '0;
    s_axil_wstrb_i = '0;
    s_axil_wvalid_i = '0;
    s_axil_bready_i = '0;
    //avst_dout_ready_i <= 1'b0;
    pause(1);
    //avst_dout_ready_i <= 1'b1;
    rst_n_i = 1'b1;
    for (int i = 0; i < 10; i++)
      begin
      //axi4l_w(32'd0,32'd1<<(8*0),4'b0001);
      //axi4l_w(32'd0,32'd2<<(8*1),4'b0010);
      //axi4l_w(32'd0,32'd3<<(8*2),4'b0100);
      //axi4l_w(32'd0,32'd4<<(8*3),4'b1000);
      //axi4l_w(32'd1,32'd5<<(8*0),4'b0001);
      //axi4l_w(32'd1,32'd6<<(8*1),4'b0010);
      //axi4l_w(32'd1,32'd7<<(8*2),4'b0100);
      //axi4l_w(32'd1,32'd8<<(8*3),4'b1000);
      //axi4l_w(32'd2,32'd9<<(8*0),4'b0001);

      //axi4l_w(32'd2,32'd16<<(8*1),4'b0110);

      //axi4l_w(32'd2,32'd1<<(8*4-1),4'b1000);

        control_packet(20,20,3);
        data_potok(20,20);
        control_packet(20,20,3);
        data_potok(20,20);
        data_potok(20,20);
        pause(11);
        //data_potok(10,10);
        //control_packet(10,10,3);
        //pause(13);
        //data_potok(10,10);
        //control_packet(10,10,3);
        //data_potok(10,10);
        //data_potok(10,10);
        //pause(11);
        //data_potok(10,10);
      end
    pause(100);
    $stop;
    //din_data_i[0][0] = 8'b0;
    //din_data_i[0][1] = 8'b0;
    //din_data_i[0][2] = 8'b0;
    //din_data_i[1][0] = 8'b0;
    //din_data_i[1][1] = 8'b1111_1111;
    //din_data_i[1][2] = 8'b0;
    //din_data_i[2][0] = 8'b0;
    //din_data_i[2][1] = 8'b0;
    //din_data_i[2][2] = 8'b0;
  end

endmodule : fir_2d_tb