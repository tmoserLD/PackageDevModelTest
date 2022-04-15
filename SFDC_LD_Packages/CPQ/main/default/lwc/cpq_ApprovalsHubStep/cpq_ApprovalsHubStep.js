import { LightningElement, api, track } from 'lwc';

export default class CPQ_ApprovalsHubStep extends LightningElement {

    // All Steps in Approval
    @api allSteps;

    // Info for current user
    @api currentUser;

    // Step record
    @api step;


    get approved() {
        return this.step.stepInfo.Status__c === 'Approved';
    }

    get groupNumber() {
        return 'Group ' + (this.allSteps.indexOf(this.step) + 1);
    }

    get rejected() {
        return this.step.stepInfo.Status__c === 'Rejected';
    }

    reload(event) {
        // Send reload event to parent
        const reloadEvent = new CustomEvent(
            'reload', {
                detail: {}
            });
        this.dispatchEvent(reloadEvent);
    }

}