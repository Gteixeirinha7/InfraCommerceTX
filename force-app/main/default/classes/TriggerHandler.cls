public virtual with sharing class TriggerHandler {
    
    public System.TriggerOperation operation {get; set;}
    public List<SObject> newRecordList {get;set;}
    public List<SObject> oldRecordList {get;set;}
    public Map<Id, SObject> newMap {get;set;}
    public Map<Id, SObject> oldMap {get;set;}
    
    public TriggerHandler(System.TriggerOperation operation, List<SObject> newRecordList, List<SObject> oldRecordList, Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        this.operation     = operation;
        this.newRecordList = newRecordList;
        this.oldRecordList = oldRecordList;
        this.newMap        = newMap;
        this.oldMap        = oldMap;
    }

    public void execute() {
        if (this.operation == System.TriggerOperation.BEFORE_INSERT) {
            beforeInsert();
        }
        else if (this.operation == System.TriggerOperation.AFTER_INSERT) {
            afterInsert();
        }
        else if (this.operation == System.TriggerOperation.BEFORE_UPDATE) {
            beforeUpdate();
        }
        else if (this.operation == System.TriggerOperation.AFTER_UPDATE) {
            afterUpdate();
        }
        else if (this.operation == System.TriggerOperation.BEFORE_DELETE) {
            beforeDelete();
        }
        else if (this.operation == System.TriggerOperation.AFTER_DELETE) {
            afterDelete();
        }
    }

    public virtual void beforeInsert(){}

    public virtual void afterInsert(){}

    public virtual void beforeUpdate(){}

    public virtual void afterUpdate(){}

    public virtual void beforeDelete(){}

    public virtual void afterDelete(){}

}