#!/bin/bash
# added 2021-02-17 by Kevin Guillemot
# This file is part of the liblognorm project, released under ASL 2.0
. $srcdir/exec.sh

test_def $0 "xml field"
add_rule 'version=2'
add_rule 'rule=:%start:word% %field1:xml%%half:char-sep:<%%field2:xml%%rest:rest%'
add_rule 'rule=:%start:word% %field:xml%%rest:rest%'
add_rule 'rule=:%field:xml%%rest:rest%'

# first, a real-world case
execute '<?xml version="1.0" encoding="UTF-8"?> <Tree1 xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="ns1" xsi:type="ns1:Tree1">  <Tree2 xsi:type="ns1:Tree2">   <name>TREE2</name>   <Tree4 xsi:type="ns1:Tree4">    <name>TREE4</name>   </Tree4>   <Tree5 xsi:type="ns1:Tree5">    <name>TREE5</name>   </Tree5>   <Tree6 xsi:type="ns1:Tree6">    <name>TREE6</name>   </Tree6>   <Tree7 xsi:type="ns1:Tree7">    <name>TREE7</name>   </Tree7>  </Tree2> </Tree1>'
assert_output_json_eq '{ "rest": "", "field": { "Tree1": { "Tree2": { "name": "TREE2", "Tree4": { "name": "TREE4" }, "Tree5": { "name": "TREE5" }, "Tree6": { "name": "TREE6" }, "Tree7": { "name": "TREE7" } } } } }'

execute 'START <?xml version="1.0" encoding="UTF-8"?> <Tree1 xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="ns1" xsi:type="ns1:Tree1">  <Tree2 xsi:type="ns1:Tree2">   <name>TREE2</name>   <Tree4 xsi:type="ns1:Tree4">    <name>TREE4</name>   </Tree4>   <Tree5 xsi:type="ns1:Tree5">    <name>TREE5</name>   </Tree5>   <Tree6 xsi:type="ns1:Tree6">    <name>TREE6</name>   </Tree6>   <Tree7 xsi:type="ns1:Tree7">    <name>TREE7</name>   </Tree7>  </Tree2> </Tree1>'
assert_output_json_eq '{ "rest": "", "field": { "Tree1": { "Tree2": { "name": "TREE2", "Tree4": { "name": "TREE4" }, "Tree5": { "name": "TREE5" }, "Tree6": { "name": "TREE6" }, "Tree7": { "name": "TREE7" } } } }, "start": "START" }'

execute 'START <?xml version="1.0" encoding="UTF-8"?> <Tree1 xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="ns1" xsi:type="ns1:Tree1">  <Tree2 xsi:type="ns1:Tree2">   <name>TREE2</name>   <Tree4 xsi:type="ns1:Tree4">    <name>TREE4</name>   </Tree4>   <Tree5 xsi:type="ns1:Tree5">    <name>TREE5</name>   </Tree5>   <Tree6 xsi:type="ns1:Tree6">    <name>TREE6</name>   </Tree6>   <Tree7 xsi:type="ns1:Tree7">    <name>TREE7</name>   </Tree7>  </Tree2> </Tree1><?xml version="1.0" encoding="UTF-8"?><Tree2><name>TREE2</name></Tree2>'
assert_output_json_eq '{ "rest": "", "field2": { "Tree2": { "name": "TREE2" } }, "half": "", "field1": { "Tree1": { "Tree2": { "name": "TREE2", "Tree4": { "name": "TREE4" }, "Tree5": { "name": "TREE5" }, "Tree6": { "name": "TREE6" }, "Tree7": { "name": "TREE7" } } } }, "start": "START" }'

#
#check cases where parsing failure must occur
#
echo verify failure cases

# Empty xml is invalid
execute '<?xml version="1.0" encoding="UTF-8"?>'
assert_output_json_eq '{ "originalmsg": "<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "unparsed-data": "version=\"1.0\" encoding=\"UTF-8\"?>" }'

# Truncated XML is invalid
execute '<?xml version="1.0" encoding="UTF-8"?><Tree1><name>TREE1</name>'
assert_output_json_eq '{ "originalmsg": "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Tree1><name>TREE1<\/name>", "unparsed-data": "version=\"1.0\" encoding=\"UTF-8\"?><Tree1><name>TREE1<\/name>" }'

# Missing xml header is invalid
execute '<Tree1><name>TREE1</name></Tree1>'
assert_output_json_eq '{ "originalmsg": "<Tree1><name>TREE1<\/name><\/Tree1>", "unparsed-data": "" }'

cleanup_tmp_files

