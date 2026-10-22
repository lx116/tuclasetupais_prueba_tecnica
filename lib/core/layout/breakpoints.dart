/// A screen is wide once it passes this width; at or below it, mobile.
const double wideBreakpoint = 900;

bool isWideWidth(double width) => width > wideBreakpoint;
