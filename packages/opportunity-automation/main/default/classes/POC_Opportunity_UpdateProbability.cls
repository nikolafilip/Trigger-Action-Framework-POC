public class POC_Opportunity_UpdateProbability implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<Opportunity> newList, List<Opportunity> oldList) {
        // Prevent recursion by ensuring this action only runs once per record per transaction
        Map<Id, Integer> processedRecords = TriggerBase.idToNumberOfTimesSeenAfterUpdate;

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for (Opportunity opp : newList) {
            if (processedRecords.get(opp.Id) > 1) {
                continue; // Skip if this record has already been processed
            }
            Opportunity oppUpdated = new Opportunity(Id = opp.Id);
            if (opp.StageName == POC_Opportunity_Service.STAGE_CLOSED_WON && opp.Total_Product_Value__c > 100000) {
                oppUpdated.Probability = 90;
            } else if (opp.StageName == POC_Opportunity_Service.STAGE_CLOSED_LOST) {
                oppUpdated.Probability = 0;
            } else {
                oppUpdated.Probability = 50;
            }

            // Intentionally left out check to see if opp.Probability != oppUpdated.Probability in order to showcase recursion control
            opportunitiesToUpdate.add(oppUpdated);
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
}