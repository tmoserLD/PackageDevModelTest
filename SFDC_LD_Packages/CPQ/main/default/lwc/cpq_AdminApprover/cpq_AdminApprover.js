import { LightningElement, api, track } from 'lwc';

export default class Cpq_AdminApprover extends LightningElement {

    // Spinner
    @track loading = false;

    // Approver
    @api approver;

    // Object containing selections for all levels
    @api selected;

    // If group is currently selected
    get isSelected() {
        if (this.selected.approvalApproverGroupApprover !== undefined
        ) {
            return this.selected.approvalApproverGroupApprover.includes(this.approver.approverInfo.Id);
        } else {
            return false;
        }
    }

    selectApprover(event) {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'approvals',
                    approval: this.selected.approval,
                    approvalName: this.selected.approvalName,
                    approvalTab: 'approverGroups',
                    approvalApproverGroup: this.selected.approvalApproverGroup,
                    approvalApproverGroupName: this.selected.approvalApproverGroupName,
                    approvalApproverGroupTab: 'approvers',
                    approvalApproverGroupApprover: this.selected.approvalApproverGroupApprover === this.approver.approverInfo.Id ? undefined : this.approver.approverInfo.Id,
                    approvalApproverGroupApproverName: this.selected.approvalApproverGroupApproverName === this.approver.approverInfo.Name ? undefined : this.approver.approverInfo.Name,
                    approvalApproverGroupApproverTab: 'approver'
                }
            }
        });
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
        if (this.selected.approvalApproverGroupApproverName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'approvals',
                        approval: this.selected.approval,
                        approvalName: this.selected.approvalName,
                        approvalTab: 'approverGroups',
                        approvalApproverGroup: this.selected.approvalApproverGroup,
                        approvalApproverGroupName: this.selected.approvalApproverGroupName,
                        approvalApproverGroupTab: this.selected.approvalApproverGroupTab,
                        approvalApproverGroupApprover: this.approver.approverInfo.Id,
                        approvalApproverGroupApproverName: this.approver.approverInfo.Name,
                        approvalApproverGroupApproverTab: this.selected.approvalApproverGroupApproverTab
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