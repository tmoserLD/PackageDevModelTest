public class Slack_Messaging {

    public static String sendSlackMessage(String destinationId, String timestampToThread, String viewName, Map<String, Object> viewParameters) {

        // Instantiate Custom Slack App
        Slack.App app = Slack.App.Toggle_for_SFDC.get();

        // User client did not work
        // Slack.UserClient userClient = app.getUserClientForTeam('T014SESUVJL', 'U0142RV4VR9');

        // Bot client to send as bot
        Slack.BotClient client = app.getBotClientForTeam(Slack_Workspace__c.getInstance().Workspace_Id__c);

        // Define View to send as message
        // Must have a root view of type 'message', not 'modal'
        Slack.ViewReference viewReference;
        switch on viewName {
            when 'approval_message' {
                viewReference = Slack.View.approval_message.get();
            }
        }

        // Set View Parameters - only high level method parameters -- ActionDispatcher classes will query relevant data from parameters
        for (String parameter : viewParameters.keySet()) {
            viewReference.setParameter(parameter, viewParameters.get(parameter));
        }

        // Build Message
        Slack.ChatPostMessageRequest req = new Slack.ChatPostMessageRequest.builder()
            // Channel or User Slack Id
            .channel(destinationId)
            // Existing timestamp of message to send this message in thread
            .threadTs(timestampToThread)
            // View to build
            .viewReference(viewReference)
            .build();

        // Send Message
        Slack.ChatPostMessageResponse response = client.ChatPostMessage(req);

        // Error
        if (response.getError() != null) {
            return 'Error: ' + response.getError();
        }
        // Return timestamp
        else {
            return response.getTs();
        }

    }
}