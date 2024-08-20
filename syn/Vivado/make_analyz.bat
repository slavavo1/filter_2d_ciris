SET PATH=%VIVADO_19_1%\bin;%PATH%
hdlmake
make mrproper
make synthesize
@pause