#!/bin/sh
echo "Commiting to Github"
read -p 'Enter a commit message: ' commit_message
git add .
git commit -m "$commit_message"
git push
echo "Packaging using Maven"
mvn -Dmaven.test.skip=true package
echo "Deploying to BK1031 Server"
scp ./target/link-1.0-SNAPSHOT.jar ./link.jar
echo "Deployment complete"