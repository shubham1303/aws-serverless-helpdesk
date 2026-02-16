import json
import boto3
import os

cognito = boto3.client('cognito-idp')

def lambda_handler(event, context):
    """
    Cognito Post-Confirmation Trigger
    Automatically adds new users to 'customers' group after signup
    """
    try:
        user_pool_id = event['userPoolId']
        username = event['userName']
        
        print(f"Auto-assigning user {username} to customers group")
        
        # Add user to customers group
        cognito.admin_add_user_to_group(
            UserPoolId=user_pool_id,
            Username=username,
            GroupName='customers'
        )
        
        print(f"Successfully added {username} to customers group")
        
        # Must return the event for Cognito triggers
        return event
        
    except Exception as e:
        print(f"Error in post-signup trigger: {str(e)}")
        # Return event anyway to not block user signup
        return event