public class Slack_Event_Dispatcher extends Slack.EventDispatcher {
    public override Slack.ActionHandler invoke(Slack.EventParameters parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.ack(new Handler(parameters, context));
    }

    public class Handler implements Slack.RunnableHandler {
        Slack.EventParameters parameters;
        Slack.RequestContext context;

        public Handler(Slack.EventParameters parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public void run() {
            Slack.App app = Slack.App.Toggle_for_SFDC.get();
            Slack.BotClient botClient = app.getBotClientForTeam(this.context.getTeamId());
            Slack.Event event = this.parameters.getEvent();

            // Home Page Opened
            if (event instanceof Slack.AppHomeOpenedEvent) {

                // Define home page
                Slack.ViewReference viewReference = Slack.View.app_home.get();
                viewReference.setParameter('headerText', 'Welcome to the Toggle for SFDC App!');
                viewReference.setParameter('bodyText', 'To see how this custom home view was created, see the Slack_Event_Dispatcher apex class.');
                Slack.HomeView homeView = new Slack.HomeView.builder().viewReference(viewReference).build();
    
                // Build home page for user
                Slack.AppHomeOpenedEvent appHomeOpened = (Slack.AppHomeOpenedEvent) parameters.getEvent();
                String userId = appHomeOpened.getUser();
                Slack.ViewsPublishRequest req = new Slack.ViewsPublishRequest.builder().userId(userId).view(homeView).build();
    
                // Publish home page to user
                Slack.ViewsPublishResponse response = botClient.viewsPublish(req);
                if (response.getError() != null) {
                    System.debug(response.getResponseMetadata().getMessages());
                }
            }
        }
    }
}