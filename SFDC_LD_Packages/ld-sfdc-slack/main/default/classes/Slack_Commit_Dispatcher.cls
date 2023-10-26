public class Slack_Commit_Dispatcher extends Slack.ActionDispatcher {
    public override Slack.ActionHandler invoke(Map<String, Object> parameters, Slack.RequestContext context) {
        // The slack action handler should immediately be returned.
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
            // Process the form data and return the modal view that corresponds to the requested object.
            Slack.ModalView modalView;
            String actionType = (this.parameters.containsKey('actionType') ? (String) this.parameters.get('actionType') : null);
            switch on actionType {
                when 'approval_approve_reject' {
                    modalView = submitApproval();
                }
            }
            // No modal found
            if (modalView == null) {
                return MessageModal.getMessageModalView('Error Rendering View', new List<String>{'Oops! There is no view associated with the actionType: \'',actionType, '\''});
            }
            return modalView;
        }

        private Slack.ModalView submitApproval() {
            try {
                Map<String, Object> formData = this.context.getFormData() != null ? this.context.getFormData() : new Map<String,Object>();
                Opportunity opp = new Opportunity();
                opp.Id = (this.parameters.containsKey('approvalId') ? (String) this.parameters.get('approvalId') : null);
                opp.Name = (formData.containsKey('ApprovalStatus') ? (String) formData.get('ApprovalStatus') : null);
                update opp;
                String title = 'Approval Saved!';
                String body = 'Approval saved as: \'' + opp.Name + '\'';
                return MessageModal.getMessageModalView(title, new List<String>{body});
            } catch (Exception e) {
                return getMessageModal(e.getMessage());
            }
        }

        private Slack.ModalView getMessageModal(String errorMessage) {
            String title = 'Error Processing Commit Request';
            String body = 'Oops! The following error occurred: ' + '\n' + errorMessage;
            return MessageModal.getMessageModalView(title, new List<String>{ body });
        }
    }
}
