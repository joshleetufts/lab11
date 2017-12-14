import java.util.*; 

class CSVParser {
  // A generic CSV reader class
  
  public String[] headers;
  public List<Map<String, String>> rows;
  
  CSVParser(String filePath) {
    String[] lines = loadStrings(filePath);
    rows = new ArrayList<Map<String, String>>();
    
    // Get the headers from the first line
    headers = split(lines[0], ",");
    
    // Iterate through all the non-header rows
    for(int row = 1; row < lines.length; row++){
      
      // Split the row by comma
      String[] rowSplit = split(lines[row], ",");
      
      // Initialize a new map for this row, mapping strings to strings
      Map<String, String> rowData = new HashMap<String, String>();
      
      // For each row, get the data and put it into a Map at the associated row index
      for (int col = 0; col < rowSplit.length; col++) {
        rowData.put(headers[col], rowSplit[col]);
      }
      
      // Put the data into the "rows" map
      rows.add(rowData);
    }
  }
}