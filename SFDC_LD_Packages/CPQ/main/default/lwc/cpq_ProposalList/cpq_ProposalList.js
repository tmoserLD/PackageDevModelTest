import { LightningElement, api, track } from 'lwc';

// Delete Records Method
import deleteRecords from '@salesforce/apex/cpq_ContainerClass.deleteRecords';

export default class CPQ_ProposalList extends LightningElement {

    // Opportunity Info
    @api oppInfo;

    // Loading / Show Spinner
    @track loading = false;

    // Boolean indicator if Proposals exist on Opp
    get noProposalsToDisplay() {
        if (this.oppInfo.AttachedContentDocuments) {
            return this.oppInfo.AttachedContentDocuments.length <= 0;
        } else {
            return true;
        }
    }

    // Number of Proposals currently associated to Opp
    get numberOfProposals() {
        if (this.oppInfo.AttachedContentDocuments) {
            return this.oppInfo.AttachedContentDocuments.length;
        } else {
            return 0;
        }
    }

    // Delete Proposal
    async deleteProposal(event) {

        this.loading = true;
        try {
            await deleteRecords({
                records: [this.oppInfo.AttachedContentDocuments.find(
                    proposal => proposal.Id === event.detail
                )]
            });

            const reloadEvent = new CustomEvent(
                'reload', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Proposal was deleted',
                            variant: 'success'
                        }
                    }
                });
            this.dispatchEvent(reloadEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to delete the proposal',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }
    }
}