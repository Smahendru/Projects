void showWalls(){
  int f = 0; //first index of wall
  int s = 0; //second index
  int t = 0; //third index
  int fo = 0; //fourth index
  int k = 0;
  int start;
  for(int i = 0;i<CnV;i++)
  {
   C[i][4] = 0; 
  }
  for(int j = 0;j<n_loops;j++)
  {
    if(j ==0)
       start = 0;
    else
    {fill(green);stroke(brown);
      start = connections[j-1][1]*6;
    }
    //start = 18;
    k = start;
 // println("start: "+start);
  while(k<(CnV - 4*(n_loops-1))) //to prevent the function from accessing bridge corners which are added at the end
  {
    f = C[k][2];
    s = C[f][1];
    t = C[s][1];
    fo = C[t][1];
  /* println("f: "+f+" ; "+(Q.G[C[f][0]].x+Q.G[C[f][0]].y+Q.G[C[f][0]].z));
    println("s: "+s+" ; "+(Q.G[C[s][0]].x+Q.G[C[s][0]].y+Q.G[C[s][0]].z));
    println("t: "+t+" ; "+(Q.G[C[t][0]].x+Q.G[C[t][0]].y+Q.G[C[t][0]].z));
    println("fo: "+fo+" ; "+(Q.G[C[fo][0]].x+Q.G[C[fo][0]].y+Q.G[C[fo][0]].z));
   */beginShape();
    v(Q.G[C[f][0]]);
    v(Q.G[C[s][0]]);
    v(Q.G[C[t][0]]);
    v(Q.G[C[fo][0]]);
   endShape(CLOSE);
   k = fo;
   if(k == start)
     break;
  }
  }
  
  //int n=min(P.nv,Q.nv);
  //for (int i=n-1, j=0; j<n; i=j++) {
    //beginShape(); v(P.G[i]); v(P.G[j]); v(Q.G[j]); v(Q.G[i]); endShape(CLOSE);
    //}
  }
  
  
void drawCeiling()
{
int SC = 3; //since ceiling corners start from 3 and go in multiples of 6 with an offset of 3
int i = SC;
beginShape();
do{
  v(Q.G[C[i][0]]);
  i = C[i][1];
}while(i!=SC);
endShape(CLOSE);
}


void drawFloor()
{
int SC = 2; //since floor corners start from 2 and go in multiples of 6 with an offset of 2
int i = SC;
beginShape();
do{
  v(Q.G[C[i][0]]);
  i = C[i][1];
}while(i!=SC);
endShape(CLOSE);

}
