module ethernet_header_parser (
    tdata,
    clk,
    tvalid,
    dst_mac,
    src_mac,
    eth_type,
    valid
);

    input [63:0] tdata;
    input clk;
    input tvalid;
    output [47:0] dst_mac;
    output [47:0] src_mac;
    output [15:0] eth_type;
    output valid;

    /* signal declarations */
    wire _23 = 1'b0;
    wire _22 = 1'b0;
    wire _20 = 1'b1;
    wire _19 = 1'b0;
    wire _18 = 1'b0;
    wire _17 = 1'b0;
    reg _21;
    wire _1;
    reg _24;
    wire [15:0] _26 = 16'b0000000000000000;
    wire [15:0] _25 = 16'b0000000000000000;
    wire [7:0] _29;
    wire [7:0] _28;
    wire [15:0] _30;
    reg [15:0] _31;
    wire [15:0] _3;
    reg [15:0] _27;
    wire [47:0] _33 = 48'b000000000000000000000000000000000000000000000000;
    wire [47:0] _32 = 48'b000000000000000000000000000000000000000000000000;
    wire [7:0] _43;
    wire [7:0] _42;
    wire [7:0] _41;
    wire [7:0] _40;
    wire [15:0] _39;
    wire [47:0] _44;
    wire [31:0] _37 = 32'b00000000000000000000000000000000;
    wire [7:0] _36;
    wire [7:0] _35;
    wire [47:0] _38;
    reg [47:0] _45;
    wire [47:0] _5;
    reg [47:0] _34;
    wire [47:0] _56 = 48'b000000000000000000000000000000000000000000000000;
    wire [47:0] _55 = 48'b000000000000000000000000000000000000000000000000;
    wire [7:0] _63;
    wire [7:0] _62;
    wire [7:0] _61;
    wire [7:0] _60;
    wire [7:0] _59;
    wire [7:0] _58;
    wire [47:0] _64;
    wire vdd = 1'b1;
    wire [1:0] _14 = 2'b00;
    wire [1:0] _13 = 2'b00;
    wire [1:0] _53;
    wire [1:0] _51 = 2'b11;
    wire [1:0] _52;
    wire [1:0] _49 = 2'b10;
    wire [1:0] _50;
    wire [1:0] _47 = 2'b01;
    wire [1:0] _46 = 2'b00;
    wire [1:0] _48;
    reg [1:0] _54;
    wire [1:0] _10;
    reg [1:0] _16;
    reg [47:0] _65;
    wire [47:0] _11;
    reg [47:0] _57;

    /* logic */
    always @* begin
        case (_16)
        0: _21 <= _17;
        1: _21 <= _18;
        2: _21 <= _19;
        default: _21 <= _20;
        endcase
    end
    assign _1 = _21;
    always @(posedge clk) begin
        _24 <= _1;
    end
    assign _29 = tdata[47:40];
    assign _28 = tdata[39:32];
    assign _30 = { _28, _29 };
    always @* begin
        case (_16)
        0: _31 <= _27;
        1: _31 <= _27;
        2: _31 <= _30;
        default: _31 <= _27;
        endcase
    end
    assign _3 = _31;
    always @(posedge clk) begin
        _27 <= _3;
    end
    assign _43 = tdata[31:24];
    assign _42 = tdata[23:16];
    assign _41 = tdata[15:8];
    assign _40 = tdata[7:0];
    assign _39 = _34[47:32];
    assign _44 = { _39, _40, _41, _42, _43 };
    assign _36 = tdata[63:56];
    assign _35 = tdata[55:48];
    assign _38 = { _35, _36, _37 };
    always @* begin
        case (_16)
        0: _45 <= _34;
        1: _45 <= _38;
        2: _45 <= _44;
        default: _45 <= _34;
        endcase
    end
    assign _5 = _45;
    always @(posedge clk) begin
        _34 <= _5;
    end
    assign _63 = tdata[47:40];
    assign _62 = tdata[39:32];
    assign _61 = tdata[31:24];
    assign _60 = tdata[23:16];
    assign _59 = tdata[15:8];
    assign _58 = tdata[7:0];
    assign _64 = { _58, _59, _60, _61, _62, _63 };
    assign _53 = tvalid ? _51 : _46;
    assign _52 = tvalid ? _51 : _49;
    assign _50 = tvalid ? _49 : _47;
    assign _48 = tvalid ? _47 : _46;
    always @* begin
        case (_16)
        0: _54 <= _48;
        1: _54 <= _50;
        2: _54 <= _52;
        default: _54 <= _53;
        endcase
    end
    assign _10 = _54;
    always @(posedge clk) begin
        _16 <= _10;
    end
    always @* begin
        case (_16)
        0: _65 <= _57;
        1: _65 <= _64;
        2: _65 <= _57;
        default: _65 <= _57;
        endcase
    end
    assign _11 = _65;
    always @(posedge clk) begin
        _57 <= _11;
    end

    /* aliases */

    /* output assignments */
    assign dst_mac = _57;
    assign src_mac = _34;
    assign eth_type = _27;
    assign valid = _24;

endmodule
