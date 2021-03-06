library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package image_info is 
    type INTEGERS is array (0 to 30) of integer range 0 to 1048575; -- TODO: refactor

    constant image_width : INTEGERS := (640, 640, 320, 320, 252, 72, 30, 163, 116, 109, 120, 108, 109, 106,
                                        124, 125, 122, 44, 290, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 40, 320);
    constant image_height : INTEGERS := (480, 480, 480, 480, 105, 70, 66, 285, 211, 209, 205, 213, 214, 218,
                                         218, 221, 216, 23, 121, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 40, 151);
    constant image_address : INTEGERS := (0, 307200, 614400, 691200, 768000, 781230, 783750, 784740, 807968,
                                          820206, 831597, 843897, 855399, 867062, 878616, 892132, 905945,
                                          919121, 919627, 937172, 937684, 938196, 938708, 939220, 939732,
                                          940244, 940756, 941268, 941780, 942292, 943092);

    type NUMBERS is array (0 to 9) of integer range 0 to 30;
    constant i_display_ram_1 : integer := 0;
    constant i_display_ram_2 : integer := 1;

    constant i_background1 : integer := 2;
    constant i_background2 : integer := 3;
    constant i_help : integer := 4;
    constant i_crow : integer := 5;
    constant i_holybullet : integer := 6;
    constant i_loser : integer := 7;
    constant i_person_left_1 : integer := 8;
    constant i_person_left_2 : integer := 9;
    constant i_person_left_3 : integer := 10;
    constant i_person_middle_1 : integer := 11;
    constant i_person_middle_2 : integer := 12;
    constant i_person_middle_3 : integer := 13;
    constant i_person_right_1 : integer := 14;
    constant i_person_right_2 : integer := 15;
    constant i_person_right_3 : integer := 16;
    constant i_bullet : integer := 17;
    constant i_start : integer := 18;
    constant i_number : NUMBERS := (19, 20, 21, 22, 23, 24, 25, 26, 27, 28);
    constant i_life : integer := 29;
    constant i_logo : integer := 30;
    
    constant graphics_ram_1 : integer := 0;
    constant graphics_ram_2 : integer := 307200;
end package image_info;