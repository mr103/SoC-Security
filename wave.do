onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/clk_i
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/rst_ni
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_o_axi_awready
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_i_axi_awaddr
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_i_axi_awvalid
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_o_axi_wready
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_i_axi_wdata
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_i_axi_wvalid
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_o_axi_arready
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_i_axi_araddr
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_i_axi_arvalid
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_o_axi_rresp
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_o_axi_rvalid
add wave -noupdate -expand -group {TB - Slv Interface} /tb_axi_master_md5/tb_o_axi_rdata
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/clk_i
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/rst_ni
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/o_axi_awready
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/i_axi_awvalid
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/i_axi_awaddr
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/o_axi_wready
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/i_axi_wvalid
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/i_axi_wdata
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/md5_reg_wren
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/loc_wr_addr
add wave -noupdate -expand -group {DUT- SLV Interface} -radix hexadecimal /tb_axi_master_md5/md5_top_axi4lite_inst/md5_reg0
add wave -noupdate -expand -group {DUT- SLV Interface} -radix hexadecimal /tb_axi_master_md5/md5_top_axi4lite_inst/md5_reg1
add wave -noupdate -expand -group {DUT- SLV Interface} -radix hexadecimal /tb_axi_master_md5/md5_top_axi4lite_inst/md5_reg2
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/o_axi_arready
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/i_axi_araddr
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/i_axi_arvalid
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/o_axi_rdata
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/i_axi_rready
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/o_m_axi_rready
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/loc_rd_addr
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/md5_reg_rden
add wave -noupdate -expand -group {DUT- SLV Interface} /tb_axi_master_md5/md5_top_axi4lite_inst/reg_data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 302
configure wave -valuecolwidth 100
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1176 ns}
