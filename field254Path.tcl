package require Tk
#change the filepath of both of these to wherever you put them on your pc
set 254_path [file join C: /Users Drew Desktop pathGui hopperPath.txt]
set test_field [file join C: /Users Drew Desktop pathGui Field.csv]

#you can change this to make the whole field+robot bigger or smaller, example: 12*2 is twice as big as 12*1
set pNum [expr 12*1]

wm geometry . [regsub -- {^[0-9]+x[0-9]+} [wm geometry .] 1000x600]
grid [tk::canvas .canvas -scrollregion "0 0 1000 1000" -yscrollcommand ".v set" -xscrollcommand ".h set"] -sticky nwes -column 0 -row 0
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

grid [tk::scrollbar .h -orient horizontal -command ".canvas xview"] -column 0 -row 1 -sticky we
grid [tk::scrollbar .v -orient vertical -command ".canvas yview"] -column 1 -row 0 -sticky ns
grid [ttk::sizegrip .sz] -column 1 -row 1 -sticky se

set heading 0
set length  [expr {2.25*$pNum}]
set width   [expr {2.25*$pNum}]

proc drawFE {color name startx starty args} {
set largs [split $args  ]
.canvas create line $args -fill $color -width 1 -tags $name
if {[lindex $largs 2] == 0} {
.canvas move $name $startx $starty
}
}

proc drawField {} {
global test_field pNum
set fieldE_list [list]
set fIn [open $test_field r]
gets $fIn linex
while {[gets $fIn linex] >= 0} {
    set fieldsx [split $linex ,]
    set x [lindex $fieldsx 0]
    set y [lindex $fieldsx 1]
    lappend fieldE_list [list $x $y]
}
close $fIn

set fieldElement_list [list]
set elemNum -1
set thingx "gray,halfField,[expr 3*$pNum],[expr 3*$pNum]"
foreach xy $fieldE_list {

 set x [lindex $xy 0]
 set y [lindex $xy 1]
 if {$x == {gray}} {
  #new element
set thingL [split $thingx ,]
drawFE {*}$thingL
set thingx "$x,$y"

 } else {
  #same element
set thingx "$thingx,[expr $x*$pNum],[expr $y*$pNum]"
 }
}
set thingL [split $thingx ,]
drawFE {*}$thingL
}
drawField

.canvas create poly 0 0 0 $width $length $width $length 0 -fill yellow -outline blue -width 1 -tags robot

proc moveRobot {x y} {
    .canvas move robot $x $y
}

proc rotateRobotBy {degrees} {
    global heading length width
    set heading [expr {$heading + $degrees}]
    rotateRobotTo $heading
}
proc rotateRobotTo {newHeading} {
    global heading length width
    set heading $newHeading
    set radians [expr {$heading * atan(1) * 4.0 / 180.0}]
    set xsum 0.0
    set ysum 0.0
    set npts 0
    foreach {x y} [.canvas coords robot] {
        incr npts
        set xsum [expr {$xsum + $x}]
        set ysum [expr {$ysum + $y}]
    }
    set xcenter [expr {$xsum * 1.0 / $npts}]
    set ycenter [expr {$ysum * 1.0 / $npts}]
    set coord_list [list]
    foreach {x y} [list [expr {$xcenter - ($length / 2)}]\
                        [expr {$ycenter - ($width  / 2)}]\
                        [expr {$xcenter - ($length / 2)}]\
                        [expr {$ycenter + ($width  / 2)}]\
                        [expr {$xcenter + ($length / 2)}]\
                        [expr {$ycenter + ($width  / 2)}]\
                        [expr {$xcenter + ($length / 2)}]\
                        [expr {$ycenter - ($width  / 2)}]] {
        set x [expr {$x - $xcenter}]  ;# shift to origin
        set y [expr {$y - $ycenter}]

        set xr [expr {$x * cos($radians) - $y * sin($radians)}]   ;# rotate
        set yr [expr {$x * sin($radians) + $y * cos($radians)}]

        set xx [expr {$xr + $xcenter}]   ;# shift back
        set yy [expr {$yr + $ycenter}]

        lappend coord_list $xx $yy
    }
    .canvas coords robot $coord_list
}

set 254_path_length 0
set 254_path_list [list]
set 254_path_listR [list]
set 254_path_listD [list]
proc 254Path {} {
global 254_path pNum 254_path_listR 254_path_length 254_path_list 254_path_listD pi
set pi [expr {2 * acos(0)}]
set fin [open $254_path r]
#set fout [open [file join C: /Users Drew Desktop pathGui testing.csv] w]
gets $fin line
gets $fin line
    set fields [split $line ,]
set 254_path_length [lindex $fields 0]
while {[gets $fin line] >= 0} {
lappend 254_path_list $line
}
close $fin
set lxy [list red lxy 0 0]
for {set l 0} {$l < $254_path_length} {incr l} {
 set lineDL [lindex $254_path_list $l]
 set lx [expr [lindex $lineDL 6]*$pNum]
 set ly [expr [lindex $lineDL 7]*$pNum]
 lappend lxy $lx
 lappend lxy $ly
}
drawFE {*}$lxy
set rxy [list red rxy 0 0]
for {set r 0} {$r < $254_path_length} {incr r} {
 set lineDR [lindex $254_path_list [expr $r+$254_path_length]]
 set rx [expr [lindex $lineDR 6]*$pNum]
 set ry [expr [lindex $lineDR 7]*$pNum]
 lappend rxy $rx
 lappend rxy $ry
}
drawFE {*}$rxy
set lastx 0
set lasty 0
for {set i 0} {$i < $254_path_length} {incr i} {
set firstLine [lindex $254_path_list $i]
set secondLine [lindex $254_path_list [expr $i+$254_path_length]]
set firstx [lindex $firstLine 6]
set firsty [lindex $firstLine 7]
set secondx [lindex $secondLine 6]
set secondy [lindex $secondLine 7]
set avgHdg [expr [lindex $firstLine 4]*180/$pi]
set dx [expr ((($firstx+$secondx)/2)-$lastx)]
set dy [expr ((($firsty+$secondy)/2)-$lasty)]

set wb [expr sqrt((($secondx-$firstx)*($secondx-$firstx))+(($secondy-$firsty)*($secondy-$firsty)))]
#puts $fout "$wb,wb,$firstx,$firsty,$secondx,$secondy,$dx,dx,$dy,dy,$avgHdg,avgHdg"
set lastx [expr $lastx+$dx]
set lasty [expr $lasty+$dy]
lappend 254_path_listR [list $avgHdg [expr $dx*$pNum] [expr $dy*$pNum]]
}

#close $fout
}
254Path

proc AssignElements { theList args } {
    set ix -1
    foreach varname $args {
        incr ix
        upvar $varname var
        set var [lindex $theList $ix]
    }
}

set delay 20
proc animateRobot {} {
    global istep delay 254_path_listR
    incr istep
    if {$istep < [llength $254_path_listR]} {
        AssignElements [lindex $254_path_listR $istep] hdg dx dy
        rotateRobotTo $hdg
        moveRobot $dx $dy
        after idle [list after $delay animateRobot]
    }
}

proc runPath {} {
    global istep length width pNum
    .canvas coords robot [list 0 0 0 $width $length $width $length 0]
    #.canvas move robot [expr 3*$pNum] [expr (3*$pNum)+(27.16666667/2*$pNum)-(1.125*$pNum)]
.canvas move robot [expr 3*$pNum] [expr (27*$pNum)-(2.25*$pNum)]
    set istep 0
    after idle [list after 0 animateRobot]
}
.canvas move lxy [expr (3*$pNum)+(1.125*$pNum)] [expr (27*$pNum)-(1.125*$pNum)]
.canvas move rxy [expr (3*$pNum)+(1.125*$pNum)] [expr (27*$pNum)-(1.125*$pNum)]

bind .canvas <1> {runPath}
