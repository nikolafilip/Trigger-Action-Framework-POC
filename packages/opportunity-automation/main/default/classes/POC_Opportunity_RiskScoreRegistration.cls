public class POC_Opportunity_RiskScoreRegistration implements TriggerAction.AfterUpdate, TriggerAction.AfterInsert {

    public void afterUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        List<Opportunity> opportunitiesToRegister = new List<Opportunity>();
        Map<Id,Opportunity> oldMap = new Map<Id,Opportunity>(oldList);

        for (Opportunity opp : newList) {
            if (opp.StageName != oldMap.get(opp.Id).StageName ||
            opp.CloseDate != oldMap.get(opp.Id).CloseDate ||
            opp.Amount != oldMap.get(opp.Id).Amount) {    
                opportunitiesToRegister.add(opp);
            }
        }

        if (!opportunitiesToRegister.isEmpty()) {
            POC_Opportunity_RiskCalculator.registerOpportunities(opportunitiesToRegister);
        }
    }

    public void afterInsert (List<Opportunity> newList) {
        List<Opportunity> opportunitiesToRegister = new List<Opportunity>();

        for (Opportunity opp : newList) {
            opportunitiesToRegister.add(opp);
        }

        if (!opportunitiesToRegister.isEmpty()) {
            POC_Opportunity_RiskCalculator.registerOpportunities(opportunitiesToRegister);
        }
    }
}