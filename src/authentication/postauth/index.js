/*import { AWSLambda } from '@sentry/serverless';
import { PutEventsCommand } from '@aws-sdk/client-eventbridge';
import { ebClient } from './client';
import { v4 as uuidv4 } from 'uuid';*/

exports.handler = async (event, context, callback) => {
    console.log("POST_AUTH_EVENT", event);

    /*try {
        const params = {
            Entries: [
                {
                    Source: process.env.EVENT_SOURCE,
                    Detail: JSON.stringify({
                        uid: event.request.userAttributes['sub'],
                        wallet: event.request.clientMetadata['address'],
                    }),
                    DetailType: process.env.EVENT_DETAIL_TYPE,
                    Resources: [],
                    EventBusName: process.env.EVENT_BUS_NAME,
                    EventGroupId: event.request.clientMetadata['address'], // wallet address
                    EventDeduplicationId: uuidv4(),
                },
            ],
        };

        await ebClient.send(new PutEventsCommand(params));
    } catch (error) {
        console.error(error);
        throw error;
    }*/

    //return event;
    callback(null, event);
};
