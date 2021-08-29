#!/bin/sh
echo "Commiting to Github"
read -p 'Enter a commit message: ' commit_message
git add .
git commit -m "$commit_message"
git push
echo "Packaging using Maven"
mvn -Dmaven.test.skip=true package
echo "Deploying to BK1031 Server"
scp ./target/midna-1.0-SNAPSHOT-jar-with-dependencies.jar ./midna.jar
echo "Deployment complete"