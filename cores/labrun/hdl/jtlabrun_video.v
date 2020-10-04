/*  This file is part of JTCONTRA.
    JTCONTRA program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTCONTRA program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTCONTRA.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 3-10-2020 */

module jtlabrun_video(
    input               rst,
    input               clk,
    input               clk24,
    output              pxl2_cen,
    output              pxl_cen,
    output              LHBL,
    output              LVBL,
    output              LHBL_dly,
    output              LVBL_dly,
    output              HS,
    output              VS,
    output              flip,
    input               dip_pause,
    input               start_button,
    // PROMs
    input      [ 9:0]   prog_addr,
    input      [ 3:0]   prog_data,
    input               prom_we,
    // CPU      interface
    inout               gfx_cs,
    input               pal_cs,
    input               cpu_rnw,
    input               cpu_cen,
    input      [13:0]   cpu_addr,
    input      [ 7:0]   cpu_dout,
    output     [ 7:0]   gfx_dout,
    output     [ 7:0]   pal_dout,
    output              cpu_irqn,
    // SDRAM interface
    output     [17:0]   gfx_addr,
    input      [15:0]   gfx_data,
    input               gfx_ok,
    output              gfx_romcs,
    // Colours
    output     [ 4:0]   red,
    output     [ 4:0]   green,
    output     [ 4:0]   blue,
    // Test
    input      [ 3:0]   gfx_en
);

wire [ 8:0] vrender, vrender1, vdump, hdump;
wire [ 6:0] gfx_pxl;
wire [17:0] gfx_pre;
wire        gfx_sel;

// According to MAME, there are interrupts at 240Hz,
// which I assume should mean 4 interrupts per frame
// No schematics, no PCB, no gfx chip decap yet as of today
// so I am just aligning this to match LVBL nicely and
// leaving this function out of jtcontra_gfx for now
assign cpu_irqn = vdump[5:3]!=3'b110;

jtframe_cen48 u_cen(
    .clk        ( clk       ),    // 48 MHz
    .cen12      ( pxl2_cen  ),
    .cen16      (           ),
    .cen8       (           ),
    .cen6       ( pxl_cen   ),
    .cen4       (           ),
    .cen4_12    (           ), // cen4 based on cen12
    .cen3       (           ),
    .cen3q      (           ), // 1/4 advanced with respect to cen3
    .cen1p5     (           ),
    .cen12b     (           ),
    .cen6b      (           ),
    .cen3b      (           ),
    .cen3qb     (           ),
    .cen1p5b    (           )
);

jtframe_vtimer u_timer(
    .clk        ( clk           ),
    .pxl_cen    ( pxl_cen       ),
    .vdump      ( vdump         ),
    .vrender    ( vrender       ),
    .vrender1   ( vrender1      ),
    .H          ( hdump         ),
    .Hinit      (               ),
    .Vinit      (               ),
    .LHBL       ( LHBL          ),
    .LVBL       ( LVBL          ),
    .HS         ( HS            ),
    .VS         ( VS            )
);

jtcontra_gfx #(.BYPASS_VPROM(1)) u_gfx(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .clk24      ( clk24         ),
    .cpu_cen    ( cpu_cen       ),
    .pxl2_cen   ( pxl2_cen      ),
    .pxl_cen    ( pxl_cen       ),
    .LHBL       ( LHBL          ),
    .LVBL       ( LVBL          ),
    .HS         ( HS            ),
    .VS         ( VS            ),
    // PROMs
    .prom_we    ( prom_we       ),
    .prog_addr  ( prog_addr[8:0]),
    .prog_data  ( prog_data[3:0]),
    // Screen position
    .hdump      ( hdump         ),
    .vdump      ( vdump         ),
    .vrender    ( vrender       ),
    .vrender1   ( vrender1      ),
    .flip       ( flip          ),
    // CPU      interface
    .cs         ( gfx_cs        ),
    .cpu_rnw    ( cpu_rnw       ),
    .addr       ( cpu_addr      ),
    .cpu_dout   ( cpu_dout      ),
    .dout       ( gfx_dout      ),
    .cpu_irqn   (               ),
    // SDRAM interface
    .rom_obj_sel( gfx_sel       ),
    .rom_addr   ( gfx_pre       ),
    .rom_data   ( gfx_data      ),
    .rom_cs     ( gfx_romcs     ),
    .rom_ok     ( gfx_ok        ),
    .pxl_out    ( gfx_pxl       ),
    // Test
    .gfx_en     ( gfx_en[1:0]   )
);


jtlabrun_colmix u_colmix(
    .rst        ( rst           ),
    .clk        ( clk           ),
    .clk24      ( clk24         ),
    .cpu_cen    ( cpu_cen       ),
    .pxl2_cen   ( pxl2_cen      ),
    .pxl_cen    ( pxl_cen       ),
    .LHBL       ( LHBL          ),
    .LVBL       ( LVBL          ),
    .LHBL_dly   ( LHBL_dly      ),
    .LVBL_dly   ( LVBL_dly      ),
    // CPU      interface
    .pal_cs     ( pal_cs        ),
    .cpu_rnw    ( cpu_rnw       ),
    .cpu_addr   ( cpu_addr[7:0] ),
    .cpu_dout   ( cpu_dout      ),
    .pal_dout   ( pal_dout      ),
    // Colours
    .gfx_pxl    ( gfx_pxl       ),
    .red        ( red           ),
    .green      ( green         ),
    .blue       ( blue          )
);

endmodule