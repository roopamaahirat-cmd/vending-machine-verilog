timescale 1ns / 1ps

module VendingMachine # (
parameter WATER_BOTTLE_PRICE = 7'd20,
parameter PEN_PRICE          = 7'd10,
parameter NOTEBOOK_PRICE     = 7'd50,
parameter COKE_PRICE         = 7'd35,
parameter LAYS_PRICE         = 7'd20
)
(
//Global signal
    input  wire         i_clk,          //clock signal
    input  wire         i_rst,          //Reset signal(active high)
    //Inputs
    input  wire         i_start,        //Start signal
    input  wire         i_cancel,       //Cancel signal
    input  wire [2:0]   i_product_code, //product selection input signal
    input  wire         i_online_payment, //onlne payment signal
    input  wire [6:0]   i_total_coin_value, //total no of valid coins inserted
    
    //output
    output wire [2:0]    o_state,                 //indicates current state
    output wire          o_dispense_product,     //to dispense the product
    output wire [6:0]    o_return_change,        //Return change value
    output wire [6:0]    o_product_price       //Indicate the price of the selected product
    );
    
    //States
localparam IDLE_STATE                   = 4'b000,
           SELECT_PRODUCT_STATE         = 4'b001,
           PEN_SELECTION_STATE          = 4'b010,
           NOTEBOOK_SELECTION_STATE     = 4'b011,
           COKE_SELECTION_STATE         = 4'b100,
           LAYS_SELECTION_STATE         = 4'b101,
           WATER_BOTTLE_SELECTION_STATE = 4'b110,
           DISPENSE_AND_RETURN_STATE    = 4'b111;
          
  //Internal wire or regs 
reg [2:0] r_state, r_next_state;
reg [6:0] r_return_change;
reg [6:0] r_next_return_change;
reg [6:0] r_product_price;
reg [6:0] r_next_product_price;

reg       r_dispense_product;

//Update States
always@(posedge i_clk or posedge i_rst) begin
   if (i_rst) begin
   
   r_state <=IDLE_STATE;
   r_product_price <=0;
   r_return_change <=0;
   
  end else begin
  
   r_state <= r_next_state;
   r_return_change <= r_next_return_change;
   r_product_price <= r_next_product_price; 
   
   end
   
end
  
 //State Machine
always@(*) begin

   //memory
  r_next_state = r_state;
  r_next_return_change = r_return_change;
  r_next_product_price = r_product_price;
  
  case(r_state)
   
      IDLE_STATE: begin
          
          if(i_start)
              r_next_state = SELECT_PRODUCT_STATE;
          else if(i_cancel)
               r_next_state = IDLE_STATE;
          else
               r_next_state = IDLE_STATE;
      
        end
      
      SELECT_PRODUCT_STATE: begin
          case(i_product_code)
          
          3'b000: begin
              r_next_state = PEN_SELECTION_STATE;
              r_next_product_price = PEN_PRICE;
      end
      
      3'b001: begin
              r_next_state = PEN_SELECTION_STATE;
              r_next_product_price = NOTEBOOK_PRICE;
      end
      
      3'b010: begin
              r_next_state = NOTEBOOK_SELECTION_STATE;
              r_next_product_price =COKE_PRICE;
      end
      
      3'b011: begin
              r_next_state = LAYS_SELECTION_STATE;
              r_next_product_price = LAYS_PRICE;
      end
      
      3'b100: begin
              r_next_state = WATER_BOTTLE_SELECTION_STATE;
              r_next_product_price = WATER_BOTTLE_PRICE;
      end
      
      //Never reached (avoid latches)
      default: begin
              r_next_state = IDLE_STATE;
              r_next_product_price = 0;
      end
      
   endcase
      
end
       
      PEN_SELECTION_STATE,
      NOTEBOOK_SELECTION_STATE,
      COKE_SELECTION_STATE,
      LAYS_SELECTION_STATE,
      WATER_BOTTLE_SELECTION_STATE: begin
      
           if(i_cancel)begin
               r_next_state = IDLE_STATE;
               r_next_return_change = i_total_coin_value;
           end 
           else if(i_total_coin_value >= r_product_price)
               r_next_state = DISPENSE_AND_RETURN_STATE;
           else if(i_online_payment)
                r_next_state = DISPENSE_AND_RETURN_STATE;
           else
                r_next_state = r_state;
                
      end
      
      DISPENSE_AND_RETURN_STATE: begin
      
                 r_next_state = IDLE_STATE;
                 if(i_online_payment)
                     r_next_return_change = 0;
                 else if (i_total_coin_value >= r_product_price)
                      r_next_return_change = i_total_coin_value - r_product_price;
      
      end
      
      default: begin
      
           r_next_state = IDLE_STATE;
           r_next_product_price = 0;
           r_next_return_change = 0;
      
      end
      
 endcase
   
      
end

//output logic
assign o_state = r_state;
assign o_dispense_product = (r_state ==   DISPENSE_AND_RETURN_STATE) ? 1'b1: 1'b0;
assign o_return_change = (r_state ==   DISPENSE_AND_RETURN_STATE) ? r_return_change: 1'b0;
assign o_product_price = (r_state ==   DISPENSE_AND_RETURN_STATE) ? r_product_price: 1'b0;
  
  endmodule  