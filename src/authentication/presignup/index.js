exports.handler = async (event, context, callback) => {
    console.log("PRE_SIGNUP_EVENT", event);
    event.response.autoConfirmUser = true;

    callback(null, event);
};
