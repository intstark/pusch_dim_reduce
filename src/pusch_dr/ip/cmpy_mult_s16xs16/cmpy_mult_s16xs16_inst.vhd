	component cmpy_mult_s16xs16 is
		port (
			dataa_real  : in  std_logic_vector(15 downto 0) := (others => 'X'); -- dataa_real
			dataa_imag  : in  std_logic_vector(15 downto 0) := (others => 'X'); -- dataa_imag
			datab_real  : in  std_logic_vector(15 downto 0) := (others => 'X'); -- datab_real
			datab_imag  : in  std_logic_vector(15 downto 0) := (others => 'X'); -- datab_imag
			result_real : out std_logic_vector(31 downto 0);                    -- result_real
			result_imag : out std_logic_vector(31 downto 0);                    -- result_imag
			clock       : in  std_logic                     := 'X'              -- clk
		);
	end component cmpy_mult_s16xs16;

	u0 : component cmpy_mult_s16xs16
		port map (
			dataa_real  => CONNECTED_TO_dataa_real,  --  dataa_real.dataa_real
			dataa_imag  => CONNECTED_TO_dataa_imag,  --  dataa_imag.dataa_imag
			datab_real  => CONNECTED_TO_datab_real,  --  datab_real.datab_real
			datab_imag  => CONNECTED_TO_datab_imag,  --  datab_imag.datab_imag
			result_real => CONNECTED_TO_result_real, -- result_real.result_real
			result_imag => CONNECTED_TO_result_imag, -- result_imag.result_imag
			clock       => CONNECTED_TO_clock        --       clock.clk
		);

