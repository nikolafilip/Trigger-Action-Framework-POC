# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

Problem statement:
In this scenario, we needed to automate several key processes for both Lead and Opportunity management. For Leads, the goal was to ensure that every new Lead’s status is set to "New" upon creation, automatically assign Leads sourced from the web to the appropriate sales queue, and implement a bypass mechanism for specific users to override the status requirement. For Opportunities, the automations included setting the Region__c field based on the related Account’s billing state, notifying the Opportunity owner if the Opportunity amount exceeds $100,000, managing recursion during probability updates, and calculating a risk score based on various factors at the end of the transaction.

Use Case Overview:
Lead Management:
sObject_Trigger_Setting.Lead.md-meta

- When a new Lead is inserted, the Lead’s status should be automatically set to "New" using Apex.
	- POC_Lead_StatusValidation
	- Trigger_Action.POC_Lead_StatusValidation.md-meta
	
- If the Lead’s source is "Web," invoke a Flow to automatically assign the Lead to a specific sales queue.
	- POC_Queue.queue-meta
	- POC_Lead_AssignmentRules.flow-meta
	- Trigger_Action.POC_Lead_AssignmentRules.md-meta
	
- Implement a bypass mechanism for specific users who have a custom permission, allowing them to bypass the status setting.
	- POC_Lead_BypassStatusValidation.customPermission-meta
	- Bypass_Lead_Status_Validation.permissionset-meta
	- Trigger_Action.POC_Lead_StatusValidation.md-meta

Opportunity Management:
	- sObject_Trigger_Setting.Opportunity.md-meta
	
- Automatically set a custom field Region__c on the Opportunity based on the related Account’s billing state using Apex.
	- POC_Opportunity_SetRegion
	- Trigger_Action.POC_Opportunity_SetRegion_BeforeInsert.md-meta
	- Trigger_Action.POC_Opportunity_SetRegion_BeforeUpdate.md-meta
	
- If the Opportunity's Amount exceeds $100,000, invoke a Flow to notify the Opportunity owner.
	- POC_Opportunity_NotifyOwnerOfAmount.flow-meta
	- Trigger_Action.POC_NotifyOwnerOfAmount_AfterInsert.md-meta
	- Trigger_Action.POC_NotifyOwnerOfAmount_AfterUpdate.md-meta

- Implement recursion management to prevent infinite loops when updating the Probability field based on StageName and Total_Product_Value__c in an after update context.
	- POC_Opportunity_UpdateProbability
	- Trigger_Action.POC_Opportunity_UpdateProbability.md-meta

- Use the Singleton pattern to fetch related Account information once and use it across multiple trigger actions.
	- POC_Opportunity_Queries
	- Trigger_Action.POC_Opportunity_Queries_BeforeInsert.md-meta
	- Trigger_Action.POC_Opportunity_Queries_BeforeUpdate.md-meta
	
- Use a DML finalizer to enqueue a job that recalculates a custom Risk_Score__c field on the Opportunity at the end of the transaction.
	The risk scoring model calculates the `Risk_Score__c` field on an Opportunity based on several factors:
	1. Base Score: Starts with a base score of 50.
	2. Amount Factor: Adjusts the score based on the Opportunity amount, decreasing risk for higher amounts and increasing it for lower amounts.
	3. Close Date Factor: Evaluates the proximity of the close date, with closer dates indicating higher risk.
	4. Stage Factor: Considers the sales stage, assigning higher risk to early stages like "Prospecting" and "Qualification," while reducing risk for "Closed Won" opportunities. "Closed Lost" automatically sets the risk to the maximum score of 100.
	The final risk score is capped between 0 (no risk) and 100 (highest risk), providing a comprehensive assessment of the Opportunity's potential risk.
	- Experimental feature - eg. does not work through UI but works through Developer Console (use Dev console to update Opp during demo)
	- Independent of sObject (always ran, but we still need to register objects through triggers)
	- POC_Opportunity_RiskCalculator
	- POC_Opportunity_RiskScoreRegistration
	- POC_Opportunity_RiskCalculator_Queueable
	- DML_Finalizer.POC_Opportunity_RiskCalculator.md-meta
	- Trigger_Action.POC_RiskScoreRegistration_AfterInsert.md-meta
	- Trigger_Action.POC_RiskScoreRegistration_AfterUpdate.md-meta

- Showcase DML-less Apex Tests
	- POC_Opportunity_RiskScoreTest
	- POC_Opportunity_SetRegionTest
	- POC_Opportunity_UpdateProbabilityTest
	
Showcase:
Support for apex classes, support for flows
Order of operations, apex mixed with flows
Bypass mechanisms (apex, custom permission, flow)
Recurison management
Singleton pattern
Leverage package directories to do automations for two different object - for every object there should be a different folder in the project and defined in sfdx-project.json
Apex unit testing (using fake ID)
Finalizers (keep in mind this feature is experimental)