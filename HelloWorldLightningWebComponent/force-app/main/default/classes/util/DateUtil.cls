public with sharing class DateUtil {
    private class DateHandleException extends Exception {}

    public static Integer monthBetween(Date startDate,Date endDate){
        if(startDate==null||endDate==null){
            throw new DateHandleException('startDate or endDate can not be null');
        }
        return startDate.monthsBetween(endDate);
    }
}