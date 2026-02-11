import json
import boto3
import os
from datetime import datetime
from boto3.dynamodb.conditions import Key
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super(DecimalEncoder, self).default(obj)

dynamodb = boto3.resource('dynamodb')
tickets_table = dynamodb.Table(os.environ['TICKETS_TABLE'])

def lambda_handler(event, context):
    """
    Update a ticket's status, priority, category, or other fields
    """
    try:
        # Get ticket ID from path
        path_params = event.get('pathParameters', {}) or {}
        if 'ticket_id' not in path_params:
            return response(400, {'error': 'ticket_id is required'})
        
        ticket_id = path_params['ticket_id']
        
        # Parse update data
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        # Get existing ticket
        result = tickets_table.query(
            KeyConditionExpression=Key('ticket_id').eq(ticket_id),
            Limit=1
        )
        
        if not result['Items']:
            return response(404, {'error': 'Ticket not found'})
        
        existing_ticket = result['Items'][0]
        
        # Build update expression
        update_expr = "SET updated_at = :updated_at"
        expr_values = {':updated_at': datetime.utcnow().isoformat()}
        expr_names = {}
        
        # Allowed fields to update
        allowed_fields = ['status', 'priority', 'category', 'assigned_to', 'title', 'description']
        
        for field in allowed_fields:
            if field in body:
                # Handle reserved keywords (status is reserved)
                if field == 'status':
                    update_expr += ", #status = :status"
                    expr_names['#status'] = 'status'
                    expr_values[':status'] = body[field]
                else:
                    update_expr += f", {field} = :{field}"
                    expr_values[f':{field}'] = body[field]
        
        # Update the ticket
        response_data = tickets_table.update_item(
            Key={
                'ticket_id': ticket_id,
                'created_at': existing_ticket['created_at']
            },
            UpdateExpression=update_expr,
            ExpressionAttributeValues=expr_values,
            ExpressionAttributeNames=expr_names if expr_names else None,
            ReturnValues='ALL_NEW'
        )
        
        return response(200, {
            'message': 'Ticket updated successfully',
            'ticket': response_data['Attributes']
        })
        
    except Exception as e:
        print(f"Error updating ticket: {str(e)}")
        return response(500, {'error': 'Internal server error'})

def response(status_code, body):
    """Helper function to format API Gateway response"""
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization',
            'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
        },
        'body': json.dumps(body, cls=DecimalEncoder)
    }