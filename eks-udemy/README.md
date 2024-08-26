https://github.com/devteds/demo-app-bookstore


source tfvars.env first



mysql/rds
terraform output
export DB_ADDRESS = $(terraform ouput -raw address)
mysql -uappuser -papppassword -h$DB_ADDRESS bookstore

To run this if you dont have mysql intalled with docker,  you can do:

docker run --rm -it mysql:5.7 mysql -uappuser -papppassword -h$DB_ADDRESS bookstore


INSTALL INGRESS:

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml



REMEMBER TO DESTORY INGRESS SEPERATELY AS THIS ISNT DONE WITH TF.


To Destroy:
source tfvars.env
terraform destroy rds
terraform destroy eks
terraform destroy vpc

kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml



