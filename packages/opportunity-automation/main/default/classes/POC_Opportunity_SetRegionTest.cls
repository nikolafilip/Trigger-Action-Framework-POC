@IsTest
public class POC_Opportunity_SetRegionTest {
    
    @IsTest
    static void testSetRegion() {
        // Create unique fake IDs for each Account
        Id fakeAccountIdCA = TriggerTestUtility.getFakeId(Account.SObjectType);
        Id fakeAccountIdNY = TriggerTestUtility.getFakeId(Account.SObjectType);
        Id fakeAccountIdTX = TriggerTestUtility.getFakeId(Account.SObjectType);
        
        // Simulate account data with different billing states
        Account accountWithCA = new Account(Id = fakeAccountIdCA, BillingState = POC_Opportunity_Service.STATE_CA);
        Account accountWithNY = new Account(Id = fakeAccountIdNY, BillingState = POC_Opportunity_Service.STATE_NY);
        Account accountWithTX = new Account(Id = fakeAccountIdTX, BillingState = 'TX');

        // Populate the singleton with test data
        POC_Opportunity_Queries.getInstance().beforeAccountMap = new Map<Id, Account>{
            fakeAccountIdCA => accountWithCA,
            fakeAccountIdNY => accountWithNY,
            fakeAccountIdTX => accountWithTX
        };
        
        // Create unique fake IDs for each Opportunity
        Id fakeOpportunityIdCA = TriggerTestUtility.getFakeId(Opportunity.SObjectType);
        Id fakeOpportunityIdNY = TriggerTestUtility.getFakeId(Opportunity.SObjectType);
        Id fakeOpportunityIdTX = TriggerTestUtility.getFakeId(Opportunity.SObjectType);
        
        // Create test Opportunities
        Opportunity oppCA = new Opportunity(Id = fakeOpportunityIdCA, AccountId = fakeAccountIdCA);
        Opportunity oppNY = new Opportunity(Id = fakeOpportunityIdNY, AccountId = fakeAccountIdNY);
        Opportunity oppTX = new Opportunity(Id = fakeOpportunityIdTX, AccountId = fakeAccountIdTX);

        List<Opportunity> oppList = new List<Opportunity>{oppCA, oppNY, oppTX};

        // Execute the beforeInsert logic
        POC_Opportunity_SetRegion triggerHandler = new POC_Opportunity_SetRegion();
        triggerHandler.beforeInsert(oppList);

        // Assert that the Region__c field was set correctly after insert
        System.assertEquals(POC_Opportunity_Service.REGION_WEST, oppCA.Region__c, 'Region should be set to West for CA billing state');
        System.assertEquals(POC_Opportunity_Service.REGION_EAST, oppNY.Region__c, 'Region should be set to East for NY billing state');
        System.assertEquals(POC_Opportunity_Service.REGION_CENTRAL, oppTX.Region__c, 'Region should be set to Central for TX billing state');
        
        // Simulate a change in BillingState on the Account for update scenario
        accountWithCA.BillingState = POC_Opportunity_Service.STATE_NY;
        accountWithNY.BillingState = 'TX';
        accountWithTX.BillingState = POC_Opportunity_Service.STATE_CA;

        // Update the singleton with the modified Account data
        POC_Opportunity_Queries.getInstance().beforeAccountMap = new Map<Id, Account>{
            fakeAccountIdCA => accountWithCA,
            fakeAccountIdNY => accountWithNY,
            fakeAccountIdTX => accountWithTX
        };

        // Execute the beforeUpdate logic
        triggerHandler.beforeUpdate(oppList, oppList); // passing old and new lists the same for simplicity in this context

        // Assert that the Region__c field was updated correctly
        System.assertEquals(POC_Opportunity_Service.REGION_EAST, oppCA.Region__c, 'Region should be updated to East for NY billing state');
        System.assertEquals(POC_Opportunity_Service.REGION_CENTRAL, oppNY.Region__c, 'Region should be updated to Central for TX billing state');
        System.assertEquals(POC_Opportunity_Service.REGION_WEST, oppTX.Region__c, 'Region should be updated to West for CA billing state');
    }
}
