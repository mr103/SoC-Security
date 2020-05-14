//
// Copyright (C) 2019 Massachusetts Institute of Technology
//
// File         : md5_top_axi4lite.v
// Project      : Common Evaluation Platform (CEP)
// Description  : This file provides an axi4-lite wrapper for the wishbone based-MD5 core
//

module md5_top_axi4lite (

    // Clock & Reset
    clk_i,
    rst_ni,    

    // AXI4 Slave Interface
    o_axi_awready,
    i_axi_awaddr, 
    i_axi_awcache, 
    i_axi_awprot, 
    i_axi_awvalid,

    o_axi_wready, 
    i_axi_wdata, 
    i_axi_wstrb, 
    i_axi_wvalid,

    o_axi_bresp, 
    o_axi_bvalid, 
    i_axi_bready,
    
    o_axi_arready,
    i_axi_araddr,
    i_axi_arcache,
    i_axi_arprot,
    i_axi_arvalid,

    o_axi_rresp,
    o_axi_rvalid,
    o_axi_rdata,
    i_axi_rready,




    // AXI4 Master Interface 
    o_m_axi_awid,
    o_m_axi_awaddr,
    o_m_axi_awlen,
    o_m_axi_awsize,
    o_m_axi_awburst,
    o_m_axi_awlock,
    o_m_axi_awcache,
    o_m_axi_awprot,
    o_m_axi_awqos,
    o_m_axi_awuser,
    o_m_axi_awvalid,
    i_m_axi_awready,

    o_m_axi_wdata,
    o_m_axi_wstrb,
    o_m_axi_wlast,
    o_m_axi_wuser,
    o_m_axi_wvalid,
    i_m_axi_wready,

    i_m_axi_bid,
    i_m_axi_bresp,
    i_m_axi_buser,
    i_m_axi_bvalid,
    o_m_axi_bready,

    o_m_axi_arid,
    o_m_axi_araddr,
    o_m_axi_arlen, 
    o_m_axi_arsize, 
    o_m_axi_arburst, 
    o_m_axi_arlock,
    o_m_axi_arcache, 
    o_m_axi_arprot,
    o_m_axi_arqos,
    o_m_axi_aruser,
    o_m_axi_arvalid,
    i_m_axi_arready,

    i_m_axi_rid,
    i_m_axi_rdata,
    i_m_axi_rresp,
    i_m_axi_rlast,
    i_m_axi_ruser,
    i_m_axi_rvalid,
    o_m_axi_rready

);

	parameter C_AXI_DATA_WIDTH  = 32;   // Width of the AXI R&W data
    parameter C_AXI_ADDR_WIDTH  = 32;   // AXI Address width


	parameter C_M_AXI_DATA_WIDTH   = 32; // Width of the AXI4 full R&W data
    parameter C_M_AXI_ADDR_WIDTH   = 32; // AXI4 full Address width
    parameter C_M_AXI_AWUSER_WIDTH = 0; // AXI4 full write address user width
    parameter C_M_AXI_ARUSER_WIDTH = 0; // AXI4 full read address user width
    parameter C_M_AXI_WUSER_WIDTH  = 0; // AXI4 full write data user width
    parameter C_M_AXI_RUSER_WIDTH  = 0; // AXI4 full read data user width
    parameter C_M_AXI_BUSER_WIDTH  = 0; // AXI4 full write response user width
    parameter C_M_AXI_ID_WIDTH     = 2;  // AXI4 full ID width -- depends on number of masters



    // Clocks and Resets
    input   wire                                clk_i;
    input   wire                                rst_ni;

    // AXI Slave Interface
    // AXI write address channel signals
    output  wire                                o_axi_awready;  // Slave is ready to accept
    input   wire    [C_AXI_ADDR_WIDTH-1:0]      i_axi_awaddr;   // Write address
    input   wire    [3:0]                       i_axi_awcache;  // Write Cache type
    input   wire    [2:0]                       i_axi_awprot;   // Write Protection type
    input   wire                                i_axi_awvalid;  // Write address valid

    // AXI write data channel signals
    output  wire                                o_axi_wready;   // Write data ready
    input   wire    [C_AXI_DATA_WIDTH-1:0]      i_axi_wdata;    // Write data
    input   wire    [C_AXI_DATA_WIDTH/8-1:0]    i_axi_wstrb;    // Write strobes
    input   wire                                i_axi_wvalid;   // Write valid

    // AXI write response channel signals
    output  wire    [1:0]                       o_axi_bresp;    // Write response
    output  wire                                o_axi_bvalid;   // Write reponse valid
    input   wire                                i_axi_bready;   // Response ready

    // AXI read address channel signals
    output  wire                                o_axi_arready;  // Read address ready
    input   wire    [C_AXI_ADDR_WIDTH-1:0]      i_axi_araddr;   // Read address
    input   wire    [3:0]                       i_axi_arcache;  // Read Cache type
    input   wire    [2:0]                       i_axi_arprot;   // Read Protection type
    input   wire                                i_axi_arvalid;  // Read address valid

    // AXI read data channel signals
    output  wire [1:0]                          o_axi_rresp;    // Read response
    output  wire                                o_axi_rvalid;   // Read reponse valid
    output  wire [C_AXI_DATA_WIDTH-1:0]         o_axi_rdata;    // Read data
    input   wire                                i_axi_rready;   // Read Response ready






 // AXI Master Interface
    // AXI write address channel signals
    input    wire                                i_m_axi_awready;  // Slave is ready to accept
    output   wire    [C_M_AXI_ID_WIDTH-1:0]      o_m_axi_awid;     // Write address ID
    output   wire    [C_M_AXI_ADDR_WIDTH-1:0]    o_m_axi_awaddr;   // Write address
    output   wire    [7:0]                       o_m_axi_awlen;    // Write adress length
    output   wire    [2:0]                       o_m_axi_awsize;   // Write adress size
    output   wire    [1:0]                       o_m_axi_awburst;  // Write adress burst
    output   wire                                o_m_axi_awlock;   // Write adress lock
    output   wire    [3:0]                       o_m_axi_awcache;  // Write Cache type
    output   wire    [2:0]                       o_m_axi_awprot;   // Write Protection type
    output   wire                                o_m_axi_awvalid;  // Write address valid
    output   wire    [3:0]                       o_m_axi_awqos;    // Write qos
    output   wire    [C_M_AXI_AWUSER_WIDTH-1:0]  o_m_axi_awuser;   // Write user


    // AXI write data channel signals
    input    wire                                i_m_axi_wready;   // Write data ready
    output   wire    [C_M_AXI_DATA_WIDTH-1:0]    o_m_axi_wdata;    // Write data
    output   wire    [C_M_AXI_DATA_WIDTH/8-1:0]  o_m_axi_wstrb;    // Write strobes
    output   wire                                o_m_axi_wlast;    // Write last
    output   wire    [C_M_AXI_WUSER_WIDTH-1:0]   o_m_axi_wuser;    // Write user
    output   wire                                o_m_axi_wvalid;   // Write valid

    // AXI write response channel signals
    input    wire    [1:0]                       i_m_axi_bresp;    // Write response
    input    wire    [C_M_AXI_ID_WIDTH-1:0]      i_m_axi_bid;      // Write response ID
    input    wire    [C_M_AXI_BUSER_WIDTH-1:0]   i_m_axi_buser;    // Write response user
    input    wire                                i_m_axi_bvalid;   // Write reponse valid
    output   wire                                o_m_axi_bready;   // Response ready

    // AXI read address channel signals
    input    wire                                i_m_axi_arready;  // Slave is ready to accept
    output   wire    [C_M_AXI_ID_WIDTH-1:0]      o_m_axi_arid;     // Read address ID
    output   wire    [C_M_AXI_ADDR_WIDTH-1:0]    o_m_axi_araddr;   // Read address
    output   wire    [7:0]                       o_m_axi_arlen;    // Read adress length
    output   wire    [2:0]                       o_m_axi_arsize;   // Read adress size
    output   wire    [1:0]                       o_m_axi_arburst;  // Read adress burst
    output   wire                                o_m_axi_arlock;   // Read adress lock
    output   wire    [3:0]                       o_m_axi_arcache;  // Read Cache type
    output   wire    [2:0]                       o_m_axi_arprot;   // Read Protection type
    output   wire    [3:0]                       o_m_axi_arqos;    // Read qos
    output   wire    [C_M_AXI_ARUSER_WIDTH-1:0]  o_m_axi_aruser;   // Read user
    output   wire                                o_m_axi_arvalid;  // Read address valid

    // AXI read data channel signals
    input  wire [1:0]                            i_m_axi_rresp;    // Read response
    input  wire [C_M_AXI_ID_WIDTH-1:0]           i_m_axi_rid;      // Read ID
    input  wire                                  i_m_axi_rlast;     // Read last
    input  wire [C_M_AXI_RUSER_WIDTH-1:0]        i_m_axi_ruser;    // Read user
    input  wire                                  i_m_axi_rvalid;   // Read reponse valid
    input  wire [C_M_AXI_DATA_WIDTH-1:0]         i_m_axi_rdata;    // Read data
    output wire                                  o_m_axi_rready;   // Read Response ready




	/*-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)*/
	parameter ADDR_LSB  = (C_M_AXI_DATA_WIDTH/32)+ 1;
	parameter OPT_MEM_ADDR_BITS = 1;
    parameter C_S_AXI_DATA_WIDTH = 32;
    parameter C_S_AXI_ADDR_WIDTH = 4;

	/*------------------------------------------------
	---- Signals for user logic register space 
	------------------------------------------------
	---- Number of Slave Registers 4*/
	reg [C_M_AXI_DATA_WIDTH-1 : 0] md5_reg0	;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] md5_reg1	;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] md5_reg2	;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] md5_reg3	;
	wire                           md5_reg_rden	;
	wire                           md5_reg_wren	;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] reg_data_out	;
	reg                            aw_en ;
	integer byte_index	;

    //Slave Interface signals -- coming from interconnect or tb //Mahima
    wire S_AXI_WVALID;
    wire S_AXI_AWVALID;
    wire [(C_S_AXI_DATA_WIDTH/8)-1 :0] S_AXI_WSTRB;
    wire [C_S_AXI_DATA_WIDTH-1 :0] S_AXI_WDATA;
    wire S_AXI_ARVALID;

    // Wishbone slave wires
    wire                                wb_rst;
    wire [C_AXI_ADDR_WIDTH - 3:0]   	wbs_adr_i;
    wire [C_AXI_DATA_WIDTH - 1:0]  		wbs_dat_i;
    wire [3:0]                          wbs_sel_i;
    wire                                wbs_we_i;
    wire                                wbs_cyc_i;
    wire                                wbs_stb_i;
    wire [C_AXI_DATA_WIDTH - 1:0]   	wbs_dat_o;
    wire 								wbs_err_o;
    wire                                wbs_ack_o;

    // Instantiation of the pipelined AXI4 to Wishbone converter
    axlite2wbsp # (
        .C_AXI_DATA_WIDTH               (C_AXI_DATA_WIDTH),     // Width of the AXI R&W data
        .C_AXI_ADDR_WIDTH               (C_AXI_ADDR_WIDTH)      // AXI Address Width
    ) axlite2wbsp_inst ( 
        .i_clk                          (clk_i), 
        .i_axi_reset_n                  (rst_ni),

        // AXI4 Slave Interface
        .o_axi_awready                  (o_axi_awready),
        .i_axi_awaddr                   (i_axi_awaddr), 
        .i_axi_awcache                  (i_axi_awcache), 
        .i_axi_awprot                   (i_axi_awprot), 
        .i_axi_awvalid                  (i_axi_awvalid),

        .o_axi_wready                   (o_axi_wready), 
        .i_axi_wdata                    (i_axi_wdata), 
        .i_axi_wstrb                    (i_axi_wstrb), 
        .i_axi_wvalid                   (i_axi_wvalid),

        .o_axi_bresp                    (o_axi_bresp), 
        .o_axi_bvalid                   (o_axi_bvalid), 
        .i_axi_bready                   (i_axi_bready),

        .o_axi_arready                  (o_axi_arready),
        .i_axi_araddr                   (i_axi_araddr),
        .i_axi_arcache                  (i_axi_arcache),
        .i_axi_arprot                   (i_axi_arprot),
        .i_axi_arvalid                  (i_axi_arvalid),

        .o_axi_rresp                    (o_axi_rresp),
        .o_axi_rvalid                   (o_axi_rvalid),
        .o_axi_rdata                    (o_axi_rdata),
        .i_axi_rready                   (i_axi_rready),

        // Wishbone Master Interface
        .o_reset                        (wb_rst), 
        .o_wb_cyc                       (wbs_cyc_i), 
        .o_wb_stb                       (wbs_stb_i), 
        .o_wb_we                        (wbs_we_i), 
        .o_wb_addr                      (wbs_adr_i), 
        .o_wb_data                      (wbs_dat_i), 
        .o_wb_sel                       (wbs_sel_i),
        .i_wb_ack                       (wbs_ack_o), 
        .i_wb_stall                     (1'b0), 
        .i_wb_data                      (wbs_dat_o), 
        .i_wb_err                       (wbs_err_o)
    );

    // Instantiate the wishbone-based MD5 Core
    md5_top_wb #(
        .AW 			(C_AXI_ADDR_WIDTH - 2),
        .DW 			(C_AXI_DATA_WIDTH)
    ) md5_top_wb_inst (
        // Wishbone Slave interface
        .wb_clk_i       (clk_i),
        .wb_rst_i       (wb_rst),
        .wb_dat_i       (wbs_dat_i),
        .wb_adr_i       (wbs_adr_i),
        .wb_sel_i       (wbs_sel_i[3:0]),
        .wb_we_i        (wbs_we_i),
        .wb_cyc_i       (wbs_cyc_i),
        .wb_stb_i       (wbs_stb_i),
        .wb_dat_o       (wbs_dat_o),
        .wb_err_o       (wbs_err_o),
        .wb_ack_o       (wbs_ack_o),

        // Processor interrupt
        .int_o          ()
    );

 //Instantiate AXI Master Interface
    tmp_master_v1_0_M00_AXI #(
        //parameters
        .C_M_TARGET_SLAVE_BASE_ADDR	(),
        .C_M_AXI_BURST_LEN	        (),
        .C_M_AXI_ID_WIDTH           (C_M_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH	        (C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH	        (C_M_AXI_DATA_WIDTH),
		.C_M_AXI_AWUSER_WIDTH       (C_M_AXI_AWUSER_WIDTH),
		.C_M_AXI_ARUSER_WIDTH       (C_M_AXI_ARUSER_WIDTH),
		.C_M_AXI_WUSER_WIDTH	    (C_M_AXI_WUSER_WIDTH),
		.C_M_AXI_RUSER_WIDTH	    (C_M_AXI_RUSER_WIDTH)

    ) axi_master_inst (
        //ports connections
        .INIT_AXI_TXN(),
        .TXN_DONE(),
        .ERROR(),

        .M_AXI_ACLK         (clk_i),
        .M_AXI_ARESETN      (rst_ni),

        .M_AXI_AWID         (o_m_axi_awid), //(C_M_AXI_ID_WIDTH-1 downto 0)
        .M_AXI_AWADDR       (o_m_axi_awaddr),//(C_M_AXI_ADDR_WIDTH-1 downto 0);
        .M_AXI_AWLEN        (o_m_axi_awlen),//(7 downto 0)
        .M_AXI_AWSIZE       (o_m_axi_awsize),//(2 downto 0);
        .M_AXI_AWBURST      (o_m_axi_awburst),//(1 downto 0);
        .M_AXI_AWLOCK       (o_m_axi_awlock),
        .M_AXI_AWCACHE      (o_m_axi_awcache),//(3 downto 0);
        .M_AXI_AWPROT       (o_m_axi_awprot),//(2 downto 0);
        .M_AXI_AWQOS        (o_m_axi_awqos),//(3 downto 0);
        .M_AXI_AWUSER       (),//(C_M_AXI_AWUSER_WIDTH-1 downto 0)
        .M_AXI_AWVALID      (o_m_axi_awvalid),
        .M_AXI_AWREADY      (i_m_axi_awready),

        .M_AXI_WDATA        (o_m_axi_wdata),//(C_M_AXI_DATA_WIDTH-1 downto 0);
        .M_AXI_WSTRB        (o_m_axi_wstrb),//(C_M_AXI_DATA_WIDTH/8-1 downto 0);
        .M_AXI_WLAST        (o_m_axi_wlast),
        .M_AXI_WUSER        (),//(C_M_AXI_WUSER_WIDTH-1 downto 0);
        .M_AXI_WVALID       (o_m_axi_wvalid),
        .M_AXI_WREADY       (i_m_axi_wready),

        .M_AXI_BID          (i_m_axi_bid), //(C_M_AXI_ID_WIDTH-1 downto 0)
        .M_AXI_BRESP        (i_m_axi_bresp),	//(1 downto 0);
        .M_AXI_BUSER        (), //(C_M_AXI_BUSER_WIDTH-1 downto 0);
        .M_AXI_BVALID       (i_m_axi_bvalid),
        .M_AXI_BREADY       (o_m_axi_bready),

        .M_AXI_ARID         (o_m_axi_arid), //(C_M_AXI_ID_WIDTH-1 downto 0);
        .M_AXI_ARADDR       (o_m_axi_araddr),//(C_M_AXI_ADDR_WIDTH-1 downto 0);
        .M_AXI_ARLEN        (o_m_axi_arlen), //(7 downto 0);
        .M_AXI_ARSIZE       (o_m_axi_arsize), //(2 downto 0);
        .M_AXI_ARBURST      (o_m_axi_arburst), //(1 downto 0);
        .M_AXI_ARLOCK       (o_m_axi_arlock),
        .M_AXI_ARCACHE      (o_m_axi_arcache), //(3 downto 0);
        .M_AXI_ARPROT       (o_m_axi_arprot),//(2 downto 0);
        .M_AXI_ARQOS        (o_m_axi_arqos),//(3 downto 0);
        .M_AXI_ARUSER       (),//(C_M_AXI_ARUSER_WIDTH-1 downto 0);
        .M_AXI_ARVALID      (o_m_axi_arvalid),
        .M_AXI_ARREADY      (i_m_axi_arready),

        .M_AXI_RID          (i_m_axi_rid),//(C_M_AXI_ID_WIDTH-1 downto 0);
        .M_AXI_RDATA        (i_m_axi_rdata),//(C_M_AXI_DATA_WIDTH-1 downto 0);
        .M_AXI_RRESP        (i_m_axi_rresp),//(1 downto 0);
        .M_AXI_RLAST        (i_m_axi_rlast),
        .M_AXI_RUSER        (),//(C_M_AXI_RUSER_WIDTH-1 downto 0);
        .M_AXI_RVALID       (i_m_axi_rvalid),
        .M_AXI_RREADY       (o_m_axi_rready)
    );

/*
-- Implement memory mapped register select and write logic generation
-- The write data is accepted and written to memory mapped registers when
-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
-- select byte enables of slave registers while writing.
-- These registers are cleared when reset (active low) is applied.
-- Slave register write enable is asserted when valid address and data are available
-- and the slave is ready to accept the write address and write data.*/
//Richa -- slave from interconnect need to be added and respective signals

//Connecting slave/tb signals to the master signals till we get a slave instantiated in the md5_top 
//Mahima
assign S_AXI_AWVALID = 1; //o_m_axi_awvalid;
assign S_AXI_WVALID = 1;//o_m_axi_wvalid;
assign S_AXI_ARVALID = 1;//o_m_axi_arvalid;
assign S_AXI_WDATA = 'hFEEE;//o_m_axi_wdata;
assign S_AXI_WSTRB = 4'b1111;//o_m_axi_wstrb;


assign md5_reg_wren = i_m_axi_awready && S_AXI_WVALID && i_m_axi_awready && S_AXI_AWVALID ; //Mahima - edit these

reg [OPT_MEM_ADDR_BITS:0]  loc_addr ; 

always @(posedge clk_i or negedge rst_ni)  
begin
    if (!rst_ni) begin
        md5_reg0 <= 'h0;
	    md5_reg1 <= 'h0;
	    md5_reg2 <= 'h0;
	    md5_reg3 <= 'h0;
    end

    else begin
        loc_addr = o_m_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS : ADDR_LSB];
	    if (md5_reg_wren == 1) begin
	      case (loc_addr) 

	        2'b00: begin
            md5_reg0 <= S_AXI_WDATA;
            //Richa-- check this "Range must be bounded by constant expressions" error
               //for ( byte_index= 0; byte_index <= (C_M_AXI_DATA_WIDTH/8-1) ; byte_index=byte_index+1) begin
	           //   if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	           //      //Respective byte enables are asserted as per write strobes                   
	           //      //slave registor 0
	           //      md5_reg0[byte_index*8+7 : byte_index*8] <= S_AXI_WDATA[byte_index*8+7 : byte_index*8];
	           //   end
	           // end
            end

	        2'b01: begin
            md5_reg1 <= S_AXI_WDATA;
                //for (byte_index= 0; byte_index <= (C_M_AXI_DATA_WIDTH/8-1) ; byte_index=byte_index+1) begin
	            //  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	            //     //Respective byte enables are asserted as per write strobes                   
	            //     //slave registor 1
	            //     md5_reg1[byte_index*8+7 : byte_index*8] <= S_AXI_WDATA[byte_index*8+7 : byte_index*8];
	            //  end
	            //end
            end

	        2'b10: begin
            md5_reg2 <= S_AXI_WDATA;
                //for (byte_index= 0; byte_index <= (C_M_AXI_DATA_WIDTH/8-1) ; byte_index=byte_index+1) begin
	            //  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	            //     //Respective byte enables are asserted as per write strobes                   
	            //     //slave registor 2
	            //     md5_reg2[byte_index*8+7 : byte_index*8] <= S_AXI_WDATA[byte_index*8+7 : byte_index*8];
	            //  end
	            //end
            end

	        2'b11: begin
            md5_reg3 <= S_AXI_WDATA;
               //for (byte_index= 0; byte_index <= (C_M_AXI_DATA_WIDTH/8-1) ; byte_index=byte_index+1) begin
	           //   if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	           //      //Respective byte enables are asserted as per write strobes                   
	           //      //slave registor 3
	           //      md5_reg3[byte_index*8+7 : byte_index*8] <= S_AXI_WDATA[byte_index*8+7 : byte_index*8];
	           //   end
	           // end
            end

	        default: begin
	            md5_reg0 <= md5_reg0;
	            md5_reg1 <= md5_reg1;
	            md5_reg2 <= md5_reg2;
	            md5_reg3 <= md5_reg3;
            end

	      endcase
        end
    end
end

/*-- Implement memory mapped register select and read logic generation
-- Slave register read enable is asserted when valid address is available
-- and the slave is ready to accept the read address.*/

assign md5_reg_rden = i_m_axi_arready && S_AXI_ARVALID && (! i_m_axi_rvalid) ; //Mahima

always @(posedge clk_i or negedge rst_ni or md5_reg_rden)  
begin
    loc_addr <= o_m_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS : ADDR_LSB];
    case (loc_addr)  
        2'b00 :   reg_data_out <= md5_reg0;
        2'b01 :   reg_data_out <= md5_reg1;
        2'b10 :   reg_data_out <= md5_reg2;
        2'b11 :   reg_data_out <= md5_reg3;
        default : reg_data_out <= 'h0;
    endcase
end

//Richa -- check how to assign input axi_rdata signal?--- Error Illegal reference to net "i_m_axi_rdata" 
//-- Output register or memory read data
always @(posedge clk_i or negedge rst_ni)  
begin
    //if (!rst_ni)
        //i_m_axi_rdata  <= 'h0;
    //else begin
    //	if (md5_reg_rden == 1) 
        	/*-- When there is a valid read address (S_AXI_ARVALID) with 
	        -- acceptance of read address by the slave (axi_arready), 
	        -- output the read dada 
	        -- Read address mux*/
            //i_m_axi_rdata <= reg_data_out;     //-- register read data
    //end
end 


endmodule   // end md5_top_axi4lite
