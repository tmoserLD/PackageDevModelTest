import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminApproval extends LightningElement {

    // Spinner
    @track loading = false;

    // Approval
    @api approval;

    // Object containing selections for all levels
    @api selected;

    // If approval is currently selected
    get isSelected() {
        if (this.selected.approval !== undefined
        ) {
            return this.selected.approval.includes(this.approval.approvalInfo.Id);
        } else {
            return false;
        }
    }

    // Child saved event
    childSaved(event) {

        // Send chilsaved event to parent
        const childsavedEvent = new CustomEvent(
            'childsaved', {
                detail: event.detail
            });
        this.dispatchEvent(childsavedEvent);
    }

    handleTabChange(event) {
        if (this.selected.approvalName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'approvals',
                        approval: this.approval.approvalInfo.Id,
                        approvalName: this.approval.approvalInfo.Name,
                        approvalTab: this.selected.approvalTab
                    }
                }
            });
        }
    }

    // Select Event
    updateSelections(event) {

        // Send select event to parent
        const selectEvent = new CustomEvent(
            'select', {
                detail: {
                    selected: event.detail.selected
                }
            });
        this.dispatchEvent(selectEvent);
    }

}