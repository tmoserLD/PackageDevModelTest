import { LightningElement, api, track } from 'lwc';

// Clone Method
import cloneRecord from '@salesforce/apex/cpq_AdminContainerClass.cloneRecord';

// Delete Method
import deleteRecords from '@salesforce/apex/cpq_AdminContainerClass.deleteRecords';

export default class CPQ_AdminProposalCriteriaGroupForm extends LightningElement {

    // Button Label
    @api buttonLabel;

    // Card Title
    @api cardTitle;

    // Group
    @api group;

    // Group Id
    @api groupId;

    // Evaluation Logic
    @track evalLogic;

    // Spinner
    @track loading = false;

    // Object containing selections for all levels
    @api selected;

    // Delete Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Confirmation Modal
    @track confirmDeletePrompt = 'Are you sure you want to delete this criteria group?';

    // On Mount
    connectedCallback() {
        if (this.group !== undefined) {
            this.evalLogic = this.group.groupInfo.Evaluation_Logic__c;
        }
    }

    get hasId() {
        return this.group !== undefined;
    }

    // N Evaluation Type
    get n_Eval() {
        if (this.evalLogic !== undefined) {
            return this.evalLogic.includes('N required');
        } else {
            return false;
        }
    }

    get sectionId() {
        return this.selected.proposalSection.split('-')[0];
    }

    // Evaluation Logic Change
    evalLogicChange(event) {
        this.evalLogic = event.target.value;
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
                records: [this.group.groupInfo]
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Criteria Group was deleted',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'proposalSections',
                            proposalSection: this.selected.proposalSection,
                            proposalSectionName: this.selected.proposalSectionName,
                            proposalSectionTab: 'criteriaGroups',
                            proposalSectionCriteriaGroup: undefined,
                            proposalSectionCriteriaGroupName: undefined,
                            proposalSectionCriteriaGroupTab: undefined
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the criteria group',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Delete clicked
    deleteGroup() {
        this.showConfirmDelete = true;
    }

    // Saved Group
    savedGroup(event) {

        this.loading = false;

        // Send childsaved event to parent
        const savedEvent = new CustomEvent(
            'childsaved', {
                detail: {
                    toast: {
                        title: 'Success!',
                        message: 'Proposal Criteria Group was saved',
                        variant: 'success'
                    },
                    selected: {
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'proposalSections',
                        proposalSection: this.selected.proposalSection,
                        proposalSectionName: this.selected.proposalSectionName,
                        proposalSectionTab: 'criteriaGroups',
                        proposalSectionCriteriaGroup: event.detail.id,
                        proposalSectionCriteriaGroupTab: undefined
                    }
                }
            });
        this.dispatchEvent(savedEvent);
    }

    // Error
    handleError(error) {
        this.template.querySelector('c-error-modal').showError(
            {
                title: 'An error occurred while trying to save the criteria group',
                body: error.detail.detail + '\n\n' + error.detail.message,
                forceRefresh: false
            }
        );
        this.loading = false;
    }

    // Submit
    submitGroup() {
        this.loading = true;
    }

    // Clone record
    async cloneGroup() {

        this.loading = true;

        try {
            let newRecord = await cloneRecord({
                recordId: this.group.groupInfo.Id,
                objectAPI: 'CPQ_Playbook_Proposal_Criteria_Group__c'
            });

            // Send childsaved event to parent
            const childSavedEvent = new CustomEvent(
                'childsaved', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Criteria Group was cloned',
                            variant: 'success'
                        },
                        selected: {
                            playbook: this.selected.playbook,
                            playbookName: this.selected.playbookName,
                            playbookTab: 'proposalSections',
                            proposalSection: this.selected.proposalSection,
                            proposalSectionName: this.selected.proposalSectionName,
                            proposalSectionTab: 'criteriaGroups',
                            proposalSectionCriteriaGroup: newRecord.Id,
                            proposalSectionCriteriaGroupName: newRecord.Name,
                            proposalSectionCriteriaGroupTab: 'group'
                        }
                    }
                }
            );
            this.dispatchEvent(childSavedEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to clone the criteria group',
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