module control_or_gate(
    input external_control,
    input axi_control,
    output control_trigger
    );
    assign control_trigger = external_control || axi_control;
    
endmodule
