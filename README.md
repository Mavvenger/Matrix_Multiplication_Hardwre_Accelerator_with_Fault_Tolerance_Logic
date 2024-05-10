# Matrix_Multiplication_Hardwre_Accelerator_with_Fault_Tolerance_Logic
This project is based on Verilog HDL modeling a matrix multiplication hardware accelerator with fault tolerant logic                            
Design files contain:                                                                
(1)top.v ： Condensing of submodules                                                                                               
(2)CheckSum_Generation.v ： Generates the column and row checksum of the matrix                                                           
(3)CheckSum_Verification.v : Verifies that matrix column and row checksums are consistent with reference values                                      
(4)FSM_for_Baseline_with_Fault_Tolerance_Logic.v : Control data path data processing timing                                                        
(5)MACs.v : Multiply_Accumulate                      
(6)mux32.v : Data Selector                                             
(7)Circular_Shifter : Matrix Row Rotation 
Simulation files contain:                                                                                           
(1)tb_top.v : Joint functional simulation                                                                                        
(2)tb_CheckSum_Generation.v : CheckSum_Generation simulation                                             
(3)tb_CheckSum_Verification.v : CheckSum_Verification simulation                                                                                
(4)tb_FSM_for_Baseline_with_Fault_Tolerance_Logic.v : Datapath Controller simulation                                                              
(5)tb_MACs.v : MACs simulation                                                                   
(6)tb_mux32.v : mux32 simulation    '                                                                   
(7)tb_Circular_Shifter : Circular_Shifter simulation
