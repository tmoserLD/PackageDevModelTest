import { LightningElement, api, track  } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class CPQ_ProposalListItem extends NavigationMixin(LightningElement) {

    // All Proposals on opp
    @api allProposals = [];

    // Opportunity Info
    @api oppInfo;

    // Proposal record
    @api proposal;

    // Delete Quote Confirmation Modal toggle
    @track showConfirmDelete = false;

    // Prompt to show in Delete Quote Confirmation Modal
    @track confirmDeletePrompt = '';

    // Determine if Proposal can be deleted
    get canDelete() {
        if (this.oppInfo.Lock_CPQ__c) {
            return false;
        } else {
            return true;
        }
    }

    // Delete button title
    get deleteTitle() {
        let title = 'Delete Proposal';
        if (this.oppInfo.Lock_CPQ__c) {
            title = 'Cannot Delete. Opportunity is locked';
        }
        return title;
    }

    // CSS classes for main div
    get mainCSS() {
        let mainCSS = 'slds-grid slds-p-around_x-small';
        if (this.allProposals.indexOf(this.proposal) % 2 === 1) {
            mainCSS += ' slds-theme_shade';
        }
        return mainCSS;
    }

    // Cancel delete proposal
    cancelDeleteProposal() {
        this.showConfirmDelete = false;
        this.confirmDeletePrompt = '';
    }

    // Confirmation received to delete proposal
    confirmDeleteProposal() {

        this.showConfirmDelete = false;
        this.confirmDeletePrompt = '';

        // Send delete call to parent
        const deleteQuoteEvent = new CustomEvent(
            'deleteproposal', {
                detail: this.proposal.Id
            });
        this.dispatchEvent(deleteQuoteEvent);
    }

    // Delete Proposal clicked
    deleteProposal() {
        this.showConfirmDelete = true;
        this.confirmDeletePrompt = 'Are you sure you want to delete \'' + this.proposal.ContentDocument.LatestPublishedVersion.Title + '\'?';
    }

    // View Proposal
    viewProposal() {
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: this.proposal.ContentDocument.Id
            }
        })
    }
}