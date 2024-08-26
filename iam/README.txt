
Here we create an IAM role that gies S3 read access to all buckets.  We create 2 ec2 instances, one with the attached polich and one without to prove we can access s3 with 

aws s3 list


(Note my deafult SG already has SSH/22 access to connect to test)
