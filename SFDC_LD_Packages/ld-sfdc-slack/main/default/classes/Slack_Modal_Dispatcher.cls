public class Slack_Modal_Dispatcher extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        return Slack.ActionHandler.updateModal(new Handler(parameters, context));
    }

    public class Handler implements Slack.ModalHandler {
        Map<String, Object> parameters;
        Slack.RequestContext context;

        public Handler(Map<String, Object> parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }

        public Slack.ModalView call() {
            
            Slack.ViewReference viewReference;
            String viewName = (this.parameters.containsKey('viewName') ? (String) this.parameters.get('viewName') : null);

            // Returns the modal view that corresponds to the requested object.
            switch on viewName {
                when 'approval_approve_reject_modal' {
                    viewReference = Slack.View.approval_approve_reject_modal.get();
                    viewReference.setParameter('approvalId', (this.parameters.containsKey('approvalId') ? (String) this.parameters.get('approvalId') : null));
                }
                when 'approval_view_more_modal' {
                    viewReference = Slack.View.approval_view_more_modal.get();
                    viewReference.setParameter('approvalId', (this.parameters.containsKey('approvalId') ? (String) this.parameters.get('approvalId') : null));
                }
                when 'approval_assigned_modal' {
                    viewReference = Slack.View.approval_assigned_modal.get();
                }
            }

            // No view found
            if (viewReference == null) {
                viewReference = Slack.View.message_modal.get();
                viewReference.setParameter('title', 'Error Processing Modal Request');
                viewReference.setParameter('message', 'Oops! There is no modal view associated with the viewName: ' + viewName);
            }

            // Build Modal
            Slack.ModalView modalView = new Slack.ModalView.builder().viewReference(viewReference).build();
            return modalView;
        }
    }
}
