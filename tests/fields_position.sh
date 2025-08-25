#!/bin/bash
# added 2025-05-06 by EDuquennoy
# This file is part of the liblognorm project, released under ASL 2.0
. $srcdir/exec.sh

test_def $0 "field position meta"

add_rule 'version=2'
add_rule 'rule=:%test:op-quoted-string%%rest:rest%'
execute 'abcd efgh' -oaddFieldsPosition
assert_output_json_eq '{ "rest": " efgh", "test": "abcd", "metadata": { "rule": { "fields_position": { "test": [ 0, 4 ], "rest": [ 4, 9 ] } } } }'

reset_rules

add_rule 'version=2'
add_rule 'rule=:%f:cef%'
execute 'CEF:0|Vendor|Product|Version|Signature ID|some name|Severity| aa=field1 bb=this is a value cc=field 3' -oaddFieldsPosition
assert_output_json_eq '{"f":{"DeviceVendor":"Vendor","DeviceProduct":"Product","DeviceVersion":"Version","SignatureID":"Signature ID","Name":"some name","Severity":"Severity","Extensions":{"aa":"field1","bb":"this is a value","cc":"field 3"}},"metadata":{"rule":{"fields_position":{"f":{"DeviceVendor":[6,12],"DeviceProduct":[13,20],"DeviceVersion":[21,28],"SignatureID":[29,41],"Name":[42,51],"Severity":[52,60],"Extensions":{"aa":[65,71],"bb":[75,90],"cc":[94,101],"__fieldposition":[61,101]},"__fieldposition":[0,101]}}}}}'

reset_rules

add_rule 'version=2'
add_rule 'rule=:%{"name":"iface", "type":"char-to", "extradata":":"}%:%{"name":"ip", "type":"ipv4"}%/%{"name":"port", "type":"number"}%%{"name":"tail", "type":"rest"}%'
execute 'Outside:10.20.30.40/35 (40.30.20.10/35 brace missing' -oaddFieldsPosition
assert_output_json_eq '{"tail":" (40.30.20.10/35 brace missing","port":"35","ip":"10.20.30.40","iface":"Outside","metadata":{"rule":{"fields_position":{"iface":[0,7],"ip":[8,19],"port":[20,22],"tail":[22,52]}}}}'

reset_rules

add_rule 'version=2'
add_rule 'rule=:A %ip_src:char-to: % Hello, %nested_test:rest%'
execute 'A 192.168.1.1 Hello, this is a test' -oaddFieldsPosition
assert_output_json_eq '{ "nested_test": "this is a test", "ip_src": "192.168.1.1", "metadata": { "rule": { "fields_position": { "ip_src": [ 2, 13 ], "nested_test": [ 21, 35 ] } } } }'

reset_rules

add_rule 'version=2'
add_rule 'rule=:header=%json_doc:json%%test:rest%'
execute 'header={"ok?": "bla", "nested_test": {"blabla": true}}....' -oaddFieldsPosition
assert_output_json_eq '{"test":"....","json_doc":{"ok?":"bla","nested_test":{"blabla":true}},"metadata":{"rule":{"fields_position":{"json_doc":[7,54],"test":[54,58]}}}}'

reset_rules

add_rule 'version=2'
add_rule 'rule=:%f:checkpoint-lea%'
execute 'tcp_flags: RST-ACK; src: 192.168.0.1;' -oaddFieldsPosition
assert_output_json_eq '{"f":{"tcp_flags":"RST-ACK","src":"192.168.0.1"},"metadata":{"rule":{"fields_position":{"tcp_flags":[11,18],"src":[25,36],"f":[0,37]}}}}'

reset_rules

cleanup_tmp_files


