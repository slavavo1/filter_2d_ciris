onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/clk_i
add wave -noupdate -expand /fir_2d_tb/i_filter_2d_ciris/data_fifo_i
add wave -noupdate -expand /fir_2d_tb/i_filter_2d_ciris/data_fifo_o
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/data_reg
add wave -noupdate {/fir_2d_tb/i_filter_2d_ciris/read.ena[2]}
add wave -noupdate {/fir_2d_tb/i_filter_2d_ciris/delay_read[2]}
add wave -noupdate {/fir_2d_tb/i_filter_2d_ciris/delay_read[1]}
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/in.dout.valid
add wave -noupdate -childformat {{{/fir_2d_tb/i_filter_2d_ciris/data_y[2]} -radix unsigned} {{/fir_2d_tb/i_filter_2d_ciris/data_y[1]} -radix unsigned} {{/fir_2d_tb/i_filter_2d_ciris/data_y[0]} -radix unsigned}} -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/data_y[2]} {-height 15 -radix unsigned} {/fir_2d_tb/i_filter_2d_ciris/data_y[1]} {-height 15 -radix unsigned} {/fir_2d_tb/i_filter_2d_ciris/data_y[0]} {-height 15 -radix unsigned}} /fir_2d_tb/i_filter_2d_ciris/data_y
add wave -noupdate -expand -subitemconfig {/fir_2d_tb/i_filter_2d_ciris/read.ena -expand} /fir_2d_tb/i_filter_2d_ciris/read
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/delay_valid
add wave -noupdate -expand -subitemconfig {/fir_2d_tb/i_filter_2d_ciris/write.ena -expand} /fir_2d_tb/i_filter_2d_ciris/write
add wave -noupdate -expand /fir_2d_tb/i_filter_2d_ciris/full
add wave -noupdate -expand /fir_2d_tb/i_filter_2d_ciris/delay_read
add wave -noupdate {/fir_2d_tb/i_filter_2d_ciris/read.ena[1]}
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/in.dout.ready
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/in.dout.data
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/out.din.ready
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/out.din.valid
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/out.din.data
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/vip_ctrl_valid_i
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/avst_dout_ready_i
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/avst_din_valid_i
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/vip_ctrl_valid_o
add wave -noupdate -color Gold /fir_2d_tb/i_filter_2d_ciris/avst_dout_data_o
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/avst_dout_valid_o
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/avst_dout_eop_o
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/shift_end
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/avst_dout_sop_o
add wave -noupdate {/fir_2d_tb/i_filter_2d_ciris/delay_read[1]}
add wave -noupdate {/fir_2d_tb/i_filter_2d_ciris/read.ena[0]}
add wave -noupdate {/fir_2d_tb/i_filter_2d_ciris/delay_read[2]}
add wave -noupdate -radix unsigned -childformat {{{/fir_2d_tb/i_filter_2d_ciris/data_cb[2]} -radix unsigned} {{/fir_2d_tb/i_filter_2d_ciris/data_cb[1]} -radix unsigned} {{/fir_2d_tb/i_filter_2d_ciris/data_cb[0]} -radix unsigned}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/data_cb[2]} {-height 15 -radix unsigned} {/fir_2d_tb/i_filter_2d_ciris/data_cb[1]} {-height 15 -radix unsigned} {/fir_2d_tb/i_filter_2d_ciris/data_cb[0]} {-height 15 -radix unsigned}} /fir_2d_tb/i_filter_2d_ciris/data_cb
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/in.dout.valid
add wave -noupdate -radix unsigned -childformat {{{/fir_2d_tb/i_filter_2d_ciris/data_cr[2]} -radix unsigned} {{/fir_2d_tb/i_filter_2d_ciris/data_cr[1]} -radix unsigned} {{/fir_2d_tb/i_filter_2d_ciris/data_cr[0]} -radix unsigned}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/data_cr[2]} {-height 15 -radix unsigned} {/fir_2d_tb/i_filter_2d_ciris/data_cr[1]} {-height 15 -radix unsigned} {/fir_2d_tb/i_filter_2d_ciris/data_cr[0]} {-height 15 -radix unsigned}} /fir_2d_tb/i_filter_2d_ciris/data_cr
add wave -noupdate -radix unsigned -childformat {{{/fir_2d_tb/i_filter_2d_ciris/data_y[2]} -radix unsigned} {{/fir_2d_tb/i_filter_2d_ciris/data_y[1]} -radix unsigned} {{/fir_2d_tb/i_filter_2d_ciris/data_y[0]} -radix unsigned}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/data_y[2]} {-height 15 -radix unsigned} {/fir_2d_tb/i_filter_2d_ciris/data_y[1]} {-height 15 -radix unsigned} {/fir_2d_tb/i_filter_2d_ciris/data_y[0]} {-height 15 -radix unsigned}} /fir_2d_tb/i_filter_2d_ciris/data_y
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/data_cr_wire
add wave -noupdate -expand /fir_2d_tb/i_filter_2d_ciris/data_end
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/data_end_wire
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/write_delay
add wave -noupdate -expand -subitemconfig {/fir_2d_tb/i_filter_2d_ciris/in.dout -expand} /fir_2d_tb/i_filter_2d_ciris/in
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/in
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/end_of_video_i
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/end_of_video_o
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/end_of_video_reg
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/full_full
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/caunt_h
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/caunt_v
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/dout_data_o
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/overflow
add wave -noupdate -radix decimal -childformat {{{/fir_2d_tb/i_filter_2d_ciris/COEF[2]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/COEF[1]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/COEF[0]} -radix decimal}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/COEF[2]} {-height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/COEF[1]} {-height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/COEF[0]} {-height 15 -radix decimal}} /fir_2d_tb/i_filter_2d_ciris/COEF
add wave -noupdate -radix decimal -childformat {{{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/dataa[2]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/dataa[1]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/dataa[0]} -radix decimal}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/dataa[2]} {-height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/dataa[1]} {-height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/dataa[0]} {-height 15 -radix decimal}} /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/dataa
add wave -noupdate -color Gold -itemcolor Gold -radix decimal -childformat {{{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result[2]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result[1]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result[0]} -radix decimal}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result[2]} {-color Gold -height 15 -itemcolor Gold -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result[1]} {-color Gold -height 15 -itemcolor Gold -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result[0]} {-color Gold -height 15 -itemcolor Gold -radix decimal}} /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result
add wave -noupdate -radix decimal -childformat {{{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_l[2]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_l[1]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_l[0]} -radix decimal}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_l[2]} {-height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_l[1]} {-height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_l[0]} {-height 15 -radix decimal}} /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_l
add wave -noupdate -color Gold -radix decimal -childformat {{{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_w[2]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_w[1]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_w[0]} -radix decimal}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_w[2]} {-color Gold -height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_w[1]} {-color Gold -height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_w[0]} {-color Gold -height 15 -radix decimal}} /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/result_w
add wave -noupdate -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/data_out_l
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/data_shift
add wave -noupdate -color Green -radix decimal /fir_2d_tb/test_caunt
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/COEF
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/shift_out
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/reg_axil
add wave -noupdate -radix decimal -childformat {{{/fir_2d_tb/i_filter_2d_ciris/coef_r[2]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/coef_r[1]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/coef_r[0]} -radix decimal}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/coef_r[2]} {-height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/coef_r[1]} {-height 15 -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/coef_r[0]} {-height 15 -radix decimal}} /fir_2d_tb/i_filter_2d_ciris/coef_r
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/clk
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/rst
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_awaddr
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_awvalid
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_awready
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_wdata
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_wstrb
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_wvalid
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_wready
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_bresp
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_bvalid
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_bready
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_araddr
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_arvalid
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_arready
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_rdata
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_rresp
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_rvalid
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/s_axil_rready
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_wr_addr
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_wr_data
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_wr_strb
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_wr_en
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_wr_wait
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_wr_ack
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_rd_addr
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_rd_en
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_rd_data
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_rd_wait
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_axil_reg_if/reg_rd_ack
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/i_paralel_sum/data_i
add wave -noupdate -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/i_paralel_sum/data_o
add wave -noupdate -expand /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/i_paralel_sum/data_sum
add wave -noupdate /fir_2d_tb/i_filter_2d_ciris/genblk1/i_mult_matrix_2d_y/i_paralel_sum/ena_i
add wave -noupdate -radix decimal /fir_2d_tb/i_filter_2d_ciris/CONVEYOR
add wave -noupdate -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk1/i_sqrt/data_a_i
add wave -noupdate -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk1/i_sqrt/data_b_i
add wave -noupdate -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk1/i_sqrt/data_out
add wave -noupdate -color Yellow -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/data_out_l
add wave -noupdate -color Yellow -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/data_shift
add wave -noupdate -color Yellow -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/dataa
add wave -noupdate -color Yellow -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/din_datab_i
add wave -noupdate -color Yellow -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/dout_data_o
add wave -noupdate -color Yellow -radix decimal -childformat {{{/fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result[2]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result[1]} -radix decimal} {{/fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result[0]} -radix decimal}} -expand -subitemconfig {{/fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result[2]} {-color Yellow -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result[1]} {-color Yellow -radix decimal} {/fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result[0]} {-color Yellow -radix decimal}} /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result
add wave -noupdate -color Yellow -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result_l
add wave -noupdate -color Yellow -radix decimal /fir_2d_tb/i_filter_2d_ciris/genblk1/genblk2/i_mult_matrix_2d_y_tr/result_w
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {72034800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 258
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {72033400 ps} {72068400 ps}
