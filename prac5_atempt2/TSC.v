`include "adc.v"

//state for state machine
`define STOP 3'b000 //when the machine is powered on and has not been reset yet.
`define READY 3'b001 //machine has been reset, waiting for start command
`define RUNNING 3'b010 //machine is running, incrementing the timer and writing adc values to the ring buffer
`define TRIGERED 3'b011 //the machine has been triggered, and is capturing the next 16 values
`define IDLE 3'b100 //the machine has capture the 16 values and is waiting for a start or SBF command
`define SENDING 3'b101 //the machine has received and SBF command and is sending data on the SD line.

//bit definitions for the current serial bit when transmitting data via SD line
`define WAIT_BIT 4'b1101 //wait for at least 1 posedge clk for first start bit
`define START_BIT 4'b1110 //start bit
`define END_BIT 4'b0111 //data bytes is only has bits 0-7, so reaching bit 8 means the byte has finished.
`define FIRST_BIT 4'b1111 //the 'first' bit of the byte. the serial bit is always incremented BEFORE the bit is sent

module TSC (
    //control lines for this module
    input wire clk,
    input wire reset,
    input wire start,
    input wire SBF,

    //watching register for test bench

    //state machine watchers
    output reg[2:0] state_out,

    //adc watchers
    output reg adc_request_out, 
    output reg adc_ready_out,
    output reg [7:0] adc_data_out,

    //ring buffer watchers
    output reg [4:0] read_ptr_out,
    output reg [4:0] write_ptr_out,
    output reg [7:0] ring_buffer_read_ptr,
    output reg [7:0] ring_buffer_write_ptr,
    
    //trigger watchers
    output reg [4:0] remaining_values_out,
    output reg [31:0] TRIGTM_out,

    //hub module watchers
    output reg TRD_out,
    output reg SD_out,
    output reg CD_out,
    output reg [3:0] serial_bit_out
    );

// ADC MODULE
  reg adc_request = 0;
  wire adc_ready;
  wire [7:0] adc_data;

  initial begin //assign watching registers for test bench
    assign adc_request_out = adc_request;
    assign adc_ready_out = adc_ready;
    assign adc_data_out = adc_data;
  end
  
  ADC i_adc (
    .req(adc_request),
    .rst(reset),
    .rdy(adc_ready),
    .dat(adc_data)
  );

// HUB MODULE (not implemented)
  reg TRD = 1'b0; //trigger the HUB that the values can be sent.
// wire SBF; //included as a TSC module input for testing
  reg SD = 1'b0; //serial data line
  reg CD = 1'b1; //completed data line

  initial begin //assign watching registers for test bench
    assign TRD_out = TRD;
    assign SD_out = SD;
    assign CD_out = CD;
  end

// TSC MACHINE CODE

  reg [2:0] state = `STOP; //current state for state machine
  reg [31:0] timer = 32'h0000; 
  reg [31:0] TRIGTM = 32'h0000; //time when triggered
  parameter [7:0] TRIGVL = 8'hc8; //constant trigger value.
  reg [4:0] remaining_values = 5'h00; //when triggered, this will count down from 16 to grab the following 16 adc values

  reg [7:0] ring_buffer [0:31]; 
  reg [4:0] read_ptr; //the 'head' of the ring buffer
  reg [4:0] write_ptr; //the 'tail' of the ring buffer
  reg [3:0] serial_bit; //current bit in the byte (including start bit) of the byte being sent over SD line.
  
  initial begin //assign watching registers for test bench
    assign state_out = state;
    assign read_ptr_out = read_ptr;
    assign write_ptr_out = write_ptr;
    assign remaining_values_out = remaining_values;
    assign TRIGTM_out = TRIGTM;
    assign serial_bit_out = serial_bit;
  end

// POSEDGE RESET
  always @(posedge reset) begin // reset completely reset this module and the adc
    state = `READY;
    // stuff that needs to be reset here
    remaining_values = 5'h00;
    read_ptr = 5'b00000;
    write_ptr = 5'b11111;
  end

//POSEDGE START
  always @(posedge start) begin // start starts the ring buffer and timer
    if ((state == `READY) || (state == `IDLE)) begin
      timer = 32'h0000;
      TRD = 1'b0;
      state = `RUNNING;
    end
  end

//POSEDGE CLOCK
  always @(posedge clk) begin
    case(state)

      `RUNNING: begin
        timer++;
        if (~ adc_request)
          adc_request = 1; //request new adc value (handled with posedge adc_ready)
      end

      `TRIGERED: begin
        timer++;
        if(remaining_values--) begin //check that there are remaining values left to capture and decrement.
          if (~ adc_request)
            adc_request = 1; //request new adc value (handled with posedge adc_ready)
        end else begin //all 16 values have been captured, wait for start or SBF command
          state = `IDLE; 
          TRD = 1'b1;
        end
      end

      `SENDING: begin //wait 1 posedge clk for first start bit
        if (serial_bit == `WAIT_BIT) begin
          serial_bit = `START_BIT;
        end
      end

      default:;

    endcase
  end

//NEGEDGE CLOCK
  always @(negedge clk) begin //bytes are written on negedge, and read on the posedge
    if (state == `SENDING) begin
      case(serial_bit)

        `WAIT_BIT:; //wait bit is handled by POSEDGE CLK

        `START_BIT: begin
            SD = 1'b0; //pull start bit low;
            serial_bit = `FIRST_BIT; //start the transmission
        end

        `END_BIT: begin
            //usually the stop bit would go here, but instead it transitions straight to the next stop bit
            SD = 1'b0;
            serial_bit = `FIRST_BIT; //serial = `START_BIT would implement the stop bit -> start bit -> next byte

            if (read_ptr++ == write_ptr) begin //read next byte. if bytes are finished, go to ready state and put CD high
                state = `READY;
                CD = 1'b1;
            end
        end

        default: begin //handle the byte transmission;
          SD = ring_buffer[read_ptr][++serial_bit]; //send the [serial bit] bit of the current byte
        end

      endcase
    end

    ring_buffer_read_ptr <= ring_buffer[read_ptr]; //update watching register
    ring_buffer_write_ptr <= ring_buffer[write_ptr]; //update watching register
  end

//POSEDGE ADC READY
  always @(posedge adc_ready) begin
    if (adc_request) begin
      #1 //delay so the pulse doesn't disappear on the echo. TO BE REMOVED
          
      //manage trigger_value
      if (state != `TRIGERED) begin  //if it hasn't been triggered already, check for a valid trigger
        if (adc_data > TRIGVL) begin
          state = `TRIGERED;
          TRIGTM = timer; //capture time of trigger
          remaining_values = 5'h10; //set remaining adc values to 16 (handled by posedge clk)
        end
      end

      //store data and move pointers around
      ring_buffer[++write_ptr] = adc_data;
      read_ptr++;

      adc_request = 0; //pull request down

      ring_buffer_read_ptr <= ring_buffer[read_ptr]; //update watching register
      ring_buffer_write_ptr <= ring_buffer[write_ptr]; //update watching register
    end
  end

//POSEDGE SBF
  always @(posedge SBF) begin
    if (state == `IDLE) begin //wait for SBF command when in idle state
      state = `SENDING;
      SD = 1'b1;
      CD = 1'b0;
      TRD = 1'b0;
      serial_bit = `WAIT_BIT; //wait for posedge clk to start the start bit
    end
  end

endmodule