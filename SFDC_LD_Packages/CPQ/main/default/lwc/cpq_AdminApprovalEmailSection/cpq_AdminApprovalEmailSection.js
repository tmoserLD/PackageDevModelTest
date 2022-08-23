import { LightningElement, api, track } from 'lwc';

export default class CPQ_AdminApprovalEmailSection extends LightningElement {

    // Spinner
    @track loading = false;

    // Section
    @api section;

    // Object containing selections for all levels
    @api selected;

    // If section is currently selected
    get isSelected() {
        if (this.selected.emailSection !== undefined
        ) {
            return this.selected.emailSection.includes(this.section.sectionInfo.Id);
        } else {
            return false;
        }
    }

    selectSection(event) {
        this.updateSelections({
            detail: {
                selected: {
                    playbook: this.selected.playbook,
                    playbookName: this.selected.playbookName,
                    playbookTab: 'approvals',
                    approval: this.selected.approval,
                    approvalName: this.selected.approvalName,
                    approvalTab: 'emailSections',
                    emailSection: this.selected.emailSection === this.section.sectionInfo.Id ? undefined : this.section.sectionInfo.Id,
                    emailSectionName: this.selected.emailSectionName === this.section.sectionInfo.Name ? undefined : this.section.sectionInfo.Name,
                    emailSectionTab: 'section'
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
        if (this.selected.emailSectionName === undefined) {
            this.updateSelections({
                detail: {
                    selected: {
                        tabChange: false,
                        playbook: this.selected.playbook,
                        playbookName: this.selected.playbookName,
                        playbookTab: 'approvals',
                        approval: this.selected.approval,
                        approvalName: this.selected.approvalName,
                        approvalTab: 'emailSections',
                        emailSection: this.section.sectionInfo.Id,
                        emailSectionName: this.section.sectionInfo.Name,
                        emailSectionTab: this.selected.emailSectionTab
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