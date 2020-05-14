// Mahima - This tb is developed to test the axi master's write & read interface. 
//This tb emulates the axi4 slave
module tb_axi_master_md5;

    logic                   clk = 0;
    logic                   rst = 1;
    logic                   done = 0;
    logic                   pass = 1;

    parameter C_AXI_DATA_WIDTH  = 32;   // Width of the AXI R&W data
    parameter C_AXI_ADDR_WIDTH  = 32;   // AXI Address width


	parameter C_M_AXI_DATA_WIDTH   = 32; // Width of the AXI4 full R&W data
    parameter C_M_AXI_ADDR_WIDTH   = 32; // AXI4 full Address width
    parameter C_M_AXI_AWUSER_WIDTH = 0; // AXI4 full write address user width
    parameter C_M_AXI_ARUSER_WIDTH = 0; // AXI4 full read address user width
    parameter C_M_AXI_WUSER_WIDTH  = 0; // AXI4 full write data user width
    parameter C_M_AXI_RUSER_WIDTH  = 0; // AXI4 full read data user width
    parameter C_M_AXI_BUSER_WIDTH = 0; // AXI4 full write response user width
    parameter C_M_AXI_ID_WIDTH     = 2;  // AXI4 full ID width -- depends on number of masters


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

    // Instantiate the DUT
    md5_top_axi4lite md5_top_axi4lite_inst (
        .clk_i          ( clk               ),
        .rst_ni         ( rst               ),

        // AXI4Lite Slave Interface
        .o_axi_awready  ( ),
        .i_axi_awaddr   ( ), 
        .i_axi_awcache  ( ), 
        .i_axi_awprot   ( ), 
        .i_axi_awvalid  ( ),

        .o_axi_wready   ( ), 
        .i_axi_wdata    ( ), 
        .i_axi_wstrb    ( ), 
        .i_axi_wvalid   ( ),

        .o_axi_bresp    ( ), 
        .o_axi_bvalid   ( ), 
        .i_axi_bready   ( ),

        .o_axi_arready  ( ),
        .i_axi_araddr   ( ),
        .i_axi_arcache  ( ),
        .i_axi_arprot   ( ),
        .i_axi_arvalid  ( ),

        .o_axi_rresp    ( ),
        .o_axi_rvalid   ( ),
        .o_axi_rdata    ( ),
        .i_axi_rready   ( ),

        // AXI4 Master Interface
        .o_m_axi_awid   ( tb_m_axi_awid   ),
        .o_m_axi_awaddr ( tb_m_axi_awaddr), //Add the address from module 
        .o_m_axi_awlen  ( tb_m_axi_awlen  ),
        .o_m_axi_awsize ( ),
        .o_m_axi_awburst( tb_m_axi_awburst),
        .o_m_axi_awlock ( ),
        .o_m_axi_awcache( ),
        .o_m_axi_awprot ( ),
        .o_m_axi_awqos  ( ),
        .o_m_axi_awuser ( ),
        .o_m_axi_awvalid( tb_m_axi_awvalid ),
        .i_m_axi_awready( tb_m_axi_awready ),
    
        .o_m_axi_wdata  ( tb_m_axi_wdata   ),
        .o_m_axi_wstrb  ( tb_m_axi_wstrb),
        .o_m_axi_wlast  ( tb_m_axi_wlast   ),
        .o_m_axi_wuser  ( ),
        .o_m_axi_wvalid ( tb_m_axi_wvalid  ),
        .i_m_axi_wready ( tb_m_axi_wready  ),
    
        .i_m_axi_bid    ( tb_m_axi_bid     ),
        .i_m_axi_bresp  ( tb_m_axi_bresp   ),
        .i_m_axi_buser  ( ),
        .i_m_axi_bvalid ( tb_m_axi_bvalid  ),
        .o_m_axi_bready ( tb_m_axi_bready  ),
    
        .o_m_axi_arid   ( tb_m_axi_arid    ),
        .o_m_axi_araddr ( tb_m_axi_araddr  ), //Add the address from module 
        .o_m_axi_arlen  ( tb_m_axi_arlen   ), 
        .o_m_axi_arsize ( ), 
        .o_m_axi_arburst( tb_m_axi_arburst ), 
        .o_m_axi_arlock ( ),
        .o_m_axi_arcache( ), 
        .o_m_axi_arprot ( ),
        .o_m_axi_arqos  ( ),
        .o_m_axi_aruser ( ),
        .o_m_axi_arvalid( tb_m_axi_arvalid ),
        .i_m_axi_arready( tb_m_axi_arready ),
    
        .i_m_axi_rid    ( tb_m_axi_rid     ),
        .i_m_axi_rdata  ( tb_m_axi_rdata   ),
        .i_m_axi_rresp  ( tb_m_axi_rresp   ),
        .i_m_axi_rlast  ( tb_m_axi_rlast   ),
        .i_m_axi_ruser  ( ),
        .i_m_axi_rvalid ( tb_m_axi_rvalid  ),
        .o_m_axi_rready ( tb_m_axi_rready  )
    );

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

        assign tb_m_axi_bvalid  = 0;

        assign tb_m_axi_arvalid = 1;
        assign tb_m_axi_rvalid  = 0;
        assign tb_m_axi_rready  = 1;
        assign tb_m_axi_rid     = 1;
        assign tb_m_axi_rdata   = 'hABCD;

        #400;

        done = 1;
        
    end

    // Mahima - Implement write response logic generation  "BRESP"

    always @(posedge clk) begin
	    if ((tb_m_axi_awready == 1) && (tb_m_axi_awvalid == 1) && (tb_m_axi_wready = 1) && (tb_m_axi_wvalid == 1) && (tb_m_axi_bvalid == 0)  ) begin
            tb_m_axi_bvalid <= "1";
            tb_m_axi_bresp  <= "00"; 
            tb_m_axi_bid    <= tb_m_axi_awid;
        end 
	    else if ((tb_m_axi_bready == 1) && (tb_m_axi_bvalid == 1)) begin  
	        tb_m_axi_bvalid <= 0;                                       
	    end                  
	end 

	// Mahima - Implement axi_arready generation "ARREADY"

	always @(posedge clk) begin
	    if ((tb_m_axi_arready == 0) && (tb_m_axi_arvalid == 1)) begin
            //indicates that the slave has acceped the valid read address
            tb_m_axi_arready <= 1;  
        end        
	    else begin
	        tb_m_axi_arready <= 0;
	    end                  
	end  

	// Mahima - Implement axi_rvalid generation "RVALID"

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

    // Mahima --------WRITE TRANSACTION--------//

    always @(posedge clk) begin
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

    end
        

endmodule
