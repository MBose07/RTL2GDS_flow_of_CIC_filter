`timescale 1ns/1ns

module tb;
    // Parameters matching your DUT
    parameter integer out_width = 16;
    parameter integer in_width = 16;
    parameter integer decimation_ratio = 4;
    parameter integer order = 6;
    parameter integer differential_delay = 4;
    
    // Inputs
    reg clk;
    reg rst;
    reg signed [in_width-1:0] d_in;
    reg ce_1;
    reg ce_2;

    // Outputs
    wire signed [out_width-1:0] d_out;

    // Internal TB signals
    integer file_in, file_out;
    integer status;
    reg signed [in_width-1:0] sample_in;
    
    // Counter for generating the decimation clock enable (ce_2)
    integer dec_cnt;
    
    // Delayed ce_2 to capture valid output data
    reg ce_2_d;

    // Instantiate the Unit Under Test (UUT)
    cic #(
        .out_width(out_width),
        .in_width(in_width),
        .decimation_ratio(decimation_ratio),
        .order(order),
        .differential_delay(differential_delay)
    ) uut (
        .clk(clk),
        .rst(rst),
        .d_in(d_in),
        .ce_1(ce_1),
        .ce_2(ce_2),
        .d_out(d_out)
    );

    // Clock generation (10MHz)
    always #50 clk = ~clk;

    // Generate decimation clock enable (ce_2)
    always @(posedge clk) begin
        if (rst) begin
            dec_cnt <= 0;
            ce_2 <= 0;
        end else begin
            if (dec_cnt == decimation_ratio - 1) begin
                dec_cnt <= 0;
                ce_2 <= 1;
            end else begin
                dec_cnt <= dec_cnt + 1;
                ce_2 <= 0;
            end
        end
    end

    // Logic to capture output
    // The comb stage processes on ce_2, meaning d_out updates on the clock edge 
    // where ce_2 is high. We sample and write to file 1 cycle later (ce_2_d).
    always @(posedge clk) begin
        ce_2_d <= ce_2;
        if (!rst && ce_2_d) begin
            $fwrite(file_out, "%d\n", d_out);
        end
    end

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;       // Module uses active-high reset
        ce_1 = 1;      // Enable standard integrator clock
        ce_2 = 0;
        d_in = 0;
        dec_cnt = 0;

        // Open Files
        file_in = $fopen("input.txt", "r");
        file_out = $fopen("output.txt", "w");

        if (file_in == 0 || file_out == 0) begin
            $display("Error: Could not open input.txt or output_v.txt");
            $finish;
        end

        // Reset pulse
        #200 rst = 0;
        #100;

        $display("Starting simulation...");

        // Read input file line by line
        while (!$feof(file_in)) begin
            status = $fscanf(file_in, "%d\n", sample_in);
            
            // Assign 16-bit sample directly to d_in
            d_in = sample_in;
            
            // Wait for next clock cycle to feed the next sample
            @(posedge clk);
        end

        // Wait for the pipeline to flush (Decimation delay + Order latency)
        repeat (200) @(posedge clk);

        // Close Files
        $fclose(file_in);
        $fclose(file_out);
        
        $display("Simulation finished. Check output_v.txt");
        $finish;
    end

endmodule