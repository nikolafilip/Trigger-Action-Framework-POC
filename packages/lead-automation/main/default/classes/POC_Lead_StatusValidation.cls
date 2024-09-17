public class POC_Lead_StatusValidation implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Lead> newList) {
        for (Lead l : newList) {
            if (l.Status != POC_Lead_Service.STATUS_NEW) {
                l.addError(POC_Lead_Service.STATUS_VALIDATION_ERROR_MESSAGE);
            }
        }
    }
}