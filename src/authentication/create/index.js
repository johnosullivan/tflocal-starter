//import { AWSLambda } from '@sentry/serverless';

exports.handler = async (event, context, callback) => {
    console.log("CREATE_AUTH_EVENT", event);

    if (event.request.challengeName === 'CUSTOM_CHALLENGE') {
        event.response.publicChallengeParameters = {
            walletChallenge: true,
        };
    }

    callback(null, event);
};
