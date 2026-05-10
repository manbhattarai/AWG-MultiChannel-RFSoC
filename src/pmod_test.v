
module pmod_test(
    input clk,
    input pmod_in,
    output pmod_out

    );
    
    
    reg in_ff;
    reg out_ff;
    
    always @(posedge clk)
    begin
        in_ff <= pmod_in;
        out_ff <= in_ff;
    end
    
    assign pmod_out = out_ff;
    
endmodule
