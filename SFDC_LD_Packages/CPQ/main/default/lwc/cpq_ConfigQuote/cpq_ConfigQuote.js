import { LightningElement, api, track } from 'lwc';

// Initial Query Method
import getConfigInfo from '@salesforce/apex/cpq_ConfigQuoteClass.getConfigInfo';

// Contract Query Method
import getContractInfo from '@salesforce/apex/cpq_ConfigQuoteClass.getContractInfo';

// Save Method
import saveQuoteConfiguration from '@salesforce/apex/cpq_ConfigQuoteClass.saveQuoteConfiguration';

export default class CPQ_ConfigQuote extends LightningElement {

    // Type of Quote configuration
    @api configType;
    // Default Currency
    @api defaultCurrency;
    // Opportunity Info
    @api oppInfo;
    // Quote Info for existing quote being edited (Empty obj if new Quote)
    @api existingQuoteData;
    // User Info
    @api userInfo;

    // Playbook Approvals
    @track approvals = [];
    // Loading / Show Spinner
    @track loading = true;
    // Playbooks info
    @track playbooks = [];
    // Pricebooks info
    @track pricebooks = [];
    // Approvals needed for Quote
    @track quoteApprovals = [];
    // End Date of quote being configured
    @track quoteEndDate;
    // Name of quote being configured
    @track quoteName = 'New Quote';
    // Start Date of quote being configured
    @track quoteStartDate;
    // Products added to Quote
    @track quoteProducts = [];
    // Key increment helper upon deletion such that child product components do not inherit different product with same previous key
    @track quoteProductKeyHelper = 1;
    // Playbook Rules
    @track rules = [];
    // Id of Playbook currently selected
    @track selectedPlaybookId;
    // Pricebook related to currently selected Playbook
    @track selectedPricebook;
    // Contract Info for contract being replaced/renewed
    @track contractInfo = {Contract_Playbook_Answers__r: [], Contract_Entitlements__r: []};
    // Columns to show for Product Summary
    @track productColumns = [];
    // Columns to show for Entitlement Summary
    @track entitlementColumns = [];
    // Currency Conversion Map
    @track currencyMap = {};
    // Contract Currency
    @track contractCurrency;
    // Opportunity Currency
    @track oppCurrency;

    // On Mount
    async connectedCallback() {
        // Get configInfo
        let configInfo;
        try {
            configInfo = await getConfigInfo({
                adjustingContract: this.existingQuoteData.Adjustment_of_Contract__c
            });

            let playbooks = configInfo.playbooks;
            this.rules = configInfo.rules;
            this.approvals = configInfo.approvals;
            this.pricebooks = configInfo.pricebooks;
            this.currencyMap = configInfo.currencyMap;

            this.oppCurrency = this.oppInfo.CurrencyIsoCode;

            // Set existing quote Name
            if (this.existingQuoteData.Name !== undefined) {
                this.quoteName = this.existingQuoteData.Name;
            }

            // Get Contract info
            if (this.existingQuoteData.Adjustment_of_Contract__c !== undefined) {
                this.contractInfo = await getContractInfo({
                    contractId: this.existingQuoteData.Adjustment_of_Contract__c,
                    entitlementFields: configInfo.entitlementFields
                });
                // Currency for non-MultiCurrency orgs
                if (this.contractInfo.CurrencyIsoCode === undefined) {
                    this.contractInfo.CurrencyIsoCode = this.defaultCurrency;
                }
                this.contractCurrency = this.contractInfo.CurrencyIsoCode;
                // Do not allow empty child lists
                if (this.contractInfo.Contract_Playbook_Answers__r === undefined) {
                    this.contractInfo.Contract_Playbook_Answers__r = [];
                }
                if (this.contractInfo.Contract_Entitlements__r === undefined) {
                    this.contractInfo.Contract_Entitlements__r = [];
                }
                this.contractInfo.Contract_Entitlements__r.forEach(function(ent) {
                    ent.Unit_Price__c = this.convertCurrency(ent.Unit_Price__c, this.contractInfo.CurrencyIsoCode, this.oppCurrency);
                    ent.List_Price__c = this.convertCurrency(ent.List_Price__c, this.contractInfo.CurrencyIsoCode, this.oppCurrency);
                    ent.Total_Price__c = this.convertCurrency(ent.Total_Price__c, this.contractInfo.CurrencyIsoCode, this.oppCurrency);
                    ent.SubTotal_Price__c = this.convertCurrency(ent.SubTotal_Price__c, this.contractInfo.CurrencyIsoCode, this.oppCurrency);
                }, this);
            }

            // Set default selected playbook
            if (playbooks.length > 0) {

                // Match playbook from existing quote
                if (this.existingQuoteData.CPQ_Playbook__c !== undefined) {
                    this.selectedPlaybookId = this.existingQuoteData.CPQ_Playbook__c;
                    this.selectedPricebook = JSON.parse(JSON.stringify(
                        this.pricebooks.find(pricebook => pricebook.Id === this.existingQuoteData.CPQ_Playbook__r.Price_Book__c)
                    ));
                    this.productColumns = playbooks.find(playbook => playbook.playbookInfo.Id === this.selectedPlaybookId).productColumns;
                    this.entitlementColumns = playbooks.find(playbook => playbook.playbookInfo.Id === this.selectedPlaybookId).entitlementColumns;
                }
                // Otherwise default to first playbook
                else {
                    this.selectedPlaybookId = playbooks[0].playbookInfo.Id;
                    this.selectedPricebook = JSON.parse(JSON.stringify(
                        this.pricebooks.find(pricebook => pricebook.Id === playbooks[0].playbookInfo.Price_Book__c)
                    ));
                    this.productColumns = playbooks[0].productColumns;
                    this.entitlementColumns = playbooks[0].entitlementColumns;
                }

                if (this.selectedPricebook !== undefined &&
                    this.selectedPricebook.PricebookEntries !== undefined    
                ) {
                    this.selectedPricebook.PricebookEntries.forEach(function(pbe) {
                        pbe.Manually_Addible = pbe.Manually_Addible__c;
                    }, this);
                }
            }

            // Set default values on questions
            playbooks.forEach(function(playbook) {
                playbook.questionGroups.forEach(function(group) {

                    // Previous values obj
                    group.groupInfo.prevValues = {};

                    group.questions.forEach(function(question) {

                        // Previous values obj
                        question.questionInfo.prevValues = {};

                        // Find value from existing quote answer
                        let existingValue;
                        let existingTouch;
                        if (this.existingQuoteData.CPQ_Playbook_Answers__r !== undefined) {
                            this.existingQuoteData.CPQ_Playbook_Answers__r.filter(
                                answer => answer.CPQ_Playbook_Question__c === question.questionInfo.Id
                            ).forEach(function(answer) {
                                if (question.questionInfo.Answer_Type__c === 'Boolean') {
                                    existingValue = answer.Value_Boolean__c;
                                }
                                else if (question.questionInfo.Answer_Type__c === 'Currency') {
                                    existingValue = answer.Value_Currency__c;
                                } 
                                else if (question.questionInfo.Answer_Type__c === 'Date') {
                                    existingValue = answer.Value_Date__c;
                                }
                                else if (question.questionInfo.Answer_Type__c === 'Decimal') {
                                    existingValue = answer.Value_Decimal__c;
                                }
                                else if (question.questionInfo.Answer_Type__c === 'Integer') {
                                    existingValue = answer.Value_Integer__c;
                                }
                                else if (question.questionInfo.Answer_Type__c === 'Picklist' ||
                                    question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                    question.questionInfo.Answer_Type__c === 'Text' ||
                                    question.questionInfo.Answer_Type__c === 'Text Area'
                                ) {
                                    existingValue = answer.Value_Text__c;
                                }

                                existingTouch = answer.HasBeenTouched__c;
                            }, this);
                        }

                        // Default Field Value
                        if (question.questionInfo.Default_Field_Value__c !== undefined) {
                            // Determine object housing field
                            let obj = question.questionInfo.Default_Field_Value__c.split('.')[0];
                            let field = question.questionInfo.Default_Field_Value__c.split('.')[1];
                            let value;
                            // Quote
                            if (obj === 'Quote') {
                                value = this.existingQuoteData[field];
                            }
                            // Opportunity
                            else if (obj === 'Opportunity') {
                                value = this.oppInfo[field];
                            }
                            // Account
                            else if (obj === 'Account') {
                                value = this.oppInfo.Account[field];
                            }
                            // User
                            else if (obj === 'User') {
                                value = this.userInfo[field];
                            }
                            // Profile
                            else if (obj === 'Profile') {
                                value = this.userInfo.Profile[field];
                            }
                            // UserRole
                            else if (obj === 'UserRole') {
                                value = this.userInfo.UserRole[field];
                            }

                            // Address unpacking
                            if (value !== undefined) {
                                if (value.city !== undefined ||
                                    value.country !== undefined ||
                                    value.postalCode !== undefined ||
                                    value.state !== undefined ||
                                    value.street !== undefined
                                ) {
                                    let addressObj = JSON.parse(JSON.stringify(value));
                                    value = '';
                                    if (addressObj.street !== undefined) {
                                        value += addressObj.street + ', ';
                                    }
                                    if (addressObj.city !== undefined) {
                                        value += addressObj.city + ', ';
                                    }
                                    if (addressObj.state !== undefined) {
                                        value += addressObj.state + ', ';
                                    }
                                    if (addressObj.country !== undefined) {
                                        value += addressObj.country + ', ';
                                    }
                                    if (addressObj.postalCode !== undefined) {
                                        value += addressObj.postalCode;
                                    }
                                    if (value.length > 0) {
                                        if (value.charAt(value.length-1) === ' ' &&
                                            value.charAt(value.length-2) === ','
                                        ) {
                                            value = value.slice(0, -2);
                                        }
                                    }
                                }
                            }

                            question.questionInfo.answer = value;
                        }

                        // Value found from existing answer
                        else if (existingValue !== undefined) {
                            question.questionInfo.answer = existingValue;
                            question.questionInfo.touched = existingTouch;
                        }

                        // Default Values
                        // Boolean
                        else if (question.questionInfo.Default_Value_Boolean__c !== undefined &&
                            question.questionInfo.Answer_Type__c === 'Boolean'  
                        ) {
                            question.questionInfo.answer = question.questionInfo.Default_Value_Boolean__c;
                        }
                        // Currency
                        else if (question.questionInfo.Default_Value_Currency__c !== undefined &&
                            question.questionInfo.Answer_Type__c === 'Currency'  
                        ) {
                            question.questionInfo.answer = this.convertCurrency(question.questionInfo.Default_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                        }
                        // Date
                        else if (question.questionInfo.Default_Value_Date__c !== undefined &&
                            question.questionInfo.Answer_Type__c === 'Date'  
                        ) {
                            question.questionInfo.answer = question.questionInfo.Default_Value_Date__c;
                        }
                        // Decimal
                        else if (question.questionInfo.Default_Value_Decimal__c !== undefined &&
                            question.questionInfo.Answer_Type__c === 'Decimal'  
                        ) {
                            question.questionInfo.answer = question.questionInfo.Default_Value_Decimal__c;
                        }
                        // Integer
                        else if (question.questionInfo.Default_Value_Integer__c !== undefined &&
                            question.questionInfo.Answer_Type__c === 'Integer'  
                        ) {
                            question.questionInfo.answer = question.questionInfo.Default_Value_Integer__c;
                        }
                        // Text
                        else if (question.questionInfo.Default_Value_Text__c !== undefined &&
                            (
                                question.questionInfo.Answer_Type__c === 'Picklist' ||
                                question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                question.questionInfo.Answer_Type__c === 'Text' ||
                                question.questionInfo.Answer_Type__c === 'Text Area'
                            )
                        ) {
                            question.questionInfo.answer = question.questionInfo.Default_Value_Text__c;
                        }

                        // No Default
                        else {
                            if (question.questionInfo.Answer_Type__c === 'Boolean') {
                                question.questionInfo.answer = false;
                            }
                        }
                    }, this);
                }, this);
            }, this);

            // Add existing products
            if (this.existingQuoteData.QuoteLineItems !== undefined) {
                this.existingQuoteData.QuoteLineItems.forEach(function(qli) {
                    
                    // Find associated product
                    // Selected Pricebook
                    if (this.selectedPricebook !== undefined &&
                        this.selectedPricebook.PricebookEntries !== undefined    
                    ) {
                        this.selectedPricebook.PricebookEntries.forEach(function(entry) {
                            // Matching product
                            if (entry.Product2Id === qli.Product2Id ||
                                entry.Product2Id === qli.Product__c    
                            ) {
                                let productToAdd = JSON.parse(JSON.stringify(entry));

                                // Product Name
                                productToAdd.Product_Name = entry.Product2.Name;
                                                    
                                // Quantity
                                productToAdd.Quantity = qli.Quantity__c;

                                // List Price
                                productToAdd.List_Price = qli.List_Price__c;

                                // Unit Price
                                productToAdd.Unit_Price = qli.Quoted_Price__c !== undefined ? qli.Quoted_Price__c : qli.Unit_Price__c;

                                // Discount
                                if (productToAdd.List_Price !== 0) {
                                    productToAdd.Discount = 1 - (productToAdd.Unit_Price / productToAdd.List_Price);
                                } else {
                                    productToAdd.Discount = 0;
                                }

                                // Prices
                                productToAdd.Total_Price = productToAdd.Unit_Price * productToAdd.Quantity;
                                productToAdd.Sub_Total_Price = productToAdd.List_Price * productToAdd.Quantity;

                                // Dates
                                productToAdd.Start_Date = qli.Start_Date__c;
                                productToAdd.End_Date = qli.End_Date__c;

                                // Permissions
                                productToAdd.Quantity_Editable = entry.Quantity_Editable__c;
                                productToAdd.Removable = entry.Removable__c;
                                productToAdd.Discountable = entry.Discountable__c;
                                productToAdd.Dates_Editable = entry.Dates_Editable__c;
                                productToAdd.List_Price_Editable = entry.List_Price_Editable__c;

                                // Previous values obj
                                productToAdd.prevValues = {};

                                // QLI Stamp Fields
                                productToAdd.qliFields = [];

                                // Added by action
                                productToAdd.addedByAction = qli.CPQ_Playbook_Rule_Action__c; 

                                // Key
                                productToAdd.key = this.quoteProducts.length.toString() + '.' + this.quoteProductKeyHelper.toString();

                                let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
                                updatedProducts.push(productToAdd);

                                this.quoteProducts = updatedProducts;
                            }
                        }, this);
                    }
                }, this);
            }

            // Set Quote Dates
            this.updateQuoteDates(playbooks);

            // Run rules
            playbooks = this.runRules(playbooks);
            this.playbooks = playbooks;

            // Evaluate approvals
            this.evaluateApprovals();

            this.loading = false;

        } catch (e) {
            console.error(e);
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to retrieve the CPQ Configuration Data',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }
    }

    // Title for Quote Configuration
    get configTitle() {
        if (this.configType == 'New') {
            return 'Configure New Quote';
        } else if (this.configType == 'Edit') {
            return 'Configure Quote';
        }
    }

    // Determine if Cancel button can be clicked
    get disableCancelButton() {
        if (this.loading === true) {
            return true;
        } else {
            return false;
        }   
    }

    // Determine if Save button can be clicked
    get disableSaveButton() {
        if (this.loading === true) {
            return true;
        } else {
            return false;
        }
    }

    // Playbook picklist options
    get playbookOptions() {
        let playbookOptions = [];
        this.playbooks.forEach(function(playbook) {
            playbookOptions.push(
                {
                    label: playbook.playbookInfo.Label__c,
                    value: playbook.playbookInfo.Id
                }
            );
        });
        return playbookOptions;
    }

    // Playbook has been selected
    get playbookSelected() {
        if (this.selectedPlaybookId) {
            return true;
        } else {
            return false;
        }
    }

    // Playbook that is currently selected
    get selectedPlaybookObj() {
        if (this.selectedPlaybookId) {
            return this.playbooks.find(
                playbook => playbook.playbookInfo.Id === this.selectedPlaybookId
            );
        } else {
            return {};
        }
    }

    // Answer "Touched" Event
    answerTouch(event) {

        let updatedPlaybooks = this.playbooks;

        updatedPlaybooks.forEach(function(playbook) {
            if (playbook.playbookInfo.Id === event.detail.playbookId) {
                playbook.questionGroups.forEach(function(group) {
                    if (group.groupInfo.Id === event.detail.groupId) {
                        group.questions.forEach(function(question) {
                            if (question.questionInfo.Id === event.detail.questionId) {
                                question.questionInfo.touched = true;
                                question.questionInfo.answer = event.detail.answer;
                            }
                        });
                    }
                });
            }
        });

        // Run rules
        updatedPlaybooks = this.runRules(updatedPlaybooks);
        this.playbooks = updatedPlaybooks;

        // Evaluate approvals
        this.evaluateApprovals();
    }

    // Cancel clicked - return to main
    cancel() {
        const cancelEvent = new CustomEvent(
            'cancel', {
                detail: '' 
            });
        this.dispatchEvent(cancelEvent);
    }

    // Check and act on Approvals
    evaluateApprovals() {
        this.approvals.forEach(function(approval) {
            // Approval of selected playbook
            if (approval.approvalInfo.CPQ_Playbook__c === this.selectedPlaybookId) {
                let approvalEvaluation = this.evaluateCriteria(approval, this.playbooks);

                // Change in approval evaluation status
                if (approvalEvaluation != approval.approvalInfo.prevEvaluation) {

                    // Add
                    if (approvalEvaluation === true) {
                        let approvalToAdd = JSON.parse(JSON.stringify(approval));
                        this.quoteApprovals.push(approvalToAdd);
                    }
                    // Remove
                    else if (approvalEvaluation === false) {
                        let updatedApprovals = this.quoteApprovals.filter(
                            addedApproval => addedApproval.approvalInfo.Id !== approval.approvalInfo.Id
                        );
                        this.quoteApprovals = updatedApprovals;
                    }
                }

                // Set lookback evaluation for next update
                approval.approvalInfo.prevEvaluation = approvalEvaluation;
            }
        }, this);
    }

    // Evaluate Criteria based on current configuration
    evaluateCriteria(obj, playbooks) {

        let evaluation = true;

        // Set group Ns
        let groupEvalN = {
            requireds: true,
            exactN_needed: 0,
            exactN_passed: 0,
            atLeastN_needed: -1,
            atLeastN_passed: 0,
            atMostN_needed: 1,
            atMostN_passed: 0,
        };

        obj.criteriaGroups.forEach(function(criteriaGroup) {
            // Assume true
            let groupEvaluation = true;

            // Update needed Ns
            if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of N required') {
                groupEvalN.exactN_needed = criteriaGroup.groupInfo.N__c;
            }
            else if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of at least N required') {
                groupEvalN.atLeastN_needed = criteriaGroup.groupInfo.N__c;
            }
            else if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of at most N required') {
                groupEvalN.atMostN_needed = criteriaGroup.groupInfo.N__c;
            }

            // Set criteria Ns
            let criterionEvalN = {
                requireds: true,
                exactN_needed: 0,
                exactN_passed: 0,
                atLeastN_needed: -1,
                atLeastN_passed: 0,
                atMostN_needed: 1,
                atMostN_passed: 0,
            };

            // Evaluate each criterion
            criteriaGroup.criteria.forEach(function(criterion) {
                // Assume false, if no question found it remains false
                let criterionEvaluation = false;

                // Update needed Ns
                if (criterion.criterionInfo.Evaluation_Logic__c === 'One of N required') {
                    criterionEvalN.exactN_needed = criterion.criterionInfo.N__c;
                }
                else if (criterion.criterionInfo.Evaluation_Logic__c === 'One of at least N required') {
                    criterionEvalN.atLeastN_needed = criterion.criterionInfo.N__c;
                }
                else if (criterion.criterionInfo.Evaluation_Logic__c === 'One of at most N required') {
                    criterionEvalN.atMostN_needed = criterion.criterionInfo.N__c;
                }

                // Find System source that Criterion references
                if (criterion.criterionInfo.Criterion_Source__c === 'System Value' &&
                    criterion.criterionInfo.System_Value_Source__c !== undefined
                ) {
                    // Is Edit
                    if (criterion.criterionInfo.System_Value_Source__c === 'Is Edit') {
                        criterionEvaluation = ((this.configType === 'Edit') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // Is Contract Replacement
                    else if (criterion.criterionInfo.System_Value_Source__c === 'Is Contract Replacement') {
                        criterionEvaluation = ((this.existingQuoteData.Adjustment_Type__c === 'Replacement') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // Is Contract Renewal
                    else if (criterion.criterionInfo.System_Value_Source__c === 'Is Contract Renewal') {
                        criterionEvaluation = ((this.existingQuoteData.Adjustment_Type__c === 'Renewal') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // Contract Is Active
                    else if (criterion.criterionInfo.System_Value_Source__c === 'Contract Is Active') {
                        criterionEvaluation = ((this.contractInfo.Contract_Status__c === 'Active') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // Contract Is Upcoming
                    else if (criterion.criterionInfo.System_Value_Source__c === 'Contract Is Upcoming') {
                        criterionEvaluation = ((this.contractInfo.Contract_Status__c === 'Upcoming') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                    // Contract Is Past
                    else if (criterion.criterionInfo.System_Value_Source__c === 'Contract Is Past') {
                        criterionEvaluation = ((this.contractInfo.Contract_Status__c === 'Past') === criterion.criterionInfo.Comparison_Value_Boolean__c);
                    }
                }
                // Find Question that Criterion references
                else if (criterion.criterionInfo.Criterion_Source__c === 'Question' &&
                    criterion.criterionInfo.CPQ_Playbook_Question__c !== undefined
                ) {
                    playbooks.forEach(function(playbook) {
                        // Matching Playbook
                        if (playbook.playbookInfo.Id === this.selectedPlaybookId) {
                            playbook.questionGroups.forEach(function(group) {
                                // Matching Group
                                if (group.groupInfo.Id === criterion.criterionInfo.CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c) {
                                    group.questions.forEach(function(question) {
                                        // Matching Question
                                        if (question.questionInfo.Id === criterion.criterionInfo.CPQ_Playbook_Question__c) {

                                            // Current answer
                                            let answer = question.questionInfo.answer;

                                            // Comparison value
                                            let comparisonValue;
                                            if (question.questionInfo.Answer_Type__c === 'Boolean') {
                                                comparisonValue = criterion.criterionInfo.Comparison_Value_Boolean__c;
                                            }
                                            else if (question.questionInfo.Answer_Type__c === 'Currency') {
                                                comparisonValue = this.convertCurrency(criterion.criterionInfo.Comparison_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                                            }
                                            else if (question.questionInfo.Answer_Type__c === 'Date') {
                                                if (answer) {
                                                    answer = new Date(answer);
                                                }
                                                if (comparisonValue) {
                                                    comparisonValue = new Date(criterion.criterionInfo.Comparison_Value_Date__c);
                                                }
                                            }
                                            else if (question.questionInfo.Answer_Type__c === 'Decimal') {
                                                comparisonValue = criterion.criterionInfo.Comparison_Value_Decimal__c;
                                            }
                                            else if (question.questionInfo.Answer_Type__c === 'Integer') {
                                                comparisonValue = criterion.criterionInfo.Comparison_Value_Integer__c;
                                            }
                                            else if (question.questionInfo.Answer_Type__c === 'Picklist' ||
                                                question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                                question.questionInfo.Answer_Type__c === 'Text' ||
                                                question.questionInfo.Answer_Type__c === 'Text Area'
                                            ) {
                                                comparisonValue = criterion.criterionInfo.Comparison_Value_Text__c;
                                            }

                                            // Comparison
                                            if (criterion.criterionInfo.Comparison_Operator__c === 'Equals') {
                                                criterionEvaluation = (answer === comparisonValue);
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not equal') {
                                                criterionEvaluation = (answer !== comparisonValue);
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than') {
                                                criterionEvaluation = (answer > comparisonValue);
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than or equal') {
                                                criterionEvaluation = (answer >= comparisonValue);
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than') {
                                                criterionEvaluation = (answer < comparisonValue);
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than or equal') {
                                                criterionEvaluation = (answer <= comparisonValue);
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Contains') {
                                                if (answer !== undefined) {
                                                    criterionEvaluation = (answer.includes(comparisonValue));
                                                } else {
                                                    criterionEvaluation = false;
                                                }
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not contain') {
                                                if (answer !== undefined) {
                                                    criterionEvaluation = (!answer.includes(comparisonValue));
                                                } else {
                                                    criterionEvaluation = true;
                                                }
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Is empty') {
                                                criterionEvaluation = (answer === '' || answer === undefined || answer === null);
                                            }
                                            else if (criterion.criterionInfo.Comparison_Operator__c === 'Is not empty') {
                                                criterionEvaluation = !(answer === '' || answer === undefined || answer === null);
                                            }
                                        }
                                    }, this);
                                }
                            }, this);
                        }
                    }, this);
                }
                // Find Product that Criterion references
                else if (criterion.criterionInfo.Criterion_Source__c === 'Product' &&
                    criterion.criterionInfo.Product__c !== undefined
                ) {

                    // Entitlement
                    if (criterion.criterionInfo.Product_Is_Entitlement__c === true) {
                        this.contractInfo.Contract_Entitlements__r.forEach(function(ent) {
                            // Matching product
                            if (ent.Product__c === criterion.criterionInfo.Product__c &&
                                (
                                    (
                                        criterion.criterionInfo.Target_Manual_Addition_Only__c !== true &&
                                        (
                                            criterion.criterionInfo.Product_Criterion_Target_Rule_Action__c === undefined ||
                                            ent.CPQ_Playbook_Rule_Action__c === criterion.criterionInfo.Product_Criterion_Target_Rule_Action__c
                                        )
                                    ) ||
                                    (
                                        criterion.criterionInfo.Target_Manual_Addition_Only__c === true &&
                                        ent.CPQ_Playbook_Rule_Action__c === undefined
                                    )
                                )
                            ) {

                                let newProdField;
                                if (criterion.criterionInfo.Product_Field__c === 'Quantity') {
                                    newProdField = 'Quantity__c';    
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'Discount') {
                                    newProdField = 'Discount__c'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'Unit Price') {
                                    newProdField = 'Unit_Price__c'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'List Price') {
                                    newProdField = 'List_Price__c'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'Total Price') {
                                    newProdField = 'Total_Price__c'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'Start Date') {
                                    newProdField = 'Start_Date__c'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'End Date') {
                                    newProdField = 'End_Date__c'; 
                                }

                                // Current value
                                let value = ent[newProdField];

                                // Comparison value
                                let comparisonValue;
                                if (newProdField === 'Start_Date__c' ||
                                    newProdField === 'End_Date__c'
                                ) {
                                    if (value) {
                                        value = new Date(value);
                                    }
                                    if (comparisonValue) {
                                        comparisonValue = new Date(criterion.criterionInfo.Comparison_Value_Date__c);
                                    }
                                }
                                else if (newProdField === 'Unit_Price__c' ||
                                    newProdField === 'List_Price__c' ||
                                    newProdField === 'Total_Price__c'
                                ) {
                                    comparisonValue = this.convertCurrency(criterion.criterionInfo.Comparison_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                                }
                                else if (newProdField === 'Quantity__c') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Integer__c;
                                }
                                else if (newProdField === 'Discount__c') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Decimal__c;
                                }

                                // Comparison
                                if (criterion.criterionInfo.Comparison_Operator__c === 'Equals') {
                                    criterionEvaluation = (value === comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not equal') {
                                    criterionEvaluation = (value !== comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than') {
                                    criterionEvaluation = (value > comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than or equal') {
                                    criterionEvaluation = (value >= comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than') {
                                    criterionEvaluation = (value < comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than or equal') {
                                    criterionEvaluation = (value <= comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Contains') {
                                    if (value !== undefined) {
                                        criterionEvaluation = (value.includes(comparisonValue));
                                    } else {
                                        criterionEvaluation = false;
                                    }
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not contain') {
                                    if (value !== undefined) {
                                        criterionEvaluation = (!value.includes(comparisonValue));
                                    } else {
                                        criterionEvaluation = false;
                                    }
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is empty') {
                                    criterionEvaluation = (answer === '' || answer === undefined || answer === null);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is not empty') {
                                    criterionEvaluation = !(answer === '' || answer === undefined || answer === null);
                                }
                            }
                        }, this);
                    }

                    // Quote Product
                    else {
                        this.quoteProducts.forEach(function(product) {
                            // Matching product
                            if (product.Product2Id === criterion.criterionInfo.Product__c &&
                                (
                                    (
                                        criterion.criterionInfo.Target_Manual_Addition_Only__c !== true &&
                                        (
                                            criterion.criterionInfo.Product_Criterion_Target_Rule_Action__c === undefined ||
                                            product.addedByAction === criterion.criterionInfo.Product_Criterion_Target_Rule_Action__c
                                        )
                                    ) ||
                                    (
                                        criterion.criterionInfo.Target_Manual_Addition_Only__c === true &&
                                        product.addedByAction === undefined
                                    )
                                )
                            ) {

                                // Field
                                let newProdField;
                                if (criterion.criterionInfo.Product_Field__c === 'Quantity') {
                                    newProdField = 'Quantity';    
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'Discount') {
                                    newProdField = 'Discount'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'Unit Price') {
                                    newProdField = 'Unit_Price'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'List Price') {
                                    newProdField = 'List_Price'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'Total Price') {
                                    newProdField = 'Total_Price'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'Start Date') {
                                    newProdField = 'Start_Date'; 
                                }
                                else if (criterion.criterionInfo.Product_Field__c === 'End Date') {
                                    newProdField = 'End_Date'; 
                                }

                                // Current value
                                let value = product[newProdField];

                                // Comparison value
                                let comparisonValue;
                                if (newProdField === 'Start_Date' ||
                                    newProdField === 'End_Date'
                                ) {
                                    if (value) {
                                        value = new Date(value);
                                    }
                                    if (comparisonValue) {
                                        comparisonValue = new Date(criterion.criterionInfo.Comparison_Value_Date__c);
                                    }
                                }
                                else if (newProdField === 'Unit_Price' ||
                                    newProdField === 'List_Price' ||
                                    newProdField === 'Total_Price'
                                ) {
                                    comparisonValue = this.convertCurrency(criterion.criterionInfo.Comparison_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                                }
                                else if (newProdField === 'Quantity') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Integer__c;
                                }
                                else if (newProdField === 'Discount') {
                                    comparisonValue = criterion.criterionInfo.Comparison_Value_Decimal__c;
                                }

                                // Comparison
                                if (criterion.criterionInfo.Comparison_Operator__c === 'Equals') {
                                    criterionEvaluation = (value === comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not equal') {
                                    criterionEvaluation = (value !== comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than') {
                                    criterionEvaluation = (value > comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Greater than or equal') {
                                    criterionEvaluation = (value >= comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than') {
                                    criterionEvaluation = (value < comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Less than or equal') {
                                    criterionEvaluation = (value <= comparisonValue);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Contains') {
                                    if (value !== undefined) {
                                        criterionEvaluation = (value.includes(comparisonValue));
                                    } else {
                                        criterionEvaluation = false;
                                    }
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Does not contain') {
                                    if (value !== undefined) {
                                        criterionEvaluation = (!value.includes(comparisonValue));
                                    } else {
                                        criterionEvaluation = false;
                                    }
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is empty') {
                                    criterionEvaluation = (answer === '' || answer === undefined || answer === null);
                                }
                                else if (criterion.criterionInfo.Comparison_Operator__c === 'Is not empty') {
                                    criterionEvaluation = !(answer === '' || answer === undefined || answer === null);
                                }
                            }
                        }, this);
                    }
                }

                // Update needed Ns
                if (criterionEvaluation === true) {
                    if (criterion.criterionInfo.Evaluation_Logic__c === 'One of N required') {
                        criterionEvalN.exactN_passed += 1;
                    }
                    else if (criterion.criterionInfo.Evaluation_Logic__c === 'One of at least N required') {
                        criterionEvalN.atLeastN_passed += 1;
                    }
                    else if (criterion.criterionInfo.Evaluation_Logic__c === 'One of at most N required') {
                        criterionEvalN.atMostN_passed += 1;
                    }
                } else {
                    // Criterion required, but did not pass
                    if (criterion.criterionInfo.Evaluation_Logic__c === 'Required') {
                        criterionEvalN.requireds = false;
                    }
                }
            }, this);

            // Check group evaluation status
            // At least 1 required criterion did not pass
            if (criterionEvalN.requireds === false) {
                groupEvaluation = false;
            }
            // Mismatch of N required 
            else if (criterionEvalN.exactN_needed !== criterionEvalN.exactN_passed) {
                groupEvaluation = false;
            }
            // Mismatch of at least N required 
            else if (criterionEvalN.atLeastN_needed > criterionEvalN.atLeastN_passed) {
                groupEvaluation = false;
            }
            // Mismatch of at most N required 
            else if (criterionEvalN.atMostN_needed < criterionEvalN.atMostN_passed) {
                groupEvaluation = false;
            }

            // Update needed Ns
            if (groupEvaluation === true) {
                if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of N required') {
                    groupEvalN.exactN_passed += 1;
                }
                else if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of at least N required') {
                    groupEvalN.atLeastN_passed += 1;
                }
                else if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'One of at most N required') {
                    groupEvalN.atMostN_passed += 1;
                }
            } else {
                // Criterion required, but did not pass
                if (criteriaGroup.groupInfo.Evaluation_Logic__c === 'Required') {
                    groupEvalN.requireds = false;
                }
            }
        }, this);

        // Check evaluation status
        // At least 1 required group did not pass
        if (groupEvalN.requireds === false) {
            evaluation = false;
        }
        // Mismatch of N required 
        else if (groupEvalN.exactN_needed !== groupEvalN.exactN_passed) {
            evaluation = false;
        }
        // Mismatch of at least N required 
        else if (groupEvalN.atLeastN_needed > groupEvalN.atLeastN_passed) {
            evaluation = false;
        }
        // Mismatch of at most N required 
        else if (groupEvalN.atMostN_needed < groupEvalN.atMostN_passed) {
            evaluation = false;
        }

        return evaluation;
    }

    // Check and act on Rules
    evaluateRules(playbooks) {
        let changedRuleEvaluation = false;
        this.rules.forEach(function(rule) {
            // Rule of selected playbook
            if (rule.ruleInfo.CPQ_Playbook__c === this.selectedPlaybookId) {
                let ruleEvaluation = this.evaluateCriteria(rule, playbooks);

                // Determine if rule should fire
                if ((
                        rule.ruleInfo.Evaluate_When__c == 'Evaluation change' &&
                        ruleEvaluation != rule.ruleInfo.prevEvaluation
                    ) ||
                    (
                        rule.ruleInfo.Evaluate_When__c == 'When TRUE with evaluation change' &&
                        ruleEvaluation === true &&
                        rule.ruleInfo.prevEvaluation !== true
                    ) ||
                    (
                        rule.ruleInfo.Evaluate_When__c == 'When FALSE with evaluation change' &&
                        ruleEvaluation === false &&
                        rule.ruleInfo.prevEvaluation !== false
                    ) ||
                    (
                        rule.ruleInfo.Evaluate_When__c == 'Always when TRUE' &&
                        ruleEvaluation === true
                    ) ||
                    (
                        rule.ruleInfo.Evaluate_When__c == 'Always when FALSE' &&
                        ruleEvaluation === false
                    ) ||
                    rule.ruleInfo.Evaluate_When__c == 'Always'
                ) {

                    if (ruleEvaluation != rule.ruleInfo.prevEvaluation) {
                        changedRuleEvaluation = true;
                    }

                    // Run each action
                    rule.actions.forEach(function(action) {

                        // Playbook actions
                        if (
                            (
                                action.actionInfo.Action_Type__c === 'Adjust question field' ||
                                action.actionInfo.Action_Type__c === 'Adjust question group field'
                            ) &&
                            (
                                action.actionInfo.CPQ_Playbook_Question__c !== undefined ||
                                action.actionInfo.CPQ_Playbook_Question_Group__c !== undefined
                            )
                        ) {
                            playbooks.forEach(function(playbook) {
                                // Matching Playbook
                                if (playbook.playbookInfo.Id === this.selectedPlaybookId) {
                                    playbook.questionGroups.forEach(function(group) {
                                        // Matching Playbook
                                        if (group.groupInfo.CPQ_Playbook__c === this.selectedPlaybookId) {

                                            // Question Group action
                                            if (action.actionInfo.Action_Type__c === 'Adjust question group field') {

                                                // Matching Question Group
                                                if (group.groupInfo.Id === action.actionInfo.CPQ_Playbook_Question_Group__c) {

                                                    if (ruleEvaluation === true) {

                                                        group.groupInfo.prevValues[action.actionInfo.Question_Group_Adjustment_Field__c] = group.groupInfo[action.actionInfo.Question_Group_Adjustment_Field__c];

                                                        // Static Source
                                                        if (action.actionInfo.Value_Source_Type__c === 'Static') {
                                                            
                                                            // Set new static value
                                                            if (action.actionInfo.Question_Group_Adjustment_Field__c === 'IsHidden__c') {
                                                                group.groupInfo[action.actionInfo.Question_Group_Adjustment_Field__c] = action.actionInfo.Question_Field_Value_Boolean__c;
                                                            }
                                                        }
                                                        // Dynamic Source
                                                        else if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {

                                                            let fieldType;
                                                            if (action.actionInfo.Question_Group_Adjustment_Field__c === 'IsHidden__c') {
                                                                fieldType = 'Boolean';
                                                            }
                                                            group.groupInfo[action.actionInfo.Question_Group_Adjustment_Field__c] = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, fieldType, playbooks, action.actionInfo.Numeric_Math_Operator__c);
                                                        }
                                                    } else {
                                                        if (group.groupInfo.prevValues.hasOwnProperty(action.actionInfo.Question_Group_Adjustment_Field__c)) {
                                                            group.groupInfo[action.actionInfo.Question_Group_Adjustment_Field__c] = group.groupInfo.prevValues[action.actionInfo.Question_Group_Adjustment_Field__c];
                                                        }
                                                    }
                                                }
                                            }
                                            // Question action
                                            else if (action.actionInfo.Action_Type__c === 'Adjust question field') {
                                                // Matching Group
                                                if (group.groupInfo.Id === action.actionInfo.CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c) {
                                                    group.questions.forEach(function(question) {
                                                        // Matching Question
                                                        if (question.questionInfo.Id === action.actionInfo.CPQ_Playbook_Question__c) { 

                                                            // Execute action
                                                            if (action.actionInfo.Action_Type__c === 'Adjust question field') {

                                                                if (ruleEvaluation === true) {

                                                                    question.questionInfo.prevValues[action.actionInfo.Question_Adjustment_Field__c] = question.questionInfo[action.actionInfo.Question_Adjustment_Field__c];
    
                                                                    // Static Source
                                                                    if (action.actionInfo.Value_Source_Type__c === 'Static') {
                                                                        
                                                                        // Set new static value
                                                                        if (
                                                                            (
                                                                                question.questionInfo.Answer_Type__c === 'Boolean' &&
                                                                                action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                            ) ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'IsHidden__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'IsRequired__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'IsReadOnly__c'
                                                                        ) {
                                                                            question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Question_Field_Value_Boolean__c;
                                                                        }
                                                                        else if (question.questionInfo.Answer_Type__c === 'Currency' &&
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                        ) {
                                                                            question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = this.convertCurrency(action.actionInfo.Question_Field_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                                                                        }
                                                                        else if (question.questionInfo.Answer_Type__c === 'Date' &&
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                        ) {
                                                                            question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Question_Field_Value_Date__c;
                                                                        }
                                                                        else if (
                                                                            (
                                                                                question.questionInfo.Answer_Type__c === 'Decimal' &&
                                                                                action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                            ) ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Minimum_Value__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Maximum_Value__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Step_Value__c'
                                                                        ) {
                                                                            question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Question_Field_Value_Decimal__c;
                                                                        }
                                                                        else if (question.questionInfo.Answer_Type__c === 'Integer' &&
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                        ) {
                                                                            question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Question_Field_Value_Integer__c;
                                                                        }
                                                                        else if (
                                                                            (
                                                                                action.actionInfo.Question_Adjustment_Field__c === 'answer' &&
                                                                                (
                                                                                    question.questionInfo.Answer_Type__c === 'Picklist' ||
                                                                                    question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                                                                    question.questionInfo.Answer_Type__c === 'Text' ||
                                                                                    question.questionInfo.Answer_Type__c === 'Text Area'
                                                                                )
                                                                            ) ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Picklist_Answers__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Quote_Save_Field__c'
                                                                        ) {
                                                                            question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = action.actionInfo.Question_Field_Value_Text__c;
                                                                        }
                                                                    }
                                                                    // Dynamic Source
                                                                    else if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {

                                                                        let fieldType;
                                                                        if (
                                                                            (
                                                                                question.questionInfo.Answer_Type__c === 'Boolean' &&
                                                                                action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                            ) ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'IsHidden__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'IsRequired__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'IsReadOnly__c'
                                                                        ) {
                                                                            fieldType = 'Boolean';
                                                                        }
                                                                        else if (question.questionInfo.Answer_Type__c === 'Currency' &&
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                        ) {
                                                                            fieldType = 'Currency';
                                                                        }
                                                                        else if (question.questionInfo.Answer_Type__c === 'Date' &&
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                        ) {
                                                                            fieldType = 'Date';
                                                                        }
                                                                        else if (
                                                                            (
                                                                                question.questionInfo.Answer_Type__c === 'Decimal' &&
                                                                                action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                            ) ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Minimum_Value__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Maximum_Value__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Step_Value__c'
                                                                        ) {
                                                                            fieldType = 'Decimal';
                                                                        }
                                                                        else if (question.questionInfo.Answer_Type__c === 'Integer' &&
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'answer'
                                                                        ) {
                                                                            fieldType = 'Integer';
                                                                        }
                                                                        else if (
                                                                            (
                                                                                action.actionInfo.Question_Adjustment_Field__c === 'answer' &&
                                                                                (
                                                                                    question.questionInfo.Answer_Type__c === 'Picklist' ||
                                                                                    question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                                                                                    question.questionInfo.Answer_Type__c === 'Text' ||
                                                                                    question.questionInfo.Answer_Type__c === 'Text Area'
                                                                                )
                                                                            ) ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Picklist_Answers__c' ||
                                                                            action.actionInfo.Question_Adjustment_Field__c === 'Quote_Save_Field__c'
                                                                        ) {
                                                                            fieldType = 'Text';
                                                                        }
                                                                        question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, fieldType, playbooks, action.actionInfo.Numeric_Math_Operator__c);
                                                                    }
                                                                } else {
                                                                    if (question.questionInfo.prevValues.hasOwnProperty(action.actionInfo.Question_Adjustment_Field__c)) {
                                                                        question.questionInfo[action.actionInfo.Question_Adjustment_Field__c] = question.questionInfo.prevValues[action.actionInfo.Question_Adjustment_Field__c];
                                                                    }
                                                                }

                                                                if (question.questionInfo.actionSet !== undefined) {
                                                                    question.questionInfo.actionSet += 1;
                                                                } else {
                                                                    question.questionInfo.actionSet = 1;
                                                                }
                                                            }
                                                        }
                                                    }, this);
                                                }
                                            }
                                        }
                                    }, this);
                                }
                            }, this);
                        }
                        // Product actions
                        else if (
                            (
                                action.actionInfo.Action_Type__c === 'Add product' ||
                                action.actionInfo.Action_Type__c === 'Adjust product field'
                            ) &&
                            action.actionInfo.Product__c !== undefined
                        ) {
                            
                            // Find associated product
                            // Selected pricebook
                            if (this.selectedPricebook !== undefined &&
                                this.selectedPricebook.PricebookEntries !== undefined    
                            ) {
                                this.selectedPricebook.PricebookEntries.forEach(function(entry) {
                                    // Matching product
                                    if (entry.Product2Id === action.actionInfo.Product__c) {

                                        if (action.actionInfo.Action_Type__c === 'Add product') {

                                            if (ruleEvaluation === true) {

                                                // Only add if not already added by this rule (only relevant for initial action on edit)
                                                if (this.quoteProducts.filter(
                                                        product => product.addedByAction === action.actionInfo.Id
                                                    ).length === 0
                                                ) {
                                                    this.addProduct(JSON.parse(JSON.stringify(entry)), action.actionInfo.Id);
                                                }

                                            } else {

                                                // Remove product
                                                let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
                                                updatedProducts = updatedProducts.filter(
                                                    product => product.addedByAction !== action.actionInfo.Id
                                                );

                                                // Re-Key products
                                                this.quoteProductKeyHelper += 1;
                                                updatedProducts.forEach(function(productToKey) {
                                                    productToKey.key = updatedProducts.indexOf(productToKey).toString() + '.' + this.quoteProductKeyHelper.toString()
                                                }, this);
                                                this.quoteProducts = updatedProducts;
                                            }
                                        }
                                        else if (action.actionInfo.Action_Type__c === 'Adjust product field') {

                                            // Manually Addible (pricebook entry level)
                                            if (action.actionInfo.Product_Adjustment_Field__c === 'Manually_Addible') {

                                                if (ruleEvaluation === true) {
                                                    entry.Manually_Addible = action.actionInfo.Product_Field_Value_Boolean__c;
                                                } else {
                                                    entry.Manually_Addible = !action.actionInfo.Product_Field_Value_Boolean__c;
                                                }

                                                if (entry.Manually_Addible === false) {
                                                    // Remove manually added product
                                                    let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
                                                    updatedProducts = updatedProducts.filter(
                                                        product => product.addedByAction === undefined && product.Product2Id === entry.Product2Id
                                                    );

                                                    // Re-Key products
                                                    this.quoteProductKeyHelper += 1;
                                                    updatedProducts.forEach(function(productToKey) {
                                                        productToKey.key = updatedProducts.indexOf(productToKey).toString() + '.' + this.quoteProductKeyHelper.toString()
                                                    }, this);
                                                    this.quoteProducts = updatedProducts;
                                                }
                                            }
                                            // All others (quote product level)
                                            else {
                                                this.quoteProducts.forEach(function(product) {
                                                    if (product.Product2Id === action.actionInfo.Product__c &&
                                                        (
                                                            (// Targeting specific rule action or not targeting anything
                                                                action.actionInfo.Target_Manual_Addition_Only__c !== true &&
                                                                (
                                                                    action.actionInfo.Product_Adjustment_Target_Rule_Action__c === undefined ||
                                                                    product.addedByAction === action.actionInfo.Product_Adjustment_Target_Rule_Action__c
                                                                )
                                                            ) ||
                                                            (// Manually added target
                                                                action.actionInfo.Target_Manual_Addition_Only__c === true &&
                                                                product.addedByAction === undefined
                                                            )
                                                        )
                                                    ) {
                                                        if (ruleEvaluation === true) {

                                                            product.prevValues[action.actionInfo.Product_Adjustment_Field__c] = product[action.actionInfo.Product_Adjustment_Field__c];
                                                            product.qliFields.push(action.actionInfo.Product_Adjustment_Field__c);

                                                            // Static Source
                                                            if (action.actionInfo.Value_Source_Type__c === 'Static') {
                                                                
                                                                // Set new static value
                                                                if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Boolean') {
                                                                    product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Product_Field_Value_Boolean__c;
                                                                }
                                                                else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Currency') {
                                                                    product[action.actionInfo.Product_Adjustment_Field__c] = this.convertCurrency(action.actionInfo.Product_Field_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                                                                }
                                                                else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Date') {
                                                                    product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Product_Field_Value_Date__c;
                                                                }
                                                                else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Decimal') {
                                                                    product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Product_Field_Value_Decimal__c;
                                                                }
                                                                else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Integer') {
                                                                    product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Product_Field_Value_Integer__c;
                                                                }
                                                                else if (action.actionInfo.Product_Adjustment_Field_Type__c === 'Picklist' ||
                                                                    action.actionInfo.Product_Adjustment_Field_Type__c === 'Multi-Select Picklist' ||
                                                                    action.actionInfo.Product_Adjustment_Field_Type__c === 'Text' ||
                                                                    action.actionInfo.Product_Adjustment_Field_Type__c === 'Text Area'
                                                                ) {
                                                                    product[action.actionInfo.Product_Adjustment_Field__c] = action.actionInfo.Product_Field_Value_Text__c;
                                                                }
                                                            }
                                                            // Dynamic Source
                                                            else if (action.actionInfo.Value_Source_Type__c === 'Dynamic') {
                                                                product[action.actionInfo.Product_Adjustment_Field__c] = this.runCalculations(action.calculationItems, action.actionInfo.Calculation_Type__c, action.actionInfo.Product_Adjustment_Field_Type__c, playbooks, action.actionInfo.Numeric_Math_Operator__c);
                                                            }
                                                        } else {
                                                            if (product.prevValues.hasOwnProperty(action.actionInfo.Product_Adjustment_Field__c)) {
                                                                product[action.actionInfo.Product_Adjustment_Field__c] = product.prevValues[action.actionInfo.Product_Adjustment_Field__c];
                                                            }
                                                        }

                                                        // Reset Discount
                                                        if (action.actionInfo.Product_Adjustment_Field__c === 'Unit_Price' ||
                                                            action.actionInfo.Product_Adjustment_Field__c === 'List_Price'
                                                        ) {
                                                            if (product.List_Price !== 0) {
                                                                product.Discount = 1 - (product.Unit_Price / product.List_Price);
                                                            } else {
                                                                product.Discount = 0;
                                                            }
                                                        }

                                                        // Reset Unit Price
                                                        else if (action.actionInfo.Product_Adjustment_Field__c === 'Discount') {
                                                            product.Unit_Price = (1 - product.Discount) * product.List_Price;
                                                        }

                                                        // Reset prices
                                                        product.Total_Price = product.Quantity * product.Unit_Price;
                                                        product.Sub_Total_Price = product.Quantity * product.List_Price;
                                                    }
                                                }, this);
                                            }
                                        }
                                    }
                                }, this);
                            }
                        }
                    }, this);
                }

                // Set lookback evaluation for next update
                rule.ruleInfo.prevEvaluation = ruleEvaluation;
            }
        }, this);

        return {
            playbooks: playbooks,
            changedRuleEvaluation: changedRuleEvaluation
        };
    }

    // Name Change
    nameChange(event) {
        this.quoteName = event.detail.value;
    }

    // Playbook picklist change event
    playbookChange(event) {
        this.selectedPlaybookId = event.detail.value;
        this.selectedPricebook = JSON.parse(JSON.stringify(
            this.pricebooks.find(pricebook => pricebook.Id === this.playbooks.find(playbook => playbook.playbookInfo.Id === event.detail.value).playbookInfo.Price_Book__c)
        ));
        this.productColumns = this.playbooks.find(playbook => playbook.playbookInfo.Id === this.selectedPlaybookId).productColumns;
        this.entitlementColumns = this.playbooks.find(playbook => playbook.playbookInfo.Id === this.selectedPlaybookId).entitlementColumns;
        if (this.selectedPricebook !== undefined &&
            this.selectedPricebook.PricebookEntries !== undefined    
        ) {
            this.selectedPricebook.PricebookEntries.forEach(function(pbe) {
                pbe.Manually_Addible = pbe.Manually_Addible__c;
            }, this);
        }

        // Reset rules
        this.rules.forEach(function(rule) {
            rule.ruleInfo.prevEvaluation = undefined;
        });

        // Reset products
        this.quoteProducts = [];

        // Reset approvals
        this.quoteApprovals = [];

        // Set Quote Dates
        this.updateQuoteDates(this.playbooks);

        // Run rules
        let updatedPlaybooks = this.runRules(this.playbooks);
        this.playbooks = updatedPlaybooks;

        // Evaluate approvals
        this.evaluateApprovals();

    }

    // Calculate calculation value
    runCalculations(calculationItems, calcType, answerType, playbooks, mathOp) {

        let calcValue;

        // Set default value
        if (answerType === 'Boolean') {
            calcValue = false;
        }
        else if (answerType === 'Currency' ||
            answerType === 'Decimal' ||
            answerType === 'Integer' ||
            answerType === 'Date'
        ) {
            calcValue = undefined;
        }
        else {
            calcValue = '';
        }
        calculationItems.forEach(function(item) {
            if (item.itemInfo.Calculation_Source__c === 'Question' &&
                item.itemInfo.CPQ_Playbook_Question__c !== undefined
            ) {

                playbooks.forEach(function(playbook) {
                    // Matching Playbook
                    if (playbook.playbookInfo.Id === this.selectedPlaybookId) {
                        playbook.questionGroups.forEach(function(group) {
                            // Matching Group
                            if (group.groupInfo.Id === item.itemInfo.CPQ_Playbook_Question__r.CPQ_Playbook_Question_Group__c) {
                                group.questions.forEach(function(question) {
                                    // Matching Question
                                    if (question.questionInfo.Id === item.itemInfo.CPQ_Playbook_Question__c) { 
                                        calcValue = this.getCalcValue(calcType, calcValue, question.questionInfo.answer, answerType, question.questionInfo.Answer_Type__c);
                                    }
                                }, this);
                            }
                        }, this);
                    }
                }, this);
            } else if (item.itemInfo.Calculation_Source__c === 'Product' &&
                item.itemInfo.Product__c !== undefined &&
                item.itemInfo.Product_Calculation_Field__c !== undefined &&
                item.itemInfo.Product_Is_Entitlement__c !== true
            ) {
                // Find associated product
                this.quoteProducts.forEach(function(product) {
                    if (product.Product2Id === item.itemInfo.Product__c &&
                        (
                            item.itemInfo.Product_Calculation_Target_Rule_Action__c === undefined ||
                            product.addedByAction === item.itemInfo.Product_Calculation_Target_Rule_Action__c
                        )
                    ) {

                        let productValue;
                        // CPQ Product level
                        if (item.itemInfo.Product_Calculation_Field__c.split('.').length === 1) {
                            productValue = product[item.itemInfo.Product_Calculation_Field__c];
                        }
                        // Product2 or PricebookEntry level
                        else if (item.itemInfo.Product_Calculation_Field__c.split('.').length > 1) {
                            let obj = item.itemInfo.Product_Calculation_Field__c.split('.')[0];
                            let field = item.itemInfo.Product_Calculation_Field__c.split('.')[1];
                            // Product2
                            if (obj === 'Product2') {
                                productValue = product.Product2[field];
                            }
                            // PricebookEntry
                            else if (obj === 'PricebookEntry') {
                                productValue = product[field];
                            }
                        }

                        let itemType = 'Text';
                        if (!isNaN(productValue)) {
                            itemType = 'Decimal';
                        } else if (new Date(productValue) instanceof Date) {
                            itemType = 'Date';
                        }

                        calcValue = this.getCalcValue(calcType, calcValue, productValue, answerType, itemType);
                    }
                }, this);
            } else if (item.itemInfo.Calculation_Source__c === 'Product' &&
                item.itemInfo.Product__c !== undefined &&
                item.itemInfo.Entitlement_Calculation_Field__c !== undefined &&
                item.itemInfo.Product_Is_Entitlement__c === true
            ) {
                // Find associated entitlement
                this.contractInfo.Contract_Entitlements__r.forEach(function(ent) {
                    if (ent.Product__c === item.itemInfo.Product__c &&
                        (
                            item.itemInfo.Product_Calculation_Target_Rule_Action__c === undefined ||
                            ent.CPQ_Playbook_Rule_Action__c === item.itemInfo.Product_Calculation_Target_Rule_Action__c
                        )
                    ) {

                        let entValue;
                        // Entitlement level
                        if (item.itemInfo.Entitlement_Calculation_Field__c.split('.').length === 1) {
                            entValue = ent[item.itemInfo.Entitlement_Calculation_Field__c];
                        }
                        // Product__C level
                        else if (item.itemInfo.Entitlement_Calculation_Field__c.split('.').length > 1) {
                            let obj = item.itemInfo.Entitlement_Calculation_Field__c.split('.')[0];
                            let field = item.itemInfo.Entitlement_Calculation_Field__c.split('.')[1];
                            // Product2
                            if (obj === 'Product__r') {
                                entValue = ent.Product__r[field];
                            }
                        }

                        let itemType = 'Text';
                        if (!isNaN(entValue)) {
                            itemType = 'Decimal';
                        } else if (new Date(entValue) instanceof Date) {
                            itemType = 'Date';
                        }

                        calcValue = this.getCalcValue(calcType, calcValue, entValue, answerType, itemType);
                    }
                }, this);
            }
            else if (item.itemInfo.Calculation_Source__c === 'Current Date') {
                let today = new Date();
                let year = today.getFullYear().toString();
                let month = (today.getMonth() + 1).toString();
                if ((today.getMonth() + 1) < 10) {
                    month = '0' + month;
                }
                let day = today.getDate().toString();
                if (today.getDate() < 10) {
                    day = '0' + day;
                }
                calcValue = this.getCalcValue(calcType, calcValue, year + '-' + month + '-' + day, answerType, 'Date');
            }
            else if (item.itemInfo.Calculation_Source__c === 'Contract Start Date') {
                calcValue = this.getCalcValue(calcType, calcValue, this.contractInfo.Contract_Start_Date__c, answerType, 'Date');
            }
            else if (item.itemInfo.Calculation_Source__c === 'Contract End Date') {
                calcValue = this.getCalcValue(calcType, calcValue, this.contractInfo.Contract_End_Date__c, answerType, 'Date');
            }
            else if (item.itemInfo.Calculation_Source__c === 'Static Value') {
                let staticValue;
                if (item.itemInfo.Static_Value_Type__c === 'Boolean') {
                    staticValue = item.itemInfo.Static_Value_Boolean__c;
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Currency') {
                    staticValue = this.convertCurrency(item.itemInfo.Static_Value_Currency__c, this.defaultCurrency, this.oppCurrency);
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Date') {
                    staticValue = item.itemInfo.Static_Value_Date__c;
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Decimal') {
                    staticValue = item.itemInfo.Static_Value_Decimal__c;
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Integer') {
                    staticValue = item.itemInfo.Static_Value_Integer__c;
                }
                else if (item.itemInfo.Static_Value_Type__c === 'Text') {
                    staticValue = item.itemInfo.Static_Value_Text__c;
                }
                calcValue = this.getCalcValue(calcType, calcValue, staticValue, answerType, item.itemInfo.Static_Value_Type__c);
            }
        }, this);

        // Format
        if (calcValue !== undefined) {
            if (answerType === 'Date') {
                let calcDate = new Date(calcValue);
                // UTC used since date entered in is based on UTC, not user's time zone
                let year = calcDate.getUTCFullYear().toString();
                let month = (calcDate.getUTCMonth() + 1).toString();
                if ((calcDate.getUTCMonth() + 1) < 10) {
                    month = '0' + month;
                }
                let day = calcDate.getUTCDate().toString();
                if (calcDate.getUTCDate() < 10) {
                    day = '0' + day;
                }
                calcValue = year + '-' + month + '-' + day;
            }
            else if (answerType === 'Currency' ||
                answerType === 'Decimal' ||
                answerType === 'Integer'
            ) {
                calcValue = Number(calcValue);

                if (mathOp !== undefined) {

                    // Floor
                    if (mathOp === 'Floor') {
                        calcValue = Math.floor(calcValue);
                    }
                    // Ceiling
                    else if (mathOp === 'Ceiling') {
                        calcValue = Math.ceil(calcValue);
                    }
                    // Truncate
                    else if (mathOp === 'Truncate') {
                        calcValue = Math.trunc(calcValue);
                    }
                    // Round
                    else if (mathOp === 'Round') {
                        calcValue = Math.round(calcValue);
                    }
                    // Absolute Value
                    else if (mathOp === 'Absolute Value') {
                        calcValue = Math.abs(calcValue);
                    }
                }
            }
            else {
                calcValue = String(calcValue);
            }
        }

        return calcValue;
    }

    getCalcValue(calcType, calcValue, itemValue, answerType, itemType) {
        if (calcType === 'Add') {
            if (itemValue !== undefined) {

                let newItemVal = itemValue;
                // Date
                if (itemType === 'Date') {
                    let dateVal = new Date(itemValue);
                    newItemVal = dateVal.getTime();
                }

                // First value
                if (calcValue === undefined ||
                    calcValue === '' ||
                    calcValue === null
                ) {
                    calcValue = newItemVal;
                } else {
                    calcValue += newItemVal;
                }
            }
        }
        else if (calcType === 'Subtract') {
            if (itemValue !== undefined) {

                let newItemVal = itemValue;
                // Date
                if (itemType === 'Date') {
                    let dateVal = new Date(itemValue);
                    newItemVal = dateVal.getTime();
                }

                // First value
                if (calcValue === undefined ||
                    calcValue === '' ||
                    calcValue === null
                ) {
                    calcValue = newItemVal;
                } else {
                    calcValue -= newItemVal;
                }
            }
        }
        else if (calcType === 'Multiply') {
            if (itemValue !== undefined) {

                let newItemVal = itemValue;
                // Date
                if (itemType === 'Date') {
                    let dateVal = new Date(itemValue);
                    newItemVal = dateVal.getTime();
                }

                // First value
                if (calcValue === undefined ||
                    calcValue === '' ||
                    calcValue === null
                ) {
                    calcValue = newItemVal;
                } else {
                    calcValue *= newItemVal;
                }
            }
        }
        else if (calcType === 'Divide') {
            if (itemValue !== undefined) {

                let newItemVal = itemValue;
                // Date
                if (itemType === 'Date') {
                    let dateVal = new Date(itemValue);
                    newItemVal = dateVal.getTime();
                }

                // First value
                if (calcValue === undefined ||
                    calcValue === '' ||
                    calcValue === null
                ) {
                    calcValue = newItemVal;
                } else {
                    calcValue /= newItemVal;
                }
            }
        }
        else if (calcType === 'Max') {
            if (itemValue !== undefined) {

                if (answerType === 'Date' &&
                    (
                        calcValue === undefined ||
                        new Date(itemValue) > new Date(calcValue)
                    )
                ) {
                    calcValue = itemValue;
                }
                else if (itemValue > calcValue) {
                    calcValue = itemValue;
                }
            }
        }
        else if (calcType === 'Min') {
            if (itemValue !== undefined) {

                if (answerType === 'Date' &&
                    (
                        calcValue === undefined ||
                        new Date(itemValue) < new Date(calcValue)
                    )
                ) {
                    calcValue = itemValue;
                }
                else if (itemValue < calcValue) {
                    calcValue = itemValue;
                }
            }
        }

        return calcValue;
    }

    // Handle rules recursion -- MAX 2 times
    runRules(playbooks) {

        // Run initial rules pass
        let result = this.evaluateRules(playbooks);

        // If a rule changed evaluation, run rules again to see if actions cause others to change evaluation
        if (result.changedRuleEvaluation === true) {
            result = this.evaluateRules(result.playbooks);

            // If a rule changed evaluation, run rules again to see if actions cause others to change evaluation
            // if (result.changedRuleEvaluation === true) {
            //     result = this.evaluateRules(result.playbooks);
            // }
        }

        // this.evaluateContractAdjustment();
        this.updateQuoteDates(result.playbooks);

        return result.playbooks;
    }

    // Save clicked - generate records
    async saveQuote() {

        // Set spinner
        this.loading = true;

        // Configure Quote
        let quote = {
            sobjectType: 'Quote',
            Id: this.existingQuoteData.Id,
            Name: this.quoteName,
            OpportunityId: this.oppInfo.Id,
            CPQ_Playbook__c: this.selectedPlaybookId,
            Pricebook2Id: this.selectedPricebook.Id,
            Adjustment_of_Contract__c: this.existingQuoteData.Adjustment_of_Contract__c,
            Adjustment_Type__c: this.existingQuoteData.Adjustment_Type__c
        };

        // Configure QLIs
        let quoteLineItems = [];
        this.quoteProducts.forEach(function(product) {
            let qli = {}

            // QLI Stamp Fields
            product.qliFields.forEach(function(qliField) {
                qli[qliField] = product[qliField];
            }, this);

            // CPQ set Fields
            qli.sobjectType = 'QuoteLineItem';
            qli.CPQ_Playbook_Rule_Action__c = product.addedByAction;
            qli.End_Date__c = new Date(product.End_Date);
            qli.Discount__c = product.Discount;
            qli.List_Price__c = Number(product.List_Price);
            qli.PricebookEntryId = product.Id;
            qli.Product2Id = product.Product2Id;
            qli.Quantity = Math.min(product.Quantity, 9999999999.99);
            qli.Quantity__c = (product.Quantity);
            qli.Quoted_Price__c = Number(product.Unit_Price);
            qli.Start_Date__c = new Date(product.Start_Date);
            qli.UnitPrice = product.Unit_Price;

            quoteLineItems.push(qli);
        }, this);
        debugger;

        // Configure Playbook Answers
        let playbookAnswers = [];
        let playbookComplete = true;
        this.playbooks.forEach(function(playbook) {
            if (playbook.playbookInfo.Id === this.selectedPlaybookId) {
                playbook.questionGroups.forEach(function(group) {
                    group.questions.forEach(function(question) {

                        let playbookAnswer = {
                            sobjectType: 'CPQ_Playbook_Answer__c',
                            CPQ_Playbook_Question__c: question.questionInfo.Id,
                            Name: question.questionInfo.Name
                        };

                        // Answer Value
                        if (question.questionInfo.Answer_Type__c === 'Boolean') {
                            playbookAnswer.Value_Boolean__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Currency') {
                            playbookAnswer.Value_Currency__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Date') {
                            playbookAnswer.Value_Date__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Decimal') {
                            playbookAnswer.Value_Decimal__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Integer') {
                            playbookAnswer.Value_Integer__c = question.questionInfo.answer;
                        }
                        else if (question.questionInfo.Answer_Type__c === 'Picklist' ||
                            question.questionInfo.Answer_Type__c === 'Multi-Select Picklist' ||
                            question.questionInfo.Answer_Type__c === 'Text' ||
                            question.questionInfo.Answer_Type__c === 'Text Area'
                        ) {
                            playbookAnswer.Value_Text__c = question.questionInfo.answer;
                        }

                        // Answer "Touched"
                        playbookAnswer.HasBeenTouched__c = question.questionInfo.touched;

                        playbookAnswers.push(playbookAnswer);
                        
                        // Question still needs attention
                        if (group.groupInfo.IsHidden__c !== true &&
                            question.questionInfo.IsHidden__c !== true &&
                            question.questionInfo.IsRequired__c &&
                            !question.questionInfo.IsReadOnly__c &&
                            (
                                question.questionInfo.answer === undefined ||
                                question.questionInfo.answer === null ||
                                question.questionInfo.answer === '' ||
                                (
                                    !question.questionInfo.touched &&
                                    !question.questionInfo.IsReadOnly__c
                                )
                            )
                        ) {
                            playbookComplete = false;
                        }

                        // Populate Quote Fields
                        if (question.questionInfo.Quote_Save_Field__c !== undefined) {
                            quote[question.questionInfo.Quote_Save_Field__c] = question.questionInfo.answer;
                        }
                    }, this);
                }, this);
            }
        }, this);

        if (playbookComplete === true) {
            quote.Playbook_Status__c = 'Complete';
        } else {
            quote.Playbook_Status__c = 'Incomplete';
        }

        // Configure Quote Approvals
        let quoteApprovals = [];
        let quoteApprovalSteps = [];
        let quoteApprovers = [];
        this.quoteApprovals.forEach(function(approval) {
            let quoteApproval = {
                sobjectType: 'CPQ_Quote_Approval__c',
                CPQ_Playbook_Approval__c: approval.approvalInfo.Id,
                Name: approval.approvalInfo.Name,
                Status__c: 'Pending'
            };
            quoteApprovals.push(quoteApproval);

            let approvalSteps = [];
            let stepApprovers = [];
            approval.approverGroups.forEach(function(group) {
                let approvalStep = {
                    sobjectType: 'CPQ_Quote_Approval_Step__c',
                    CPQ_Playbook_Approver_Group__c: group.groupInfo.Id,
                    Name: group.groupInfo.Name,
                    Status__c: 'Pending'
                };
                approvalSteps.push(approvalStep);

                let approvers = [];
                group.approvers.forEach(function(approver) {
                    let quoteApprover = {
                        sobjectType: 'CPQ_Quote_Approver__c',
                        CPQ_Playbook_Approver__c: approver.approverInfo.Id,
                        Status__c: 'Pending'
                    };

                    if (approver.approverInfo.Manager_Approver__c === true) {
                        if (this.oppInfo.Owner) {
                            if (this.oppInfo.Owner.ManagerId) {
                                quoteApprover.Approver__c = this.oppInfo.Owner.ManagerId;
                                quoteApprover.Name = this.oppInfo.Owner.Manager.Name;
                                approvers.push(quoteApprover);
                            }
                        }
                    } else {
                        quoteApprover.Approver__c = approver.approverInfo.Approver__c;
                        quoteApprover.Name = approver.approverInfo.Approver__r.Name;
                        approvers.push(quoteApprover);
                    }
                }, this);
                stepApprovers.push(approvers);
            }, this);
            quoteApprovalSteps.push(approvalSteps);
            quoteApprovers.push(stepApprovers);
        }, this);

        // Send object to database
        try {
            await saveQuoteConfiguration({
                quoteToSave: quote,
                quoteLineItems: quoteLineItems,
                playbookAnswers: playbookAnswers,
                quoteApprovals: quoteApprovals,
                quoteApprovalSteps: quoteApprovalSteps,
                quoteApprovers: quoteApprovers
            });

            // Send save event to parent
            const saveEvent = new CustomEvent(
                'save', {
                    detail: {
                        toast: {
                            title: 'Success!',
                            message: 'Quote was saved',
                            variant: 'success'
                        }
                    }
                });
            this.dispatchEvent(saveEvent);
        } catch (e) {
            this.template.querySelector('c-error-modal').showError(
                {
                    title: 'An error occurred while trying to save the quote',
                    body: JSON.stringify(e),
                    forceRefresh: false
                }
            );
        }

        this.loading = false;
    }

    // Remove Product event
    removeProduct(event) {
        let productToRemove = event.detail;
        let updatedProducts = this.quoteProducts.filter(
            product => product.key !== productToRemove.key
        );
        this.quoteProductKeyHelper += 1;
        updatedProducts.forEach(function(product) {
            product.key = updatedProducts.indexOf(product).toString() + '.' + this.quoteProductKeyHelper.toString()
        }, this);
        this.quoteProducts = updatedProducts;

        // Evaluate approvals
        this.evaluateApprovals();

    }

    // Add Prodct to quote
    addProduct(entry, actionId) {
        let productToAdd = entry;

        // Product Name
        productToAdd.Product_Name = entry.Product2.Name;
        
        // Quantity
        if (entry.Quantity__c !== undefined) {
            productToAdd.Quantity = entry.Quantity__c;
        } else {
            productToAdd.Quantity = 1;
        }

        // List Price
        productToAdd.List_Price = entry.UnitPrice;

        // Unit Price
        productToAdd.Unit_Price = productToAdd.List_Price;

        // Total Price
        productToAdd.Total_Price = productToAdd.Unit_Price * productToAdd.Quantity;

        // Discount
        productToAdd.Discount = 0;

        // Prices
        productToAdd.Total_Price = productToAdd.Unit_Price * productToAdd.Quantity;
        productToAdd.Sub_Total_Price = productToAdd.List_Price * productToAdd.Quantity;

        // Dates
        productToAdd.Start_Date = this.quoteStartDate;
        productToAdd.End_Date = this.quoteEndDate;

        // Default Permissions
        productToAdd.Quantity_Editable = entry.Quantity_Editable__c;
        productToAdd.Removable = entry.Removable__c;
        productToAdd.Discountable = entry.Discountable__c;
        productToAdd.Dates_Editable = entry.Dates_Editable__c;
        productToAdd.List_Price_Editable = entry.List_Price_Editable__c;

        // Previous values obj
        productToAdd.prevValues = {};

        // QLI Stamp Fields
        productToAdd.qliFields = [];

        // Added by action
        productToAdd.addedByAction = actionId; 

        // Key
        productToAdd.key = this.quoteProducts.length.toString() + '.' + this.quoteProductKeyHelper.toString();

        let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
        updatedProducts.push(productToAdd);

        this.quoteProducts = updatedProducts;
    }

    // Add Products event
    addProducts(event) {

        let productsToAdd = JSON.parse(event.detail);
        productsToAdd.forEach(function(entry) {
            this.addProduct(entry, undefined);
        }, this);

        // Run rules
        let updatedPlaybooks = this.runRules(this.playbooks);
        this.playbooks = updatedPlaybooks;

        // Evaluate approvals
        this.evaluateApprovals();
    }

    // Update Product event
    updateProduct(event) {
        let updatedProducts = JSON.parse(JSON.stringify(this.quoteProducts));
        let productToUpdate = updatedProducts.find(product => product.key === event.detail.key);
        productToUpdate[event.detail.attribute] = event.detail.newValue;

        // Update Discount
        if (productToUpdate.List_Price !== 0) {
            productToUpdate.Discount = 1 - (productToUpdate.Unit_Price / productToUpdate.List_Price);
        } else {
            productToUpdate.Discount = 0;
        }

        // Update prices
        productToUpdate.Total_Price = productToUpdate.Unit_Price * productToUpdate.Quantity;
        productToUpdate.Sub_Total_Price = productToUpdate.List_Price * productToUpdate.Quantity;

        this.quoteProducts = updatedProducts;

        this.updateQuoteDates(this.playbooks);

        // Run rules
        let updatedPlaybooks = this.runRules(this.playbooks);
        this.playbooks = updatedPlaybooks;

        // Evaluate approvals
        this.evaluateApprovals();
    }

    // Update Quote Start/End Dates
    updateQuoteDates(playbooks) {
        // Update Quote Dates
        let quoteEnd;
        let quoteStart;
        this.quoteProducts.forEach(function(product) {
            if (new Date(product.End_Date) > new Date(quoteEnd) ||
                quoteEnd === undefined
            ) {
                quoteEnd = product.End_Date;
            }
            if (new Date(product.Start_Date) < new Date(quoteStart) ||
                quoteStart === undefined
            ) {
                quoteStart = product.Start_Date;
            }
        }, this);
        if (quoteStart !== undefined) {
            this.quoteStartDate = quoteStart;
        } else {
            let today = new Date();
            let year = today.getFullYear().toString();
            let month = (today.getMonth() + 1).toString();
            if ((today.getMonth() + 1) < 10) {
                month = '0' + month;
            }
            let day = today.getDate().toString();
            if (today.getDate() < 10) {
                day = '0' + day;
            }
            this.quoteStartDate = year + '-' + month + '-' + day;
        }
        if (quoteEnd !== undefined) {
            this.quoteEndDate = quoteEnd;
        } else {
            let defaultTerm = 12;
            if (this.selectedPlaybookId !== undefined &&
                playbooks.length > 0
            ) {
                defaultTerm = playbooks.find(playbook => playbook.playbookInfo.Id === this.selectedPlaybookId).playbookInfo.Default_Term_in_Months__c;
            }
            let today = new Date();
            let monthsFuture = new Date();
            monthsFuture.setMonth(today.getMonth() + defaultTerm);
            monthsFuture.setDate(monthsFuture.getDate() - 1);
            let year = monthsFuture.getFullYear().toString();
            let month = (monthsFuture.getMonth() + 1).toString();
            if ((monthsFuture.getMonth() + 1) < 10) {
                month = '0' + month;
            }
            let day = monthsFuture.getDate().toString();
            if (monthsFuture.getDate() < 10) {
                day = '0' + day;
            }
            this.quoteEndDate = year + '-' + month + '-' + day;
        }
    }

    convertCurrency(value, fromISO, toISO) {
        let rate = 1;
        if (this.currencyMap[toISO] !== undefined &&
            this.currencyMap[fromISO] !== undefined
        ) {
            this.currencyMap[toISO] / this.currencyMap[fromISO]
        }
        return value * rate;
    }
}