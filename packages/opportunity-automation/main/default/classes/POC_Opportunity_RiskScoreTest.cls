@IsTest
public class POC_Opportunity_RiskScoreTest {

    @IsTest
    static void testAfterUpdate() {
        // Create unique fake IDs for Opportunities
        Id fakeOpportunityId1 = TriggerTestUtility.getFakeId(Opportunity.SObjectType);
        Id fakeOpportunityId2 = TriggerTestUtility.getFakeId(Opportunity.SObjectType);

        // Simulate the original state of Opportunities
        Opportunity oppOld1 = new Opportunity(Id = fakeOpportunityId1, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Amount = 50000);
        Opportunity oppOld2 = new Opportunity(Id = fakeOpportunityId2, StageName = 'Qualification', CloseDate = Date.today().addDays(60), Amount = 75000);

        // Simulate the updated state of Opportunities
        Opportunity oppNew1 = new Opportunity(Id = fakeOpportunityId1, StageName = 'Closed Won', CloseDate = Date.today().addDays(25), Amount = 100000);
        Opportunity oppNew2 = new Opportunity(Id = fakeOpportunityId2, StageName = 'Closed Lost', CloseDate = Date.today().addDays(60), Amount = 75000);  // Only stage changed

        List<Opportunity> oldList = new List<Opportunity>{oppOld1, oppOld2};
        List<Opportunity> newList = new List<Opportunity>{oppNew1, oppNew2};

        // Create a handler instance
        POC_Opportunity_RiskScoreRegistration handler = new POC_Opportunity_RiskScoreRegistration();

        // Execute the afterUpdate logic
        Test.startTest();
        handler.afterUpdate(newList, oldList);
        Test.stopTest();

        // Assert that the opportunities have been registered for risk score calculation
        System.assertEquals(2, POC_Opportunity_RiskCalculator.getRegisteredOpportunities().size(), 'Both opportunities should be registered for risk score recalculation');
    }

    @IsTest
    static void testAfterInsert() {
        // Create unique fake IDs for Opportunities
        Id fakeOpportunityId1 = TriggerTestUtility.getFakeId(Opportunity.SObjectType);
        Id fakeOpportunityId2 = TriggerTestUtility.getFakeId(Opportunity.SObjectType);

        // Simulate new Opportunities being inserted
        Opportunity oppNew1 = new Opportunity(Id = fakeOpportunityId1, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Amount = 50000);
        Opportunity oppNew2 = new Opportunity(Id = fakeOpportunityId2, StageName = 'Qualification', CloseDate = Date.today().addDays(60), Amount = 75000);

        List<Opportunity> newList = new List<Opportunity>{oppNew1, oppNew2};

        // Create a handler instance
        POC_Opportunity_RiskScoreRegistration handler = new POC_Opportunity_RiskScoreRegistration();

        // Execute the afterInsert logic
        Test.startTest();
        handler.afterInsert(newList);
        Test.stopTest();

        // Assert that the opportunities have been registered for risk score calculation
        System.assertEquals(2, POC_Opportunity_RiskCalculator.getRegisteredOpportunities().size(), 'Both opportunities should be registered for risk score recalculation');
    }

    @IsTest
    static void testRiskScoreCalculation() {
        // Insert Opportunities with CloseDate
        Opportunity opp1 = new Opportunity(Name = 'Opportunity 1', StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Amount = 50000);
        Opportunity opp2 = new Opportunity(Name = 'Opportunity 2', StageName = 'Qualification', CloseDate = Date.today().addDays(60), Amount = 75000);
        Opportunity opp3 = new Opportunity(Name = 'Opportunity 3', StageName = 'Closed Won', CloseDate = Date.today().addDays(91), Amount = 150000);
        Opportunity opp4 = new Opportunity(Name = 'Opportunity 4', StageName = 'Closed Lost', CloseDate = Date.today().addDays(-10), Amount = 200000);
        insert new List<Opportunity>{opp1, opp2, opp3, opp4};

        // Insert Products and PricebookEntry
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;

        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, UnitPrice = 100, Pricebook2Id = Test.getStandardPricebookId(), IsActive = true);
        insert pbe;

        // Insert OpportunityLineItems (this will trigger the roll-up summary on Opportunity)
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opp1.Id, Quantity = 10, UnitPrice = 15000, PricebookEntryId = pbe.Id);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp2.Id, Quantity = 5, UnitPrice = 10000, PricebookEntryId = pbe.Id);
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = opp3.Id, Quantity = 15, UnitPrice = 10000, PricebookEntryId = pbe.Id);
        OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = opp4.Id, Quantity = 20, UnitPrice = 10000, PricebookEntryId = pbe.Id);
        insert new List<OpportunityLineItem>{oli1, oli2, oli3, oli4};

        // Re-query the Opportunities to get updated roll-up summary fields
        opp1 = [SELECT Id, StageName, Probability, Total_Product_Value__c FROM Opportunity WHERE Id = :opp1.Id];
        opp2 = [SELECT Id, StageName, Probability, Total_Product_Value__c FROM Opportunity WHERE Id = :opp2.Id];
        opp3 = [SELECT Id, StageName, Probability, Total_Product_Value__c FROM Opportunity WHERE Id = :opp3.Id];
        opp4 = [SELECT Id, StageName, Probability, Total_Product_Value__c FROM Opportunity WHERE Id = :opp4.Id];

        // Register Opportunities for Risk Calculation
        List<Opportunity> opportunitiesToRegister = new List<Opportunity>{opp1, opp2, opp3, opp4};
        POC_Opportunity_RiskCalculator.registerOpportunities(opportunitiesToRegister);

        // Create a context and execute the finalizer
        FinalizerHandler.Context context = new FinalizerHandler.Context();
        POC_Opportunity_RiskCalculator calculator = new POC_Opportunity_RiskCalculator();
        
        Test.startTest();
        calculator.execute(context);
        Test.stopTest();

        // Assert that the risk scores were calculated correctly
        Opportunity updatedOpp1 = [SELECT Id, Risk_Score__c FROM Opportunity WHERE Id = :opp1.Id];
        Opportunity updatedOpp2 = [SELECT Id, Risk_Score__c FROM Opportunity WHERE Id = :opp2.Id];
        Opportunity updatedOpp3 = [SELECT Id, Risk_Score__c FROM Opportunity WHERE Id = :opp3.Id];
        Opportunity updatedOpp4 = [SELECT Id, Risk_Score__c FROM Opportunity WHERE Id = :opp4.Id];

        System.assertNotEquals(null, updatedOpp1.Risk_Score__c, 'Risk score should be calculated for opp1');
        System.assertNotEquals(null, updatedOpp2.Risk_Score__c, 'Risk score should be calculated for opp2');
        System.assertNotEquals(null, updatedOpp3.Risk_Score__c, 'Risk score should be calculated for opp3');
        System.assertNotEquals(null, updatedOpp4.Risk_Score__c, 'Risk score should be calculated for opp4');
    }
}
