const tuc = require('temp-units-conv');
let response;

const scales = {
    c: "celsius",
    f: "fahrenheit",
    k: "kelvin"
}

exports.lambdaHandler = async (event) => {
    let conversion = event.pathParameters.conversion
    let originalValue = event.pathParameters.value
    let answer = tuc[conversion](originalValue)
    try {
        response = {
            'statusCode': 200,
            'body': JSON.stringify({
                source: scales[conversion[0]],
                target: scales[conversion[2]],
                original: originalValue,
                answer: answer
            })
        }
    } catch (err) {
        console.log(err);
        return err;
    }

    return response
};