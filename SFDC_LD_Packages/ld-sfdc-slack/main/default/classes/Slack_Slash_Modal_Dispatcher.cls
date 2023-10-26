public class Slack_Slash_Modal_Dispatcher extends Slack.SlashCommandDispatcher {
    public override Slack.ActionHandler invoke(Slack.SlashCommandParameters parameters, Slack.RequestContext context) {

        Map<String, String> commandViewMappings = new Map<String, String>{
            '/sfdc-view-assigned-approvals' => 'approval_assigned_modal'
        };

        Map<String, Object> modalParameters = new Map<String, Object> {
            'viewName' => commandViewMappings.get(parameters.getCommand())
        };

        return Slack.ActionHandler.updateModal(new Slack_Modal_Dispatcher.Handler(modalParameters, context));
    }
}
