import boto3
region = 'ap-southeast-1'
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event,context):
    custom_filter = [
        {'Name':'tag:Resource', 
        'Values': ['stopoutofworking']
        }
        ]
    instances_to_start = []
    running_instances = ec2.describe_instances(Filters=custom_filter)
    for reservation in running_instances.get('Reservations'):
        for instance in reservation.get('Instances'):
            instances_to_start.append(instance.get('InstanceId'))
    print(f'Starting following instance Ids : {instances_to_start}')
    response = ec2.start_instances(InstanceIds=instances_to_start)
    print(response)