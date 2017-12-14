public enum ChartType {
  LINECHART,
  BARCHART,
  PIECHART,
}

interface AnimationMethod {
  void call(float percent); 
}

public class Animation {
   public ChartType from, to;
   private float fromPercentage = 0.0;
   private float toPercentage = 1.0;
   private AnimationMethod renderAnimation;
   private float time;
   
   Animation(ChartType from, ChartType to, float time, AnimationMethod renderAnimation) {
     assert (from != null && to != null);
     this.from = from; // 0.0 percent
     this.to = to; // 1.0 percent
     this.renderAnimation = renderAnimation;
     this.time = time;
   }
   
   float getTime() {
     return this.time; 
   }

   boolean isAnimationFor(ChartType chart1, ChartType chart2) {
     return (chart1 == this.from && chart2 == this.to) || (chart2 == this.from && chart1 == this.to); 
   }
   
   boolean includesChartType(ChartType type) {
     return (type == this.from || type == this.to); 
   }
   
   ChartType getOtherChartType(ChartType type) {
     if (type == this.from) {
       return this.to; 
     } else if (type == this.to) {
       return this.from; 
     } else {
       return null; 
     }
   }
   
   float percentage(ChartType type) {
     assert(type == this.from || type == this.to);
     
     if (type == this.from) {
       return this.fromPercentage; 
     } 
     return this.toPercentage; 
   }
   
   ChartType type(float percentage) {
     assert (percentage == this.fromPercentage || percentage == this.toPercentage);
     if (percentage == this.fromPercentage) {
       return this.from; 
     } else {
       return this.to; 
     }
   }
   
}