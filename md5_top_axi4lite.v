
`timescale 1ns/1ns
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

    //Master Full Interface
	TXN_DONE,
	ERROR,

	M_AXI_ACLK,
	M_AXI_ARESETN,
	M_AXI_AWID,
	M_AXI_AWADDR,
	M_AXI_AWLEN,
	M_AXI_AWSIZE,
	M_AXI_AWBURST,
	M_AXI_AWLOCK,
	M_AXI_AWCACHE,
	M_AXI_AWPROT,
	M_AXI_AWQOS,
	M_AXI_AWUSER,
	M_AXI_AWVALID,
	M_AXI_AWREADY,

	M_AXI_WDATA,
	M_AXI_WSTRB,
	M_AXI_WLAST,
	M_AXI_WUSER,
	M_AXI_WVALID,
	M_AXI_WREADY,

	M_AXI_BID,
	M_AXI_BRESP,
	M_AXI_BUSER,
	M_AXI_BVALID,
	M_AXI_BREADY,

	M_AXI_ARID,
	M_AXI_ARADDR,
	M_AXI_ARLEN,
	M_AXI_ARSIZE,
	M_AXI_ARBURST,
	M_AXI_ARLOCK,
	M_AXI_ARCACHE,
	M_AXI_ARPROT,
	M_AXI_ARQOS,
	M_AXI_ARUSER,
	M_AXI_ARVALID,
	M_AXI_ARREADY,

	M_AXI_RID,
	M_AXI_RDATA,
	M_AXI_RRESP,
	M_AXI_RLAST,
	M_AXI_RUSER,
	M_AXI_RVALID,
	M_AXI_RREADY,

    md5_reg_rden,
    md5_reg_wren,
	ip_buf_rdata,

	// Wishbone slave wires
    wb_rst,
    wbs_adr_i,
	wbs_dat_i,
    wbs_sel_i,
    wbs_we_i,
    wbs_cyc_i,
    wbs_stb_i,
    wbs_dat_o,
    wbs_err_o,
    wbs_ack_o
);
    //--------------------------------------------------------------
    //----------LOCAL VARIBALES & PARAMETERS-----------START--------
    //--------------------------------------------------------------


	parameter C_AXI_DATA_WIDTH  = 32;   // Width of the AXI R&W data
    parameter C_AXI_ADDR_WIDTH  = 32;   // AXI Address width
    
    //AXI MASTER PARAMETERs
    // Base address of targeted slave
    parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h00000000; //MR changed from 32'h40000000 to 32'h40000000
    // Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
    parameter integer C_M_AXI_BURST_LEN	= 256;
    // Thread ID Width
    parameter integer C_M_AXI_ID_WIDTH	= 2;
    // Width of Address Bus
    parameter integer C_M_AXI_ADDR_WIDTH	= 32;
    // Width of Data Bus
    parameter integer C_M_AXI_DATA_WIDTH	= 32;
    // Width of User Write Address Bus
    parameter integer C_M_AXI_AWUSER_WIDTH	= 0;
    // Width of User Read Address Bus
    parameter integer C_M_AXI_ARUSER_WIDTH	= 0;
    // Width of User Write Data Bus
    parameter integer C_M_AXI_WUSER_WIDTH	= 0;
    // Width of User Read Data Bus
    parameter integer C_M_AXI_RUSER_WIDTH	= 0;
    // Width of User Response Bus
    parameter integer C_M_AXI_BUSER_WIDTH	= 0;

    //-- Example-specific design signals
	//-- local parameter for addressing 32 bit / 64 bit C_AXI_DATA_WIDTH
	//-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	//-- ADDR_LSB = 2 for 32 bits (n downto 2)
	//-- ADDR_LSB = 3 for 64 bits (n downto 3)

	parameter ADDR_LSB  = (C_AXI_DATA_WIDTH/32)+ 1;
	parameter OPT_MEM_ADDR_BITS = 1;
        

    // Clocks and Resets
    input   wire                                clk_i;
    input   wire                                rst_ni;


    reg                                         o_axi_awready_val;
    reg                                         o_axi_wready_val;
    reg                                         o_axi_arready_val;
    reg                                         o_axi_rvalid_val;
    reg                                         o_axi_rresp_val;
    reg [C_AXI_DATA_WIDTH-1:0]                  o_axi_rdata_val;

    // AXI write address channel signals
    output  wire                                o_axi_awready;  // Slave is ready to accept
    input   wire    [C_AXI_ADDR_WIDTH-1:0]      i_axi_awaddr;   // Write address
	input 	wire 								i_axi_awvalid;
    input   wire    [3:0]                       i_axi_awcache;  // Write Cache type
    input   wire    [2:0]                       i_axi_awprot;   // Write Protection type

    // AXI write data channel signals
    output  wire                                o_axi_wready;   // Write data ready
	input 	wire 								i_axi_wvalid;
    input   wire    [C_AXI_DATA_WIDTH-1:0]      i_axi_wdata;    // Write data
    input   wire    [C_AXI_DATA_WIDTH/8-1:0]    i_axi_wstrb;    // Write strobes

    // AXI write response channel signals
    output  wire    [1:0]                       o_axi_bresp;    // Write response
	output 	wire 								o_axi_bvalid;
    input   wire                                i_axi_bready;   // Response ready

    // AXI read address channel signals
    output  wire                                o_axi_arready;  // Read address ready
	input 	wire 								i_axi_arvalid;
    input   wire    [C_AXI_ADDR_WIDTH-1:0]      i_axi_araddr;   // Read address
    input   wire    [3:0]                       i_axi_arcache;  // Read Cache type
    input   wire    [2:0]                       i_axi_arprot;   // Read Protection type

    // AXI read data channel signals
    output  wire [1:0]                          o_axi_rresp;    // Read response
	output  wire 								o_axi_rvalid;
    output  wire [C_AXI_DATA_WIDTH-1:0]         o_axi_rdata;    // Read data
    input   wire                                i_axi_rready;   // Read Response ready


    // AXI write address channel signals


    //input  wire                                     INIT_AXI_TXN;
    output wire                                     TXN_DONE;
    output reg                                      ERROR;

    input  wire                                     M_AXI_ACLK;
    input  wire                                     M_AXI_ARESETN;

    output wire      [C_M_AXI_ID_WIDTH-1 : 0]       M_AXI_AWID;
    output wire      [C_M_AXI_ADDR_WIDTH-1 : 0]     M_AXI_AWADDR;
    output wire      [7 : 0]                        M_AXI_AWLEN;
    output wire      [2 : 0]                        M_AXI_AWSIZE;
    output wire      [1 : 0]                        M_AXI_AWBURST;
    output wire                                     M_AXI_AWLOCK;
    output wire      [3 : 0]                        M_AXI_AWCACHE;
    output wire      [2 : 0]                        M_AXI_AWPROT;
    output wire      [3 : 0]                        M_AXI_AWQOS;
    output wire      [C_M_AXI_AWUSER_WIDTH-1:0]     M_AXI_AWUSER;
    output wire                                     M_AXI_AWVALID;
    input  wire                                     M_AXI_AWREADY;

    output wire      [C_M_AXI_DATA_WIDTH-1 : 0]     M_AXI_WDATA;
    output wire      [C_M_AXI_DATA_WIDTH/8-1:0]     M_AXI_WSTRB;
    output wire                                     M_AXI_WLAST;
    output wire      [C_M_AXI_WUSER_WIDTH-1 :0]     M_AXI_WUSER;
    output wire                                     M_AXI_WVALID;
    input  wire                                     M_AXI_WREADY;

    input  wire      [C_M_AXI_ID_WIDTH-1 : 0]       M_AXI_BID;
    input  wire      [1 : 0]                        M_AXI_BRESP;
    input  wire      [C_M_AXI_BUSER_WIDTH-1 :0]     M_AXI_BUSER;
    input  wire                                     M_AXI_BVALID;
    output wire                                     M_AXI_BREADY;

    output wire      [C_M_AXI_ID_WIDTH-1 : 0]       M_AXI_ARID;
    output wire      [C_M_AXI_ADDR_WIDTH-1 : 0]     M_AXI_ARADDR;
    output wire      [7 : 0]                        M_AXI_ARLEN;
    output wire      [2 : 0]                        M_AXI_ARSIZE;
    output wire      [1 : 0]                        M_AXI_ARBURST;
    output wire                                     M_AXI_ARLOCK;
    output wire      [3 : 0]                        M_AXI_ARCACHE;
    output wire      [2 : 0]                        M_AXI_ARPROT;
    output wire      [3 : 0]                        M_AXI_ARQOS;
    output wire      [C_M_AXI_ARUSER_WIDTH-1:0]     M_AXI_ARUSER;
    output wire                                     M_AXI_ARVALID;
    input  wire                                     M_AXI_ARREADY;

    input  wire      [C_M_AXI_ID_WIDTH-1 : 0]       M_AXI_RID;
    input  wire      [C_M_AXI_DATA_WIDTH-1 : 0]     M_AXI_RDATA;
    input  wire      [1 : 0]                        M_AXI_RRESP;
    input  wire                                     M_AXI_RLAST;
    input  wire      [C_M_AXI_RUSER_WIDTH-1 :0]     M_AXI_RUSER;
    input  wire                                     M_AXI_RVALID;
    output wire                                     M_AXI_RREADY;


	output wire                                  md5_reg_rden	;
	output wire                                  md5_reg_wren	;


	// Wishbone slave wires
    input wire                                  wb_rst;
    input wire [C_AXI_ADDR_WIDTH - 3:0]   		wbs_adr_i;
    input wire [C_AXI_DATA_WIDTH - 1:0]  		wbs_dat_i;
	input wire [3:0]                            wbs_sel_i;
    input wire                                  wbs_we_i;
    input wire                              	wbs_cyc_i;
    input wire                              	wbs_stb_i;
    output wire [C_AXI_DATA_WIDTH - 1:0]    	wbs_dat_o;
    output wire 								wbs_err_o;
    output wire                                 wbs_ack_o;


	//------------------------------------------------
	//---- Signals for user logic register space 
	//------------------------------------------------
	//---- Number of Registers 3 

	reg [C_AXI_DATA_WIDTH-1 : 0] md5_reg0	; //control register to initiate the master
	reg [C_AXI_DATA_WIDTH-1 : 0] md5_reg1	; //source address register
	reg [C_AXI_DATA_WIDTH-1 : 0] md5_reg2	; //destination address register


	reg [C_M_AXI_DATA_WIDTH-1 : 0] reg_data_out	;
	reg                            aw_en ;

	integer byte_index	;

    

	wire                           	    INIT_AXI_TXN; //made it a local variable instead of an input

    //pancham related variables
    reg [C_M_AXI_ID_WIDTH-1:0]          ip_buf_arid;
    output reg [C_M_AXI_DATA_WIDTH-1 :0]       ip_buf_rdata;
    reg [C_M_AXI_ID_WIDTH-1:0]          op_buf_awid;
    reg [C_M_AXI_DATA_WIDTH-1 :0]       op_buf_wdata;

    //--------------------------------------------------------------
    //----------LOCAL VARIBALES & PARAMETERS-----------END----------
    //--------------------------------------------------------------




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



    //--------------------------------------------------------------
    //----------REGISTER ACCESS LOGIC--AXO SLV---------START--------
    //--------------------------------------------------------------
    
    
    assign o_axi_awready = o_axi_awready_val;
    assign o_axi_wready  = o_axi_wready_val;
    assign o_axi_arready = o_axi_arready_val;
    assign o_axi_rvalid  = o_axi_rvalid_val;
    assign o_axi_rresp   = o_axi_rresp_val;
    assign o_axi_rdata   = o_axi_rdata_val;

 

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // and the slave is ready to accept the write address and write data.


    //Implement axi_awready generation "AWREADY"
	always @(posedge clk_i) begin
        if (!rst_ni) begin
            o_axi_awready_val <= 0;
            aw_en <= 1;
        end
        else begin
            if ((o_axi_awready == 0) && (i_axi_awvalid == 1) && (i_axi_wvalid == 1) && (aw_en == 1)) begin
                o_axi_awready_val <= 1;  
            end
            else if ((i_axi_bready == 1) && (o_axi_bvalid == 1)) begin
	            aw_en <= 1;
	        	o_axi_awready_val <= 0;  
            end      
            else begin
                o_axi_awready_val <= 0;
            end
        end                  
	end 


    //Implement axi_wready generation "WREADY"
	always @(posedge clk_i) begin
        if (!rst_ni)
            o_axi_wready_val <=0;
        else begin
            if ((o_axi_wready == 0) && (i_axi_wvalid == 1) && (i_axi_awvalid == 1) && (aw_en == 1)) begin
                o_axi_wready_val <= 1;  
            end   
            else begin
                o_axi_wready_val <= 0;
            end
        end                  
	end

    assign md5_reg_wren = o_axi_wready && i_axi_wvalid && o_axi_awready && i_axi_awvalid ; 

    reg [OPT_MEM_ADDR_BITS:0]  loc_wr_addr, loc_rd_addr ; 

    always @(posedge clk_i or negedge rst_ni)  
    begin
        if (!rst_ni) begin
            md5_reg0 <= 'h0;
            md5_reg1 <= 'h0;
            md5_reg2 <= 'h0;
        end

        else begin
            loc_wr_addr = i_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS : ADDR_LSB];

            if (md5_reg_wren == 1) begin
            case (loc_wr_addr) 

                2'b00: begin
                    md5_reg0 <= i_axi_wdata;
                    //INIT_AXI_TXN <= md5_reg0;
                end

                2'b01: begin
                    md5_reg1 <= i_axi_wdata;
                end

                2'b10: begin
                    md5_reg2 <= i_axi_wdata;  
                end

                default: begin
                    md5_reg0 <= 0;
                    md5_reg1 <= 0;
                    md5_reg2 <= 0;
                end

            endcase
            end
        end
    end

    // Implement memory mapped register select and read logic generation
    // and the slave is ready to accept the read address.

    //Implement axi_arready generation "ARREADY"
	always @(posedge clk_i) begin
        if (!rst_ni)
            o_axi_arready_val <=0;
        else begin
            if ((o_axi_arready == 0) && (i_axi_arvalid == 1)) begin
                o_axi_arready_val <= 1;  
            end        
            else begin
                o_axi_arready_val <= 0;
            end
        end                  
	end 

    //Implement axi_rvalid generation "RVALID"
	always @(posedge clk_i) begin
        if (!rst_ni) begin
            o_axi_rvalid_val <=0;
            o_axi_rresp_val  <= 00; // 'OKAY' response
        end
        else begin
            if ((o_axi_arready == 1) && (i_axi_arvalid == 1) && (o_axi_rvalid == 0)) begin
                o_axi_rvalid_val <= 1; 
                o_axi_rresp_val  <= 00; // 'OKAY' response 
            end        
            else if((o_axi_rvalid == 1) && (i_axi_rready == 1)) begin
                o_axi_rvalid_val <= 0;
            end
        end                  
	end 

    assign md5_reg_rden = o_axi_arready && i_axi_arvalid && (!o_axi_rvalid) ; //Mahima-?

    always @(posedge clk_i or negedge rst_ni)  
    begin
		loc_rd_addr <= i_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS : ADDR_LSB];
		if(md5_reg_rden) begin
			case (loc_rd_addr)  
				2'b00 :   reg_data_out <= md5_reg0;
				2'b01 :   reg_data_out <= md5_reg1;
				2'b10 :   reg_data_out <= md5_reg2;
				default : reg_data_out <= 'h0;
        endcase
		end
    end
 
    //-- Output register or memory read data
    always @(posedge clk_i or negedge rst_ni)  
    begin
        if (!rst_ni)
            o_axi_rdata_val <= 'h0;
        else begin
        	if (md5_reg_rden == 1) 
                o_axi_rdata_val <= reg_data_out;     //-- register read data
        end
    end 


    //--------------------------------------------------------------
    //----------REGISTER ACCESS LOGIC------------------END--------
    //--------------------------------------------------------------


    //--------------------------------------------------------------
    //----------AXI4 MASTER INITIATION LOGIC------------START-------
    //--------------------------------------------------------------

	assign INIT_AXI_TXN = (md5_reg0) ? 1:0;

    //--------------------------------------------------------------
    //----------AXI4 MASTER INITIATION LOGIC--------------END-------
    //--------------------------------------------------------------


    //--------------------------------------------------------------
    //----------AXI4 MASTER PANCHAM INTERACTION------------START----
    //--------------------------------------------------------------

    // ip_buf = internal buffer of pancham
    // op_buf = output buffer of pancham
    /*always @(posedge clk_i or negedge rst_ni)  begin
        op_buf_wdata <= ip_buf_rdata;
        op_buf_awid  <= 1;
        ip_buf_arid  <= 1;
    end*/
    //reg [C_AXI_DATA_WIDTH - 1:0]  		wbs_dat_inpBuf_i;

	always @(posedge clk_i)  begin
       // wbs_dat_inpBuf_i <= ip_buf_rdata;
        op_buf_awid  <= 1;
        ip_buf_arid  <= 1;
    end

	//assign wbs_dat_i = ip_buf_rdata ;

	always @(posedge clk_i or negedge rst_ni)  begin
        op_buf_wdata <= wbs_dat_o;
        op_buf_awid  <= 1;
    	ip_buf_arid  <= 1;
    end

    //--------------------------------------------------------------
    //----------AXI4 MASTER PANCHAM INTERACTION--------------END----
    //--------------------------------------------------------------


    //--------------------------------------------------------------
    //----------AXI4 MASTER DESIGN------------START----
    //--------------------------------------------------------------

    // function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

    // function called clogb2 that returns an integer which has the 
    // value of the ceiling of the log base 2.                      
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
        bit_depth = bit_depth >> 1;                                 
    end                                                           
    endfunction                                                     

	// C_TRANSACTIONS_NUM is the width of the index counter for 
	// number of write or read transaction.
	localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);

	// Burst length for transactions, in C_M_AXI_DATA_WIDTHs.
	// Non-2^n lengths will eventually cause bursts across 4K address boundaries.
	localparam integer C_MASTER_LENGTH	= 12;
	// total number of burst transfers is master length divided by burst length and burst size
	localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8)-1);
	initial begin
		$display("C_NO_BURSTS_REQ = %d\n",C_NO_BURSTS_REQ);
	end
	
	// Example State machine to initialize counter, initialize write transactions, 
	// initialize read transactions and comparison of read data with the 
	// written data words.
	parameter [1:0] IDLE = 2'b00, // This state initiates AXI4Lite transaction 
			// after the state machine changes state to INIT_WRITE 
			// when there is 0 to 1 transition on INIT_AXI_TXN
		    INIT_WRITE   = 2'b01, // This state initializes write transaction,
			// once writes are done, the state machine 
			// changes state to INIT_READ 
		    INIT_READ = 2'b10, // This state initializes read transaction
			// once reads are done, the state machine 
			// changes state to INIT_COMPARE 
		    INIT_COMPARE = 2'b11; // This state issues the status of comparison 
			// of the written data with the read data	

	reg                             [1:0] mst_exec_state;

	//AXI4 internal temp signals
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	                        axi_awvalid;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	                        axi_wlast;
	reg  	                        axi_wvalid;
	reg  	                        axi_bready;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	                        axi_arvalid;
	reg  	                        axi_rready;
	
	reg [C_TRANSACTIONS_NUM : 0] 	write_index; //write beat count in a burst
	
	reg [C_TRANSACTIONS_NUM : 0] 	read_index;  //read beat count in a burst
	
	wire [C_TRANSACTIONS_NUM+2 : 0] burst_size_bytes; //size of C_M_AXI_BURST_LEN length burst in bytes
	
	reg [C_NO_BURSTS_REQ : 0] 	    write_burst_counter; //The burst counters are used to track the number of burst transfers of C_M_AXI_BURST_LEN burst length needed to transfer 2^C_MASTER_LENGTH bytes of data
	reg [C_NO_BURSTS_REQ : 0] 	    read_burst_counter;
	reg  	                        start_single_burst_write;
	reg  	                        start_single_burst_read;
	reg  	                        writes_done;
	reg  	                        reads_done;
	reg  	                        error_reg;
	reg  	                        compare_done;
	reg  	                        read_mismatch;
	reg  	                        burst_write_active;
	reg  	                        burst_read_active;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	expected_rdata;
	wire  	                        write_resp_error;
	wire  	                        read_resp_error;
	wire  	                        wnext;
	wire  	                        rnext;
	reg  	                        init_txn_ff;
	reg  	                        init_txn_ff2;
//	reg  	                        init_txn_edge;
	wire  	                        init_txn_pulse;


	// I/O Connections assignments

	//I/O Connections. Write Address (AW)
	assign M_AXI_AWID	= 'b0;
	//The AXI address is a concatenation of the target base address + active offset range
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WDATA	= axi_wdata;
	//All bursts are complete and aligned in this example
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	= axi_wlast;
	assign M_AXI_WUSER	= 'b0;
	assign M_AXI_WVALID	= axi_wvalid;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARID	= 'b0;
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_ARCACHE	= 4'b0010;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARUSER	= 'b1;
	assign M_AXI_ARVALID	= axi_arvalid;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;
	//Example design I/O
	assign TXN_DONE	= compare_done;
	//Burst size in bytes
	assign burst_size_bytes	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;

	assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;


	//Generate a pulse to initiate AXI transaction.
	always @(posedge M_AXI_ACLK)										      
	  begin                                                                        
	    // Initiates AXI transaction delay    
	    if (M_AXI_ARESETN == 0 )                                                   
	      begin                                                                    
	        init_txn_ff <= 1'b0;                                                   
	        init_txn_ff2 <= 1'b0;                                                   
	      end                                                                               
	    else                                                                       
	      begin  
	        init_txn_ff <= INIT_AXI_TXN;
	        init_txn_ff2 <= init_txn_ff;                                                                 
	      end                                                                      
	  end     


	//--------------------
	//Write Address Channel
	//--------------------

	// The purpose of the write address channel is to request the address and 
	// command information for the entire transaction.  It is a single beat
	// of information.

	// The AXI4 Write address channel in this example will continue to initiate
	// write commands as fast as it is allowed by the slave/interconnect.
	// The address will be incremented on each accepted address transaction,
	// by burst_size_byte to point to the next address. 

	  always @(posedge M_AXI_ACLK)                                   
	  begin                                                                
	                                                                       
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                           
	      begin                                                            
	        axi_awvalid <= 1'b0;                                           
	      end                                                              
	    else if (~axi_awvalid && start_single_burst_write)                 
	      begin                                                            
	        axi_awvalid <= 1'b1;                                           
	      end                                                              
	    /* Once asserted, VALIDs cannot be deasserted, so axi_awvalid      
	    must wait until transaction is accepted */                         
	    else if (M_AXI_AWREADY && axi_awvalid)                             
	      begin                                                            
	        axi_awvalid <= 1'b0;                                           
	      end                                                              
	    else                                                               
	      axi_awvalid <= axi_awvalid;                                      
	    end                                                                
	                                                                       
	                                                                       
	// Next address after AWREADY indicates previous address acceptance    
	  always @(posedge M_AXI_ACLK)                                         
	  begin                                                                
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                            
	      begin                                                            
	        axi_awaddr <= 'b0;                                             
	      end                                                              
	    else if (M_AXI_AWREADY && axi_awvalid)                             
	      begin                                                            
	        //MR axi_awaddr <= axi_awaddr + burst_size_bytes; 
            axi_awaddr <= md5_reg2;                  
	      end                                                              
	    else                                                               
	      axi_awaddr <= axi_awaddr;                                        
	    end                                                                


	//--------------------
	//Write Data Channel
	//--------------------

	//The write data will continually try to push write data across the interface.

	//The amount of data accepted will depend on the AXI slave and the AXI
	//Interconnect settings, such as if there are FIFOs enabled in interconnect.

	//Note that there is no explicit timing relationship to the write address channel.
	//The write channel has its own throttling flag, separate from the AW channel.

	//Synchronization between the channels must be determined by the user.

	//The simpliest but lowest performance would be to only issue one address write
	//and write data burst at a time.

	//In this example they are kept in sync by using the same address increment
	//and burst sizes. Then the AW and W channels have their transactions measured
	//with threshold counters as part of the user logic, to make sure neither 
	//channel gets too far ahead of each other.


	  assign wnext = M_AXI_WREADY & axi_wvalid;                                   
	                                                                                    
	// WVALID logic, similar to the axi_awvalid always block above                      
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                                        
	      begin                                                                         
	        axi_wvalid <= 1'b0;                                                         
	      end                                                                           
	    else if (~axi_wvalid && start_single_burst_write)                               
	      begin                                                                         
	        axi_wvalid <= 1'b1;                                                         
	      end                                                                           
	    /* If WREADY and too many writes, throttle WVALID                               
	    Once asserted, VALIDs cannot be deasserted, so WVALID                           
	    must wait until burst is complete with WLAST */                                 
	    else if (wnext && axi_wlast)                                                    
	      axi_wvalid <= 1'b0;                                                           
	    else                                                                            
	      axi_wvalid <= axi_wvalid;                                                     
	  end                                                                               
	                                                                                    
	                                                                                    
	//WLAST generation on the MSB of a counter underflow                                
	// WVALID logic, similar to the axi_awvalid always block above                      
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                                        
	      begin                                                                         
	        axi_wlast <= 1'b0;                                                          
	      end                                                                           
	    // axi_wlast is asserted when the write index                                   
	    // count reaches the penultimate count to synchronize                           
	    // with the last write data when write_index is b1111                           
	    // else if (&(write_index[C_TRANSACTIONS_NUM-1:1])&& ~write_index[0] && wnext)  
	    else if (((write_index == C_M_AXI_BURST_LEN-2 && C_M_AXI_BURST_LEN >= 2) && wnext) || (C_M_AXI_BURST_LEN == 1 ))
	      begin                                                                         
	        axi_wlast <= 1'b1;                                                          
	      end                                                                           
	    // Deassrt axi_wlast when the last write data has been                          
	    else if (wnext)                                                                 
	      axi_wlast <= 1'b0;                                                            
	    else if (axi_wlast && C_M_AXI_BURST_LEN == 1)                                   
	      axi_wlast <= 1'b0;                                                            
	    else                                                                            
	      axi_wlast <= axi_wlast;                                                       
	  end                                                                               
	                                                                                    
	                                                                                    
	/* Burst length counter. Uses extra counter register bit to indicate terminal       
	 count to reduce decode logic */                                                    
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 || start_single_burst_write == 1'b1)    
	      begin                                                                         
	        write_index <= 0;                                                           
	      end                                                                           
	    else if (wnext && (write_index != C_M_AXI_BURST_LEN-1))                         
	      begin                                                                         
	        write_index <= write_index + 1;                                             
	      end                                                                           
	    else                                                                            
	      write_index <= write_index;                                                   
	  end                                                                               
	                                                                                    
	                                                                                    
	/* Write Data Generator                                                             
	 Data pattern is only a simple incrementing count from 0 for each burst  */         
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
	      axi_wdata <= 'b1;                                                             
	    //else if (wnext && axi_wlast)                                                  
	    //  axi_wdata <= 'b0;                                                           
	    else if (wnext)                                                                 
	      //MR axi_wdata <= axi_wdata + 1;  
          axi_wdata <= op_buf_wdata;                                                 
	    else                                                                            
	      axi_wdata <= axi_wdata;                                                       
	    end                                                                             


	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//The write response channel provides feedback that the write has committed
	//to memory. BREADY will occur when all of the data and the write address
	//has arrived and been accepted by the slave.

	//The write issuance (number of outstanding write addresses) is started by 
	//the Address Write transfer, and is completed by a BREADY/BRESP.

	//While negating BREADY will eventually throttle the AWREADY signal, 
	//it is best not to throttle the whole data channel this way.

	//The BRESP bit [1] is used indicate any errors from the interconnect or
	//slave for the entire write burst. This example will capture the error 
	//into the ERROR output. 

	  always @(posedge M_AXI_ACLK)                                     
	  begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                            
	      begin                                                             
	        axi_bready <= 1'b0;                                             
	      end                                                               
	    // accept/acknowledge bresp with axi_bready by the master           
	    // when M_AXI_BVALID is asserted by slave                           
	    else if (M_AXI_BVALID && ~axi_bready)                               
	      begin                                                             
	        axi_bready <= 1'b1;                                             
	      end                                                               
	    // deassert after one clock cycle                                   
	    else if (axi_bready)                                                
	      begin                                                             
	        axi_bready <= 1'b0;                                             
	      end                                                               
	    // retain the previous value                                        
	    else                                                                
	      axi_bready <= axi_bready;                                         
	  end                                                                   
	                                                                        
	                                                                        
	//Flag any write response errors                                        
	  assign write_resp_error = axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]; 


	//----------------------------
	//Read Address Channel
	//----------------------------

	//The Read Address Channel (AW) provides a similar function to the
	//Write Address channel- to provide the tranfer qualifiers for the burst.

	//In this example, the read address increments in the same
	//manner as the write address channel.

	  always @(posedge M_AXI_ACLK)                                 
	  begin                                                              
	                                                                     
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                         
	      begin                                                          
	        axi_arvalid <= 1'b0;                                         
	      end                                                            
	    else if (~axi_arvalid && start_single_burst_read)                
	      begin                                                          
	        axi_arvalid <= 1'b1;                                         
	      end                                                            
	    else if (M_AXI_ARREADY && axi_arvalid)                           
	      begin                                                          
	        axi_arvalid <= 1'b0;                                         
	      end                                                            
	    else                                                             
	      axi_arvalid <= axi_arvalid;                                    
	  end                                                                
	                                                                     
	                                                                     
	// Next address after ARREADY indicates previous address acceptance  
	  always @(posedge M_AXI_ACLK)                                       
	  begin                                                              
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                          
	      begin                                                          
	        axi_araddr <= 'b0;                                        
	      end                                                            
	    else if (M_AXI_ARREADY && axi_arvalid)                           
	      begin                                                          
	        //MR axi_araddr <= axi_araddr + burst_size_bytes;  
            axi_araddr <= md5_reg1;               
	      end                                                            
	    else 
		 begin                                                         
	      axi_araddr <= axi_araddr;
		 end                                      
	  end                                                                


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	  assign rnext = M_AXI_RVALID && axi_rready;                            
	                                                                        
	                                                                        
	// Burst length counter. Uses extra counter register bit to indicate    
	// terminal count to reduce decode logic                                
	  always @(posedge M_AXI_ACLK)                                          
	  begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 || start_single_burst_read)                  
	      begin                                                             
	        read_index <= 0;                                                
	      end                                                               
	    else if (rnext && (read_index != C_M_AXI_BURST_LEN-1))              
	      begin                                                             
	        read_index <= read_index + 1;                                   
	      end                                                               
	    else                                                                
	      read_index <= read_index;                                         
	  end                                                                   
	                                                                        
	                                                                        
	/*                                                                      
	 The Read Data channel returns the results of the read request          
	                                                                        
	 In this example the data checker is always able to accept              
	 more data, so no need to throttle the RREADY signal                    
	 */                                                                     
	  always @(posedge M_AXI_ACLK)                                          
	  begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                  
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                               
	    // accept/acknowledge rdata/rresp with axi_rready by the master     
	    // when M_AXI_RVALID is asserted by slave                           
	    else if (M_AXI_RVALID)                       
	      begin                                      
	         if (M_AXI_RLAST && axi_rready)          
	          begin                                  
	            axi_rready <= 1'b0;                  
	          end                                    
	         else                                    
	           begin                                 
	             axi_rready <= 1'b1;                 
	           end                                   
	      end                                        
	    // retain the previous value                 
	  end            


	//MR adding logic to get the read_data 
    always @(posedge M_AXI_ACLK)                                          
	  begin
		  if(M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 ) 
		   begin
			   ip_buf_rdata <= 0;
		   end
		  else if(M_AXI_RVALID && axi_rready) 
		   begin
			   ip_buf_rdata <= M_AXI_RDATA;
		   end
		  else 
		   begin
			   ip_buf_rdata <= ip_buf_rdata;
		   end
      end


	//Check received read data against data generator                       
	  always @(posedge M_AXI_ACLK)                                          
	  begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                   
	      begin                                                             
	        read_mismatch <= 1'b0;                                          
	      end                                                               
	    //Only check data when RVALID is active                             
	    else if (rnext && (M_AXI_RDATA != expected_rdata))                  
	      begin                                                             
	        read_mismatch <= 1'b1;                                          
	      end                                                               
	    else                                                                
	      read_mismatch <= 1'b0;                                            
	  end                                                                   
	                                                                        
	//Flag any read response errors                                         
	  assign read_resp_error = axi_rready & M_AXI_RVALID & M_AXI_RRESP[1];  


	//----------------------------------------
	//Example design read check data generator
	//-----------------------------------------

	//Generate expected read data to check against actual read data

	  always @(posedge M_AXI_ACLK)                     
	  begin                                                  
		if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)// || M_AXI_RLAST)             
			expected_rdata <= 'b1;                            
		else if (M_AXI_RVALID && axi_rready)                  
			expected_rdata <= expected_rdata + 1;             
		else                                                  
			expected_rdata <= expected_rdata;                 
	  end                                                    


	//----------------------------------
	//Example design error register
	//----------------------------------

	//Register and hold any data mismatches, or read/write interface errors 

	  always @(posedge M_AXI_ACLK)                                 
	  begin                                                              
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                          
	      begin                                                          
	        error_reg <= 1'b0;                                           
	      end                                                            
	    else if (read_mismatch || write_resp_error || read_resp_error)   
	      begin                                                          
	        error_reg <= 1'b1;                                           
	      end                                                            
	    else                                                             
	      error_reg <= error_reg;                                        
	  end                                                                


	//--------------------------------
	//Example design throttling
	//--------------------------------

	// For maximum port throughput, this user example code will try to allow
	// each channel to run as independently and as quickly as possible.

	// However, there are times when the flow of data needs to be throtted by
	// the user application. This example application requires that data is
	// not read before it is written and that the write channels do not
	// advance beyond an arbitrary threshold (say to prevent an 
	// overrun of the current read address by the write address).

	// From AXI4 Specification, 13.13.1: "If a master requires ordering between 
	// read and write transactions, it must ensure that a response is received 
	// for the previous transaction before issuing the next transaction."

	// This example accomplishes this user application throttling through:
	// -Reads wait for writes to fully complete
	// -Address writes wait when not read + issued transaction counts pass 
	// a parameterized threshold
	// -Writes wait when a not read + active data burst count pass 
	// a parameterized threshold

	 // write_burst_counter counter keeps track with the number of burst transaction initiated            
	 // against the number of burst transactions the master needs to initiate                                   
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                                                                 
	      begin                                                                                                 
	        write_burst_counter <= 'b0;                                                                         
	      end                                                                                                   
	    else if (M_AXI_AWREADY && axi_awvalid)                                                                  
	      begin                                                                                                 
	        if (write_burst_counter[C_NO_BURSTS_REQ] == 1'b0)                                                   
	          begin                                                                                             
	            write_burst_counter <= write_burst_counter + 1'b1;                                              
	            //write_burst_counter[C_NO_BURSTS_REQ] <= 1'b1;                                                 
	          end                                                                                               
	      end                                                                                                   
	    else                                                                                                    
	      write_burst_counter <= write_burst_counter;                                                           
	  end                                                                                                       
	                                                                                                            
	 // read_burst_counter counter keeps track with the number of burst transaction initiated                   
	 // against the number of burst transactions the master needs to initiate                                   
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                                                 
	      begin                                                                                                 
	        read_burst_counter <= 'b0;                                                                          
	      end                                                                                                   
	    else if (M_AXI_ARREADY && axi_arvalid)                                                                  
	      begin                                                                                                 
	        if (read_burst_counter[C_NO_BURSTS_REQ] == 1'b0)                                                    
	          begin                                                                                             
	            read_burst_counter <= read_burst_counter + 1'b1;                                                
	            //read_burst_counter[C_NO_BURSTS_REQ] <= 1'b1;                                                  
	          end                                                                                               
	      end                                                                                                   
	    else                                                                                                    
	      read_burst_counter <= read_burst_counter;                                                             
	  end                                                                                                       
	                                                                                                            
	                                                                                                            
	  //implement master command interface state machine                                                        
	                                                                                                            
	  always @ ( posedge M_AXI_ACLK)                                                                            
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 1'b0 )                                                                             
	      begin                                                                                                 
	        // reset condition                                                                                  
	        // All the signals are assigned default values under reset condition                                
	        mst_exec_state      <= IDLE;                                                                
	        start_single_burst_write <= 1'b0;                                                                   
	        start_single_burst_read  <= 1'b0;                                                                   
	        compare_done      <= 1'b0;                                                                          
	        ERROR <= 1'b0;   
	      end                                                                                                   
	    else                                                                                                    
	      begin                                                                                                 
	                                                                                                            
	        // state transition                                                                                 
	        case (mst_exec_state)                                                                               
	                                                                                                            
	          IDLE:                                                                                     
	            // This state is responsible to wait for user defined C_M_START_COUNT                           
	            // number of clock cycles.                                                                      
	            if ( init_txn_pulse == 1'b1)                                                      
	              begin                                                                                         
	                mst_exec_state  <= INIT_READ;                                                              
	                ERROR <= 1'b0;
	                compare_done <= 1'b0;
	              end                                                                                           
	            else                                                                                            
	              begin                                                                                         
	                mst_exec_state  <= IDLE;                                                            
	              end                                                                                           
	                                                                                                            
	          INIT_WRITE:                                                                                       
	            // This state is responsible to issue start_single_write pulse to                               
	            // initiate a write transaction. Write transactions will be                                     
	            // issued until burst_write_active signal is asserted.                                          
	            // write controller                                                                             
	            if (writes_done)                                                                                
	              begin                                                                                         
	                mst_exec_state <= INIT_COMPARE;//                                                              
	              end                                                                                           
	            else                                                                                            
	              begin                                                                                         
	                mst_exec_state  <= INIT_WRITE;                                                              
	                                                                                                            
	                if (~axi_awvalid && ~start_single_burst_write && ~burst_write_active)                       
	                  begin                                                                                     
	                    start_single_burst_write <= 1'b1;                                                       
	                  end                                                                                       
	                else                                                                                        
	                  begin                                                                                     
	                    start_single_burst_write <= 1'b0; //Negate to generate a pulse                          
	                  end                                                                                       
	              end                                                                                           
	                                                                                                            
	          INIT_READ:                                                                                        
	            // This state is responsible to issue start_single_read pulse to                                
	            // initiate a read transaction. Read transactions will be                                       
	            // issued until burst_read_active signal is asserted.                                           
	            // read controller                                                                              
	            if (reads_done)                                                                                 
	              begin                                                                                         
	                mst_exec_state <= INIT_WRITE;                                                             
	              end                                                                                           
	            else                                                                                            
	              begin                                                                                         
	                mst_exec_state  <= INIT_READ;                                                               
	                                                                                                            
	                if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read)                         
	                  begin                                                                                     
	                    start_single_burst_read <= 1'b1;                                                        
	                  end                                                                                       
	               else                                                                                         
	                 begin                                                                                      
	                   start_single_burst_read <= 1'b0; //Negate to generate a pulse                            
	                 end                                                                                        
	              end                                                                                           
	                                                                                                            
	          INIT_COMPARE:                                                                                     
	            // This state is responsible to issue the state of comparison                                   
	            // of written data with the read data. If no error flags are set,                               
	            // compare_done signal will be asseted to indicate success.                                     
	            //if (~error_reg)                                                                               
	            begin                                                                                           
	              ERROR <= error_reg;
	              mst_exec_state <= IDLE;                                                               
	              compare_done <= 1'b1;                                                                         
	            end                                                                                             
	          default :                                                                                         
	            begin                                                                                           
	              mst_exec_state  <= IDLE;                                                              
	            end                                                                                             
	        endcase                                                                                             
	      end                                                                                                   
	  end //MASTER_EXECUTION_PROC                                                                               
	                                                                                                            
	                                                                                                            
	  // burst_write_active signal is asserted when there is a burst write transaction                          
	  // is initiated by the assertion of start_single_burst_write. burst_write_active                          
	  // signal remains asserted until the burst write is accepted by the slave                                 
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                                                 
	      burst_write_active <= 1'b0;                                                                           
	                                                                                                            
	    //The burst_write_active is asserted when a write burst transaction is initiated                        
	    else if (start_single_burst_write)                                                                      
	      burst_write_active <= 1'b1;                                                                           
	    else if (M_AXI_BVALID && axi_bready)                                                                    
	      burst_write_active <= 0;                                                                              
	  end                                                                                                       
	                                                                                                            
	 // Check for last write completion.                                                                        
	                                                                                                            
	 // This logic is to qualify the last write count with the final write                                      
	 // response. This demonstrates how to confirm that a write has been                                        
	 // committed.                                                                                              
	                                                                                                            
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                                                 
	      writes_done <= 1'b0;                                                                                  
	                                                                                                            
	    //The writes_done should be associated with a bready response                                           
	    //else if (M_AXI_BVALID && axi_bready && (write_burst_counter == {(C_NO_BURSTS_REQ-1){1}}) && axi_wlast)
	    else if (M_AXI_BVALID && (write_burst_counter[C_NO_BURSTS_REQ]) && axi_bready)                          
	      writes_done <= 1'b1;                                                                                  
	    else                                                                                                    
	      writes_done <= writes_done;                                                                           
	    end                                                                                                     
	                                                                                                            
	  // burst_read_active signal is asserted when there is a burst write transaction                           
	  // is initiated by the assertion of start_single_burst_write. start_single_burst_read                     
	  // signal remains asserted until the burst read is accepted by the master                                 
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                                                 
	      burst_read_active <= 1'b0;                                                                            
	                                                                                                            
	    //The burst_write_active is asserted when a write burst transaction is initiated                        
	    else if (start_single_burst_read)                                                                       
	      burst_read_active <= 1'b1;                                                                            
	    else if (M_AXI_RVALID && axi_rready && M_AXI_RLAST)                                                     
	      burst_read_active <= 0;                                                                               
	    end                                                                                                     
	                                                                                                            
	                                                                                                            
	 // Check for last read completion.                                                                         
	                                                                                                            
	 // This logic is to qualify the last read count with the final read                                        
	 // response. This demonstrates how to confirm that a read has been                                         
	 // committed.                                                                                              
	                                                                                                            
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                                                 
	      reads_done <= 1'b0;                                                                                   
	                                                                                                            
	    //The reads_done should be associated with a rready response                                            
	    //else if (M_AXI_BVALID && axi_bready && (write_burst_counter == {(C_NO_BURSTS_REQ-1){1}}) && axi_wlast)
	    else if (M_AXI_RVALID && axi_rready) //MR// && (read_index == C_M_AXI_BURST_LEN-1) && (read_burst_counter[C_NO_BURSTS_REQ]))
	      reads_done <= 1'b1;                                                                                   
	    else                                                                                                    
	      reads_done <= reads_done;                                                                             
	    end                                                                                                     





endmodule   // end md5_top_axi4lite
