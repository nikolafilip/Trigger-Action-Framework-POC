public class POC_Opportunity_RiskCalculator_Queueable implements Queueable {
    private List<Id> opportunityIds;

    public POC_Opportunity_RiskCalculator_Queueable(List<Id> opportunityIds) {
        this.opportunityIds = opportunityIds;
    }

    public void execute(QueueableContext context) {
        List<Opportunity> opportunities = [
            SELECT Amount, CloseDate, StageName, Risk_Score__c 
            FROM Opportunity 
            WHERE Id IN :opportunityIds
        ];
        for (Opportunity opp : opportunities) {
            Integer riskScore = 50;

            // Amount factor
            if (opp.Amount > 100000) {
                riskScore -= 10;
            } else if (opp.Amount < 10000) {
                riskScore += 10;
            }

            // Close Date factor
            if (opp.CloseDate <= Date.today().addDays(30)) {
                riskScore -= 15;
            } else if (opp.CloseDate > Date.today().addDays(90)) {
                riskScore += 10;
            }

            // Stage factor
            if (opp.StageName == POC_Opportunity_Service.STAGE_PROSPECTING || opp.StageName == POC_Opportunity_Service.STAGE_QUALIFICATION) {
                riskScore += 20;
            } else if (opp.StageName == POC_Opportunity_Service.STAGE_CLOSED_WON) {
                riskScore -= 30;
            } else if (opp.StageName == POC_Opportunity_Service.STAGE_CLOSED_LOST) {
                riskScore = 100;
            }

            // Cap the risk score between 0 and 100
            opp.Risk_Score__c = Math.max(0, Math.min(100, riskScore));
        }

        update opportunities;
    }
}