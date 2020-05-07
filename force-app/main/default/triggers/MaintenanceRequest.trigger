trigger MaintenanceRequest on Case (before update ,after update) {
   /* //for every case that is updated if the status = Closed
    //Call the Maintenance Request Helper Class */

    //Create a list that will hold Cases that will require routineCheckup Maintenance Request
    List<Case> routineMaintenanceRequest = new List<Case>();
    Map<Id, Case> routineMaintenanceRequestMap = new Map<Id,Case>();

    //iterate through all cases after update
    if(Trigger.isAfter){
        //Loop through all cases that were updated.
       for(Case mRep : Trigger.new){
           //Find the cases that match criteria, and add them to mkCheckup List
            if((mRep.Type == 'Repair' || mRep.Type == 'Routine Maintenance') && mRep.Status == 'Closed' ){
                routineMaintenanceRequest.add(mRep);
                routineMaintenanceRequestMap.put(mRep.Id, Trigger.newMap.get(mRep.Id));
            }
        }
        MaintenanceRequestHelper.routineCheckup(routineMaintenanceRequest,routineMaintenanceRequestMap); 
    }
}