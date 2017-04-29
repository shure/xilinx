
proc write_file {file_name text} {
    set file [open $file_name w]
    puts $file $text
    close $file
}

set hdf_file [lindex $argv 0]
set repo_path [lindex $argv 1]
set output_dir [lindex $argv 2]
#set bootargs [lindex $argv 3]

exec mkdir -p $output_dir

puts "HDF file: $hdf_file"
puts "Repo path: $repo_path"
puts "Output dir: $output_dir" 
#puts "Boot args: $bootargs"

hsi open_hw_design $hdf_file
hsi set_repo_path $repo_path
hsi create_sw_design device-tree -os device_tree -proc psu_cortexa53_0

#if { $bootargs != "" } {
    # default was: console=ttyPS0,115200
#    set_property CONFIG.bootargs $bootargs [get_os]
#}

hsi generate_target -dir $output_dir

set design [hsi get_hw_designs]
set part [hsi get_property PART $design]
set part [split $part "-"]
set chip [lindex $part 0]
set board [lindex $part end]
write_file $output_dir/chip $chip
write_file $output_dir/board $board

if { $board == "es1" } {
    set fsbl_board "zcu102"
} elseif { $board == "es2" } {
    set fsbl_board "zcu102-es2"
} else {
    error "Unknown board: $board"
}
write_file $output_dir/fsbl_board $fsbl_board

write_file $output_dir/design_name $design

puts "Hardware: chip=$chip board=$board fsbl_board=$fsbl_board"
puts "Design name: $design"
