public class Slack_Shortcut_Modal_Dispatcher extends Slack.ShortcutDispatcher {
    public override Slack.ActionHandler invoke(Slack.ShortcutParameters parameters, Slack.RequestContext context) {

        Map<String, String> callbackViewMappings = new Map<String, String>{
            'sfdc-view-assigned-approvals' => 'approval_assigned_modal'
        };

        Map<String, Object> modalParameters = new Map<String, Object> {
            'viewName' => callbackViewMappings.get(parameters.getCallBackId())
        };

        return Slack.ActionHandler.updateModal(new Slack_Modal_Dispatcher.Handler(modalParameters, context));
    }
}
