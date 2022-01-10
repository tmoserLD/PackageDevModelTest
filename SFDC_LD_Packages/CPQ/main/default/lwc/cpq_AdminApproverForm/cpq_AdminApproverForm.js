import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class Cpq_AdminApproverForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Approver
    @api approver;

    // Approver Id
    @api approverId;

    // Is Manager
    @track isManager;

    // Spinner
    @track loading = false;

    // Object containing selections for all levels
    @api selected;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this calculation item?';

    // On Mount
    connectedCallback() {
        if (this.approver !== undefined) {
            this.isManager = this.approver.approverInfo.Manager_Approver__c;
        }
    }

    get hasId() {
        return this.approver !== undefined;
    }

    get groupId() {
        return this.selected.approvalApproverGroup.split('-')[0];
    }

    // Is Manager Change
    managerChange(event) {
        this.isManager = event.target.value;
    }

    // Cancel delete
    cancelDelete() {
        this.showConfirmDelete = false;
    }

    // Confirmation received to delete
    async confirmDelete() {
        this.showConfirmDelete = false;

        this.loading = true;

        try {
            await deleteRecords({
                records: [this.approver.approverInfo]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Approver was deleted',
                            variant: 'success'
                        },
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
                            approvalApproverGroupApprover: undefined,
                            approvalApproverGroupApproverName: undefined,
                            approvalApproverGroupApproverTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the approver',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteApprover() {
        this.showConfirmDelete = true;
    }

    // Saved Approver
    savedApprover(event) {

        this.loading = false;

        // Send childsaved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Approver was saved',
                        variant: 'success'
                    },
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
                        approvalApproverGroupApprover: event.detail.id,
                        approvalApproverGroupApproverTab: 'approver'
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the approver',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitApprover() {
        this.loading = true;
    }

    // Clone record
    async cloneApprover() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.approver.approverInfo.Id,
                objectAPI: 'CPQ_Playbook_Approver__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Approver was cloned',
                            variant: 'success'
                        },
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
                            approvalApproverGroupApprover: newRecord.Id,
                            approvalApproverGroupApproverName: newRecord.Name,
                            approvalApproverGroupApproverTab: 'approver'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the approver',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    cancel() {
        // Send cancel event to parent
        const cancelEvent = new CustomEvent(
            'cancel'
        );
        this.dispatchEvent(cancelEvent);
    }

}