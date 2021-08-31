#!/bin/sh
echo "Packaging using Maven"
mvn -Dmaven.test.skip=true package
echo "Copying to Project Root"
scp ./target/link-1.0-SNAPSHOT-jar-with-dependencies.jar ./link.jar
echo "Deploying to PEL Server"
sshpass -p "{Qh5[L]aDrAJg{Bn" scp ./link.jar root@149.28.198.219:../home/portal/link.jar
sshpass -p "{Qh5[L]aDrAJg{Bn" ssh root@149.28.198.219 'pm2 restart link'"
echo "Deployment complete