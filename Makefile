sim:
	verilator --cc --trace --exe --build -j 4 -Irtl/core -Irtl/peripherals -Irtl/memory rtl/audio_soc_top.sv dv/tb_audio_soc.cpp
	./obj_dir/Vaudio_soc_top

clean:
	rm -rf obj_dir waveform.vcd
