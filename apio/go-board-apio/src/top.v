// Nandland Go Board simple mapping: switches to LEDs
// Ports aligned with the official Go_Board_Constraints.pcf
module top (
    input  wire        i_Clk,      // 25 MHz clock (unused here)
    // Push-buttons
    input  wire        i_Switch_1,
    input  wire        i_Switch_2,
    input  wire        i_Switch_3,
    input  wire        i_Switch_4,
    // LEDs
    output wire        o_LED_1,
    output wire        o_LED_2,
    output wire        o_LED_3,
    output wire        o_LED_4
);

    // Direct mapping: when switch i is pressed, LED i turns on
    assign o_LED_1 = i_Switch_1;
    assign o_LED_2 = i_Switch_2;
    assign o_LED_3 = i_Switch_3;
    assign o_LED_4 = i_Switch_4;

endmodule
