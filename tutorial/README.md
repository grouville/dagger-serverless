# Dagger serverless tutorial

In this tutorial, you are going to build, set up and deploy your first serverless application.

It will be a simple [hello-app](./hello-app/source) with one API event.

## Requirement

You will need the **dagger binary** to deploy the application.

> [Install dagger](https://docs.dagger.io/1001/install/)

> :bulb: You should also check basic tutorials about [dagger](https://docs.dagger.io/) and [cue](https://cuetorials.com/) prior start.

## Setup

> :bulb: If you encounter any issues during the setup, please contact us on [dagger discord](https://discord.gg/ufnyBtc8uY) or [write an issue](https://github.com/grouville/dagger-serverless/issues).


**0.1** - Clone  [dagger serverless repository](https://github.com/grouville/dagger-serverless)

```bash
git clone git@github.com:grouville/dagger-serverless.git
```

**0.2** - Go the `tutorial` folder

```bash
cd tutorial
```

**0.3** - Init dagger project

```bash
dagger init
```

You can now verify that init is complete by tipping the following command: `ls -a1`.<br>
It should display the same list as below.

```bash
cue.mod     # Cue modules
.dagger     # Dagger environments
hello-app   # Hello application
README.md
```

**0.4** - Add dagger serverless package

```bash
dagger mod get github.com/grouville/dagger-serverless/serverless
```

> :bulb: `-p` option target the directory which will contains cue files.

:rocket: **You are now ready to deploy a serverless application with dagger** :rocket:

## Step 1 - Build

First, create a file named `serverless-app.cue` in `hello-app` directory.

```bash
touch hello-app/serverless-app.cue
```

We are going to write our deployment in this file.

What we need to build our project with dagger is simple :

- `repository` as input to get the source application
- `binary`: build project to get the lambda binary through `go.#Build` definition

```cue
// hello-app/serverless.cue
// Package name
package hello_app

import (
    "alpha.dagger.io/dagger" // Dagger utils definitions
    "alpha.dagger.io/go"     // Go package
)

// Source code folder or repository
repository: dagger.#Input & { dagger.#Artifact }

// Lambda binary
binary: go.#Build & {
    source: repository // Source code
    output: "/lambda"  // Binary name
}
```

Now you can add the source code as input.

To list available input, you can tip the following command :

```bash
dagger input list
Input            Value              Set by user  Description
repository       dagger.#Artifact   false        Source code folder or repository
binary.version   *"1.16" | string   false        Go version to use
binary.packages  *"." | string      false        Packages to build
binary.arch      *"amd64" | string  false        Target architecture
binary.os        *"linux" | string  false        Target OS
binary.tags      *"" | string       false        Build tags to use for building
binary.ldflags   *"" | string       false        LDFLAGS to use for linking
```

Let's add our code

```bash
dagger input dir repository hello-app/source
```

You can verify if the input is successfully set with the following command :

```bash
repository       dagger.#Artifact   true         Source code folder or repository
```

If you see `true`, it's perfect!

Now we can `up` the environment to be sure that binary is successfully built.

```bash
dagger up
```

You should get the following output :

```bash
dagger output list
Output         Value      Description
binary.output  "/lambda"  Specify the targeted binary name
```

## Step 2 - Upload

Now that we have built our binary, we can upload it to an s3 bucket through the `serverless.#Code` definition.

What we need is :

- `stackName`: Infrastructure root name for s3 bucket, registry, and cloud formation.
- `config`: AWS credentials
- `code`: remote source code and infrastructure supply

```cue
// hello-app/serverless.cue
// Package name
package hello_app

import (
    "alpha.dagger.io/dagger" // Dagger utils definitions
    "alpha.dagger.io/go"     // Go package
    "alpha.dagger.io/aws"    // AWS package

    "github.com/grouville/dagger-serverless/serverless" // Our serverless package
)

// Source code folder or repository
repository: dagger.#Input & {dagger.#Artifact}

// AWS configuration
config: aws.#Config & {
    region: "eu-west-3"
}

// Infrastructure name
stackName: dagger.#Input & {string}

// Lambda binary
binary: go.#Build & {
    source: repository // Source code
    output: "/lambda"  // Binary name
}

// Upload code and supply infrastructure
code: serverless.#Code & {
    name:        "hello-app-lambda" // Function name
    "config":    config             // AWS configuration
    "stackName": stackName          // Infrastructure supply name
    source:      binary             // Source code
    handler:     binary.output      // Handler name
}
```

Let's add missing input to run the environment

```bash
dagger input secret config.accessKey <AWS_ACCESS_KEY>
dagger input secret config.secretKey <AWS_SECRET_KEY>
dagger input text <YOUR_STACK_NAME>
```

It's time for an up

```bash
dagger up
```

You should have a list of output like below

```bash
dagger output list
Output                                           Value                                                                          Description
binary.output                                    "/lambda"                                                                      Specify the targeted binary name
code.source.output                               "/lambda"                                                                      Specify the targeted binary name
code.infra.cfn.outputs.BucketURI                 "hello-app-tom-example-bucket"                                                 -
code.infra.cfn.outputs.RegistryURI               "XXXXXXXXXXX.dkr.ecr.eu-west-3.amazonaws.com/hello-app-example-registry"       -
code.infra.registryUri                           "XXXXXXXXXXX.dkr.ecr.eu-west-3.amazonaws.com/hello-app-example-registry"       ECR Repository URI
code.infra.bucketUri                             "s3://hello-app-example-bucket"                                                S3 bucket URI
code.deployment.code.source.output               "/lambda"                                                                      Specify the targeted binary name
code.deployment.remoteCode.url                   "s3://hello-app-example-bucket"                                                URL of the uploaded S3 object
code.deployment.remoteCode.source.source.output  "/lambda"                                                                      Specify the targeted binary name
code.deployment.remoteCode.target                "s3://hello-app-example-bucket"                                                Target S3 URL (eg. s3://<bucket-name>/<path>/<sub-path>)
code.deployment.codeUri                          "s3://hello-app-example-bucket/hello-app-lambda.zip"                           -
```

> :bulb: If you check on your AWS account, you will see a new cloud formation stack that supplies an s3 bucket that contains your source code zip and an ECR if you want to upload zip as an image.

## Step 3 - Declaration

Now that your code is uploaded, we will need to define our lambda function thanks to `serverless.#Function`. It has two
goals :

- specify the function option, environment...
- add events to trigger that function.

We only want to execute the function on an HTTP call for this tutorial, but other events are defined in `serverless.#Events`.

> :rocket: Don't hesitate to contribute to that repository if you want to add an event for your needs.

So we are going to add :

- `helloLabmda`: the function definition with inlined events

```cue
// hello-app/serverless.cue
// Package name
package hello_app

import (
    "alpha.dagger.io/dagger" // Dagger utils definitions
    "alpha.dagger.io/go"     // Go package
    "alpha.dagger.io/aws"    // AWS package

    "github.com/grouville/dagger-serverless/serverless"        // Our serverless package
    "github.com/grouville/dagger-serverless/serverless/events" // Serverless events package
)

// Source code folder or repository
repository: dagger.#Input & {dagger.#Artifact}

// AWS configuration
config: aws.#Config & {
    region: "eu-west-3"
}

// Infrastructure name
stackName: dagger.#Input & {string}

// Lambda binary
binary: go.#Build & {
    source: repository // Source code
    output: "/lambda"  // Binary name
}

// Upload code and supply infrastructure
code: serverless.#Code & {
    name:        "hello-app-lambda" // Function name
    "config":    config             // AWS configuration
    "stackName": stackName          // Infrastructure supply name
    source:      binary             // Source code
    handler:     binary.output      // Handler name
}

// Lambda function definition
helloLambda: serverless.#Function & {
    "code": code                        // Code
    runtime: "go1.x"                    // Lambda language
    "events": {                         // Events list
        CatchAll: events.#Api & {       // HTTP event
            path: "/{proxy+}"           // Accept request from all path
        }
    }
}
```

You can now `dagger up` to see your new outputs.

> :bulb: There are many options available on `serverless.#Function`, don't hesitate to check all cue definitions from our repository to learn more.

## Step 4 - Deployment

Your lambda is built, uploaded, and configured! It's time to deploy it with `serverless.#Application`!

We will add :
- `application`: the lambda deployment

```cue
// hello-app/serverless-app.cue
// Package name
package hello_app

import (
    "alpha.dagger.io/dagger" // Dagger utils definitions
    "alpha.dagger.io/go"     // Go package
    "alpha.dagger.io/aws"    // AWS package

    "github.com/grouville/dagger-serverless/serverless"        // Our serverless package
    "github.com/grouville/dagger-serverless/serverless/events" // Serverless events package
)

// Source code folder or repository
repository: dagger.#Input & {dagger.#Artifact}

// AWS configuration
config: aws.#Config & {
    region: "eu-west-3"
}

// Infrastructure name
stackName: dagger.#Input & {string}

// Lambda binary
binary: go.#Build & {
    source: repository // Source code
    output: "/lambda"  // Binary name
}

// Upload code and supply infrastructure
code: serverless.#Code & {
    name:        "hello-app-lambda" // Function name
    "config":    config             // AWS configuration
    "stackName": stackName          // Infrastructure supply name
    source:      binary             // Source code
    handler:     binary.output      // Handler name
}

// Lambda function definition
helloLambda: serverless.#Function & {
    "code":  code                       // Code
    runtime: "go1.x"                    // Lambda language
    "events": {                         // Events list
        CatchAll: events.#Api & {       // HTTP event
            path: "/{proxy+}"           // Accept request from all path
        }
    }
}

application: serverless.#Application & {
    "config": config                    // AWS configuration
    description: """
        Hello application with one lambda
    """
    bucket: code.infra.bucketName       // Bucket to store deployment
    functions: {                        // Functions to deploy
        HelloLambda: helloLambda
    }
}
```

You can now `up` the environment :rocket:

As we said, the lambda can be trigger through an HTTP request!
Let's retrieve the endpoint from the output

```bash
dagger output list | grep "application.deployment.outputs.URL"
# application.deployment.outputs.URL                                                 "https://XXXXXXXXXX.execute-api.XX-XXXX-X.amazonaws.com/Prod/"                                           -
```

You can now send a request on the `/hello` endpoint to verify that everything is working

```bash
curl https://XXXXXXXXXXX.execute-api.XX-XXXX-X.amazonaws.com/Prod/hello
Hello from Dagger serverless
```

## To go further

Thank you for following this tutorial. If you want to go further, take a look at those links :
- [Dagger universe](https://docs.dagger.io/reference/universe/README)
- [Dagger other tutorials](https://docs.dagger.io/1003/get-started/)

> Dagger 2021