action = "simulation"
sim_tool = "modelsim"
sim_top = "fir_2d_tb.sv"

sim_post_cmd = "vsim -voptargs=+acc -do wave.do -i fir_2d_tb"

modules = {
  "local" : [ "../../../tb/fir_2d_ciris" ],
}