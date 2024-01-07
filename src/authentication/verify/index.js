//import * as Sentry from '@sentry/serverless';
//import { ethers } from 'ethers';

// Verify that the signed request is valid.
exports.handler = async (event, context, callback) => {
        console.log('VERIFY_AUTH_EVENT', JSON.stringify(event, undefined, 2));

        /*if (event.request.challengeAnswer === 'WALLET_LOGIN') {
            const signature = event.request.clientMetadata.signature;
            const address = event.request.clientMetadata.address.toLowerCase();
            const userAddress = event.userName
                .replace('wallet_', '')
                .toLowerCase();

            if (signature == '' || address == '' || userAddress !== address) {
                event.response.answerCorrect = false;
            } else {
                try {
                    const signerAddress = ethers.utils.verifyMessage(
                        message,
                        ethers.utils.splitSignature(signature)
                    );
                    // answer is correct if signerAddress is the same as the user address
                    event.response.answerCorrect =
                        signerAddress.toLowerCase() === address;
                } catch (error) {
                    console.log(error);

                    // set sentry error capture
                    Sentry.captureException(error);

                    event.response.answerCorrect = false;
                }
            }
        } else {
            event.response.answerCorrect = false;
        }*/

        event.response.answerCorrect = false;

        console.log(event);

        callback(null, event);
};
