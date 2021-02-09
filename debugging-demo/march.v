`timescale 1ns / 1ps
`default_nettype none

// set this to 1 to create a waveform file for easier debugging
`define GENERATE_VCD 0

/* A parameterized-width positive-edge-trigged register, with synchronous reset. 
   The value to take on after a reset is the 2nd parameter. */
module Nbit_reg #(parameter n=1, r=0)
   (input  wire [n-1:0] in,
    output wire [n-1:0] out,
    input  wire         clk,
    input  wire         we,
    input  wire         gwe,
    input  wire         rst);

   reg [n-1:0] state;

   assign #(1) out = state;

   always @(posedge clk) 
     begin 
       if (gwe & rst) 
         state = r;
       else if (gwe & we) 
         state = in; 
     end
endmodule

/* 
This module should produce a "marching bit" sequence on `o`. One bit should
initially be set, and it should "move" one position to the left on each clock
cycle. When it hits the MSB position, the bit should start moving to the right,
until it hits the LSB, when it reverses again, ad infinitum.
*/
module march (input wire        clock, 
              input wire        reset, 
              output wire [7:0] o);

   wire [7:0]         disp_in, disp_out;
   wire               dir_in, dir_out;

   Nbit_reg #(1) direction(.in(dir_in),
                           .out(dir_out),
                           .clk(clock), 
                           .we(1'b1), 
                           .gwe(1'b1), 
                           .rst(reset));
   
   Nbit_reg #(8) r(.in(disp_in),
                   .out(disp_out), 
                   .clk(clock), 
                   .we(1'b1), 
                   .gwe(1'b1), 
                   .rst(reset));
   
   assign disp_in = (dir_out == 1'b0) ? {disp_out[6:0],1'b0} : {1'b0,disp_out[7:1]} ;
   assign dir_in = (disp_out == 8'h80) ? 1'b1 :
                   (disp_out == 8'h01) ? 1'b0 :
                   dir_out;
   assign o = disp_out;

endmodule

// a testbench to drive the `march` module and display its output
module test_march();

   // status variables
   integer     i;

   wire [7:0] actual_out;
   
   reg         clock, reset;
   always #5 clock <= ~clock;
   
   // instantiate the Unit Under Test (UUT)
   march m(.clock(clock), .reset(reset), .o(actual_out));
   
   initial begin // start testbench block

      if (`GENERATE_VCD) begin
         $dumpfile("march.vcd");
         $dumpvars;
      end
      
      // initialize inputs
      clock = 0;
      i = 0;
      reset = 1;
      #10;
      reset = 0;

      for (i = 0; i <= 10; i = i + 1) begin
         $display("out = %b", actual_out);
         #9;
      end

      $display("Simulation finished");
      $finish;
   end

endmodule
