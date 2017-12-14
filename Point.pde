public class Point {
  public String x;
  public float y;
  
  public float[] data;
  
  Point(String x, float[] data) {
    assert data.length > 0;
    this.x = x;
    
    this.data = data;
  }
  
  float y() {
    return this.data[0];
  }
  
  float y(int index) {
    return this.data[index];
  }
}