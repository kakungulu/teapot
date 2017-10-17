# interp.tcl --
#
#  Test file for compilation.
#  This file is a condensation of the Tcl test suite file interp.test.
#  It tests that the loader::bcproc object is correctly added at the end
#  of compilation. A now fixed bug caused it to crash the compiler executable
#  in GetCmdLocEncodingSize.
#
# Copyright (c) 1998-2000 by Ajuba Solutions. 
# Copyright (c) 2000, 2017 ActiveState Software Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: interp.tcl,v 1.2 2000/05/30 22:19:11 wart Exp $

# The set of hidden commands is platform dependent:

if {"$tcl_platform(platform)" == "macintosh"} {
    set hidden_cmds {beep cd echo encoding exit fconfigure file glob load ls open pwd socket source}
} else {
    set hidden_cmds {cd encoding exec exit fconfigure file glob load open pwd socket source}
}

foreach i [interp slaves] {
  interp delete $i
}

proc equiv {x} {return $x}

# Part 0: Check out options for interp command
test interp-1.1 {options for interp command} {
    list [catch {interp} msg] $msg
} {1 {wrong # args: should be "interp cmd ?arg ...?"}}
test interp-1.2 {options for interp command} {
    list [catch {interp frobox} msg] $msg
} {1 {bad option "frobox": must be alias, aliases, bgerror, create, delete, eval, exists, expose, hide, hidden, issafe, invokehidden, limit, marktrusted, recursionlimit, slaves, share, target, or transfer}}
test interp-1.3 {options for interp command} {
    interp delete
} ""
test interp-1.4 {options for interp command} {
    list [catch {interp delete foo bar} msg] $msg
} {1 {could not find interpreter "foo"}}
test interp-1.5 {options for interp command} {
    list [catch {interp exists foo bar} msg] $msg
} {1 {wrong # args: should be "interp exists ?path?"}}
#
# test interp-0.6 was removed
#
test interp-1.6 {options for interp command} {
    list [catch {interp slaves foo bar zop} msg] $msg
} {1 {wrong # args: should be "interp slaves ?path?"}}
test interp-1.7 {options for interp command} {
    list [catch {interp hello} msg] $msg
} {1 {bad option "hello": must be alias, aliases, bgerror, create, delete, eval, exists, expose, hide, hidden, issafe, invokehidden, limit, marktrusted, recursionlimit, slaves, share, target, or transfer}}
test interp-1.8 {options for interp command} {
    list [catch {interp -froboz} msg] $msg
} {1 {bad option "-froboz": must be alias, aliases, bgerror, create, delete, eval, exists, expose, hide, hidden, issafe, invokehidden, limit, marktrusted, recursionlimit, slaves, share, target, or transfer}}
test interp-1.9 {options for interp command} {
    list [catch {interp -froboz -safe} msg] $msg
} {1 {bad option "-froboz": must be alias, aliases, bgerror, create, delete, eval, exists, expose, hide, hidden, issafe, invokehidden, limit, marktrusted, recursionlimit, slaves, share, target, or transfer}} 
test interp-1.10 {options for interp command} {
    list [catch {interp target} msg] $msg
} {1 {wrong # args: should be "interp target path alias"}}

# Part 1: Basic interpreter creation tests:
test interp-2.1 {basic interpreter creation} {
    interp create a
} a
test interp-2.2 {basic interpreter creation} {
    catch {interp create}
} 0
test interp-2.3 {basic interpreter creation} {
    catch {interp create -safe}
} 0 
test interp-2.4 {basic interpreter creation} {
    list [catch {interp create a} msg] $msg
} {1 {interpreter named "a" already exists, cannot create}}
test interp-2.5 {basic interpreter creation} {
    interp create b -safe
} b
test interp-2.6 {basic interpreter creation} {
    interp create d -safe
} d
test interp-2.7 {basic interpreter creation} {
    list [catch {interp create -froboz} msg] $msg
} {1 {bad option "-froboz": must be -safe or --}}
test interp-2.8 {basic interpreter creation} {
    interp create -- -froboz
} -froboz
test interp-2.9 {basic interpreter creation} {
    interp create -safe -- -froboz1
} -froboz1
test interp-2.10 {basic interpreter creation} {
    interp create {a x1}
    interp create {a x2}
    interp create {a x3} -safe
} {a x3}
test interp-2.11 {anonymous interps vs existing procs} {
    set x [interp create]
    regexp {interp([0-9]+)} $x dummy thenum
    interp delete $x
    incr thenum
    proc interp$thenum {} {}
    set x [interp create]
    regexp {interp([0-9]+)} $x dummy anothernum
    if {$thenum == $anothernum} {
	set result 0
    } else {
	set result 1
    }
} 1    
test interp-2.12 {anonymous interps vs existing procs} {
    set x [interp create -safe]
    regexp {interp([0-9]+)} $x dummy thenum
    interp delete $x
    incr thenum
    proc interp$thenum {} {}
    set x [interp create -safe]
    regexp {interp([0-9]+)} $x dummy anothernum
    if {$thenum == $anothernum} {
	set result 0
    } else {
	set result 1
    }
} 1    
    
foreach i [interp slaves] {
    interp delete $i
}

# Part 2: Testing "interp slaves" and "interp exists"
test interp-3.1 {testing interp exists and interp slaves} {
    interp slaves
} ""
test interp-3.2 {testing interp exists and interp slaves} {
    interp create a
    interp exists a
} 1
test interp-3.3 {testing interp exists and interp slaves} {
    interp exists nonexistent
} 0
test interp-3.4 {testing interp exists and interp slaves} {
    list [catch {interp slaves a b c} msg] $msg
} {1 {wrong # args: should be "interp slaves ?path?"}}
test interp-3.5 {testing interp exists and interp slaves} {
    list [catch {interp exists a b c} msg] $msg
} {1 {wrong # args: should be "interp exists ?path?"}}
test interp-3.6 {testing interp exists and interp slaves} {
    interp exists
} 1
test interp-3.7 {testing interp exists and interp slaves} {
    interp slaves
} a
test interp-3.8 {testing interp exists and interp slaves} {
    list [catch {interp slaves a b c} msg] $msg
} {1 {wrong # args: should be "interp slaves ?path?"}}
test interp-3.9 {testing interp exists and interp slaves} {
    interp create {a a2} -safe
    interp slaves a
} {a2}
test interp-3.10 {testing interp exists and interp slaves} {
    interp exists {a a2}
} 1

# Part 3: Testing "interp delete"
test interp-3.11 {testing interp delete} {
    interp delete
} ""
test interp-4.1 {testing interp delete} {
    catch {interp create a}
    interp delete a
} ""
test interp-4.2 {testing interp delete} {
    list [catch {interp delete nonexistent} msg] $msg
} {1 {could not find interpreter "nonexistent"}}
test interp-4.3 {testing interp delete} {
    list [catch {interp delete x y z} msg] $msg
} {1 {could not find interpreter "x"}}
test interp-4.4 {testing interp delete} {
    interp delete
} ""
test interp-4.5 {testing interp delete} {
    interp create a
    interp create {a x1}
    interp delete {a x1}
    interp slaves a
} ""
test interp-4.6 {testing interp delete} {
    interp create c1
    interp create c2
    interp create c3
    interp delete c1 c2 c3
} ""
test interp-4.7 {testing interp delete} {
    interp create c1
    interp create c2
    list [catch {interp delete c1 c2 c3} msg] $msg
} {1 {could not find interpreter "c3"}}

foreach i [interp slaves] {
    interp delete $i
}

# Part 4: Consistency checking - all nondeleted interpreters should be
# there:
test interp-5.1 {testing consistency} {
    interp slaves
} ""
test interp-5.2 {testing consistency} {
    interp exists a
} 0
test interp-5.3 {testing consistency} {
    interp exists nonexistent
} 0

# Recreate interpreter "a"
interp create a

# Part 5: Testing eval in interpreter object command and with interp command
test interp-6.1 {testing eval} {
    a eval expr 3 + 5
} 8
test interp-6.2 {testing eval} {
    list [catch {a eval foo} msg] $msg
} {1 {invalid command name "foo"}}
test interp-6.3 {testing eval} {
    a eval {proc foo {} {expr 3 + 5}}
    a eval foo
} 8
test interp-6.4 {testing eval} {
    interp eval a foo
} 8

test interp-6.5 {testing eval} {
    interp create {a x2}
    interp eval {a x2} {proc frob {} {expr 4 * 9}}
    interp eval {a x2} frob
} 36
test interp-6.6 {testing eval} {
    list [catch {interp eval {a x2} foo} msg] $msg
} {1 {invalid command name "foo"}}

# UTILITY PROCEDURE RUNNING IN MASTER INTERPRETER:
proc in_master {args} {
     return [list seen in master: $args]
}

# Part 6: Testing basic alias creation
test interp-7.1 {testing basic alias creation} {
    a alias foo in_master
} foo
test interp-7.2 {testing basic alias creation} {
    a alias bar in_master a1 a2 a3
} bar
# Test 6.3 has been deleted.
test interp-7.3 {testing basic alias creation} {
    a alias foo
} in_master
test interp-7.4 {testing basic alias creation} {
    a alias bar
} {in_master a1 a2 a3}
test interp-7.5 {testing basic alias creation} {
    a aliases
} {foo bar}

# Part 7: testing basic alias invocation
test interp-8.1 {testing basic alias invocation} {
    catch {interp create a}
    a alias foo in_master
    a eval foo s1 s2 s3
} {seen in master: {s1 s2 s3}}
test interp-8.2 {testing basic alias invocation} {
    catch {interp create a}
    a alias bar in_master a1 a2 a3
    a eval bar s1 s2 s3
} {seen in master: {a1 a2 a3 s1 s2 s3}}

# Part 8: Testing aliases for non-existent targets
test interp-9.1 {testing aliases for non-existent targets} {
    catch {interp create a}
    a alias zop nonexistent-command-in-master
    list [catch {a eval zop} msg] $msg
} {1 {invalid command name "nonexistent-command-in-master"}}
test interp-9.2 {testing aliases for non-existent targets} {
    catch {interp create a}
    a alias zop nonexistent-command-in-master
    proc nonexistent-command-in-master {} {return i_exist!}
    a eval zop
} i_exist!

if {[info command nonexistent-command-in-master] != ""} {
    rename nonexistent-command-in-master {}
}

# Part 9: Aliasing between interpreters
test interp-10.1 {testing aliasing between interpreters} {
    catch {interp delete a}
    catch {interp delete b}
    interp create a
    interp create b
    interp alias a a_alias b b_alias 1 2 3
} a_alias
test interp-10.2 {testing aliasing between interpreters} {
    catch {interp delete a}
    catch {interp delete b}
    interp create a
    interp create b
    b eval {proc b_alias {args} {return [list got $args]}}
    interp alias a a_alias b b_alias 1 2 3
    a eval a_alias a b c
} {got {1 2 3 a b c}}
test interp-10.3 {testing aliasing between interpreters} {
    catch {interp delete a}
    catch {interp delete b}
    interp create a
    interp create b
    interp alias a a_alias b b_alias 1 2 3
    list [catch {a eval a_alias a b c} msg] $msg
} {1 {invalid command name "b_alias"}}
test interp-10.4 {testing aliasing between interpreters} {
    catch {interp delete a}
    interp create a
    a alias a_alias puts
    a aliases
} a_alias
test interp-10.5 {testing aliasing between interpreters} {
    catch {interp delete a}
    catch {interp delete b}
    interp create a
    interp create b
    a alias a_alias puts
    interp alias a a_del b b_del
    interp delete b
    a aliases
} a_alias
test interp-10.6 {testing aliasing between interpreters} {
    catch {interp delete a}
    catch {interp delete b}
    interp create a
    interp create b
    interp alias a a_command b b_command a1 a2 a3
    b alias b_command in_master b1 b2 b3
    a eval a_command m1 m2 m3
} {seen in master: {b1 b2 b3 a1 a2 a3 m1 m2 m3}}
test interp-10.7 {testing aliases between interpreters} {
    catch {interp delete a}
    interp create a
    interp alias "" foo a zoppo
    a eval {proc zoppo {x} {list $x $x $x}}
    set x [foo 33]
    a eval {rename zoppo {}}
    interp alias "" foo a {}
    equiv $x
} {33 33 33}

# Part 10: Testing "interp target"
test interp-11.1 {testing interp target} {
    list [catch {interp target} msg] $msg
} {1 {wrong # args: should be "interp target path alias"}}
test interp-11.2 {testing interp target} {
    list [catch {interp target nosuchinterpreter foo} msg] $msg
} {1 {could not find interpreter "nosuchinterpreter"}}
test interp-11.3 {testing interp target} {
    catch {interp delete a}
    interp create a
    a alias boo no_command
    interp target a boo
} ""
test interp-11.4 {testing interp target} {
    catch {interp delete x1}
    interp create x1
    x1 eval interp create x2
    x1 eval x2 eval interp create x3
    catch {interp delete y1}
    interp create y1
    y1 eval interp create y2
    y1 eval y2 eval interp create y3
    interp alias {x1 x2 x3} xcommand {y1 y2 y3} ycommand
    interp target {x1 x2 x3} xcommand
} {y1 y2 y3}
test interp-11.5 {testing interp target} {
    catch {interp delete x1}
    interp create x1
    interp create {x1 x2}
    interp create {x1 x2 x3}
    catch {interp delete y1}
    interp create y1
    interp create {y1 y2}
    interp create {y1 y2 y3}
    interp alias {x1 x2 x3} xcommand {y1 y2 y3} ycommand
    list [catch {x1 eval {interp target {x2 x3} xcommand}} msg] $msg
} {1 {target interpreter for alias "xcommand" in path "x2 x3" is not my descendant}}
test interp-11.6 {testing interp target} {
    foreach a [interp aliases] {
	rename $a {}
    }
    list [catch {interp target {} foo} msg] $msg
} {1 {alias "foo" in path "" not found}}
test interp-11.7 {testing interp target} {
    catch {interp delete a}
    interp create a
    list [catch {interp target a foo} msg] $msg
} {1 {alias "foo" in path "a" not found}}

# Part 11: testing "interp issafe"
test interp-12.1 {testing interp issafe} {
    interp issafe
} 0
test interp-12.2 {testing interp issafe} {
    catch {interp delete a}
    interp create a
    interp issafe a
} 0
test interp-12.3 {testing interp issafe} {
    catch {interp delete a}
    interp create a
    interp create {a x3} -safe
    interp issafe {a x3}
} 1
test interp-12.4 {testing interp issafe} {
    catch {interp delete a}
    interp create a
    interp create {a x3} -safe
    interp create {a x3 foo}
    interp issafe {a x3 foo}
} 1

# Part 12: testing interpreter object command "issafe" sub-command
test interp-13.1 {testing foo issafe} {
    catch {interp delete a}
    interp create a
    a issafe
} 0
test interp-13.2 {testing foo issafe} {
    catch {interp delete a}
    interp create a
    interp create {a x3} -safe
    a eval x3 issafe
} 1
test interp-13.3 {testing foo issafe} {
    catch {interp delete a}
    interp create a
    interp create {a x3} -safe
    interp create {a x3 foo}
    a eval x3 eval foo issafe
} 1

# part 14: testing interp aliases
test interp-14.1 {testing interp aliases} {
    interp aliases
} ""
test interp-14.2 {testing interp aliases} {
    catch {interp delete a}
    interp create a
    a alias a1 puts
    a alias a2 puts
    a alias a3 puts
    lsort [interp aliases a]
} {a1 a2 a3}
test interp-14.3 {testing interp aliases} {
    catch {interp delete a}
    interp create a
    interp create {a x3}
    interp alias {a x3} froboz "" puts
    interp aliases {a x3}
} froboz

# part 15: testing file sharing
test interp-15.1 {testing file sharing} {
    catch {interp delete z}
    interp create z
    z eval close stdout
    list [catch {z eval puts hello} msg] $msg
} {1 {can not find channel named "stdout"}}
catch {removeFile file-15.2}
test interp-15.2 {testing file sharing} {
    catch {interp delete z}
    interp create z
    set f [open file-15.2 w]
    interp share "" $f z
    z eval puts $f hello
    z eval close $f
    close $f
} ""
catch {removeFile file-15.2}
test interp-15.3 {testing file sharing} {
    catch {interp delete xsafe}
    interp create xsafe -safe
    list [catch {xsafe eval puts hello} msg] $msg
} {1 {can not find channel named "stdout"}}
catch {removeFile file-15.4}
test interp-15.4 {testing file sharing} {
    catch {interp delete xsafe}
    interp create xsafe -safe
    set f [open file-15.4 w]
    interp share "" $f xsafe
    xsafe eval puts $f hello
    xsafe eval close $f
    close $f
} ""
catch {removeFile file-15.4}
test interp-15.5 {testing file sharing} {
    catch {interp delete xsafe}
    interp create xsafe -safe
    interp share "" stdout xsafe
    list [catch {xsafe eval gets stdout} msg] $msg
} {1 {channel "stdout" wasn't opened for reading}}
catch {removeFile file-15.6}
test interp-15.6 {testing file sharing} {
    catch {interp delete xsafe}
    interp create xsafe -safe
    set f [open file-15.6 w]
    interp share "" $f xsafe
    set x [list [catch [list xsafe eval gets $f] msg] $msg]
    xsafe eval close $f
    close $f
    string compare [string tolower $x] \
		[list 1 [format "channel \"%s\" wasn't opened for reading" $f]]
} 0
catch {removeFile file-15.6}
catch {removeFile file-15.7}
test interp-15.7 {testing file transferring} {
    catch {interp delete xsafe}
    interp create xsafe -safe
    set f [open file-15.7 w]
    interp transfer "" $f xsafe
    xsafe eval puts $f hello
    xsafe eval close $f
} ""
catch {removeFile file-15.7}
catch {removeFile file-15.8}
test interp-15.8 {testing file transferring} {
    catch {interp delete xsafe}
    interp create xsafe -safe
    set f [open file-15.8 w]
    interp transfer "" $f xsafe
    xsafe eval close $f
    set x [list [catch {close $f} msg] $msg]
    string compare [string tolower $x] \
		[list 1 [format "can not find channel named \"%s\"" $f]]
} 0
catch {removeFile file-15.8}

#
# Torture tests for interpreter deletion order
#
proc kill {} {interp delete xxx}

test interp-15.9 {testing deletion order} {
    catch {interp delete xxx}
    interp create xxx
    xxx alias kill kill
    list [catch {xxx eval kill} msg] $msg
} {0 {}}
test interp-16.1 {testing deletion order} {
    catch {interp delete xxx}
    interp create xxx
    interp create {xxx yyy}
    interp alias {xxx yyy} kill "" kill
    list [catch {interp eval {xxx yyy} kill} msg] $msg
} {0 {}}
test interp-16.2 {testing deletion order} {
    catch {interp delete xxx}
    interp create xxx
    interp create {xxx yyy}
    interp alias {xxx yyy} kill "" kill
    list [catch {xxx eval yyy eval kill} msg] $msg
} {0 {}}
test interp-16.3 {testing deletion order} {
    catch {interp delete xxx}
    interp create xxx
    interp create ddd
    xxx alias kill kill
    interp alias ddd kill xxx kill
    set x [ddd eval kill]
    interp delete ddd
    set x
} ""
test interp-16.4 {testing deletion order} {
    catch {interp delete xxx}
    interp create xxx
    interp create {xxx yyy}
    interp alias {xxx yyy} kill "" kill
    interp create ddd
    interp alias ddd kill {xxx yyy} kill
    set x [ddd eval kill]
    interp delete ddd
    set x
} ""
test interp-16.5 {testing deletion order, bgerror} {
    catch {interp delete xxx}
    interp create xxx
    xxx eval {proc bgerror {args} {exit}}
    xxx alias exit kill xxx
    proc kill {i} {interp delete $i}
    xxx eval after 100 expr a + b
    after 200
    update
    interp exists xxx
} 0

#
# Alias loop prevention testing.
#

test interp-17.1 {alias loop prevention} {
    list [catch {interp alias {} a {} a} msg] $msg
} {1 {cannot define or rename alias "a": would create a loop}}
test interp-17.2 {alias loop prevention} {
    catch {interp delete x}
    interp create x
    x alias a loop
    list [catch {interp alias {} loop x a} msg] $msg
} {1 {cannot define or rename alias "loop": would create a loop}}
test interp-17.3 {alias loop prevention} {
    catch {interp delete x}
    interp create x
    interp alias x a x b
    list [catch {interp alias x b x a} msg] $msg
} {1 {cannot define or rename alias "b": would create a loop}}
test interp-17.4 {alias loop prevention} {
    catch {interp delete x}
    interp create x
    interp alias x b x a
    list [catch {x eval rename b a} msg] $msg
} {1 {cannot define or rename alias "b": would create a loop}}
test interp-17.5 {alias loop prevention} {
    catch {interp delete x}
    interp create x
    x alias z l1
    interp alias {} l2 x z
    list [catch {rename l2 l1} msg] $msg
} {1 {cannot define or rename alias "l2": would create a loop}}

#
# Test robustness of Tcl_DeleteInterp when applied to a slave interpreter.
# If there are bugs in the implementation these tests are likely to expose
# the bugs as a core dump.
#

if {[info commands testinterpdelete] != ""} {
    test interp-18.1 {testing Tcl_DeleteInterp vs slaves} {
	list [catch {testinterpdelete} msg] $msg
    } {1 {wrong # args: should be "testinterpdelete path"}}
    test interp-18.2 {testing Tcl_DeleteInterp vs slaves} {
	catch {interp delete a}
	interp create a
	testinterpdelete a
    } ""
    test interp-18.3 {testing Tcl_DeleteInterp vs slaves} {
	catch {interp delete a}
	interp create a
	interp create {a b}
	testinterpdelete {a b}
    } ""
    test interp-18.4 {testing Tcl_DeleteInterp vs slaves} {
	catch {interp delete a}
	interp create a
	interp create {a b}
	testinterpdelete a
    } ""
    test interp-18.5 {testing Tcl_DeleteInterp vs slaves} {
	catch {interp delete a}
	interp create a
	interp create {a b}
	interp alias {a b} dodel {} dodel
	proc dodel {x} {testinterpdelete $x}
	list [catch {interp eval {a b} {dodel {a b}}} msg] $msg
    } {0 {}}
    test interp-18.6 {testing Tcl_DeleteInterp vs slaves} {
	catch {interp delete a}
	interp create a
	interp create {a b}
	interp alias {a b} dodel {} dodel
	proc dodel {x} {testinterpdelete $x}
	list [catch {interp eval {a b} {dodel a}} msg] $msg
    } {0 {}}
    test interp-18.7 {eval in deleted interp} {
	catch {interp delete a}
	interp create a
	a eval {
	    proc dodel {} {
		delme
		dosomething else
	    }
	    proc dosomething args {
		puts "I should not have been called!!"
	    }
	}
	a alias delme dela
	proc dela {} {interp delete a}
	list [catch {a eval dodel} msg] $msg
    } {1 {attempt to call eval in deleted interpreter}}
    test interp-18.8 {eval in deleted interp} {
	catch {interp delete a}
	interp create a
	a eval {
	    interp create b
	    b eval {
		proc dodel {} {
		    dela
		}
	    }
	    proc foo {} {
		b eval dela
		dosomething else
	    }
	    proc dosomething args {
		puts "I should not have been called!!"
	    }
	}
	interp alias {a b} dela {} dela
	proc dela {} {interp delete a}
	list [catch {a eval foo} msg] $msg
    } {1 {attempt to call eval in deleted interpreter}}
}

# Test alias deletion

test interp-19.1 {alias deletion} {
    catch {interp delete a}
    interp create a
    interp alias a foo a bar
    set s [interp alias a foo {}]
    interp delete a
    set s
} {}
test interp-19.2 {alias deletion} {
    catch {interp delete a}
    interp create a
    catch {interp alias a foo {}} msg
    interp delete a
    set msg
} {alias "foo" not found}
test interp-19.3 {alias deletion} {
    catch {interp delete a}
    interp create a
    interp alias a foo a bar
    interp eval a {rename foo zop}
    interp alias a foo a zop
    catch {interp eval a foo} msg
    interp delete a
    set msg
} {invalid command name "zop"}
test interp-19.4 {alias deletion} {
    catch {interp delete a}
    interp create a
    interp alias a foo a bar
    interp eval a {rename foo zop}
    catch {interp eval a foo} msg
    interp delete a
    set msg
} {invalid command name "foo"}
test interp-19.5 {alias deletion} {
    catch {interp delete a}
    interp create a
    interp eval a {proc bar {} {return 1}}
    interp alias a foo a bar
    interp eval a {rename foo zop}
    catch {interp eval a zop} msg
    interp delete a
    set msg
} 1
test interp-19.6 {alias deletion} {
    catch {interp delete a}
    interp create a
    interp alias a foo a bar
    interp eval a {rename foo zop}
    interp alias a foo a zop
    set s [interp aliases a]
    interp delete a
    set s
} foo
test interp-19.7 {alias deletion, renaming} {
    catch {interp delete a}
    interp create a
    interp alias a foo a bar
    interp eval a rename foo blotz
    interp alias a foo {}
    set s [interp aliases a]
    interp delete a
    set s
} {}
test interp-19.8 {alias deletion, renaming} {
    catch {interp delete a}
    interp create a
    interp alias a foo a bar
    interp eval a rename foo blotz
    set l ""
    lappend l [interp aliases a]
    interp alias a foo {}
    lappend l [interp aliases a]
    interp delete a
    set l
} {foo {}}
test interp-19.9 {alias deletion, renaming} {
    catch {interp delete a}
    interp create a
    interp alias a foo a bar
    interp eval a rename foo blotz
    interp eval a {proc foo {} {expr 34 * 34}}
    interp alias a foo {}
    set l [interp eval a foo]
    interp delete a
    set l
} 1156    

test interp-20.1 {interp hide, interp expose and interp invokehidden} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    a eval {proc foo {} {}}
    a hide foo
    catch {a eval foo something} msg
    interp delete a
    set msg
} {invalid command name "foo"}
test interp-20.2 {interp hide, interp expose and interp invokehidden} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    a hide list
    set l ""
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    a expose list
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {invalid command name "list"} 0 {1 2 3}}
test interp-20.3 {interp hide, interp expose and interp invokehidden} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    a hide list
    set l ""
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    lappend l [catch {a invokehidden list 1 2 3} msg]
    lappend l $msg
    a expose list
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {invalid command name "list"} 0 {1 2 3} 0 {1 2 3}}
test interp-20.4 {interp hide, interp expose and interp invokehidden -- passing {}} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    a hide list
    set l ""
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    lappend l [catch {a invokehidden list {"" 1 2 3}} msg]
    lappend l $msg
    a expose list
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {invalid command name "list"} 0 {{"" 1 2 3}} 0 {1 2 3}}
test interp-20.5 {interp hide, interp expose and interp invokehidden -- passing {}} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    a hide list
    set l ""
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    lappend l [catch {a invokehidden list {{} 1 2 3}} msg]
    lappend l $msg
    a expose list
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {invalid command name "list"} 0 {{{} 1 2 3}} 0 {1 2 3}}
test interp-20.6 {interp invokehidden -- eval args} {
    catch {interp delete a}
    interp create a
    a hide list
    set l ""
    set z 45
    lappend l [catch {a invokehidden list $z 1 2 3} msg]
    lappend l $msg
    a expose list
    lappend l [catch {a eval list $z 1 2 3} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {45 1 2 3} 0 {45 1 2 3}}
test interp-20.7 {interp invokehidden vs variable eval} {
    catch {interp delete a}
    interp create a
    a hide list
    set z 45
    set l ""
    lappend l [catch {a invokehidden list {$z a b c}} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {{$z a b c}}}
test interp-20.8 {interp invokehidden vs variable eval} {
    catch {interp delete a}
    interp create a
    a hide list
    a eval set z 89
    set z 45
    set l ""
    lappend l [catch {a invokehidden list {$z a b c}} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {{$z a b c}}}
test interp-20.9 {interp invokehidden vs variable eval} {
    catch {interp delete a}
    interp create a
    a hide list
    a eval set z 89
    set z 45
    set l ""
    lappend l [catch {a invokehidden list $z {$z a b c}} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {45 {$z a b c}}}
test interp-20.10 {interp hide, interp expose and interp invokehidden} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    a eval {proc foo {} {}}
    interp hide a foo
    catch {interp eval a foo something} msg
    interp delete a
    set msg
} {invalid command name "foo"}
test interp-20.11 {interp hide, interp expose and interp invokehidden} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    interp hide a list
    set l ""
    lappend l [catch {interp eval a {list 1 2 3}} msg]
    lappend l $msg
    interp expose a list
    lappend l [catch {interp eval a {list 1 2 3}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {invalid command name "list"} 0 {1 2 3}}
test interp-20.12 {interp hide, interp expose and interp invokehidden} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    interp hide a list
    set l ""
    lappend l [catch {interp eval a {list 1 2 3}} msg]
    lappend l $msg
    lappend l [catch {interp invokehidden a list 1 2 3} msg]
    lappend l $msg
    interp expose a list
    lappend l [catch {interp eval a {list 1 2 3}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {invalid command name "list"} 0 {1 2 3} 0 {1 2 3}}
test interp-20.13 {interp hide, interp expose, interp invokehidden -- passing {}} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    interp hide a list
    set l ""
    lappend l [catch {interp eval a {list 1 2 3}} msg]
    lappend l $msg
    lappend l [catch {interp invokehidden a list {"" 1 2 3}} msg]
    lappend l $msg
    interp expose a list
    lappend l [catch {interp eval a {list 1 2 3}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {invalid command name "list"} 0 {{"" 1 2 3}} 0 {1 2 3}}
test interp-20.14 {interp hide, interp expose, interp invokehidden -- passing {}} {
    catch {interp delete a}
    interp create a
    a eval {proc unknown {x args} {error "invalid command name \"$x\""}}
    interp hide a list
    set l ""
    lappend l [catch {interp eval a {list 1 2 3}} msg]
    lappend l $msg
    lappend l [catch {interp invokehidden a list {{} 1 2 3}} msg]
    lappend l $msg
    interp expose a list
    lappend l [catch {a eval {list 1 2 3}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {invalid command name "list"} 0 {{{} 1 2 3}} 0 {1 2 3}}
test interp-20.15 {interp invokehidden -- eval args} {
    catch {interp delete a}
    interp create a
    interp hide a list
    set l ""
    set z 45
    lappend l [catch {interp invokehidden a list $z 1 2 3} msg]
    lappend l $msg
    a expose list
    lappend l [catch {interp eval a list $z 1 2 3} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {45 1 2 3} 0 {45 1 2 3}}
test interp-20.16 {interp invokehidden vs variable eval} {
    catch {interp delete a}
    interp create a
    interp hide a list
    set z 45
    set l ""
    lappend l [catch {interp invokehidden a list {$z a b c}} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {{$z a b c}}}
test interp-20.17 {interp invokehidden vs variable eval} {
    catch {interp delete a}
    interp create a
    interp hide a list
    a eval set z 89
    set z 45
    set l ""
    lappend l [catch {interp invokehidden a list {$z a b c}} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {{$z a b c}}}
test interp-20.18 {interp invokehidden vs variable eval} {
    catch {interp delete a}
    interp create a
    interp hide a list
    a eval set z 89
    set z 45
    set l ""
    lappend l [catch {interp invokehidden a list $z {$z a b c}} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {45 {$z a b c}}}
test interp-20.19 {interp invokehidden vs nested commands} {
    catch {interp delete a}
    interp create a
    a hide list
    set l [a invokehidden list {[list x y z] f g h} z]
    interp delete a
    set l
} {{[list x y z] f g h} z}
test interp-20.20 {interp invokehidden vs nested commands} {
    catch {interp delete a}
    interp create a
    a hide list
    set l [interp invokehidden a list {[list x y z] f g h} z]
    interp delete a
    set l
} {{[list x y z] f g h} z}
test interp-20.21 {interp hide vs safety} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [catch {a hide list} msg]    
    lappend l $msg
    interp delete a
    set l
} {0 {}}
test interp-20.22 {interp hide vs safety} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [catch {interp hide a list} msg]    
    lappend l $msg
    interp delete a
    set l
} {0 {}}
test interp-20.23 {interp hide vs safety} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [catch {a eval {interp hide {} list}} msg]    
    lappend l $msg
    interp delete a
    set l
} {1 {permission denied: safe interpreter cannot hide commands}}
test interp-20.24 {interp hide vs safety} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    set l ""
    lappend l [catch {a eval {interp hide b list}} msg]    
    lappend l $msg
    interp delete a
    set l
} {1 {permission denied: safe interpreter cannot hide commands}}
test interp-20.25 {interp hide vs safety} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    set l ""
    lappend l [catch {interp hide {a b} list} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {}}
test interp-20.26 {interp expoose vs safety} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [catch {a hide list} msg]    
    lappend l $msg
    lappend l [catch {a expose list} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {} 0 {}}
test interp-20.27 {interp expose vs safety} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [catch {interp hide a list} msg]    
    lappend l $msg
    lappend l [catch {interp expose a list} msg]    
    lappend l $msg
    interp delete a
    set l
} {0 {} 0 {}}
test interp-20.28 {interp expose vs safety} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [catch {a hide list} msg]    
    lappend l $msg
    lappend l [catch {a eval {interp expose {} list}} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {} 1 {permission denied: safe interpreter cannot expose commands}}
test interp-20.29 {interp expose vs safety} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [catch {interp hide a list} msg]    
    lappend l $msg
    lappend l [catch {a eval {interp expose {} list}} msg]    
    lappend l $msg
    interp delete a
    set l
} {0 {} 1 {permission denied: safe interpreter cannot expose commands}}
test interp-20.30 {interp expose vs safety} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    set l ""
    lappend l [catch {interp hide {a b} list} msg]    
    lappend l $msg
    lappend l [catch {a eval {interp expose b list}} msg]    
    lappend l $msg
    interp delete a
    set l
} {0 {} 1 {permission denied: safe interpreter cannot expose commands}}
test interp-20.31 {interp expose vs safety} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    set l ""
    lappend l [catch {interp hide {a b} list} msg]    
    lappend l $msg
    lappend l [catch {interp expose {a b} list} msg]
    lappend l $msg
    interp delete a
    set l
} {0 {} 0 {}}
test interp-20.32 {interp invokehidden vs safety} {
    catch {interp delete a}
    interp create a -safe
    interp hide a list
    set l ""
    lappend l [catch {a eval {interp invokehidden {} list a b c}} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {not allowed to invoke hidden commands from safe interpreter}}
test interp-20.33 {interp invokehidden vs safety} {
    catch {interp delete a}
    interp create a -safe
    interp hide a list
    set l ""
    lappend l [catch {a eval {interp invokehidden {} list a b c}} msg]
    lappend l $msg
    lappend l [catch {a invokehidden list a b c} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {not allowed to invoke hidden commands from safe interpreter}\
0 {a b c}}
test interp-20.34 {interp invokehidden vs safety} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    interp hide {a b} list
    set l ""
    lappend l [catch {a eval {interp invokehidden b list a b c}} msg]
    lappend l $msg
    lappend l [catch {interp invokehidden {a b} list a b c} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {not allowed to invoke hidden commands from safe interpreter}\
0 {a b c}}
test interp-20.35 {invokehidden at local level} {
    catch {interp delete a}
    interp create a
    a eval {
	proc p1 {} {
	    set z 90
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a h1
    }
    set r [interp eval a p1]
    interp delete a
    set r
} 91
test interp-20.36 {invokehidden at local level} {
    catch {interp delete a}
    interp create a
    a eval {
	set z 90
	proc p1 {} {
	    global z
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a h1
    }
    set r [interp eval a p1]
    interp delete a
    set r
} 91
test interp-20.37 {invokehidden at local level} {
    catch {interp delete a}
    interp create a
    a eval {
	proc p1 {} {
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a h1
    }
    set r [interp eval a p1]
    interp delete a
    set r
} 91
test interp-20.38 {invokehidden at global level} {
    catch {interp delete a}
    interp create a
    a eval {
	proc p1 {} {
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a -global h1
    }
    set r [catch {interp eval a p1} msg]
    interp delete a
    list $r $msg
} {1 {can't read "z": no such variable}}
test interp-20.39 {invokehidden at global level} {
    catch {interp delete a}
    interp create a
    a eval {
	proc p1 {} {
	    global z
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a -global h1
    }
    set r [catch {interp eval a p1} msg]
    interp delete a
    list $r $msg
} {0 91}
test interp-20.40 {safe, invokehidden at local level} {
    catch {interp delete a}
    interp create a -safe
    a eval {
	proc p1 {} {
	    set z 90
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a h1
    }
    set r [interp eval a p1]
    interp delete a
    set r
} 91
test interp-20.41 {safe, invokehidden at local level} {
    catch {interp delete a}
    interp create a -safe
    a eval {
	set z 90
	proc p1 {} {
	    global z
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a h1
    }
    set r [interp eval a p1]
    interp delete a
    set r
} 91
test interp-20.42 {safe, invokehidden at local level} {
    catch {interp delete a}
    interp create a -safe
    a eval {
	proc p1 {} {
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a h1
    }
    set r [interp eval a p1]
    interp delete a
    set r
} 91
test interp-20.43 {invokehidden at global level} {
    catch {interp delete a}
    interp create a
    a eval {
	proc p1 {} {
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a -global h1
    }
    set r [catch {interp eval a p1} msg]
    interp delete a
    list $r $msg
} {1 {can't read "z": no such variable}}
test interp-20.44 {invokehidden at global level} {
    catch {interp delete a}
    interp create a
    a eval {
	proc p1 {} {
	    global z
	    a1
	    set z
	}
	proc h1 {} {
	    upvar z z
	    set z 91
	}
    }
    a hide h1
    a alias a1 a1
    proc a1 {} {
	interp invokehidden a -global h1
    }
    set r [catch {interp eval a p1} msg]
    interp delete a
    list $r $msg
} {0 91}
test interp-20.45 {interp hide vs namespaces} {
    catch {interp delete a}
    interp create a
    a eval {
	namespace eval foo {}
	proc foo::x {} {}
    }
    set l [list [catch {interp hide a foo::x} msg] $msg]
    interp delete a
    set l
} {1 {cannot use namespace qualifiers in hidden command token (rename)}}
test interp-20.46 {interp hide vs namespaces} {
    catch {interp delete a}
    interp create a
    a eval {
	namespace eval foo {}
	proc foo::x {} {}
    }
    set l [list [catch {interp hide a foo::x x} msg] $msg]
    interp delete a
    set l
} {1 {can only hide global namespace commands (use rename then hide)}}
test interp-20.47 {interp hide vs namespaces} {
    catch {interp delete a}
    interp create a
    a eval {
	proc x {} {}
    }
    set l [list [catch {interp hide a x foo::x} msg] $msg]
    interp delete a
    set l
} {1 {cannot use namespace qualifiers in hidden command token (rename)}}
test interp-20.48 {interp hide vs namespaces} {
    catch {interp delete a}
    interp create a
    a eval {
	namespace eval foo {}
	proc foo::x {} {}
    }
    set l [list [catch {interp hide a foo::x bar::x} msg] $msg]
    interp delete a
    set l
} {1 {cannot use namespace qualifiers in hidden command token (rename)}}

test interp-21.1 {interp hidden} {
    interp hidden {}
} ""
test interp-21.2 {interp hidden} {
    interp hidden
} ""
test interp-21.3 {interp hidden vs interp hide, interp expose} {
    set l ""
    lappend l [interp hidden]
    interp hide {} pwd
    lappend l [interp hidden]
    interp expose {} pwd
    lappend l [interp hidden]
    set l
} {{} pwd {}}
test interp-21.4 {interp hidden} {
    catch {interp delete a}
    interp create a
    set l [interp hidden a]
    interp delete a
    set l
} ""
test interp-21.5 {interp hidden} {
    catch {interp delete a}
    interp create -safe a
    set l [lsort [interp hidden a]]
    interp delete a
    set l
} $hidden_cmds 
test interp-21.6 {interp hidden vs interp hide, interp expose} {
    catch {interp delete a}
    interp create a
    set l ""
    lappend l [interp hidden a]
    interp hide a pwd
    lappend l [interp hidden a]
    interp expose a pwd
    lappend l [interp hidden a]
    interp delete a
    set l
} {{} pwd {}}
test interp-21.7 {interp hidden} {
    catch {interp delete a}
    interp create a
    set l [a hidden]
    interp delete a
    set l
} ""
test interp-21.8 {interp hidden} {
    catch {interp delete a}
    interp create a -safe
    set l [lsort [a hidden]]
    interp delete a
    set l
} $hidden_cmds
test interp-21.9 {interp hidden vs interp hide, interp expose} {
    catch {interp delete a}
    interp create a
    set l ""
    lappend l [a hidden]
    a hide pwd
    lappend l [a hidden]
    a expose pwd
    lappend l [a hidden]
    interp delete a
    set l
} {{} pwd {}}

test interp-22.1 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a
    set l ""
    lappend l [a issafe]
    lappend l [a marktrusted]
    lappend l [a issafe]
    interp delete a
    set l
} {0 {} 0}
test interp-22.2 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a
    set l ""
    lappend l [interp issafe a]
    lappend l [interp marktrusted a]
    lappend l [interp issafe a]
    interp delete a
    set l
} {0 {} 0}
test interp-22.3 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [a issafe]
    lappend l [a marktrusted]
    lappend l [a issafe]
    interp delete a
    set l
} {1 {} 0}
test interp-22.4 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [interp issafe a]
    lappend l [interp marktrusted a]
    lappend l [interp issafe a]
    interp delete a
    set l
} {1 {} 0}
test interp-22.5 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    catch {a eval {interp marktrusted b}} msg
    interp delete a
    set msg
} {permission denied: safe interpreter cannot mark trusted}
test interp-22.6 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    catch {a eval {b marktrusted}} msg
    interp delete a
    set msg
} {permission denied: safe interpreter cannot mark trusted}
test interp-22.7 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [interp issafe a]
    interp marktrusted a
    interp create {a b}
    lappend l [interp issafe a]
    lappend l [interp issafe {a b}]
    interp delete a
    set l
} {1 0 0}
test interp-22.8 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [interp issafe a]
    interp create {a b}
    lappend l [interp issafe {a b}]
    interp marktrusted a
    interp create {a c}
    lappend l [interp issafe a]
    lappend l [interp issafe {a c}]
    interp delete a
    set l
} {1 1 0 0}
test interp-22.9 {testing interp marktrusted} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [interp issafe a]
    interp create {a b}
    lappend l [interp issafe {a b}]
    interp marktrusted {a b}
    lappend l [interp issafe a]
    lappend l [interp issafe {a b}]
    interp create {a b c}
    lappend l [interp issafe {a b c}]
    interp delete a
    set l
} {1 1 1 0 0}

test interp-23.1 {testing hiding vs aliases} {
    catch {interp delete a}
    interp create a
    set l ""
    lappend l [interp hidden a]
    a alias bar bar
    lappend l [interp aliases a]
    lappend l [interp hidden a]
    a hide bar
    lappend l [interp aliases a]
    lappend l [interp hidden a]
    a alias bar {}
    lappend l [interp aliases a]
    lappend l [interp hidden a]
    interp delete a
    set l
} {{} bar {} bar bar {} {}}
test interp-23.2 {testing hiding vs aliases} {pc || unix} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [lsort [interp hidden a]]
    a alias bar bar
    lappend l [interp aliases a]
    lappend l [lsort [interp hidden a]]
    a hide bar
    lappend l [interp aliases a]
    lappend l [lsort [interp hidden a]]
    a alias bar {}
    lappend l [interp aliases a]
    lappend l [lsort [interp hidden a]]
    interp delete a
    set l
} {{cd encoding exec exit fconfigure file glob load open pwd socket source} bar {cd encoding exec exit fconfigure file glob load open pwd socket source} bar {bar cd encoding exec exit fconfigure file glob load open pwd socket source} {} {cd encoding exec exit fconfigure file glob load open pwd socket source}} 

test interp-23.3 {testing hiding vs aliases} {macOnly} {
    catch {interp delete a}
    interp create a -safe
    set l ""
    lappend l [lsort [interp hidden a]]
    a alias bar bar
    lappend l [interp aliases a]
    lappend l [lsort [interp hidden a]]
    a hide bar
    lappend l [interp aliases a]
    lappend l [lsort [interp hidden a]]
    a alias bar {}
    lappend l [interp aliases a]
    lappend l [lsort [interp hidden a]]
    interp delete a
    set l
} {{beep cd echo encoding exit fconfigure file glob load ls open pwd socket source} bar {beep cd echo encoding exit fconfigure file glob load ls open pwd socket source} bar {bar beep cd echo encoding exit fconfigure file glob load ls open pwd socket source} {} {beep cd echo encoding exit fconfigure file glob load ls open pwd socket source}} 

test interp-24.1 {result resetting on error} {
    catch {interp delete a}
    interp create a
    proc foo args {error $args}
    interp alias a foo {} foo
    set l [interp eval a {
	set l {}
	lappend l [catch {foo 1 2 3} msg]
	lappend l $msg
	lappend l [catch {foo 3 4 5} msg]
	lappend l $msg
	set l
    }]
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.2 {result resetting on error} {
    catch {interp delete a}
    interp create a -safe
    proc foo args {error $args}
    interp alias a foo {} foo
    set l [interp eval a {
	set l {}
	lappend l [catch {foo 1 2 3} msg]
	lappend l $msg
	lappend l [catch {foo 3 4 5} msg]
	lappend l $msg
	set l
    }]
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.3 {result resetting on error} {
    catch {interp delete a}
    interp create a
    interp create {a b}
    interp eval a {
	proc foo args {error $args}
    }
    interp alias {a b} foo a foo
    set l [interp eval {a b} {
	set l {}
	lappend l [catch {foo 1 2 3} msg]
	lappend l $msg
	lappend l [catch {foo 3 4 5} msg]
	lappend l $msg
	set l
    }]
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.4 {result resetting on error} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    interp eval a {
	proc foo args {error $args}
    }
    interp alias {a b} foo a foo
    set l [interp eval {a b} {
	set l {}
	lappend l [catch {foo 1 2 3} msg]
	lappend l $msg
	lappend l [catch {foo 3 4 5} msg]
	lappend l $msg
	set l
    }]
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.5 {result resetting on error} {
    catch {interp delete a}
    catch {interp delete b}
    interp create a
    interp create b
    interp eval a {
	proc foo args {error $args}
    }
    interp alias b foo a foo
    set l [interp eval b {
	set l {}
	lappend l [catch {foo 1 2 3} msg]
	lappend l $msg
	lappend l [catch {foo 3 4 5} msg]
	lappend l $msg
	set l
    }]
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.6 {result resetting on error} {
    catch {interp delete a}
    catch {interp delete b}
    interp create a -safe
    interp create b -safe
    interp eval a {
	proc foo args {error $args}
    }
    interp alias b foo a foo
    set l [interp eval b {
	set l {}
	lappend l [catch {foo 1 2 3} msg]
	lappend l $msg
	lappend l [catch {foo 3 4 5} msg]
	lappend l $msg
	set l
    }]
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.7 {result resetting on error} {
    catch {interp delete a}
    interp create a
    interp eval a {
	proc foo args {error $args}
    }
    set l {}
    lappend l [catch {interp eval a foo 1 2 3} msg]
    lappend l $msg
    lappend l [catch {interp eval a foo 3 4 5} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.8 {result resetting on error} {
    catch {interp delete a}
    interp create a -safe
    interp eval a {
	proc foo args {error $args}
    }
    set l {}
    lappend l [catch {interp eval a foo 1 2 3} msg]
    lappend l $msg
    lappend l [catch {interp eval a foo 3 4 5} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.9 {result resetting on error} {
    catch {interp delete a}
    interp create a
    interp create {a b}
    interp eval {a b} {
	proc foo args {error $args}
    }
    interp eval a {
	proc foo args {
	    eval interp eval b foo $args
	}
    }
    set l {}
    lappend l [catch {interp eval a foo 1 2 3} msg]
    lappend l $msg
    lappend l [catch {interp eval a foo 3 4 5} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.10 {result resetting on error} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    interp eval {a b} {
	proc foo args {error $args}
    }
    interp eval a {
	proc foo args {
	    eval interp eval b foo $args
	}
    }
    set l {}
    lappend l [catch {interp eval a foo 1 2 3} msg]
    lappend l $msg
    lappend l [catch {interp eval a foo 3 4 5} msg]
    lappend l $msg
    interp delete a
    set l
} {1 {1 2 3} 1 {3 4 5}}
test interp-24.11 {result resetting on error} {
    catch {interp delete a}
    interp create a
    interp create {a b}
    interp eval {a b} {
	proc foo args {error $args}
    }
    interp eval a {
	proc foo args {
	    set l {}
	    lappend l [catch {eval interp eval b foo $args} msg]
	    lappend l $msg
	    lappend l [catch {eval interp eval b foo $args} msg]
	    lappend l $msg
	    set l
	}
    }
    set l [interp eval a foo 1 2 3]
    interp delete a
    set l
} {1 {1 2 3} 1 {1 2 3}}
test interp-24.12 {result resetting on error} {
    catch {interp delete a}
    interp create a -safe
    interp create {a b}
    interp eval {a b} {
	proc foo args {error $args}
    }
    interp eval a {
	proc foo args {
	    set l {}
	    lappend l [catch {eval interp eval b foo $args} msg]
	    lappend l $msg
	    lappend l [catch {eval interp eval b foo $args} msg]
	    lappend l $msg
	    set l
	}
    }
    set l [interp eval a foo 1 2 3]
    interp delete a
    set l
} {1 {1 2 3} 1 {1 2 3}}

unset hidden_cmds

test interp-25.1 {testing aliasing of string commands} {
    catch {interp delete a}
    interp create a
    a alias exec foo		;# Relies on exec being a string command!
    interp delete a
} ""


# Interps result transmission
test interp-26.1 {result code transmission 1} {knownBug} {
    # This test currently fails ! (only ok/error are passed, not the other
    # codes). Fixing the code is thus needed...  -- dl
    # (the only other acceptable result list would be
    #  {-1 0 1 0 3 4 5} because of the way return -code return(=2) works)
    # test that all the possibles error codes from Tcl get passed
    catch {interp delete a}
    interp create a
    interp eval a {proc ret {code} {return -code $code $code}}
    set res {}
    # use a for so if a return -code break 'escapes' we would notice
    for {set code -1} {$code<=5} {incr code} {
	lappend res [catch {interp eval a ret $code} msg]
    }
    interp delete a
    set res
} {-1 0 1 2 3 4 5}

test interp-26.2 {result code transmission 2} {knownBug} {
    # This test currently fails ! (error is cleared)
    # Code fixing is needed...  -- dl
    # (the only other acceptable result list would be
    #  {-1 0 1 0 3 4 5} because of the way return -code return(=2) works)
    # test that all the possibles error codes from Tcl get passed
    set interp [interp create];
    proc MyTestAlias {interp args} {
	global aliasTrace;
	lappend aliasTrace $args;
	eval interp invokehidden [list $interp] $args
    }
    foreach c {return} {
	interp hide $interp  $c;
        interp alias $interp $c {} MyTestAlias $interp $c;
    }
    interp eval $interp {proc ret {code} {return -code $code $code}}
    set res {}
    set aliasTrace {}
    for {set code -1} {$code<=5} {incr code} {
	lappend res [catch {interp eval $interp ret $code} msg]
    }
    interp delete $interp;
    list $res
} {-1 0 1 2 3 4 5}

test interp-26.3 {errorInfo transmission : regular interps} {
    set interp [interp create];
    proc MyError {secret} {
	return -code error "msg"
    }
    proc MyTestAlias {interp args} {
	MyError "some secret"
    }
    interp alias $interp test {} MyTestAlias $interp;
    set res [interp eval $interp {catch test;set errorInfo}]
    interp delete $interp;
    set res
} {msg
    while executing
"MyError "some secret""
    (procedure "MyTestAlias" line 2)
    invoked from within
"test"}

test interp-26.4 {errorInfo transmission : safe interps} {knownBug} {
    # this test fails because the errorInfo is fully transmitted
    # whether the interp is safe or not. this is maybe a feature
    # and not a bug.
    set interp [interp create -safe];
    proc MyError {secret} {
	return -code error "msg"
    }
    proc MyTestAlias {interp args} {
	MyError "some secret"
    }
    interp alias $interp test {} MyTestAlias $interp;
    set res [interp eval $interp {catch test;set errorInfo}]
    interp delete $interp;
    set res
} {msg
    while executing
"catch test"}

# Interps & Namespaces
test interp-27.1 {interp aliases & namespaces} {
    set i [interp create];
    set aliasTrace {};
    proc tstAlias {args} { 
	global aliasTrace;
	lappend aliasTrace [list [namespace current] $args];
    }
    $i alias foo::bar tstAlias foo::bar;
    $i eval foo::bar test
    interp delete $i
    set aliasTrace;
} {{:: {foo::bar test}}}

test interp-27.2 {interp aliases & namespaces} {
    set i [interp create];
    set aliasTrace {};
    proc tstAlias {args} { 
	global aliasTrace;
	lappend aliasTrace [list [namespace current] $args];
    }
    $i alias foo::bar tstAlias foo::bar;
    $i eval namespace eval foo {bar test}
    interp delete $i
    set aliasTrace;
} {{:: {foo::bar test}}}

test interp-27.3 {interp aliases & namespaces} {
    set i [interp create];
    set aliasTrace {};
    proc tstAlias {args} { 
	global aliasTrace;
	lappend aliasTrace [list [namespace current] $args];
    }
    interp eval $i {namespace eval foo {proc bar {} {error "bar called"}}}
    interp alias $i foo::bar {} tstAlias foo::bar;
    interp eval $i {namespace eval foo {bar test}}
    interp delete $i
    set aliasTrace;
} {{:: {foo::bar test}}}

test interp-27.4 {interp aliases & namespaces} {
    set i [interp create];
    namespace eval foo2 {
	variable aliasTrace {};
	proc bar {args} { 
	    variable aliasTrace;
	    lappend aliasTrace [list [namespace current] $args];
	}
    }
    $i alias foo::bar foo2::bar foo::bar;
    $i eval namespace eval foo {bar test}
    set r $foo2::aliasTrace;
    namespace delete foo2;
    set r
} {{::foo2 {foo::bar test}}}

# the following tests are commented out while we don't support
# hiding in namespaces

# test interp-27.5 {interp hidden & namespaces} {
#    set i [interp create];
#    interp eval $i {
#	namespace eval foo {
#	    proc bar {args} {
#		return "bar called ([namespace current]) ($args)"
#	    }
#	}
#    }
#    set res [list [interp eval $i {namespace eval foo {bar test1}}]]
#    interp hide $i foo::bar;
#    lappend res [list [catch {interp eval $i {namespace eval foo {bar test2}}} msg] $msg]
#    interp delete $i;
#    set res;
#} {{bar called (::foo) (test1)} {1 {invalid command name "bar"}}}

# test interp-27.6 {interp hidden & aliases & namespaces} {
#     set i [interp create];
#     set v root-master;
#     namespace eval foo {
# 	variable v foo-master;
# 	proc bar {interp args} {
# 	    variable v;
# 	    list "master bar called ($v) ([namespace current]) ($args)"\
# 		    [interp invokehidden $interp foo::bar $args];
# 	}
#     }
#     interp eval $i {
# 	namespace eval foo {
# 	    namespace export *
# 	    variable v foo-slave;
# 	    proc bar {args} {
# 		variable v;
# 		return "slave bar called ($v) ([namespace current]) ($args)"
# 	    }
# 	}
#     }
#     set res [list [interp eval $i {namespace eval foo {bar test1}}]]
#     $i hide foo::bar;
#     $i alias foo::bar foo::bar $i;
#     set res [concat $res [interp eval $i {
# 	set v root-slave;
# 	namespace eval test {
# 	    variable v foo-test;
# 	    namespace import ::foo::*;
# 	    bar test2
#         }
#     }]]
#     namespace delete foo;
#     interp delete $i;
#     set res
# } {{slave bar called (foo-slave) (::foo) (test1)} {master bar called (foo-master) (::foo) (test2)} {slave bar called (foo-slave) (::foo) (test2)}}


# test interp-27.7 {interp hidden & aliases & imports & namespaces} {
#     set i [interp create];
#     set v root-master;
#     namespace eval mfoo {
# 	variable v foo-master;
# 	proc bar {interp args} {
# 	    variable v;
# 	    list "master bar called ($v) ([namespace current]) ($args)"\
# 		    [interp invokehidden $interp test::bar $args];
# 	}
#     }
#     interp eval $i {
# 	namespace eval foo {
# 	    namespace export *
# 	    variable v foo-slave;
# 	    proc bar {args} {
# 		variable v;
# 		return "slave bar called ($v) ([info level 0]) ([uplevel namespace current]) ([namespace current]) ($args)"
# 	    }
# 	}
# 	set v root-slave;
# 	namespace eval test {
# 	    variable v foo-test;
# 	    namespace import ::foo::*;
#         }
#     }
#     set res [list [interp eval $i {namespace eval test {bar test1}}]]
#     $i hide test::bar;
#     $i alias test::bar mfoo::bar $i;
#     set res [concat $res [interp eval $i {test::bar test2}]];
#     namespace delete mfoo;
#     interp delete $i;
#     set res
# } {{slave bar called (foo-slave) (bar test1) (::test) (::foo) (test1)} {master bar called (foo-master) (::mfoo) (test2)} {slave bar called (foo-slave) (test::bar test2) (::) (::foo) (test2)}}

#test interp-27.8 {hiding, namespaces and integrity} {
#    namespace eval foo {
#	variable v 3;
#	proc bar {} {variable v; set v}
#	# next command would currently generate an unknown command "bar" error.
#	interp hide {} bar;
#    }
#    namespace delete foo;
#    list [catch {interp invokehidden {} foo} msg] $msg;
#} {1 {invalid hidden command name "foo"}}


test interp-28.1 {getting fooled by slave's namespace ?} {
    set i [interp create -safe];
    proc master {interp args} {interp hide $interp list}
    $i alias master master $i;
    set r [interp eval $i {
	namespace eval foo {
	    proc list {args} {
		return "dummy foo::list";
	    }
	    master;
	}
	info commands list
    }]
    interp delete $i;
    set r
} {}

# Tests of recursionlimit
# We need testsetrecursionlimit so we need Tcltest package
if {[catch {package require Tcltest} msg]} {
    puts "This application hasn't been compiled with Tcltest"
    puts "skipping remining interp tests that relies on it."
} else {
    # 
test interp-29.1 {recursion limit} {
    set i [interp create]
    load {} Tcltest $i
    set r [interp eval $i {
	testsetrecursionlimit 50
	proc p {} {incr ::i; p}
	set i 0
	catch p
	set i
    }]
   interp delete $i
   set r
} 49

test interp-29.2 {recursion limit inheritance} {
    set i [interp create]
    load {} Tcltest $i
    set ii [interp eval $i {
	testsetrecursionlimit 50
	interp create
    }]
    set r [interp eval [list $i $ii] {
	proc p {} {incr ::i; p}
	set i 0
	catch p
	set i
    }]
   interp delete $i
   set r
} 49

#    # Deep recursion (into interps when the regular one fails):
#    # still crashes...
#    proc p {} {
#	if {[catch p ret]} {
#	    catch {
#		set i [interp create]
#		interp eval $i [list proc p {} [info body p]]
#		interp eval $i p
#	    }
#	    interp delete $i
#	    return ok
#	}
#	return $ret
#    }
#    p

# more tests needed...

# Interp & stack
#test interp-29.1 {interp and stack (info level)} {
#} {}

}


foreach i [interp slaves] {
  interp delete $i
}
