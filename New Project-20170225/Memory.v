//This program consists of the design, codification and simulation of a RAM 
//Memory component of 256 bytes.  It is capable of managing bytes (8 bits), 
//halfwords (16 bits), words (32 bits) and doublewords (64 bits).  On the last
//case, two word operations are made to manage the 64 bits.  This process is 
//orchestrated by the CPU.  

//Author: Yorki G. Serrano-Natal

module ram256x8 (output reg [31:0] DataOut,        //Output Data, read from the RAM
                 output reg MOC,                   //Ouput that signals when an operation is completed
                 input MOV,                        //Input signal that initiates the RW operation
                 input RW,                         //Operation to be made: 1 = Read; 0 = Write
                 input [7:0] Address,              //Address in RAM were the operation will be made
                 input [31:0] DataIn,              //Input Data, written to RAM
                 input [1:0] Byte_HalfWord_Word,   //Size of the data to be managed
                 input IsSignedInstruction);       //Variable that signals if the instruction must be 
                                                   //treated with Sign Extension                   
                  
    reg [7:0] RAM[0:255];                           //256 byte Memory Locations
    
    //Operation to change MOC back to 0 whenever an operation is complete. 
    always @ (negedge MOV)  //Check if MOV changed from 1 to 0
    begin
        MOC <= 1'b0;        //Change MOC back to 0
    end
    
    //Operation that performs there's a change in MOV 
    always @ (MOV, RW)
    begin
        if (MOV)
        begin
            if (RW)
        //--------------------------------------------------------------------//
        //-------------------------READ OPERATION-----------------------------//
        //--------------------------------------------------------------------//
            begin
                //Checking data size specified by the CPU
                
                case (Byte_HalfWord_Word)
                    
                    //---------------------------BYTE------------------------//
                    2'b00:  
                        begin
                            if(IsSignedInstruction && RAM[Address][7] == 1'b1)
                            begin    
                                DataOut[31:8] <= 24'hffffff;
                            end
                            
                            else
                            begin
                                DataOut[31:8] <= 24'b0;
                            end
                               
                            DataOut[7:0] <= RAM[Address];
                            
                        end
                            
                    //------------------------HALFWORD-----------------------//
                    2'b01:  
                        begin
                        
                            if(IsSignedInstruction && RAM[Address][7] == 1)
                            begin
                                DataOut[31:16] <= 16'hffff;
                            end
                            
                            else
                            begin
                                DataOut[31:16] <= 16'b0;
                            end
                                
                            DataOut[15:8] <= RAM[Address];
                            DataOut[7:0] <= RAM[Address + 1];
                            
                        end
                            
                    //-------------------------WORD-------------------------//
                    2'b10:
                        begin 
                            DataOut[31:24] <= RAM[Address];
                            DataOut[23:16] <= RAM[Address + 1];
                            DataOut[15:8] <= RAM[Address + 2];
                            DataOut[7:0] <= RAM[Address + 3];
                        end
                        
                endcase
                
                MOC <=1'b1;  //Read Operation Completed
                
            end
            
            else 
        //--------------------------------------------------------------------//
        //-------------------------WRITE OPERATION----------------------------//
        //--------------------------------------------------------------------//
            begin
                //Checking data size specified by the CPU
                
                case (Byte_HalfWord_Word)
                    
                    //--------------------------BYTE-------------------------//
                    2'b00:  RAM[Address] <= DataIn[7:0]; 
                    
                    //------------------------HALFWORD-----------------------//
                    2'b01:  
                        begin
                            RAM[Address] <= DataIn[15:8];
                            RAM[Address + 1] <= DataIn[7:0];
                        end
                    //-------------------------WORD--------------------------//
                    2'b10:
                        begin 
                            RAM[Address] <= DataIn[31:24];
                            RAM[Address + 1] <= DataIn[23:16];
                            RAM[Address + 2] <= DataIn[15:8];
                            RAM[Address + 3] <= DataIn[7:0];
                        end
                endcase
                
                MOC<=1'b1;  //Write Operation Completed
                
            end
        end
    end
endmodule
