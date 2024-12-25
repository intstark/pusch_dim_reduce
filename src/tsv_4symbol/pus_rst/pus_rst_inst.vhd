	component pus_rst is
		port (
			source     : out std_logic_vector(15 downto 0);        -- source
			source_clk : in  std_logic                     := 'X'  -- clk
		);
	end component pus_rst;

	u0 : component pus_rst
		port map (
			source     => CONNECTED_TO_source,     --    sources.source
			source_clk => CONNECTED_TO_source_clk  -- source_clk.clk
		);

