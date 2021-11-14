
module fifo2port (


);



endmodule


entity fifo2port is
  generic(
    fifo_size : natural := 1024;
    data_width : natural := 32
  );
  port(
    wrclk : in std_logic;
    wrrst_n : in std_logic;
    wren : in boolean;
    wrdata : in std_logic_vector(data_width-1 downto 0);
    full : out boolean := FALSE;

    rdclk : in std_logic;
    rdrst_n : in std_logic;
    rden : in boolean;
    rddata : out std_logic_vector(data_width-1 downto 0) := (others => '0');
    empty : out boolean := TRUE
  );
end fifo2port;

architecture behavioral of fifo2port is
--=======================================================
--  reg/wire and components declarations
--=======================================================

  type fifo_array_t is array(0 to fifo_size-1) of std_logic_vector(data_width-1 downto 0);
  signal fifo : fifo_array_t;

  signal wren_r : boolean := FALSE;
  signal wrdata_r : std_logic_vector(data_width-1 downto 0) := (others => '0');
  signal wrmem_r : natural range 0 to fifo_size-1 := 0;
  signal wrmem_next_r : natural range 0 to fifo_size-1 := 1;
  signal rdmem_r_wrsynced : natural range 0 to fifo_size-1 := 0;

  signal rden_r : boolean := FALSE;
  signal rdmem_r : natural range 0 to fifo_size-1 := 0;
  signal wrmem_r_rdsynced : natural range 0 to fifo_size-1 := 0;

begin
--=======================================================
--  structural coding
--=======================================================


  process (wrclk)
    variable rdmem_r_wrsynced_v : natural range 0 to fifo_size-1 := 0;
  begin
    if rising_edge(wrclk) then
      rdmem_r_wrsynced <= rdmem_r_wrsynced_v;
      rdmem_r_wrsynced_v := rdmem_r;
    end if;
  end process;

  process (wrclk,wrrst_n)
    variable full_v : boolean := FALSE;
  begin
    if rising_edge(wrclk) then
      full_v := wrmem_next_r = rdmem_r_wrsynced;
      if wren then
        wrdata_r <= wrdata;
        wren_r <= not full_v;
      end if;

      if wren_r then
        fifo(wrmem_r) <= wrdata_r;
        wrmem_r <= wrmem_next_r;
        if wrmem_next_r = fifo_size-1 then
          wrmem_next_r <= 0;
          full <= 0 = rdmem_r_wrsynced;
        else
          wrmem_next_r <= wrmem_next_r + 1;
          full <= wrmem_next_r + 1 = rdmem_r_wrsynced;
        end if;
      end if;
    end if;

    if wrrst_n = '0' then
      wrmem_r <= 0;
      wrmem_next_r <= 1;
      full_v := FALSE;
      full <= FALSE;
    end if;
  end process;

  process (rdclk)
    variable wrmem_r_rdsynced_v : integer range 0 to fifo_size-1 := 0;
  begin
    if rising_edge(rdclk) then
      wrmem_r_rdsynced <= wrmem_r_rdsynced_v;
      wrmem_r_rdsynced_v := wrmem_r;
    end if;
  end process;

  process (rdclk,rdrst_n)
    variable empty_v : boolean := TRUE;
  begin
    if rising_edge(rdclk) then
      empty_v := rdmem_r = wrmem_r_rdsynced;
      if rden and not empty_v then
        rden_r <= rden;
      else
        rden_r <= FALSE;
      end if;
    
      if rden_r then
        rddata <= fifo(rdmem_r);
        if rdmem_r = fifo_size-1 then
          rdmem_r <= 0;
          empty <= 0 = wrmem_r_rdsynced;
        else
          rdmem_r <= rdmem_r + 1;
          empty <= rdmem_r + 1 = wrmem_r_rdsynced;
        end if;
      end if;
    end if;
    if rdrst_n = '0' then
      rdmem_r <= 0;
      rddata <= (others => '0');
      empty_v := TRUE;
      empty <= TRUE;
      rden_r <= FALSE;
    end if;
  end process;


end behavioral;