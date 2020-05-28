`timescale 1ns/1ns

module tb_axi_master_md5;

    logic                   clk_i;
    logic                   rst_ni;
    logic                   done;
    logic                   pass;



    parameter C_AXI_DATA_WIDTH  = 32;   // Width of the AXILite R&W data
    parameter C_AXI_ADDR_WIDTH  = 32;   // AXILite Address width


	parameter C_M_AXI_DATA_WIDTH   = 32; // Width of the AXI4 full R&W data
    parameter C_M_AXI_ADDR_WIDTH   = 32; // AXI4 full Address width
    parameter C_M_AXI_AWUSER_WIDTH = 0; // AXI4 full write address user width
    parameter C_M_AXI_ARUSER_WIDTH = 0; // AXI4 full read address user width
    parameter C_M_AXI_WUSER_WIDTH  = 0; // AXI4 full write data user width
    parameter C_M_AXI_RUSER_WIDTH  = 0; // AXI4 full read data user width
    parameter C_M_AXI_BUSER_WIDTH = 0; // AXI4 full write response user width
    parameter C_M_AXI_ID_WIDTH     = 2;  // AXI4 full ID width -- depends on number of masters



    typedef struct {
        bit [C_AXI_ADDR_WIDTH-1 : 0] addr;
        bit [C_AXI_DATA_WIDTH-1 : 0] data;
    } reg_packet_t;

    //bit [(C_AXI_ADDR_WIDTH+C_AXI_DATA_WIDTH)-1 : 0] queue[$];

    reg_packet_t queue[$];

    reg_packet_t reg_packet;


    //AXILite Slave Interface
    // AXI write address channel signals
    logic                                tb_o_axi_awready;  // Slave is ready to accept
    logic    [C_AXI_ADDR_WIDTH-1:0]      tb_i_axi_awaddr;   // Write address
    logic    [3:0]                       tb_i_axi_awcache;  // Write Cache type
    logic    [2:0]                       tb_i_axi_awprot;   // Write Protection type
    logic                                tb_i_axi_awvalid;  // Write address valid

    // AXI write data channel signals
    logic                                tb_o_axi_wready;   // Write data ready
    logic    [C_AXI_DATA_WIDTH-1:0]      tb_i_axi_wdata;    // Write data
    logic    [C_AXI_DATA_WIDTH/8-1:0]    tb_i_axi_wstrb;    // Write strobes
    logic                                tb_i_axi_wvalid;   // Write valid

    // AXI write response channel signals
    logic    [1:0]                       tb_o_axi_bresp;    // Write response
    logic                                tb_o_axi_bvalid;   // Write reponse valid
    logic                                tb_i_axi_bready;   // Response ready

    // AXI read address channel signals
    logic                                tb_o_axi_arready;  // Read address ready
    logic    [C_AXI_ADDR_WIDTH-1:0]      tb_i_axi_araddr;   // Read address
    logic    [3:0]                       tb_i_axi_arcache;  // Read Cache type
    logic    [2:0]                       tb_i_axi_arprot;   // Read Protection type
    logic                                tb_i_axi_arvalid;  // Read address valid

    // AXI read data channel signals
    logic [1:0]                          tb_o_axi_rresp;    // Read response
    logic                                tb_o_axi_rvalid;   // Read reponse valid
    logic [C_AXI_DATA_WIDTH-1:0]         tb_o_axi_rdata;    // Read data
    logic                                tb_i_axi_rready;   // Read Response ready




    // AXI Master Interface
    // AXI write address channel signals
    logic                                tb_m_axi_awready;  // Slave is ready to accept
    logic    [C_M_AXI_ID_WIDTH-1:0]      tb_m_axi_awid;     // Write address ID
    logic    [C_M_AXI_ADDR_WIDTH-1:0]    tb_m_axi_awaddr;   // Write address
    logic    [7:0]                       tb_m_axi_awlen;    // Write adress length
    logic    [2:0]                       tb_m_axi_awsize;   // Write adress size
    logic    [1:0]                       tb_m_axi_awburst;  // Write adress burst
    logic                                tb_m_axi_awlock;   // Write adress lock
    logic    [3:0]                       tb_m_axi_awcache;  // Write Cache type
    logic    [2:0]                       tb_m_axi_awprot;   // Write Protection type
    logic                                tb_m_axi_awvalid;  // Write address valid
    logic    [3:0]                       tb_m_axi_awqos;    // Write qos
    logic    [C_M_AXI_AWUSER_WIDTH-1:0]  tb_m_axi_awuser;   // Write user


    // AXI write data channel signals
    logic                                tb_m_axi_wready;   // Write data ready
    logic    [C_M_AXI_DATA_WIDTH-1:0]    tb_m_axi_wdata;    // Write data
    logic    [C_M_AXI_DATA_WIDTH/8-1:0]  tb_m_axi_wstrb;    // Write strobes
    logic                                tb_m_axi_wlast;    // Write last
    logic    [C_M_AXI_WUSER_WIDTH-1:0]   tb_m_axi_wuser;    // Write user
    logic                                tb_m_axi_wvalid;   // Write valid

    // AXI write response channel signals
    logic    [1:0]                       tb_m_axi_bresp;    // Write response
    logic    [C_M_AXI_ID_WIDTH-1:0]      tb_m_axi_bid;      // Write response ID
    logic    [C_M_AXI_BUSER_WIDTH-1:0]   tb_m_axi_buser;    // Write response user
    logic                                tb_m_axi_bvalid;   // Write reponse valid
    logic                                tb_m_axi_bready;   // Response ready

    // AXI read address channel signals
    logic                                tb_m_axi_arready;  // Slave is ready to accept
    logic    [C_M_AXI_ID_WIDTH-1:0]      tb_m_axi_arid;     // Read address ID
    logic    [C_M_AXI_ADDR_WIDTH-1:0]    tb_m_axi_araddr;   // Read address
    logic    [7:0]                       tb_m_axi_arlen;    // Read adress length
    logic    [2:0]                       tb_m_axi_arsize;   // Read adress size
    logic    [1:0]                       tb_m_axi_arburst;  // Read adress burst
    logic                                tb_m_axi_arlock;   // Read adress lock
    logic    [3:0]                       tb_m_axi_arcache;  // Read Cache type
    logic    [2:0]                       tb_m_axi_arprot;   // Read Protection type
    logic    [3:0]                       tb_m_axi_arqos;    // Read qos
    logic    [C_M_AXI_ARUSER_WIDTH-1:0]  tb_m_axi_aruser;   // Read user
    logic                                tb_m_axi_arvalid;  // Read address valid

    // AXI read data channel signals
    logic [1:0]                            tb_m_axi_rresp;    // Read response
    logic [C_M_AXI_ID_WIDTH-1:0]           tb_m_axi_rid;      // Read ID
    logic                                  tb_m_axi_rlast;     // Read last
    logic [C_M_AXI_RUSER_WIDTH-1:0]        tb_m_axi_ruser;    // Read user
    logic                                  tb_m_axi_rvalid;   // Read reponse valid
    logic [C_M_AXI_DATA_WIDTH-1:0]         tb_m_axi_rdata;    // Read data
    logic                                  tb_m_axi_rready;   // Read Response ready

	logic                                  tb_md5_reg_rden	;
	logic                                  tb_md5_reg_wren	;
    logic [C_M_AXI_DATA_WIDTH-1 :0]        tb_ip_buf_rdata;

    // Wishbone slave wires
    //logic                               tb_wb_rst;
    logic [C_AXI_ADDR_WIDTH - 3:0]   	tb_wbs_adr_i;
    logic [C_AXI_DATA_WIDTH - 1:0]  	tb_wbs_dat_i;
    logic [3:0]                         tb_wbs_sel_i;
    logic                               tb_wbs_we_i;
    logic                              	tb_wbs_cyc_i;
    logic                              	tb_wbs_stb_i;
    logic [C_AXI_DATA_WIDTH - 1:0]   	tb_wbs_dat_o;
    logic 								tb_wbs_err_o;
    logic                               tb_wbs_ack_o;

    // Instantiate the DUT
    md5_top_axi4lite md5_top_axi4lite_inst (
        .clk_i          ( clk_i               ),
        .rst_ni         ( rst_ni              ),

        // AXI4Lite Slave Interface
        .o_axi_awready  (tb_o_axi_awready),
        .i_axi_awaddr   (tb_i_axi_awaddr), 
        .i_axi_awcache  (tb_i_axi_awcache), 
        .i_axi_awprot   (tb_i_axi_awprot), 
        .i_axi_awvalid  (tb_i_axi_awvalid),

        .o_axi_wready   (tb_o_axi_wready), 
        .i_axi_wdata    (tb_i_axi_wdata), 
        .i_axi_wstrb    (tb_i_axi_wstrb), 
        .i_axi_wvalid   (tb_i_axi_wvalid),

        .o_axi_bresp    (tb_o_axi_bresp), 
        .o_axi_bvalid   (tb_o_axi_bvalid), 
        .i_axi_bready   (1'b1),

        .o_axi_arready  (tb_o_axi_arready),
        .i_axi_araddr   (tb_i_axi_araddr),
        .i_axi_arcache  (tb_i_axi_arcache),
        .i_axi_arprot   (tb_i_axi_arprot),
        .i_axi_arvalid  (tb_i_axi_arvalid),

        .o_axi_rresp    (tb_o_axi_rresp),
        .o_axi_rvalid   (tb_o_axi_rvalid),
        .o_axi_rdata    (tb_o_axi_rdata),
        .i_axi_rready   (1'b1),

        // AXI4 Master Interface
        .TXN_DONE       (),
        .ERROR          (),

        .M_AXI_ACLK     (clk_i),
        .M_AXI_ARESETN  (rst_ni),
        .M_AXI_AWID     (tb_m_axi_awid),
        .M_AXI_AWADDR   (tb_m_axi_awaddr),
        .M_AXI_AWLEN    (tb_m_axi_awlen),
        .M_AXI_AWSIZE   (tb_m_axi_awsize),
        .M_AXI_AWBURST  (tb_m_axi_awburst),
        .M_AXI_AWLOCK   (tb_m_axi_awlock),
        .M_AXI_AWCACHE  (tb_m_axi_awcache),
        .M_AXI_AWPROT   (tb_m_axi_awprot),
        .M_AXI_AWQOS    (tb_m_axi_awqos),
        .M_AXI_AWUSER   (tb_m_axi_awuser),
        .M_AXI_AWVALID  (tb_m_axi_awvalid),
        .M_AXI_AWREADY  (tb_m_axi_awready),

        .M_AXI_WDATA    (tb_m_axi_wdata),
        .M_AXI_WSTRB    (tb_m_axi_wstrb),
        .M_AXI_WLAST    (tb_m_axi_wlast),
        .M_AXI_WUSER    (tb_m_axi_wuser),
        .M_AXI_WVALID   (tb_m_axi_wvalid),
        .M_AXI_WREADY   (tb_m_axi_wready),

        .M_AXI_BID      (tb_m_axi_bid),
        .M_AXI_BRESP    (tb_m_axi_bresp),
        .M_AXI_BUSER    (tb_m_axi_buser),
        .M_AXI_BVALID   (tb_m_axi_bvalid),
        .M_AXI_BREADY   (tb_m_axi_bresp),

        .M_AXI_ARID     (tb_m_axi_arid),
        .M_AXI_ARADDR   (tb_m_axi_araddr),
        .M_AXI_ARLEN    (tb_m_axi_arlen),
        .M_AXI_ARSIZE   (tb_m_axi_arsize),
        .M_AXI_ARBURST  (tb_m_axi_arburst),
        .M_AXI_ARLOCK   (tb_m_axi_arlock),
        .M_AXI_ARCACHE  (tb_m_axi_arcache),
        .M_AXI_ARPROT   (tb_m_axi_arprot),
        .M_AXI_ARQOS    (tb_m_axi_arqos),
        .M_AXI_ARUSER   (tb_m_axi_aruser),
        .M_AXI_ARVALID  (tb_m_axi_arvalid),
        .M_AXI_ARREADY  (tb_m_axi_arready),

        .M_AXI_RID      (tb_m_axi_rid),
        .M_AXI_RDATA    (tb_m_axi_rdata),
        .M_AXI_RRESP    (tb_m_axi_rresp),
        .M_AXI_RLAST    (tb_m_axi_rlast),
        .M_AXI_RUSER    (tb_m_axi_ruser),
        .M_AXI_RVALID   (tb_m_axi_rvalid),
        .M_AXI_RREADY   (tb_m_axi_rready),

        .md5_reg_rden	( tb_md5_reg_rden  ),
	    .md5_reg_wren   ( tb_md5_reg_wren  ),
        .ip_buf_rdata   ( tb_ip_buf_rdata  ),

        	// Wishbone slave wires
        .wb_rst         (!rst_ni),
        .wbs_adr_i      (tb_wbs_adr_i),
	    .wbs_dat_i      (tb_wbs_dat_i),
        .wbs_sel_i      (tb_wbs_sel_i),
        .wbs_we_i       (tb_wbs_we_i),
        .wbs_cyc_i      (tb_wbs_cyc_i),
        .wbs_stb_i      (tb_wbs_stb_i),
        .wbs_dat_o      (tb_wbs_dat_o),
        .wbs_err_o      (tb_wbs_err_o),
        .wbs_ack_o      (tb_wbs_ack_o)

    );

    





/*************************************************************************/
/// this is just a dummy check for reg packet as RTL ready is not unable.
    always @(posedge clk_i) begin
        //if (tb_md5_reg_wren) begin
            if(tb_i_axi_awvalid) begin
                $display("write address : %h \n", tb_i_axi_awaddr);
                reg_packet.addr <= tb_i_axi_awaddr;
            end
            if(tb_i_axi_wvalid) begin        
                $display("write data: %h \n ", tb_i_axi_wdata);
                reg_packet.data <= tb_i_axi_wdata;
            end
            $display ("reg_packet = %0p",reg_packet);

        //end
    end
/************************************************************************/




    always @(posedge clk_i) begin
        if (tb_md5_reg_wren) begin
            if(tb_m_axi_awvalid && tb_m_axi_awready) begin
                $display("write address : %h \n", tb_m_axi_awaddr);
                reg_packet.addr <= tb_m_axi_awaddr;
            end
            if(tb_m_axi_wvalid && tb_m_axi_wready) begin        
                $display("write data: %h \n ", tb_m_axi_wdata);
                reg_packet.data <= tb_m_axi_wdata;
            end
            queue.push_back(reg_packet);
            $display ("reg_packet = %0p",reg_packet);

        end
    end

    always @(posedge clk_i) begin
        if (tb_md5_reg_rden) begin
            if(tb_m_axi_arvalid && tb_m_axi_arready) begin
                $display("write address : %h \n", tb_m_axi_araddr);
                reg_packet.addr <= tb_m_axi_araddr;
            end
            if(tb_m_axi_rvalid && tb_m_axi_rready) begin
                //$display("write data: %d \n ", tb_m_axi_wdata);
                foreach (queue[i]) 
                    $display ("queue[%0d] = %0p",i,queue[i]);
                    //if (queue[i].size !=0 && queue[i].addr == tb_m_axi_araddr )
                    //if (queue.addr == tb_m_axi_araddr )
                    //    tb_m_axi_rdata <= queue.data; 
            end
            //queue.push_back(reg_packet);
        end
    end

    initial begin
        // Initialize Inputs
        rst_ni = 0;
        clk_i = 1;

        // Wait 20 ns for global reset to finish and start counter
        #60;
        rst_ni = 1;
        clk_i = 0;

        #20;
        tb_i_axi_awvalid = 1'b0;
        tb_i_axi_wvalid = 1'b0;
        tb_i_axi_arvalid = 1'b0;


        //---------------AXI4 Lite Slave Interface-----------------------

        //Drive write address and write data into AXI4Lite slave interface 
        //1)Reg0 address is 00 , and data 0001 is activating the master 
        #40 tb_i_axi_awvalid  = 1'b1;
            tb_i_axi_wvalid    = 1'b1;
            tb_i_axi_awaddr   = 32'h00000;
            tb_i_axi_wdata     = 32'h0001;
        #50 tb_i_axi_awvalid   = 1'b0;
        #20 tb_i_axi_wvalid    = 1'b0;

        #150;
        //2)Reg1 address is 01 , and data ABCD is source address 
        #40 tb_i_axi_awvalid   = 1'b1;
            tb_i_axi_wvalid    = 1'b1;
            tb_i_axi_awaddr    = 32'h0004;
            tb_i_axi_wdata     = 32'hABCD;
        #50 tb_i_axi_awvalid   = 1'b0;
        #20 tb_i_axi_wvalid    = 1'b0;
        #150;
        //3)Reg2 address is 02 , and data F0F0 is Destination address 
        #40 tb_i_axi_awvalid   = 1'b1;
            tb_i_axi_awaddr    = 32'h0008;
            tb_i_axi_wvalid    = 1'b1;
            tb_i_axi_wdata     = 32'hF0F0;
        //#50 tb_i_axi_awvalid   = 1'b0;
        //#20 tb_i_axi_wvalid    = 1'b0;



        //Drive read address and receive read data from AXI4Lite slave interface 
        #40;
        tb_i_axi_arvalid = 1'b1;
        #40;
        tb_i_axi_araddr = 32'h0000;
        #140;
        tb_i_axi_araddr = 32'h0004;
        #140;
        tb_i_axi_araddr = 32'h0008;
        #100;

        //---------------AXI4 Lite Slave Interface-----------------------



        //---------------AXI4 Master Interface-----------------------

        //Drive Master interface related signals

        #20;
        tb_m_axi_awready = 0;
        tb_m_axi_wready  = 0;
        tb_m_axi_arready = 0;
        tb_m_axi_rvalid  = 0;
        tb_m_axi_bvalid  = 0; 

        #20;
        tb_m_axi_arready = 1;
        tb_m_axi_rvalid  = 1;

        #200;
        tb_m_axi_arready = 0;
    tb_m_axi_rvalid  = 0;

        #300;
        tb_m_axi_awready = 1;
        tb_m_axi_wready  = 1;
        
        #40;
        tb_m_axi_bvalid  = 1; 

        #500;        

        //---------------AXI4 Master Interface-----------------------
	    tb_wbs_sel_i = 1;
		tb_wbs_stb_i =1;
		tb_wbs_we_i =1;

        #40;
        tb_wbs_adr_i = 32'h0000;
        tb_wbs_dat_i = 1;

        #80;
        tb_wbs_adr_i = 32'h1;
        tb_wbs_dat_i = tb_ip_buf_rdata; 

        /*#80;
        tb_wbs_adr_i = 32'h2;
        tb_wbs_dat_i = tb_ip_buf_rdata;*/ 


        /*#80;
        tb_wbs_adr_i = 32'h3;
        tb_wbs_dat_i = 32'hFFFF;

        #80;
        tb_wbs_adr_i = 32'h4;
        tb_wbs_dat_i = 32'hFFFF_FFFF;


        #80;
        tb_wbs_adr_i = 32'h5;
        tb_wbs_dat_i = 32'h5;


        #80;
        tb_wbs_adr_i = 32'h6;
        tb_wbs_dat_i = 32'hFFFF;


        #80;
        tb_wbs_adr_i = 32'h7;
        tb_wbs_dat_i = 32'h7;


        #80;
        tb_wbs_adr_i = 32'h8;
        tb_wbs_dat_i = 32'h1111;

        #80;
        tb_wbs_adr_i = 32'h9;
        tb_wbs_dat_i = 32'hFFFF;

        #80;
        tb_wbs_adr_i = 32'ha;
        tb_wbs_dat_i = 32'haaaa_aaaa;
        

        #80;
        tb_wbs_adr_i = 32'hb;
        tb_wbs_dat_i = 32'hbbbb_bbbb;


        #80;
        tb_wbs_adr_i = 32'hc;
        tb_wbs_dat_i = 32'hc;


        #80;
        tb_wbs_adr_i = 32'hd;
        tb_wbs_dat_i = 32'h0000_11FF;

        #80;
        tb_wbs_adr_i = 32'he;
        tb_wbs_dat_i = 32'he;

        #80;
        tb_wbs_adr_i = 32'hf;
        tb_wbs_dat_i = 32'hFFFF;

        #80;
        tb_wbs_adr_i = 32'h10;
        tb_wbs_dat_i = 32'h1111_FFFF;*/


        // terminate simulation
        #400;
        $finish();
    end

    // Clock generator logic
    always@(clk_i) begin
        #10ns clk_i <= !clk_i;
    end

    always@(posedge clk_i) begin    
        if((tb_m_axi_rvalid==1) && (tb_m_axi_rready==1)) begin
            tb_m_axi_rid     = 1;
            tb_m_axi_rdata   = 'hFEDC;
        end
    end

    


/*
    always @(posedge clk_i) begin
        if (tb_md5_reg_rden) begin
            if(tb_m_axi_arvalid && tb_m_axi_arready) begin
                if (tb_m_axi_araddr == )
                $display("read address : %d \n", tb_m_axi_araddr);
                reg_packet.addr <= tb_m_axi_awaddr;
            end
            if(tb_m_axi_rvalid && tb_m_axi_rready) begin
                $display("read data: %d \n ", tb_m_axi_rdata);
                reg_packet.data <= tb_m_axi_wdata;
            end
            queue.push_back(reg_packet);
        end
    end
*/





/*
    //tCK value:
    int tCK = 5;

    // Reset the Device under Test
    task reset_dut();
        repeat (4) #tCK;
        rst <= 0;
        repeat (4) #tCK;
        rst <= 1;
        #tCK;
    endtask : reset_dut

    // Clock is always running
    initial begin
        while (!done) begin
            clk <= 1;
            #(tCK/2);
            clk <= 0;
            #(tCK/2);
        end
        $stop;
    end

    initial begin
        
        // Reset the system
        reset_dut();
        @(posedge clk);

        assign tb_m_axi_awready = 1;
        assign tb_m_axi_awvalid = 1;

        assign tb_m_axi_wready  = 1;
        assign tb_m_axi_wvalid  = 1;

        assign tb_m_axi_arvalid = 1;
        assign tb_m_axi_rready  = 1;
        assign tb_m_axi_rid     = 1;
        assign tb_m_axi_rdata   = 'hABCD;

        #400;

        done = 1;
        
    end



    // Implement write response logic generation  "BRESP"

    always @(posedge clk) begin
	    if ((tb_m_axi_awready == 1) && (tb_m_axi_awvalid == 1) && (tb_m_axi_wready = 1) && (tb_m_axi_wvalid == 1) && (tb_m_axi_bvalid == 0)  ) begin
            tb_m_axi_bvalid <= "1";
            tb_m_axi_bresp  <= "00"; 
        end 
	    else if ((tb_m_axi_bready == 1) && (tb_m_axi_bvalid == 1)) begin  
	        tb_m_axi_bvalid <= 0;                                       
	    end                  
	end 

	// Implement axi_arready generation "ARREADY"

	always @(posedge clk) begin
	    if ((tb_m_axi_arready == 0) && (tb_m_axi_arvalid == 1)) begin
            //indicates that the slave has acceped the valid read address
            tb_m_axi_arready <= 1;  
        end        
	    else begin
	        tb_m_axi_arready <= 0;
	    end                  
	end  

	// Implement axi_rvalid generation "RVALID"

	always @(posedge clk) begin
	    if ((tb_m_axi_arready == 1) && (tb_m_axi_arvalid == 1) && (tb_m_axi_rvalid == 0)) begin
	        //Valid read data is available at the read data bus
	        tb_m_axi_rvalid <= 1;
	        tb_m_axi_rresp  <= "00"; //'OKAY' response
        end
	    else if ((tb_m_axi_rvalid == 1) && (tb_m_axi_rready == 1)) begin
	        //Read data is accepted by the master
	        tb_m_axi_rvalid <= 0;
	    end          

	end

    //-------WRITE TRANSACTION--------//

    /*always @(posedge clk) begin
        if(tb_m_axi_awvalid) begin
           $display("Write address ID: %d \n", tb_m_axi_awid);
           $display("Write address: %d \n ", tb_m_axi_awaddr); 
           $display("Write AD Burst Type: %d \n", tb_m_axi_awburst);
           $display("Write AD Burst Length: %d \n", tb_m_axi_awlen);
        end

        if(tb_m_axi_wvalid) begin
           $display("Write data: %d \n ", tb_m_axi_wdata); 
           if(tb_m_axi_wlast) begin
               $display("Last write data recieved");
           end
        end

        if(tb_m_axi_bready) begin
           $display("Write ID: %d \n", tb_m_axi_bid);
        end

    end*/
      

endmodule
