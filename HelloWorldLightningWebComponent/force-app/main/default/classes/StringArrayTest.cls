public inherited sharing class StringArrayTest {
    public StringArrayTest() {

    }
    public static List<String> generateStringArray(Integer listSize){
        List<String> strList=new List<String>();
        Integer currentIndex=0;
        while(listSize>currentIndex){
            strList.add('Test '+currentIndex);
            currentIndex++;
        }
        return strList;
    }
}