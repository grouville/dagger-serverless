# Dagger serverless examples

There are many examples to cover all use cases, from the simplistic one to a multi lambda deployment.

Here's list of command to explore examples

```bash
# List examples
dagger list

# See the deployment's input
dagger -e <selected deployment> input list

# Fill input
dagger -e <selected deployment> input <arg> <key> <value>

# Up example
dagger -e <selected deployment> up

# List output
dagger -e <selected deployment> output list
```

> :warning: You'll need to provide your AWS credentials to run examples.

### [Stack](./stack)

Supply the necessary infrastructure to deploy a serverless application.

**Goal** Understand `serverless.#Stack` definition and infrastructure.

### [Code](./code)

Upload a lambda binary to `s3 Bucket` and `ECR`.

**Goal** Understand ways to upload lambda.

### [Function](./function)

Create function manifest from code and events.

**Goals**

- Discover events
- Create multiple functions with multiple events
- Understand created manifest

### [Api](./api)

Configure AWS API Gateway from `serverless.#API` definition.

**Goal** Learn how to configure serverless API.

### [Secret](./secret)

Create and deploy secrets to [aws secret manager](https://aws.amazon.com/secrets-manager/) thanks `serverless.#Secrets`.

**Goal** Understand how to use secrets with serverless function.

### [InlineSecret](./inline-secret)

Directly code your lambda in your `cue` file thanks to `inlineCode` field. It's the best way to fastly deploy your lambda.

**Goal** Write inlined lambda

### [Layers](./layers)

Use layers with your lambda to manage dependencies and optimize your deployment.

> :bulb: You'll need to tip `npm i` in [dependencies](./layers/dependencies) folder before running `dagger up`.

**Goals**

- Deploy layers
- Link layers to lambdas
- Deploy a simple application

### [Application](./application)

Deploy a basic serverless application with multiple lambdas triggered by API events.

**Goals**

- Understand `serverless.#Application` primary usage
- Deploy multiple functions
- Setup global API configuration
- Setup API events

:rocket: To start creating your first dagger serverless deployment, you should follow our
simple [tutorial](../tutorial).