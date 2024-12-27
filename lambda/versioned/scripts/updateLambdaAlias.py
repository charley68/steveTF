import boto3
import os

def get_api_gateway_endpoints(api_name):
    client = boto3.client('apigateway', region_name=os.getenv('AWS_REGION'))

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
                arn = f"arn:aws:execute-api:{os.getenv('AWS_REGION')}:{boto3.client('sts').get_caller_identity()['Account']}:{api_id}/*/{method}{resource_path}"
                endpoints.append(arn)

    return endpoints

def update_or_create_alias_with_permissions(api_gateway_arn, alias_name="prod"):
    lambda_client = boto3.client('lambda', region_name=os.getenv('AWS_REGION'))

    # Derive the function name from the ARN (after the last '/')
    function_name = api_gateway_arn.split('/')[-1]

    # Publish the latest version of the Lambda function
    try:
        response = lambda_client.publish_version(FunctionName=function_name)
        latest_version = response['Version']
        print(f"Published version {latest_version} for function {function_name}.")

        # Check if the alias exists
        try:
            alias = lambda_client.get_alias(FunctionName=function_name, Name=alias_name)
            print(f"Alias '{alias_name}' exists for function {function_name}, updating to version {latest_version}.")

            # Update the alias to the latest version
            lambda_client.update_alias(
                FunctionName=function_name,
                Name=alias_name,
                FunctionVersion=latest_version
            )
        except lambda_client.exceptions.ResourceNotFoundException:
            print(f"Alias '{alias_name}' does not exist for function {function_name}, creating it.")

            # Create the alias pointing to the latest version
            lambda_client.create_alias(
                FunctionName=function_name,
                Name=alias_name,
                FunctionVersion=latest_version,
                Description=f"Alias {alias_name} pointing to version {latest_version}"
            )

        # Add permissions for API Gateway to invoke the alias
        statement_id = "AllowExecutionFromAPIGateway"
        try:
            lambda_client.get_policy(FunctionName=f"{function_name}:{alias_name}")
            print(f"Policy already exists for alias '{alias_name}' on function {function_name}.")
        except lambda_client.exceptions.ResourceNotFoundException:
            print(f"Adding invoke permissions to alias '{alias_name}' for function {function_name}.")
            lambda_client.add_permission(
                FunctionName=f"{function_name}:{alias_name}",
                StatementId=statement_id,
                Action="lambda:InvokeFunction",
                Principal="apigateway.amazonaws.com",
                SourceArn=api_gateway_arn
            )
            print(f"Added invoke permissions to alias '{alias_name}' for function {function_name}.")

    except Exception as e:
        print(f"Failed to process function {function_name}: {e}")

if __name__ == "__main__":
    api_name = "steveAPI"  # Set API Gateway name to "hello-world-api"

    # Get the list of API Gateway endpoints
    endpoints = get_api_gateway_endpoints(api_name)

    if endpoints:
        print(f"Endpoints for API Gateway '{api_name}':")
        for endpoint in endpoints:
            print(f"Processing ARN: {endpoint}")
            update_or_create_alias_with_permissions(endpoint)
    else:
        print(f"No endpoints found for API Gateway '{api_name}'.")
