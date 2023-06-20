# Delayed Events with EventBridge Scheduler

## Summary

This is a sample project with the intent to demonstrate how to delay Cloudwatch Events using EventBridge Scheduler. To demonstrate this capability, this sample project will be delaying an event to update a DynamoDB item to have the attribute `isExpire` as `true`. In additional to delaying this attribute change, this repo will also allow the ability to customize how to delay that event. These customizations include:
- How long to delay the event
- Option to include/exclude the weekend as an acceptable expiration time
- Establish a time zone to make these calculations. 

This sample repo is to serve as a starting point for how you can delay any event using EventBridge Scheduler, as well as a starting point for other personalized customizations one might want to include/exclude in setting up how to delay their event.

## Architecture Diagram

![Alt text](assets/Architecture-Diagram.png?raw=true "Architecture Diagram")

## Prerequisites needed for inital deployment

- Terraform must be installed
- AWS Credentials must be configured that has appropriate permissions to deploy Terraform applications.
- Set the region in `src/environments/eng/backend.tfvars` to the region of the AWS credentials you've authenticated with.

## Below are Terraform specific commands

- `terraform -chdir=src init -backend-config=environments/eng/backend.tfvars` Initialize your Terraform backend
- `terraform -chdir=src plan -var-file=environments/eng/variables.tfvars` See what changes you're bringing with this build
- `terraform -chdir=src apply -var-file=environments/eng/variables.tfvars` Deploy your changes to your AWS account
- `terraform -chdir=src destroy -var-file=environments/eng/variables.tfvars` Delete all of the built resources

## Testing

You can test out the infrastructure of delaying an event by adding the follow item to the created DynamoDB table
```python
{
    "pk": "SamplePK",
    "sk": "SampleSK",
    "epoch_time_of_flag": "<CURRENT_TIME_IN_EPOCH>", # Example: "1686601441"
    "expiration_time_in_minutes": "<HOW_MANY_MINUTES_TO_DELAY>", # Example: "30"
    "expire_on_weekend": BOOLEAN # Example: false
    "time_zone": "<IANA_TIME_ZONE>", # Example: "America/New_York"
    "status": "REQUESTED"
}
```
Once created in DynamoDB, you should be able to see the EventBridge Schedule created in EventBridge AWS Console. When the `expiration_time_in_minutes` passes (in this example, 30 minutes), you should be able to see it successfully delayed the event of setting the `isExpired` attribute for that item to `true`.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

