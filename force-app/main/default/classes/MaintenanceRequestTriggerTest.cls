@isTest
public with sharing class MaintenanceRequestTriggerTest {
    @TestSetup
    private static void makeData(){

        //Make Some Equipment
        List<Product2> equipment = new List<Product2>();
        for(Integer i = 0; i < 5 ; i++){
            equipment.add(new Product2(
                Name = 'Equipment ' + (i+1),
                ProductCode = 'Product Code ' + (i),
                IsActive = true,
                Maintenance_Cycle__c = Integer.valueOf(Math.random() * 200),
                Replacement_Part__c = true,
                Lifespan_Months__c = 15 * (i)
            ));
        }
        insert equipment;

        //Create Some Cases
        List<Case> maintenanceRequests = new List<Case>();
        for(Integer j = 0; j < 5; j++){
            maintenanceRequests.add(new Case(
            Subject = 'Test Case ' + (j+1),
            Status = 'New',
            AccountId = '0015w00002AfVDJAA3',
            Origin = 'Web',
            Type = 'Routine Maintenance'
            ));
        }
        insert maintenanceRequests;

        //Create some Work Parts
        List<Work_Part__c> workParts = new List<Work_Part__c>();
        for(Integer k = 0; k < 100; k++){
            workParts.add(new Work_Part__c(
                Quantity__c = Integer.valueOf(Math.random() * 100),
                Equipment__c = equipment[Integer.valueOf(Math.random() * 4)].Id,
                Maintenance_Request__c = maintenanceRequests[Integer.valueOf(Math.random() * 4)].Id
            ));
        }
        insert workParts;

    }

    @isTest
    private static void testTrigger(){
        Test.startTest();
        List<Case> c = [SELECT Id, Status,Subject FROM Case WHERE Status = 'New'];
        for(Case cs : c){
            cs.Status = 'Closed';
        }
        update c;
        Test.stopTest();
    }
}
