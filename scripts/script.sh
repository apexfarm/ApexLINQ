# force:package:create only execute for the first time
# sfdx force:package:create -n ApexLINQ -t Unlocked -r force-app
sfdx force:package:version:create -p ApexLINQ -x -c --wait 10 --code-coverage
sfdx force:package:version:list
sfdx force:package:version:promote -p 04tGC000007TPsvYAG
sfdx force:package:version:report -p 04tGC000007TPsvYAG