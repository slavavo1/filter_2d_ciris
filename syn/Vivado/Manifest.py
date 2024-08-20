target = "xilinx"
action = "synthesis"

syn_family = "ARTIX-7"
syn_device = "xc7a12t"
syn_grade = "-3"
syn_package = "cpg238"
syn_top = "filter_2d_ciris"
syn_project = "filter_2d_ciris"
syn_tool = "vivado"
language = "verilog"


modules = {
  "local" : [ "../../rtl" ],
}

