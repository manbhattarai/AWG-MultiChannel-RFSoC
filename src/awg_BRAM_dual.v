module awg_BRAM_dual
  #(parameter GPIO_DATA_WIDTH = 16,
    parameter RAM_DATA_WIDTH = 128,
    parameter DAC_DATA_WIDTH = 256,
    parameter RAM_ADDR_WIDTH = 15,
    parameter RAM_WORD_WIDTH = 8, //number of 16-bit values at one RAM address
    parameter RAM_DEPTH = 1<<RAM_ADDR_WIDTH) 
   (input                        rst_n,
    input                        write_enable,
    input                        enable_ch0,
    input                        enable_ch2,
    input  [31:0]                MAX_POINTS,
    input                        control_trigger,
    input                        m_axis_clk,
    input  [GPIO_DATA_WIDTH-1:0] m_axis_tdata, 
    input                        m_axis_tvalid,
    output  reg                  m_axis_tready,
    input                        m00_axis_aclk,
    output [DAC_DATA_WIDTH-1:0]  m00_axis_tdata,
    output                       m00_axis_tvalid,
    input                        m22_axis_aclk,
    output [DAC_DATA_WIDTH-1:0]  m22_axis_tdata,
    output                       m22_axis_tvalid
    );
    
    reg [RAM_ADDR_WIDTH-1:0] raddr0;
    reg [RAM_ADDR_WIDTH-1:0] raddr1;
    reg [RAM_ADDR_WIDTH-1:0] raddr2;
    reg [RAM_ADDR_WIDTH-1:0] raddr3;
    
    reg [RAM_DATA_WIDTH-1:0] ram0 [0:RAM_DEPTH-1];
    reg [RAM_DATA_WIDTH-1:0] ram1 [0:RAM_DEPTH-1];
    reg [RAM_DATA_WIDTH-1:0] ram2 [0:RAM_DEPTH-1];
    reg [RAM_DATA_WIDTH-1:0] ram3 [0:RAM_DEPTH-1];
    
    (*ASYNC_REG = "TRUE"*)  reg [RAM_DATA_WIDTH-1:0] ram0_pipe0;
    (*ASYNC_REG = "TRUE"*) reg [RAM_DATA_WIDTH-1:0] ram1_pipe0;
    reg [RAM_DATA_WIDTH-1:0] ram0_pipe1;
    reg [RAM_DATA_WIDTH-1:0] ram1_pipe1;
    
    (*ASYNC_REG = "TRUE"*) reg [RAM_DATA_WIDTH-1:0] ram2_pipe0;
    (*ASYNC_REG = "TRUE"*) reg [RAM_DATA_WIDTH-1:0] ram3_pipe0;
    reg [RAM_DATA_WIDTH-1:0] ram2_pipe1;
    reg [RAM_DATA_WIDTH-1:0] ram3_pipe1;
        
    reg [DAC_DATA_WIDTH-1:0] data_out_0_pipe0;
    reg [DAC_DATA_WIDTH-1:0] data_out_1_pipe0;
    
    reg valid_out_0 = 0;
    reg valid_out_1 = 0;
    
    reg [RAM_DATA_WIDTH-1:0] temp_data_out;
    reg [2:0] ram_counter = 0;
    
    
    reg [$clog2(RAM_WORD_WIDTH) - 1 :0] col;
    reg [RAM_ADDR_WIDTH - 1 :0] row;
    
    reg read_enable_0;
    reg read_enable_2;
    always @(posedge m_axis_clk)
    begin
        read_enable_0 <= (!write_enable) && enable_ch0;
        read_enable_2 <= (!write_enable) && enable_ch2;
    end    
    reg [15:0] temp_storage;
    
    integer count;
    always @(posedge m_axis_clk)
    begin
        if(!rst_n)
        begin
            m_axis_tready <= 0;
            col <= 0;
            row <= 0;
            ram_counter <= 0;
            count <=0;
        end
        else 
        begin
            
            m_axis_tready <= 1;
            
            if(m_axis_tvalid && m_axis_tready)
            begin
                col <= col + 1;
                if (col == 8-1)
                begin
                    row <= row + 1;
                    if (row == RAM_DEPTH - 1)
                    begin
                        ram_counter <= ram_counter + 1;
                        if (ram_counter >= 3)
                        begin
                           ram_counter <= 3;
                            row <= RAM_DEPTH - 1;
                            col <= 8-1;   
                           m_axis_tready <= 0; 
                        end
                    end
                end 
                        
            end
    
        end
    
    end
    
    always @(posedge m_axis_clk) 
    begin
        if (write_enable)
        begin
            case (ram_counter)
                2'd0: ram0[row][col*16 +: 16] <= m_axis_tdata;
                2'd1: ram1[row][col*16 +: 16] <= m_axis_tdata;
                2'd2: ram2[row][col*16 +: 16] <= m_axis_tdata;
                2'd3: ram3[row][col*16 +: 16] <= m_axis_tdata;
                default : temp_storage <= m_axis_tdata;
            endcase
        end
    end 
       
    
    always@(posedge m00_axis_aclk)
    begin
        if(read_enable_0)
        begin
            valid_out_0 <= 1;
            ram0_pipe0 <= ram0[raddr0];
            ram1_pipe0 <= ram1[raddr1];
            ram0_pipe1 <= ram0_pipe0;
            ram1_pipe1 <= ram1_pipe0;
            data_out_0_pipe0 <= {ram1_pipe1,ram0_pipe1};
        end
        else
        begin
            data_out_0_pipe0 <= 16'b0;  // just having valid_out set to 0 did not disable the output. The dac would generate pulse at clock frequency.
            valid_out_0 <= 0;
        end
        
    end
    
    always@(posedge m22_axis_aclk)
    begin
        if(read_enable_2)
        begin
            valid_out_1 <= 1;
            ram2_pipe0 <= ram2[raddr2];
            ram3_pipe0 <= ram3[raddr3];
            ram2_pipe1 <= ram2_pipe0;
            ram3_pipe1 <= ram3_pipe0;
            data_out_1_pipe0 <= {ram3_pipe1,ram2_pipe1};
        end
        else
        begin
            valid_out_1 <= 0;
            data_out_1_pipe0 <= 16'b0;
        end
        
    end
    
     
     reg [RAM_ADDR_WIDTH-1:0] raddr0_pipe = 0;
     reg [RAM_ADDR_WIDTH-1:0] raddr1_pipe = 0;
     reg [RAM_ADDR_WIDTH-1:0] raddr2_pipe = 0;
     reg [RAM_ADDR_WIDTH-1:0] raddr3_pipe = 0;
     
     reg [RAM_ADDR_WIDTH-1:0] raddr0_pipe_trig = 0;
     reg [RAM_ADDR_WIDTH-1:0] raddr1_pipe_trig = 0;
     reg [RAM_ADDR_WIDTH-1:0] raddr2_pipe_trig = 0;
     reg [RAM_ADDR_WIDTH-1:0] raddr3_pipe_trig = 0;

     always@(posedge m00_axis_aclk)
     begin
        if (raddr0_pipe < MAX_POINTS)
        begin    
            raddr0_pipe <= raddr0_pipe + 1;
            raddr1_pipe <= raddr1_pipe + 1;
        end
        else
        begin
            raddr0_pipe <= 0;
            raddr1_pipe <= 0;
        end
        if (control_trigger)
        begin
            raddr0_pipe_trig <= raddr0_pipe + 2**(RAM_ADDR_WIDTH-1);
            raddr1_pipe_trig <= raddr1_pipe + 2**(RAM_ADDR_WIDTH-1);
        end
        else
        begin
            raddr0_pipe_trig <= raddr0_pipe;
            raddr1_pipe_trig <= raddr1_pipe;
        end
        raddr0 <= raddr0_pipe_trig;
        raddr1 <= raddr1_pipe_trig;
     end
     
     
     
     always@(posedge m22_axis_aclk)
     begin
        if (raddr2_pipe < MAX_POINTS)
        begin
            raddr2_pipe <= raddr2_pipe + 1;
            raddr3_pipe <= raddr3_pipe + 1;
        end
        else
        begin
            raddr2_pipe <= 0;
            raddr3_pipe <= 0;
        end
        if (control_trigger)
        begin
            raddr2_pipe_trig <= raddr2_pipe + 2**(RAM_ADDR_WIDTH-1);
            raddr3_pipe_trig <= raddr3_pipe + 2**(RAM_ADDR_WIDTH-1);
        end
        else
        begin
            raddr2_pipe_trig <= raddr2_pipe;
            raddr3_pipe_trig <= raddr3_pipe;
        end
        raddr2 <= raddr2_pipe_trig;
        raddr3 <= raddr3_pipe_trig;
     end

        
     assign m00_axis_tdata = data_out_0_pipe0;
     assign m22_axis_tdata = data_out_1_pipe0;
     assign m00_axis_tvalid = valid_out_0;
     assign m22_axis_tvalid = valid_out_1;
    
endmodule
