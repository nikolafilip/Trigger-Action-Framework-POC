@IsTest
public class POC_Opportunity_UpdateProbabilityTest {

    // In this class, we can't use TriggerTestUtility.getFakeId because the functionality depends on a Roll-Up Summary field.
    // This is a good example to compare the time it takes to run a DML-less test, and a test that has DML and SOQL.
    @IsTest
    static void testAfterUpdate() {
        // Insert Opportunities with CloseDate
        Opportunity opp1 = new Opportunity(Name = 'Opportunity 1', StageName = POC_Opportunity_Service.STAGE_CLOSED_WON, CloseDate = Date.today().addDays(30));
        Opportunity opp2 = new Opportunity(Name = 'Opportunity 2', StageName = POC_Opportunity_Service.STAGE_CLOSED_LOST, CloseDate = Date.today().addDays(60));
        Opportunity opp3 = new Opportunity(Name = 'Opportunity 3', StageName = POC_Opportunity_Service.STAGE_PROSPECTING, CloseDate = Date.today().addDays(90));
        insert new List<Opportunity>{opp1, opp2, opp3};

        // Insert Products and PricebookEntry
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;

        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, UnitPrice = 100, Pricebook2Id = Test.getStandardPricebookId(), IsActive = true);
        insert pbe;

        // Insert OpportunityLineItems (this will trigger the roll-up summary on Opportunity)
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opp1.Id, Quantity = 10, UnitPrice = 15000, PricebookEntryId = pbe.Id);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp2.Id, Quantity = 5, UnitPrice = 10000, PricebookEntryId = pbe.Id);
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = opp3.Id, Quantity = 1, UnitPrice = 5000, PricebookEntryId = pbe.Id);
        insert new List<OpportunityLineItem>{oli1, oli2, oli3};

        // Re-query the Opportunities to get updated roll-up summary fields
        opp1 = [SELECT Id, StageName, Probability, Total_Product_Value__c FROM Opportunity WHERE Id = :opp1.Id];
        opp2 = [SELECT Id, StageName, Probability, Total_Product_Value__c FROM Opportunity WHERE Id = :opp2.Id];
        opp3 = [SELECT Id, StageName, Probability, Total_Product_Value__c FROM Opportunity WHERE Id = :opp3.Id];

        // Clone Opportunities to simulate old state
        List<Opportunity> oldList = new List<Opportunity>{
            opp1.clone(false, true, true, true), 
            opp2.clone(false, true, true, true), 
            opp3.clone(false, true, true, true)
        };

        List<Opportunity> newList = new List<Opportunity>{opp1, opp2, opp3};

        // Create a handler instance
        POC_Opportunity_UpdateProbability handler = new POC_Opportunity_UpdateProbability();

        // Execute the afterUpdate logic
        handler.afterUpdate(newList, oldList);

        // Verify the expected Probability values
        System.assertEquals(90, opp1.Probability, 'Probability should be set to 90% for Closed Won with high value');
        System.assertEquals(0, opp2.Probability, 'Probability should be set to 0% for Closed Lost');
        System.assertEquals(50, opp3.Probability, 'Probability should be set to 50% for other stages');
    }
}
