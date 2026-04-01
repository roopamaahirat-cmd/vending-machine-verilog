`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2026 10:29:07
// Design Name: 
// Module Name: VendingMachine_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VendingMachine_TB;

//Inputs
reg CLK;
reg RST;
reg START;
reg CANCEL;
reg [2:0] PRODUCT_CODE;
reg ONLINE_PAYMENT;
reg [6:0] COINS;
//Outputs
wire [3:0] STATE;
wire DISPENS_PRODUCT;
wire [6:0] RETURN_CHANGE_VALUE;
wire [6:0] PRODUCT_PRICE_VALUE;

//Clock gn
always begin

    #5 CLK = ~CLK;    //10ns or 100MHZ

end

initial begin

   CLK = 1'b0;
   RST = 1'b1;
   START = 1'b0;
   CANCEL = 1'b0;
   COINS = 1'b0;
   ONLINE_PAYMENT = 0;
   PRODUCT_CODE = 3'b000;
   
   //Remove reset
   #100 RST = 1'b0;
   #100 ;
   
   //PEN Dispense with online payment
   START = 1'b1;
   ONLINE_PAYMENT = 1'b1;
   #30 START = 1'b0;
   ONLINE_PAYMENT = 1'b0;
   #50;
   START = 1'b1;
   PRODUCT_CODE = 3'b001; //Notebook
   COINS = 7'd60;
   #30 START = 1'b0;
   
   #50;
   START = 1'b1;
   PRODUCT_CODE = 3'b100; //Water
   COINS = 7'd20;
   #30 START = 1'b0;
   
   #50;
   START = 1'b1;
   PRODUCT_CODE = 3'b100; //Water
   COINS = 7'd30;
   #30 START = 1'b0;
   
   #50 $finish;
   
end

//DUT design under test
VendingMachine DUT(
    .i_clk      (CLK),            //clock signal
    .i_rst      (RST),            //Reset signal(active high)
    
    .i_start    (START),          //Start signal
    .i_cancel   (CANCEL),          //Cancel signal
    .i_product_code  (PRODUCT_CODE),       //product selection input signal
    .i_online_payment (ONLINE_PAYMENT),       //onlne payment signal
    .i_total_coin_value (COINS),               //total no of valid coins inserted
    
    
    .o_state    (STATE),                           //indicates current state
    .o_dispense_product (DISPENSE_PRODUCT),        //to dispense the product
    .o_return_change   (RETURN_CHANGE_VALUE),     //Return change value
    .o_product_price     (PRODUCT_PRICE_VALUE)     //Indicate the price of the selected product
    );
endmodule
