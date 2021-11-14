set_global_assignment -entity "chip_id" -library "lib_chip_id" -name IP_TOOL_NAME "altchip_id"
set_global_assignment -entity "chip_id" -library "lib_chip_id" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "chip_id" -library "lib_chip_id" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_chip_id" -name SPD_FILE [file join $::quartus(sip_path) "chip_id.spd"]

set_global_assignment -library "lib_chip_id" -name MISC_FILE [file join $::quartus(sip_path) "chip_id_sim/chip_id.v"]
set_global_assignment -library "lib_chip_id" -name MISC_FILE [file join $::quartus(sip_path) "chip_id_sim/altchip_id/altchip_id.v"]
