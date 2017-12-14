public class Button {
  float x, y, w, h;
  String text;
  color background;
  boolean selected = false;
  boolean active = true;
  
  public Button(String text, color c) {
    this.text = text;
    this.background = c;
  }
  
  public void setSelected(boolean selected) {
    this.selected = selected; 
  }
  
  public void setActive(boolean active) {
    this.active = active; 
  }
  
  public void setLabel(String l) {
    text = l;
  }

  boolean mouseOver(){
    if (!active) {
      return false; 
    }
    if (mouseX > this.x && mouseX < (this.x + this.w) && mouseY > this.y && mouseY < (this.y + this.h)) {
      return true;
    } else {
      return false;
    }
  }
  
  void render(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    if (this.mouseOver() || this.selected) {
      fill(150);
    } else {
      fill(this.background);
    }
    
    rect(x, y, w, h);
    fill(active? 0 : 130);
    textSize(14);
    textLeading(12);
    textAlign(CENTER, CENTER);
    text(text, x, y, w, h-5);
  }
}