//Variable to store current mode - 1- for 2D and 2- for 3D, initially it will be 2D; can be changed by pressing 'e'
int mode = 1;

boolean pick = false;

color [] swatch = new int []{
#ED1C24, #FFF100, #00A550, #00ADEF, #2E3092, #EC008B, #BE1E2D, #EF4036, #F05A28, #F7931D, #FBAF3F, #F8ED31, #D6DF23, #8CC63E, #009344, #006738, #2AB573, #00A79D, #27A9E1, #1B75BB, #2A388F, #262261, #652C90, #91268F, #9E1E62, #D91B5B, #ED2A7B
};

pts CP = new pts(); //corners' positions
//int[][]F = new int[50][50];
int[] nFc = new int[50];
int nF = 0;//number of faces



float dz=0; // distance to camera. Manipulated with wheel or when 
float rx=-0.06*TWO_PI, ry=-0.04*TWO_PI;    // view angles manipulated when space pressed but not mouse
Boolean twistFree=false, animating=false, center=true, showControlPolygon=true, showFloor=false;
float t=0, s=0;
pt F = P(0,0,0);  // focus point:  the camera is looking at it (moved when 'f or 'F' are pressed
pt O=P(100,100,0); // red point controlled by the user via mouseDrag : used for inserting vertices ...
int[][] C = new int[1000][5]; //0 - stores V, 1 - stores N, 2 - stores S, 3 - stores Deleted, 4 - stores Visited
int PnV = 0; // number of vertices
int CnV = 0; //number of corners

int n_loops = 0; //stores number of loops
int[][] connections = new int[50][2]; //stores connecting corners / 3D vertices indices; its length would be equal to n_loops 


//variables for 2d drawing mode
pt2 mStart,mEnd;
int nC,nG;
pt2[] G = new pt2[50];
int[] Vd = new int[50]; //stores whether a vertex is deleted or not
int[][] C1 = new int[100][5];
pt2[] CP1 = new pt2[50]; //corners' positions
boolean isNewSVertex= true;
boolean drag = false;
boolean closest = false;
boolean face = false;
boolean isNewEVertex = true;
boolean isOnEdge = false;
boolean isOnVertex = true;
boolean[] smooth = new boolean[1000]; //to keep track of which corners have been smoothened
boolean[] concave = new boolean[1000];
boolean[] concave3D = new boolean[1000];
int SVI = 0, EVI=0; //starting vertex id and end vertex id (in case new edge is created from an existing vertex and/or dropped on an existing vertex

pt2 Cu;

void setup() {
  myFace = loadImage("data/Mypic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  P.declare(); Q.declare(); PtQ.declare(); // P is a polyloop in 3D: declared in pts
  size(600,600,P3D);
  noSmooth();
  for(int i = 0; i<1000;i++)
  {concave[i] = false;concave3D[i] = false;}
  if(mode == 1) //2D mode
  { mEnd = new pt2(mouseX, mouseY);
  mStart = Mouse1();
  nG = 0;
  nC= 0;
  }
  else
  {
     P.resetOnCircle(12,100); // used to get started if no model exists on file 
 // P.loadPts("data/pts");  // loads saved model from file
  
  Q.loadPts("data/pts2");  // loads saved model from file
  resetCorners();
  setCorners();
  Q.extruded();
  CP.declare();
  }  
}




void resetCorners(){
  CnV=0;
  for(int i=0;i<1000;i++)
  {
    for(int j = 0;j<5;j++)
    C[i][j] =0;
  }
}
  
  
void setCorners() {
  int start,end;
  PnV = Q.len();
//CnV = PnV*6; //6 corners for every vertex
int nC = 0; //Corner counter
  int n2Dv = 0; //2D vertices counter
  
for(int j = 0;j<n_loops;j++)
{
  if(n_loops == 1)
    end = PnV;
  else
  {
    if(j!=n_loops-1)    end = connections[j][1];
    else                end = PnV;   
  }
  if(j == 0)
    start = 0;
  else
    start = connections[j-1][1];
CnV = end*6;
println("start :"+start+" end: "+end);
for(int i = start;i<end;i++)
{
  C[nC][0] = i;
  C[nC+1][0] = i;
  C[nC+2][0] = i;
  C[nC+3][0] = PnV+i;
  C[nC+4][0] = PnV+i;
  C[nC+5][0] = PnV+i;
  if(concave[n2Dv] == true)
   { concave3D[nC+2] = concave3D[nC+3] = true;}
  n2Dv++;
  if(i == start)
  {
  C[nC][1] = nC+7;
  C[nC+1][1] = nC+4;
  C[nC+2][1] = CnV-4;
  C[nC+3][1] = nC+9;
  C[nC+4][1] = CnV-1;
  C[nC+5][1] = nC;
  }
  else if(i == end-1)
  {
    C[nC][1] = (start*6)+1;
    C[nC+1][1] = nC+4;
    C[nC+2][1] = nC-4;
    C[nC+3][1] = (start*6)+3;
    C[nC+4][1] = nC-1;
    C[nC+5][1] = nC;
  }
  else
  {
    C[nC][1] = nC+7;
    C[nC+1][1] = nC+4;
    C[nC+2][1] = nC-4;
    C[nC+3][1] = nC+9;
    C[nC+4][1] = nC-1;
    C[nC+5][1] = nC;
  }
  
  C[nC][2] = nC+1;
  C[nC+1][2] = nC+2;
  C[nC+2][2] = nC;
  C[nC+3][2] = nC+4;
  C[nC+4][2] = nC+5;
  C[nC+5][2] = nC+3;
  nC+=6; 
}
}

//set bridges now
for(int j = 0;j<n_loops-1;j++)
{
  //add two corners in floor
  int Ci1 = connections[j][0];
  int Ci2 = connections[j][1];
  C[nC][0] = Ci1;
  C[nC+1][0] = Ci2;
  
  C[nC][1] = C[(Ci1*6)+2][1];
  C[nC+1][1] = C[(Ci2*6)+2][1];
  
  C[(Ci1*6)+2][1] = nC+1;
  C[(Ci2*6)+2][1] = nC;
  
  C[nC][2] = C[(Ci1*6)+2][2];
  C[nC+1][2] = C[(Ci2*6)+2][2];
  
  C[(Ci1*6)+2][2] = nC;
  C[(Ci2*6)+2][2] = nC+1;
  
//add two corners in ceiling
//  int Ci3 = connections[j][0];
 // int Ci4 = connections[j][1]+PnV;
  C[nC+2][0] = Ci1+PnV;
  C[nC+3][0] = Ci2+PnV;
  
  C[nC+2][1] = C[(Ci1*6)+3][1];
  C[nC+3][1] = C[(Ci2*6)+3][1];
  
  C[(Ci1*6)+3][1] = nC+3;
  C[(Ci2*6)+3][1] = nC+2;
  
  C[nC+2][2] = C[(Ci1*6)+3][2];
  C[nC+3][2] = C[(Ci2*6)+3][2];
  
  C[(Ci1*6)+3][2] = nC+2;
  C[(Ci2*6)+3][2] = nC+3;
    nC+=4;
  
}
CnV = nC;
println("CnV: "+CnV);
saveCornersToFile("data/corners");

}

void saveCornersToFile(String fn) {
  String [] inppts = new String [CnV+1];
  int s=0;
  inppts[s++]=str(CnV);
  for (int i=0; i<CnV; i++) {inppts[s++]=str(C[i][0])+","+str(C[i][1])+","+str(C[i][2]);}
  saveStrings(fn,inppts);
  };


void drawCorners() {
  CP.nv = CnV;
 for(int j = 0; j<CnV; j++)
 {
   if(C[j][3]!=1)
   {
  if(C[j][1]==-1)
      {
    fill(black); stroke(black); show(P(Q.G[C[j][0]].x-8,Q.G[C[j][0]].y+14,Q.G[C[j][0]].z),2);
    fill(black);  //text("C"+j,Q.G[C[j][0]].x-8,Q.G[C[j][0]].y+14);
    CP.G[j] = P(Q.G[C[j][0]].x-8,Q.G[C[j][0]].y+14,Q.G[C[j][0]].z);
    }
   else
   {
     if(C[j][2] == -1)
     {fill(black); stroke(black); vec Edge = V(Q.G[C[C[j][1]][0]],Q.G[C[j][0]]); pt Cp = P(Q.G[C[j][0]]);
     Cp.add(30,U(Edge)); 
     show(Cp,1.5);
     fill(black); // text("C"+j,Cp.x-8,Cp.y+14);
     CP.G[j] = P(Cp.x, Cp.y,Cp.z);
     }
     else
     {
      // if(concave3D[j] == false)
       //{
         fill(black); stroke(black); 
       vec Edge1 = U(V(Q.G[C[j][0]],Q.G[C[C[j][1]][0]])); 
       vec Edge2 = U(V(Q.G[C[C[j][2]][0]],Q.G[C[C[C[j][2]][1]][0]]));
       pt Cp = P(Q.G[C[j][0]]);
       //println(angle(Edge1,Edge2));
       Cp.add(20,R(Edge1, 0.5*(angle(Edge1,Edge2)),Edge1,Edge2)); 
       show(Cp,2);
       fill(black); // text("C"+j,Cp.x-8,Cp.y+14);
       CP.G[j] = P(Cp.x, Cp.y,Cp.z);
       //}
       /*else
       {
       //  println("entered for j: "+j);
         fill(black); stroke(black); 
       vec Edge1 = U(V(Q.G[C[j][0]],Q.G[C[C[j][1]][0]])); 
       vec Edge2 = U(V(Q.G[C[C[j][2]][0]],Q.G[C[C[C[j][2]][1]][0]]));
       //vec sub = Edge1.sub(Edge2);
       pt Cp = P(Q.G[C[j][0]]);
       //println(angle(Edge1,Edge2));
       Cp.add(20,R(Edge2, 0.5*(angle(Edge2,Edge1)),Edge1,Edge2)); 
       show(Cp,2);
       fill(black); // text("C"+j,Cp.x-8,Cp.y+14);
       CP.G[j] = P(Cp.x, Cp.y,Cp.z);
       }*/
    }
   }
  }
 }
}


void drawFaces()
{
  
nF=0; 
int cI =0; //cI = color index
  for(int i = 0; i<CnV;i++)
    C[i][4] = 0;
  for(int i = 0; i<CnV;i++)
  {
    if(C[i][4] !=1) // not visited
    {
    if(C[i][3]!=1) // not deleted
    {
      if(C[i][1]== -1)
        nF = 1;
      else
      {
        int CurCorner = i;
         stroke(swatch[cI]); strokeWeight(1.5); 
         beginShape();
     do
    {
        v(CP.G[CurCorner]);
        C[CurCorner][4] = 1;
        CurCorner = C[CurCorner][1];
    } while(CurCorner!=i);
    endShape(CLOSE);
         nF++; cI++;
         if(cI>swatch.length)
           cI = 0;
    }
    }
    }

 // println("Number of faces: "+nF);
}

}


void draw() {
  
  if(mode == 1)
  {
   background(white); // clear screen and paints white background
  

  if (mousePressed) {fill(white); stroke(red); showDisk(mouseX,mouseY,16);} // paints a red disk filled with white if mouse pressed
  if (keyPressed) {fill(black); text(key,mouseX-2,mouseY); } // writes the character of key if still pressed
  if (!mousePressed && !keyPressed) scribeMouseCoordinates(); // writes current mouse coordinates if nothing pressed
  
  displayHeader();
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if(filming && (animating || change)) saveFrame("FRAMES/"+nf(frameCounter++,4)+".tif");  
  

//drawing edges using active corners
pen(black,2.5); // sets stroke color (to balck) and width (to 3 pixels)
//fill(white); stroke(black); beginShape();
for(int j = 0; j<nC;j++)
{
 if(C1[j][1]!=-1 && C1[j][3]!=1)
 {
 draw2DLine(black,G[C1[j][0]],G[C1[C1[j][1]][0]],1);
// v(G[C1[j][0]]);
 //v(G[C1[C1[j][1]][0]]);
 }
}
//endShape();

for(int i=0;i<nG;i++)
{ if(Vd[i]!=1)
{
  //fill(black); stroke(black); show(P(Q.G[C[j][0]].x-8,Q.G[C[j][0]].y+14,Q.G[C[j][0]].z),2);
 fill(white); stroke(black); strokeWeight(2.5); showDisk(G[i].x,G[i].y,12); 
 if(i+1<10){
   fill(black); text(i+1,G[i].x-3,G[i].y+4);
 }
 else{
   fill(black); text(i+1,G[i].x-7,G[i].y+4);
 }
}
}

for(int j = 0; j<nC;j++)
{
draw2DCorners();
}

if(drag == true)
  draw2DMouseLine();
if(closest == true){
    float cl = 10000;
    Cu = P1(mouseX, mouseY);
    int clIndex=0;
   
    for(int i=0; i<nC; i++){
      if(cl > d(CP1[i], Cu) && C1[i][3]!=1){
        cl = d(CP1[i], Cu);
        clIndex = i;
      }
    }
    if(nC>0){
      fill(red); stroke(red); showDisk(CP1[clIndex].x,CP1[clIndex].y,4);
    }
    if(C1[clIndex][1]!=-1 && nC>0){
      fill(blue); stroke(blue); showDisk(CP1[C1[clIndex][1]].x,CP1[C1[clIndex][1]].y,4);
    }
    if(C1[clIndex][2]!=-1 && nC>0){
      fill(green); stroke(green); showDisk(CP1[C1[clIndex][2]].x,CP1[C1[clIndex][2]].y,4);
    }
  }  
if(face==true){
nF=0;
  for(int i = 0; i<nC;i++)
    C1[i][4] = 0;
  for(int i = 0; i<nC;i++)
  {
    if(C1[i][4] !=1) // not visited
    {
    if(C1[i][3]!=1) // not deleted
    {
      if(C1[i][1]== -1)
        nF = 1;
      else
      {
        int CurCorner = i;
     do
    {
      pt2 newPa = P1(0,0);
      pt2 newPb = P1(0,0);
      vec2 v = V(0,0);
      vec2 u = V(0,0);
      if(C1[C1[CurCorner][1]][2]==-1){
        v = V(G[C1[CurCorner][0]],G[C1[C1[CurCorner][1]][0]]);
        newPa = P1(CP1[CurCorner]);
        newPa = P1(newPa,v);
        stroke(swatch[nF]); strokeWeight(1.5); edge(CP1[CurCorner],newPa);
        stroke(swatch[nF]); strokeWeight(1.5); edge(newPa, CP1[C1[CurCorner][1]]);
        C1[CurCorner][4] = 1;
      }
      if(C1[CurCorner][2]==-1){
        u = V(G[C1[C1[CurCorner][1]][0]],G[C1[CurCorner][0]]);
        newPb = P1(CP1[C1[CurCorner][1]]);
        newPb = P1(newPb,u);
        stroke(swatch[nF]); strokeWeight(1.5); edge(CP1[CurCorner],newPb);
        stroke(swatch[nF]); strokeWeight(1.5); edge(newPb, CP1[C1[CurCorner][1]]);
        C1[CurCorner][4] = 1;
      }
      if(C1[C1[CurCorner][1]][2]!=-1 && C1[CurCorner][2]!=-1){
        stroke(swatch[nF]); strokeWeight(1.5); edge(CP1[CurCorner],CP1[C1[CurCorner][1]]);
        C1[CurCorner][4] = 1;
      }
      CurCorner = C1[CurCorner][1];
    } while(CurCorner!=i);
         nF++;
    }
    }
    }
  }
  println("Number of faces: "+nF);
}



  }
  else
  {
    background(255);
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
    camera();       // sets a standard perspective
    translate(width/2,height/2,dz); // puts origin of model at screen center and moves forward/away by dz
    lights();  // turns on view-dependent lighting
    rotateX(rx); rotateY(ry); // rotates the model around the new origin (center of screen)
    rotateX(PI/2); // rotates frame around X to make X and Y basis vectors parallel to the floor
   if(center) translate(-F.x,-F.y,-F.z);
    noStroke(); // if you use stroke, the weight (width) of it will be scaled with you scaleing factor

  
 /*   if(showFloor) {
      //showFrame(50); // X-red, Y-green, Z-blue arrows
      fill(yellow); pushMatrix(); translate(0,0,-1.5); box(400,400,1); popMatrix(); // draws floor as thin plate
      fill(magenta); show(F,4); // magenta focus point (stays at center of screen)
      fill(magenta,100); showShadow(F,5); // magenta translucent shadow of focus point (after moving it up with 'F'
      if(showControlPolygon) {
        pushMatrix(); 
        fill(grey,100); scale(1,1,0.01); Q.drawClosedCurveAsRods(4); 
        Q.drawBalls(4); 
        popMatrix();} // show floor shadow of polyloop
      }
    fill(black); show(O,4); fill(red,100); showShadow(O,5); // show red tool point and its shadow
*/
    computeProjectedVectors(); // computes screen projections I, J, K of basis vectors (see bottom of pv3D): used for dragging in viewer's frame    
    pp=Q.idOfVertexWithClosestScreenProjectionTo(Mouse()); // id of vertex of P with closest screen projection to mouse (us in keyPressed 'x'...


  /*  if(showControlPolygon) {
      //fill(green); P.drawClosedCurveAsRods(4); P.drawBalls(4); // draw curve P as cones with ball ends
      fill(red); Q.drawClosedCurveAsRods(4); Q.drawBalls(4); // draw curve Q
      //fill(green,100); P.drawBalls(5); // draw semitransluent green balls around the vertices
      fill(grey,100); show(Q.closestProjectionOf(O),6); // compputes and shows the closest projection of O on P
      fill(red,100); Q.showPicked(6); // shows currently picked vertex in red (last key action 'x', 'z'
      }
  */
  // replace the following 2 lines by display of the extrucded polygonal model
  fill(cyan); stroke(blue); showWalls();  
  noStroke(); //fill(yellow); P.drawClosedLoop(); 
  fill(yellow); stroke(red); drawCeiling();
  fill(orange); stroke(red); drawFloor();
  
  drawCorners();
  noFill(); drawFaces();
  if(pick == true)
  {
  int pickIndex = pickCorner(pick(mouseX,mouseY));
  pt picked = CP.G[pickIndex]; stroke(red);fill(red); show(picked,3); //current in red
  pt Npicked = CP.G[C[pickIndex][1]]; stroke(blue);fill(blue); show(Npicked,3); //next in blue
  pt Spicked = CP.G[C[pickIndex][2]]; stroke(green);fill(green); show(Spicked,3); //swing in green
}
  
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  
  
  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX,mouseY,26,26); fill(red); text(key,mouseX-5,mouseY+4);}
    // for demos: shows the mouse and the key pressed (but it may be hidden by the 3D model)
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if (animating) { t+=PI/180*2; if(t>=TWO_PI) t=0; s=(cos(t)+1.)/2; } // periodic change of time 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  } 

}

  
void draw2DMouseLine() {
  vec2 v = V(mStart, mEnd);
  draw2DLine(yellow, mStart, P1(mStart, v), 1); 
}

void draw2DCorners() {
 // println("nC: "+nC);
 for(int j = 0; j<nC; j++)
 {
   //if(j == 2)
   //break;
   if(C1[j][3]!=1)
   {
  if(C1[j][1]==-1)
      {
        //println("entered here....");
    fill(black); stroke(black); showDisk(G[C1[j][0]].x-8,G[C1[j][0]].y+14,2);
    fill(black);  text("C"+j,G[C1[j][0]].x-8,G[C1[j][0]].y+14);
    CP1[j] = P1(G[C1[j][0]].x-8,G[C1[j][0]].y+14);
    }
   else
   {
     if(C1[j][2] == -1)
     {
       //println("here & j: " +j);
       fill(black); stroke(black); vec2 Edge = V(G[C1[C1[j][1]][0]],G[C1[j][0]]); pt2 Cp = P1(G[C1[j][0]]);
     Cp.add(12,U(Edge)); 
     showDisk(Cp.x,Cp.y,1.5);
     fill(black);  text("C"+j,Cp.x-8,Cp.y+14);
     CP1[j] = P1(Cp.x, Cp.y);
     }
     else
     {
       
      /* if(C1[j][2] == -2 || smooth[j]== true) //smoothened already so, just draw
       {
        // println("smoothened already called for j: "+j);
         
         //println("cp1[j].x: "+CP1[j].x);
         showDisk(CP1[j].x,CP1[j].y,1.5);
        // break;

       }
       else                // not smoothened, so smoothen it and then draw
       {
         println("not smooth called for j: "+j);
         fill(black); stroke(black); 
       vec2 Edge1 = U(V(G[C1[j][0]],G[C1[C1[j][1]][0]])); 
       int nswing=C1[j][2];
       if(C1[C1[j][2]][2] ==-2)
       {
         while(C1[nswing][2]!=-2)
         {
           nswing = C1[nswing][1];
         }
       }
         
       vec2 Edge2 = U(V(G[C1[nswing][0]],G[C1[C1[nswing][1]][0]]));
       println(positive1(angle(Edge1,Edge2)));
       //pt2 Cp = P1(G[C1[j][0]]);
       //println(positive1(angle(Edge1,Edge2)));
       //Cp.add(12,R(Edge1, 0.5*positive1(angle(Edge1,Edge2)))); 
       //Cp.add(30,R(Edge1, 0.5*(angle(Edge1,Edge2))));
       //showDisk(Cp.x,Cp.y,1.5);
       if(positive1(angle(Edge1,Edge2)) > 3.2)
       {
         println("Entered 1");
       pt2 temp1 = P1(G[C1[j][0]]);
       temp1.add(12,R(Edge1, 0.25*positive1(angle(Edge1,Edge2))));
       showDisk(temp1.x,temp1.y,1.5);
       C1[nC][0] = C1[j][0];
       C1[nC][1] = C1[j][1];
       C1[nC][2] = C1[j][2];
       CP1[nC] = P1(temp1.x,temp1.y);
       smooth[nC] = true;
       pt2 temp2 = P1(G[C1[j][0]]);
       temp2.add(12,R(Edge1, 0.40*positive1(angle(Edge1,Edge2))));
       showDisk(temp2.x,temp2.y,1.5);
       C1[nC+1][0] = C1[j][0];
       C1[nC+1][1] = nC;
       C1[nC+1][2] = -2;
       CP1[nC+1] = P1(temp2.x,temp2.y);
       smooth[nC+1] = true;
       pt2 temp3 = P1(G[C1[j][0]]);
       temp3.add(12,R(Edge1, 0.55*positive1(angle(Edge1,Edge2))));
       showDisk(temp3.x,temp3.y,1.5);
       C1[nC+2][0] = C1[j][0];
       C1[nC+2][1] = nC+1;
       C1[nC+2][2] = -2;
       CP1[nC+2] = P1(temp3.x,temp3.y);
       smooth[nC+2] = true;
       pt2 temp4 = P1(G[C1[j][0]]);
       temp4.add(12,R(Edge1, 0.75*positive1(angle(Edge1,Edge2))));
       showDisk(temp4.x,temp4.y,1.5);
       C1[j][1] = nC+2;
       C1[j][2] = -2;
       CP1[j] = P1(temp4.x,temp4.y);
       smooth[j] = true;
      // j+=3;
      nC+=3;       
     }
       else if(positive1(angle(Edge1,Edge2)) < 3.0)
       {
         println("Entered 2 & C1[j][0]: "+ C1[j][0]+" &j: "+j);
       pt2 temp1 = P1(G[C1[j][0]]);
       temp1.add(16,R(Edge1, 0.25*positive1(angle(Edge1,Edge2))));
       showDisk(temp1.x,temp1.y,1.5);
       C1[nC][0] = C1[j][0];
       C1[nC][1] = C1[j][1];
       C1[nC][2] = C1[j][2];
       CP1[nC] = P1(temp1.x,temp1.y);
       smooth[nC] = true;
       pt2 temp2 = P1(G[C1[j][0]]);
       temp2.add(13,R(Edge1, 0.40*positive1(angle(Edge1,Edge2))));
       showDisk(temp2.x,temp2.y,1.5);
       C1[nC+1][0] = C1[j][0];
       C1[nC+1][1] = nC;
       C1[nC+1][2] = -2;
       CP1[nC+1] = P1(temp2.x,temp2.y);
       smooth[nC+1] = true;
       pt2 temp3 = P1(G[C1[j][0]]);
       temp3.add(12.3,R(Edge1, 0.55*positive1(angle(Edge1,Edge2))));
       showDisk(temp3.x,temp3.y,1.5);
       C1[nC+2][0] = C1[j][0];
       C1[nC+2][1] = nC+1;
       C1[nC+2][2] = -2;
       CP1[nC+2] = P1(temp3.x,temp3.y);
    smooth[nC+2] = true;
       pt2 temp4 = P1(G[C1[j][0]]);
       temp4.add(16,R(Edge1, 0.75*(angle(Edge1,Edge2))));
       showDisk(temp4.x,temp4.y,1.5);
       C1[j][1] = nC+2;
       C1[j][2] = -2;
       CP1[j] = P1(temp4.x,temp4.y);
       smooth[j] = true;
      // j+=3;
      nC+=3; 
     //println("new nC: "+nC); 
     }
       else
       {*/
       fill(black); stroke(black); 
       vec2 Edge1 = U(V(G[C1[j][0]],G[C1[C1[j][1]][0]]));
       vec2 Edge2 = U(V(G[C1[C1[j][2]][0]],G[C1[C1[C1[j][2]][1]][0]]));
       if(positive1(angle(Edge1,Edge2)) > 3.14)
         concave[j] = true;
         pt2 Cp = P1(G[C1[j][0]]);
       Cp.add(20,R(Edge1, 0.5*positive1(angle(Edge1,Edge2)))); 
       showDisk(Cp.x,Cp.y,1.5);
     fill(black);  text("C"+j,Cp.x-8,Cp.y+14);
       CP1[j] = P1(Cp.x, Cp.y);
         
     //}
     //  }
    }
   }
  }
 }
}


void draw2DLine(int stroke, pt2 lineStart, pt2 lineEnd, float alpha) {
    stroke(stroke, alpha*255);
    edge(lineStart, lineEnd);
}

  
//function to smooth out corners
/*void smoothen()
{
  int CountNew = 0; //count new vertices, start from 0
  for(int j = 0; j<nC;j++)
  {
     fill(black); stroke(black); 
       vec2 Edge1 = U(V(G[C1[j][0]],G[C1[C1[j][1]][0]])); 
       vec2 Edge2 = U(V(G[C1[C1[j][2]][0]],G[C1[C1[C1[j][2]][1]][0]]));
       pt2 Cp = P1(G[C1[j][0]]);
       //println(positive1(angle(Edge1,Edge2)));
       Cp.add(30,R(Edge1, 0.5*positive1(angle(Edge1,Edge2)))); 
       //Cp.add(30,R(Edge1, 0.5*(angle(Edge1,Edge2))));
       showDisk(Cp.x,Cp.y,1.5);
       if(positive1(angle(Edge1,Edge2)) > 3.2)
       {
       pt2 temp1 = P1(G[C1[j][0]]);
       temp1.add(10,R(Edge1, 0.25*positive1(angle(Edge1,Edge2))));
       showDisk(temp1.x,temp1.y,1.5);
       pt2 temp2 = P1(G[C1[j][0]]);
       temp2.add(10,R(Edge1, 0.40*positive1(angle(Edge1,Edge2))));
       showDisk(temp2.x,temp2.y,1.5);
       pt2 temp3 = P1(G[C1[j][0]]);
       temp3.add(10,R(Edge1, 0.55*positive1(angle(Edge1,Edge2))));
       showDisk(temp3.x,temp3.y,1.5);
       pt2 temp4 = P1(G[C1[j][0]]);
       temp4.add(10,R(Edge1, 0.75*positive1(angle(Edge1,Edge2))));
       showDisk(temp4.x,temp4.y,1.5);
       }
       else if(positive1(angle(Edge1,Edge2)) < 3.0)
       {
       pt2 temp1 = P1(G[C1[j][0]]);
       temp1.add(16,R(Edge1, 0.25*positive1(angle(Edge1,Edge2))));
       showDisk(temp1.x,temp1.y,1.5);
       pt2 temp2 = P1(G[C1[j][0]]);
       temp2.add(13,R(Edge1, 0.40*positive1(angle(Edge1,Edge2))));
       showDisk(temp2.x,temp2.y,1.5);
       pt2 temp3 = P1(G[C1[j][0]]);
       temp3.add(12.5,R(Edge1, 0.55*positive1(angle(Edge1,Edge2))));
       showDisk(temp3.x,temp3.y,1.5);
       pt2 temp4 = P1(G[C1[j][0]]);
       temp4.add(16,R(Edge1, 0.75*(angle(Edge1,Edge2))));
       showDisk(temp4.x,temp4.y,1.5);
       }
       fill(black);  text("C"+j,Cp.x-8,Cp.y+14);
       CP1[j] = P1(Cp.x, Cp.y);
  }
}  */
 
  
void keyPressed() {
  if(key=='?') scribeText=!scribeText;
  if(key=='!') snapPicture();
  if(key=='~') filming=!filming;
  if(key==']') showControlPolygon=!showControlPolygon;
  if(key=='0') P.flatten();
  if(key=='_') showFloor=!showFloor;
  if(key=='q') Q.copyFrom(P);
  if(key=='p') P.copyFrom(Q);
  if(key=='e') {PtQ.copyFrom(Q);Q.copyFrom(P);P.copyFrom(PtQ);}
  if(key=='.') F=P.Picked(); // snaps focus F to the selected vertex of P (easier to rotate and zoom while keeping it in center)
  if(key=='x' || key=='z' || key=='d') P.setPickedTo(pp); // picks the vertex of P that has closest projeciton to mouse
  if(key=='d') P.deletePicked();
  if(key=='i') P.insertClosestProjection(O); // Inserts new vertex in P that is the closeset projection of O
  if(key=='W') {P.savePts("data/pts"); Q.savePts("data/pts2");}  // save vertices to pts2
  if(key=='L') {P.loadPts("data/pts"); Q.loadPts("data/pts2");}   // loads saved model
  if(key=='w') P.savePts("data/pts");   // save vertices to pts
  if(key=='l') P.loadPts("data/pts"); 
  if(key=='a') animating=!animating; // toggle animation
  
  //if(key == 's') smoothen();
  
  if(key == 'm')pick =true;
  
  if(key=='q')if(mode==1){mode=2;
    //size(600, 600, P3D); // p3D means that we will do 3D graphics
   P.resetOnCircle(12,100); // used to get started if no model exists on file 
 // P.loadPts("data/pts");  // loads saved model from file
  
 // Q.loadPts("data/pts2");  // loads saved model from file
  println("Create model called");
  createModel();
 
  println("model creation successful");
  resetCorners();
  println("Corners resetted");
  setCorners();
  println("Setting corners successful");
  Q.extruded();
  println("Vertices extrusion successful");
  Q.savePts("data/pts3");
  CP.declare();
}else mode=1;
  if(key=='c') closest=true;
  if(key=='f') face = true;
  
  if(key=='#') exit();
  change=true;
  }
  
  
void keyReleased() { // executed each time a key is released
  //if(key=='b') {xb=mouseX; yb=mouseY;}
  if(key=='a') animating=false;  // quit application
  if(key=='c') closest=false;
  if(key=='f') face = false;
  change=true;
  }

  
  void mousePressed() { // when mouse key is pressed 
if(mode ==1)
{
  drag = false;
  change=true;
 isNewSVertex = true;
  mStart = Mouse1();
 if(nG!=0)
 {
   
   for(int i = 0;i<nG;i++)
   {
     if(Vd[i]!=1)
     {
     if(d(mStart,G[i])<12.0)
     {  isNewSVertex = false;
     SVI = i;
       break;
     }
     }
   }
 }
   if(isNewSVertex == true)
   {
     G[nG] = mStart;
     
     C1[nC][0] = nG;
     C1[nC][1] = -1;
     C1[nC][2] = -1;
     nG++;
     nC++;
   }
}
}

void mouseReleased()
{
  if(mode == 1)
  {
  drag = false;
 change = false;
  mEnd = Mouse1();
  isNewEVertex = true;
  int newCorner = -1;
  int newECorner = -1;
  int SVC = 0;
  int EVC = 0;
  int ESI = 0; //edge starting index if drawn on edge
  
if(d(mStart,mEnd)>2)
{
if(nG!=0)
 {
   for(int i = 0;i<nG;i++)
   {
     if(Vd[i]!=1) //check if its not deleted
     {
     if(d(mEnd,G[i])<12.0)
     {  isNewEVertex = false;
       EVI = i;
      // println("End vertex index: "+ EVI);
       break;
     }
   }
   }
 }
   if(isNewEVertex == true)
   {
    
    // println("new end vertex");
     
if(isNewSVertex)
{
  if(CountActiveVertices()<=1)
  {
     G[nG] = mEnd;
  newCorner = nC;
     C1[newCorner][0] = nG;
     C1[newCorner][2] = -1;
     C1[nC-1][1] = newCorner;
     C1[newCorner][1] = nC-1;
     nC++;
     nG++;
  }
  else{
    G[nG-1] = null;
    C1[nC-1][0]=0;
    nG--;
    nC--;
  
  }
}
else //starting from already existing vertex
{
  //ESI = CheckOnEdge(mEnd) ;
 
 
   G[nG] = mEnd;
  newCorner = nC;
    C1[newCorner][0] = nG;
    C1[newCorner][2] = -1;
     
  for(int i=0;i<nC;i++)
  {
   if(C1[i][0]==SVI && C1[i][3]!=1)
  {
    SVC = i;
    if(C1[SVC][2]==-1 )
     {  if(C1[SVC][1]!= -1)
         C1[SVC][2] = nC+1; 
     break;}
    else if(C1[SVC][1]!=-1)
    {
      int StartCorner = SVC;
      do
   {
     if(positive1(angle(V(G[C1[SVC][0]],G[C1[C1[SVC][1]][0]]),V(G[C1[C1[SVC][2]][0]],G[C1[C1[C1[SVC][2]][1]][0]])))> positive1(angle(V(G[C1[SVC][0]],G[C1[C1[SVC][1]][0]]),V(G[C1[SVC][0]],G[C1[newCorner][0]]))))
     {
       println("Got a match");
       break;
     }
     else
       SVC = C1[SVC][2];
   } while(SVC!=StartCorner);
   StartCorner = SVC;
   while(C1[StartCorner][2] !=SVC)
   {  StartCorner = C1[StartCorner][2];}
   C1[StartCorner][2] = nC+1;
   break;
    }
  } 
  
  }
  println("Start Vertex index: "+SVC);
  if(C1[SVC][1] == -1)
  {
    C1[SVC][1] = newCorner;
    C1[newCorner][1] = SVC;
    nC+=1;
  }
  else
  {
    C1[nC+1][0] = C1[SVC][0];
    C1[nC+1][2] = SVC;
    C1[newCorner][1] = nC+1;
    C1[nC+1][1] = C1[SVC][1];
    C1[SVC][1] = newCorner;
    nC+=2;  
   }    
nG++;


}
}

else //End is on an existing vertex
{
 // newECorner = nC;
   
  if(isNewSVertex)
  {
    SVC = nC-1;
    SVI = nG-1;
  }
  else
  {
for(int i=0;i<nC;i++)
  {
   if(C1[i][0]==SVI && C1[i][3]!=1)
  {
    SVC = i;
    break;
  } 
  
  }
  }
  for(int i=0;i<nC;i++)
  {
   if(C1[i][0]==EVI && C1[i][3]!=1)
  {
    EVC = i;
     
    if(C1[EVC][2]==-1)
    {
      //println("No. of corners: "+C[EVC][1]);
      if(C1[EVC][1] !=-1)
         { newECorner = nC;  C1[EVC][2] = newECorner;} 
      break;}
    else if(C1[EVC][1]!=-1)
    {
      newECorner = nC;
      int EndCorner = EVC;
      do
   {
     if(positive1(angle(V(G[C1[EVC][0]],G[C1[C1[EVC][1]][0]]),V(G[C1[C1[EVC][2]][0]],G[C1[C1[C1[EVC][2]][1]][0]])))> positive1(angle(V(G[C1[EVC][0]],G[C1[C1[EVC][1]][0]]),V(G[C1[EVC][0]],G[C1[SVC][0]]))))
     {
       println("Got a match");
       break;
     }
     else
       EVC = C1[EVC][2];
   } while(EVC!=EndCorner);
   EndCorner = EVC;
   while(C1[EndCorner][2] !=EVC)
   {  EndCorner = C1[EndCorner][2];}
   C1[EndCorner][2] = newECorner;
   
   break;
  } 
}
  }
  if(C1[EVC][1]!=-1)
  {
    C1[newECorner][0] = C1[EVC][0];
    C1[newECorner][2] = EVC;}
 if(!isNewSVertex) //assigning proper corner to start vertex (if its not new)
{
  newCorner = nC+1;
    for(int i=0;i<nC;i++)
  {
   if(C1[i][0]==SVI && C1[i][3]!=1)
  {
    SVC = i;
     
    if(C1[SVC][2]==-1)
     {C1[SVC][2] = newCorner; break;}
    else
    {
      int StartCorner = SVC;
      do
   {
     if(positive1(angle(V(G[C1[SVC][0]],G[C1[C1[SVC][1]][0]]),V(G[C1[C1[SVC][2]][0]],G[C1[C1[C1[SVC][2]][1]][0]])))> positive1(angle(V(G[C1[SVC][0]],G[C1[C1[SVC][1]][0]]),V(G[C1[SVC][0]],G[C1[EVC][0]]))))
     {
       println("Got a match");
       break;
     }
     else
       SVC = C1[SVC][2];
   } while(SVC!=StartCorner);
   StartCorner = SVC;
   while(C1[StartCorner][2] !=SVC)
   {  StartCorner = C1[StartCorner][2];}
   C1[StartCorner][2] = newCorner;
   
   break;
  } 
  }
  }
  if(C1[EVC][1]!=-1)
  {
    C1[newCorner][0] = C1[SVC][0];
    C1[newCorner][2] = SVC;
    C1[newECorner][1] = C1[EVC][1];
    C1[EVC][1] = newECorner+1;
    C1[newCorner][1] = C1[SVC][1];
    C1[SVC][1] = newECorner;
    nC+=2;
    println("Inside this: C[EVC][1]!=-1");
  }
  else
  {
    println("Inside this: C[EVC][1]==-1");
    C1[newCorner][0] = C1[SVC][0];
    C1[newCorner][2] = SVC;
    C1[EVC][1] = newCorner;
    C1[newCorner][1] = C1[SVC][1];
    C1[SVC][1] = EVC;
    nC+=1;
  }
} 
else
{
  if(C1[EVC][1]!=-1)
  {
  C1[SVC][1] = newECorner; 
    C1[newECorner][1] = C1[EVC][1];
   C1[EVC][1] = SVC;
 nC++;
  }
  else
  {
    C1[SVC][1] = EVC;
    C1[EVC][1] = SVC;
  }
}
  
}
}
 

else
{
  if(CountActiveVertices()>1) //to prevent creation of a second vertex in space without any edge (as its not a Euler operation)
  {
    if(isNewSVertex) //check if its a new starting vertex as we can click on an existing vertex, which would remove that vertex and its an acceptable Euler operation
    {
     /* int edgeSIndex = CheckOnEdge(mEnd);
      println("EdgeIndex: "+ edgeSIndex);
      if(edgeSIndex != -1)
      {println("Point is on edge: "+edgeSIndex+","+C[edgeSIndex][1]);
        C[nC][0] = nG-1;
        C[nC-1][1] = C[edgeSIndex][1];
       C[edgeSIndex][1] = nC-1; 
       int nI;
       if(C[C[nC-1][1]][2] == -1)
         nI = C[nC-1][1];
       else
         nI = C[C[nC-1][1]][2];
       C[nC][1] = C[nI][1];
       C[nI][1] = nC;
       C[nC][2] = nC-1;
       C[nC-1][2] = nC;
       nC++;
       println("number of corners : "+nC);
      }
      else
      {*/
      println("Creating extra vertex in space! Not an Euler Operation");
      nG--;
      C1[nC-1][0] = -1;
      C1[nC-1][1] = -1;
      C1[nC-1][2] = -1;
      nC--;
      //}
    }
  }

}
}
}

int CountActiveVertices()
{
  int AV=0;
  for(int i = 0;i <nG;i++)
  {
    if(Vd[i]!=1)
      AV++;
  }
  return AV;
}



void mouseWheel(MouseEvent event) {dz -= event.getAmount(); change=true;}

void mouseMoved() {
  if (keyPressed && key==' ') {rx-=PI*(mouseY-pmouseY)/height; ry+=PI*(mouseX-pmouseX)/width;};
  if (keyPressed && key=='s') dz+=(float)(mouseY-pmouseY); // approach view (same as wheel)
  }
  
void mouseDragged() {
  if(mode == 1)
  {
    mEnd = Mouse1();
  drag = true;
  change=true;
  }
  else
  {
  if (!keyPressed) {O.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); }
  if (keyPressed && key==CODED && keyCode==SHIFT) {O.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0)));};
  if (keyPressed && key=='x') P.movePicked(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='z') P.movePicked(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='X') P.moveAll(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='Z') P.moveAll(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
  if (keyPressed && key=='f') { // move focus point on plane
    if(center) F.sub(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToIJ(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  if (keyPressed && key=='F') { // move focus point vertically
    if(center) F.sub(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    else F.add(ToK(V((float)(mouseX-pmouseX),(float)(mouseY-pmouseY),0))); 
    }
  }
  }  

// **** Header, footer, help text on canvas
void displayHeader() { // Displays title and authors face on screen
    scribeHeader(title,0); scribeHeaderRight(name); 
    fill(white); image(myFace, width-myFace.width/2,25,myFace.width/2,myFace.height/2); 
    }
void displayFooter() { // Displays help text at the bottom
    scribeFooter(guide,1); 
    scribeFooter(menu,0); 
    }

String title ="2014: Polyloop & extrusion editor in 3D", name ="Sonal Mahendru",
       menu="?:hlp, !:pic, ~:film, SPC:rot, s/whl:zoom, f/F:focus, .:on-pick, drag/shift:red, a:anim, _:floor, #:quit",
       guide="q: extrude model in 3d, m: pick nearest corner and show its next and swing, x/z:pick+drag, d:del, i:ins near red, p/q:cpy, e:swap, X/Z:transl, 0:flat, ]:tube, l/L:load, w/W:wrt"; // user's guide


