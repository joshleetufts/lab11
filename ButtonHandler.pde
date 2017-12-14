class ButtonHandler {
  private HashMap<String, Button> buttons;
  ButtonHandler() {
    buttons = new HashMap<String, Button>();
  }
  
  public String newButton(String tag, String text, color c) {
    Button button = new Button(text, c);
    buttons.put(tag, button);
    
    return tag;
  }
  
}