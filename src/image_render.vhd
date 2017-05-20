library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use work.image_info.all;

entity image_render is 
    generic (
        VGA_WIDTH : integer := 640;
        VGA_HEIGHT : integer := 480
    );
    port (
        image_id : in integer range 0 to 31;
        base_address : in integer range 0 to 1048575;
        x : in integer range 0 to VGA_WIDTH;
        y : in integer range 0 to VGA_HEIGHT;
        rst, clk : in std_logic;
        din : in std_logic_vector(31 downto 0);
        dout : out std_logic_vector(31 downto 0);
        dout_en : out std_logic;
        we_n, oe_n: out std_logic;
        addr : out std_logic_vector(19 downto 0);
        sram_done : in std_logic;
        done : out std_logic
    );
end entity image_render;

architecture image_render_bhv of image_render is 
    type state is (s_init, s_read, s_write, s_done);
    signal current_state : state := s_init;
    signal data : std_logic_vector(15 downto 0);
    shared variable row : integer range 0 to VGA_HEIGHT;
    shared variable col : integer range 0 to VGA_WIDTH;
    shared variable cnt : integer range 0 to 1048575;
    shared variable alpha : std_logic;
begin
    dout <= x"0000" & data;

    main : process(clk, rst)
    begin
        if rst = '1' then
            current_state <= s_read;
            row := 0;
            col := 0;
            cnt := 0;
            done <= '0';
            oe_n <= '0';
            we_n <= '1';
            dout_en <= '0';
            addr <= conv_std_logic_vector(image_address(image_id) + cnt / 2, addr'length);
        elsif rising_edge(clk) then
            case current_state is
                when s_read =>
                    if sram_done = '1' then
                        if cnt MOD 2 = 0 then
                            alpha := din(0);
                        else
                            alpha := din(16);
                        end if;
                        if (row + x) >= VGA_HEIGHT or (col + y) >= VGA_WIDTH or alpha = '0' then 
                            current_state <= s_write;
                        else
                            if cnt MOD 2 = 0 then
                                data <= din(15 downto 0);
                            else
                                data <= din(31 downto 16);
                            end if;
                            current_state <= s_write;
                            oe_n <= '1';
                            we_n <= '0';
                            addr <= conv_std_logic_vector(base_address + (row + x) * VGA_WIDTH + (col + y), addr'length);
                            dout_en <= '1';
                        end if;
                    end if;
                when s_write =>
                    if sram_done = '1' then
                        col := col + 1;
                        cnt := cnt + 1;
                        if col = image_width(image_id) then
                            col := 0;
                            row := row + 1;
                        end if;
                        if row = image_height(image_id) then
                            current_state <= s_done;
                            done <= '1';
                        else
                            current_state <= s_read;
                            oe_n <= '0';
                            we_n <= '1';
                            dout_en <= '0';
                            addr <= conv_std_logic_vector(image_address(image_id) + cnt / 2, addr'length);
                        end if;
                    end if;
                when s_done =>
                    current_state <= s_done;
                when others =>
                    current_state <= s_init;
            end case;
        end if;
    end process;
end architecture image_render_bhv;