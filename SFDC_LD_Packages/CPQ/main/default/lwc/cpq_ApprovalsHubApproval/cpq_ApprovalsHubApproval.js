import { LightningElement, api, track } from 'lwc';

export default class CPQ_ApprovalsHubApproval extends LightningElement {

    // Approval Record
    @api approval;

    // Info for current user
    @api currentUser;

    reload(event) {
        // Send reload event to parent
        const reloadEvent = new CustomEvent(
            'reload', {
                detail: {}
            });
        this.dispatchEvent(reloadEvent);
    }

}