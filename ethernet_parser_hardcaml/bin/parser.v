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
    wire [15:0] _28;
    reg [15:0] _29;
    wire [15:0] _3;
    reg [15:0] _27;
    wire [47:0] _31 = 48'b000000000000000000000000000000000000000000000000;
    wire [47:0] _30 = 48'b000000000000000000000000000000000000000000000000;
    wire [15:0] _37;
    wire [31:0] _36;
    wire [47:0] _38;
    wire [15:0] _34;
    wire [31:0] _33;
    wire [47:0] _35;
    reg [47:0] _39;
    wire [47:0] _5;
    reg [47:0] _32;
    wire [47:0] _50 = 48'b000000000000000000000000000000000000000000000000;
    wire [47:0] _49 = 48'b000000000000000000000000000000000000000000000000;
    wire [47:0] _52;
    wire vdd = 1'b1;
    wire [1:0] _14 = 2'b00;
    wire [1:0] _13 = 2'b00;
    wire [1:0] _47;
    wire [1:0] _45 = 2'b11;
    wire [1:0] _46;
    wire [1:0] _43 = 2'b10;
    wire [1:0] _44;
    wire [1:0] _41 = 2'b01;
    wire [1:0] _40 = 2'b00;
    wire [1:0] _42;
    reg [1:0] _48;
    wire [1:0] _10;
    reg [1:0] _16;
    reg [47:0] _53;
    wire [47:0] _11;
    reg [47:0] _51;

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
    assign _28 = tdata[47:32];
    always @* begin
        case (_16)
        0: _29 <= _27;
        1: _29 <= _27;
        2: _29 <= _28;
        default: _29 <= _27;
        endcase
    end
    assign _3 = _29;
    always @(posedge clk) begin
        _27 <= _3;
    end
    assign _37 = _32[15:0];
    assign _36 = tdata[31:0];
    assign _38 = { _36, _37 };
    assign _34 = tdata[63:48];
    assign _33 = _32[47:16];
    assign _35 = { _33, _34 };
    always @* begin
        case (_16)
        0: _39 <= _32;
        1: _39 <= _35;
        2: _39 <= _38;
        default: _39 <= _32;
        endcase
    end
    assign _5 = _39;
    always @(posedge clk) begin
        _32 <= _5;
    end
    assign _52 = tdata[47:0];
    assign _47 = tvalid ? _45 : _40;
    assign _46 = tvalid ? _45 : _43;
    assign _44 = tvalid ? _43 : _41;
    assign _42 = tvalid ? _41 : _40;
    always @* begin
        case (_16)
        0: _48 <= _42;
        1: _48 <= _44;
        2: _48 <= _46;
        default: _48 <= _47;
        endcase
    end
    assign _10 = _48;
    always @(posedge clk) begin
        _16 <= _10;
    end
    always @* begin
        case (_16)
        0: _53 <= _51;
        1: _53 <= _52;
        2: _53 <= _51;
        default: _53 <= _51;
        endcase
    end
    assign _11 = _53;
    always @(posedge clk) begin
        _51 <= _11;
    end

    /* aliases */

    /* output assignments */
    assign dst_mac = _51;
    assign src_mac = _32;
    assign eth_type = _27;
    assign valid = _24;

endmodule
