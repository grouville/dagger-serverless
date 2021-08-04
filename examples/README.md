# Dagger serverless examples

There are many examples to cover all uses cases from the simplistic one to a multi lambda deployment.

### [Stack](./stack)

Supply the necessary infrastructure to deploy serverless application.

**Goal** Understand `serverless.#Stack` definition and infrastructure.

### [Code](./code)

Upload a lambda binary to `s3 Bucket` and `ECR`.

**Goal** Understand ways to upload lambda.

### [Function](./function)

Create function manifest from code and events.

**Goal** 
 - Discover events
 - Create multiple functions with multiple events
 - Understand created manifest

### [Api](./api)

Configure AWS API Gateway from `serverless.#API` definition.

**Goal** Learn how configure serverless API.
 
### [Secret](./secret)

Create and deploy secrets to [aws secret manager](https://aws.amazon.com/secrets-manager/) thanks `serverless.#Secrets`.

**Goal** Understand how to use secrets with serverless function.

### [Application](./application)

Deploy a basic serverless application with multiple lambda triggered by API events.

**Goal** 
- Understand `serverless.#Application` basic usage
- Deploy multiple functions
- Setup global API configuration
- Setup API events


:rocket: To start creating your first dagger serverless deployment, you should follow our simple [tutorial](../tutorial/).