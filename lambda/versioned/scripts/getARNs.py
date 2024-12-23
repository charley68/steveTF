import boto3

def get_api_gateway_endpoints(api_name):
    client = boto3.client('apigateway', "eu-west-2")

    # Find the API Gateway by name
    apis = client.get_rest_apis()['items']
    api = next((api for api in apis if api['name'] == api_name), None)

    if not api:
        print(f"No API Gateway found with name '{api_name}'.")
        return []

    api_id = api['id']
    endpoints = []

    # Get resources for the API Gateway
    resources = client.get_resources(restApiId=api_id)['items']
    for resource in resources:
        resource_path = resource['path']
        if 'resourceMethods' in resource:
            for method in resource['resourceMethods']:
                arn = f"arn:aws:execute-api:{client.meta.region_name}:{boto3.client('sts', "eu-west-2").get_caller_identity()['Account']}:{api_id}/*/{method}{resource_path}"
                endpoints.append(arn)

    return endpoints

if __name__ == "__main__":
    api_name = "steve-api"
    endpoints = get_api_gateway_endpoints(api_name)

    if endpoints:
        print(f"Endpoints for API Gateway '{api_name}':")
        for endpoint in endpoints:
            print(endpoint)
    else:
        print(f"No endpoints found for API Gateway '{api_name}'.")

