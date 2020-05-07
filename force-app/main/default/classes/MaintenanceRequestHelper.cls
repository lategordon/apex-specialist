public with sharing class MaintenanceRequestHelper {
    /*
    When an existing maintenance request of type Repair or Routine Maintenance is Closed, 
    you create a new maintenance request for a future routine checkup. This new request is 
    tied to the same vehicle and piece of equipment to be serviced as the original closed service request. 
    This new request's Type should be set as Routine Maintenance. The Subject should not be null and the 
    Report Date field reflects the day the request was created. Another aspect about parts is they all have 
    different lifespans. Therefore, you need to calculate and set the next due date using the maintenance cycle 
    defined on the related work part records. If multiple work parts are used in the maintenance request, 
    choose the shortest maintenance cycle to define the service date.

    */

/*routineCheckup method takes as input a list of Cases
These cases have a status of Closed.
routineCheckup will create a new maintenace request for a future routine checkup.
- future checkup has the same vehicle and piece of equipment.
- new request Type = 'Routine Maintenance'
- subject should not be null
- report date field is day the request was created (Today)
- set due date using the maintenance cycle defined on related work parts.
- if multiple work parts choose the shorted maintenance cyce to define the service date


*/
    public static void routineCheckup(List<Case> closedMaintenanceRequest, Map<Id, Case> closedMaintenanceRequestMap){
        List<Case> allNewMaintenanceRequests = new List<Case>();
        Map<Id, Case> oldNewCases = new Map<Id,Case>();
        
        //Create a new Case for each Closed Case
        for(Case c : closedMaintenanceRequest){
            Case newMaintenanceRequest = c.clone(false, true, false, false);
            newMaintenanceRequest.Vehicle__c = c.Vehicle__c;
            newMaintenanceRequest.Equipment__c = c.Equipment__c;
            newMaintenanceRequest.Origin = c.Origin;
            newMaintenanceRequest.Priority = c.Priority;
            newMaintenanceRequest.AccountId = c.AccountId;
            newMaintenanceRequest.ContactId = c.ContactId;
            newMaintenanceRequest.Status = 'New';
            newMaintenanceRequest.Type = 'Routine Maintenance';
            newMaintenanceRequest.Date_Reported__c = date.Today();
            newMaintenanceRequest.Date_Due__c = date.Today().addDays(getMaintenanceCycle(c));
            newMaintenanceRequest.Subject = String.isBlank(c.Subject) ? 'Routine Maintenance' : c.Subject;
            allNewMaintenanceRequests.add(newMaintenanceRequest);
            oldNewCases.put(c.Id,newMaintenanceRequest);
        }
        insert(allNewMaintenanceRequests);
        updateRelatedWorkParts(oldNewCases);
    }

    private static Integer getMaintenanceCycle(Case c){
        System.debug('case is: ' + c);
        //Get all related Work Parts to Case
        List<Work_Part__c> workParts = [SELECT Id, Equipment__c 
                              FROM Work_Part__c 
                              WHERE Maintenance_Request__c = :c.Id];
       // System.debug('WorkParts '+ workParts.size() + ' ' + workParts);
        
        List<Id> equipIds = new List<Id>();

        for(Work_Part__c wp : workParts){
            equipIds.add(wp.Equipment__c);
        }
       // System.debug('equipIds ' + equipIds);
        List<Product2> allEquipment = new List<Product2>();
        if(equipIds.size() >= 1){
                    allEquipment = [SELECT Maintenance_Cycle__c
                                       FROM Product2
                                       WHERE Id IN :equipIds];
        }
        else{
            return 0;
        }
                                    
      //  System.debug('allEquipment ' + allEquipment);
        allEquipment.sort();
      //  System.debug('allEquipment after sort ' + allEquipment);
      //  System.debug(Integer.valueOf(allEquipment[0].Maintenance_Cycle__c));

        Return Integer.valueOf(allEquipment[0].Maintenance_Cycle__c);

    }



    private static void updateRelatedWorkParts(Map<Id, Case> closedWorkOrders){
        List<Work_Part__c> workParts = [SELECT Id, Name, Quantity__c, Maintenance_Request__c,Equipment__c
                                        FROM Work_Part__c  
                                        WHERE Maintenance_Request__c IN :closedWorkOrders.keySet()];
        List<Work_Part__c> newWP = new List<Work_Part__c>();
        for(Work_Part__c wp : workParts){
            Work_Part__c newWorkPart = new Work_Part__c();
            newWorkPart.Equipment__c = wp.Equipment__c;
            newWorkPart.Quantity__c = wp.Quantity__c;
            newWorkPart.Maintenance_Request__c = closedWorkOrders.get(wp.Maintenance_Request__c).Id;
            newWP.add(newWorkPart);
        }
        insert newWP;
    }


}
