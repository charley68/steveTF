


This terraform setup will build a labda function and setup alias.  Run it twice with a modification to the hello-world.lambda the second time.
The idea here is that we have two version of Lamnda  (1 & 2).  We create two Alias  (staging and prod).  Staging will point to the latest version 
of the lambda whilst prod will typically point to the previous (or last deployed) version.

We then create two stages  (pre-prod and prod).   Both stages define an environment variable called  "lambdaAlias".  The pre-prod stage sets this variable
to staging and the prod stage sets this variable to "prod"

The APIGateway references this variable dynamically as $${stageVariables.lambdaAlias} which gets resolved at runtime

(note the $$ seems necessary for TF,  in AWS directly, we only need $)

Now you can run the following for stage "pre-prod" and stage "prod" and each should point to a different version of the lamnda.


curl https://azzz5lg7te.execute-api.eu-west-2.amazonaws.com/pre-prod/hello-world
curl https://azzz5lg7te.execute-api.eu-west-2.amazonaws.com/prod/hello-world 


