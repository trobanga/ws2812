library design_library;
configuration TB_cfg of ws2812_vhd_tst is
  for Bench
    for i1: ws2812
      use entity design_library.ws2812(rtl);
    end for;
  end for;
end;

