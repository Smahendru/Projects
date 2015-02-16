//*****************************************************************************
// TITLE:         GEOMETRY UTILITIES IN 2D  
// DESCRIPTION:   Classes and functions for manipulating points, vec2tors, edges, triangles, quads, frames, and circular arcs  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  Sept2ember 2009
// EDITS:         Revised July 2011
//*****************************************************************************
//************************************************************************
//**** POINT CLASS
//************************************************************************
class pt2 { float x=0,y=0; 
  // CREATE
  pt2 () {}
  pt2 (float px, float py) {x = px; y = py;};

  // MODIFY
  pt2 setTo(float px, float py) {x = px; y = py; return this;};  
  pt2 setTo(pt2 P) {x = P.x; y = P.y; return this;}; 
  pt2 setToMouse() { x = mouseX; y = mouseY;  return this;}; 
  pt2 add(float u, float v) {x += u; y += v; return this;}                       // P.add(u,v): P+=<u,v>
  pt2 add(pt2 P) {x += P.x; y += P.y; return this;};                              // incorrect notation, but useful for computing weighted averages
  pt2 add(float s, pt2 P)   {x += s*P.x; y += s*P.y; return this;};               // adds s*P
  pt2 add(vec2 V) {x += V.x; y += V.y; return this;}                              // P.add(V): P+=V
  pt2 add(float s, vec2 V) {x += s*V.x; y += s*V.y; return this;}                 // P.add(s,V): P+=sV
  pt2 translateTowards(float s, pt2 P) {x+=s*(P.x-x);  y+=s*(P.y-y);  return this;};  // transalte by ratio s towards P
  pt2 scale(float u, float v) {x*=u; y*=v; return this;};
  pt2 scale(float s) {x*=s; y*=s; return this;}                                  // P.scale(s): P*=s
  pt2 scale(float s, pt2 C) {x*=C.x+s*(x-C.x); y*=C.y+s*(y-C.y); return this;}    // P.scale(s,C): scales wrt C: P=L(C,P,s);
  pt2 rotate(float a) {float dx=x, dy=y, c=cos(a), s=sin(a); x=c*dx+s*dy; y=-s*dx+c*dy; return this;};     // P.rotate(a): rotate P around origin by angle a in radians
  pt2 rotate(float a, pt2 G) {float dx=x-G.x, dy=y-G.y, c=cos(a), s=sin(a); x=G.x+c*dx+s*dy; y=G.y-s*dx+c*dy; return this;};   // P.rotate(a,G): rotate P around G by angle a in radians
  pt2 rotate(float s, float t, pt2 G) {float dx=x-G.x, dy=y-G.y; dx-=dy*t; dy+=dx*s; dx-=dy*t; x=G.x+dx; y=G.y+dy;  return this;};   // fast rotate s=sin(a); t=tan(a/2); 
  pt2 moveWithMouse() { x += mouseX-pmouseX; y += mouseY-pmouseY;  return this;}; 
     
  // DRAW , WRITE
  pt2 write() {print("("+x+","+y+")"); return this;};  // writes point coordinates in text window
  pt2 v() {vertex(x,y); return this;};  // used for drawing polygons between beginShape(); and endShape();
  pt2 show(float r) {ellipse(x, y, 2*r, 2*r); return this;}; // shows point as disk of radius r
  pt2 show() {show(3); return this;}; // shows point as small dot
  pt2 label(String s, float u, float v) {fill(black); text(s, x+u, y+v); noFill(); return this; };
  pt2 label(String s, vec2 V) {fill(black); text(s, x+V.x, y+V.y); noFill(); return this; };
  pt2 label(String s) {label(s,5,4); return this; };
  } // end of pt2 class

//************************************************************************
//**** VECTORS
//************************************************************************
class vec2 { float x=0,y=0; 
 // CREATE
  vec2 () {};
  vec2 (float px, float py) {x = px; y = py;};
 
 // MODIFY
  vec2 setTo(float px, float py) {x = px; y = py; return this;}; 
  vec2 setTo(vec2 V) {x = V.x; y = V.y; return this;}; 
  vec2 zero() {x=0; y=0; return this;}
  vec2 scaleBy(float u, float v) {x*=u; y*=v; return this;};
  vec2 scaleBy(float f) {x*=f; y*=f; return this;};
  vec2 reverse() {x=-x; y=-y; return this;};
  vec2 divideBy(float f) {x/=f; y/=f; return this;};
  vec2 normalize() {float n=sqrt(sq(x)+sq(y)); if (n>0.000001) {x/=n; y/=n;}; return this;};
  vec2 add(float u, float v) {x += u; y += v; return this;};
  vec2 add(vec2 V) {x += V.x; y += V.y; return this;};   
  vec2 add(float s, vec2 V) {x += s*V.x; y += s*V.y; return this;};   
  vec2 rotateBy(float a) {float xx=x, yy=y; x=xx*cos(a)-yy*sin(a); y=xx*sin(a)+yy*cos(a); return this;};
  vec2 left() {float m=x; x=-y; y=m; return this;}; // turns vec2tor left
 
  // OUTPUT VEC
  vec2 clone() {return(new vec2(x,y));}; 

  // OUTPUT TEST MEASURE
  float norm() {return(sqrt(sq(x)+sq(y)));}
  boolean isNull() {return((abs(x)+abs(y)<0.000001));}
  float angle() {return(atan2(y,x)); }

  // DRAW, PRINT
  void write() {println("<"+x+","+y+">");};
  void showAt (pt2 P) {line(P.x,P.y,P.x+x,P.y+y); }; 
  void showArrowAt (pt2 P) {line(P.x,P.y,P.x+x,P.y+y); 
      float n=min(this.norm()/10.,height/50.); 
      pt2 Q=P1(P,this); 
      vec2 U = S(-n,U(this));
      vec2 W = S(.3,R(U)); 
      beginShape(); Q.add(U).add(W).v(); Q.v(); Q.add(U).add(M(W)).v(); endShape(CLOSE); }; 
  void label(String s, pt2 P) {P1(P).add(0.5,this).add(3,R(U(this))).label(s); };
  } // end vec2 class

//************************************************************************
//**** POINTS
//************************************************************************
// create 
pt2 P1() {return P1(0,0); };                                                                            // make point (0,0)
pt2 P1(float x, float y) {return new pt2(x,y); };                                                       // make point (x,y)
pt2 P1(pt2 P) {return P1(P.x,P.y); };                                                                    // make copy of point A
pt2 Mouse1() {return P1(mouseX,mouseY);};                                                                 // returns point at current mouse location
pt2 Pmouse1() {return P1(pmouseX,pmouseY);};                                                              // returns point at previous mouse location
pt2 ScreenCenter1() {return P1(width/2,height/2);}                                                        //  point in center of  canvas

// display 
void show(pt2 P, float r) {ellipse(P.x, P.y, 2*r, 2*r);};                                             // draws circle of center r around P
void show(pt2 P) {ellipse(P.x, P.y, 6,6);};                                                           // draws small circle around point
void edge(pt2 P, pt2 Q) {line(P.x,P.y,Q.x,Q.y); };                                                      // draws edge (P,Q)
void arrow(pt2 P, pt2 Q) {arrow(P,V(P,Q)); }                                                            // draws arrow from P to Q
void label(pt2 P, String S) {text(S, P.x-4,P.y+6.5); }                                                 // writes string S next to P on the screen ( for example label(P[i],str(i));)
void label(pt2 P, vec2 V, String S) {text(S, P.x-3.5+V.x,P.y+7+V.y); }                                  // writes string S at P+V
void v(pt2 P) {vertex(P.x,P.y);};                                                                      // vertex for drawing polygons between beginShape() and endShape()
void show(pt2 P, pt2 Q, pt2 R) {beginShape(); v(P); v(Q); v(R); endShape(CLOSE); };                      // draws triangle 

// transform 
pt2 R(pt2 Q, float a) {float dx=Q.x, dy=Q.y, c=cos(a), s=sin(a); return new pt2(c*dx+s*dy,-s*dx+c*dy); };  // Q rotated by angle a around the origin
pt2 R(pt2 Q, float a, pt2 C) {float dx=Q.x-C.x, dy=Q.y-C.y, c=cos(a), s=sin(a); return P1(C.x+c*dx-s*dy, C.y+s*dx+c*dy); };  // Q rotated by angle a around point P
pt2 P1(pt2 P, vec2 V) {return P1(P.x + V.x, P.y + V.y); }                                                 //  P+V (P transalted by vec2tor V)
pt2 P1(pt2 P, float s, vec2 V) {return P1(P,W(s,V)); }                                                    //  P+sV (P transalted by sV)
pt2 MoveByDistanceTowards(pt2 P, float d, pt2 Q) { return P1(P,d,U(V(P,Q))); };                          //  P+dU(PQ) (transLAted P by *distance* s towards Q)!!!

// average 
pt2 P1(pt2 A, pt2 B) {return P1((A.x+B.x)/2.0,(A.y+B.y)/2.0); };                                          // (A+B)/2 (average)
pt2 P1(pt2 A, pt2 B, pt2 C) {return P1((A.x+B.x+C.x)/3.0,(A.y+B.y+C.y)/3.0); };                            // (A+B+C)/3 (average)
pt2 P1(pt2 A, pt2 B, pt2 C, pt2 D) {return P1(P1(A,B),P1(C,D)); };                                            // (A+B+C+D)/4 (average)

// weighted average 
pt2 P1(float a, pt2 A) {return P1(a*A.x,a*A.y);}                                                      // aA  
pt2 P1(float a, pt2 A, float b, pt2 B) {return P1(a*A.x+b*B.x,a*A.y+b*B.y);}                              // aA+bB, (a+b=1) 
pt2 P1(float a, pt2 A, float b, pt2 B, float c, pt2 C) {return P1(a*A.x+b*B.x+c*C.x,a*A.y+b*B.y+c*C.y);}   // aA+bB+cC 
pt2 P1(float a, pt2 A, float b, pt2 B, float c, pt2 C, float d, pt2 D){return P1(a*A.x+b*B.x+c*C.x+d*D.x,a*A.y+b*B.y+c*C.y+d*D.y);} // aA+bB+cC+dD 
     
// barycentric coordinates and transformations
float m(pt2 A, pt2 B, pt2 C) {return (B.x-A.x)*(C.y-A.y) - (B.y-A.y)*(C.x-A.x); }
float a(pt2 P, pt2 A, pt2 B, pt2 C) {return m(P,B,C)/m(A,B,C); }
float b(pt2 P, pt2 A, pt2 B, pt2 C) {return m(A,P,C)/m(A,B,C); }
float c(pt2 P, pt2 A, pt2 B, pt2 C) {return m(A,B,P)/m(A,B,C); }

// measure 
boolean isSame(pt2 A, pt2 B) {return (A.x==B.x)&&(A.y==B.y) ;}                                         // A==B
boolean isSame(pt2 A, pt2 B, float e) {return ((abs(A.x-B.x)<e)&&(abs(A.y-B.y)<e));}                   // ||A-B||<e
float d(pt2 P, pt2 Q) {return sqrt(d2(P,Q));  };                                                       // ||AB|| (Distance)
float d2(pt2 P, pt2 Q) {return sq(Q.x-P.x)+sq(Q.y-P.y); };                                             // AB*AB (Distance squared)

//************************************************************************
//**** VECTORS
//************************************************************************
// create 
vec2 V(vec2 V) {return new vec2(V.x,V.y); };                                                             // make copy of vec2tor V
vec2 V(pt2 P) {return new vec2(P.x,P.y); };                                                              // make vec2tor from origin to P
vec2 V(float x, float y) {return new vec2(x,y); };                                                      // make vec2tor (x,y)
vec2 V(pt2 P, pt2 Q) {return new vec2(Q.x-P.x,Q.y-P.y);};                                                 // PQ (make vec2tor Q-P from P to Q
vec2 U(vec2 V) {float n = n(V); if (n==0) return new vec2(0,0); else return new vec2(V.x/n,V.y/n);};      // V/||V|| (Unit vec2tor : normalized version of V)
vec2 U(pt2 P, pt2 Q) {return U(V(P,Q));};                                                                // PQ/||PQ| (Unit vec2tor : from P towards Q)
vec2 MouseDrag1() {return new vec2(mouseX-pmouseX,mouseY-pmouseY);};                                      // vec2tor representing recent mouse displacement

// display 
void show(pt2 P, vec2 V) {line(P.x,P.y,P.x+V.x,P.y+V.y); }                                              // show V as line-segment from P 
void show(pt2 P, float s, vec2 V) {show(P,S(s,V));}                                                     // show sV as line-segment from P 
void arrow(pt2 P, float s, vec2 V) {arrow(P,S(s,V));}                                                   // show sV as arrow from P 
void arrow(pt2 P, vec2 V, String S) {arrow(P,V); P1(P1(P,0.70,V),15,R(U(V))).label(S,V(-5,4));}       // show V as arrow from P and print string S on its side
void arrow(pt2 P, vec2 V) {show(P,V);  float n=n(V); if(n<0.01) return; float s=max(min(0.2,20./n),6./n);       // show V as arrow from P 
     pt2 Q=P1(P,V); vec2 U = S(-s,V); vec2 W = R(S(.3,U)); beginShape(); v(P1(P1(Q,U),W)); v(Q); v(P1(P1(Q,U),-1,W)); endShape(CLOSE);}; 

// weighted sum 
vec2 W(float s,vec2 V) {return V(s*V.x,s*V.y);}                                                      // sV
vec2 W(vec2 U, vec2 V) {return V(U.x+V.x,U.y+V.y);}                                                   // U+V 
vec2 W(vec2 U,float s,vec2 V) {return W(U,S(s,V));}                                                   // U+sV
vec2 W(float u, vec2 U, float v, vec2 V) {return W(S(u,U),S(v,V));}                                   // uU+vV ( Linear combination)

// transformed 
vec2 R(vec2 V) {return new vec2(-V.y,V.x);};                                                             // V turned right 90 degrees (as seen on screen)
vec2 R(vec2 V, float a) {float c=cos(a), s=sin(a); return(new vec2(V.x*c-V.y*s,V.x*s+V.y*c)); };                                     // V rotated by a radians
vec2 S(float s,vec2 V) {return new vec2(s*V.x,s*V.y);};                                                  // sV
vec2 Reflection(vec2 V, vec2 N) { return W(V,-2.*dot(V,N),N);};                                          // reflection
vec2 M(vec2 V) { return V(-V.x,-V.y); }                                                                  // -V


// measure 
float dot(vec2 U, vec2 V) {return U.x*V.x+U.y*V.y; }                                                     // dot(U,V): U*V (dot product U*V)
float det(vec2 U, vec2 V) {return U.x*V.y-U.y*V.x; }                                                         // det | U V | = scalar cross UxV 
float n(vec2 V) {return sqrt(dot(V,V));};                                                               // n(V): ||V|| (norm: length of V)
float n2(vec2 V) {return dot(V,V);};                                                             // n2(V): V*V (norm squared)
boolean parallel (vec2 U, vec2 V) {return dot(U,R(V))==0; }; 

float angle (vec2 U, vec2 V) {return atan2(det(U,V),dot(U,V)); };                                   // angle <U,V> (between -PI and PI)
float angle(vec2 V) {return(atan2(V.y,V.x)); };                                                       // angle between <1,0> and V (between -PI and PI)
float angle(pt2 A, pt2 B, pt2 C) {return  angle(V(B,A),V(B,C)); }                                       // angle <BA,BC>
float turnAngle(pt2 A, pt2 B, pt2 C) {return  angle(V(A,B),V(B,C)); }                                   // angle <AB,BC> (positive when right turn as seen on screen)
int toDeg(float a) {return int(a*180/PI);}                                                           // convert radians to degrees
float toRad(float a) {return(a*PI/180);}                                                             // convert degrees to radians 
float positive1(float a) { if(a<0) return a+TWO_PI; else return a;}                                   // adds 2PI to make angle positive


//************************************************************************
//**** INTERPOLATION
//************************************************************************
// LERP
pt2 L(pt2 A, pt2 B, float t) {return P1(A.x+t*(B.x-A.x),A.y+t*(B.y-A.y));}

